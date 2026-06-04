import { Crest } from './ui/Crest'
import { ThemeToggle } from './ui/ThemeToggle'
import styles from './EmptyState.module.css'

/** Branded waiting / connecting / error screen on the dark theme. */
export function EmptyState({
  title,
  subtitle,
  tone = 'info',
}: {
  title: string
  subtitle?: string
  tone?: 'info' | 'error'
}) {
  return (
    <div className={styles.empty}>
      <div className={styles.corner}>
        <ThemeToggle />
      </div>
      <Crest subtitle="Dirección General de Vitis" />
      <div className={styles.radar} data-tone={tone}>
        <span className={styles.sweep} />
        <span className={styles.dot} />
      </div>
      <h1 className={styles.title}>{title}</h1>
      {subtitle && <p className={styles.sub}>{subtitle}</p>}
    </div>
  )
}
