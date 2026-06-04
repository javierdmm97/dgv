import { createContext, useContext, useMemo, useReducer, type ReactNode } from 'react'
import type { NotificationType } from '../lib/types'
import { seed, simReducer, type SimState } from './simData'

interface SimContextValue extends SimState {
  postNotification: (nType: NotificationType, text: string, targetPlayerId?: string | null) => void
  newRound: () => void
  finish: () => void
  reopen: () => void
  addReading: (playerId: string, bac: number) => void
  fine: (playerId: string) => void
  grantTitle: (playerId: string, titleKey: string) => void
  toggleIncautado: (playerId: string) => void
  reset: () => void
}

const SimContext = createContext<SimContextValue | null>(null)

export function SimulatorProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(simReducer, undefined, seed)

  const value = useMemo<SimContextValue>(
    () => ({
      ...state,
      postNotification: (nType, text, targetPlayerId) =>
        dispatch({ kind: 'notify', nType, text, targetPlayerId }),
      newRound: () => dispatch({ kind: 'newRound' }),
      finish: () => dispatch({ kind: 'finish' }),
      reopen: () => dispatch({ kind: 'reopen' }),
      addReading: (playerId, bac) => dispatch({ kind: 'addReading', playerId, bac }),
      fine: (playerId) => dispatch({ kind: 'fine', playerId }),
      grantTitle: (playerId, titleKey) => dispatch({ kind: 'grantTitle', playerId, titleKey }),
      toggleIncautado: (playerId) => dispatch({ kind: 'toggleIncautado', playerId }),
      reset: () => dispatch({ kind: 'reset' }),
    }),
    [state],
  )

  return <SimContext.Provider value={value}>{children}</SimContext.Provider>
}

export function useSimulator(): SimContextValue {
  const ctx = useContext(SimContext)
  if (!ctx) throw new Error('useSimulator must be used within SimulatorProvider')
  return ctx
}
