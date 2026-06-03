import { useEffect, useState } from 'react'
import { collection, onSnapshot, orderBy, query } from 'firebase/firestore'
import { db } from '../lib/firebase'
import type { AppNotification } from '../lib/types'

/**
 * All notifications, ordered by timestamp. The ticker derives what's currently
 * on screen purely from this list + the wall clock (see lib/ticker.ts), so the
 * web never writes back a `read` status.
 */
export function useNotifications() {
  const [notifications, setNotifications] = useState<AppNotification[]>([])

  useEffect(() => {
    const q = query(collection(db, 'notifications'), orderBy('timestamp', 'asc'))
    const unsub = onSnapshot(
      q,
      (snap) => {
        setNotifications(
          snap.docs.map((d) => ({ id: d.id, ...(d.data() as Omit<AppNotification, 'id'>) })),
        )
      },
      (err) => console.error('[useNotifications]', err),
    )
    return unsub
  }, [])

  return notifications
}
