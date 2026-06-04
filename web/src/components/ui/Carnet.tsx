import { useState } from 'react'
import type { LeaderboardEntry } from '../../lib/types'
import { perfectionScore } from '../../lib/scoring'
import { maxBac } from '../../lib/leaderboard'
import { stickerForRank } from '../../lib/awards'
import { TitleBadge } from './TitleBadge'
import { DistintivoAmbiental } from './DistintivoAmbiental'
import { StampIncautado } from './StampIncautado'
import styles from './Carnet.module.css'

interface CarnetProps {
  entry: LeaderboardEntry
  /** Podium medal (1–3) baked onto the permit, ceremony only. */
  medal?: 1 | 2 | 3
  /** Crown for "coleccionista de títulos". */
  coleccionista?: boolean
  /** Environmental sticker rank (1–5) for the back; omit to hide. */
  envRank?: number
  flippable?: boolean
}

const MEDAL = { 1: '🥇', 2: '🥈', 3: '🥉' } as const

function CarnetFront({ entry, medal, coleccionista }: Omit<CarnetProps, 'flippable' | 'envRank'>) {
  const id = entry.identity
  const name = id ? `${id.name} ${id.surname}` : 'Conductor anónimo'
  const photo = id?.photoUrl ?? entry.photoUrl
  const scored = entry.readings.filter((r) => r.roundNumber > 0).length
  const precision = perfectionScore(entry.readings)
  const precisionTxt = Number.isFinite(precision) ? precision.toFixed(2) : '—'

  return (
    <div className={styles.face} data-side="front">
      <img className={styles.bg} src="/license/front.webp" alt="" />

      <div className={styles.photo}>
        {photo ? (
          <img src={photo} alt="" />
        ) : (
          <span className={styles.photoInitials}>
            {(id?.name?.[0] ?? '') + (id?.surname?.[0] ?? '') || '··'}
          </span>
        )}
      </div>

      <div className={styles.name} title={name}>
        {name}
      </div>
      <div className={styles.points}>
        <span className="tnum">{entry.points}</span> puntos
      </div>
      <div className={styles.meta1}>
        Rondas: <span className="tnum">{scored}</span> · Lecturas:{' '}
        <span className="tnum">{entry.readings.length}</span>
      </div>
      <div className={styles.meta2}>
        Perdido: <span className="tnum">{entry.moneyLost}</span> € · Precisión:{' '}
        <span className="tnum">{precisionTxt}</span>
      </div>
      {entry.fineCount > 0 && (
        <div className={styles.fines}>
          🚗 <span className="tnum">{entry.fineCount}</span>{' '}
          {entry.fineCount === 1 ? 'multa' : 'multas'}
        </div>
      )}

      {entry.titleDetails.length > 0 && (
        <div className={styles.titles}>
          {entry.titleDetails.map((t) => (
            <TitleBadge key={t.key} detail={t} size={26} />
          ))}
        </div>
      )}

      {medal && <div className={styles.medal}>{MEDAL[medal]}</div>}
      {coleccionista && <div className={styles.crown}>👑</div>}

      {entry.isIncautado && (
        <div className={styles.stamp}>
          <StampIncautado />
        </div>
      )}
    </div>
  )
}

function CarnetBack({ entry, envRank }: Pick<CarnetProps, 'entry' | 'envRank'>) {
  const scored = entry.readings
    .filter((r) => r.roundNumber > 0)
    .sort((a, b) => a.roundNumber - b.roundNumber)
  const precision = perfectionScore(entry.readings)
  const precisionTxt = Number.isFinite(precision) ? precision.toFixed(2) : '—'
  const sticker = envRank ? stickerForRank(envRank) : null

  return (
    <div className={styles.face} data-side="back">
      <img className={styles.bg} src="/license/back.webp" alt="" />

      <div className={styles.annex}>
        <div className={styles.annexHead}>Anexo · Historial</div>
        <ul className={styles.history}>
          {scored.length === 0 && <li className={styles.histEmpty}>Sin mediciones todavía</li>}
          {scored.map((r) => {
            const up = r.pointsChange > 0
            const flat = r.pointsChange === 0
            return (
              <li key={r.id}>
                <span className={styles.histRound}>R{r.roundNumber}</span>
                <span className="tnum">{r.bac.toFixed(2)}</span>
                <span className={styles.histPts} data-dir={up ? 'up' : flat ? 'flat' : 'down'}>
                  {up ? '▲' : flat ? '·' : '▼'} {r.pointsChange > 0 ? '+' : ''}
                  {r.pointsChange}
                </span>
              </li>
            )
          })}
        </ul>
        <div className={styles.annexTotals}>
          <span>
            Perdido <b className="tnum">{entry.moneyLost}€</b>
          </span>
          <span>
            Precisión <b className="tnum">{precisionTxt}</b>
          </span>
        </div>
        {sticker && (
          <div className={styles.annexSticker}>
            <DistintivoAmbiental stickerKey={sticker} size={40} showLabel />
            <span className={styles.annexMax}>
              BAC máx <b className="tnum">{maxBac(entry.readings).toFixed(2)}</b>
            </span>
          </div>
        )}
      </div>
    </div>
  )
}

/** The satirical Spanish driving permit, faithful to the app's template + data. */
export function Carnet({ entry, medal, coleccionista, envRank, flippable = true }: CarnetProps) {
  const [flipped, setFlipped] = useState(false)
  return (
    <div className={styles.scene}>
      <div className={styles.card} data-flipped={flipped || undefined}>
        <div className={styles.front} aria-hidden={flipped}>
          <CarnetFront entry={entry} medal={medal} coleccionista={coleccionista} />
        </div>
        <div className={styles.back} aria-hidden={!flipped}>
          <CarnetBack entry={entry} envRank={envRank} />
        </div>
      </div>
      {flippable && (
        <button className={styles.flip} onClick={() => setFlipped((f) => !f)}>
          {flipped ? 'Ver anverso' : 'Ver reverso'} ⟳
        </button>
      )}
    </div>
  )
}
