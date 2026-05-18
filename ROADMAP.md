# 🗺️ Operación DGV - Project Roadmap

This roadmap outlines the development plan for Operación DGV. It's a living document that will be updated as the project evolves.

---

## 🎯 Project Vision

Create a fun, safe, and technically excellent party app that gamifies responsible drinking through a satirical Spanish traffic authority (DGT) theme.

---

## 📅 Development Phases

### ✅ Phase 0: Foundation & Setup (Week 0) - COMPLETED

**Goal:** Establish project infrastructure and documentation

- [x] Project initialization with Flutter
- [x] Complete documentation (`AI_INSTRUCTIONS.md`, `README.md`)
- [x] CI/CD automation (GitHub Actions)
- [x] Git workflow and conventions
- [x] Code quality standards
- [x] Changelog and roadmap setup

**Deliverables:**
- ✅ Project repository with complete documentation
- ✅ Automated CI/CD pipeline
- ✅ Development guidelines for both developers

---

### ✅ Phase 1: Foundation (Week 1) - COMPLETED

**Goal:** Set up core architecture and basic infrastructure

#### Tasks

**1.1 Project Setup**
- [x] Configure `pubspec.yaml` with all required dependencies
- [x] Set up Hive for local storage with persistent state management
- [x] Initialize Riverpod providers
- [x] Configure code generation (build_runner)
- [x] Set up lefthook for pre-commit hooks

**1.2 Core Theme & Constants**
- [x] Implement DGT color palette (`lib/core/theme/dgt_colors.dart`)
  - Primary: #0F5993 (DGT Blue)
  - Background: #F6F4F5 (Light Gray)
  - License ID: #F3E8EC (Light Pink)
  - Green: #D2D667, Yellow: #F4E944, Orange: #F3910E, Red: #EF6B6A
- [x] Create typography system (`lib/core/theme/dgt_typography.dart`)
- [x] Build theme configuration (`lib/core/theme/dgt_theme.dart`)
- [x] Define app constants (`lib/core/constants/app_constants.dart`)
  - Breathalyzer readings in mg/L (based on real DGT data)
  - Optimal BAC zones: Small=2.5, Medium=2.0, Large=1.8 mg/L
  - Tolerance: ±0.2 mg/L (in zone), ±0.4 mg/L (close)
  - Impoundment threshold: 3.5 mg/L
  - Dangerous spike: >0.8 mg/L per hour
- [x] Set up asset paths (`lib/core/constants/asset_paths.dart`)
- [x] Create DGT strings (`lib/core/constants/dgt_strings.dart`)
  - Added `FakeNewsArticle` model and 5 static satirical articles

**1.3 Core Models**
- [x] Create `PlayerProfile` model (Freezed + JSON)
- [x] Create `BACReading` model (Freezed + JSON)
- [x] Create `GameState` model (Freezed + JSON)
- [x] Create `CheckpointState` + `GroupCheckpoint` models (Freezed + JSON)
  - Per-group checkpoint system with independent timers
- [x] Create `DGTTitle` enum with display names and icons
- [x] Create `GrandPrize` enum with metadata
- [x] Generate Freezed and JSON serialization code

**1.4 Core Utilities (Business Logic)**
- [x] Implement BAC calculator (`lib/core/utils/bac_calculator.dart`)
- [x] Implement points calculator (`lib/core/utils/points_calculator.dart`)
- [x] Implement title evaluator (`lib/core/utils/title_evaluator.dart`)
- [x] Implement checkpoint calculator (`lib/core/utils/checkpoint_calculator.dart`)
- [x] Write comprehensive unit tests for all utilities (`test/unit/core/utils/`)
  - 90%+ coverage target; property-based tests with 200-iteration loops

**1.5 Data Layer (Repositories)**
- [x] Create repository interfaces (Player, GameState, Checkpoint)
- [x] Implement Hive repositories with JSON serialization
- [x] Create Hive service for initialization and box management
- [x] Implement stream support for reactive updates
- [x] Write unit tests for all repositories (`test/unit/data/repositories/`)
  - `FakeBox` in-memory test double; round-trip, CRUD, and invariant tests

