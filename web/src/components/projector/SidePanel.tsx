import { useEffect, useState } from 'react'
import type { Row } from '../../lib/leaderboard'
import type { AppNotification } from '../../lib/types'
import { NOTIFICATION_EMOJI } from '../../lib/theme'
import { stripLeadingEmoji } from '../../lib/text'
import { Carnet } from '../ui/Carnet'
import styles from './SidePanel.module.css'

const FOCO_MS = 12_000

function FocoRotatorio({ rows }: { rows: Row[] }) {
  const [i, setI] = useState(0)
  useEffect(() => {
    if (rows.length < 2) return
    const t = setInterval(() => setI((x) => (x + 1) % rows.length), FOCO_MS)
    return () => clearInterval(t)
  }, [rows.length])

  const row = rows[Math.min(i, rows.length - 1)]
  if (!row) return null
  const id = row.entry.identity

  return (
    <div className={styles.panel}>
      <div className={styles.head}>
        <span className={styles.headMark}>▸</span> Foco
      </div>
      <div className={styles.focoCard} key={row.entry.id}>
        <Carnet entry={row.entry} flippable={false} medal={row.rank <= 3 ? (row.rank as 1 | 2 | 3) : undefined} />
        <div className={styles.focoCaption}>
          <span className={styles.focoRank}>#{row.rank}</span>
          {id ? `${id.name} ${id.surname}` : 'Conductor'}
        </div>
      </div>
    </div>
  )
}

function Tablon({ notifications }: { notifications: AppNotification[] }) {
  const recent = [...notifications]
    .sort((a, b) => (b.timestamp?.toMillis?.() ?? 0) - (a.timestamp?.toMillis?.() ?? 0))
    .slice(0, 6)

  return (
    <div className={styles.panel}>
      <div className={styles.head}>
        <span className={styles.headMark}>▸</span> Tablón
      </div>
      <ul className={styles.alerts}>
        {recent.length === 0 && <li className={styles.alertEmpty}>Sin avisos todavía</li>}
        {recent.map((n) => (
          <li key={n.id} className={styles.alert} data-type={n.type}>
            <span className={styles.alertEmoji}>{NOTIFICATION_EMOJI[n.type] ?? '📣'}</span>
            <span className={styles.alertText}>{stripLeadingEmoji(n.text)}</span>
          </li>
        ))}
      </ul>
    </div>
  )
}

export function SidePanel({
  rows,
  notifications,
}: {
  rows: Row[]
  notifications: AppNotification[]
}) {
  return (
    <div className={styles.side}>
      <FocoRotatorio rows={rows} />
      <Tablon notifications={notifications} />
    </div>
  )
}
