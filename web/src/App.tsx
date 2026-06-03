import { useActiveSession } from './hooks/useActiveSession'
import { usePlayers } from './hooks/usePlayers'
import { useNotifications } from './hooks/useNotifications'
import { useDisplayMode } from './hooks/useDisplayMode'
import { EmptyState } from './components/EmptyState'
import { Ceremony } from './components/Ceremony'
import { ProjectorApp } from './app/ProjectorApp'
import { MobileApp } from './app/MobileApp'
import {
  DEMO_NOTIFICATIONS,
  DEMO_PLAYERS,
  DEMO_SESSION,
  DEMO_SESSION_FINISHED,
} from './lib/demoData'

// ?demo=1 renders sample data; ?demo=ceremony shows the finished-game view.
const params =
  typeof window !== 'undefined' ? new URLSearchParams(window.location.search) : new URLSearchParams()
const DEMO = params.has('demo')
const DEMO_CEREMONY = params.get('demo') === 'ceremony'

export default function App() {
  const mode = useDisplayMode()
  const { session: liveSession, loading, error } = useActiveSession()
  const livePlayers = usePlayers(liveSession?.id ?? null)
  const liveNotifications = useNotifications()

  const session = DEMO ? (DEMO_CEREMONY ? DEMO_SESSION_FINISHED : DEMO_SESSION) : liveSession
  const players = DEMO ? DEMO_PLAYERS : livePlayers
  const notifications = DEMO ? DEMO_NOTIFICATIONS : liveNotifications

  if (!DEMO && loading) {
    return <EmptyState title="Conectando…" subtitle="Estableciendo enlace con el control DGV" />
  }
  if (!DEMO && error && !liveSession) {
    return (
      <EmptyState
        tone="error"
        title="Error de conexión"
        subtitle="No se pudo enlazar con el servidor. Reintentando automáticamente…"
      />
    )
  }
  if (!session) {
    return (
      <EmptyState
        title="Sin partida activa"
        subtitle="Esperando a que empiece el control de alcoholemia"
      />
    )
  }

  if (session.isFinished && session.ceremony) {
    return <Ceremony entries={players} variant={mode} />
  }

  return mode === 'tv' ? (
    <ProjectorApp session={session} players={players} notifications={notifications} />
  ) : (
    <MobileApp session={session} players={players} notifications={notifications} />
  )
}
