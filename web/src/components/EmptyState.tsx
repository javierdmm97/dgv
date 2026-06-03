export function EmptyState({ title, subtitle }: { title: string; subtitle?: string }) {
  return (
    <div className="empty">
      <img className="empty__logo" src="/dgv_logo.png" alt="Operación DGV" />
      <h1 className="empty__title">{title}</h1>
      {subtitle && <p className="empty__subtitle">{subtitle}</p>}
    </div>
  )
}
