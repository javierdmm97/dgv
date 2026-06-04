import { useActiveSession } from './hooks/useActiveSession'
import { usePlayers } from './hooks/usePlayers'
import { useNotifications } from './hooks/useNotifications'
import { EmptyState } from './components/EmptyState'
import { MainView } from './app/MainView'
import { AdminApp } from './app/AdminApp'
import {
  DEMO_NOTIFICATIONS,
  DEMO_PLAYERS,
  DEMO_SESSION,
  DEMO_SESSION_FINISHED,
} from './lib/demoData'

// ?demo=1 renders sample data; ?demo=ceremony shows the finished-game view.
// ?admin=1 opens the local simulator panel (drives the views without Firestore).
const params =
  typeof window !== 'undefined' ? new URLSearchParams(window.location.search) : new URLSearchParams()
const DEMO = params.has('demo')
const DEMO_CEREMONY = params.get('demo') === 'ceremony'
const ADMIN = params.has('admin')

export default function App() {
  return ADMIN ? <AdminApp /> : <LiveApp />
}

function LiveApp() {
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

  return <MainView session={session} players={players} notifications={notifications} />
}
