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
- ✅ Development guidelines for all developers

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
- [x] Create typography system (`lib/core/theme/dgt_typography.dart`)
- [x] Build theme configuration (`lib/core/theme/dgt_theme.dart`)
- [x] Define app constants (`lib/core/constants/app_constants.dart`)
- [x] Set up asset paths (`lib/core/constants/asset_paths.dart`)
- [x] Create DGT strings (`lib/core/constants/dgt_strings.dart`)

**1.3 Core Models**
- [x] Create `PlayerProfile` model (Freezed + JSON)
- [x] Create `BACReading` model (Freezed + JSON)
- [x] Create `GameState` model (Freezed + JSON)
- [x] Create `CheckpointState` + `GroupCheckpoint` models (Freezed + JSON)
- [x] Create `DGTTitle` enum with display names and icons
- [x] Generate Freezed and JSON serialization code

**1.4 Core Utilities (Business Logic)**
- [x] Implement BAC calculator (`lib/core/utils/bac_calculator.dart`)
- [x] Implement points calculator (`lib/core/utils/points_calculator.dart`)
- [x] Implement title evaluator (`lib/core/utils/title_evaluator.dart`)
- [x] Implement checkpoint calculator (`lib/core/utils/checkpoint_calculator.dart`)
- [x] Write comprehensive unit tests for all utilities

**1.5 Data Layer (Repositories)**
- [x] Create repository interfaces (Player, GameState, Checkpoint)
- [x] Implement Hive repositories with JSON serialization
- [x] Create Hive service for initialization and box management
- [x] Implement stream support for reactive updates

**1.6 State Management (Riverpod Providers)**
- [x] Create repository providers (DI)
- [x] Create player providers (list, by ID, count, mutations)
- [x] Create game state providers (start, resume, finish, advance round)
- [x] Create checkpoint providers (`CheckpointNotifier` with per-second ticker)

**1.7–1.9 App Entry & UI**
- [x] Set up main.dart with Hive initialization
- [x] Build `MainMenuScreen`, `FakeNewsScreen`, `FakeErrorScreen`
- [x] Build reusable widgets: `MassiveButton`, `CustomKeypad`, `TitleBadge`, `LicenseCard`

**Deliverables:** ✅ Complete core infrastructure + UI + 157 tests passing

**Completed:** May 12, 2026

---

### ✅ Phase 2: Core Gameplay (Week 2) - COMPLETED

**Goal:** Implement BAC entry, points calculation, and basic leaderboard

#### Tasks

**2.1 BAC Calculation Utilities**
- [x] Implement Widmark formula and optimal zone calculation
- [x] Implement hybrid points system
- [x] Write comprehensive unit tests with edge cases

**2.2 Round 0 (Baseline Measurement)**
- [x] Build Round 0 flow — no feedback, no points, no titles

**2.3 Manual BAC Entry**
- [x] Build manual entry screen with custom keypad (X.XX format)
- [x] Save BAC readings to Hive with round number

**2.4 Real-time Feedback System (Round 1+)**
- [x] Build feedback screen with color-coded full-screen notifications
- [x] Show points gained/lost and DGT titles won

**2.5 License Update System**
- [x] Implement `LicenseGenerator` (dart:ui canvas pipeline)
- [x] `LicenseUpdateService` regenerates license after each round

**2.6 Checkpoint Timer System**
- [x] Per-group timer system with independent intervals
- [x] `GroupCountdownCard` with MM:SS countdown
- [x] Police siren flash animation + audio alert

**2.7 Points & Title System**
- [x] Automatic points change after BAC entry (Round 1+ only)
- [x] Per-round title evaluation via `RoundCompletionService`

**2.8 Basic Leaderboard**
- [x] Leaderboard sorted by points with medal badges for top 3
- [x] BAC progression `LineChart` with optimal zone band
- [x] Player detail screen with title chips

**Deliverables:** ✅ Working game loop + 225 tests passing

