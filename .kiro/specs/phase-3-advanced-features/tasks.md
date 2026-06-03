# Implementation Plan: Phase 3 — Advanced Features

## Overview

Phase 3 completes the Operación DGV game loop across 12 requirements. Tasks are ordered to respect dependencies: data model changes first, then business logic, then UI, then integration wiring.

## Tasks

- [x] 1. Data model and repository foundations
  - [x] 1.1 Add `licenseBackImagePath` field to `PlayerProfile`
    - Add `@HiveField(13) @Default(null) String? licenseBackImagePath` to `PlayerProfile` Freezed factory in `lib/core/models/player_profile.dart`
    - Run `dart run build_runner build -d` to regenerate `.freezed.dart` and `.g.dart`
    - Verify `flutter analyze` reports 0 issues
    - _Requirements: 8.7_

  - [x] 1.2 Create `CurveSettingsRepository`
    - Create `lib/data/repositories/curve_settings_repository.dart` with abstract interface and `HiveCurveSettingsRepository` implementation
    - `getMultiplier()` reads from `HiveService.getSettingsBox()` with key `'curve_multiplier'`, returns `1.00` if absent
    - `saveMultiplier(double value)` writes to the same box
    - Add `@riverpod CurveSettingsRepository curveSettingsRepository(...)` provider in `lib/core/providers/repository_providers.dart`
    - Add `@riverpod Future<double> curveMultiplier(...)` provider that reads from the repository
    - _Requirements: 12.6, 12.9_

  - [x] 1.3 Register `assets/sound/` in `pubspec.yaml`
    - Add `- assets/sound/` under `flutter.assets` in `pubspec.yaml`
    - Run `flutter pub get` to verify no errors
    - _Requirements: 6.1_

- [x] 2. Business logic updates
  - [x] 2.1 Apply `Curve_Multiplier` in `BACCalculator`
    - Update `calculateOptimalBrAC(roundNumber, sex, bodySize, {double curveMultiplier = 1.0})` to multiply the raw target by `curveMultiplier`
    - **Architecture note:** The multiplier is read by Riverpod providers (e.g., `checkpointNotifierProvider`, `bacEntryProvider`) and passed as a parameter to `calculateOptimalBrAC()`. Pure utility classes (`TitleEvaluator`, `PointsCalculator`) receive the already-computed optimal value — they do NOT read the provider directly. Do not thread Riverpod into pure Dart utility classes.
    - Update call sites in providers to read `curveMultiplierProvider` and pass the value down
    - Write unit tests: `calculateOptimalBrAC` returns `rawTarget × 0.80`, `rawTarget × 1.00`, `rawTarget × 1.20`
    - _Requirements: 12.7, 12.8, 12.10_

  - [x] 2.2 Fix `TitleEvaluator` — `velocidadDeCrucero` tie-breaking
    - Update `_findClosestToOptimal` to use alphabetical name as tiebreaker when distances are equal
    - Write unit test: two players equidistant → player with earlier name wins
    - _Requirements: 7.2_

  - [x] 2.3 Fix `TitleEvaluator` — `multaPorExceso` awards all tied players
    - Replace single-winner `_findHighestSpike` with multi-winner logic that awards all players sharing the maximum spike
    - Ensure `multaPorExceso` is not awarded in round 1
    - Write unit tests: single winner; tied winners; round 1 returns no award
    - _Requirements: 7.3, 7.9_

- [x] 3. Siren audio fix
  - [x] 3.1 Uncomment `AudioPlayer` in `SirenAlertOverlay`
    - Add `AudioPlayer? _audioPlayer` field
    - Add `_playAudio()` method with try/catch that plays `assets/sound/policia_control.mp3`
    - Call `_playAudio()` in `initState`
    - Stop and dispose `_audioPlayer` in `dispose()`
    - Verify visual animation continues if audio throws
    - _Requirements: 6.2, 6.3, 6.4, 6.5_

