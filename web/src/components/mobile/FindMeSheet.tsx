import { useMemo, useState } from 'react'
import type { LeaderboardEntry } from '../../lib/types'
import { Avatar } from '../ui/Avatar'
import { Plate } from '../ui/Plate'
import styles from './FindMeSheet.module.css'

const norm = (s: string) =>
  s.normalize('NFD').replace(new RegExp('[\\u0300-\\u036f]', 'g'), '').toLowerCase()

/** "Encuéntrate" — pick your driver; the phone remembers it (localStorage). */
export function FindMeSheet({
  entries,
  onPick,
}: {
  entries: LeaderboardEntry[]
  onPick: (id: string) => void
}) {
  const [q, setQ] = useState('')
  const list = useMemo(() => {
    const query = norm(q.trim())
    return [...entries]
      .map((e) => ({ e, name: e.identity ? `${e.identity.name} ${e.identity.surname}` : 'Conductor' }))
      .filter(({ name }) => !query || norm(name).includes(query))
      .sort((a, b) => a.name.localeCompare(b.name, 'es'))
  }, [entries, q])

  return (
    <div className={styles.sheet}>
      <div className={styles.intro}>
        <span className={styles.emoji}>🪪</span>
        <h2 className={styles.title}>Encuéntrate</h2>
        <p className={styles.lead}>
          Marca tu conductor para fijar tu carnet y tu posición. Tu navegador lo recordará en este
          dispositivo.
        </p>
      </div>

      <input
        className={styles.search}
        type="search"
        placeholder="Busca tu nombre…"
        value={q}
        onChange={(e) => setQ(e.target.value)}
        autoComplete="off"
      />

      <ul className={styles.list}>
        {list.length === 0 && <li className={styles.empty}>Sin coincidencias</li>}
        {list.map(({ e, name }) => (
          <li key={e.id}>
            <button className={styles.row} onClick={() => onPick(e.id)}>
              <Avatar photoUrl={e.identity?.photoUrl ?? e.photoUrl} name={e.identity?.name} surname={e.identity?.surname} size={40} />
              <span className={styles.rowName}>{name}</span>
              <Plate id={e.id} name={e.identity?.name} surname={e.identity?.surname} size="sm" />
            </button>
          </li>
        ))}
      </ul>
    </div>
  )
}
