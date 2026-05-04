# 🚔 Operación DGV (Dirección General de Vitis)

**Party Breathalyzer Tracker with DGT Theme**

A Flutter mobile app that gamifies responsible drinking at parties through a satirical Spanish traffic authority (DGT) theme. Players compete to maintain the most "license points" by pacing their alcohol consumption, not by drinking the most.

> 📚 **Documentation:** [CONTRIBUTING.md](CONTRIBUTING.md) | [Development Guide](docs/DEVELOPMENT.md) | [Automation Guide](docs/AUTOMATION.md) | [Roadmap](ROADMAP.md)

---

## 🎯 Quick Start

### Prerequisites
- Flutter 3.10+ and Dart 3.0+
- Git
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

1. **Player Registration** - Avatar selection, sex/body size input, photo capture
2. **Breathalyzer Data Entry** - Manual keypad, OCR camera, round-robin lineup
3. **Checkpoint System** - Timed rounds with police siren alerts
4. **Points System** - BAC-based scoring with penalties for "speeding"
5. **Leaderboard** - Real-time rankings with BAC progression graphs
6. **DGT Titles** - Awards like "Velocidad de Crucero" and "Multa por Exceso"
7. **Fake DGT License** - Generated ID cards with player photos and achievements
8. **Final Ceremony** - "Mario Party" style reveal with envelope animations

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
- **Primary:** `#003DA5` (DGT Blue)
- **Warning:** `#FFC107` (Traffic Yellow)
- **Danger:** `#D32F2F` (Violation Red)
- **Success:** `#388E3C` (Safe Green)

### UI/UX Principles
- **Oversized touch targets** (minHeight: 80)
- **No native keyboards** for numerical input
- **High contrast** for impaired vision
- **Minimal navigation** to reduce cognitive load
- **Instant feedback** with audio + visual cues

---

## 🧮 Game Mechanics

### Points System
- Everyone starts with **15 points**
- Points are deducted based on BAC increase rate:
  - Safe pace (0.00-0.02/hr): 0 points
  - Moderate (0.02-0.05/hr): -1 point
  - Fast (0.05-0.10/hr): -3 points
  - Dangerous (>0.10/hr): -5 points

### BAC Calculation
Uses the **Widmark formula** with sex and body size:
- `BAC = (Alcohol in grams / (Body weight × r)) × 100`
- `r = 0.68` for men, `0.55` for women
- Body sizes: S (55kg), M (70kg), L (90kg)

### DGT Titles
- 🟢 **Velocidad de Crucero** - Most consistent pace
- 🔴 **Multa por Exceso** - Aggressive BAC spike
- 🔰 **La 'L' de Prácticas** - Lowest overall score
- 🔋 **Vehículo Híbrido** - Drank water (BAC dropped)
- 🛠️ **ITV Passed** - Same reading twice in a row

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

- Developer 1: [Your name]
- Developer 2: [Partner's name]

---

**Built with Flutter 💙 | Powered by Riverpod ⚡ | Gamifying Responsible Drinking 🚔**
