import { STICKER_LABEL } from '../../lib/awards'
import styles from './DistintivoAmbiental.module.css'

/** Environmental distinctive sticker (the "más contaminante" gag) + optional label. */
export function DistintivoAmbiental({
  stickerKey,
  size = 64,
  showLabel = false,
}: {
  stickerKey: string
  size?: number
  showLabel?: boolean
}) {
  const label = STICKER_LABEL[stickerKey] ?? 'Distintivo ambiental'
  return (
    <span className={styles.wrap}>
      <img
        className={styles.sticker}
        src={`/distintivos/${stickerKey}.webp`}
        alt={label}
        width={size}
        height={size}
        loading="lazy"
      />
      {showLabel && <span className={styles.label}>{label}</span>}
    </span>
  )
}
