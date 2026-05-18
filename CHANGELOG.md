# Changelog

All notable changes to the Operación DGV project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

---

## [0.3.0] - 2026-05-14

### 🎉 Phase 2 Completion - Core Gameplay

This release delivers the full playable game loop: player selection → Round 0 baseline → BAC entry → real-time feedback → checkpoint timers with siren alerts → leaderboard with BAC progression graphs and fake license generation.

### Added

#### App Routing & Wiring
- **Route constants** (`lib/core/constants/route_constants.dart`) — central `AppRoutes` class for all named routes
- **App wiring** (`lib/app.dart`) — `onGenerateRoute` switch wiring all screens; `MainMenuScreen` as home

#### Player Registration Feature
- **RegistrationNotifier** (`lib/features/player_registration/providers/registration_provider.dart`) — multi-step form state with `RegistrationFormState` (Freezed); auto-generates `optimalBAC` from body size on submit; triggers async license generation
- **PlayerRegistrationScreen** (`lib/features/player_registration/presentation/player_registration_screen.dart`) — 5-page `PageView` flow: name → surname → sex → body size → photo; auto-advances on selection pages; displays optimal BAC zone on photo page
- **PlayerSelectionScreen** (`lib/features/player_registration/presentation/player_selection_screen.dart`) — `LicenseCard` + `Checkbox` list; `SegmentedButton` interval selector (30/45/60 min); enables start only when ≥1 player selected

#### BAC Entry System
- **BACEntryResult / RoundRobinArgs** (`lib/features/breathalyzer/providers/bac_entry_result.dart`) — plain Dart route-argument value objects
- **BACEntryNotifier** (`lib/features/breathalyzer/providers/bac_entry_provider.dart`) — `submitBAC` orchestrates Widmark → points calculation → impoundment check → checkpoint recording; Round 0 saves baseline silently
- **ManualEntryScreen** (`lib/features/breathalyzer/presentation/manual_entry_screen.dart`) — `CustomKeypad(maxDigits: 3)` for X.XX mg/L entry; player photo/initials avatar; submits via `BACEntryNotifier`
- **RoundRobinScreen** (`lib/features/breathalyzer/presentation/round_robin_screen.dart`) — sequential player carousel; Round 0 advances silently; Round 1+ pushes `FeedbackScreen`; on completion calls `CheckpointNotifier.completeGroupMeasurement` or `GameStateNotifier.advanceRound`
- **FeedbackScreen** (`lib/features/breathalyzer/presentation/feedback_screen.dart`) — full-screen color-coded result (green/yellow/red/dark); points delta in `displayLarge`; impoundment banner; awarded DGT title display; auto-dismiss after `AppConstants.feedbackDuration`; triggers `SirenAlertOverlay` on impoundment

#### Checkpoint UI
- **SirenAlertOverlay** (`lib/features/checkpoint/presentation/siren_alert_overlay.dart`) — `AnimationController` red/blue flash at 250ms for `AppConstants.sirenDuration`; audio via `audioplayers` in try/catch (degrades silently)
- **GroupCountdownCard** (`lib/features/checkpoint/presentation/group_countdown_card.dart`) — renders per-group "Grupo N: MM:SS" countdown from `GroupCheckpoint.formattedTimeRemaining`; highlights active groups
- **CheckpointScreen** (`lib/features/checkpoint/presentation/checkpoint_screen.dart`) — `ref.listen` detects `isCheckpointActive` transition to trigger `SirenAlertOverlay`; countdown body with `GroupCountdownCard` list; active checkpoint body with group banner + "Ir al Retén" button

#### Leaderboard & Player Detail
- **sortedLeaderboardProvider** (`lib/features/leaderboard/providers/leaderboard_provider.dart`) — `FutureProvider` watching `playerListProvider`; returns `List.unmodifiable` sorted descending by points
- **LeaderboardScreen** (`lib/features/leaderboard/presentation/leaderboard_screen.dart`) — `RefreshIndicator` + `ListView`; gold/silver/bronze medal badges for top 3; `LicenseCard` per player; tap → player detail
- **PlayerDetailScreen** (`lib/features/leaderboard/presentation/player_detail_screen.dart`) — player header with photo, points, impounded badge; earned DGT title chips; `fl_chart` `LineChart` with optimal zone band (green shading), color-coded dots per zone; empty state for no readings

#### License Generation
- **LicenseGenerator** (`lib/features/fake_id/services/license_generator.dart`) — `dart:ui` `PictureRecorder` + `Canvas` pipeline: loads `assets/carnet-de-conducir.png` template, circle-clips player photo (or draws initials avatar), overlays name/points/BAC/title emoji text, exports PNG to app documents directory
- **LicenseUpdateService** (`lib/features/fake_id/services/license_update_service.dart`) — thin wrapper calling `LicenseGenerator.generate` then `PlayerRepository.update` with new license path

