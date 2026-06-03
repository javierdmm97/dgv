import type { AppNotification } from '../../lib/types'
import { Crest } from '../ui/Crest'
import { TickerPill } from './TickerPill'
import styles from './MobileHeader.module.css'

export function MobileHeader({
  round,
  notifications,
  onOpenTablon,
}: {
  round: number
  notifications: AppNotification[]
  onOpenTablon: () => void
}) {
  return (
    <header className={styles.header}>
      <div className={styles.top}>
        <Crest compact subtitle="Control de alcoholemia" />
        <span className={styles.live}>
          <span className="live-dot" /> En vivo · R<b className="tnum">{round}</b>
        </span>
      </div>
      <TickerPill notifications={notifications} onOpen={onOpenTablon} />
    </header>
  )
}
