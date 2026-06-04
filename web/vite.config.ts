import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// Read-only public leaderboard. Builds to dist/ for Firebase Hosting.
export default defineConfig({
  plugins: [react()],
  build: { outDir: 'dist', sourcemap: true },
})