**Completed:** 2026-05-14

---

### ✅ Phase 2.5: Mechanics Revision - COMPLETED (2026-05-25)

**Goal:** Revise and correct current gameplay mechanics before advancing. Merged to `main` before Phase 3.

#### Tasks

**2.5.1 Points System Overhaul**
- [x] Replace old scale with proportional 5-tier system: **-2 / -1 / 0 / +1 / +2** (fine stays at -4)
- [x] Zone thresholds are now % of per-round optimal (±10/20/40/80%) — scales correctly across all rounds and profiles
- [x] Update `PointsCalculator.calculatePointsChange()` (remove timeDelta param, 5-tier zones)
- [x] Enforce max points cap at 15 (no exceeding on positive gains)
- [x] Update all unit tests for new logic

**2.5.2 Replace Impoundment with Fine System**
- [x] Remove all `isImpounded` logic from `PlayerProfile`, `PointsCalculator`, UI
- [x] Add `fineCount` and `moneyLost` fields to `PlayerProfile` Hive model
- [x] Fine triggered when measurement gives -4 points (>80% above per-round optimal)
- [x] Show `assets/fine.png` full-screen on fine
- [x] Track money lost: `moneyLost += 100` per fine (informational only)
- [x] Update `LicenseCard` and `LicenseGenerator` (remove "IMPOUNDED" overlay)

**2.5.3 DGT Title Logic Updates**
- [x] `itvPassed`: new logic → was out of zone last round AND back in zone this round ("Redemption")
- [x] `vehiculoHibrido`: marked TBD (BAC drops implausible in 5h party window)
- [x] Titles are **cosmetic only** — no gameplay impact
- [x] Unit tests updated

**2.5.4 Leaderboard Tiebreaker**
- [x] `PointsCalculator.calculatePerfectionScore()` added (avg + variance of deviation from per-round optimal)
- [x] `sortedLeaderboardProvider` uses perfection score as tiebreaker
- [x] Leaderboard reactivity fix

**2.5.5 OS Push Notifications for Checkpoint Alerts**
- [x] `flutter_local_notifications` dependency added
- [x] Android/iOS platform permissions configured
- [x] Notification triggered when checkpoint group's turn begins
- [x] Sound: `assets/sound/policia_control.mp3` registered in `pubspec.yaml`

**2.5.6 Debug Skip Button**
- [x] Debug skip button in checkpoint screen, gated behind `kDebugMode`

**2.5.7 BrAC Calculator Proportional Zones**
- [x] Zone detection updated to proportional % of per-round optimal (replaces absolute ±0.2/±0.4 mg/L)
- [x] `isNeutralZone()` and `isFarFromOptimal()` added to `BACCalculator`
- [x] BAC progression graph uses proportional band

**2.5.8 Round-Robin Auto-Advance Removal**
- [x] Removed `Timer`-based auto-advance from `RoundRobinScreen`
- [x] Player manually advances after confirming each BAC entry

**Deliverables:** All complete — 0 analyzer issues, all tests passing

---

### 🚀 Phase 3: Advanced Features (Week 3)

**Goal:** Complete the game loop with OCR, full round-robin audit, license viewing, and game end flow

#### Tasks

**3.1 OCR Camera Integration ("El Radar")**
- [ ] Set up ML Kit text recognition
- [ ] Build camera OCR screen (`lib/features/breathalyzer/presentation/camera_ocr_screen.dart`)
- [ ] Implement OCR service with confidence scoring (auto-confirm if >90%)
- [ ] Implement fallback to manual entry
- [ ] Handle edge cases (poor lighting, angles, multiple numbers)
- [ ] Write tests with mock camera data

**3.2 Round-Robin Flow ("El Retén") — Audit & Complete**
- [ ] Audit current implementation — identify what is done vs. missing
- [ ] No auto-advance: player manually moves to next after confirming entry
- [ ] Ensure progress indicator is accurate ("3/8 players logged")
- [ ] Write/update integration tests