- [x] 4. License back-side generation
  - [x] 4.1 Add `generateBack()` to `LicenseGenerator`
    - Add `static Future<String> generateBack(PlayerProfile player)` method
    - Load `assets/license/back.png` as template (600×375 canvas)
    - Draw round-by-round table: "R{N}: {bac} mg/L ({points change})" for each active reading
    - Draw fine log: "Multa {N} — Ronda {N} — 100€" for each fine
    - Draw total money lost and perfection score
    - Save as `license_back_{player.id}.png` in app documents directory
    - _Requirements: 8.5, 8.6_

  - [x] 4.2 Update `LicenseUpdateService` to generate both sides
    - Call both `LicenseGenerator.generate()` and `LicenseGenerator.generateBack()`
    - Persist both paths via `player.copyWith(licenseImagePath: ..., licenseBackImagePath: ...)`
    - _Requirements: 8.8_

- [x] 5. OCR camera integration
  - [x] 5.1 Create `OcrService` interface and `MlKitOcrService`
    - Create `lib/features/breathalyzer/data/ocr_service.dart` with `OcrService` abstract interface and `OcrCandidate` model
    - Implement `MlKitOcrService` using `google_mlkit_text_recognition`
    - Filter recognised text with regex `\d\.\d{2}`, parse to `double`, derive confidence from ML Kit block score
    - When multiple candidates, return all sorted by confidence descending
    - Write unit tests with `FakeOcrService`: high confidence auto-confirm; low confidence manual; no match timeout
    - _Requirements: 1.1, 1.2, 1.6, 1.10_

  - [x] 5.2 Create `CameraOcrScreen`
    - Create `lib/features/breathalyzer/presentation/camera_ocr_screen.dart`
    - Accept `PlayerProfile player` and `OcrService ocrService` (defaults to `MlKitOcrService`)
    - Live camera preview with `CameraController`; capture frame every 500 ms
    - 10-second timeout `Timer` → navigate to `ManualEntryScreen` on expiry
    - On confidence > 0.90: push `BacConfirmationScreen`
    - On confidence ≤ 0.90: show detected value + "Confirmar" / "Reintentar" buttons
    - On camera unavailable/permission denied: show error dialog → navigate to `ManualEntryScreen` after acknowledgment
    - Bounding box overlay via `CustomPaint`
    - "Entrada manual" `MassiveButton` always visible (minHeight 80)
    - _Requirements: 1.1, 1.3, 1.4, 1.5, 1.7, 1.8, 1.9_

- [x] 6. Keypad confirmation step
  - [x] 6.1 Create `BacConfirmationScreen`
    - Create `lib/features/breathalyzer/presentation/bac_confirmation_screen.dart`
    - Accept `BacConfirmationArgs(PlayerProfile player, double enteredValue)`
    - Display player name at 24sp bold and entered value at 48sp bold
    - "Confirmar" `MassiveButton` (minHeight 80): triggers save, pops with `BACEntryResult`
    - "Corregir" `MassiveButton` (minHeight 80, secondary style): pops with `null`
    - No Hive writes until "Confirmar" is tapped
    - Write widget tests: Confirmar saves; Corregir returns null; values displayed at correct sizes
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

  - [x] 6.2 Wire `BacConfirmationScreen` into `ManualEntryScreen` and `CameraOcrScreen`
    - Update `ManualEntryScreen` to push `BacConfirmationScreen` instead of saving directly
    - If `BacConfirmationScreen` returns `null`, re-show keypad with previous value
    - `CameraOcrScreen` pushes `BacConfirmationScreen` for low-confidence results
    - _Requirements: 5.7_

- [x] 7. Graph zone visualization
  - [x] 7.1 Add zone bands to BAC graph in `PlayerDetailScreen`
    - Create `buildZoneBands(double optimal, int roundNumber)` helper function
    - Use wider sweet-spot (0.20) for rounds 1–2, standard (0.10) for rounds 3+; fall back to standard if detection fails
    - Convert to `HorizontalRangeAnnotation` entries in `fl_chart` `LineChartData`
    - Fill opacity ≤ 0.15 for all bands
    - Existing optimal line and BrAC line rendered on top
    - Handle single-reading edge case: set `minX = 0`, `maxX = 2`
    - Write widget tests: 5 zone bands present; opacity ≤ 0.15; single-reading renders without error
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

