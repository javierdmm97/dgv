import { useEffect, useMemo, useState } from 'react'
import type { AppNotification } from '../../lib/types'
import { DISPLAY_MS } from '../../lib/ticker'
import { NOTIFICATION_EMOJI } from '../../lib/theme'
import { stripLeadingEmoji } from '../../lib/text'
import styles from './NewsTicker.module.css'

/**
 * Broadcast lower-third — a circular carousel of the last 3 notifications, so
 * there is ALWAYS one on screen. The index is derived from the wall clock
 * (floor(now / DISPLAY_MS) % n), so every screen shows the same item in sync
 * without any Firestore writes.
 */
export function NewsTicker({ notifications }: { notifications: AppNotification[] }) {
  const items = useMemo(
    () =>
      [...notifications]
        .sort((a, b) => (a.timestamp?.toMillis?.() ?? 0) - (b.timestamp?.toMillis?.() ?? 0))
        .slice(-3),
    [notifications],
  )

  const [now, setNow] = useState(() => Date.now())
  useEffect(() => {
    const t = setInterval(() => setNow(Date.now()), 200)
    return () => clearInterval(t)
  }, [])

  if (items.length === 0) {
    return (
      <div className={styles.news} data-idle>
        <span className={styles.kicker}>Última hora</span>
        <span className={styles.text}>Operación DGV · control de alcoholemia en directo</span>
      </div>
    )
  }

  const idx = Math.floor(now / DISPLAY_MS) % items.length
  const n = items[idx]
  const progress = (now % DISPLAY_MS) / DISPLAY_MS

  return (
    <div className={styles.news}>
      <span className={styles.kicker}>Última hora</span>
      <div key={n.id} className={styles.item}>
        <span className={styles.emoji}>{NOTIFICATION_EMOJI[n.type] ?? '📣'}</span>
        <span className={styles.text}>{stripLeadingEmoji(n.text)}</span>
      </div>
      <span className={styles.progress} style={{ width: `${Math.min(progress, 1) * 100}%` }} />
    </div>
  )
}
