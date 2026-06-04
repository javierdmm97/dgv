import { SimulatorProvider, useSimulator } from '../admin/SimulatorContext'
import { AdminPanel } from '../admin/AdminPanel'
import { MainView } from './MainView'

function AdminInner() {
  const sim = useSimulator()
  return (
    <>
      <MainView session={sim.session} players={sim.players} notifications={sim.notifications} />
      <AdminPanel />
    </>
  )
}

/** ?admin=1 — drives the real views from a local simulator (no Firestore writes). */
export function AdminApp() {
  return (
    <SimulatorProvider>
      <AdminInner />
    </SimulatorProvider>
  )
}
