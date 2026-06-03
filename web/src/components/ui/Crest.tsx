import styles from './Crest.module.css'

/** DGV brand lockup for headers and the waiting screen. */
export function Crest({ subtitle, compact = false }: { subtitle?: string; compact?: boolean }) {
  return (
    <span className={styles.crest} data-compact={compact || undefined}>
      <img className={styles.logo} src="/dgv_logo_transparent.webp" alt="" />
      <span className={styles.text}>
        <span className={styles.brand}>
          Operación <b>DGV</b>
        </span>
        {subtitle && <span className={styles.sub}>{subtitle}</span>}
      </span>
    </span>
  )
}
