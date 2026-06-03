import { useCallback, useLayoutEffect, useRef } from 'react'

/**
 * FLIP reordering for the live leaderboard: when ranking changes, rows glide
 * from their old position to the new one (Web Animations API, no dependency).
 *
 * Usage:
 *   const setRowRef = useFlipReorder(rows.map(r => r.id).join(','))
 *   rows.map(r => <li ref={setRowRef(r.id)} key={r.id}>…</li>)
 */
export function useFlipReorder(orderKey: string) {
  const refs = useRef(new Map<string, HTMLElement>())
  const prev = useRef(new Map<string, DOMRect>())

  useLayoutEffect(() => {
    const curr = new Map<string, DOMRect>()
    refs.current.forEach((el, id) => curr.set(id, el.getBoundingClientRect()))
    curr.forEach((rect, id) => {
      const before = prev.current.get(id)
      const el = refs.current.get(id)
      if (!before || !el) return
      const dy = before.top - rect.top
      if (Math.abs(dy) > 1) {
        el.animate(
          [{ transform: `translateY(${dy}px)` }, { transform: 'translateY(0)' }],
          { duration: 480, easing: 'cubic-bezier(0.2, 0.7, 0.2, 1)' },
        )
      }
    })
    prev.current = curr
  }, [orderKey])

  return useCallback(
    (id: string) => (el: HTMLElement | null) => {
      if (el) refs.current.set(id, el)
      else refs.current.delete(id)
    },
    [],
  )
}
