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
  - **Updated:** Breathalyzer readings in mg/L (based on real DGT data)
  - Optimal BAC zones: Small=2.5, Medium=2.0, Large=1.8 mg/L
  - Tolerance: ±0.2 mg/L (in zone), ±0.4 mg/L (close)
  - Impoundment threshold: 3.5 mg/L
  - Dangerous spike: >0.8 mg/L per hour
- [x] Set up asset paths (`lib/core/constants/asset_paths.dart`)
  - Include fake error message: assets/msg_error.png
- [x] Create DGT strings (`lib/core/constants/dgt_strings.dart`)

**1.3 Core Models**
- [x] Create `PlayerProfile` model (Freezed + JSON)
  - Add `name` and `surname` fields
  - Add `photoPath` for camera capture
  - Add `optimalBAC` field (calculated from body size)
  - Add `titleCounts` map to track DGT title accumulation
  - Add `crossedOptimalLine` flag for Grand Prize eligibility
  - Add `licenseImagePath` for auto-generated license
- [x] Create `BACReading` model (Freezed + JSON)
  - Add `roundNumber` field (0 for baseline)
  - Add `entryMethod` field (manual, OCR, roundRobin)
  - Add `pointsChange` field
- [x] Create `GameState` model (Freezed + JSON)
  - Track current round, game in progress flag, player IDs
- [x] Create `CheckpointState` model (Freezed + JSON)
  - **Updated:** Per-group checkpoint system with independent timers
  - Each group has its own `lastMeasurement` and `intervalMinutes`
  - Groups can measure at different times (e.g., Group 1 at 14:00, Group 2 at 14:30)
- [x] Create `DGTTitle` enum with display names and icons
- [x] Create `GrandPrize` enum with metadata
- [x] Generate Freezed and JSON serialization code
- [ ] Write unit tests for models

**1.4 Core Utilities (Business Logic)**
- [x] Implement BAC calculator (`lib/core/utils/bac_calculator.dart`)
  - **Updated:** Calibrated with real DGT data for breathalyzer readings (mg/L)
  - Widmark formula for estimation only
  - Optimal zone calculations based on body size
  - Zone checking methods (isInOptimalZone, isCloseToOptimal, crossedOptimalLine)
- [x] Implement points calculator (`lib/core/utils/points_calculator.dart`)
  - Hybrid points system (+2 in zone, +1 close, -3 crossed, -2 spike, -5 impounded)
  - Feedback message generation
  - Average distance from optimal calculation
- [x] Implement title evaluator (`lib/core/utils/title_evaluator.dart`)
  - Per-round title awards (5 titles)
  - Grand prize calculation (3 prizes)
  - Environmental distinctive selection (top 5)
- [x] Implement checkpoint calculator (`lib/core/utils/checkpoint_calculator.dart`)
  - **Updated:** Per-group timer calculations
  - Independent checkpoint times for each group
  - Configurable intervals (30, 45, 60 minutes)
  - Group division logic (3-8 players per group)
  - Beer consumption estimation
- [ ] Write comprehensive unit tests for all utilities

**1.5 Data Layer (Repositories)**
- [x] Create repository interfaces (Player, GameState, Checkpoint)
- [x] Implement Hive repositories with JSON serialization
- [x] Create Hive service for initialization and box management
- [x] Implement stream support for reactive updates
- [ ] Write unit tests for repositories

**1.6 State Management (Riverpod Providers)**
- [x] Create repository providers (DI)
- [x] Create player providers (list, by ID, count, mutations)
- [x] Create game state providers (start, resume, finish, advance round)
- [ ] Create checkpoint providers (per-group timer management)
- [ ] Write tests for provider logic

**1.7 App Entry Point**
- [x] Set up main.dart with Hive initialization
- [x] Create app.dart with MaterialApp and DGT theme
- [x] Wrap app with ProviderScope
- [x] Update basic smoke test
- [ ] Main Menu (Persistent Home Screen) - **TO BE DONE BY PERSON B**
- [ ] Fake News & Fake Error Screens - **TO BE DONE BY PERSON B**
- [ ] Player Registration Flow - **TO BE DONE BY PERSON B**

**1.8 Reusable Widgets** - **TO BE DONE BY PERSON B**
- [ ] Build `MassiveButton` widget (oversized, high-contrast)
- [ ] Build `CustomKeypad` widget (drunk-proof number pad)
- [ ] Build `TitleBadge` widget (DGT title with counter: 🟢×3)
- [ ] Build `LicenseCard` widget (display player license)
- [ ] Write widget tests

**Deliverables:**
- ✅ Complete core infrastructure (Person A)
  - ✅ All dependencies installed
  - ✅ Theme system complete
  - ✅ All constants defined (calibrated with real DGT data)
  - ✅ 6 domain models with Freezed + JSON
  - ✅ 4 utility classes with business logic
  - ✅ 3 repositories with Hive storage
  - ✅ Riverpod providers for data access
  - ✅ App entry point configured
  - ✅ Tests passing, analysis clean
- ⏳ UI screens and widgets (Person B)
  - [ ] Main menu with all buttons
  - [ ] Fake News and Fake Error screens
  - [ ] Complete player registration flow
  - [ ] License auto-generation system
  - [ ] Custom widgets (MassiveButton, CustomKeypad, etc.)

**Estimated Completion:** End of Week 1

---

### 📋 Phase 2: Core Gameplay (Week 2)

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
- [ ] Write comprehensive unit tests with edge cases
- [ ] Test with real-world scenarios

**2.2 Round 0 (Baseline Measurement)**
- [ ] Build Round 0 flow (triggered by "Start Game" button)
- [ ] Navigate to round-robin screen
- [ ] Measure each player's initial BAC
- [ ] Show only "Reading recorded for [Player Name]" (no feedback)
- [ ] Save as `roundNumber: 0` in BACReading
- [ ] After all players measured → transition to Round 1
- [ ] Write integration tests

