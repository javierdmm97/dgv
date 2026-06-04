import type { LeaderboardEntry } from '../../lib/types'
import { perfectionScore } from '../../lib/scoring'
import { Carnet } from '../ui/Carnet'
import { BacChart } from '../BacChart'
import { TitleBadge } from '../ui/TitleBadge'
import styles from './CarnetView.module.css'

function Stat({ value, label, tone }: { value: string; label: string; tone?: 'red' }) {
  return (
    <div className={styles.stat} data-tone={tone}>
      <span className={styles.statValue}>{value}</span>
      <span className={styles.statLabel}>{label}</span>
    </div>
  )
}

/** Full driver detail: the satirical permit + stats + BAC chart + distinctions. */
export function CarnetView({
  entry,
  rank,
  envRank,
  onBack,
  isMe,
  onToggleMe,
}: {
  entry: LeaderboardEntry
  rank: number
  envRank?: number
  onBack?: () => void
  isMe?: boolean
  onToggleMe?: () => void
}) {
  const id = entry.identity
  const name = id ? `${id.name} ${id.surname}` : 'Conductor'
  const precision = perfectionScore(entry.readings)
  const precisionTxt = Number.isFinite(precision) ? precision.toFixed(2) : '—'

  return (
    <div className={styles.view}>
      {onBack && (
        <button className={styles.back} onClick={onBack}>
          ‹ Clasificación
        </button>
      )}

      <div className={styles.idline}>
        {!entry.isIncautado && <span className={styles.rank}>#{rank}</span>}
        <h1 className={styles.name}>{name}</h1>
      </div>

      <Carnet entry={entry} envRank={envRank} />

      {onToggleMe && (
        <button className={styles.meToggle} data-on={isMe || undefined} onClick={onToggleMe}>
          {isMe ? '✕ Este no soy yo' : '⊕ Soy yo · fijar mi carnet'}
        </button>
      )}

      {entry.isIncautado && (
        <div className={styles.incauted}>🚗 Vehículo incautado — fuera de la clasificación</div>
      )}

      <div className={styles.stats}>
        <Stat value={String(entry.points)} label="Puntos" />
        <Stat value={String(entry.fineCount)} label="Multas" tone={entry.fineCount > 0 ? 'red' : undefined} />
        <Stat value={`${entry.moneyLost} €`} label="Perdido" tone={entry.moneyLost > 0 ? 'red' : undefined} />
        <Stat value={precisionTxt} label="Precisión" />
      </div>

      <section className={styles.panel}>
        <h2 className={styles.panelTitle}>Progresión de tasa</h2>
        <BacChart readings={entry.readings} width={520} height={240} />
      </section>

      {entry.titleDetails.length > 0 && (
        <section className={styles.panel}>
          <h2 className={styles.panelTitle}>Distinciones</h2>
          <ul className={styles.titles}>
            {entry.titleDetails.map((t) => (
              <li key={t.key} className={styles.titleRow}>
                <TitleBadge detail={t} size={34} showCount={false} />
                <span className={styles.titleName}>{t.displayName}</span>
                <span className={styles.titleCount}>×{t.count}</span>
              </li>
            ))}
          </ul>
        </section>
      )}
    </div>
  )
}
