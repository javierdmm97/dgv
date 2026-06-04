import type { Row } from '../../lib/leaderboard'
import type { LeaderboardEntry } from '../../lib/types'
import { pointsColor } from '../../lib/theme'
import { Plate } from '../ui/Plate'
import { Avatar } from '../ui/Avatar'
import { PointsMeter } from '../ui/PointsMeter'
import { ZoneTag } from '../ui/ZoneTag'
import { TitleBadge } from '../ui/TitleBadge'
import { StampIncautado } from '../ui/StampIncautado'
import styles from './Clasificacion.module.css'

function Card({
  row,
  onSelect,
  me,
}: {
  row: Row
  onSelect: (id: string) => void
  me?: boolean
}) {
  const { entry, rank, last } = row
  const id = entry.identity
  const name = id ? `${id.name} ${id.surname}` : 'Conductor'
  return (
    <button className={styles.card} data-me={me || undefined} onClick={() => onSelect(entry.id)}>
      <span className={styles.rank}>
        <span className="tnum">{rank}</span>
      </span>
      <Avatar photoUrl={id?.photoUrl ?? entry.photoUrl} name={id?.name} surname={id?.surname} size={46} />
      <span className={styles.main}>
        <span className={styles.nameRow}>
          <span className={styles.name}>{name}</span>
          {me && <span className={styles.youTag}>Tú</span>}
        </span>
        <span className={styles.plateRow}>
          <Plate id={entry.id} name={id?.name} surname={id?.surname} size="sm" />
          {last ? <ZoneTag bac={last.bac} optimal={last.optimalBAC} size="sm" /> : <span className={styles.base}>Base</span>}
        </span>
        <span className={styles.meterRow}>
          <PointsMeter points={entry.points} showValue={false} size="sm" />
          {entry.titleDetails.slice(0, 4).map((t) => (
            <TitleBadge key={t.key} detail={t} size={16} showCount={false} />
          ))}
        </span>
      </span>
      <span className={styles.pts} style={{ color: pointsColor(entry.points) }}>
        <b className="tnum">{entry.points}</b>
        <small>pts</small>
      </span>
    </button>
  )
}

export function Clasificacion({
  rows,
  incautados,
  meId,
  onSelect,
}: {
  rows: Row[]
  incautados: LeaderboardEntry[]
  meId: string | null
  onSelect: (id: string) => void
}) {
  const meRow = meId ? rows.find((r) => r.entry.id === meId) : undefined
  const meRank = meRow ? rows.indexOf(meRow) + 1 : 0

  return (
    <div className={styles.wrap}>
      {/* Pin "your position" only when you'd otherwise be scrolled out of sight. */}
      {meRow && meRank > 3 && (
        <div className={styles.meBlock}>
          <span className={styles.meLabel}>Tu posición</span>
          <Card row={meRow} onSelect={onSelect} me />
        </div>
      )}

      <ul className={styles.list}>
        {rows.length === 0 && <li className={styles.empty}>Esperando las primeras mediciones…</li>}
        {rows.map((r) => (
          <li key={r.entry.id}>
            <Card row={r} onSelect={onSelect} me={r.entry.id === meId} />
          </li>
        ))}
      </ul>

      {incautados.length > 0 && (
        <div className={styles.incBlock}>
          <span className={styles.incLabel}>Incautados</span>
          {incautados.map((e) => (
            <button key={e.id} className={styles.incRow} onClick={() => onSelect(e.id)}>
              <Avatar photoUrl={e.identity?.photoUrl ?? e.photoUrl} name={e.identity?.name} surname={e.identity?.surname} size={36} />
              <span className={styles.incName}>
                {e.identity ? `${e.identity.name} ${e.identity.surname}` : 'Conductor'}
              </span>
              <StampIncautado />
            </button>
          ))}
        </div>
      )}
    </div>
  )
}