- [x] 8. Last measurement display
  - [x] 8.1 Create `LastMeasurementWidget`
    - Create `lib/widgets/last_measurement_widget.dart`
    - Display `Último registro: 0.XX mg/L — Ronda N` using the player's most recent active reading
    - Font size ≥ 16sp; `DGTColors.textSecondary` color
    - Return `SizedBox.shrink()` when player has no readings
    - Write widget tests: correct text format; hidden when no readings; updates reactively
    - _Requirements: 4.1, 4.2, 4.5, 4.6_

  - [x] 8.2 Add `LastMeasurementWidget` to leaderboard player cards
    - Place `LastMeasurementWidget` inside `LicenseCard` or immediately below it in `LeaderboardScreen`
    - Verify it is visible without scroll
    - _Requirements: 4.3, 4.4_

- [x] 9. DGT title badges on leaderboard
  - [x] 9.1 Display title badges with counters on `LeaderboardScreen`
    - Add title badge row to each player card showing `TitleBadge` widgets with `×N` counters
    - Only show titles where `titleCounts[title] > 0`
    - Write widget test: badges visible with correct counters
    - _Requirements: 7.7_

- [x] 10. Two-sided license viewer
  - [x] 10.1 Create `LicenseViewerScreen`
    - Create `lib/features/fake_id/presentation/license_viewer_screen.dart`
    - Accept `PlayerProfile player`
    - `PageView` with 2 pages, each wrapped in `InteractiveViewer(minScale: 1.0, maxScale: 4.0)`
    - Page 1: `Image.file(player.licenseImagePath)` (front)
    - Page 2: `Image.file(player.licenseBackImagePath)` if non-null, else `_DynamicBackWidget(player)` built from readings
    - Page indicator (two dots) showing current page
    - Write widget tests: two pages; page indicator; null back path shows dynamic fallback without crash
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.9, 8.10_

  - [x] 10.2 Wire `LicenseViewerScreen` from `LeaderboardScreen`
    - Tap on player card navigates to `LicenseViewerScreen`
    - _Requirements: 8.1_

- [x] 11. Game state recovery
  - [x] 11.1 Create `RecoveryNotifier` provider
    - Create `lib/core/providers/recovery_provider.dart` with `@riverpod RecoveryNotifier`
    - On `build()`: read `GameStateRepository`, determine `RecoveryRoute` (mainMenu / checkpoint / leaderboard)
    - Restore checkpoint timer via `checkpointNotifierProvider.notifier.restoreFromState(gameState)` when game is in progress
    - _Requirements: 9.1, 9.2, 9.3, 9.4_

  - [x] 11.2 Wire `RecoveryNotifier` into app launch
    - Update `app.dart` or `main.dart` to watch `recoveryNotifierProvider` and route on first build
    - Write integration tests: pre-seeded Hive → correct route + correct round; empty Hive → main menu
    - _Requirements: 9.5, 9.6, 9.7_

- [ ] 12. Player edit and delete
  - [~] 12.1 Add swipe-to-delete to player list in `MainMenuScreen`
    - Wrap each `LicenseCard` in `Dismissible` with `endToStart` direction
    - `confirmDismiss` shows `AlertDialog` "¿Eliminar a [Name]?" with "Eliminar" / "Cancelar"
    - On confirm: call `playerNotifierProvider.notifier.delete(player.id)`
    - Hide swipe-to-delete when game is in progress
    - Write widget tests: dialog shown; cancel resets; confirm removes player
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.9_

  - [~] 12.2 Add edit mode to `PlayerRegistrationScreen`
    - Add optional `PlayerProfile? editingPlayer` parameter
    - When non-null: pre-populate all fields, change title to "Editar Conductor"
    - On save: call `playerRepository.update()` + `LicenseUpdateService.updateForPlayer()`
    - Add "Editar" icon button to `LicenseCard` in player list (hidden during active game)
    - Write widget tests: fields pre-populated; save updates record; cancel leaves unchanged
    - _Requirements: 10.5, 10.6, 10.7, 10.8, 10.9_

