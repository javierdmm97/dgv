import { useCallback, useEffect, useState } from 'react'

const KEY = 'dgv:me'

/**
 * "Encuéntrame" — the phone remembers which driver you are (localStorage), so it
 * can pin your carnet and your leaderboard position. Read-only & anonymous: this
 * is just a local preference, never written to Firestore.
 */
export function useMe() {
  const [meId, setMeId] = useState<string | null>(() => {
    try {
      return localStorage.getItem(KEY)
    } catch {
      return null
    }
  })

  useEffect(() => {
    const onStorage = (e: StorageEvent) => {
      if (e.key === KEY) setMeId(e.newValue)
    }
    window.addEventListener('storage', onStorage)
    return () => window.removeEventListener('storage', onStorage)
  }, [])

  const setMe = useCallback((id: string | null) => {
    try {
      if (id) localStorage.setItem(KEY, id)
      else localStorage.removeItem(KEY)
    } catch {
      /* private mode / disabled storage — keep in-memory only */
    }
    setMeId(id)
  }, [])

  return { meId, setMe }
}