**1.6 State Management (Riverpod Providers)**
- [x] Create repository providers (DI)
- [x] Create player providers (list, by ID, count, mutations)
- [x] Create game state providers (start, resume, finish, advance round)
- [x] Create checkpoint providers (`lib/core/providers/checkpoint_providers.dart`)
  - `CheckpointNotifier` with per-second ticker, absolute-timestamp timers
  - `checkpointStreamProvider`, `isCheckpointDueProvider`, `activeGroupProgressProvider`
- [x] Write integration tests for checkpoint provider (`test/integration/`)
  - 6 scenarios: initialize, restart recovery, group independence, UI unlock, sequential processing, reset

**1.7 App Entry Point**
- [x] Set up main.dart with Hive initialization
- [x] Create app.dart with MaterialApp and DGT theme
- [x] Wrap app with ProviderScope
- [x] Update basic smoke test

**1.8 Main Menu & Screens**
- [x] Build `MainMenuScreen` (`lib/features/main_menu/presentation/main_menu_screen.dart`)
  - Persistent home screen with DGT layout
  - Start/Resume Game button (conditional on game state)
  - Mis Vehículos section with player list
  - Actualidad DGT fake news section
- [x] Build `FakeNewsScreen` + `FakeNewsDetailScreen`
- [x] Build `FakeErrorScreen` (satirical DGT error modal)
- [x] Build `FakeErrorNotification` (dismissible top bar)
- [x] Build `FakeNewsSection` (horizontal article preview)
- [x] Build `MainMenuNotifier` provider (`lib/features/main_menu/providers/`)

**1.9 Reusable Widgets**
- [x] Build `MassiveButton` (`lib/widgets/massive_button.dart`)
  - 80px min height, haptic feedback, disabled state, optional icon
- [x] Build `CustomKeypad` (`lib/widgets/custom_keypad.dart`)
  - 3×4 grid, 80×80px buttons, 0.XX format, haptic on every tap
- [x] Build `TitleBadge` (`lib/widgets/title_badge.dart`)
  - DGT title icon + ×N counter, grayed-out at count=0
- [x] Build `LicenseCard` (`lib/widgets/license_card.dart`)
  - Circular photo, points, title badges, impounded overlay
- [x] Write widget tests (`test/widget/widgets/`)

**Deliverables:**
- ✅ Complete core infrastructure
  - ✅ All dependencies installed
  - ✅ Theme system complete
  - ✅ All constants defined (calibrated with real DGT data)
  - ✅ 6 domain models with Freezed + JSON
  - ✅ 4 utility classes with business logic
  - ✅ 3 repositories with Hive storage
  - ✅ Riverpod providers for data access (including CheckpointNotifier)
  - ✅ App entry point configured
- ✅ UI screens and widgets
  - ✅ Main menu with Start/Resume, Mis Vehículos, Fake News sections
  - ✅ Fake News and Fake Error screens
  - ✅ Custom widgets (MassiveButton, CustomKeypad, LicenseCard, TitleBadge)
- ✅ Test suite: 157 tests passing, 0 analyzer issues
  - ✅ Unit tests for all utilities and repositories
  - ✅ Widget tests for all reusable widgets
  - ✅ Integration tests for CheckpointProvider + Hive

**Completed:** May 12, 2026

---

### ✅ Phase 2: Core Gameplay (Week 2) - COMPLETED

**Goal:** Implement BAC entry, points calculation, and basic leaderboard

#### Tasks

**2.1 BAC Calculation Utilities**
- [x] Implement Widmark formula (`lib/core/utils/bac_calculator.dart`)
- [x] Implement optimal BAC zone calculation (calibrated with real DGT data)
  - **Updated:** Breathalyzer readings in mg/L
  - Small: 2.5 mg/L, Medium: 2.0 mg/L, Large: 1.8 mg/L