- [ ] 13. Finish Game button and Final Ceremony plac eholder
  - [~] 13.1 Add `FinishGameButton` to `MainMenuScreen`
    - Show `MassiveButton('Finalizar Partida')` when game is in progress
    - Disabled (grayed out) when `currentRound < 5`
    - Enabled when `currentRound >= 5` and all players in current round measured
    - On tap: show `AlertDialog` "¿Finalizar la partida? Mínimo 5 rondas completadas." with "Finalizar" / "Cancelar"
    - On confirm: navigate to `FinalCeremonyScreen`
    - Write widget tests: disabled below round 5; enabled at round 5; dialog shown; navigation occurs
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

  - [~] 13.2 Create `FinalCeremonyScreen` placeholder
    - Create `lib/features/main_menu/presentation/final_ceremony_screen.dart`
    - Display "Ceremonia Final — Próximamente"
    - "Volver al Menú" `MassiveButton` (minHeight 80): clears game state via `GameStateRepository.clear()`, then navigates to main menu only after successful clear
    - On clear: all game-related screens reflect cleared state
    - Write widget test: button navigates to main menu; game state cleared
    - _Requirements: 11.6, 11.7, 11.8_

- [ ] 14. BAC Curve Calibration settings screen
  - [~] 14.1 Create `SettingsScreen`
    - Create `lib/features/main_menu/presentation/settings_screen.dart`
    - `Slider` with `min: 0.80`, `max: 1.20`, `divisions: 8`, default `1.00`
    - Human-readable label: "Curva: 1.00× — Estándar" / "Curva: 0.95× — Menos agresiva" / etc.
    - Warning text shown when multiplier ≠ 1.00
    - Disabled + message "No se puede cambiar la curva durante una ronda activa." when `currentRound >= 1`
    - Save button persists via `CurveSettingsRepository`
    - Write widget tests: slider range; label text; disabled during active game; warning shown
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6_

  - [~] 14.2 Add Settings icon to `MainMenuScreen`
    - Add settings `IconButton` in app bar or main menu header
    - Navigates to `SettingsScreen`
    - _Requirements: 12.1_

- [~] 15. Final verification
  - Run `flutter test` — all tests pass
  - Run `flutter analyze` — 0 issues
  - Run `dart run build_runner build -d` — 0 conflicts
  - Verify `assets/sound/` is registered and audio plays on physical device

## Notes

- Run `dart run build_runner build -d` after task 1.1 (PlayerProfile model change) before any other tasks that use PlayerProfile
- Tasks 2.x (business logic) can be done in parallel with tasks 3–4 (siren, license back)
- Tasks 5–6 (OCR, confirmation) depend on task 6.1 being done before 6.2
- Tasks 7–9 (graph, last measurement, title badges) are independent UI tasks
- Tasks 10–11 (license viewer, recovery) depend on tasks 1.1 and 4.x
- Tasks 12–14 (edit/delete, finish game, settings) are independent of each other

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.3"] },
    { "id": 1, "tasks": ["2.1", "2.2", "2.3", "3.1", "4.1"] },
    { "id": 2, "tasks": ["4.2", "5.1", "6.1", "7.1", "8.1", "9.1"] },
    { "id": 3, "tasks": ["5.2", "6.2", "8.2", "10.1", "11.1", "12.1", "13.1", "14.1"] },
    { "id": 4, "tasks": ["10.2", "11.2", "12.2", "13.2", "14.2"] },
    { "id": 5, "tasks": ["15"] }
  ]
}
```
