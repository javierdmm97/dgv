// Local simulator state + actions. Each action mirrors a real Firestore write the
// Flutter app performs (firebase_sync_service.dart) — but applied to an in-memory
// store, so nothing touches Firestore. The point is to SEE how the web reacts.

import { Timestamp } from 'firebase/firestore'
import type {
  AppNotification,
  LeaderboardEntry,
  NotificationType,
  Reading,
  Session,
} from '../lib/types'
import { STARTING_POINTS } from '../lib/theme'
import { DEMO_NOTIFICATIONS, DEMO_PLAYERS, DEMO_SESSION } from '../lib/demoData'

export interface SimState {
  session: Session
  players: LeaderboardEntry[]
  notifications: AppNotification[]
}

// --- party-mode optimal BrAC table (mirrors BACCalculator._partyModeTargets) ---
const TARGETS: Record<string, number[]> = {
  'male-small': [0.105, 0.21, 0.315, 0.42, 0.525, 0.63, 0.735, 0.735, 0.735, 0.735],
  'male-medium': [0.111, 0.223, 0.335, 0.446, 0.558, 0.67, 0.782, 0.782, 0.782, 0.782],
  'male-large': [0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 0.875, 0.875, 0.875],
  'female-small': [0.086, 0.173, 0.26, 0.346, 0.433, 0.52, 0.607, 0.607, 0.607, 0.607],
  'female-medium': [0.108, 0.216, 0.325, 0.433, 0.541, 0.65, 0.758, 0.758, 0.758, 0.758],
  'female-large': [0.118, 0.236, 0.355, 0.473, 0.591, 0.71, 0.828, 0.828, 0.828, 0.828],
}

export function optimalFor(entry: LeaderboardEntry, round: number): number {
  if (round <= 0) return 0
  const sex = entry.identity?.sex ?? 'male'
  const size = entry.identity?.bodySize ?? 'medium'
  const arr = TARGETS[`${sex}-${size}`] ?? TARGETS['male-medium']
  return arr[Math.min(round, arr.length) - 1]
}

/** Points awarded for a reading vs its optimal (mirrors PointsCalculator). */
export function ptsChange(bac: number, optimal: number): number {
  if (optimal <= 0) return 0
  const pct = Math.abs(bac - optimal) / optimal
  if (pct <= 0.1) return 2
  if (pct <= 0.2) return 1
  if (pct <= 0.4) return 0
  if (pct <= 0.8) return -1
  return bac > optimal ? -4 : -2
}

export const TITLE_META: Record<string, { displayName: string; emoji: string }> = {
  velocidadDeCrucero: { displayName: 'Velocidad de Crucero', emoji: '🟢' },
  multaPorExceso: { displayName: 'Multa por Exceso', emoji: '🔴' },
  lDePracticas: { displayName: 'L de Prácticas', emoji: '🔰' },
  vehiculoHibrido: { displayName: 'El favorito de la DGV', emoji: '🔋' },
  itvPassed: { displayName: 'ITV Pasada', emoji: '🛠️' },
}

/** The app's notification quick-templates (notification_composer_screen.dart). */
export const NOTIF_TEMPLATES: Record<NotificationType, { emoji: string; label: string }> = {
  manual: { emoji: '📣', label: '' },
  fine: { emoji: '🚔', label: 'Nueva multa expedida' },
  streak: { emoji: '🔥', label: '¡Racha en curso! Hay alguien imparable esta noche...' },
  moab: { emoji: '🍺', label: '¡Alerta MOAB! Mother Of All Beers detectada' },
  zone: { emoji: '✅', label: '¡Zona verde conseguida! Gran conducción' },
}

const uid = () =>
  typeof crypto !== 'undefined' && crypto.randomUUID
    ? crypto.randomUUID()
    : `sim-${Date.now()}-${Math.round(performance.now())}`
const now = () => Timestamp.fromMillis(Date.now())
const clamp = (n: number) => Math.max(0, Math.min(STARTING_POINTS, n))

/** Fresh seed from the demo fixtures (deep-ish copy so we never mutate them). */
export function seed(): SimState {
  return {
    session: { ...DEMO_SESSION },
    players: DEMO_PLAYERS.map((p) => ({
      ...p,
      readings: [...p.readings],
      titleDetails: p.titleDetails.map((t) => ({ ...t })),
      titleCounts: { ...p.titleCounts },
      bacHistory: [...p.bacHistory],
      optimalBACHistory: [...p.optimalBACHistory],
    })),
    notifications: DEMO_NOTIFICATIONS.map((n) => ({ ...n })),
  }
}

