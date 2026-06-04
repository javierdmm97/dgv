// Enriched leaderboard rows derived from raw entries. Pure helpers built on top
// of scoring.ts so components don't recompute ranking/zone logic ad hoc.

import type { LeaderboardEntry, Reading } from './types'
import { lastReading, rankLeaderboard } from './scoring'
import { zoneKey, type ZoneKey } from './theme'

export interface Row {
  entry: LeaderboardEntry
  rank: number
  last?: Reading
  zone?: ZoneKey
  totalTitles: number
}

/** Total titles earned across all types. */
export function totalTitles(e: LeaderboardEntry): number {
  return e.titleDetails?.reduce((s, t) => s + (t.count || 0), 0) ?? 0
}

/** Highest BAC ever read (drives the environmental distinctive ranking). */
export function maxBac(readings: Reading[]): number {
  return readings.reduce((m, r) => Math.max(m, r.bac), 0)
}

/** Ranked, enriched rows (impounded drivers already excluded by rankLeaderboard). */
export function rankRows(entries: LeaderboardEntry[]): Row[] {
  return rankLeaderboard(entries).map((entry, i) => {
    const last = lastReading(entry.readings)
    return {
      entry,
      rank: i + 1,
      last,
      zone: last ? zoneKey(last.bac, last.optimalBAC) : undefined,
      totalTitles: totalTitles(entry),
    }
  })
}

/** Impounded drivers, shown apart from the active ranking. */
export function incautados(entries: LeaderboardEntry[]): LeaderboardEntry[] {
  return entries.filter((e) => e.isIncautado)
}

/** How many ranked drivers are currently inside their optimal zone. */
export function countInZone(rows: Row[]): number {
  return rows.filter((r) => r.zone === 'green').length
}
