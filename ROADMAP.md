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
- [ ] Set up Hive for local storage
- [ ] Initialize Riverpod providers
- [ ] Configure code generation (build_runner)
- [ ] Set up lefthook for pre-commit hooks

**1.2 Core Theme & Constants**
- [ ] Implement DGT color palette (`lib/core/theme/dgt_colors.dart`)
- [ ] Create typography system (`lib/core/theme/dgt_typography.dart`)
- [ ] Build theme configuration (`lib/core/theme/dgt_theme.dart`)
- [ ] Define app constants (`lib/core/constants/app_constants.dart`)
- [ ] Set up asset paths (`lib/core/constants/asset_paths.dart`)
- [ ] Create DGT strings (`lib/core/constants/dgt_strings.dart`)

**1.3 Core Models**
- [ ] Create `PlayerProfile` model (Freezed + Hive)
- [ ] Create `BACReading` model (Freezed + Hive)
- [ ] Create `Achievement` model (Freezed + Hive)
- [ ] Generate Hive type adapters
- [ ] Write unit tests for models

**1.4 Reusable Widgets**
- [ ] Build `MassiveButton` widget (oversized, high-contrast)
- [ ] Build `CustomKeypad` widget (drunk-proof number pad)
- [ ] Build `DGTAvatar` widget (player avatar display)
- [ ] Write widget tests

**1.5 Player Registration Flow**
- [ ] Name input screen with custom keyboard
- [ ] Avatar selection screen (grid of 12+ options)
- [ ] Sex selection screen (Male/Female buttons)
- [ ] Body size selection screen (S/M/L buttons)
- [ ] Photo capture screen with countdown timer
- [ ] Confirmation screen
- [ ] Implement Riverpod providers for registration state
- [ ] Implement Hive storage for player profiles
- [ ] Write integration tests for registration flow

**Deliverables:**
- ✅ Working app with theme and navigation
- ✅ Complete player registration flow
- ✅ Players saved to Hive storage
- ✅ All tests passing

**Estimated Completion:** End of Week 1

---

### 📋 Phase 2: Core Gameplay (Week 2)

**Goal:** Implement BAC entry, points calculation, and basic leaderboard

#### Tasks

**2.1 BAC Calculation Utilities**
- [ ] Implement Widmark formula (`lib/core/utils/bac_calculator.dart`)
- [ ] Implement points deduction logic (`lib/core/utils/points_calculator.dart`)
- [ ] Write comprehensive unit tests with edge cases
- [ ] Test with real-world scenarios

**2.2 Manual BAC Entry**
- [ ] Build manual entry screen with custom keypad
- [ ] Implement BAC entry provider (Riverpod)
- [ ] Add haptic feedback on keypad taps
- [ ] Implement BAC validation (0.00-9.99 range)
- [ ] Save BAC readings to Hive
- [ ] Write widget and integration tests

**2.3 Checkpoint Timer System**
- [ ] Implement checkpoint timer provider (Riverpod)
- [ ] Build shot clock widget (countdown display)
- [ ] Add police siren audio alert
- [ ] Implement screen flash animation (red/blue)
- [ ] Lock UI until all players log BAC
- [ ] Write tests for timer logic

**2.4 Points System**
- [ ] Implement automatic points deduction after BAC entry
- [ ] Calculate delta from previous reading
- [ ] Apply penalties based on rate per hour
- [ ] Update player points in Hive
- [ ] Show penalty notification UI
- [ ] Write unit tests for all penalty scenarios

**2.5 Basic Leaderboard**
- [ ] Build leaderboard screen (sorted by points)
- [ ] Display player cards with avatar, name, points, BAC
- [ ] Implement leaderboard provider (Riverpod)
- [ ] Add pull-to-refresh functionality
- [ ] Write widget tests

**Deliverables:**
- ✅ Working BAC entry system
- ✅ Functional checkpoint timer
- ✅ Automatic points calculation
- ✅ Basic leaderboard display
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
- [ ] Build full-screen red warning UI
- [ ] Add error buzzer sound
- [ ] Mark player as impounded in Hive
- [ ] Prevent impounded players from next round
- [ ] Write tests for all penalty scenarios

**3.4 DGT Title Evaluation**
- [ ] Implement title evaluator (`lib/core/utils/title_evaluator.dart`)
- [ ] Define all 5 DGT titles (Cruise Control, Speeding, etc.)
- [ ] Calculate titles after each checkpoint
- [ ] Award titles to players
- [ ] Display titles on leaderboard
- [ ] Write unit tests for title logic

**3.5 Audio & Visual Effects**
- [ ] Add police siren sound effect
- [ ] Add error buzzer sound effect
- [ ] Implement siren animation widget
- [ ] Add haptic feedback for all interactions
- [ ] Test on physical devices

**Deliverables:**
- ✅ Working OCR camera integration
- ✅ Round-robin BAC entry flow
- ✅ Complete penalty system
- ✅ DGT title awards
- ✅ Audio/visual effects
- ✅ All tests passing

**Estimated Completion:** End of Week 3

---

### 🎨 Phase 4: Polish & Release (Week 4)

**Goal:** Add fake license generation, final ceremony, and prepare for release

#### Tasks

**4.1 Fake DGT License Generation**
- [ ] Design DGT license template (blue/yellow)
- [ ] Build license card widget
- [ ] Implement photo cropping (circular)
- [ ] Add achievement badges to license
- [ ] Export license as PNG to gallery
- [ ] Write widget tests

**4.2 Final Ceremony ("La Multa")**
- [ ] Build final ceremony screen
- [ ] Implement envelope animation for each category
- [ ] Add confetti animation
- [ ] Reveal fake licenses with winner photos
- [ ] Add share functionality (export all licenses)
- [ ] Write integration tests

**4.3 BAC Progression Graphs**
- [ ] Integrate `fl_chart` package
- [ ] Build BAC progression line chart
- [ ] Add to player detail screen
- [ ] Show all checkpoints on timeline
- [ ] Write widget tests

**4.4 Comprehensive Testing**
- [ ] Achieve 80%+ code coverage
- [ ] Test all features on physical devices
- [ ] Test with real users (party scenario)
- [ ] Fix all bugs discovered during testing
- [ ] Performance optimization (60fps animations)

**4.5 Documentation & Release**
- [ ] Update all documentation
- [ ] Create user guide (in-app onboarding)
- [ ] Record demo video
- [ ] Set up Firebase App Distribution
- [ ] Build release APK
- [ ] Create GitHub release (v1.0.0)

**Deliverables:**
- ✅ Complete app with all features
- ✅ Fake license generation
- ✅ Final ceremony animations
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
