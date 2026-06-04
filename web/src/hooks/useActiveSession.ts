import { useEffect, useState } from 'react'
import { collection, limit, onSnapshot, orderBy, query } from 'firebase/firestore'
import { db } from '../lib/firebase'
import type { Session } from '../lib/types'

/**
 * Subscribe to the current session.
 *
 * There is no explicit "active session" pointer in Firestore, so we listen to
 * the most recent sessions by startTime and pick the first one still in progress
 * (falling back to the latest finished one so the ceremony stays on screen).
 * Ordering by a single field avoids needing a composite index.
 *
 * TODO(app): consider writing a `config/current` pointer doc from the app to make
 * this unambiguous (abandoned games never reset isInProgress).
 */
export function useActiveSession() {
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    const q = query(collection(db, 'sessions'), orderBy('startTime', 'desc'), limit(5))
    const unsub = onSnapshot(
      q,
      (snap) => {
        const sessions = snap.docs.map((d) => ({ id: d.id, ...d.data() }) as Session)
        const active = sessions.find((s) => s.isInProgress) ?? sessions[0] ?? null
        setSession(active)
        setError(null)
        setLoading(false)
      },
      (err) => {
        console.error('[useActiveSession]', err)
        setError(err as Error)
        setLoading(false)
      },
    )
    return unsub
  }, [])

  return { session, loading, error }
}
