# 🚔 Operación DGV (Dirección General de Vitis)

**Party Breathalyzer Tracker with DGT Theme**

A Flutter mobile app that gamifies responsible drinking at parties through a satirical Spanish traffic authority (DGT) theme. Players compete to maintain the most "license points" by pacing their alcohol consumption, not by drinking the most.

> 📚 **Documentation:** [CONTRIBUTING.md](CONTRIBUTING.md) | [Development Guide](docs/DEVELOPMENT.md) | [Automation Guide](docs/AUTOMATION.md) | [Roadmap](ROADMAP.md)

---

## 🎯 Quick Start

### Prerequisites
- Flutter 3.10+ and Dart 3.0+
- Git
- **Lefthook** (for git hooks) - [Installation instructions](#lefthook-installation)
- Android Studio or VS Code with Flutter extensions

### Setup

1. **Clone and setup:**
   ```bash
   git clone https://github.com/yourusername/dgv.git
   cd dgv
   ./setup.sh          # Linux/macOS
   .\setup.ps1         # Windows PowerShell
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Read the docs:**
   - **[AI_INSTRUCTIONS.md](AI_INSTRUCTIONS.md)** - Complete project specification
   - **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute
   - **[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)** - Development workflow
   - **[ROADMAP.md](ROADMAP.md)** - Development plan

---

## 🪝 Lefthook Installation

Lefthook is used for git hooks (pre-commit formatting, linting, etc.). Install it before running the setup script:

### Option 1: Using npm (recommended if you have Node.js)
```bash
npm install -g lefthook
```

### Option 2: Using Homebrew (macOS)
```bash
brew install lefthook
```

### Option 3: Using apt (Ubuntu/Debian/WSL)
```bash
curl -1sLf 'https://dl.cloudsmith.io/public/evilmartians/lefthook/setup.deb.sh' | sudo -E bash
sudo apt install lefthook
```

### Option 4: Direct download
Download the binary from [Lefthook Releases](https://github.com/evilmartians/lefthook/releases) and add it to your PATH.

### Verify installation
```bash
lefthook version
```

After installing lefthook, run the setup script to configure git hooks:
```bash
./setup.sh          # Linux/macOS/WSL
.\setup.ps1         # Windows PowerShell
```

---

## 📁 Project Structure

```
lib/
├── core/                    # Shared resources (theme, constants, utils, models)
│   ├── constants/           # App constants, asset paths, DGT strings + fake news
│   ├── models/              # Freezed models (PlayerProfile, BACReading, GameState, etc.)
│   ├── providers/           # Riverpod providers (player, game state, checkpoint)
│   ├── storage/             # Hive service
│   ├── theme/               # DGT color palette, typography, theme config
│   └── utils/               # Business logic (BACCalculator, PointsCalculator, etc.)
├── data/
│   └── repositories/        # Hive-backed repository implementations
├── widgets/                 # Reusable UI components
│   ├── massive_button.dart  # 80px min-height drunk-proof button
│   ├── custom_keypad.dart   # 3×4 grid keypad (no native keyboard)
│   ├── title_badge.dart     # DGT title icon + ×N counter
│   └── license_card.dart    # Player license card with photo, points, badges
└── features/                # Feature modules (feature-first architecture)
    ├── main_menu/           # Persistent home screen + fake news/error screens
    ├── player_registration/ # Player creation & setup (Phase 2)
    ├── breathalyzer/        # BAC data entry & OCR (Phase 2/3)
    ├── checkpoint/          # Round management & timer UI (Phase 2)
    ├── scoring/             # Points calculation & penalties (Phase 2)
    ├── leaderboard/         # "Carnet por Puntos" display (Phase 2)
    ├── achievements/        # DGT titles & awards (Phase 3)
    └── fake_id/             # DGT License generation (Phase 4)
```

---

## 🎮 Core Features

### ✅ Implemented (Phase 1)
1. **Main Menu** - Persistent home screen with Start/Resume Game, Mis Vehículos, Fake News section
2. **Fake News Screen** - Satirical DGT articles list + full article view
3. **Fake Error Screen** - Satirical DGT error modal with close button
4. **Checkpoint Provider** - Per-group timer management with Hive persistence and restart recovery
5. **MassiveButton** - 80px min-height, haptic feedback, drunk-proof button widget
6. **CustomKeypad** - 3×4 grid, 80×80px buttons, 0.XX format, no native keyboard
7. **TitleBadge** - DGT title icon with ×N accumulation counter
8. **LicenseCard** - Player license with circular photo, points, title badges, impounded overlay

### 📋 Planned (Phase 2+)
9. **Player Registration** - Name + surname, sex/body size, photo capture, auto-generated license ID
10. **Round 0 (Baseline)** - Initial BAC measurement with no feedback (silent baseline)
11. **Breathalyzer Data Entry** - Manual keypad, OCR camera, round-robin lineup
12. **Checkpoint System UI** - Timed rounds with police siren alerts
13. **"Sweet Spot" System** - Price is Right mechanic: get close to optimal BAC without going over
14. **Points System UI** - Hybrid scoring: gain points for staying in zone, lose for dangerous behavior
15. **Real-time Feedback** - Messages after each measurement (points, titles, warnings)
16. **Live License Updates** - Licenses auto-update with badges, viewable anytime by clicking player
17. **Leaderboard** - Real-time rankings with BAC progression graphs
18. **DGT Titles** - Per-round awards with logos (Velocidad de Crucero, Multa por Exceso, etc.)
19. **Environmental Badges** - Top 5 highest BAC players get eco-style distinctive badges (as a joke)
20. **Final Ceremony** - 3 Grand Prizes + Environmental Distinctives reveal with animations
21. **Persistent State** - All data saved continuously, resume game after crash/restart

---

## 🛠️ Tech Stack

- **Framework:** Flutter 3.10+ (Dart 3.0+)
- **State Management:** Riverpod 2.0+ with code generation
- **Local Storage:** Hive 2.0+
- **Models:** Freezed for immutable data classes
- **OCR:** Google ML Kit Text Recognition
- **Charts:** fl_chart
- **Audio:** audioplayers

---

## 📋 Development Commands

```bash
# Setup
flutter pub get
lefthook install
dart run build_runner build -d

# Development
dart format .                           # Format code
flutter analyze                         # Static analysis
flutter test                            # Run tests
dart run build_runner watch -d          # Watch mode for code generation

# Build
flutter build apk --release             # Android APK
flutter build appbundle --release       # Android App Bundle
```

**See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for complete workflow and standards.**

---

## 🎨 Design System

### DGT Color Palette
- **Primary:** `#0F5993` (DGT Blue)
- **Background:** `#F6F4F5` (Light Gray)
- **License ID:** `#F3E8EC` (Light Pink)
- **Green:** `#D2D667` (Lime Green)
- **Yellow:** `#F4E944` (Bright Yellow)
- **Orange:** `#F3910E` (Traffic Orange)
- **Red:** `#EF6B6A` (Violation Red)

### UI/UX Principles
- **Oversized touch targets** (minHeight: 80)
- **No native keyboards** for numerical input
- **High contrast** for impaired vision
- **Minimal navigation** to reduce cognitive load
- **Instant feedback** with audio + visual cues

---

## 🧮 Game Mechanics

### Measurement System
The app uses **breathalyzer readings in mg/L** (milligrams per liter of exhaled air), which is the standard DGT measurement format. This is different from blood alcohol concentration (BAC) percentages.

### "Sweet Spot" System (Price is Right Mechanic)
The optimal BrAC target **grows each round** as players consume more drinks. It is derived from official DGT BrAC tables (midpoint of published ranges), calibrated per sex and body size. Round N ≈ N drinks consumed.

**Body size groups (from DGT):**
- Men: Small = 60–70 kg, Medium = 70–90 kg, Large = 90–110 kg
- Women: Small = 40–50 kg, Medium = 50–70 kg, Large = 70–90 kg

**Example progression (men, medium — 70–90 kg):**
| Round | Optimal BrAC | "In zone" band |
|-------|-------------|----------------|
| 1 | 0.13 mg/L | 0.00–0.33 |
| 3 | 0.38 mg/L | 0.18–0.58 |
| 5 | 0.62 mg/L | 0.42–0.82 |
| 8 | 0.99 mg/L | 0.79–1.19 |

**Tolerance zones (applied to the per-round target):**
- **In the zone:** ±0.2 mg/L from optimal → **+4 points**
- **Close to optimal:** ±0.4 mg/L from optimal → **+2 points**

### Points System (Simplified)
- Everyone starts with **15 points** (hard cap — cannot exceed)
- **Scale:** -4 | -2 | 0 | +2 | +4 per round:
  - In the zone (±0.2 mg/L): **+4 points**
  - Close to optimal (±0.4 mg/L): **+2 points**
  - Neutral: **0 points**
  - Too low (>0.4 mg/L below optimal): **-2 points** ("Policía de la Diversión 🚔")
  - Over the line (>0.4 mg/L above optimal): **-4 points** → issues a **Fine** 🚗
- **No impoundment** — players are never excluded from rounds
- **Fine:** shown as `assets/fine.png` full-screen; tracks money lost for a separate next-day game

### Round System
- **Round 0 (Baseline):** Initial measurement, NO feedback, NO points, NO titles
- **Round 1+:** Full feedback after each measurement (points, titles, warnings)

### BAC Calculation
Uses the **Widmark formula** with sex and body size:
- `BAC = (Alcohol in grams / (Body weight × r)) × 100`
- `r = 0.68` for men, `0.55` for women
- Body sizes: S (55kg), M (70kg), L (90kg)

### DGT Titles (Per-Round Awards — Visual/Cosmetic Only)
Awarded **every checkpoint** based on player behavior. Titles are cosmetic — they accumulate on the license card but don't determine winners:
- 🟢 **Velocidad de Crucero** - Closest to their optimal zone this round
- 🔴 **Multa por Exceso** - Highest BAC spike from last round
- 🔰 **L de Prácticas** - Lowest BAC reading in the round
- 🔋 **Vehículo Híbrido** - [TBD — replacement title pending team decision]
- 🔧 **ITV Passed** - Lost points last round but back in zone ("Redemption")

Players accumulate these titles throughout the night (tracked with counters on the license).

### Environmental Distinctive Badges
At the end of the night, the **top 5 highest BAC players** receive satirical environmental badges (like DGT eco labels) — **as a joke, because they are the least eco-friendly** 🏭💨.

### Winners & Leaderboard
The **Leaderboard is the only source of truth**. The top 3 players (🥇🥈🥉) are the winners:
1. **Primary:** Most points at game end
2. **Tiebreaker:** Perfection score — who stayed closest to their optimal zone line throughout the game (lower deviation = better)

### Quick Example
```
Player: Medium (M), Optimal: 2.0 mg/L
Round 0: Reading 0.8 mg/L → "Reading recorded" (no feedback)
Round 1: Reading 2.0 mg/L → "+4 points: ¡En la zona!" (green screen)
Round 2: Reading 2.8 mg/L → "-4 points: ¡Te has pasado! + Fine 🚗" (red screen)
Round 3: Reading 1.0 mg/L → "-2 points: Policía de la Diversión 🚔" (blue screen)
```

---

## 🤝 Contributing

This project uses:
- **Git workflow:** `main` (production), `develop` (integration), `feature/*`, `fix/*`
- **Commit convention:** `type(scope): description` (e.g., `feat(breathalyzer): add OCR camera`)
- **Automated checks:** Pre-commit hooks format and analyze code
- **CI/CD:** GitHub Actions run tests and build on every PR

**See [CONTRIBUTING.md](CONTRIBUTING.md) for complete guidelines.**

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| **[AI_INSTRUCTIONS.md](AI_INSTRUCTIONS.md)** | Complete project specification |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | Contribution guidelines |
| **[ROADMAP.md](ROADMAP.md)** | Development plan and milestones |
| **[CHANGELOG.md](CHANGELOG.md)** | Version history |
| **[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)** | Setup, workflow, coding standards |
| **[docs/AUTOMATION.md](docs/AUTOMATION.md)** | CI/CD, GitHub Actions, git hooks |

---

## 🚨 Important Notes

### Safety First
This app gamifies **responsible drinking**, not excessive consumption. The goal is to encourage pacing and moderation through game mechanics.

### Drunk-Proof UX
Every UI element is designed for users with impaired motor skills and vision:
- Massive buttons (80×80 minimum)
- High-contrast colors
- Custom keypads (no tiny native keyboards)
- Minimal navigation
- Audio + visual feedback

### Testing on Physical Devices
Drunk-proof UX **cannot be validated in simulators**. Always test on real devices with actual users.

---

## 📄 License

[Add your license here]

---

## 👥 Contributors

- Developer A: [Javier] — Core infrastructure, architecture, Firebase
- Developer B: [Kristian] — UI/UX, screens, animations
- Developer C: [Josema] — Firebase backend & Web frontend (Phase 4)

---

**Built with Flutter 💙 | Powered by Riverpod ⚡ | Gamifying Responsible Drinking 🚔**

---

## 🚀 Quick Reference

### Common Commands

```bash
# Setup
flutter pub get                       # Install dependencies
lefthook install                      # Install git hooks
dart run build_runner build -d        # Generate code

# Development
dart run build_runner watch -d        # Watch mode for code generation
dart format .                         # Format code
flutter analyze                       # Static analysis
flutter test                          # Run tests
flutter test --coverage               # Run tests with coverage

# Running
flutter run                           # Run in debug mode
flutter run --release                 # Run in release mode

# Building
flutter build apk --debug             # Build debug APK
flutter build apk --release           # Build release APK
flutter build appbundle --release     # Build release bundle
```

### Troubleshooting

| Problem | Solution |
|---------|----------|
| Lefthook not running | `lefthook install` |
| CI failing on format | `dart format . && git add . && git commit --amend --no-edit` |
| Build runner errors | `flutter clean && flutter pub get && dart run build_runner build -d` |
| Merge conflicts | `git checkout develop && git pull && git checkout your-branch && git merge develop` |

**For detailed guides, see:**
- [Development Guide](docs/DEVELOPMENT.md) - Setup, workflow, standards
- [Automation Guide](docs/AUTOMATION.md) - CI/CD, hooks, releases
- [Contributing Guide](CONTRIBUTING.md) - How to contribute
