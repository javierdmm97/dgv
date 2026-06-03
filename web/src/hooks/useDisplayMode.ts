import { useEffect, useState } from 'react'

export type DisplayMode = 'tv' | 'mobile'

/**
 * Which experience to render. Auto: wide + landscape viewport → projector ('tv'),
 * else 'mobile'. Override with ?tv=1 (force projector) or ?phone=1 / ?mobile=1.
 * This is what makes the web NOT "a bigger mobile" — each mode has its own tree.
 */
function compute(): DisplayMode {
  if (typeof window === 'undefined') return 'mobile'
  const p = new URLSearchParams(window.location.search)
  if (p.has('tv')) return 'tv'
  if (p.has('phone') || p.has('mobile')) return 'mobile'
  const wide = window.innerWidth >= 900
  const landscape = window.innerWidth >= window.innerHeight
  return wide && landscape ? 'tv' : 'mobile'
}

export function useDisplayMode(): DisplayMode {
  const [mode, setMode] = useState<DisplayMode>(compute)
  useEffect(() => {
    const onResize = () => setMode(compute())
    window.addEventListener('resize', onResize)
    window.addEventListener('orientationchange', onResize)
    return () => {
      window.removeEventListener('resize', onResize)
      window.removeEventListener('orientationchange', onResize)
    }
  }, [])
  return mode
}
