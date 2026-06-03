import type { AppNotification } from './types'

/** How long each notification is displayed, in milliseconds. */
export const DISPLAY_MS = 10_000

export interface ScheduledItem {
  notification: AppNotification
  start: number // ms epoch
  end: number // ms epoch
}

export interface TickerState {
  active: ScheduledItem | null
  /** 0→1 progress through the active item's window (drives the countdown bar). */
  progress: number
  /** When the active item ends (ms epoch) — schedule the next re-evaluation. */
  nextChangeAt: number | null
}

/**
 * Deterministic, write-free ticker schedule.
 *
 * Every client computes the SAME schedule from the same notifications + clock,
 * so the projector and all phones show the same item at the same time without
 * any client writing to Firestore. Each notification plays for DISPLAY_MS,
 * chained in creation order (never before it was created, never overlapping):
 *
 *   start_i = max(timestamp_i, end_{i-1});  end_i = start_i + DISPLAY_MS
 *
 * Bursts queue FIFO; items whose window already passed never replay; a late
 * joiner lands on the same current item. No `status` flips required.
 */
export function buildSchedule(notifications: AppNotification[]): ScheduledItem[] {
  const sorted = [...notifications].sort((a, b) => {
    const ta = a.timestamp?.toMillis?.() ?? 0
    const tb = b.timestamp?.toMillis?.() ?? 0
    return ta - tb || a.id.localeCompare(b.id)
  })

  const schedule: ScheduledItem[] = []
  let cursor = Number.NEGATIVE_INFINITY
  for (const n of sorted) {
    const created = n.timestamp?.toMillis?.() ?? 0
    const start = Math.max(created, cursor)
    const end = start + DISPLAY_MS
    schedule.push({ notification: n, start, end })
    cursor = end
  }
  return schedule
}

/** Resolve the active item (and countdown progress) for a given wall-clock `now`. */
export function resolveTicker(schedule: ScheduledItem[], now: number): TickerState {
  const active = schedule.find((s) => now >= s.start && now < s.end) ?? null
  if (!active) {
    // Idle until the next upcoming item's start (if any).
    const upcoming = schedule.find((s) => s.start > now)
    return { active: null, progress: 0, nextChangeAt: upcoming?.start ?? null }
  }
  const progress = (now - active.start) / DISPLAY_MS
  return { active, progress, nextChangeAt: active.end }
}
