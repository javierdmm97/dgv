import type { LeaderboardEntry, Reading } from './types'

/**
 * Perfection score = mean(|bac - optimalBAC|) + variance(|bac - optimalBAC|)
 * over active readings (roundNumber > 0). Lower is better. Mirrors the app's
 * PointsCalculator.calculatePerfectionScore — used as the leaderboard tiebreaker
 * and shown as "Precisión". Uses the optimalBAC stored on each reading (which
 * already bakes in the pre-game beer offset) — never recompute from the round.
 */
export function perfectionScore(readings: Reading[]): number {
  const devs = readings
    .filter((r) => r.roundNumber > 0)
    .map((r) => Math.abs(r.bac - r.optimalBAC))
  if (devs.length === 0) return Number.POSITIVE_INFINITY
  const avg = devs.reduce((a, b) => a + b, 0) / devs.length
  const variance = devs.reduce((a, d) => a + (d - avg) ** 2, 0) / devs.length
  return avg + variance
}

/**
 * Ranked leaderboard: exclude impounded (isIncautado) players, sort by points
 * DESC, tiebreak by perfection score ASC. Mirrors TitleEvaluator.calculateLeaderboard.
 */
export function rankLeaderboard(entries: LeaderboardEntry[]): LeaderboardEntry[] {
  return [...entries]
    .filter((e) => !e.isIncautado)
    .sort(
      (a, b) =>
        b.points - a.points ||
        perfectionScore(a.readings) - perfectionScore(b.readings),
    )
}

/** Most recent scored reading (roundNumber > 0), for the "Último registro" line. */
export function lastReading(readings: Reading[]): Reading | undefined {
  const active = readings
    .filter((r) => r.roundNumber > 0)
    .sort((a, b) => a.roundNumber - b.roundNumber)
  return active[active.length - 1]
}
