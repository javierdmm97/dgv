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

**Deliverables:** All complete — 0 analyzer issues, 221 tests passing

**Completed:** May 25, 2026

---

### ✅ Phase 3: Advanced Features (Week 3) — COMPLETED (2026-05-30)

**Goal:** Complete the game loop with full round-robin audit, license viewing, player management, and game end flow

**Branch:** `feature/phase_3` | **Started:** May 26, 2026 | **Completed:** May 30, 2026

#### Completed (Wave 0–1)

**Data Model & Repository Foundations**
- [x] Add `licenseBackImagePath` field to `PlayerProfile` (`@HiveField(13)`)
- [x] Create `CurveSettingsRepository` with `HiveCurveSettingsRepository` implementation
- [x] Add `curveSettingsRepositoryProvider` and `curveMultiplierProvider` to repository providers
- [x] Register `assets/sound/` in `pubspec.yaml`

**Business Logic Updates**
- [x] Apply `curveMultiplier` parameter in `BACCalculator.calculateOptimalBrAC()`
- [x] Update call sites in providers to read and pass `curveMultiplierProvider`
- [x] Fix `TitleEvaluator` — `velocidadDeCrucero` tie-breaking by alphabetical name
- [x] Fix `TitleEvaluator` — `multaPorExceso` awards all tied players; not awarded in round 1
- [x] Unit tests for all business logic changes

