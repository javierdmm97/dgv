# Changelog

All notable changes to the Operación DGV project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed - Game Mechanics & Flow Redesign (May 4, 2026)

**Major game mechanics and app flow overhaul:**

#### App Flow & Navigation
- **Main Menu (Persistent Home Screen):** Added central hub that persists throughout app lifecycle
  - Add Player button → navigate to registration
  - Fake News button → satirical DGT news articles (joke feature)
  - Fake Error Message button → fake error screen (joke feature)
  - Start Game button → begin Round 0 (visible if no game in progress)
  - Resume Game button → continue existing game (visible if game in progress)
- **Crash Recovery:** App checks Hive for existing game state on launch and allows resuming
- **Persistent State:** All game data saved continuously (round number, timer state, player data, BAC readings)

#### Player Registration Updates
- **Name + Surname:** Changed from single "name" field to separate name and surname inputs
- **License Auto-Generation:** License created immediately after photo capture (not at end)
  - Uses template image with placeholders
  - Auto-updates throughout game with new badges
  - Viewable anytime by tapping player in leaderboard
- **License Viewing:** Tap player card in leaderboard → full-screen license view with pinch-to-zoom

#### Round System
- **Round 0 (Baseline):** Added initial measurement round with NO feedback
  - Silent baseline measurement for all players
  - No points changes, no title awards, no messages
  - Only shows "Reading recorded for [Player Name]"
  - Saved as `roundNumber: 0` for delta calculations
- **Round 1+ (Active Rounds):** Full feedback after each measurement
  - Full-screen notifications with color-coded backgrounds
  - Points gained/lost displayed
  - DGT titles won shown with animations
  - Warnings and penalties displayed
  - License auto-updated with new badges

#### Core Mechanics
- **"Sweet Spot" System:** Players now have personalized optimal BAC zones based on body size
  - Small (S): 0.05 optimal BAC
  - Medium (M): 0.07 optimal BAC
  - Large (L): 0.09 optimal BAC
  - Tolerance: ±0.02 (the "sweet spot")
- **Hybrid Points System:** Changed from pure penalty system to reward + penalty hybrid
  - Start with 15 points
  - Gain points for staying in zone (+2 in zone, +1 close)
  - Lose points for dangerous behavior (-3 over line, -2 fast spike, -5 impoundment)
- **Grand Prizes:** Replaced single winner with 3 separate grand prizes:
  - 🏆 El Conductor Perfecto (Highest points + never crossed line)
  - 🎯 Precisión Absoluta (Closest average to optimal zone)
  - 👑 Coleccionista de Títulos (Most DGT titles accumulated)

#### DGT Titles System
- **Per-Round Awards:** Titles now awarded every checkpoint (not just at end)
  - 🟢 Velocidad de Crucero (Closest to optimal zone)
  - 🔴 Multa por Exceso (Highest BAC spike)
  - 🔰 L de Prácticas (Lowest BAC in round)
  - 🔋 Vehículo Híbrido (BAC dropped - drank water)
  - 🛠️ ITV Passed (Same reading twice ±0.01)
- Players accumulate title counts throughout the night
- Titles displayed with counters on leaderboard (🟢×3, 🔴×1, etc.)
- Licenses auto-update with new title badges after each round

#### New Features
- **Environmental Distinctive Badges:** Top 5 highest BAC players receive satirical eco-style badges (as a joke)
- **Fake Error Message:** Added humorous error screen (assets/msg_error.png) shown on impoundment or randomly during ceremony
- **Fake News Screen:** Satirical DGT/DGV news articles accessible from main menu
- **Real-time License Updates:** Licenses update automatically after each round with new points and badges
- **Final Report Screen:** Summary statistics and graphs before final ceremony
- **License Export:** Export single or all licenses to gallery

#### UI/UX Updates
- **Color Palette Correction:**
  - Primary: #0F5993 (DGT Blue) - was #003DA5
  - Background: #F6F4F5 (Light Gray) - was #121212 dark
  - License ID: #F3E8EC (Light Pink)
  - Green: #D2D667, Yellow: #F4E944, Orange: #F3910E, Red: #EF6B6A
- **Leaderboard Enhancements:**
  - Show name + surname (not just name)
  - Show optimal BAC zone for each player
  - Display title badge counters
  - Tap player card → view full license
  - Highlight optimal zone as green band on BAC graphs
  - Mark Round 0 as baseline on graphs
