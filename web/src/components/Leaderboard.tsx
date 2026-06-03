import { rankLeaderboard } from '../lib/scoring'
import type { LeaderboardEntry, Session } from '../lib/types'
import { PlayerRow } from './PlayerRow'

export function Leaderboard({
  session,
  players,
  onSelect,
}: {
  session: Session
  players: LeaderboardEntry[]
  onSelect?: (id: string) => void
}) {
  const ranked = rankLeaderboard(players)

  return (
    <section className="leaderboard">
      <header className="leaderboard__header">
        <img className="leaderboard__logo" src="/dgv_logo.png" alt="Operación DGV" />
        <div className="leaderboard__meta">
          <h1>Carnet por Puntos</h1>
          <span>Ronda {session.currentRound}</span>
        </div>
      </header>

      {ranked.length === 0 ? (
        <p className="leaderboard__empty">Sin jugadores todavía…</p>
      ) : (
        <ol className="leaderboard__list">
          {ranked.map((entry, i) => (
            <PlayerRow key={entry.id} entry={entry} rank={i + 1} onSelect={onSelect} />
          ))}
        </ol>
      )}
    </section>
  )
}
