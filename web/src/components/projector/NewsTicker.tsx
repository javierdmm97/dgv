import { useEffect, useMemo, useState } from 'react'
import type { AppNotification } from '../../lib/types'
import { buildSchedule, resolveTicker } from '../../lib/ticker'
import { NOTIFICATION_EMOJI } from '../../lib/theme'
import { stripLeadingEmoji } from '../../lib/text'
import styles from './NewsTicker.module.css'

/**
 * Broadcast lower-third. Uses the deterministic, write-free ticker schedule
 * (lib/ticker.ts) so every screen shows the same item at the same time.
 */
export function NewsTicker({ notifications }: { notifications: AppNotification[] }) {
  const schedule = useMemo(() => buildSchedule(notifications), [notifications])
  const [now, setNow] = useState(() => Date.now())

  useEffect(() => {
    const t = setInterval(() => setNow(Date.now()), 200)
    return () => clearInterval(t)
  }, [])

  const { active, progress } = resolveTicker(schedule, now)

  return (
    <div className={styles.news} data-idle={!active || undefined}>
      <span className={styles.kicker}>Última hora</span>
      {active ? (
        <>
          <span className={styles.emoji}>{NOTIFICATION_EMOJI[active.notification.type] ?? '📣'}</span>
          <span className={styles.text}>{stripLeadingEmoji(active.notification.text)}</span>
          <span className={styles.progress} style={{ width: `${Math.min(progress, 1) * 100}%` }} />
        </>
      ) : (
        <span className={styles.text}>Operación DGV · control de alcoholemia en directo</span>
      )}
    </div>
  )
}
