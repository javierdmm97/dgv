import { initializeApp } from 'firebase/app'
import { getFirestore } from 'firebase/firestore'

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
export const db = getFirestore(app)
