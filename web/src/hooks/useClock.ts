import { useEffect, useState } from 'react'

/** Live wall-clock string (HH:MM) for the projector header. */
export function useClock(): string {
  const [now, setNow] = useState(() => new Date())
  useEffect(() => {
    const t = setInterval(() => setNow(new Date()), 1000)
    return () => clearInterval(t)
  }, [])
  return now.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' })
}
