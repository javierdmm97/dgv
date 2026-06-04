import styles from './SegmentedNav.module.css'

export type MobileTab = 'clasificacion' | 'carnet' | 'tablon'

export function SegmentedNav({
  value,
  onChange,
  hasMe,
}: {
  value: MobileTab
  onChange: (t: MobileTab) => void
  hasMe: boolean
}) {
  const tabs: { id: MobileTab; label: string }[] = [
    { id: 'clasificacion', label: 'Clasificación' },
    { id: 'carnet', label: hasMe ? 'Mi carnet' : 'Encuéntrate' },
    { id: 'tablon', label: 'Tablón' },
  ]
  return (
    <nav className={styles.nav} role="tablist" aria-label="Secciones">
      {tabs.map((t) => (
        <button
          key={t.id}
          role="tab"
          aria-selected={value === t.id}
          className={styles.tab}
          data-active={value === t.id || undefined}
          onClick={() => onChange(t.id)}
        >
          {t.label}
        </button>
      ))}
    </nav>
  )
}