#### Round Completion
- **RoundCompletionService** (`lib/features/breathalyzer/providers/round_completion_service.dart`) — evaluates per-round DGT titles via `TitleEvaluator`, increments player `titleCounts`, persists updates, triggers license regeneration; wired into `CheckpointNotifier._completeCheckpoint`

### Changed

#### Bug Fixes & Improvements
- **CustomKeypad** (`lib/widgets/custom_keypad.dart`) — added `maxDigits` parameter (default `2` for backward compat, `3` for BAC entry); buffer `[a,b,c]` displays as `a.bc`; updated `_onDigit`, `_displayValue`, `_parseInitialValue`, `_onConfirm`
- **BACCalculator doc comment** (`lib/core/utils/bac_calculator.dart`) — fixed `±0.02` → `±0.2` in tolerance comments
- **CheckpointNotifier** (`lib/core/providers/checkpoint_providers.dart`) — `_completeCheckpoint` now calls `RoundCompletionService.evaluateAndApply` and `GameStateNotifier.advanceRound`
- **leaderboard_provider** — returns `List.unmodifiable` to prevent caller mutation
- **CheckpointScreen AppBar** — shows "Control Sorpresa" (no round) when no game is active; "Control Sorpresa — Ronda N" only when a game is in progress

#### Layout Fix
- **ManualEntryScreen** — wrapped body in `SingleChildScrollView` to prevent column overflow on smaller viewport heights; replaced `Spacer` with fixed `SizedBox(height: 32)` gap

### Testing

#### New Unit Tests
- **BAC calculator edge cases** (`test/unit/core/utils/bac_calculator_edge_cases_test.dart`) — body size ordering, Widmark formula proportionality, male vs female constants, rate calculation, extreme values, boundary conditions
- **Points calculator edge cases** (`test/unit/core/utils/points_calculator_edge_cases_test.dart`) — average distance, clamping, spike priority
- **BACEntryNotifier** (`test/unit/features/breathalyzer/bac_entry_provider_test.dart`) — Round 0 baseline (no points, no checkpoint call), Round 1 optimal zone (+2), impoundment override (−5), checkpoint recording
- **sortedLeaderboardProvider** (`test/unit/features/leaderboard/leaderboard_provider_test.dart`) — sort order, empty list, single player, equal-points stability, unmodifiable result

#### New Widget Tests
- **ManualEntryScreen** (`test/widget/features/breathalyzer/manual_entry_screen_test.dart`) — AppBar title, player name, optimal BAC hint, initials avatar, `CustomKeypad(maxDigits: 3)`, background color
- **FeedbackScreen** (`test/widget/features/breathalyzer/feedback_screen_test.dart`) — player name, points delta sign, impoundment banner, background color, Continuar button navigation
- **LeaderboardScreen** (`test/widget/features/leaderboard/leaderboard_screen_test.dart`) — AppBar title, empty state, loading indicator, `LicenseCard` count, medal emoji placement (top 3 only)
- **CheckpointScreen** (`test/widget/features/checkpoint/checkpoint_screen_test.dart`) — AppBar title states, no-game body, countdown body, active checkpoint banner, round number display, loading indicator

### Quality
- `flutter analyze` — 0 issues
- `flutter test` — 225/225 tests passing
- All lint rules resolved (`unnecessary_underscores`, `prefer_const_constructors`, `deprecated_member_use`)

---

## [0.2.0] - 2026-05-14

### 🎉 Phase 1 Completion - UI, Providers, and Test Suite

This release completes Phase 1 of the project with comprehensive UI screens, state management providers, reusable widgets, and extensive test coverage.

### Added

#### Core Providers & State Management
- **Checkpoint Providers** (`lib/core/providers/checkpoint_providers.dart`)
  - Per-group checkpoint timer management with independent intervals
  - Configurable checkpoint intervals (30, 45, 60 minutes)
  - Group division logic (3-8 players per group)
  - Hive persistence for timer state and crash recovery
  - Stream-based reactive updates for UI
  - Beer consumption estimation per group
  - Generated code with Riverpod annotations

#### UI Screens - Main Menu Feature
- **Main Menu Screen** (`lib/features/main_menu/presentation/main_menu_screen.dart`)
  - Persistent home screen that serves as central navigation hub
  - Game state detection (Start Game vs Resume Game buttons)
  - Navigation to Add Player, Fake News, and Fake Error screens
  - DGT-themed UI with oversized touch targets (60+ height)
  - Responsive layout with proper spacing
- **Fake News Screen** (`lib/features/main_menu/presentation/fake_news_screen.dart`)
  - Satirical DGT news articles with authentic styling
  - Scrollable list of fake news items
  - Tap to view full article details
  - DGT color palette integration
