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

### 🚧 Phase 1: Foundation (Week 1) - IN PROGRESS

**Goal:** Set up core architecture and basic infrastructure

#### Tasks

**1.1 Project Setup**
- [ ] Configure `pubspec.yaml` with all required dependencies
- [ ] Set up Hive for local storage with persistent state management
- [ ] Initialize Riverpod providers
- [ ] Configure code generation (build_runner)
- [ ] Set up lefthook for pre-commit hooks

**1.2 Core Theme & Constants**
- [ ] Implement DGT color palette (`lib/core/theme/dgt_colors.dart`)
  - Primary: #0F5993 (DGT Blue)
  - Background: #F6F4F5 (Light Gray)
  - License ID: #F3E8EC (Light Pink)
  - Green: #D2D667, Yellow: #F4E944, Orange: #F3910E, Red: #EF6B6A
- [ ] Create typography system (`lib/core/theme/dgt_typography.dart`)
- [ ] Build theme configuration (`lib/core/theme/dgt_theme.dart`)
- [ ] Define app constants (`lib/core/constants/app_constants.dart`)
  - Optimal BAC zones: S=0.05, M=0.07, L=0.09
  - Tolerance: ±0.02
  - Impoundment threshold: 1.2
- [ ] Set up asset paths (`lib/core/constants/asset_paths.dart`)
  - Include fake error message: assets/msg_error.png
- [ ] Create DGT strings (`lib/core/constants/dgt_strings.dart`)

**1.3 Core Models**
- [ ] Create `PlayerProfile` model (Freezed + Hive)
  - Add `name` and `surname` fields
  - Add `photoPath` for camera capture
  - Add `optimalBAC` field (calculated from body size)
  - Add `titleCounts` map to track DGT title accumulation
  - Add `crossedOptimalLine` flag for Grand Prize eligibility
  - Add `licenseImagePath` for auto-generated license
- [ ] Create `BACReading` model (Freezed + Hive)
  - Add `roundNumber` field (0 for baseline)
- [ ] Create `GameState` model (Freezed + Hive)
  - Track current round, timer state, game in progress flag
- [ ] Generate Hive type adapters
- [ ] Write unit tests for models

**1.4 Reusable Widgets**
- [ ] Build `MassiveButton` widget (oversized, high-contrast)
- [ ] Build `CustomKeypad` widget (drunk-proof number pad)
- [ ] Build `TitleBadge` widget (DGT title with counter: 🟢×3)
- [ ] Write widget tests

**1.5 Main Menu (Persistent Home Screen)**
- [ ] Build main menu screen with DGT/DGV branding
- [ ] Add "Add Player" button → navigate to registration
- [ ] Add "Fake News" button → show satirical DGT news screen
- [ ] Add "Fake Error Message" button → show fake error screen
- [ ] Add "Start Game" button (visible if no game in progress)
- [ ] Add "Resume Game" button (visible if game in progress)
- [ ] Implement game state provider (check Hive for existing game)
- [ ] Write integration tests for menu navigation

**1.6 Fake News & Fake Error Screens**
- [ ] Design fake news screen with satirical DGT articles
- [ ] Implement fake error screen (display assets/msg_error.png)
- [ ] Add "Back to Menu" buttons
- [ ] Write widget tests

**1.7 Player Registration Flow**
- [ ] Name input screen with custom keyboard
- [ ] Surname input screen with custom keyboard
- [ ] Sex selection screen (Male/Female buttons)
- [ ] Body size selection screen (S/M/L buttons with weight indicators)
- [ ] Photo capture screen with countdown timer
- [ ] Confirmation screen (shows calculated optimal BAC zone)
- [ ] Implement license generation service
  - Load template image
  - Add photo, name, surname, sex, size, ID, points
  - Reserve space for badge slots
  - Save license image to app documents
- [ ] Implement Riverpod providers for registration state
- [ ] Calculate optimal BAC based on body size
- [ ] Implement Hive storage for player profiles
- [ ] Write integration tests for registration flow

