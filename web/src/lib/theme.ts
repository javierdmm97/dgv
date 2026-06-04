// Palette + zone logic. The "Centro de Control" chrome lives in CSS tokens
// (styles/tokens.css); this file is the TS mirror for values needed inside SVG
// or inline styles, plus the zone math (thresholds mirror the Flutter app).

/** True DGT palette from the app's DGTColors — used by the carnet "paper". */
export const DGT = {
  primary: '#0F5993', // DGT blue
  background: '#F6F4F5',
  licenseId: '#F3E8EC', // license-card pink
  surface: '#FFFFFF',
  green: '#D2D667',
  yellow: '#F4E944',
  orange: '#F3910E',
  red: '#EF6B6A',
  textPrimary: '#000000',
  textSecondary: '#666666',
  textOnPrimary: '#FFFFFF',
} as const

export type ZoneKey = 'green' | 'yellow' | 'orange' | 'red'

/**
 * Zone colors as CSS variable references, so they follow the active theme
 * (dark/light) automatically — the concrete hexes live in styles/tokens.css.
 * Used in inline styles / SVG (via `style`), never as raw SVG attributes.
 */
export const ZONE: Record<ZoneKey, string> = {
  green: 'var(--green)',
  yellow: 'var(--yellow)',
  orange: 'var(--orange)',
  red: 'var(--red)',
}

/**
 * Which zone a BAC measurement falls into vs its round's optimal target.
 * Thresholds mirror the app: ≤10% green, ≤20% yellow, ≤40% orange, else red.
 */
export function zoneKey(bac: number, optimal: number): ZoneKey {
  if (optimal <= 0) return 'orange'
  const pct = Math.abs(bac - optimal) / optimal
  if (pct <= 0.1) return 'green'
  if (pct <= 0.2) return 'yellow'
  if (pct <= 0.4) return 'orange'
  return 'red'
}

/** Hex color of a BAC measurement by zone proximity. */
export function zoneColor(bac: number, optimal: number): string {
  return ZONE[zoneKey(bac, optimal)]
}

/** Short human label for a zone (baseline round has no target). */
export function zoneLabel(bac: number, optimal: number): string {
  if (optimal <= 0) return 'Base'
  const k = zoneKey(bac, optimal)
  const over = bac > optimal
  if (k === 'green') return 'En zona'
  if (k === 'yellow') return 'Cerca'
  if (k === 'orange') return over ? 'Por encima' : 'Por debajo'
  return over ? 'Pasado' : 'Muy bajo'
}

export type PointsKey = 'green' | 'orange' | 'red'

/** Bucket for a player's remaining license points (15 = full). */
export function pointsKey(points: number): PointsKey {
  if (points >= 10) return 'green'
  if (points >= 5) return 'orange'
  return 'red'
}

/** Color for a player's remaining license points. */
export function pointsColor(points: number): string {
  return ZONE[pointsKey(points)]
}

/** Emoji per notification type, mirroring the in-app composer templates. */
export const NOTIFICATION_EMOJI: Record<string, string> = {
  fine: '🚔',
  streak: '🔥',
  moab: '🍺',
  zone: '✅',
  manual: '📣',
}

export const STARTING_POINTS = 15
