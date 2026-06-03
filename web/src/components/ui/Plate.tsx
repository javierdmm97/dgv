import { plateOf } from '../../lib/plate'
import styles from './Plate.module.css'

/** Spanish-style license plate as a stable driver identity chip ("0427 LUF"). */
export function Plate({
  id,
  name,
  surname,
  size = 'md',
}: {
  id: string
  name?: string
  surname?: string
  size?: 'sm' | 'md' | 'lg'
}) {
  const { digits, letters } = plateOf(id, name, surname)
  return (
    <span className={styles.plate} data-size={size} aria-hidden="true">
      <span className={styles.band}>
        <span className={styles.stars}>★</span>
        <span className={styles.country}>E</span>
      </span>
      <span className={styles.code}>
        <span className="tnum">{digits}</span> {letters}
      </span>
    </span>
  )
}
