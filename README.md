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
├── widgets/                 # Reusable UI components
└── features/                # Feature modules (feature-first architecture)
    ├── player_registration/ # Player creation & setup
    ├── breathalyzer/        # BAC data entry & OCR
    ├── checkpoint/          # Round management & timers
    ├── scoring/             # Points calculation & penalties
    ├── leaderboard/         # "Carnet por Puntos" display
    ├── achievements/        # DGT titles & awards
    └── fake_id/             # DGT License generation
```

---

## 🎮 Core Features

1. **Main Menu** - Persistent home screen with Add Player, Fake News, Fake Error (jokes), Start/Resume Game
2. **Player Registration** - Name + surname, sex/body size, photo capture, auto-generated license ID
3. **Round 0 (Baseline)** - Initial BAC measurement with no feedback (silent baseline)
4. **Breathalyzer Data Entry** - Manual keypad, OCR camera, round-robin lineup
5. **Checkpoint System** - Timed rounds with police siren alerts
6. **"Sweet Spot" System** - Price is Right mechanic: get close to optimal BAC without going over
7. **Points System** - Hybrid scoring: gain points for staying in zone, lose for dangerous behavior
8. **Real-time Feedback** - Messages after each measurement (points, titles, warnings)
9. **Live License Updates** - Licenses auto-update with badges, viewable anytime by clicking player
10. **Leaderboard** - Real-time rankings with BAC progression graphs
11. **DGT Titles** - Per-round awards with logos (Velocidad de Crucero, Multa por Exceso, etc.)
12. **Environmental Badges** - Top 5 highest BAC players get eco-style distinctive badges (as a joke)
13. **Final Ceremony** - 3 Grand Prizes + Environmental Distinctives reveal with animations
14. **Persistent State** - All data saved continuously, resume game after crash/restart

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
Each player has a personalized **optimal breathalyzer reading zone** based on body size:
- **Small (S):** 2.5 mg/L optimal (equivalent to ~6-7 beers sustained)
- **Medium (M):** 2.0 mg/L optimal (equivalent to ~7-8 beers sustained)
- **Large (L):** 1.8 mg/L optimal (equivalent to ~8-9 beers sustained)
- **Tolerance zones:**
  - **In the zone:** ±0.2 mg/L (the "sweet spot")
  - **Close to optimal:** ±0.4 mg/L

### Points System (Hybrid)
- Everyone starts with **15 points**
- **Gain points** for staying in your zone:
  - In the zone (±0.2 mg/L): +2 points
  - Close to optimal (±0.4 mg/L): +1 point
- **Lose points** for dangerous behavior:
  - Over the line (beyond +0.4 mg/L): -3 points + lose Grand Prize eligibility
  - Spike too fast (>0.8 mg/L per hour): -2 points
  - Impoundment (≥3.5 mg/L): -5 points + sit out next round

### Round System
- **Round 0 (Baseline):** Initial measurement, NO feedback, NO points, NO titles
- **Round 1+:** Full feedback after each measurement (points, titles, warnings)

### BAC Calculation
Uses the **Widmark formula** with sex and body size:
- `BAC = (Alcohol in grams / (Body weight × r)) × 100`
- `r = 0.68` for men, `0.55` for women
- Body sizes: S (55kg), M (70kg), L (90kg)

### DGT Titles (Per-Round Awards)
Awarded **every checkpoint** based on player behavior:
- 🟢 **Velocidad de Crucero** - Closest to their optimal zone
- 🔴 **Multa por Exceso** - Highest reading spike from last round
- 🔰 **L de Prácticas** - Lowest reading in the round
- 🔋 **Vehículo Híbrido** - Reading dropped (drank water)
- 🛠️ **ITV Passed** - Same reading twice in a row (±0.01 mg/L)

Players accumulate these titles throughout the night (tracked with counters).

### Environmental Distinctive Badges
At the end of the night, the **top 5 highest BAC players** receive satirical environmental badges (like DGT eco labels) as a joke.

### Grand Prizes (Final Ceremony)
Three separate grand prizes awarded at the end:
1. 🏆 **El Conductor Perfecto** - Highest points + never crossed optimal line
2. 🎯 **Precisión Absoluta** - Closest average to optimal zone across all rounds
3. 👑 **Coleccionista de Títulos** - Most DGT titles accumulated

### Quick Example
```
Player: Medium (M), Optimal: 2.0 mg/L
Round 0: Reading 0.8 mg/L → "Reading recorded" (no feedback)
Round 1: Reading 2.0 mg/L → "+2 points: In the zone!" (green screen)
Round 2: Reading 2.8 mg/L → "-3 points: Over the line!" (red screen)
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

- Developer 1: [Javier]
- Developer 2: [Kristian]

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
