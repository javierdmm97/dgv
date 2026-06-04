// Deterministic Spanish-style license plate per driver ("0427 LUF"), used as a
// stable identity chip. Digits hash from the player id (stable across rounds);
// letters from the name. Pure / no randomness so every client agrees.

export interface Plate {
  digits: string // 4 digits
  letters: string // 3 letters
}

export function plateOf(id: string, name = '', surname = ''): Plate {
  let h = 0
  for (const c of id) h = (h * 31 + c.charCodeAt(0)) >>> 0
  const digits = String(h % 10000).padStart(4, '0')
  const src = `${surname}${name}`.toUpperCase().replace(/[^A-Z]/g, '')
  const letters = `${src}DGV`.slice(0, 3)
  return { digits, letters }
}