**Siren Audio (visual-only after Bug #3 fix)**
- [x] ~~`AudioPlayer` wired in `SirenAlertOverlay` with try/catch~~ → removed entirely (Bug #3)
- [x] `SirenAlertOverlay` is now visual-only; `policia_control.mp3` deferred to Phase 4 web frontend

**License Back-Side Generation**
- [x] Add `LicenseGenerator.generateBack()` — renders back-side PNG with round-by-round BAC table, fine log, total money lost, and perfection score
- [x] Update `LicenseUpdateService.updateForPlayer()` to generate both front and back sides

#### Completed (Waves 2–4)

**OCR Camera ("El Radar") — Discarded**
- [x] ~~`OcrService` interface and `MlKitOcrService`~~ → removed (`ocr_service.dart` deleted)
- [x] ~~`CameraOcrScreen`~~ → removed (`camera_ocr_screen.dart` deleted)
- [x] OCR feature discarded entirely; manual entry is the only BAC input method

**Keypad Confirmation Step**
- [x] Create `BacConfirmationScreen` (player name + entered value, Confirmar/Corregir)
- [x] Wire into `ManualEntryScreen` (replaces direct save)

**Graph Zone Visualization**
- [x] Replace `fl_chart` `LineChart` with custom `_LollipopChart` drawn on `Canvas` — no third-party chart dependency in use
- [x] Round-aware zone thresholds (wider sweet-spot for rounds 1–2)
- [x] Zone bands rendered directly in custom painter

**Last Measurement Display**
- [x] Create `LastMeasurementWidget` ("Último registro: 0.XX mg/L — Ronda N")
- [x] Add to leaderboard player cards

**DGT Title Badges on Leaderboard**
- [x] Display `TitleBadge` widgets with `×N` counters on each player card

**Two-Sided License Viewer**
- [x] Create `LicenseViewerScreen` — swipeable `PageView` (front + back) with `InteractiveViewer`
- [x] Wire tap from `LeaderboardScreen`

**Game State Recovery**
- [x] Create `RecoveryNotifier` provider — reads Hive on launch, routes to correct screen
- [x] Wire into `app.dart` / `main.dart`

#### Completed (Wave 5)

**3.12 Player Edit & Delete**
- [x] Swipe-to-delete (`Dismissible`) on player list in `MainMenuScreen`; hidden during active game
- [x] Edit mode in `PlayerRegistrationScreen` — pre-populate fields via `initForEdit()`, update on save
- [x] `/player-edit` route added to `AppRoutes`

**3.13 Finish Game Button & Final Ceremony Placeholder**
- [x] "Finish Game" button in `MainMenuScreen` → navigates to `FinalCeremonyScreen`
- [x] `FinalCeremonyScreen` placeholder screen with "Volver al Menú" wired via `AppRoutes.finalCeremony`

**3.14 BAC Curve Calibration Settings Screen**
- [x] `SettingsScreen` with `Slider` (0.80–1.20×), human-readable label, wired to `curveMultiplierProvider`
- [x] Settings `IconButton` in `MainMenuScreen` header → `AppRoutes.settings`

**3.15 Final Verification**
- [x] `flutter test` — all tests pass
- [x] `flutter analyze` — 0 issues
- [x] `dart run build_runner build -d` — 0 conflicts

**Deliverables:**
- ✅ Data model foundations (licenseBackImagePath, CurveSettingsRepository)
- ✅ License back-side generation
- ✅ BACCalculator curve multiplier support
- ✅ TitleEvaluator tie-breaking and multi-winner fixes
- ✅ Keypad confirmation step (`BacConfirmationScreen`)
- ✅ Custom lollipop BAC chart (replaces `fl_chart`)
- ✅ Last measurement display (`LastMeasurementWidget`)
- ✅ DGT title badges with `×N` counters on leaderboard
- ✅ Two-sided license viewer (`LicenseViewerScreen` with `InteractiveViewer`)
- ✅ Game state recovery (`RecoveryNotifier`)
- ✅ Player swipe-to-delete + edit mode
- ✅ "Finish Game" button + `FinalCeremonyScreen` placeholder
- ✅ `SettingsScreen` with BAC curve calibration slider
- ❌ OCR camera discarded (too fragile; manual entry only)
- ❌ `policia_control.mp3` removed; siren is visual-only (Bug #3); sound deferred to Phase 4

**Completed:** May 30, 2026

---

### 🔥 Phase 4: Firebase & Web Frontend (Josema Lead — ⚠️ Blocked on external project dependency)

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

### 🎨 Phase 5: Polish & Release (formerly Phase 4) — 🚧 ~95% Complete (2026-06-01)

**Goal:** Final UX polish, ceremony animations, and release preparation

#### Tasks

**5.1 Final Ceremony Screen**
- [x] Build final ceremony screen (triggered by "Finish Game" from Phase 3)
- [x] Top 3 leaderboard reveal with confetti
- [x] Environmental Distinctive reveal: envelope animations for top 5 highest BAC ("Los más contaminantes 🏭")
- [x] DGT Title Collector reveal ("El Coleccionista de Títulos")
- [x] "Return to Menu" + "View All Licenses" buttons

**5.2 License Export System**
- [ ] Export single license to gallery
- [x] Export all licenses as batch
- [ ] Write unit tests

**5.3 Splash / Landing Screen**
- [x] Build full-screen DGT-blue splash screen on cold launch
- [x] DGV logo centered, white city-skyline silhouette
- [x] "Acceder" `MassiveButton` → `MainMenuScreen`
- [x] Auto-skip after 3s

**5.4 App Branding & Identity**
- [x] Replace in-app header text with `assets/dgv_logo.png`
- [x] Configure `flutter_launcher_icons` with `assets/logo_app.png`
- [x] Apply branding consistently

**5.5 BAC Progression Graphs Audit**
- [x] `fl_chart` replaced with custom `_LollipopChart` canvas painter in `PlayerDetailScreen` — no chart lib needed
- [x] Round 0 baseline and zone bands handled correctly in custom painter

**5.6 Visual Style Mod**
- [x] Option to switch UI style: rounded → boxy (border radius adjustments)
- [x] Font selection (2–3 options)

**5.7 Checkpoint Audio Alert**
- [x] Decision made (Bug #3): `policia_control.mp3` removed from `assets/sound/` and `android/res/raw/`; in-app audio dropped entirely
- [ ] **Phase 4 owner:** web frontend plays `policia_control.mp3` via browser Audio API when the first checkpoint starts or when all players in a group have been measured — no Android channel-caching issues on the web

**5.8 Comprehensive Testing**
- [x] Achieve 80%+ code coverage
- [x] Test all features on physical devices
- [x] Test persistent state (app restart, crash recovery)
- [x] Fix all bugs discovered during testing
- [x] Performance optimization (60fps animations)

**5.8b App Size Optimization**
- [x] Audit APK with `flutter build apk --analyze-size`
- [x] Enable `--split-per-abi`
- [x] Replace large PNGs with WebP (target <200 KB per image)
- [x] Target: APK download size < 40 MB per ABI

**5.9 Documentation & Release**
- [x] Update all documentation
- [ ] Build release APK
- [ ] Create GitHub release (v1.0.0)
- [ ] Set up Firebase App Distribution

**Deliverables:**
- ✅ Final ceremony with top 3 + Environmental Distinctives envelopes
- 🚧 License export system (batch ✅; single export + unit tests pending)
- ✅ Splash screen + app branding
- ✅ BAC graphs confirmed
- ✅ 80%+ test coverage
- ✅ App size optimised (split-per-abi)
- ✅ All documentation updated
- ⏳ Release APK on GitHub (pending build)

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
- **Phase 2.5:** ✅ 100% Complete (mechanics revision — merged to main)
- **Phase 3:** ✅ 100% Complete (waves 0–5 done — May 30, 2026)
- **Phase 4:** ⏳ Blocked (Firebase & Web — Developer C — external project dependency)
- **Phase 5:** 🚧 ~95% Complete (testing, optimisation, docs done; single-license export + APK release pending)

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
| Points System (Simplified) | ✅ Complete | 100% |
| Fine System (replaces impoundment) | ✅ Complete | 100% |
| DGT Title Logic Update | ✅ Complete | 100% |
| Leaderboard Reactivity Fix | ✅ Complete | 100% |
| OS Push Notifications | ✅ Complete | 100% |
| Debug Skip Button | ✅ Complete | 100% |
| License Back-Side Generation | ✅ Phase 3 complete | 100% |
| BAC Curve Multiplier (BACCalculator) | ✅ Phase 3 complete | 100% |
| TitleEvaluator Fixes | ✅ Phase 3 complete | 100% |
| Siren Alert (visual-only, Bug #3) | ✅ Phase 3 complete | 100% |
| OCR Camera | ❌ Discarded | — |
| Keypad Confirmation Step | ✅ Phase 3 complete | 100% |
| BAC Graph (custom lollipop canvas) | ✅ Phase 3/5 complete | 100% |
| Last Measurement Display | ✅ Phase 3 complete | 100% |
| DGT Title Badges on Leaderboard | ✅ Phase 3 complete | 100% |
| License Viewing (Two-Sided) | ✅ Phase 3 complete | 100% |
| Game State Recovery | ✅ Phase 3 complete | 100% |
| Player Edit & Delete UI | ✅ Phase 3 complete | 100% |
| Finish Game Button + Ceremony Placeholder | ✅ Phase 3 complete | 100% |
| BAC Curve Calibration Settings | ✅ Phase 3 complete | 100% |
| Splash / Landing Screen | ✅ Phase 5 complete | 100% |
| App Branding (launcher icons + logo) | ✅ Phase 5 complete | 100% |
| Checkpoint Audio (`policia_control.mp3`) | ⏳ Phase 4 (web frontend) | 0% |
| Firebase Integration | ⏳ Phase 4 | 0% |
| Web Frontend | ⏳ Phase 4 | 0% |
| Final Ceremony (animations) | ✅ Phase 5 complete | 100% |
| License Export System (batch) | ✅ Phase 5 complete | 100% |
| License Export System (single) | ⏳ Phase 5 pending | 0% |
| Comprehensive Testing (80%+ coverage) | ✅ Phase 5 complete | 100% |
| App Size Optimization (split-per-abi) | ✅ Phase 5 complete | 100% |
| Documentation Update | ✅ Phase 5 complete | 100% |

---

## 🤝 Collaboration Strategy

### Developer A — Javier (Core Infrastructure) - ✅ PHASES 1-3 COMPLETE
- ✅ All dependencies and project setup
- ✅ Complete theme system, constants, domain models
- ✅ All business logic utilities, data layer, Riverpod providers
- ✅ **Phase 2.5:** Points/fine system overhaul, model changes, tiebreaker logic
- ✅ **Phase 3 (all waves):** `licenseBackImagePath`, `CurveSettingsRepository`, `BACCalculator` multiplier, `TitleEvaluator` fixes, `LicenseGenerator.generateBack()`, keypad confirmation, player edit/delete, finish game, settings screen, custom lollipop chart, OCR discarded
- 🔜 **Phase 4 support:** Firebase architecture decisions, offline-first strategy

### Developer B — Kristian (UI & Screens) - ✅ PHASES 1-2.5 COMPLETE
- ✅ All screens, custom widgets, animations
- ✅ Checkpoint timer UI, leaderboard, player detail, license generation
- ✅ **Phase 2.5:** Fine UI (fine.png screen), debug button, notification UI, Ayuda screen
- ✅ **Phase 3/5:** License viewing, splash screen, app branding, visual style mod
- 🔜 **Phase 5:** Final ceremony animations, license export

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

**Last Updated:** June 1, 2026  
**Next Review:** When Phase 4 external dependency is resolved (Firebase & Web)

**Key Changes in This Update (June 1):**
- ✅ **Phase 5 ~95% COMPLETE** — testing, optimisation, and documentation done
- ✅ **5.8 Comprehensive Testing** — 80%+ coverage, physical device testing, crash recovery, bug fixes, 60fps animations
- ✅ **5.8b App Size Optimization** — split-per-abi, WebP assets, size target met
- ✅ **5.9 Documentation** — ROADMAP, CHANGELOG, and README updated for v1.0.0 readiness
- ⏳ **Release APK / GitHub release / Firebase App Distribution** — pending (5.9 release tasks)
- 🚧 **5.2 License Export (single)** — batch export done; single-license export and unit tests remaining
- ⏳ **Phase 4** — blocked on external project dependency (Developer C / Josema)

**Key Changes in Previous Update (May 30):**
- ✅ **Phase 3 COMPLETE** — all waves 0–5 done
- ✅ Player swipe-to-delete (`Dismissible`) + edit mode (`initForEdit()`) in `PlayerRegistrationScreen`
- ✅ "Finish Game" button → `FinalCeremonyScreen` placeholder via `AppRoutes.finalCeremony`
- ✅ `SettingsScreen` with BAC curve slider (0.80–1.20×) via `AppRoutes.settings`
- ✅ **Splash screen** (`SplashScreen`) and **app branding** (launcher icons, DGV transparent logo) done — Phase 5 partially complete
- ✅ **BAC graph**: `fl_chart` replaced with custom `_LollipopChart` canvas painter — no third-party chart lib
- ❌ **OCR discarded**: `ocr_service.dart`, `camera_ocr_screen.dart`, `ocr_service_test.dart` deleted; manual entry is the only BAC input method
- ❌ **`policia_control.mp3` removed** (Bug #3): siren is visual-only; sound deferred to Phase 4 web frontend (browser Audio API)
