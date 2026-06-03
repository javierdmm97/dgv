import { useEffect, useRef, useState } from 'react'
import type { Session } from '../lib/types'

/**
 * Plays the checkpoint siren on a NEW ROUND (`sessions/{id}.currentRound` increment,
 * which the app already writes via FirebaseSyncService.syncRoundComplete).
 *
 * Browsers block autoplay until a user gesture, and that unlock only lasts for the
 * current page load — so we ask UP FRONT, on first open, with a popup (not when the
 * first alarm fires, by which point it'd be blocked). Clicking "Activar sonido"
 * primes the audio element (muted play→pause) to unlock future siren playback.
 */
export function AudioController({ session }: { session: Session }) {
  const [decided, setDecided] = useState(false)
  const [enabled, setEnabled] = useState(false)
  const audioRef = useRef<HTMLAudioElement | null>(null)
  const lastRound = useRef<number | null>(null)

  useEffect(() => {
    const round = session.currentRound
    if (lastRound.current === null) {
      lastRound.current = round // seed baseline, don't sound on load
      return
    }
    if (round > lastRound.current) {
      lastRound.current = round
      if (enabled && audioRef.current) {
        audioRef.current.currentTime = 0
        void audioRef.current.play().catch(() => {})
      }
    }
  }, [session.currentRound, enabled])

  const enableSound = async () => {
    const a = audioRef.current
    if (a) {
      try {
        // Prime/unlock the element with a silent play during this user gesture.
        a.muted = true
        await a.play()
        a.pause()
        a.currentTime = 0
        a.muted = false
      } catch {
        /* ignore — element will still be unlocked by the gesture */
      }
    }
    setEnabled(true)
    setDecided(true)
  }

  return (
    <>
      <audio ref={audioRef} src="/police_siren.mp3" preload="auto" />

      {!decided && (
        <div className="modal" role="dialog" aria-modal="true" aria-labelledby="audio-modal-title">
          <div className="modal__card">
            <div className="modal__emoji">🚨</div>
            <h2 id="audio-modal-title">¿Activar el sonido?</h2>
            <p>Esta pantalla reproduce una sirena en cada control de alcoholemia. Actívalo para oírla en directo.</p>
            <div className="modal__actions">
              <button className="btn btn--primary" onClick={enableSound}>🔊 Activar sonido</button>
              <button className="btn btn--ghost" onClick={() => setDecided(true)}>Ahora no</button>
            </div>
          </div>
        </div>
      )}

      {decided && !enabled && (
        <button className="audio-unlock" onClick={enableSound}>🔊 Activar sonido</button>
      )}
    </>
  )
}