/** Recompute points + histories from a player's readings (idempotent). */
function withReadings(p: LeaderboardEntry, readings: Reading[]): LeaderboardEntry {
  const active = readings.filter((r) => r.roundNumber > 0).sort((a, b) => a.roundNumber - b.roundNumber)
  const points = clamp(STARTING_POINTS + readings.reduce((s, r) => s + r.pointsChange, 0))
  return {
    ...p,
    readings,
    points,
    bacHistory: active.map((r) => r.bac),
    optimalBACHistory: active.map((r) => r.optimalBAC),
  }
}

export type SimAction =
  | { kind: 'notify'; nType: NotificationType; text: string; targetPlayerId?: string | null }
  | { kind: 'newRound' }
  | { kind: 'finish' }
  | { kind: 'reopen' }
  | { kind: 'addReading'; playerId: string; bac: number }
  | { kind: 'fine'; playerId: string }
  | { kind: 'grantTitle'; playerId: string; titleKey: string }
  | { kind: 'toggleIncautado'; playerId: string }
  | { kind: 'reset' }

const mapPlayer = (
  players: LeaderboardEntry[],
  id: string,
  fn: (p: LeaderboardEntry) => LeaderboardEntry,
) => players.map((p) => (p.id === id ? fn(p) : p))

export function simReducer(state: SimState, action: SimAction): SimState {
  switch (action.kind) {
    case 'notify':
      return {
        ...state,
        notifications: [
          ...state.notifications,
          {
            id: uid(),
            text: action.text,
            timestamp: now(),
            status: 'pending',
            type: action.nType,
            targetPlayerId: action.targetPlayerId ?? null,
          },
        ],
      }

    case 'newRound':
      // → sessions/{id}.currentRound += 1 (syncRoundComplete). Triggers the siren.
      return { ...state, session: { ...state.session, currentRound: state.session.currentRound + 1 } }

    case 'finish':
      // → sessions/{id} { isFinished:true, isInProgress:false, finishTime } (syncGameFinish).
      return {
        ...state,
        session: { ...state.session, isFinished: true, isInProgress: false, finishTime: now() },
      }

    case 'reopen':
      return {
        ...state,
        session: { ...state.session, isFinished: false, isInProgress: true },
      }

    case 'addReading':
      return {
        ...state,
        players: mapPlayer(state.players, action.playerId, (p) => {
          const round = state.session.currentRound
          const optimal = optimalFor(p, round)
          const reading: Reading = {
            id: uid(),
            bac: action.bac,
            timestamp: now(),
            roundNumber: round,
            entryMethod: 'manual',
            pointsChange: ptsChange(action.bac, optimal),
            optimalBAC: optimal,
          }
          return withReadings(p, [...p.readings.filter((r) => r.roundNumber !== round), reading])
        }),
      }

    case 'fine': {
      // Mirrors a fine: -4 reading + fineCount/moneyLost, plus the app's auto
      // "🚔 Multa para {name}" notification (checkpoint_providers.dart).
      const target = state.players.find((p) => p.id === action.playerId)
      const name = target?.identity?.name ?? 'Conductor'
      return {
        ...state,
        players: mapPlayer(state.players, action.playerId, (p) => {
          const round = state.session.currentRound
          const optimal = optimalFor(p, round)
          const bac = Number((Math.max(optimal, 0.3) * 2).toFixed(2))
          const reading: Reading = {
            id: uid(),
            bac,
            timestamp: now(),
            roundNumber: round,
            entryMethod: 'manual',
            pointsChange: -4,
            optimalBAC: optimal,
          }
          return withReadings(
            { ...p, fineCount: p.fineCount + 1, moneyLost: p.moneyLost + 100, crossedOptimalLine: true },
            [...p.readings.filter((r) => r.roundNumber !== round), reading],
          )
        }),
        notifications: [
          ...state.notifications,
          {
            id: uid(),
            text: `🚔 Multa para ${name}`,
            timestamp: now(),
            status: 'pending',
            type: 'fine',
            targetPlayerId: action.playerId,
          },
        ],
      }
    }

    case 'grantTitle':
      return {
        ...state,
        players: mapPlayer(state.players, action.playerId, (p) => {
          const meta = TITLE_META[action.titleKey]
          if (!meta) return p
          const has = p.titleDetails.some((t) => t.key === action.titleKey)
          const titleDetails = has
            ? p.titleDetails.map((t) =>
                t.key === action.titleKey ? { ...t, count: t.count + 1 } : t,
              )
            : [...p.titleDetails, { key: action.titleKey, ...meta, count: 1 }]
          return {
            ...p,
            titleDetails,
            titleCounts: { ...p.titleCounts, [action.titleKey]: (p.titleCounts[action.titleKey] ?? 0) + 1 },
          }
        }),
      }

    case 'toggleIncautado':
      return {
        ...state,
        players: mapPlayer(state.players, action.playerId, (p) => ({ ...p, isIncautado: !p.isIncautado })),
      }

    case 'reset':
      return seed()
  }
}
