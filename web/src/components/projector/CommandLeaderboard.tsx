import type { Row } from '../../lib/leaderboard'
import type { LeaderboardEntry } from '../../lib/types'
import { useFlipReorder } from '../../hooks/useFlipReorder'
import { Plate } from '../ui/Plate'
import { StampIncautado } from '../ui/StampIncautado'
import { DriverRow } from './DriverRow'
import styles from './CommandLeaderboard.module.css'

export function CommandLeaderboard({
  rows,
  incautados,
}: {
  rows: Row[]
  incautados: LeaderboardEntry[]
}) {
  const setRowRef = useFlipReorder(rows.map((r) => r.entry.id).join(','))

  return (
    <section className={styles.board}>
      <div className={styles.head}>
        <span>#</span>
        <span>Matrícula</span>
        <span />
        <span>Conductor</span>
        <span>Carnet por puntos</span>
        <span>Estado</span>
        <span>Tasa por ronda</span>
      </div>

      <ul className={styles.list}>
        {rows.map((r) => (
          <li key={r.entry.id} ref={setRowRef(r.entry.id)}>
            <DriverRow row={r} />
          </li>
        ))}
        {rows.length === 0 && <li className={styles.empty}>Esperando las primeras mediciones…</li>}
      </ul>

      {incautados.length > 0 && (
        <div className={styles.incautados}>
          <span className={styles.incLabel}>Incautados</span>
          {incautados.map((e) => (
            <span key={e.id} className={styles.incItem}>
              <Plate id={e.id} name={e.identity?.name} surname={e.identity?.surname} size="sm" />
              <span className={styles.incName}>
                {e.identity ? `${e.identity.name} ${e.identity.surname}` : 'Conductor'}
              </span>
              <StampIncautado />
            </span>
          ))}
        </div>
      )}
    </section>
  )
}
