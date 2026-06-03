import { Crest } from '../ui/Crest'
import { useClock } from '../../hooks/useClock'
import styles from './TopBar.module.css'

export function TopBar({
  round,
  drivers,
  inZone,
  incautados,
}: {
  round: number
  drivers: number
  inZone: number
  incautados: number
}) {
  const clock = useClock()
  return (
    <header className={styles.bar}>
      <Crest subtitle="Control de alcoholemia" />

      <div className={styles.right}>
        <span className={styles.live}>
          <span className="live-dot" /> En vivo
        </span>
        <div className={styles.meta}>
          <span>
            Ronda <b className="tnum">{round}</b>
          </span>
          <span className={styles.sep} />
          <span className="tnum">{clock}</span>
          <span className={styles.sep} />
          <span>
            <b className="tnum">{drivers}</b> conductores
          </span>
          <span className={styles.sep} />
          <span className={styles.zone}>
            <b className="tnum">{inZone}</b> en zona
          </span>
          {incautados > 0 && (
            <>
              <span className={styles.sep} />
              <span className={styles.inc}>
                <b className="tnum">{incautados}</b> incautados
              </span>
            </>
          )}
        </div>
      </div>
    </header>
  )
}
