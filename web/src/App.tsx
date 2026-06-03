import { useState } from 'react'
import { useActiveSession } from './hooks/useActiveSession'
import { usePlayers } from './hooks/usePlayers'
import { rankLeaderboard } from './lib/scoring'
import { Leaderboard } from './components/Leaderboard'
import { PlayerDetail } from './components/PlayerDetail'
import { NotificationTicker } from './components/NotificationTicker'
import { Ceremony } from './components/Ceremony'
import { AudioController } from './components/AudioController'
import { EmptyState } from './components/EmptyState'
import { DEMO_NOTIFICATIONS, DEMO_PLAYERS, DEMO_SESSION } from './lib/demoData'

// ?demo=1 renders sample data for visual review without a live Firestore game.
const DEMO = typeof window !== 'undefined' && new URLSearchParams(window.location.search).has('demo')

export default function App() {
  const { session: liveSession, loading } = useActiveSession()
  const livePlayers = usePlayers(liveSession?.id ?? null)
  const [selectedId, setSelectedId] = useState<string | null>(null)

  const session = DEMO ? DEMO_SESSION : liveSession
  const players = DEMO ? DEMO_PLAYERS : livePlayers

  if (!DEMO && loading) return <EmptyState title="Conectando…" />
  if (!session) {
    return <EmptyState title="Sin partida activa" subtitle="Esperando a que empiece el control de alcoholemia…" />
  }

  const showCeremony = session.isFinished && session.ceremony
  const ranked = rankLeaderboard(players)
  const selectedIndex = selectedId ? ranked.findIndex((p) => p.id === selectedId) : -1
  const selected = selectedIndex >= 0 ? ranked[selectedIndex] : null

  return (
    <div className="app">
      {!showCeremony && !selected && <NotificationTicker override={DEMO ? DEMO_NOTIFICATIONS : undefined} />}
      <main className="app__main">
        {showCeremony ? (
          <Ceremony ceremony={session.ceremony!} />
        ) : selected ? (
          <PlayerDetail entry={selected} rank={selectedIndex + 1} onBack={() => setSelectedId(null)} />
        ) : (
          <Leaderboard session={session} players={players} onSelect={setSelectedId} />
        )}
      </main>
      <AudioController session={session} />
    </div>
  )
}