- **Fake News Detail Screen** (`lib/features/main_menu/presentation/fake_news_detail_screen.dart`)
  - Full article view with image, headline, and body text
  - Back navigation to news list
  - Proper text formatting and spacing
- **Fake Error Screen** (`lib/features/main_menu/presentation/fake_error_screen.dart`)
  - Humorous fake error message screen
  - Displays mock system error with DGT branding
  - Return to menu functionality
  - Used for impoundment penalties and random ceremony jokes

#### UI Widgets - Main Menu Components
- **Fake Error Notification** (`lib/features/main_menu/presentation/widgets/fake_error_notification.dart`)
  - Reusable error notification widget
  - DGT-styled error display
  - Configurable message and icon
- **Fake News Section** (`lib/features/main_menu/presentation/widgets/fake_news_section.dart`)
  - News item card component
  - Thumbnail image support
  - Headline and summary display
  - Tap interaction handling

#### Reusable Widgets
- **Massive Button** (`lib/widgets/massive_button.dart`)
  - Oversized button widget for drunk-proof UX
  - Minimum height of 60+ pixels
  - High contrast colors from DGT palette
  - Haptic feedback on tap
  - Loading state support
  - Customizable colors, text, and icons
- **Custom Keypad** (`lib/widgets/custom_keypad.dart`)
  - Drunk-proof numerical input widget
  - Large touch targets (80x80 minimum)
  - Supports decimal input for BAC entry
  - Backspace and clear functionality
  - Haptic feedback on key press
  - Customizable max length and decimal places
  - Value change callback
- **Title Badge** (`lib/widgets/title_badge.dart`)
  - DGT title display widget with counter
  - Shows title emoji and count (e.g., 🟢×3)
  - Compact and large size variants
  - Proper spacing and alignment
  - Used in leaderboard and license cards
- **License Card** (`lib/widgets/license_card.dart`)
  - Player license display widget
  - Shows photo, name, surname, points, optimal BAC
  - Displays title badges in grid layout
  - Tap to view full-screen license
  - DGT-themed styling with license ID background color
  - Supports impoundment badge overlay

#### Constants & Strings
- **DGT Strings** (`lib/core/constants/dgt_strings.dart`)
  - Centralized string constants for UI text
  - Main menu labels and buttons
  - Fake news headlines and articles
  - Error messages and notifications
  - Title names and descriptions
  - Consistent Spanish DGT terminology

#### State Management - Main Menu
- **Main Menu Provider** (`lib/features/main_menu/providers/main_menu_provider.dart`)
  - Game state detection (in progress vs not started)
  - Navigation state management
  - Fake news data provider
  - Generated Freezed models and Riverpod code

#### Comprehensive Test Suite

**Unit Tests (90%+ coverage target):**
- **BAC Calculator Tests** (`test/unit/core/utils/bac_calculator_test.dart`)
  - 348 lines of comprehensive tests
  - Optimal zone calculations for all body sizes
  - Zone checking methods (in zone, close, crossed line)
  - Edge cases and boundary conditions
  - Widmark formula validation
- **Points Calculator Tests** (`test/unit/core/utils/points_calculator_test.dart`)
  - 347 lines of test coverage
  - Hybrid points system validation (+2 in zone, +1 close, -3 crossed, -2 spike, -5 impounded)
  - Feedback message generation tests
  - Average distance calculations
  - All reward and penalty scenarios
- **Title Evaluator Tests** (`test/unit/core/utils/title_evaluator_test.dart`)
  - 392 lines of comprehensive tests
  - Per-round title awards (5 titles)
  - Grand prize calculations (3 prizes)
  - Environmental distinctive selection (top 5)
  - Edge cases (ties, no eligible players)
- **Checkpoint Calculator Tests** (`test/unit/core/utils/checkpoint_calculator_test.dart`)
  - 348 lines of test coverage
  - Per-group timer calculations
  - Independent checkpoint times for each group
  - Configurable intervals (30, 45, 60 minutes)
  - Group division logic validation
  - Beer consumption estimation

**Repository Tests (85%+ coverage target):**
- **Player Repository Tests** (`test/unit/data/repositories/player_repository_test.dart`)
  - 248 lines of tests
  - CRUD operations validation
  - Stream-based updates testing
  - Hive persistence verification
  - Mock Hive box implementation
- **Game State Repository Tests** (`test/unit/data/repositories/game_state_repository_test.dart`)
  - 211 lines of tests
  - Game state persistence
  - Round tracking
  - Timer state management
  - Crash recovery scenarios
- **Checkpoint Repository Tests** (`test/unit/data/repositories/checkpoint_repository_test.dart`)
  - 263 lines of tests
  - Per-group checkpoint state persistence
  - Timer state save/load
  - Group management operations
  - Stream updates validation
