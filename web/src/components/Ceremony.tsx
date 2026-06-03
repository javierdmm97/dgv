import type { Ceremony as CeremonyData } from '../lib/types'

const MEDALS = ['🥇', '🥈', '🥉']

/**
 * End-of-game ceremony. All categories are precomputed by the app and stored on
 * sessions/{id}.ceremony — render directly, no recomputation.
 */
export function Ceremony({ ceremony }: { ceremony: CeremonyData }) {
  return (
    <section className="ceremony">
      <h1 className="ceremony__title">🏁 Ceremonia Final</h1>

      <div className="ceremony__podium">
        {ceremony.podium.map((p, i) => (
          <div key={p.playerId} className={`podium podium--${p.rank}`}>
            <div className="podium__medal">{MEDALS[i] ?? p.rank}</div>
            <div className="podium__name">{p.name} {p.surname}</div>
            <div className="podium__points">{p.points} pts</div>
          </div>
        ))}
      </div>

      {ceremony.coleccionista && (
        <div className="ceremony__card">
          <h2>👑 El Coleccionista de Títulos</h2>
          <p>
            {ceremony.coleccionista.name} {ceremony.coleccionista.surname} —{' '}
            {ceremony.coleccionista.totalTitles} títulos
          </p>
        </div>
      )}

      <div className="ceremony__card">
        <h2>🏭 Los Más Contaminantes</h2>
        <ol className="ceremony__env">
          {ceremony.environmentals.map((e) => (
            <li key={e.playerId}>
              <span className="ceremony__sticker">{e.stickerKey.replace(/_/g, ' ')}</span>
              <span>{e.name} {e.surname}</span>
              <span>{e.maxBAC.toFixed(2)} mg/L</span>
            </li>
          ))}
        </ol>
      </div>
    </section>
  )
}
