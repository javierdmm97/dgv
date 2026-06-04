import { useEffect, useMemo, useState } from 'react'
import type { AppNotification } from '../../lib/types'
import { buildSchedule, resolveTicker } from '../../lib/ticker'
import { NOTIFICATION_EMOJI } from '../../lib/theme'
import { stripLeadingEmoji } from '../../lib/text'
import styles from './TickerPill.module.css'

/** Compact live ticker for the phone header. Tap → jump to the Tablón tab. */
export function TickerPill({
  notifications,
  onOpen,
}: {
  notifications: AppNotification[]
  onOpen: () => void
}) {
  const schedule = useMemo(() => buildSchedule(notifications), [notifications])
  const [now, setNow] = useState(() => Date.now())
  useEffect(() => {
    const t = setInterval(() => setNow(Date.now()), 300)
    return () => clearInterval(t)
  }, [])

  const { active } = resolveTicker(schedule, now)
  if (!active) return null
  const n = active.notification

  return (
    <button className={styles.pill} data-type={n.type} onClick={onOpen}>
      <span className={styles.emoji}>{NOTIFICATION_EMOJI[n.type] ?? '📣'}</span>
      <span className={styles.text}>{stripLeadingEmoji(n.text)}</span>
      <span className={styles.chev}>›</span>
    </button>
  )
}
