import { useMemo, useState } from 'react'
import type { AppNotification, LeaderboardEntry, Session } from '../lib/types'
import { incautados, rankRows } from '../lib/leaderboard'
import { environmentals } from '../lib/awards'
import { useMe } from '../hooks/useMe'
import { MobileHeader } from '../components/mobile/MobileHeader'
import { SegmentedNav, type MobileTab } from '../components/mobile/SegmentedNav'
import { Clasificacion } from '../components/mobile/Clasificacion'
import { CarnetView } from '../components/mobile/CarnetView'
import { FindMeSheet } from '../components/mobile/FindMeSheet'
import { Tablon } from '../components/mobile/Tablon'
import { SirenController } from '../components/SirenController'
import styles from './MobileApp.module.css'

/** The personal "tu carnet en el bolsillo" experience (phone). */
export function MobileApp({
  session,
  players,
  notifications,
}: {
  session: Session
  players: LeaderboardEntry[]
  notifications: AppNotification[]
}) {
  const { meId, setMe } = useMe()
  const [tab, setTab] = useState<MobileTab>('clasificacion')
  const [selectedId, setSelectedId] = useState<string | null>(null)

  const rows = useMemo(() => rankRows(players), [players])
  const inc = useMemo(() => incautados(players), [players])
  const envRankById = useMemo(() => {
    const map = new Map<string, number>()
    environmentals(players).forEach((e) => map.set(e.entry.id, e.rank))
    return map
  }, [players])

  const byId = (id: string | null): LeaderboardEntry | null =>
    id ? players.find((p) => p.id === id) ?? null : null
  const rankOf = (id: string) => {
    const i = rows.findIndex((r) => r.entry.id === id)
    return i >= 0 ? i + 1 : 0
  }

  // A tapped driver opens a full-screen detail over the tabs. SirenController is
  // mounted once at the bottom (stable across navigation) so its audio-unlock
  // popup never re-appears when switching views.
  const selected = byId(selectedId)
  const meEntry = byId(meId)

  return (
    <div className={styles.app}>
      {selected ? (
        <main className={styles.detail}>
          <CarnetView
            entry={selected}
            rank={rankOf(selected.id)}
            envRank={envRankById.get(selected.id)}
            onBack={() => setSelectedId(null)}
            isMe={meId === selected.id}
            onToggleMe={() => setMe(meId === selected.id ? null : selected.id)}
          />
        </main>
      ) : (
        <>
          <MobileHeader
            round={session.currentRound}
            notifications={notifications}
            onOpenTablon={() => setTab('tablon')}
          />
          <SegmentedNav value={tab} onChange={setTab} hasMe={!!meEntry} />

          <main className={styles.main}>
            {tab === 'clasificacion' && (
              <Clasificacion rows={rows} incautados={inc} meId={meId} onSelect={setSelectedId} />
            )}
            {tab === 'carnet' &&
              (meEntry ? (
                <CarnetView
                  entry={meEntry}
                  rank={rankOf(meEntry.id)}
                  envRank={envRankById.get(meEntry.id)}
                  isMe
                  onToggleMe={() => setMe(null)}
                />
              ) : (
                <FindMeSheet entries={players} onPick={(id) => setMe(id)} />
              ))}
            {tab === 'tablon' && <Tablon notifications={notifications} />}
          </main>
        </>
      )}

      <SirenController session={session} variant="mobile" />
    </div>
  )
}