**2.3 Manual BAC Entry**
- [ ] Build manual entry screen with custom keypad
- [ ] Implement BAC entry provider (Riverpod)
- [ ] Add haptic feedback on keypad taps
- [ ] Implement BAC validation (0.00-9.99 mg/L range)
- [ ] Save BAC readings to Hive with round number
- [ ] Write widget and integration tests

**2.4 Real-time Feedback System (Round 1+)**
- [ ] Build feedback screen (full-screen notifications)
- [ ] Show points gained/lost with color-coded backgrounds
- [ ] Show DGT titles won with logo animations
- [ ] Show warnings for approaching limits
- [ ] Show penalties for violations
- [ ] Implement feedback provider (Riverpod)
- [ ] Write widget tests

**2.5 License Update System**
- [ ] Implement license update service
- [ ] Load existing license image
- [ ] Update points value on license
- [ ] Add new title badges to reserved slots
- [ ] Add "IMPOUNDED" badge if applicable
- [ ] Save updated license image
- [ ] Write unit tests for license updates

**2.6 Checkpoint Timer System**
- [ ] Implement checkpoint timer provider (Riverpod)
  - **Updated:** Per-group timer system
  - Each group has independent timer based on their last measurement
  - Configurable intervals (30, 45, 60 minutes)
- [ ] Build timer widget for each group (countdown display)
- [ ] Add police siren audio alert when group checkpoint is due
- [ ] Implement screen flash animation (red/blue)
- [ ] Lock UI for active group until all players in group log BAC
- [ ] Save timer state to Hive for each group
- [ ] Trigger per-round title evaluation after all groups complete
- [ ] Write tests for timer logic and persistence

**2.7 Points & Title System**
- [x] Implement automatic points change after BAC entry (Round 1+ only)
- [x] Calculate position relative to optimal zone
- [x] Apply rewards/penalties based on zone position
- [ ] Update player points in Hive
- [ ] Show notification UI ("+2 points: In the zone!" or "-3 points: Over the line!")
- [ ] Mark `crossedOptimalLine` flag when player exceeds optimal + 0.4 mg/L
- [x] Implement per-round title evaluation (`lib/core/utils/title_evaluator.dart`)
- [ ] Award 5 titles per checkpoint (Velocidad de Crucero, Multa por Exceso, etc.)
- [ ] Increment title counters in player profiles
- [ ] Show title award animation with logo
- [ ] Update license with new title badges
- [ ] Write unit tests for all scenarios

**2.8 Basic Leaderboard**
- [ ] Build leaderboard screen (sorted by points)
- [ ] Display player cards with photo, name + surname, points, BAC
- [ ] Show optimal BAC zone for each player
- [ ] Display title badge counters (🟢×3, 🔴×1, etc.)
- [ ] Add tap interaction → navigate to full license view
- [ ] Implement leaderboard provider (Riverpod)
- [ ] Add pull-to-refresh functionality
- [ ] Write widget tests

**Deliverables:**
- ✅ Working BAC entry system
- ✅ Round 0 baseline measurement (no feedback)
- ✅ Functional checkpoint timer with per-group intervals
- ✅ Hybrid points calculation (rewards + penalties)
- ✅ Real-time feedback system (Round 1+)
- ✅ License update system (auto-update after each round)
- ✅ Per-round title awards
- ✅ Basic leaderboard with title counters and tap-to-view license
- ✅ All tests passing

**Estimated Completion:** End of Week 2

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
- **Phase 1:** ✅ 80% Complete (Core infrastructure done by Person A, UI pending for Person B)
- **Phase 2:** ⏳ 20% Complete (Business logic done, UI implementation pending)
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
| State Management | 🚧 In Progress | 70% |
| Player Registration | ⏳ Planned | 0% |
| Manual BAC Entry | ⏳ Planned | 0% |
| OCR Camera | ⏳ Planned | 0% |
| Round-Robin Flow | ⏳ Planned | 0% |
| Checkpoint Timer | 🚧 In Progress | 50% |
| Points System | 🚧 In Progress | 80% |
| Penalty System | ⏳ Planned | 0% |
| Leaderboard | ⏳ Planned | 0% |
| DGT Titles | 🚧 In Progress | 80% |
| BAC Graphs | ⏳ Planned | 0% |
| Fake License | ⏳ Planned | 0% |
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

### Person B (UI & Screens) - 🚧 IN PROGRESS
- [ ] Main menu screen (persistent home)
- [ ] Fake News and Fake Error screens
- [ ] Player registration flow (6 screens)
- [ ] Custom widgets (MassiveButton, CustomKeypad, LicenseCard, TitleBadge)
- [ ] Manual BAC entry screen
- [ ] Leaderboard screen
- [ ] License viewing screen
- [ ] Checkpoint timer UI
- [ ] Feedback screens
- [ ] OCR camera integration
- [ ] Round-robin flow
- [ ] Final ceremony animations

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

**Last Updated:** May 6, 2026  
**Next Review:** May 13, 2026 (End of Phase 2)

**Key Changes in This Update:**
- ✅ Phase 1 core infrastructure completed by Person A
- 🔄 Updated BAC thresholds based on real DGT data (breathalyzer readings in mg/L)
- 🔄 Updated checkpoint system to per-group timers with configurable intervals
- 🔄 Calibrated optimal zones: Small=2.5, Medium=2.0, Large=1.8 mg/L
- 🔄 Updated impoundment threshold to 3.5 mg/L
- 🔄 Updated tolerances: ±0.2 mg/L (in zone), ±0.4 mg/L (close)
- 📝 Person B to continue with UI screens and widgets