- [x] Add zone checking methods (isInOptimalZone, isCloseToOptimal, crossedOptimalLine)
- [x] Implement hybrid points system (`lib/core/utils/points_calculator.dart`)
  - Gain points for staying in zone (+2 in zone, +1 close)
  - Lose points for dangerous behavior (-3 over line, -2 fast spike, -5 impounded)
- [x] Write comprehensive unit tests with edge cases
- [x] Test with real-world scenarios

**2.2 Round 0 (Baseline Measurement)**
- [x] Build Round 0 flow (triggered by "Start Game" button)
- [x] Navigate to round-robin screen
- [x] Measure each player's initial BAC
- [x] Show only "Reading recorded for [Player Name]" (no feedback)
- [x] Save as `roundNumber: 0` in BACReading
- [x] After all players measured → transition to Round 1
- [x] Write integration tests

**2.3 Manual BAC Entry**
- [x] Build manual entry screen with custom keypad
- [x] Implement BAC entry provider (Riverpod)
- [x] Implement BAC validation (0.00–9.99 mg/L range)
- [x] Extended `CustomKeypad` to `maxDigits: 3` for X.XX format
- [x] Save BAC readings to Hive with round number
- [x] Write widget and integration tests

**2.4 Real-time Feedback System (Round 1+)**
- [x] Build feedback screen (full-screen notifications)
- [x] Show points gained/lost with color-coded backgrounds
- [x] Show DGT titles won
- [x] Show impoundment banner for violations
- [x] Auto-dismiss after `AppConstants.feedbackDuration`
- [x] Write widget tests

**2.5 License Update System**
- [x] Implement `LicenseGenerator` (dart:ui canvas pipeline)
- [x] Load template, overlay player photo/name/points/titles
- [x] `LicenseUpdateService` regenerates license after each round
- [x] Save updated license PNG to app documents directory

**2.6 Checkpoint Timer System**
- [x] Per-group timer system with independent intervals
- [x] `GroupCountdownCard` widget with MM:SS countdown
- [x] Police siren flash animation (red/blue `AnimationController`)
- [x] Audio alert via `audioplayers` (degrades silently if asset absent)
- [x] `CheckpointScreen` with `ref.listen` for activation transitions
- [x] Timer state saved to Hive per group
- [x] Title evaluation triggered after all groups complete
- [x] Write tests for timer logic

**2.7 Points & Title System**
- [x] Implement automatic points change after BAC entry (Round 1+ only)
- [x] Calculate position relative to optimal zone
- [x] Apply rewards/penalties based on zone position
- [x] Update player points in Hive
- [x] Show notification UI via `FeedbackScreen`
- [x] Mark `crossedOptimalLine` flag when player exceeds optimal + 0.4 mg/L
- [x] Implement per-round title evaluation (`lib/core/utils/title_evaluator.dart`)
- [x] Increment title counters in player profiles via `RoundCompletionService`
- [x] Update license with new title badges

**2.8 Basic Leaderboard**
- [x] Build leaderboard screen (sorted by points)
- [x] Display `LicenseCard` per player with medal badges for top 3
- [x] BAC progression `LineChart` with optimal zone band (player detail screen)
- [x] Tap interaction → navigate to `PlayerDetailScreen`
- [x] `sortedLeaderboardProvider` (Riverpod FutureProvider)
- [x] Pull-to-refresh functionality
- [x] Write widget tests

**Deliverables:**
- ✅ Working BAC entry system (manual, X.XX format)
- ✅ Round 0 baseline measurement (no feedback)
- ✅ Functional checkpoint timer with per-group intervals and siren
- ✅ Hybrid points calculation (rewards + penalties)
- ✅ Real-time feedback system (Round 1+)
- ✅ License generation and update system
- ✅ Per-round title awards via `RoundCompletionService`
- ✅ Leaderboard with medal badges + `fl_chart` BAC progression graph
- ✅ Player detail screen with title chips and optimal zone visualization
- ✅ 225 tests passing, 0 analysis issues