**Deliverables:**
- ✅ Working app with theme and navigation
- ✅ Main menu with all buttons (Add Player, Fake News, Fake Error, Start/Resume)
- ✅ Fake News and Fake Error screens
- ✅ Complete player registration flow (name + surname)
- ✅ License auto-generation system with template
- ✅ Players saved to Hive storage
- ✅ Persistent game state management
- ✅ All tests passing

**Estimated Completion:** End of Week 1

---

### 📋 Phase 2: Core Gameplay (Week 2)

**Goal:** Implement BAC entry, points calculation, and basic leaderboard

#### Tasks

**2.1 BAC Calculation Utilities**
- [ ] Implement Widmark formula (`lib/core/utils/bac_calculator.dart`)
- [ ] Implement optimal BAC zone calculation (S=0.05, M=0.07, L=0.09)
- [ ] Add zone checking methods (isInOptimalZone, isCloseToOptimal, crossedOptimalLine)
- [ ] Implement hybrid points system (`lib/core/utils/points_calculator.dart`)
  - Gain points for staying in zone (+2 in zone, +1 close)
  - Lose points for dangerous behavior (-3 over line, -2 fast spike, -5 impoundment)
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
- [ ] Implement BAC validation (0.00-9.99 range)
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
- [ ] Build shot clock widget (countdown display)
- [ ] Add police siren audio alert
- [ ] Implement screen flash animation (red/blue)
- [ ] Lock UI until all players log BAC
- [ ] Save timer state to Hive every second
- [ ] Trigger per-round title evaluation after all players log
- [ ] Write tests for timer logic and persistence

**2.7 Points & Title System**
- [ ] Implement automatic points change after BAC entry (Round 1+ only)
- [ ] Calculate position relative to optimal zone
- [ ] Apply rewards/penalties based on zone position
- [ ] Update player points in Hive
- [ ] Show notification UI ("+2 points: In the zone!" or "-3 points: Over the line!")
- [ ] Mark `crossedOptimalLine` flag when player exceeds optimal + 0.05
- [ ] Implement per-round title evaluation (`lib/core/utils/title_evaluator.dart`)
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
- ✅ Functional checkpoint timer with persistence
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
- **Phase 1:** 🚧 0% Complete (In Progress)
- **Phase 2:** ⏳ 0% Complete (Planned)
- **Phase 3:** ⏳ 0% Complete (Planned)
- **Phase 4:** ⏳ 0% Complete (Planned)

### Feature Completion
| Feature | Status | Progress |
|---------|--------|----------|
| Player Registration | ⏳ Planned | 0% |
| Manual BAC Entry | ⏳ Planned | 0% |
| OCR Camera | ⏳ Planned | 0% |
| Round-Robin Flow | ⏳ Planned | 0% |
| Checkpoint Timer | ⏳ Planned | 0% |
| Points System | ⏳ Planned | 0% |
| Penalty System | ⏳ Planned | 0% |
| Leaderboard | ⏳ Planned | 0% |
| DGT Titles | ⏳ Planned | 0% |
| BAC Graphs | ⏳ Planned | 0% |
| Fake License | ⏳ Planned | 0% |
| Final Ceremony | ⏳ Planned | 0% |

---

## 🤝 Collaboration Strategy

### Developer 1 Focus Areas
- Player registration flow
- Manual BAC entry
- Leaderboard UI
- Fake license generation

### Developer 2 Focus Areas
- OCR camera integration
- Checkpoint timer system
- Points calculation logic
- Final ceremony animations

### Shared Responsibilities
- Core theme and widgets
- Testing (both write tests for their features)
- Code reviews (review each other's PRs)
- Documentation updates

---

## 📝 Notes

- This roadmap is flexible and will be updated based on progress and feedback
- Each phase should be completed before moving to the next
- All features must have tests before being considered complete
- Physical device testing is mandatory for drunk-proof UX validation
- Update this roadmap weekly during development

---

**Last Updated:** May 4, 2026  
**Next Review:** May 11, 2026 (End of Phase 1)
