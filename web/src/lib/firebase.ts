import { initializeApp } from 'firebase/app'
import { initializeFirestore } from 'firebase/firestore'

// Web config comes from .env (VITE_FIREBASE_*). These are public client
// identifiers, not secrets; Firestore security rules are the real access control.
// We use ONLY Firestore — no Storage, no Messaging, no RTDB — so the config holds
// just the fields the Firestore SDK needs (no storageBucket / messagingSenderId).
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
}

export const app = initializeApp(firebaseConfig)

// Auto-detect long-polling: corporate networks / proxies / firewalls often block
// Firestore's default WebChannel streaming, which makes realtime listeners hang and
// then error (surfacing as "Sin partida activa"). Auto-detect transparently falls
// back to long-polling when WebChannel is unavailable, while still using the faster
// WebChannel where it works.
export const db = initializeFirestore(app, {
  experimentalAutoDetectLongPolling: true,
})