**Completed:** 2026-05-14

---

### 🚀 Phase 3: Advanced Features (Week 3)

**Goal:** Add OCR, round-robin flow, penalties, and DGT titles

#### Tasks

**3.1 OCR Camera Integration**
- [ ] Set up ML Kit text recognition
- [ ] Build camera OCR screen
- [ ] Implement OCR service (`lib/features/breathalyzer/data/ocr_service.dart`)
- [ ] Add confidence scoring (auto-confirm if >90%)
- [ ] Implement fallback to manual entry
- [ ] Handle edge cases (poor lighting, angles, multiple numbers)
- [ ] Write tests with mock camera data

**3.2 Round-Robin Flow ("El Retén")**
- [ ] Build round-robin screen with avatar carousel
- [ ] Implement auto-advance every 10 seconds
- [ ] Add progress indicator (e.g., "3/8 players logged")
- [ ] Tap avatar to open data entry
- [ ] Implement round-robin provider (Riverpod)
- [ ] Write integration tests

**3.3 Penalty System**
- [ ] Implement "Vehículo Inmovilizado" (impoundment) logic
  - **Updated:** Threshold at 3.5 mg/L (based on real DGT data)
- [ ] Build full-screen fake error message UI (assets/msg_error.png)
- [ ] Add error buzzer sound
- [ ] Mark player as impounded in Hive
- [ ] Prevent impounded players from next round
- [ ] Write tests for all penalty scenarios

**3.4 DGT Title System (Complete)**
- [ ] Finalize title evaluator (`lib/core/utils/title_evaluator.dart`)
- [ ] Implement all 5 per-round titles with logos
- [ ] Calculate grand prize winners:
  - 🏆 El Conductor Perfecto (Highest points + never crossed line)
  - 🎯 Precisión Absoluta (Closest average to optimal zone)
  - 👑 Coleccionista de Títulos (Most DGT titles accumulated)
- [ ] Implement Environmental Distinctive calculation (top 5 highest BAC)
- [ ] Display titles on leaderboard with counters
- [ ] Write unit tests for all title logic

**3.5 License Viewing**
- [ ] Build full-screen license view screen
- [ ] Display current license image with all badges
- [ ] Add pinch-to-zoom functionality
- [ ] Add share button (export to gallery)
- [ ] Navigate from leaderboard (tap player card)
- [ ] Write widget tests

**3.6 Game State Recovery**
- [ ] Implement game recovery provider
- [ ] Check Hive for existing game state on app launch
- [ ] Resume timer from saved state
- [ ] Load all players and their data
- [ ] Navigate to appropriate screen based on game state
- [ ] Write integration tests for crash recovery

**Deliverables:**
- ✅ Working OCR camera integration
- ✅ Round-robin BAC entry flow
- ✅ Complete penalty system with fake error message
- ✅ All DGT titles (per-round + grand prizes)
- ✅ Environmental Distinctive badges
- ✅ Full-screen license viewing (tap from leaderboard)
- ✅ Game state recovery (resume after crash)
- ✅ Audio/visual effects
- ✅ All tests passing

**Estimated Completion:** End of Week 3

---

### 🎨 Phase 4: Polish & Release (Week 4)

**Goal:** Add fake license generation, final ceremony, and prepare for release

#### Tasks

**4.1 Final Report Screen**
- [ ] Build final report screen with summary statistics
- [ ] Display BAC progression graphs for all players
- [ ] Show final leaderboard
- [ ] Add "Continue to Ceremony" button
- [ ] Write widget tests

**4.2 License Export System**
- [ ] Implement license export service
- [ ] Export single license to gallery
- [ ] Export all licenses as batch
- [ ] Add share functionality (social media)
- [ ] Write unit tests

