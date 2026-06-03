// DGT palette — EXACT values from the Flutter app's DGTColors.
// (Note: the hex in CLAUDE.md / the original brief are wrong; these are the real ones.)
export const DGT = {
  primary: '#0F5993', // DGT blue
  background: '#F6F4F5',
  licenseId: '#F3E8EC', // license-card pink
  surface: '#FFFFFF',
  green: '#D2D667', // zone: on target
  yellow: '#F4E944', // zone: close
  orange: '#F3910E', // zone: far
  red: '#EF6B6A', // zone: fine / danger
  textPrimary: '#000000',
  textSecondary: '#666666',
  textOnPrimary: '#FFFFFF',
} as const

/** Color of a BAC measurement by its proximity to the round's optimal target. */
export function zoneColor(bac: number, optimal: number): string {
  if (optimal <= 0) return DGT.orange
  const pct = Math.abs(bac - optimal) / optimal
  if (pct <= 0.1) return DGT.green
  if (pct <= 0.2) return DGT.yellow
  if (pct <= 0.4) return DGT.orange
  return DGT.red
}

/** Color for a player's remaining license points (15 = full). */
export function pointsColor(points: number): string {
  if (points >= 10) return DGT.green
  if (points >= 5) return DGT.orange
  return DGT.red
}

/** Emoji per notification type, mirroring the in-app composer templates. */
export const NOTIFICATION_EMOJI: Record<string, string> = {
  fine: '🚔',
  streak: '🔥',
  moab: '🍺',
  zone: '✅',
  manual: '📣',
}
