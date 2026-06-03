import { useEffect, useMemo, useState } from 'react'
import { useNotifications } from '../hooks/useNotifications'
import { buildSchedule, resolveTicker } from '../lib/ticker'
import { DGT, NOTIFICATION_EMOJI } from '../lib/theme'
import type { AppNotification } from '../lib/types'

const TYPE_COLOR: Record<string, string> = {
  fine: DGT.red,
  streak: DGT.orange,
  moab: DGT.yellow,
  zone: DGT.green,
  manual: DGT.primary,
}

// Some notification texts already start with an emoji (e.g. the auto-fine
// "🚔 Multa para X"); we show the type emoji as a badge, so strip a leading
// emoji from the text to avoid duplicates.
const stripLeadingEmoji = (t: string) => t.replace(/^\s*\p{Extended_Pictographic}️?\s*/u, '')

/**
 * Deterministic, write-free ticker (see lib/ticker.ts). Every client renders the
 * same active notification + countdown from the shared notification list and the
 * wall clock — no Firestore writes, no cross-client races.
 */
export function NotificationTicker({ override }: { override?: AppNotification[] }) {
  const live = useNotifications()
  const notifications = override ?? live
  const schedule = useMemo(() => buildSchedule(notifications), [notifications])
  const [now, setNow] = useState(() => Date.now())

  useEffect(() => {
    const t = setInterval(() => setNow(Date.now()), 200)
    return () => clearInterval(t)
  }, [])

  const { active, progress } = resolveTicker(schedule, now)
  if (!active) return null

  const n = active.notification
  const color = TYPE_COLOR[n.type] ?? DGT.primary

  return (
    <div className="ticker" style={{ borderBottomColor: color }}>
      <div className="ticker__body">
        <span className="ticker__emoji">{NOTIFICATION_EMOJI[n.type] ?? '📣'}</span>
        <span className="ticker__text">{stripLeadingEmoji(n.text)}</span>
        {n.imageUrl && <img className="ticker__image" src={n.imageUrl} alt="" />}
      </div>
      <div className="ticker__progress">
        <div
          className="ticker__progress-bar"
          style={{ width: `${Math.min(progress, 1) * 100}%`, background: color }}
        />
      </div>
    </div>
  )
}
