import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './styles/fonts.css'
import './styles/tokens.css'

// Apply the saved theme before first paint (default dark, no flash of wrong theme).
try {
  document.documentElement.dataset.theme =
    localStorage.getItem('dgv:theme') === 'light' ? 'light' : 'dark'
} catch {
  document.documentElement.dataset.theme = 'dark'
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
