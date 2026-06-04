import { useMemo } from 'react'
import type { LeaderboardEntry } from '../lib/types'
import { perfectionScore } from '../lib/scoring'
import { coleccionista, environmentals, podium } from '../lib/awards'
import { totalTitles } from '../lib/leaderboard'
import type { DisplayMode } from '../hooks/useDisplayMode'
import { Crest } from './ui/Crest'
import { ThemeToggle } from './ui/ThemeToggle'
import { Avatar } from './ui/Avatar'
import { Plate } from './ui/Plate'
import { DistintivoAmbiental } from './ui/DistintivoAmbiental'
import styles from './Ceremony.module.css'

const MEDAL = ['🥇', '🥈', '🥉']
const fullName = (e: LeaderboardEntry) =>
  e.identity ? `${e.identity.name} ${e.identity.surname}` : 'Conductor'

function precisionAbsoluta(entries: LeaderboardEntry[]): LeaderboardEntry | null {
  const eligible = entries.filter(
    (e) => !e.isIncautado && e.readings.some((r) => r.roundNumber > 0),
  )
  if (eligible.length === 0) return null
  return eligible.reduce((best, e) =>
    perfectionScore(e.readings) < perfectionScore(best.readings) ? e : best,
  )
}

/** End-of-game ceremony. Derives every category from the entries (lib/awards). */
export function Ceremony({
  entries,
  variant = 'tv',
}: {
  entries: LeaderboardEntry[]
  variant?: DisplayMode
}) {
  const top3 = useMemo(() => podium(entries), [entries])
  const env = useMemo(() => environmentals(entries), [entries])
  const colec = useMemo(() => coleccionista(entries), [entries])
  const precise = useMemo(() => precisionAbsoluta(entries), [entries])

  // Podium display order: 2 · 1 · 3 (winner centered, raised).
  const order = [top3[1], top3[0], top3[2]].filter(Boolean) as LeaderboardEntry[]

  return (
    <div className={styles.wrap} data-variant={variant}>
      <div className={styles.corner}>
        <ThemeToggle />
      </div>
      <header className={styles.header}>
        <Crest subtitle="Acta final del operativo" />
        <h1 className={styles.title}>Ceremonia de clausura</h1>
      </header>

      <section className={styles.podium}>
        {order.map((e) => {
          const rank = top3.findIndex((p) => p.id === e.id) + 1
          return (
            <div key={e.id} className={styles.step} data-rank={rank}>
              <div className={styles.medal}>{MEDAL[rank - 1]}</div>
              <Avatar
                photoUrl={e.identity?.photoUrl ?? e.photoUrl}
                name={e.identity?.name}
                surname={e.identity?.surname}
                size={rank === 1 ? 92 : 72}
              />
              <div className={styles.stepName}>{fullName(e)}</div>
              <Plate id={e.id} name={e.identity?.name} surname={e.identity?.surname} size="sm" />
              <div className={styles.stepPoints}>
                <span className="tnum">{e.points}</span> pts
              </div>
              <div className={styles.pedestal} data-rank={rank}>
                {rank}º
              </div>
            </div>
          )
        })}
      </section>

      <section className={styles.prizes}>
        {top3[0] && (
          <PrizeCard emoji="🏆" title="Conductor Perfecto" name={fullName(top3[0])} detail={`${top3[0].points} puntos`} />
        )}
        {precise && (
          <PrizeCard
            emoji="🎯"
            title="Precisión Absoluta"
            name={fullName(precise)}
            detail={`Precisión ${perfectionScore(precise.readings).toFixed(2)}`}
          />
        )}
        {colec && (
          <PrizeCard
            emoji="👑"
            title="Coleccionista de Títulos"
            name={fullName(colec)}
            detail={`${totalTitles(colec)} distinciones`}
          />
        )}
      </section>

      <section className={styles.envCard}>
        <h2 className={styles.envTitle}>🏭 Los más contaminantes</h2>
        <ol className={styles.envList}>
          {env.map((e) => (
            <li key={e.entry.id} className={styles.envRow}>
              <span className={styles.envRank}>{e.rank}º</span>
              <DistintivoAmbiental stickerKey={e.stickerKey} size={44} />
              <span className={styles.envName}>{fullName(e.entry)}</span>
              <span className={styles.envBac}>
                <span className="tnum">{e.maxBAC.toFixed(2)}</span> mg/L
              </span>
            </li>
          ))}
        </ol>
      </section>
    </div>
  )
}

function PrizeCard({
  emoji,
  title,
  name,
  detail,
}: {
  emoji: string
  title: string
  name: string
  detail: string
}) {
  return (
    <div className={styles.prize}>
      <span className={styles.prizeEmoji}>{emoji}</span>
      <span className={styles.prizeTitle}>{title}</span>
      <span className={styles.prizeName}>{name}</span>
      <span className={styles.prizeDetail}>{detail}</span>
    </div>
  )
}
