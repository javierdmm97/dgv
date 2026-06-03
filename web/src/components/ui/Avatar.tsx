import styles from './Avatar.module.css'

/** Driver photo (base64 data URL) or initials fallback on DGT blue. */
export function Avatar({
  photoUrl,
  name = '',
  surname = '',
  size = 48,
  round = false,
}: {
  photoUrl?: string
  name?: string
  surname?: string
  size?: number
  round?: boolean
}) {
  const initials = `${name[0] ?? ''}${surname[0] ?? ''}`.toUpperCase() || '··'
  return (
    <div
      className={styles.avatar}
      data-round={round || undefined}
      style={{ width: size, height: size, fontSize: Math.round(size * 0.38) }}
    >
      {photoUrl ? <img src={photoUrl} alt="" loading="lazy" /> : <span>{initials}</span>}
    </div>
  )
}
