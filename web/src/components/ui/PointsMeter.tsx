import type { CSSProperties } from 'react'
import { pointsColor, STARTING_POINTS } from '../../lib/theme'
import styles from './PointsMeter.module.css'

/** The "carnet por puntos" gauge: N segments (filled = remaining points). */
export function PointsMeter({
  points,
  max = STARTING_POINTS,
  showValue = true,
  size = 'md',
}: {
  points: number
  max?: number
  showValue?: boolean
  size?: 'sm' | 'md' | 'lg'
}) {
  const clamped = Math.max(0, Math.min(points, max))
  return (
    <div
      className={styles.meter}
      data-size={size}
      style={{ '--pc': pointsColor(points) } as CSSProperties}
    >
      <div className={styles.segs} role="img" aria-label={`${points} de ${max} puntos`}>
        {Array.from({ length: max }, (_, i) => (
          <span key={i} className={styles.seg} data-on={i < clamped || undefined} />
        ))}
      </div>
      {showValue && (
        <div className={styles.value}>
          <span className="tnum">{points}</span>
          <small>pts</small>
        </div>
      )}
    </div>
  )
}
