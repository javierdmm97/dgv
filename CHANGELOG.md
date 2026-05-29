# Changelog

All notable changes to the Operación DGV project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added — Phase 3 Wave 0–1 (May 26–28, 2026)

**Data Model & Repository Foundations**
- `licenseBackImagePath` field (`@HiveField(13) String?`) added to `PlayerProfile` Freezed model
- `CurveSettingsRepository` abstract interface + `HiveCurveSettingsRepository` implementation in `lib/data/repositories/curve_settings_repository.dart`
- `curveSettingsRepositoryProvider` and `curveMultiplierProvider` added to `lib/core/providers/repository_providers.dart`
- `assets/sound/` registered as Flutter asset directory in `pubspec.yaml`

**Business Logic Updates**
- `BACCalculator.calculateOptimalBrAC()` now accepts `{double curveMultiplier = 1.0}` parameter and applies it to the raw target
- Call sites in `checkpointNotifierProvider` and `bacEntryProvider` updated to read `curveMultiplierProvider` and pass the value down
- `TitleEvaluator._findClosestToOptimal()` updated with alphabetical name tiebreaker for `velocidadDeCrucero`
- `TitleEvaluator._awardMultaPorExceso()` rewritten to award all tied players sharing the maximum spike; not awarded in round 1
- Unit tests added for all business logic changes

**Siren Audio Fix**
- `AudioPlayer` wired in `SirenAlertOverlay.initState()` with try/catch silent degradation
- `_audioPlayer` stopped and disposed in `dispose()`

**License Back-Side Generation**
- `LicenseGenerator.generateBack(PlayerProfile player)` added — renders back-side PNG with round-by-round BrAC table, fine log, total money lost, and perfection score onto `assets/license/back.png` template
- `LicenseUpdateService.updateForPlayer()` updated to call both `generate()` and `generateBack()` and persist both paths

### Added — Phase 3 Wave 2–4 (May 29, 2026)

**OCR Camera Integration ("El Radar")**
- `OcrService` abstract interface + `OcrCandidate` model in `lib/features/breathalyzer/data/ocr_service.dart`
- `MlKitOcrService` implementation using `google_mlkit_text_recognition` — filters text with `\d\.\d{2}` regex, derives confidence from ML Kit block scores
- `CameraOcrScreen` with live `CameraController` preview, frame capture every 500 ms, 10-second timeout fallback, bounding box `CustomPaint` overlay, and "Entrada manual" `MassiveButton`
- Auto-confirms on confidence > 0.90; shows "Confirmar"/"Reintentar" on confidence ≤ 0.90
- Graceful fallback to `ManualEntryScreen` on camera unavailable or permission denied

**Keypad Confirmation Step**
- `BacConfirmationScreen` with player name (24sp bold), entered value (48sp bold), "Confirmar" and "Corregir" `MassiveButton` actions (minHeight 80)
- No Hive writes until "Confirmar" is tapped; "Corregir" returns to keypad with pre-populated value
- Wired into `ManualEntryScreen` (replaces direct save) and `CameraOcrScreen` (low-confidence path)

**Graph Zone Visualization**
- `buildZoneBands(double optimal, int roundNumber)` helper producing 5 colored zone bands
- Round-aware thresholds: wider sweet-spot (0.20) for rounds 1–2, standard (0.10) for rounds 3+
- Rendered as `HorizontalRangeAnnotation` entries in `fl_chart` `LineChartData` with fill opacity ≤ 0.15
- Single-reading edge case handled (`minX = 0`, `maxX = 2`)

**Last Measurement Display**
- `LastMeasurementWidget` displaying `Último registro: 0.XX mg/L — Ronda N` (font ≥ 16sp)
- Returns `SizedBox.shrink()` when player has no readings; updates reactively via Riverpod
- Placed inside `LicenseCard` on `LeaderboardScreen`

**DGT Title Badges on Leaderboard**
- `TitleBadge` widgets with `×N` accumulation counters now visible on each player card in `LeaderboardScreen`
- Only badges with count > 0 are shown

