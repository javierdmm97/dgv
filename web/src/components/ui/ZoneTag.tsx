import type { CSSProperties } from 'react'
import { ZONE, zoneKey, zoneLabel } from '../../lib/theme'
import styles from './ZoneTag.module.css'

/** Small pill describing how a BAC reading sits vs its round's optimal target. */
export function ZoneTag({
  bac,
  optimal,
  size = 'md',
}: {
  bac: number
  optimal: number
  size?: 'sm' | 'md'
}) {
  const k = zoneKey(bac, optimal)
  return (
    <span
      className={styles.tag}
      data-size={size}
      style={{ '--zc': ZONE[k] } as CSSProperties}
    >
      <span className={styles.dot} />
      {zoneLabel(bac, optimal)}
    </span>
  )
}
