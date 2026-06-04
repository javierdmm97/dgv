# Operación DGV — Web Frontend

A **read-only, public, real-time leaderboard** for the Operación DGV party game.
The Flutter app (on one phone) is the sole writer to Firestore; this web app only
reads via real-time listeners and is meant to be shown on a projector and opened
on guests' phones via a shared URL.

> Schema source of truth: `../lib/features/firebase/services/firebase_sync_service.dart`.
> Gameplay state lives in `sessions/{id}/players/{pid}` (NOT `players/{id}` — the
> ROADMAP §4.2 block is stale). Identity (name/photo) is in `players/{id}`.

## Stack
Vite + React + TypeScript + Firebase Web SDK (modular v10). Deploys to Firebase Hosting.

## Setup
```bash
cd web
npm install
cp .env.example .env      # then fill VITE_FIREBASE_* from the Firebase console (Web app)
npm run dev               # local dev at http://localhost:5173
```

## Build & deploy
```bash
npm run build             # → dist/
firebase deploy --only hosting     # uses web/firebase.json + web/.firebaserc
# or: npm run deploy
```

## CI/CD (auto-deploy)
`.github/workflows/deploy-web.yml` builds and deploys to Firebase Hosting on every
push to `main` that touches `web/**` (path-filtered). It needs one repo secret —
**`FIREBASE_TOKEN`** — which must be set by a repo admin:

```bash
firebase login:ci          # run locally as the Firebase project owner → copy the token
gh secret set FIREBASE_TOKEN --repo javierdmm97/dgv   # a repo admin pastes the token
```

Build-time `VITE_FIREBASE_*` come from the committed `web/.env.production` (public
client keys), so no other secrets/variables are needed.

## Structure
```
src/
  lib/
    firebase.ts      Firebase init from .env
    types.ts         Firestore document types (verified against the app)
    theme.ts         DGT colors + zone/points color helpers
    scoring.ts       leaderboard ranking + perfection-score tiebreaker
    ticker.ts        deterministic, write-free notification schedule
  hooks/
    useActiveSession.ts   picks the in-progress session (latest by startTime)
    usePlayers.ts         joins sessions/{id}/players + players/{id}
    useNotifications.ts   live notifications stream
  components/
    Leaderboard.tsx · PlayerRow.tsx
    NotificationTicker.tsx   one notification at a time, 10s, countdown bar
    Ceremony.tsx             end-of-game podium / environmentals / coleccionista
    AudioController.tsx      checkpoint siren (watches sessions.lastSirenAt)
    EmptyState.tsx
public/
    police_siren.mp3 · dgv_logo.png
```

## The notification ticker (no writes)
The app's original design had the web flip `status: pending→read`, but that breaks
with multiple viewers. Instead the ticker is a **pure function of the notification
list + the wall clock** (`lib/ticker.ts`): each notification plays for 10s, chained
in creation order, so every screen independently shows the same item — no writes,
no races. Late joiners sync to the same current item; expired notifications never
replay (only a recent burst's still-queued tail is shown).

## Pending dependencies (app/Firebase side)
1. **Firestore security rules** — the web needs public read on `sessions`,
   `sessions/{id}/players`, `players`, and `notifications`. No write access needed.
   Suggested rules:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{db}/documents {
       match /sessions/{s}        { allow read: if true; allow write: if false; }
       match /sessions/{s}/players/{p} { allow read: if true; allow write: if false; }
       match /players/{p}         { allow read: if true; allow write: if false; }
       match /notifications/{n}   { allow read: if true; allow write: if false; }
     }
   }
   ```
   (The app authenticates separately as the writer; tighten `write` to that path as needed.)
2. **Siren signal** — the app should write `sessions/{id}.lastSirenAt =
   serverTimestamp()` when a checkpoint fires. `AudioController` already watches it.
3. **Web Firebase app** — register a Web app in the console to get `VITE_FIREBASE_*`.
```
