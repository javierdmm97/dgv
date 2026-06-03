import { useEffect, useMemo, useState } from 'react'
import { collection, onSnapshot } from 'firebase/firestore'
import { db } from '../lib/firebase'
import type { LeaderboardEntry, PlayerGameplay, PlayerIdentity } from '../lib/types'

/**
 * Live leaderboard entries for a session.
 *
 * Joins two collections by identical doc id:
 *   - sessions/{id}/players/{pid}  → gameplay (points, titles, readings…)
 *   - players/{pid}                → identity (name, surname, photo)
 * The gameplay doc has no name, so the identity join is required for display.
 */
export function usePlayers(sessionId: string | null) {
  const [gameplay, setGameplay] = useState<PlayerGameplay[]>([])
  const [identities, setIdentities] = useState<Record<string, PlayerIdentity>>({})

  // Identities (top-level players collection) — one listener for the whole game.
  useEffect(() => {
    const unsub = onSnapshot(collection(db, 'players'), (snap) => {
      const map: Record<string, PlayerIdentity> = {}
      snap.forEach((d) => {
        map[d.id] = { id: d.id, ...(d.data() as Omit<PlayerIdentity, 'id'>) }
      })
      setIdentities(map)
    })
    return unsub
  }, [])

  // Session-scoped gameplay docs.
  useEffect(() => {
    if (!sessionId) {
      setGameplay([])
      return
    }
    const unsub = onSnapshot(collection(db, 'sessions', sessionId, 'players'), (snap) => {
      setGameplay(snap.docs.map((d) => ({ id: d.id, ...(d.data() as Omit<PlayerGameplay, 'id'>) })))
    })
    return unsub
  }, [sessionId])

  const entries: LeaderboardEntry[] = useMemo(
    () => gameplay.map((g) => ({ ...g, identity: identities[g.playerId ?? g.id] })),
    [gameplay, identities],
  )

  return entries
}
