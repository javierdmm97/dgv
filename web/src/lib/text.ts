/**
 * Some notification texts already begin with an emoji (e.g. "🚔 Multa para X").
 * The UI shows a type emoji badge separately, so strip a leading emoji to avoid
 * showing it twice.
 */
export function stripLeadingEmoji(t: string): string {
  return t.replace(/^\s*\p{Extended_Pictographic}️?\s*/u, '')
}