- **Final Ceremony Updates:**
  - Final report screen with statistics before ceremony
  - 3 Grand Prize reveals with envelope animations
  - Environmental Distinctive reveal for top 5
  - 10% chance to show fake error message as a joke
  - "Return to Menu" button (clear game state)
  - "View All Licenses" gallery view

#### Technical Changes
- Updated `PlayerProfile` model:
  - Added `surname` field
  - Added `licenseImagePath` for auto-generated license
  - Added `optimalBAC` field (calculated from body size)
  - Added `titleCounts` map for DGT title accumulation
  - Added `crossedOptimalLine` flag for Grand Prize eligibility
- Added `GameState` model:
  - Track current round number
  - Track game in progress flag
  - Track timer state for persistence
- Updated `BACReading` model:
  - Added `roundNumber` field (0 for baseline)
- Enhanced `BACCalculator` with zone checking methods
- Rewrote `PointsCalculator` for hybrid reward/penalty system
- Expanded `TitleEvaluator` for per-round awards and grand prizes
- Added `LicenseGenerator` service for template-based license creation and updates
- Added `GameRecovery` provider for crash recovery

### Added
- Optional APK build toggle in PR template to control CI build behavior

### Changed
- Consolidated documentation structure to eliminate duplication
- Streamlined README.md with essential information
- Removed redundant docs: ARCHITECTURE.md, HUMAN_SUMMARY.md, INDEX.md
- Improved documentation navigation and clarity
- APK builds in CI now only run when explicitly requested via PR checkbox

### 🎯 Planned Features
- Main menu with persistent home screen
- Fake News and Fake Error screens (joke features)
- Player registration flow with name + surname and photo capture
- License auto-generation system with template
- Round 0 baseline measurement (no feedback)
- Manual BAC entry with custom keypad
- OCR camera integration for breathalyzer readings
- Checkpoint timer system with siren alerts and persistence
- Hybrid points calculation (rewards + penalties)
- Real-time feedback system (Round 1+)
- License update system (auto-update after each round)
- Per-round DGT title awards with logos
- Leaderboard with BAC progression graphs and optimal zones
- License viewing (tap player card → full-screen view)
- Environmental Distinctive badges for top 5 highest BAC
- Final report screen with statistics and graphs
- Final ceremony with 3 Grand Prizes + Environmental Distinctives
- Game state recovery (resume after crash)
- License export system (single and batch)

---

## [0.1.0] - 2026-05-04

### 🎉 Initial Setup

#### Added
- Project initialization with Flutter 3.24.0
- Complete project documentation:
  - `AI_INSTRUCTIONS.md` - Comprehensive project specification
  - `README.md` - Quick start guide
  - `DOCUMENTATION_STRUCTURE.md` - Documentation hierarchy
  - `CLAUDE.md` and `.cursorrules` - AI assistant configuration
- Feature-first folder structure definition
- Core architecture rules (Riverpod, Hive, Freezed)
- DGT color palette and typography guidelines
- Game mechanics specifications (BAC calculations, points system)
- CI/CD automation:
  - GitHub Actions for testing and building
  - Automated PR labeling
  - Release automation with changelog extraction
  - Pre-commit hooks configuration
- Git workflow and commit conventions
- Code quality standards (linting, formatting, testing)

#### Documentation
- Defined 7 major features with detailed specifications
- Created AI agent personas for specialized tasks
- Established drunk-proof UI/UX principles
- Documented Widmark formula for BAC calculations
- Outlined 4-phase project milestones

---

## Version Format

### Types of Changes
- **Added** - New features
- **Changed** - Changes in existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Vulnerability fixes

### Version Numbers
- **MAJOR** - Incompatible API changes
- **MINOR** - New functionality (backwards-compatible)
- **PATCH** - Bug fixes (backwards-compatible)

---

## How to Update This Changelog

When working on a feature:

1. Add your changes under `[Unreleased]` section
2. Use the appropriate category (Added, Changed, Fixed, etc.)
3. Write clear, user-focused descriptions
4. Reference PR numbers: `(#123)`

Example:
```markdown
## [Unreleased]

### Added
- Player registration screen with avatar selection (#45)
- Custom keypad widget for BAC entry (#47)

### Fixed
- Points calculation for negative BAC deltas (#52)
```

When releasing a version:

1. Move `[Unreleased]` changes to a new version section
2. Add the release date
3. Create a git tag: `git tag -a v1.0.0 -m "Release v1.0.0"`
4. Push the tag: `git push origin v1.0.0`
5. GitHub Actions will automatically create a release

---

[Unreleased]: https://github.com/yourusername/dgv/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/yourusername/dgv/releases/tag/v0.1.0
