import type { AppNotification, LeaderboardEntry, Session } from '../lib/types'
import { useDisplayMode } from '../hooks/useDisplayMode'
import { Ceremony } from '../components/Ceremony'
import { ProjectorApp } from './ProjectorApp'
import { MobileApp } from './MobileApp'

/** Dispatches the active session to the right view (ceremony / projector / mobile). */
export function MainView({
  session,
  players,
  notifications,
}: {
  session: Session
  players: LeaderboardEntry[]
  notifications: AppNotification[]
}) {
  const mode = useDisplayMode()

  if (session.isFinished) {
    return <Ceremony entries={players} variant={mode} />
  }

  return mode === 'tv' ? (
    <ProjectorApp session={session} players={players} notifications={notifications} />
  ) : (
    <MobileApp session={session} players={players} notifications={notifications} />
  )
}