**4.3 Final Ceremony ("La Multa")**
- [ ] Build final ceremony screen
- [ ] Add "Finish Game" button to main menu (visible if game in progress)
- [ ] Implement envelope animation for 3 Grand Prizes:
  - 🏆 El Conductor Perfecto
  - 🎯 Precisión Absoluta
  - 👑 Coleccionista de Títulos
- [ ] Add Environmental Distinctive reveal (top 5 highest BAC)
- [ ] Update licenses with environmental badges
- [ ] Add confetti animation
- [ ] Reveal fake licenses with winner photos
- [ ] Add 10% chance to show fake error message as a joke
- [ ] Add "Return to Menu" button (clear game state)
- [ ] Add "View All Licenses" button (gallery view)
- [ ] Write integration tests

**4.4 BAC Progression Graphs**
- [ ] Integrate `fl_chart` package
- [ ] Build BAC progression line chart
- [ ] Highlight optimal zone as green band
- [ ] Mark Round 0 as baseline
- [ ] Show all checkpoints on timeline
- [ ] Add to player detail screen and final report
- [ ] Write widget tests

**4.5 Comprehensive Testing**
- [ ] Achieve 80%+ code coverage
- [ ] Test all features on physical devices
- [ ] Test persistent state (app restart, crash recovery)
- [ ] Test with real users (party scenario)
- [ ] Fix all bugs discovered during testing
- [ ] Performance optimization (60fps animations)

**4.6 Documentation & Release**
- [ ] Update all documentation
- [ ] Create user guide (in-app onboarding)
- [ ] Record demo video
- [ ] Set up Firebase App Distribution
- [ ] Build release APK
- [ ] Create GitHub release (v1.0.0)

**Deliverables:**
- ✅ Complete app with all features
- ✅ Final report screen with statistics and graphs
- ✅ License export system (single and batch)
- ✅ Final ceremony with 3 Grand Prizes + Environmental Distinctives
- ✅ Fake error message integration (impoundment + 10% ceremony chance)
- ✅ BAC graphs with optimal zone visualization and Round 0 baseline
- ✅ Persistent state management (crash recovery)
- ✅ 80%+ test coverage
- ✅ Release APK on GitHub
- ✅ Demo video

**Estimated Completion:** End of Week 4

---

## 🔮 Future Enhancements (Post-v1.0.0)

### v1.1.0 - Social Features
- [ ] Share leaderboard to social media
- [ ] Export game summary as image
- [ ] QR code for quick player joining
- [ ] Multiplayer sync across devices (Firebase)

### v1.2.0 - Customization
- [ ] Custom avatar upload
- [ ] Configurable checkpoint intervals
- [ ] Custom BAC thresholds per player
- [ ] Theme customization (colors, sounds)

### v1.3.0 - Analytics & Insights
- [ ] Historical game statistics
- [ ] Personal BAC trends over time
- [ ] Achievement unlocking system
- [ ] Leaderboard across multiple games

### v2.0.0 - Advanced Features
- [ ] iOS support
- [ ] Web version for desktop
- [ ] Bluetooth breathalyzer integration
- [ ] Real-time multiplayer with WebSockets
- [ ] Cloud backup of game history

---

## 📊 Progress Tracking

### Overall Progress
- **Phase 0:** ✅ 100% Complete
- **Phase 1:** ✅ 100% Complete (Core infrastructure + UI screens + tests)
- **Phase 2:** ✅ 100% Complete (Full game loop + leaderboard + license generation)
- **Phase 3:** ⏳ 0% Complete (Planned)
- **Phase 4:** ⏳ 0% Complete (Planned)

