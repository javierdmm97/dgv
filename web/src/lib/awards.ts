// End-of-game (and provisional, in-progress) award derivation — mirrors the
// app's TitleEvaluator so the web can render the ceremony from live entries even
// before the app writes `session.ceremony`.

import type { LeaderboardEntry } from './types'
import { rankLeaderboard } from './scoring'
import { maxBac, totalTitles } from './leaderboard'

/** Environmental distinctive sticker by rank (1-based) among the top-5 max-BAC. */
export const STICKER_BY_RANK = [
  'sin_pegatina',
  'pegatina_b',
  'pegatina_c',
  'pegatina_eco',
  'pegatina_0_emisiones',
] as const

export const STICKER_LABEL: Record<string, string> = {
  sin_pegatina: 'Sin distintivo',
  pegatina_b: 'Distintivo B',
  pegatina_c: 'Distintivo C',
  pegatina_eco: 'Distintivo ECO',
  pegatina_0_emisiones: 'Distintivo 0',
}

export function stickerForRank(rank1: number): string {
  return STICKER_BY_RANK[Math.min(Math.max(rank1, 1), 5) - 1]
}

export interface Environmental {
  rank: number
  stickerKey: string
  entry: LeaderboardEntry
  maxBAC: number
}

/** Top-5 "más contaminantes" by max BAC, each tagged with its sticker. */
export function environmentals(entries: LeaderboardEntry[]): Environmental[] {
  return [...entries]
    .sort((a, b) => maxBac(b.readings) - maxBac(a.readings))
    .slice(0, 5)
    .map((entry, i) => ({
      rank: i + 1,
      stickerKey: stickerForRank(i + 1),
      entry,
      maxBAC: maxBac(entry.readings),
    }))
}

/** Driver with the most titles (excludes impounded). */
export function coleccionista(entries: LeaderboardEntry[]): LeaderboardEntry | null {
  const eligible = entries.filter((e) => !e.isIncautado && totalTitles(e) > 0)
  if (eligible.length === 0) return null
  return eligible.reduce((best, e) => (totalTitles(e) > totalTitles(best) ? e : best))
}

/** Top-3 by the leaderboard ranking. */
export function podium(entries: LeaderboardEntry[]): LeaderboardEntry[] {
  return rankLeaderboard(entries).slice(0, 3)
}
