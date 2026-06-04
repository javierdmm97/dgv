import type { Timestamp } from 'firebase/firestore'

// ---------------------------------------------------------------------------
// Firestore document types — mirror exactly what the Flutter app writes via
// lib/features/firebase/services/firebase_sync_service.dart.
// IMPORTANT: gameplay state lives in sessions/{id}/players/{pid}, NOT players/{id}.
// (The ROADMAP §4.2 schema block is stale — trust this.)
// ---------------------------------------------------------------------------

export type TitleKey =
  | 'velocidadDeCrucero'
  | 'multaPorExceso'
  | 'lDePracticas'
  | 'vehiculoHibrido'
  | 'itvPassed'

export interface TitleDetail {
  key: TitleKey | string
  displayName: string // already-resolved Spanish name from the app
  emoji: string
  count: number
}

export interface Reading {
  id: string
  bac: number
  timestamp: Timestamp
  roundNumber: number // 0 = baseline (no target, no scoring)
  entryMethod: 'manual' | 'ocr' | 'roundRobin'
  pointsChange: number
  optimalBAC: number // THE target-line value (already includes pre-game beer offset)
  notes?: string | null
}

/** players/{id} — identity only (no gameplay state). */
export interface PlayerIdentity {
  id: string
  name: string
  surname: string
  sex: 'male' | 'female'
  bodySize: 'small' | 'medium' | 'large'
  photoUrl?: string // base64 data URL (no Firebase Storage on free tier)
}

/** sessions/{id}/players/{pid} — per-session gameplay state (leaderboard source). */
export interface PlayerGameplay {
  id: string
  playerId: string
  points: number
  fineCount: number
  moneyLost: number
  crossedOptimalLine: boolean
  isIncautado: boolean
  titleCounts: Record<string, number>
  titleDetails: TitleDetail[]
  readings: Reading[]
  bacHistory: number[]
  optimalBACHistory: number[]
  photoUrl?: string
}

/** A leaderboard row = gameplay joined with identity (by identical doc id). */
export interface LeaderboardEntry extends PlayerGameplay {
  identity?: PlayerIdentity
}

export interface CeremonyPodium {
  rank: number
  playerId: string
  name: string
  surname: string
  points: number
}

export interface CeremonyColeccionista {
  playerId: string
  name: string
  surname: string
  totalTitles: number
}

export interface CeremonyEnvironmental {
  rank: number
  stickerKey: string // sin_pegatina | pegatina_b | pegatina_c | pegatina_eco | pegatina_0_emisiones
  playerId: string
  name: string
  surname: string
  maxBAC: number
}

export interface Ceremony {
  podium: CeremonyPodium[]
  coleccionista: CeremonyColeccionista | null
  environmentals: CeremonyEnvironmental[]
}

export interface Session {
  id: string
  startTime: Timestamp
  currentRound: number
  isFinished: boolean
  isInProgress: boolean
  playerIds: string[]
  preGameBeers: number
  finishTime?: Timestamp
  ceremony?: Ceremony
  // NEW siren signal — app to write serverTimestamp() when a checkpoint fires
  // (group becomes due OR fully measured). The web watches this to play the siren.
  lastSirenAt?: Timestamp
}

export type NotificationType = 'manual' | 'fine' | 'streak' | 'moab' | 'zone'

export interface AppNotification {
  id: string
  text: string
  imageUrl?: string | null
  timestamp: Timestamp
  status: 'pending' | 'read' // web does NOT write this; ticker is computed client-side
  type: NotificationType
  targetPlayerId?: string | null
}