**3.3 Graph Zone Visualization**
- [ ] Add zone bands to BAC progression graph: +2 (green), +1 (yellow), 0 (gray), -1 (orange), -2 (blue)
- [ ] Fine zone (-4) not shown on graph since it's already indicated by the Multa icon
- [ ] Zones should be round-aware (wider for rounds 1-2, standard for rounds 3+)
- [ ] Update `LineChart` in player detail screen with zone bands

**3.4 Last Measurement Display**
- [ ] Show last measurement on "Clasificación" (Carnet por Puntos) screen
- [ ] Display format: "Último registro: 0.XX mg/L - Ronda N"
- [ ] Update when keypad is open (already shown in "Detalle del Conductor")
- [ ] Ensure "Último registro" is visible and prominent

**3.5 Keypad Confirmation**
- [ ] Add confirmation step to keypad before submitting BAC reading
- [ ] Show "Confirmar" button after entering value
- [ ] Allow user to go back and re-enter if incorrect
- [ ] Prevent accidental submissions

**3.6 Siren Audio Fix**
- [ ] Register `assets/sound/` in `pubspec.yaml`
- [ ] Uncomment `AudioPlayer` call in `SirenAlertOverlay`
- [ ] Test audio on physical device

**3.7 DGT Title System — Finalize**
- [ ] Complete all 5 per-round title evaluators (including TBD vehiculoHibrido replacement)
- [ ] Define final replacement title for `vehiculoHibrido` with team
- [ ] Display title badges on leaderboard with counters
- [ ] Write unit tests for all title logic

**3.8 License Viewing**
- [ ] Build full-screen license view screen (tap from leaderboard)
- [ ] Show current license image with all badges
- [ ] Add pinch-to-zoom functionality
- [ ] Write widget tests

**3.9 Game State Recovery**
- [ ] Implement game recovery provider
- [ ] Check Hive for existing game state on app launch
- [ ] Resume timer from saved state
- [ ] Write integration tests for crash recovery

**3.10 Player Management (Edit & Delete)**
- [ ] Add swipe-to-delete on `LicenseCard` in the player list
- [ ] Add "Editar Conductor" screen (reuse `PlayerRegistrationScreen` in edit mode)
- [ ] Confirmation dialog before delete
- [ ] Write widget tests

**3.11 "Finish Game" Button (Post-Round 5)**
- [ ] Add "Finish Game" button accessible when a game is in progress (main menu or game screen)
- [ ] Button only enabled after Round 5 is complete (minimum rounds requirement)
- [ ] Confirmation dialog → navigate to Final Ceremony
- [ ] Clear game state on "Return to Menu"
- [ ] Display message: "Minimum 5 rounds completed. Ready to finish?"

**3.12 BAC Curve Calibration System**
- [ ] Add settings screen accessible from main menu
- [ ] Implement curve multiplier setting (range: 0.80 to 1.20, default: 1.00)
- [ ] Multiplier adjusts all optimal BAC targets proportionally
- [ ] Setting can only be changed between rounds (not during active round)
- [ ] Display warning: "Curve adjustment affects all players equally. No points will be refunded."
- [ ] Persist multiplier setting in Hive
- [ ] Update `BACCalculator.calculateOptimalBrAC()` to apply multiplier
- [ ] Add unit tests for multiplier logic
- [ ] UI shows current multiplier value (e.g., "Curva: 0.95x - Menos agresiva")

**Deliverables:**
- ✅ Working OCR camera integration
- ✅ Audited and complete round-robin flow
- ✅ Graph zone visualization with round-aware bands
- ✅ Last measurement display on Clasificación screen
- ✅ Keypad confirmation step to prevent errors
- ✅ Siren audio working
- ✅ All 5 DGT titles finalized
- ✅ Full-screen license viewing
- ✅ Game state recovery
- ✅ Player edit & delete UI
- ✅ "Finish Game" accessible after Round 5
- ✅ BAC curve calibration system
- ✅ All tests passing