**Two-Sided License Viewer**
- `LicenseViewerScreen` — full-screen swipeable `PageView` with front and back sides
- Each page wrapped in `InteractiveViewer` (minScale: 1.0, maxScale: 4.0) for pinch-to-zoom
- Page 2 falls back to `_DynamicBackWidget` (built from `PlayerProfile.readings`) when `licenseBackImagePath` is null
- Two-dot page indicator showing current side
- Wired from `LeaderboardScreen` player card tap

**Game State Recovery**
- `RecoveryNotifier` Riverpod provider reads `GameStateRepository` on app launch
- Routes to checkpoint screen, leaderboard, or main menu based on saved `GameState`
- Restores checkpoint timer elapsed time via `checkpointNotifierProvider.notifier.restoreFromState()`
- Wired into `app.dart` first-build routing

### Changed
- **README.md** — Phase 3 feature list updated: waves 0–4 items moved from "Planned" to "Implemented"; wave 5 remaining items listed separately
- **ROADMAP.md** — Phase 3 progress updated to ~80%; feature completion table updated; key changes note added

### Changed — Game Mechanics & Flow Redesign (May 4, 2026)

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
- Phase 1 completion spec with requirements document ready for implementation
  - 17 detailed requirements covering checkpoint providers, unit tests, UI screens, and reusable widgets
  - Checkpoint provider with per-group timer management and Hive persistence
  - Comprehensive unit tests for BAC Calculator, Points Calculator, Title Evaluator, and Checkpoint Calculator (90% coverage target)
  - Unit tests for all repositories (85% coverage target)
  - Main Menu screen (persistent home with game state detection)
  - Fake News and Fake Error screens (satirical DGT theme)
  - Reusable widgets: Massive Button, Custom Keypad, Title Badge, License Card (drunk-proof design)
  - Integration tests for checkpoint providers with Hive persistence
  - JSON serialization requirements for CheckpointState and GameState
  - Spec location: `.kiro/specs/phase-1-completion/`

### Changed
- **Documentation Refactoring**: Comprehensive restructuring to eliminate duplication and establish clear information hierarchy
  - Eliminated all content duplication between CONTRIBUTING.md, docs/DEVELOPMENT.md, and docs/AUTOMATION.md
  - Established single sources of truth: DEVELOPMENT.md for setup/workflow/standards, AUTOMATION.md for CI/CD/hooks/releases
  - Transformed CONTRIBUTING.md into high-level entry point with navigation links to detailed documentation
  - Added Quick Reference section to README.md with common commands and troubleshooting cheat sheet
  - Created clear cross-file navigation with hyperlinks between related topics
  - Preserved all existing documentation content while reorganizing for clarity
- Consolidated documentation structure to eliminate duplication
- Streamlined README.md with essential information
- Removed redundant docs: ARCHITECTURE.md, HUMAN_SUMMARY.md, INDEX.md
- Improved documentation navigation and clarity
- APK builds in CI now only run when explicitly requested via PR checkbox

### Added
- `CheckpointNotifier` provider with per-group timer management, absolute-timestamp timers, Hive persistence, and restart recovery
- Main menu screens: `MainMenuScreen`, `FakeNewsScreen`, `FakeNewsDetailScreen`, `FakeErrorScreen`
- Main menu sub-widgets: `FakeErrorNotification`, `FakeNewsSection`
- `MainMenuNotifier` provider with `dismissFakeError` support
- Reusable widgets: `MassiveButton`, `CustomKeypad`, `TitleBadge`, `LicenseCard`
- `FakeNewsArticle` model and 5 static satirical articles in `dgt_strings.dart`
- Unit tests for `BACCalculator`, `PointsCalculator`, `TitleEvaluator`, `CheckpointCalculator` (property-based, 200 iterations each)
- Unit tests for `PlayerRepository`, `GameStateRepository`, `CheckpointRepository` with `FakeBox` test double
- Integration tests for `CheckpointProvider` + Hive (6 scenarios)
- Widget tests for `TitleBadge`




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
