import { useTheme } from '../../hooks/useTheme'
import styles from './ThemeToggle.module.css'

/** Sun/moon icon button that flips between dark (default) and light backgrounds. */
export function ThemeToggle() {
  const { theme, toggle } = useTheme()
  const toLight = theme === 'dark'
  return (
    <button
      className={styles.toggle}
      onClick={toggle}
      title={toLight ? 'Fondo claro' : 'Fondo oscuro'}
      aria-label={toLight ? 'Cambiar a fondo claro' : 'Cambiar a fondo oscuro'}
    >
      {toLight ? '☀️' : '🌙'}
    </button>
  )
}
