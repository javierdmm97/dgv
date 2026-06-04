import { useEffect, useRef, useState } from 'react'
import type { Session } from '../lib/types'
import styles from './SirenController.module.css'

/**
 * Plays the checkpoint siren on a NEW ROUND (`currentRound` increment, written by
 * the app) and triggers a dramatic full-screen takeover on the projector (a slide
 * banner on mobile). Browsers gate autoplay behind a gesture that only lasts the
 * page load, so we ask up front with a one-time popup and prime the element then.
 */
export function SirenController({ session, variant }: { session: Session; variant: 'tv' | 'mobile' }) {
  const [decided, setDecided] = useState(false)
  const [enabled, setEnabled] = useState(false)
  const [takeoverRound, setTakeoverRound] = useState<number | null>(null)
  const audioRef = useRef<HTMLAudioElement | null>(null)
  const lastRound = useRef<number | null>(null)

  useEffect(() => {
    const round = session.currentRound
    if (lastRound.current === null) {
      lastRound.current = round // seed; don't fire on first load
      return
    }
    if (round > lastRound.current) {
      lastRound.current = round
      if (enabled && audioRef.current) {
        audioRef.current.currentTime = 0
        void audioRef.current.play().catch(() => {})
      }
      setTakeoverRound(round)
      const t = setTimeout(() => setTakeoverRound(null), variant === 'tv' ? 4800 : 3200)
      return () => clearTimeout(t)
    }
  }, [session.currentRound, enabled, variant])

  const enableSound = async () => {
    const a = audioRef.current
    if (a) {
      try {
        a.muted = true
        await a.play()
        a.pause()
        a.currentTime = 0
        a.muted = false
      } catch {
        /* gesture still unlocks the element */
      }
    }
    setEnabled(true)
    setDecided(true)
  }

  return (
    <>
      <audio ref={audioRef} src="/police_siren.mp3" preload="auto" />

      {!decided && (
        <div className={styles.modalScrim} role="dialog" aria-modal="true" aria-labelledby="siren-title">
          <div className={styles.modal}>
            <div className={styles.modalEmoji}>🚨</div>
            <h2 id="siren-title">¿Activar el sonido?</h2>
            <p>Esta pantalla hace sonar una sirena en cada nuevo control. Actívalo para vivirlo en directo.</p>
            <div className={styles.modalActions}>
              <button className={styles.btnPrimary} onClick={enableSound}>
                🔊 Activar sonido
              </button>
              <button className={styles.btnGhost} onClick={() => setDecided(true)}>
                Ahora no
              </button>
            </div>
          </div>
        </div>
      )}

      {decided && !enabled && (
        <button className={styles.unlock} onClick={enableSound} title="Activar sonido">
          🔊
        </button>
      )}

      {takeoverRound !== null && (
        <div className={styles.takeover} data-variant={variant} role="alert">
          <div className={styles.takeoverInner}>
            <span className={styles.takeoverEmoji}>🚨</span>
            <span className={styles.takeoverTitle}>Nuevo control de alcoholemia</span>
            <span className={styles.takeoverSub}>Preparen el etilómetro</span>
          </div>
        </div>
      )}
    </>
  )
}
