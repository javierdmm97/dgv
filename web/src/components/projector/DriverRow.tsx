import type { Row } from '../../lib/leaderboard'
import { Plate } from '../ui/Plate'
import { Avatar } from '../ui/Avatar'
import { PointsMeter } from '../ui/PointsMeter'
import { ZoneTag } from '../ui/ZoneTag'
import { TitleBadge } from '../ui/TitleBadge'
import { BacChart } from '../BacChart'
import styles from './DriverRow.module.css'

export function DriverRow({ row }: { row: Row }) {
  const { entry, rank, last, zone } = row
  const id = entry.identity
  const name = id ? `${id.name} ${id.surname}` : 'Conductor'
  const trend = last
    ? last.pointsChange > 0
      ? 'up'
      : last.pointsChange < 0
        ? 'down'
        : 'flat'
    : 'flat'

  return (
    <div className={styles.row} data-zone={zone} data-top={rank <= 3 || undefined}>
      <div className={styles.rank}>
        <span className="tnum">{rank}</span>
      </div>

      <Plate id={entry.id} name={id?.name} surname={id?.surname} size="md" />

      <Avatar photoUrl={id?.photoUrl ?? entry.photoUrl} name={id?.name} surname={id?.surname} size={50} />

      <div className={styles.idcol}>
        <div className={styles.name}>{name}</div>
        <div className={styles.titles}>
          {entry.titleDetails.length > 0 ? (
            entry.titleDetails.map((t) => <TitleBadge key={t.key} detail={t} size={20} />)
          ) : (
            <span className={styles.noTitles}>Sin distinciones</span>
          )}
        </div>
      </div>

      <div className={styles.points}>
        <PointsMeter points={entry.points} size="md" />
      </div>

      <div className={styles.status}>
        {last ? <ZoneTag bac={last.bac} optimal={last.optimalBAC} /> : <span className={styles.base}>Base</span>}
        <span className={styles.trend} data-dir={trend}>
          {trend === 'up' ? '▲' : trend === 'down' ? '▼' : '·'}
        </span>
      </div>

      <div className={styles.chart}>
        <BacChart readings={entry.readings} width={172} height={50} compact />
      </div>
    </div>
  )
}