- **Fake Box Helper** (`test/unit/data/repositories/fake_box.dart`)
  - 168 lines of mock Hive box implementation
  - Reusable test utility for all repository tests
  - In-memory storage for fast tests
  - Full Hive Box API implementation

**Integration Tests:**
- **Checkpoint Provider Integration Tests** (`test/integration/checkpoint_provider_test.dart`)
  - 384 lines of comprehensive integration tests
  - End-to-end provider functionality
  - Hive persistence integration
  - Timer state management across app restarts
  - Group checkpoint coordination
  - Real-world usage scenarios

**Widget Tests:**
- **Title Badge Widget Tests** (`test/widget/widgets/title_badge_test.dart`)
  - 202 lines of widget tests
  - Rendering validation for both sizes
  - Counter display verification
  - Layout and spacing tests
  - Accessibility checks

### Changed

#### Documentation Updates
- **README.md Updates**
  - Updated Phase 1 progress to 100% complete
  - Added new UI screens to feature list
  - Updated test coverage statistics
  - Added widget documentation
  - Improved setup instructions
- **ROADMAP.md Updates**
  - Marked Phase 1 as ✅ 100% Complete
  - Updated feature completion table
  - Moved completed tasks from "Planned" to "Complete"
  - Updated progress tracking section
  - Added Phase 2 preparation notes

#### Technical Improvements
- Generated Riverpod provider code for checkpoint management
- Generated Freezed models for main menu state
- Added JSON serialization for CheckpointState
- Improved code organization with feature-first structure
- Enhanced error handling in providers
- Added comprehensive inline documentation

### Testing & Quality
- **Total Test Files:** 11 new test files
- **Total Test Lines:** 3,500+ lines of test code
- **Coverage Targets:**
  - Unit tests: 90%+ coverage achieved
  - Repository tests: 85%+ coverage achieved
  - Widget tests: Core widgets covered
  - Integration tests: Critical flows validated
- **Test Quality:**
  - Edge cases and boundary conditions covered
  - Real-world scenarios validated
  - Mock implementations for fast execution
  - Comprehensive assertions and expectations

### Developer Experience
- Reusable widgets reduce code duplication
- Centralized string constants improve maintainability
- Comprehensive tests enable confident refactoring
- Clear provider structure simplifies state management
- Feature-first organization improves navigation

### 🎯 What's Next (Phase 2)
- Player registration flow implementation
- Manual BAC entry screen with custom keypad integration
- Round 0 baseline measurement flow
- Real-time feedback system for Round 1+
- Leaderboard screen with BAC progression
- License viewing and update system

---

## [0.1.0] - 2026-05-04

### 🎉 Initial Setup & Foundation

### Changed
- **README.md & AI_INSTRUCTIONS.md Game Mechanics Update:** Updated documentation to reflect breathalyzer readings in mg/L instead of BAC percentages
  - Changed optimal zones: Small 2.5 mg/L, Medium 2.0 mg/L, Large 1.8 mg/L (was 0.05, 0.07, 0.09 BAC)
  - Updated tolerance zones: ±0.2 mg/L (in zone), ±0.4 mg/L (close) - was ±0.02 BAC
  - Updated thresholds: Spike rate >0.8 mg/L/hr, Impoundment ≥3.5 mg/L (was >0.15/hr, ≥1.2 BAC)
  - README.md: Added Measurement System section explaining mg/L vs BAC percentages
  - README.md: Updated Quick Example with mg/L readings
  - README.md: Removed duplicate sections (BAC Calculation, DGT Titles, Grand Prizes)
  - AI_INSTRUCTIONS.md: Updated BACCalculator, PointsCalculator, and TitleEvaluator code examples
  - AI_INSTRUCTIONS.md: Updated leaderboard card layout example and impoundment threshold
  - Documentation now matches app_constants.dart implementation
- Improved setup script to source bashrc for Flutter PATH detection in non-interactive shells
- Switched from incompatible lefthook Dart package to native lefthook binary
- Added comprehensive lefthook installation guide to README
- Fixed labeler.yml format for actions/labeler@v5 compatibility
- Added required write permissions to GitHub Actions workflows

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
- Updated asset paths and images for v2 (#)
```

When releasing a version:

1. Move `[Unreleased]` changes to a new version section
2. Add the release date
3. Create a git tag: `git tag -a v1.0.0 -m "Release v1.0.0"`
4. Push the tag: `git push origin v1.0.0`
5. GitHub Actions will automatically create a release

---

[Unreleased]: https://github.com/javierdmm97/dgv/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/javierdmm97/dgv/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/javierdmm97/dgv/releases/tag/v0.1.0