**Estimated Completion:** End of Week 3

---

### 🔥 Phase 4: Firebase & Web Frontend (New Phase — Josema Lead)

**Goal:** Add real-time Firebase sync and a companion web frontend for the leaderboard display screen

**⚠️ Offline-First Constraint:** The app must work fully without internet. Firebase writes only happen when connectivity is available. No feature should break if Firebase is unreachable.

#### Tasks

**4.1 Firebase Setup**
- [ ] Add `firebase_core`, `cloud_firestore` dependencies
- [ ] Configure Firebase project (Android only initially)
- [ ] Implement connectivity check before any Firestore write
- [ ] Write Firebase service with offline-first wrapper

**4.2 Firestore Data Schema**

*Players collection:*
```
players/{unique_id}
  name: String
  surname: String
  photoUrl: String (Firebase Storage URL)
  points: int
  pointsHistory: List<int>        # points after each round
  bacHistory: List<double>        # BAC readings per round
  fineCount: int
  moneyLost: int
  timestamp: Timestamp
```

*Notifications collection:*
```
notifications/{id}
  text: String
  imageUrl: String?               # optional
  timestamp: Timestamp
  status: String                  # "pending" | "read"
```

**4.3 App → Firebase Sync**
- [ ] Sync player data after each round (points, BAC, fines)
- [ ] Upload player photo to Firebase Storage on registration
- [ ] Auto-sync Notification writes from in-app events (new fine, streaks, etc.)

**4.4 In-App Notification Sender**
- [ ] Build notification compose screen (custom text, optional image)
- [ ] Predefined notification templates:
  - New fine issued
  - Player on streak (3+ rounds over the line)
  - MOAB alert (Mother Of All Beers — extended streak, MW joke reference)
  - Congratulations on zone entry
- [ ] Writing a notification = writing to Firestore `notifications` collection

**4.5 Web Frontend (Leaderboard Screen)**
- [ ] Real-time leaderboard with player stats (points, BAC, fines)
- [ ] Top 3 medals (🥇🥈🥉) prominently displayed
- [ ] Notification ticker at top: each notification shows for 30s–1min
  - Visual countdown bar (left to right) showing remaining display time
  - Auto-advances to next notification
- [ ] Sound effects: on leaderboard update, on new notification
- [ ] End-of-game summary view: top 3, Environmental Distinctives, most titles collected
- [ ] Auto-reload when Firestore data changes (real-time listener)

**Deliverables:**
- ✅ Firebase integration with offline-first behavior
- ✅ Real-time player sync after each round
- ✅ In-app notification sender (custom + predefined)
- ✅ Web frontend leaderboard with notification ticker
- ✅ App works fully without internet

**Estimated Completion:** Parallel to / after Phase 3

---

### 🎨 Phase 5: Polish & Release (formerly Phase 4)

**Goal:** Final UX polish, ceremony animations, and release preparation

#### Tasks

**5.1 Final Ceremony Screen**
- [ ] Build final ceremony screen (triggered by "Finish Game" from Phase 3)
- [ ] Top 3 leaderboard reveal with confetti
- [ ] Environmental Distinctive reveal: envelope animations for top 5 highest BAC ("Los más contaminantes 🏭")
- [ ] DGT Title Collector reveal ("El Coleccionista de Títulos")
- [ ] "Return to Menu" + "View All Licenses" buttons

**5.2 License Export System**
- [ ] Export single license to gallery
- [ ] Export all licenses as batch
- [ ] Write unit tests

**5.3 Splash / Landing Screen**
- [ ] Build full-screen DGT-blue splash screen on cold launch
- [ ] DGV logo centered, white city-skyline silhouette
- [ ] "Acceder" `MassiveButton` → `MainMenuScreen`
- [ ] Auto-skip after 3s

