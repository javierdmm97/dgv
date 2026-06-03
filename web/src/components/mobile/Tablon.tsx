import type { AppNotification } from '../../lib/types'
import { NOTIFICATION_EMOJI } from '../../lib/theme'
import { stripLeadingEmoji } from '../../lib/text'
import styles from './Tablon.module.css'

function ago(ts: AppNotification['timestamp']): string {
  const ms = Date.now() - (ts?.toMillis?.() ?? 0)
  const min = Math.floor(ms / 60_000)
  if (min < 1) return 'ahora'
  if (min < 60) return `hace ${min} min`
  const h = Math.floor(min / 60)
  return `hace ${h} h`
}

/** Notification feed (newest first). */
export function Tablon({ notifications }: { notifications: AppNotification[] }) {
  const sorted = [...notifications].sort(
    (a, b) => (b.timestamp?.toMillis?.() ?? 0) - (a.timestamp?.toMillis?.() ?? 0),
  )

  if (sorted.length === 0) {
    return <div className={styles.empty}>El tablón está tranquilo… de momento.</div>
  }

  return (
    <ul className={styles.feed}>
      {sorted.map((n) => (
        <li key={n.id} className={styles.item} data-type={n.type}>
          <span className={styles.emoji}>{NOTIFICATION_EMOJI[n.type] ?? '📣'}</span>
          <div className={styles.body}>
            <p className={styles.text}>{stripLeadingEmoji(n.text)}</p>
            <time className={styles.time}>{ago(n.timestamp)}</time>
          </div>
        </li>
      ))}
    </ul>
  )
}
