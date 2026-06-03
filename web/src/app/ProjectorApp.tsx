import { useMemo } from 'react'
import type { AppNotification, LeaderboardEntry, Session } from '../lib/types'
import { countInZone, incautados, rankRows } from '../lib/leaderboard'
import { TopBar } from '../components/projector/TopBar'
import { CommandLeaderboard } from '../components/projector/CommandLeaderboard'
import { SidePanel } from '../components/projector/SidePanel'
import { NewsTicker } from '../components/projector/NewsTicker'
import { SirenController } from '../components/SirenController'
import styles from './ProjectorApp.module.css'

/** The "Centro de Control" broadcast view (projector / big screen). */
export function ProjectorApp({
  session,
  players,
  notifications,
}: {
  session: Session
  players: LeaderboardEntry[]
  notifications: AppNotification[]
}) {
  const rows = useMemo(() => rankRows(players), [players])
  const inc = useMemo(() => incautados(players), [players])
  const inZone = countInZone(rows)

  return (
    <div className={styles.app}>
      <TopBar round={session.currentRound} drivers={rows.length} inZone={inZone} incautados={inc.length} />
      <div className={styles.body}>
        <main className={styles.main}>
          <CommandLeaderboard rows={rows} incautados={inc} />
        </main>
        <aside className={styles.aside}>
          <SidePanel rows={rows} notifications={notifications} />
        </aside>
      </div>
      <NewsTicker notifications={notifications} />
      <SirenController session={session} variant="tv" />
    </div>
  )
}
