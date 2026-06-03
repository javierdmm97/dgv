import { pointsColor, zoneColor } from '../lib/theme'
import { lastReading } from '../lib/scoring'
import type { LeaderboardEntry } from '../lib/types'
import { BacChart } from './BacChart'

const MEDALS = ['🥇', '🥈', '🥉']

function initials(name?: string, surname?: string) {
  return `${name?.[0] ?? '?'}${surname?.[0] ?? ''}`.toUpperCase()
}

export function PlayerRow({
  entry,
  rank,
  onSelect,
}: {
  entry: LeaderboardEntry
  rank: number
  onSelect?: (id: string) => void
}) {
  const id = entry.identity
  const photo = id?.photoUrl ?? entry.photoUrl
  const last = lastReading(entry.readings)
  const medal = rank <= 3 ? MEDALS[rank - 1] : null
  const clickable = Boolean(onSelect)

  return (
    <li
      className={clickable ? 'row row--clickable' : 'row'}
      onClick={clickable ? () => onSelect!(entry.id) : undefined}
      role={clickable ? 'button' : undefined}
      tabIndex={clickable ? 0 : undefined}
      onKeyDown={clickable ? (e) => (e.key === 'Enter' || e.key === ' ') && onSelect!(entry.id) : undefined}
    >
      <div className="row__rank">{medal ?? rank}</div>

      <div className="row__avatar" style={{ background: photo ? undefined : 'var(--dgt-primary)' }}>
        {photo ? <img src={photo} alt="" /> : <span>{initials(id?.name, id?.surname)}</span>}
      </div>

      <div className="row__main">
        <div className="row__name">
          {id ? `${id.name} ${id.surname}` : entry.playerId}
        </div>
        <div className="row__sub">
          {last
            ? `Último: ${last.bac.toFixed(2)} mg/L · Ronda ${last.roundNumber}`
            : 'Sin mediciones'}
          {entry.fineCount > 0 && (
            <span className="row__fine"> · 🚗 {entry.fineCount} multa(s) · {entry.moneyLost} €</span>
          )}
          {entry.isIncautado && <span className="row__fine"> · 🚓 Incautado</span>}
        </div>
        <div className="row__titles">
          {entry.titleDetails
            .filter((t) => t.count > 0)
            .map((t) => (
              <span key={t.key} className="badge" title={t.displayName}>
                {t.emoji} ×{t.count}
              </span>
            ))}
        </div>
      </div>

      <div className="row__chart">
        <BacChart readings={entry.readings} compact width={180} height={48} />
      </div>

      <div className="row__points" style={{ color: pointsColor(entry.points) }}>
        {entry.points}
        <span className="row__points-unit">pts</span>
      </div>

      {last && (
        <div
          className="row__zone"
          title={`Objetivo: ${last.optimalBAC.toFixed(2)} mg/L`}
          style={{ background: zoneColor(last.bac, last.optimalBAC) }}
        />
      )}
    </li>
  )
}
