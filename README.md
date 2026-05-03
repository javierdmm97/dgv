# 🚔 Operación DGV (Dirección General de Vitis)

**Party Breathalyzer Tracker with DGT Theme**

> 👋 **First time here?** Start with **[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)** for setup and workflow.
> 
> 📚 **Documentation:** [INDEX](docs/INDEX.md) | [Development](docs/DEVELOPMENT.md) | [Automation](docs/AUTOMATION.md) | [Architecture](docs/ARCHITECTURE.md)

A Flutter mobile app that gamifies responsible drinking at parties through a satirical Spanish traffic authority (DGT) theme. Players compete to maintain the most "license points" by pacing their alcohol consumption, not by drinking the most.

---

## 🎯 Quick Start

### For Developers

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/dgv.git
   cd dgv
   ```

2. **Run the setup script:**
   
   **Linux/macOS:**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```
   
   **Windows (PowerShell):**
   ```powershell
   .\setup.ps1
   ```
   
   Or manually:
   ```bash
   flutter pub get
   flutter pub add --dev lefthook
   lefthook install
   dart run build_runner build -d
   ```

3. **Read the documentation:**
   - [`AI_INSTRUCTIONS.md`](AI_INSTRUCTIONS.md) - Complete project specification
   - [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) - Setup, workflow, and standards
   - [`.claude/skills/`](.claude/skills/) - Flutter/Riverpod best practices
   - [`ROADMAP.md`](ROADMAP.md) - Development plan and progress

4. **Run the app:**
   ```bash
   flutter run
   ```

### For AI Assistants (Claude Web / Cursor)

1. **Read [`AI_INSTRUCTIONS.md`](AI_INSTRUCTIONS.md) first** - Single source of truth for:
   - Project mission and game mechanics
   - Core architecture rules (Riverpod, Hive, Freezed)
   - Feature specifications
   - UI/UX guidelines (drunk-proof design)

2. **Reference [`.claude/skills/`](.claude/skills/) for implementation patterns:**
   - `dart-flutter-patterns/` - Riverpod, null safety, widget architecture
   - `flutter-dart-code-review/` - Code review checklist

3. **Follow the configuration:**
   - Cursor users: See [`.cursorrules`](.cursorrules)
   - Claude Web users: See [`CLAUDE.md`](CLAUDE.md)

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
# Code Generation
dart run build_runner build -d          # One-time build
dart run build_runner watch -d          # Watch mode

# Code Quality
dart format .                           # Format all files
flutter analyze                         # Static analysis
flutter test                            # Run all tests
flutter test --coverage                 # Generate coverage report

# Build
flutter build apk --release             # Android APK
flutter build appbundle --release       # Android App Bundle
```

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

## 🤝 Collaboration

This project is designed for **two developers** working in parallel using AI assistants:

### Git Workflow
- `main` - Production-ready code
- `develop` - Integration branch
- `feature/*` - New features
- `fix/*` - Bug fixes

### Commit Convention
```
<type>(<scope>): <description>

Examples:
feat(breathalyzer): add OCR camera screen
fix(scoring): correct points deduction formula
refactor(ui): extract massive button widget
test(calculator): add BAC calculation tests
```

### Pre-Commit Hooks
Automatically runs on every commit:
- `dart format .` - Format code
- `flutter analyze` - Static analysis
- `flutter test` - Run tests

---

## 📚 Documentation

### Core Documentation
- **[AI_INSTRUCTIONS.md](AI_INSTRUCTIONS.md)** - Complete project specification for AI assistants
- **[ROADMAP.md](ROADMAP.md)** - Development plan and milestones
- **[CHANGELOG.md](CHANGELOG.md)** - Version history
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[CLAUDE.md](CLAUDE.md)** - Claude AI configuration

### In `docs/` folder
- **[INDEX.md](docs/INDEX.md)** - Documentation navigation guide
- **[DEVELOPMENT.md](docs/DEVELOPMENT.md)** - Setup, workflow, coding standards
- **[AUTOMATION.md](docs/AUTOMATION.md)** - CI/CD, GitHub Actions, git hooks
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Project structure and organization
- **[HUMAN_SUMMARY.md](docs/HUMAN_SUMMARY.md)** - Quick setup overview

---

## 🤖 Automation & CI/CD

This project includes comprehensive automation to facilitate collaboration:

### ✅ Automated Checks
- **Pre-commit hooks** - Format and analyze code before committing
- **Commit message validation** - Enforce conventional commit format
- **CI pipeline** - Test, analyze, and build on every PR
- **Changelog checks** - Ensure changelog is updated with every PR

### 🏷️ Auto-labeling
- PRs are automatically labeled based on files changed and branch name
- Makes it easy to filter and organize PRs

### 🚀 Release Automation
- Create a git tag → GitHub Actions automatically:
  - Builds release APK and App Bundle
  - Extracts changelog for the version
  - Creates GitHub release with download links

### 📋 Quick Commands
```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Create release
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

**See [`docs/AUTOMATION.md`](docs/AUTOMATION.md) for complete details.**

---

## 🏁 Project Milestones

### Phase 1: Foundation (Week 1)
- [ ] Project setup (packages, folder structure)
- [ ] Core theme and constants
- [ ] Player registration flow
- [ ] Hive storage implementation

### Phase 2: Core Gameplay (Week 2)
- [ ] Manual BAC entry with custom keypad
- [ ] Points calculation logic
- [ ] Checkpoint timer system
- [ ] Basic leaderboard

### Phase 3: Advanced Features (Week 3)
- [ ] OCR camera integration
- [ ] Round-robin "El Retén" flow
- [ ] Penalty system with audio/visual alerts
- [ ] DGT title evaluation

### Phase 4: Polish (Week 4)
- [ ] Fake license generation
- [ ] Final ceremony animations
- [ ] Comprehensive testing
- [ ] Performance optimization
- [ ] APK distribution via Firebase

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
