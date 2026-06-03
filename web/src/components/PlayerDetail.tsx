import { pointsColor, zoneColor, DGT } from '../lib/theme'
import { perfectionScore } from '../lib/scoring'
import type { LeaderboardEntry } from '../lib/types'
import { BacChart } from './BacChart'

function initials(name?: string, surname?: string) {
  return `${name?.[0] ?? '?'}${surname?.[0] ?? ''}`.toUpperCase()
}

function Stat({ label, value, color }: { label: string; value: string; color?: string }) {
  return (
    <div className="stat">
      <span className="stat__value" style={{ color }}>{value}</span>
      <span className="stat__label">{label}</span>
    </div>
  )
}

export function PlayerDetail({
  entry,
  rank,
  onBack,
}: {
  entry: LeaderboardEntry
  rank: number
  onBack: () => void
}) {
  const id = entry.identity
  const photo = id?.photoUrl ?? entry.photoUrl
  const score = perfectionScore(entry.readings)
  const earned = entry.titleDetails.filter((t) => t.count > 0)
  const rows = [...entry.readings].sort((a, b) => a.roundNumber - b.roundNumber)

  return (
    <section className="detail">
      <header className="detail__top">
        <button className="detail__back" onClick={onBack}>← Volver</button>
      </header>

      <div className="detail__id">
        <div className="detail__avatar" style={{ background: photo ? undefined : DGT.primary }}>
          {photo ? <img src={photo} alt="" /> : <span>{initials(id?.name, id?.surname)}</span>}
        </div>
        <div className="detail__id-text">
          <h1>{id ? `${id.name} ${id.surname}` : entry.playerId}</h1>
          <span>Puesto #{rank}</span>
        </div>
        <div className="detail__points" style={{ color: pointsColor(entry.points) }}>
          {entry.points}
          <small>pts</small>
        </div>
      </div>

      <div className="detail__stats">
        <Stat label="Precisión" value={Number.isFinite(score) ? score.toFixed(3) : '—'} />
        <Stat label="Multas" value={String(entry.fineCount)} color={entry.fineCount > 0 ? DGT.red : undefined} />
        <Stat label="Perdido" value={`${entry.moneyLost} €`} color={entry.moneyLost > 0 ? DGT.red : undefined} />
        {entry.isIncautado && <Stat label="Estado" value="Incautado 🚓" color={DGT.red} />}
      </div>

      <div className="detail__card">
        <h2>Progresión de tasa</h2>
        <BacChart readings={entry.readings} width={720} height={280} />
      </div>

      <div className="detail__card">
        <h2>Títulos DGV</h2>
        {earned.length === 0 ? (
          <p className="detail__muted">Sin títulos todavía</p>
        ) : (
          <ul className="detail__titles">
            {earned.map((t) => (
              <li key={t.key}>
                <span className="detail__title-emoji">{t.emoji}</span>
                <span>{t.displayName}</span>
                <span className="detail__title-count">×{t.count}</span>
              </li>
            ))}
          </ul>
        )}
      </div>

      <div className="detail__card">
        <h2>Mediciones</h2>
        <table className="detail__table">
          <thead>
            <tr>
              <th>Ronda</th>
              <th>Medición</th>
              <th>Objetivo</th>
              <th>Diff</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((r) => {
              const baseline = r.roundNumber === 0
              const diff = r.bac - r.optimalBAC
              return (
                <tr key={r.id}>
                  <td>R{r.roundNumber}</td>
                  <td>{r.bac.toFixed(2)} mg/L</td>
                  <td>{baseline ? '—' : `${r.optimalBAC.toFixed(2)} mg/L`}</td>
                  <td style={{ color: baseline ? undefined : zoneColor(r.bac, r.optimalBAC), fontWeight: 600 }}>
                    {baseline ? '—' : `${diff >= 0 ? '+' : ''}${diff.toFixed(2)}`}
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>
    </section>
  )
}