### Feature Completion
| Feature | Status | Progress |
|---------|--------|----------|
| Core Infrastructure | ✅ Complete | 100% |
| Theme System | ✅ Complete | 100% |
| Domain Models | ✅ Complete | 100% |
| Business Logic | ✅ Complete | 100% |
| Data Layer | ✅ Complete | 100% |
| State Management | ✅ Complete | 100% |
| Checkpoint Provider | ✅ Complete | 100% |
| Main Menu Screen | ✅ Complete | 100% |
| Fake News & Error Screens | ✅ Complete | 100% |
| Reusable Widgets | ✅ Complete | 100% |
| Player Registration | ✅ Complete | 100% |
| Player Selection | ✅ Complete | 100% |
| Manual BAC Entry | ✅ Complete | 100% |
| Round-Robin Flow | ✅ Complete | 100% |
| Feedback Screen | ✅ Complete | 100% |
| Checkpoint Timer UI | ✅ Complete | 100% |
| Points System UI | ✅ Complete | 100% |
| Penalty System (impoundment) | ✅ Complete | 100% |
| Leaderboard | ✅ Complete | 100% |
| BAC Graphs | ✅ Complete | 100% |
| Fake License Generation | ✅ Complete | 100% |
| Unit Tests (Utils) | ✅ Complete | 100% |
| Unit Tests (Providers) | ✅ Complete | 100% |
| Widget Tests | ✅ Complete | 100% |
| OCR Camera | ⏳ Planned | 0% |
| Final Ceremony | ⏳ Planned | 0% |

---

## 🤝 Collaboration Strategy

### Person A (Core Infrastructure) - ✅ COMPLETED
- ✅ All dependencies and project setup
- ✅ Complete theme system (colors, typography, theme)
- ✅ All constants (calibrated with real DGT data)
- ✅ All domain models (6 models with Freezed + JSON)
- ✅ All business logic utilities (4 utility classes)
- ✅ Complete data layer (3 repositories with Hive)
- ✅ Riverpod providers for data access
- ✅ App entry point and configuration

### Person B (UI & Screens) - ✅ PHASE 2 COMPLETE
- ✅ Main menu screen (persistent home with DGT layout)
- ✅ Fake News and Fake Error screens
- ✅ Custom widgets (MassiveButton, CustomKeypad, LicenseCard, TitleBadge)
- ✅ CheckpointNotifier provider (per-group timer management)
- ✅ Player registration flow (5-page wizard with photo capture)
- ✅ Player selection screen (checkbox list + interval picker)
- ✅ Manual BAC entry screen (CustomKeypad maxDigits=3)
- ✅ Round-robin flow (RoundRobinScreen with sequential player carousel)
- ✅ Feedback screen (full-screen color-coded results + auto-dismiss)
- ✅ Checkpoint timer UI (GroupCountdownCard + SirenAlertOverlay)
- ✅ Leaderboard screen (medal badges + pull-to-refresh)
- ✅ Player detail screen (fl_chart BAC graph + title chips)
- ✅ License generator (dart:ui canvas PNG generation)
- ✅ Comprehensive test suite (225 tests, 0 issues)
- [ ] OCR camera integration (Phase 3)
- [ ] Final ceremony animations (Phase 4)

### Shared Responsibilities
- Testing (both write tests for their features)
- Code reviews (review each other's PRs)
- Documentation updates
- Physical device testing

---

## 📝 Notes

- This roadmap is flexible and will be updated based on progress and feedback
- Each phase should be completed before moving to the next
- All features must have tests before being considered complete
- Physical device testing is mandatory for drunk-proof UX validation
- Update this roadmap weekly during development

---

**Last Updated:** May 14, 2026  
**Next Review:** End of Phase 3

**Key Changes in This Update:**
- ✅ Phase 2 fully completed (full game loop: registration → BAC entry → feedback → checkpoint → leaderboard)
- ✅ 26 new files created, 5 existing files modified
- ✅ Complete round-robin BAC entry flow with `BACEntryNotifier`
- ✅ Full-screen feedback with color-coded results and auto-dismiss
- ✅ Siren alert overlay (flash animation + audio)
- ✅ Leaderboard with `fl_chart` BAC progression graph and optimal zone band
- ✅ Fake license generation via `dart:ui` canvas pipeline
- ✅ 225 tests passing, `flutter analyze` 0 issues
- 📝 Phase 3 next: OCR camera integration, penalty system UI, grand prize title logic
