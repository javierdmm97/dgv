import { useCallback, useState } from 'react'

export type Theme = 'dark' | 'light'

const KEY = 'dgv:theme'

/** Read the theme already applied to <html> by main.tsx (defaults to dark). */
function current(): Theme {
  if (typeof document === 'undefined') return 'dark'
  return document.documentElement.dataset.theme === 'light' ? 'light' : 'dark'
}

/**
 * Dark is the default. The toggle flips <html data-theme> and persists the choice
 * (localStorage `dgv:theme`). Only one toggle is mounted per view, so local state
 * is enough — no shared store needed.
 */
export function useTheme() {
  const [theme, setTheme] = useState<Theme>(current)

  const toggle = useCallback(() => {
    setTheme((prev) => {
      const next: Theme = prev === 'dark' ? 'light' : 'dark'
      document.documentElement.dataset.theme = next
      try {
        localStorage.setItem(KEY, next)
      } catch {
        /* private mode — keep in-memory only */
      }
      return next
    })
  }, [])

  return { theme, toggle }
}
