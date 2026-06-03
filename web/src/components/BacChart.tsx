import { DGT, zoneColor } from '../lib/theme'
import type { Reading } from '../lib/types'

/**
 * BAC progression "lollipop" chart — mirrors the Flutter app's _LollipopChart.
 *
 *  - X axis: one slot per scored round (roundNumber > 0), label "R{n}".
 *  - Y axis: BAC (mg/L), 0 → maxY (rounded up to the next 0.5 above the data).
 *  - Green polyline: the per-round optimal target, read from each reading's
 *    stored optimalBAC (already includes the pre-game beer offset — never recompute).
 *  - Each round: a vertical stick from optimal → measured BAC plus a dot at the
 *    measured BAC, colored by zone proximity (green/yellow/orange/red).
 *
 * `compact` renders an axis-less sparkline for inline use in a leaderboard row.
 */
export function BacChart({
  readings,
  width = 460,
  height = 260,
  compact = false,
}: {
  readings: Reading[]
  width?: number
  height?: number
  compact?: boolean
}) {
  const pts = readings
    .filter((r) => r.roundNumber > 0)
    .sort((a, b) => a.roundNumber - b.roundNumber)

  if (pts.length === 0) {
    return compact ? null : <div className="chart chart--empty">Sin mediciones todavía</div>
  }

  const leftPad = compact ? 4 : 44
  const rightPad = compact ? 4 : 16
  const topPad = compact ? 6 : 12
  const bottomPad = compact ? 6 : 28

  const rawMax = Math.max(...pts.flatMap((p) => [p.bac, p.optimalBAC])) + 0.15
  const maxY = Math.max(0.5, Math.ceil(rawMax / 0.5) * 0.5)
  const step = maxY <= 0.5 ? 0.1 : maxY <= 1.0 ? 0.2 : 0.5

  const plotW = width - leftPad - rightPad
  const plotH = height - topPad - bottomPad
  const slotW = plotW / pts.length
  const x = (i: number) => leftPad + (i + 0.5) * slotW
  const y = (v: number) => topPad + plotH * (1 - v / maxY)

  const dotR = compact ? 4 : 7
  const targetPath = pts.map((p, i) => `${x(i)},${y(p.optimalBAC)}`).join(' ')

  const gridLines: number[] = []
  if (!compact) for (let v = 0; v <= maxY + 1e-9; v += step) gridLines.push(Number(v.toFixed(2)))

  return (
    <svg
      className="chart"
      width={width}
      height={height}
      viewBox={`0 0 ${width} ${height}`}
      role="img"
      aria-label="Progresión de tasa de alcohol"
    >
      {/* Gridlines + Y labels */}
      {gridLines.map((v) => (
        <g key={v}>
          <line x1={leftPad} y1={y(v)} x2={width - rightPad} y2={y(v)} stroke={DGT.textSecondary} strokeOpacity={0.15} />
          <text x={leftPad - 6} y={y(v) + 3} textAnchor="end" fontSize={9} fill={DGT.textSecondary}>
            {v.toFixed(1)}
          </text>
        </g>
      ))}

      {/* Optimal target line (green) */}
      <polyline points={targetPath} fill="none" stroke={DGT.green} strokeWidth={2} />

      {/* Lollipops: stick (optimal → bac) + dot, colored by zone */}
      {pts.map((p, i) => {
        const color = zoneColor(p.bac, p.optimalBAC)
        return (
          <g key={p.id ?? i}>
            <line x1={x(i)} y1={y(p.optimalBAC)} x2={x(i)} y2={y(p.bac)} stroke={color} strokeOpacity={0.8} strokeWidth={2} />
            <circle cx={x(i)} cy={y(p.bac)} r={dotR} fill={color} stroke="#fff" strokeWidth={compact ? 1 : 1.5} />
            {!compact && (
              <text x={x(i)} y={height - bottomPad + 16} textAnchor="middle" fontSize={9} fill={DGT.textSecondary}>
                R{p.roundNumber}
              </text>
            )}
          </g>
        )
      })}
    </svg>
  )
}
