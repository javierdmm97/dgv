import { useState } from 'react'
import type { NotificationType } from '../lib/types'
import { useSimulator } from './SimulatorContext'
import { NOTIF_TEMPLATES, TITLE_META } from './simData'
import styles from './AdminPanel.module.css'

const NOTIF_TYPES: NotificationType[] = ['manual', 'fine', 'streak', 'moab', 'zone']

export function AdminPanel() {
  const sim = useSimulator()
  const players = sim.players
  const [open, setOpen] = useState(true)

  // notification composer
  const [nType, setNType] = useState<NotificationType>('manual')
  const [target, setTarget] = useState('')
  const [text, setText] = useState('')

  // player controls
  const [pid, setPid] = useState(players[0]?.id ?? '')
  const [bac, setBac] = useState('0.45')
  const [titleKey, setTitleKey] = useState('velocidadDeCrucero')

  const nameOf = (id: string) => {
    const p = players.find((x) => x.id === id)
    return p?.identity ? `${p.identity.name} ${p.identity.surname}` : 'Conductor'
  }
  const tpl = NOTIF_TEMPLATES[nType]
  const placeholder =
    nType === 'manual' ? 'Escribe tu mensaje…' : `${tpl.emoji} ${tpl.label}`

  const send = () => {
    const prefix = target ? `${nameOf(target).split(' ')[0]}: ` : ''
    const base = text.trim() || (nType === 'manual' ? '' : `${tpl.emoji} ${tpl.label}`)
    const final = `${prefix}${base}`.trim()
    if (!final) return
    sim.postNotification(nType, final, target || null)
    setText('')
  }

  const selected = players.find((p) => p.id === pid)

  if (!open) {
    return (
      <button className={styles.handle} onClick={() => setOpen(true)}>
        ⚙ Simular
      </button>
    )
  }

  return (
    <aside className={styles.panel}>
      <header className={styles.head}>
        <div>
          <div className={styles.title}>Simulador</div>
          <div className={styles.subtitle}>Replica las escrituras de la app · local, no toca Firestore</div>
        </div>
        <button className={styles.close} onClick={() => setOpen(false)} aria-label="Cerrar">
          ✕
        </button>
      </header>

      {/* ---- Partida ---- */}
      <section className={styles.section}>
        <h3 className={styles.h3}>Partida</h3>
        <div className={styles.statusLine}>
          Ronda <b className="tnum">{sim.session.currentRound}</b> ·{' '}
          {sim.session.isFinished ? 'finalizada' : 'en curso'}
        </div>
        <div className={styles.btnRow}>
          <button className={styles.btn} onClick={sim.newRound}>
            🚨 Nueva ronda
          </button>
          {sim.session.isFinished ? (
            <button className={styles.btn} onClick={sim.reopen}>
              ↩ Reabrir
            </button>
          ) : (
            <button className={styles.btn} onClick={sim.finish}>
              🏁 Finalizar
            </button>
          )}
        </div>
        <p className={styles.hint}>Nueva ronda → sessions.currentRound +1 (suena la sirena). Finalizar → ceremonia.</p>
      </section>

      {/* ---- Notificación ---- */}
      <section className={styles.section}>
        <h3 className={styles.h3}>Notificación</h3>
        <div className={styles.field}>
          <label htmlFor="sim-type">Tipo</label>
          <select
            id="sim-type"
            name="sim-type"
            value={nType}
            onChange={(e) => setNType(e.target.value as NotificationType)}
          >
            {NOTIF_TYPES.map((t) => (
              <option key={t} value={t}>
                {NOTIF_TEMPLATES[t].emoji} {t}
              </option>
            ))}
          </select>
        </div>
        <div className={styles.field}>
          <label htmlFor="sim-target">Para (opcional)</label>
          <select id="sim-target" name="sim-target" value={target} onChange={(e) => setTarget(e.target.value)}>
            <option value="">— Sin objetivo —</option>
            {players.map((p) => (
              <option key={p.id} value={p.id}>
                {nameOf(p.id)}
              </option>
            ))}
          </select>
        </div>
        <textarea
          className={styles.textarea}
          name="sim-text"
          aria-label="Mensaje de la notificación"
          rows={2}
          placeholder={placeholder}
          value={text}
          onChange={(e) => setText(e.target.value)}
        />
        <button className={styles.btnPrimary} onClick={send}>
          Enviar notificación
        </button>
        <p className={styles.hint}>→ notifications/{'{id}'} (sendNotification). Aparece en el ticker y el Tablón.</p>
      </section>

      {/* ---- Jugador ---- */}
      <section className={styles.section}>
        <h3 className={styles.h3}>Jugador</h3>
        <div className={styles.field}>
          <label htmlFor="sim-player">Conductor</label>
          <select id="sim-player" name="sim-player" value={pid} onChange={(e) => setPid(e.target.value)}>
            {players.map((p) => (
              <option key={p.id} value={p.id}>
                {nameOf(p.id)}
              </option>
            ))}
          </select>
        </div>

        <div className={styles.inline}>
          <input
            className={styles.bac}
            type="number"
            step="0.01"
            min="0"
            name="sim-bac"
            value={bac}
            onChange={(e) => setBac(e.target.value)}
            aria-label="Tasa (mg/L)"
          />
          <button className={styles.btn} onClick={() => sim.addReading(pid, Number(bac) || 0)}>
            Añadir lectura
          </button>
        </div>

        <div className={styles.btnRow}>
          <button className={styles.btn} onClick={() => sim.fine(pid)}>
            🚔 Multar
          </button>
          <button className={styles.btn} onClick={() => sim.toggleIncautado(pid)}>
            {selected?.isIncautado ? '↩ Devolver' : '🚫 Incautar'}
          </button>
        </div>

        <div className={styles.inline}>
          <select
            name="sim-title"
            aria-label="Título a conceder"
            value={titleKey}
            onChange={(e) => setTitleKey(e.target.value)}
          >
            {Object.entries(TITLE_META).map(([key, meta]) => (
              <option key={key} value={key}>
                {meta.emoji} {meta.displayName}
              </option>
            ))}
          </select>
          <button className={styles.btn} onClick={() => sim.grantTitle(pid, titleKey)}>
            Conceder
          </button>
        </div>
        <p className={styles.hint}>Lectura/multa/título → sessions/{'{id}'}/players (syncPlayerUpdate).</p>
      </section>

      <section className={styles.section}>
        <button className={styles.btnGhost} onClick={sim.reset}>
          ↺ Reiniciar simulación
        </button>
      </section>
    </aside>
  )
}
