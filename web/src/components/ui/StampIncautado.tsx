import styles from './StampIncautado.module.css'

/** The rotated red "INCAUTADO" stamp (mirrors license_card.dart). Parent positions it. */
export function StampIncautado({ label = 'INCAUTADO' }: { label?: string }) {
  return (
    <span className={styles.stamp} role="img" aria-label={`Vehículo ${label.toLowerCase()}`}>
      {label}
    </span>
  )
}
