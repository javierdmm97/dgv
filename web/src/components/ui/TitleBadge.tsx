import { useState } from 'react'
import type { CSSProperties } from 'react'
import type { TitleDetail } from '../../lib/types'
import styles from './TitleBadge.module.css'

/** Web-optimized title icon by key (mirrors assets/titles, resized to webp). */
const ICON: Record<string, string> = {
  velocidadDeCrucero: '/titles/velocidadDeCrucero.webp',
  multaPorExceso: '/titles/multaPorExceso.webp',
  lDePracticas: '/titles/lDePracticas.webp',
  vehiculoHibrido: '/titles/vehiculoHibrido.webp',
  itvPassed: '/titles/itvPassed.webp',
}

/** A DGT title (achievement) icon with its ×N count. Falls back to the emoji. */
export function TitleBadge({
  detail,
  size = 30,
  showCount = true,
}: {
  detail: TitleDetail
  size?: number
  showCount?: boolean
}) {
  const [failed, setFailed] = useState(false)
  const src = ICON[detail.key]
  const useImg = src && !failed
  return (
    <span
      className={styles.badge}
      style={{ '--s': `${size}px` } as CSSProperties}
      title={`${detail.displayName}${detail.count > 1 ? ` ×${detail.count}` : ''}`}
    >
      {useImg ? (
        <img
          src={src}
          alt={detail.displayName}
          width={size}
          height={size}
          loading="lazy"
          onError={() => setFailed(true)}
        />
      ) : (
        <span className={styles.emoji}>{detail.emoji}</span>
      )}
      {showCount && detail.count > 1 && <span className={styles.count}>×{detail.count}</span>}
    </span>
  )
}
