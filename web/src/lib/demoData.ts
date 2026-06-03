import { Timestamp } from 'firebase/firestore'
import type { AppNotification, LeaderboardEntry, Reading, Session } from './types'

// Sample data for visual review only — enabled with ?demo=1. Never used in prod.

function readings(optimals: number[], bacs: number[]): Reading[] {
  return optimals.map((optimalBAC, i) => ({
    id: `r${i + 1}`,
    bac: bacs[i],
    timestamp: Timestamp.fromMillis(Date.now() - (optimals.length - i) * 600_000),
    roundNumber: i + 1,
    entryMethod: 'manual',
    pointsChange: 0,
    optimalBAC,
  }))
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
  return {
    id,
    playerId: id,
    points,
    fineCount: 0,
    moneyLost: 0,
    crossedOptimalLine: false,
    isIncautado: false,
    titleCounts: {},
    titleDetails: [],
    readings: rs,
    bacHistory: bacs,
    optimalBACHistory: optimals,
    identity: { id, name, surname, sex: 'male', bodySize: 'medium' },
    ...extra,
  }
}

const OPT = [0.111, 0.223, 0.335, 0.446, 0.558]

export const DEMO_PLAYERS: LeaderboardEntry[] = [
  entry('p3', 'Carla', 'Méndez', 15, OPT, [0.108, 0.22, 0.33, 0.45, 0.56], {
    titleDetails: [
      { key: 'velocidadDeCrucero', displayName: 'Velocidad de Crucero', emoji: '🟢', count: 3 },
      { key: 'lDePracticas', displayName: 'L de Prácticas', emoji: '🔰', count: 1 },
    ],
  }),
  entry('p1', 'Ana', 'García', 13, OPT, [0.12, 0.24, 0.30, 0.49, 0.52], {
    titleDetails: [{ key: 'velocidadDeCrucero', displayName: 'Velocidad de Crucero', emoji: '🟢', count: 2 }],
  }),
  entry('p5', 'Elena', 'Vidal', 8, OPT, [0.09, 0.27, 0.40, 0.40, 0.66], {
    titleDetails: [{ key: 'vehiculoHibrido', displayName: 'El favorito de la DGV', emoji: '🔋', count: 1 }],
  }),
  entry('p2', 'Bruno', 'Ruiz', 6, OPT, [0.15, 0.31, 0.34, 0.62, 0.59], {
    fineCount: 1,
    moneyLost: 100,
    crossedOptimalLine: true,
    titleDetails: [{ key: 'multaPorExceso', displayName: 'Multa por Exceso', emoji: '🔴', count: 1 }],
  }),
  entry('p4', 'Diego', 'Soto', 3, OPT, [0.2, 0.45, 0.62, 0.88, 1.05], {
    fineCount: 2,
    moneyLost: 200,
    crossedOptimalLine: true,
    titleDetails: [{ key: 'multaPorExceso', displayName: 'Multa por Exceso', emoji: '🔴', count: 2 }],
  }),
]

export const DEMO_SESSION: Session = {
  id: 'demo-session',
  startTime: Timestamp.fromMillis(Date.now() - 3_600_000),
  currentRound: 5,
  isFinished: false,
  isInProgress: true,
  playerIds: DEMO_PLAYERS.map((p) => p.id),
  preGameBeers: 2,
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
    text: '🚔 Multa para Diego Soto: exceso de tasa en la Ronda 5',
    timestamp: Timestamp.fromMillis(Date.now() - 3_000),
    status: 'pending',
    type: 'fine',
    targetPlayerId: 'p4',
  },
  {
    id: 'n2',
    text: '✅ ¡Zona verde conseguida! Carla Méndez clava el objetivo',
    timestamp: Timestamp.fromMillis(Date.now() - 1_000),
    status: 'pending',
    type: 'zone',
    targetPlayerId: 'p3',
  },
]