**5.4 App Branding & Identity**
- [ ] Replace in-app header text with `assets/dgv_logo.png`
- [ ] Configure `flutter_launcher_icons` with `assets/logo_app.png`
- [ ] Apply branding consistently

**5.5 BAC Progression Graphs Audit**
- [ ] Confirm `fl_chart` BAC graph is fully implemented (may already be done)
- [ ] Ensure Round 0 baseline and optimal zone band are correct

**5.6 Visual Style Mod**
- [ ] Option to switch UI style: rounded → boxy (border radius adjustments)
- [ ] Font selection (2–3 options)

**5.7 Checkpoint Audio Alert**
- [ ] Decide on audio delivery strategy for checkpoint sound (`policia_control.mp3`):
  - Option A: Play sound in-app via `audioplayers`/`just_audio` when app is in foreground (no OS notification sound)
  - Option B: Firebase-triggered notification from a backend/cloud function so the OS delivers the sound natively
  - Option C: Web frontend (Phase 4) acts as the "speaker host" — receives a Firestore write and plays the sound through browser audio API on a connected device
- [ ] Current state: OS notification fires correctly with default system sound; custom sound blocked by Android channel caching behaviour

**5.8 Comprehensive Testing**
- [ ] Achieve 80%+ code coverage
- [ ] Test all features on physical devices
- [ ] Test persistent state (app restart, crash recovery)
- [ ] Fix all bugs discovered during testing
- [ ] Performance optimization (60fps animations)

**5.8 App Size Optimization**
- [ ] Audit APK with `flutter build apk --analyze-size`
- [ ] Enable `--split-per-abi`
- [ ] Replace large PNGs with WebP (target <200 KB per image)
- [ ] Target: APK download size < 40 MB per ABI

**5.9 Documentation & Release**
- [ ] Update all documentation
- [ ] Build release APK
- [ ] Create GitHub release (v1.0.0)
- [ ] Set up Firebase App Distribution

**Deliverables:**
- ✅ Final ceremony with top 3 + Environmental Distinctives envelopes
- ✅ License export system
- ✅ Splash screen + app branding
- ✅ BAC graphs confirmed
- ✅ 80%+ test coverage
- ✅ Release APK on GitHub

**Estimated Completion:** End of Week 4 (after Phase 4 Firebase)

---

## 🔮 Future Enhancements (Post-v1.0.0)

### v1.1.0 - Analytics & Export
- [ ] Historical game statistics
- [ ] Export game summary as image
- [ ] Personal BAC trends over time

### v1.2.0 - Insights
- [ ] Leaderboard across multiple games
- [ ] Cloud backup of game history
- [ ] Web version for desktop

---

## 📊 Progress Tracking

### Overall Progress
- **Phase 0:** ✅ 100% Complete
- **Phase 1:** ✅ 100% Complete
- **Phase 2:** ✅ 100% Complete
- **Phase 2.5:** 🚧 In Progress (mechanics revision)
- **Phase 3:** ⏳ Planned
- **Phase 4:** ⏳ Planned (Firebase & Web — Developer C)
- **Phase 5:** ⏳ Planned (Polish & Release)

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
| Manual BAC Entry | ✅ Complete | 100% |
| Round-Robin Flow | ✅ Complete (needs audit) | 100% |
| Feedback Screen | ✅ Complete | 100% |
| Checkpoint Timer UI | ✅ Complete | 100% |
| Points System UI | ✅ Complete | 100% |
| Leaderboard | ✅ Complete | 100% |
| BAC Graphs | ✅ Complete | 100% |
| Fake License Generation | ✅ Complete | 100% |
| Points System (Simplified) | 🚧 Phase 2.5 | 0% |
| Fine System (replaces impoundment) | 🚧 Phase 2.5 | 0% |
| DGT Title Logic Update | 🚧 Phase 2.5 | 0% |
| Leaderboard Reactivity Fix | 🚧 Phase 2.5 | 0% |
| OS Push Notifications | 🚧 Phase 2.5 | 0% |
| Debug Skip Button | 🚧 Phase 2.5 | 0% |
| OCR Camera | ⏳ Phase 3 | 0% |
| License Viewing | ⏳ Phase 3 | 0% |
| Game State Recovery | ⏳ Phase 3 | 0% |
| Player Edit & Delete UI | ⏳ Phase 3 | 0% |
| Finish Game Button | ⏳ Phase 3 | 0% |
| Firebase Integration | ⏳ Phase 4 | 0% |
| Web Frontend | ⏳ Phase 4 | 0% |
| Final Ceremony | ⏳ Phase 5 | 0% |
| Splash / Landing Screen | ⏳ Phase 5 | 0% |
| App Branding | ⏳ Phase 5 | 0% |
| App Size Optimization | ⏳ Phase 5 | 0% |

