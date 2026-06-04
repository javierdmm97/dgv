import { Timestamp } from 'firebase/firestore'
import type { AppNotification, LeaderboardEntry, Reading, Session, TitleDetail } from './types'

// Sample data for visual review only — enabled with ?demo=1 (and ?demo=ceremony
// for the finished-game view). Never used in prod.

/** Mirror the app's per-reading pointsChange so the carnet history shows ▲/▼. */
function ptsChange(bac: number, optimal: number): number {
  if (optimal <= 0) return 0
  const pct = Math.abs(bac - optimal) / optimal
  if (pct <= 0.1) return 2
  if (pct <= 0.2) return 1
  if (pct <= 0.4) return 0
  if (pct <= 0.8) return -1
  return bac > optimal ? -4 : -2
}

function readings(optimals: number[], bacs: number[]): Reading[] {
  return optimals.map((optimalBAC, i) => ({
    id: `r${i + 1}`,
    bac: bacs[i],
    timestamp: Timestamp.fromMillis(Date.now() - (optimals.length - i) * 600_000),
    roundNumber: i + 1,
    entryMethod: 'manual',
    pointsChange: ptsChange(bacs[i], optimalBAC),
    optimalBAC,
  }))
}

const T = {
  crucero: (count: number): TitleDetail => ({
    key: 'velocidadDeCrucero',
    displayName: 'Velocidad de Crucero',
    emoji: '🟢',
    count,
  }),
  multa: (count: number): TitleDetail => ({
    key: 'multaPorExceso',
    displayName: 'Multa por Exceso',
    emoji: '🔴',
    count,
  }),
  ele: (count: number): TitleDetail => ({
    key: 'lDePracticas',
    displayName: 'L de Prácticas',
    emoji: '🔰',
    count,
  }),
  hibrido: (count: number): TitleDetail => ({
    key: 'vehiculoHibrido',
    displayName: 'El favorito de la DGV',
    emoji: '🔋',
    count,
  }),
  itv: (count: number): TitleDetail => ({
    key: 'itvPassed',
    displayName: 'ITV Pasada',
    emoji: '🛠️',
    count,
  }),
}

function entry(
  id: string,
  name: string,
  surname: string,
  points: number,
  optimals: number[],
  bacs: number[],
  extra: Partial<LeaderboardEntry> = {},
): LeaderboardEntry {
  const rs = readings(optimals, bacs)
  const titleDetails = extra.titleDetails ?? []
  const titleCounts: Record<string, number> = {}
  for (const t of titleDetails) titleCounts[t.key] = t.count
  return {
    id,
    playerId: id,
    points,
    fineCount: 0,
    moneyLost: 0,
    crossedOptimalLine: false,
    isIncautado: false,
    titleCounts,
    titleDetails,
    readings: rs,
    bacHistory: bacs,
    optimalBACHistory: optimals,
    identity: { id, name, surname, sex: 'male', bodySize: 'medium' },
    ...extra,
  }
}

const OPT = [0.111, 0.223, 0.335, 0.446, 0.558, 0.67]

export const DEMO_PLAYERS: LeaderboardEntry[] = [
  entry('p3', 'Carla', 'Méndez', 15, OPT, [0.108, 0.22, 0.33, 0.45, 0.56, 0.66], {
    titleDetails: [T.crucero(4), T.ele(1)],
    identity: { id: 'p3', name: 'Carla', surname: 'Méndez', sex: 'female', bodySize: 'small' },
  }),
  entry('p1', 'Ana', 'García', 13, OPT, [0.12, 0.24, 0.3, 0.49, 0.52, 0.64], {
    titleDetails: [T.crucero(2), T.itv(1)],
    identity: { id: 'p1', name: 'Ana', surname: 'García', sex: 'female', bodySize: 'medium' },
  }),
  entry('p6', 'Hugo', 'Navarro', 11, OPT, [0.1, 0.2, 0.36, 0.43, 0.6, 0.69], {
    titleDetails: [T.crucero(1), T.hibrido(1)],
  }),
  entry('p5', 'Elena', 'Vidal', 8, OPT, [0.05, 0.09, 0.12, 0.18, 0.22, 0.3], {
    titleDetails: [T.hibrido(3), T.ele(2)],
    identity: { id: 'p5', name: 'Elena', surname: 'Vidal', sex: 'female', bodySize: 'small' },
  }),
  entry('p2', 'Bruno', 'Ruiz', 6, OPT, [0.15, 0.31, 0.34, 0.62, 0.59, 0.78], {
    fineCount: 1,
    moneyLost: 100,
    crossedOptimalLine: true,
    titleDetails: [T.multa(1)],
  }),
  entry('p7', 'Iván', 'Cano', 2, OPT, [0.18, 0.4, 0.55, 0.8, 0.95, 1.12], {
    fineCount: 2,
    moneyLost: 200,
    crossedOptimalLine: true,
    titleDetails: [T.multa(2)],
  }),
  entry('p4', 'Diego', 'Soto', 0, OPT, [0.2, 0.45, 0.62, 0.88, 1.05, 1.3], {
    fineCount: 3,
    moneyLost: 300,
    crossedOptimalLine: true,
    isIncautado: true,
    titleDetails: [T.multa(3)],
  }),
]

export const DEMO_SESSION: Session = {
  id: 'demo-session',
  startTime: Timestamp.fromMillis(Date.now() - 3_600_000),
  currentRound: 6,
  isFinished: false,
  isInProgress: true,
  playerIds: DEMO_PLAYERS.map((p) => p.id),
  preGameBeers: 2,
}

export const DEMO_SESSION_FINISHED: Session = {
  ...DEMO_SESSION,
  id: 'demo-session-finished',
  isFinished: true,
  isInProgress: false,
  finishTime: Timestamp.fromMillis(Date.now()),
  // The redesigned Ceremony derives podium/coleccionista/environmentals from the
  // entries (via lib/awards), so an empty marker object is enough to trigger it.
  ceremony: { podium: [], coleccionista: null, environmentals: [] },
}

export const DEMO_NOTIFICATIONS: AppNotification[] = [
  {
    id: 'n0',
    text: '📣 Operación DGV en marcha. ¡Conduce con responsabilidad!',
    timestamp: Timestamp.fromMillis(Date.now() - 60_000),
    status: 'pending',
    type: 'manual',
  },
  {
    id: 'n1',
    text: '🚔 Multa para Iván Cano: exceso de tasa en la Ronda 6',
    timestamp: Timestamp.fromMillis(Date.now() - 5_000),
    status: 'pending',
    type: 'fine',
    targetPlayerId: 'p7',
  },
  {
    id: 'n2',
    text: '✅ ¡Zona verde! Carla Méndez clava el objetivo otra vez',
    timestamp: Timestamp.fromMillis(Date.now() - 2_000),
    status: 'pending',
    type: 'zone',
    targetPlayerId: 'p3',
  },
  {
    id: 'n3',
    text: '🔥 Hugo Navarro encadena 3 rondas en zona',
    timestamp: Timestamp.fromMillis(Date.now() - 500),
    status: 'pending',
    type: 'streak',
    targetPlayerId: 'p6',
  },
]