---

## 🤝 Collaboration Strategy

### Developer A — Javier (Core Infrastructure) - ✅ PHASES 1-2 COMPLETE
- ✅ All dependencies and project setup
- ✅ Complete theme system, constants, domain models
- ✅ All business logic utilities, data layer, Riverpod providers
- 🚧 **Phase 2.5:** Points/fine system overhaul, model changes, tiebreaker logic
- 🔜 **Phase 4 support:** Firebase architecture decisions, offline-first strategy

### Developer B — Kristian (UI & Screens) - ✅ PHASES 1-2 COMPLETE
- ✅ All screens, custom widgets, animations
- ✅ Checkpoint timer UI, leaderboard, player detail, license generation
- 🚧 **Phase 2.5:** Fine UI (fine.png screen), debug button, notification UI
- 🔜 **Phase 3:** OCR screen, license viewing, final ceremony screen
- 🔜 **Phase 5:** Splash screen, app branding, visual style mod

### Developer C — Josema (Firebase & Web Frontend) - 🔜 PHASE 4 LEAD
- 🔜 **Phase 4:** Firebase setup, Firestore schema, offline-first sync
- 🔜 **Phase 4:** Web frontend (leaderboard display + notification ticker)
- 🔜 **Phase 4:** In-app notification sender UI (in coordination with Developer B)
- **Sync point:** Align with Developer A on Firestore schema before starting

### Shared Responsibilities
- Testing (all developers write tests for their features)
- Code reviews (review each other's PRs)
- Documentation updates
- Physical device testing (especially for drunk-proof UX)

---

## 📝 Notes

- This roadmap is flexible and will be updated as the project evolves
- Phase 2.5 **must be complete and on `main`** before Phase 3 starts — it corrects the foundations
- Phase 4 (Firebase) can partially overlap with Phase 3 — Developer C works independently
- All features must have tests before being considered complete
- Physical device testing is mandatory for drunk-proof UX validation
- Update this roadmap weekly during development

---

**Last Updated:** May 25, 2026  
**Next Review:** End of Phase 2.5

**Key Changes in This Update (May 25 — Phase 2.5 planning):**
- 🆕 Added **Phase 2.5** (mechanics revision: points simplification, fines, title logic, notifications)
- 🆕 Added **Phase 4** (Firebase + Web Frontend, Developer C lead)
- 📋 Renamed old **Phase 4 → Phase 5** (Polish & Release)
- 🗑️ Removed 3 Grand Prizes as separate awards — Leaderboard is the sole source of truth
- 🗑️ Removed impoundment system — replaced with Fine system
- 🗑️ Removed Round-Robin auto-advance — manual progression only
- 🗑️ Removed from Future Enhancements: social sharing, QR join, cross-device sync, avatar upload, configurable intervals, theme customization, BAC thresholds per player, achievement system, cross-game leaderboard, iOS, Bluetooth, WebSockets
- 📋 Moved OS push notifications from Future → Phase 2.5 (critical)
- 📋 Moved "Finish Game" button from Phase 4 → Phase 3
- 👥 Added **Developer C (Josema)** for Phase 4 — Firebase & Web Frontend
