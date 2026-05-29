# Requirements Document

## Introduction

Phase 3 completes the Operación DGV game loop by adding OCR camera input, a fully audited round-robin flow, rich graph zone visualization, license back-side generation and full-screen viewing, keypad confirmation, siren audio, finalized DGT title logic, game state crash recovery, player edit/delete management, a "Finish Game" end-of-game trigger, and a BAC curve calibration system.

All features must comply with the project's architecture rules: Flutter/Dart 3.0+, Riverpod 2.0+ with `@riverpod` code generation, Hive persistence, Freezed models, feature-first folder structure, `package:` imports only, `const` constructors everywhere possible, no `!` bang operator, no native keyboards for numerical input, and oversized touch targets (minHeight: 80).

---

## Glossary

- **OCR_Service**: The ML Kit text recognition service that reads BrAC values from a camera feed.
- **Camera_OCR_Screen**: The full-screen camera UI for "El Radar" OCR input mode.
- **RoundRobinScreen**: The "El Retén" sequential player measurement carousel.
- **Progress_Indicator**: The `X / N conductores medidos` bar shown during round-robin.
- **BAC_Graph**: The `fl_chart` line chart showing a player's BrAC progression over rounds.
- **Zone_Band**: A colored horizontal band on the BAC_Graph representing a scoring zone.
- **Leaderboard_Screen**: The "Carnet por Puntos" screen listing all players sorted by points.
- **Last_Measurement_Widget**: The widget displaying "Último registro: 0.XX mg/L — Ronda N" on the Leaderboard_Screen.
- **Keypad**: The custom 3×4 grid numeric input widget (`CustomKeypad`).
- **Confirmation_Step**: The intermediate screen shown after a BrAC value is entered but before it is submitted.
- **SirenAlertOverlay**: The police siren flash animation widget that also triggers audio.
- **AudioPlayer**: The `audioplayers` package instance used to play `assets/sound/policia_control.mp3`.
- **TitleEvaluator**: The utility class that awards DGT titles per round.
- **DGTTitle**: The enum of five per-round cosmetic title awards.
- **vehiculoHibrido**: The DGT title whose replacement logic is TBD; stubbed until the team defines it.
- **LicenseGenerator**: The `dart:ui` canvas pipeline that renders license PNG files.
- **LicenseUpdateService**: The service that calls LicenseGenerator and persists the updated path.
- **License_Front**: The front-side license PNG rendered from `assets/license/front.png`.
- **License_Back**: The back-side license PNG rendered from `assets/license/back.png`.
- **License_Viewer_Screen**: The full-screen swipeable PageView showing License_Front and License_Back.
- **InteractiveViewer**: The Flutter widget providing pinch-to-zoom on each license side.
- **GameStateRepository**: The Hive-backed repository that persists and loads `GameState`.
- **Recovery_Provider**: The Riverpod provider that checks Hive on app launch and routes accordingly.
- **PlayerRegistrationScreen**: The existing player creation screen, reused in edit mode.
- **Edit_Screen**: `PlayerRegistrationScreen` opened in edit mode for an existing player.
- **Finish_Game_Button**: The button that triggers end-of-game flow after Round 5 is complete.
- **Final_Ceremony_Screen**: The placeholder screen navigated to after confirming game end.
- **Settings_Screen**: The screen accessible from the main menu for BAC curve calibration.
- **Curve_Multiplier**: A `double` in range [0.80, 1.20] that scales all optimal BrAC targets.
- **BACCalculator**: The utility class computing per-round optimal BrAC targets.
- **CurveSettingsRepository**: The Hive-backed storage for the Curve_Multiplier value.
- **PlayerProfile**: The Freezed + Hive model holding all player game data.
- **BACReading**: The Freezed model for a single breathalyzer measurement.
- **GameState**: The Freezed + Hive model holding current round, timer state, and player references.
- **DGTColors**: The project color palette class.

---

## Requirements

---

### Requirement 1: OCR Camera Integration ("El Radar")

**User Story:** As a game operator, I want to point the phone camera at a breathalyzer display and have the BrAC value read automatically, so that data entry is faster and less error-prone during a party.

#### Acceptance Criteria

1. WHEN the operator opens the Camera_OCR_Screen, THE OCR_Service SHALL activate the device camera and begin continuous text recognition using Google ML Kit.
2. WHEN the OCR_Service detects a numeric value matching the pattern `\d\.\d{2}` (e.g., `0.45`) in the camera frame, THE OCR_Service SHALL extract that value and associate a confidence score between 0.0 and 1.0.
3. WHEN the OCR_Service produces a confidence score greater than 0.90, THE Camera_OCR_Screen SHALL auto-confirm the detected value and navigate to the Confirmation_Step without requiring manual user action.
4. WHEN the OCR_Service produces a confidence score of 0.90 or below, THE Camera_OCR_Screen SHALL display the detected value with a "Confirmar" button and a "Reintentar" button, requiring explicit user confirmation before proceeding.
5. IF the OCR_Service fails to detect any valid numeric value within 10 seconds of camera activation, THEN THE Camera_OCR_Screen SHALL display a fallback prompt and navigate to the manual entry screen.
6. IF the camera frame contains multiple candidate numeric values, THEN THE OCR_Service SHALL select the value with the highest confidence score and discard the others.
7. IF the device camera is unavailable or permission is denied, THEN THE Camera_OCR_Screen SHALL display an error message and, after the user acknowledges the error, navigate to the manual entry screen.
8. WHEN the OCR_Service is active, THE Camera_OCR_Screen SHALL display a live viewfinder with a highlighted bounding box around any detected numeric candidate.
9. THE Camera_OCR_Screen SHALL provide a "Entrada manual" button with minHeight 80 that navigates to the manual entry screen at any time.
10. THE OCR_Service SHALL be testable with mock camera data by accepting an injectable text recognition interface.

---

### Requirement 2: Round-Robin Flow Audit and Completion ("El Retén")

**User Story:** As a game operator, I want the round-robin measurement flow to be complete and reliable, so that every player is measured exactly once per round with accurate progress tracking.

#### Acceptance Criteria

1. THE RoundRobinScreen SHALL display the current player's LicenseCard and a "Medir a [Name]" button with minHeight 80 as the primary action.
2. WHEN a player's measurement is confirmed, THE RoundRobinScreen SHALL mark that player as measured and update the Progress_Indicator before presenting the next unmeasured player.
3. THE Progress_Indicator SHALL display the text `X / N conductores medidos` where X is the count of measured players and N is the total player count in the group, and SHALL render a `LinearProgressIndicator` with value `X / N`.
4. THE RoundRobinScreen SHALL NOT auto-advance to the next player; the operator SHALL manually tap the "Medir" button to initiate each measurement.
5. WHEN all players in the group have been measured and the current round is 0, THE RoundRobinScreen SHALL call `gameStateNotifier.advanceRound()` and navigate to the Leaderboard_Screen.
6. WHEN all players in the group have been measured and the current round is 1 or greater, THE RoundRobinScreen SHALL pop back to the checkpoint screen.
7. WHEN a measurement for round 1 or greater results in a fine (points change of -4), THE RoundRobinScreen SHALL navigate to the fine screen before navigating to the feedback screen. THE RoundRobinScreen SHALL NOT navigate to the fine screen when the measurement result is not a fine.
8. THE RoundRobinScreen SHALL skip already-measured players when cycling through the player list, ensuring no player is measured twice in the same round.
9. THE RoundRobinScreen integration tests SHALL verify that the progress indicator reaches `N / N` after all players are measured and that navigation to the correct next screen occurs.

---

### Requirement 3: Graph Zone Visualization

**User Story:** As a player, I want to see colored zone bands on my BrAC progression graph, so that I can visually understand which scoring zone each of my readings fell into.

#### Acceptance Criteria

1. THE BAC_Graph SHALL render five Zone_Bands as horizontal filled areas between the following BrAC boundaries for each round:
   - **+2 zone** (green, `DGTColors.green`): between `optimal × 0.90` and `optimal × 1.10`
   - **+1 zone** (yellow, `DGTColors.yellow`): between `optimal × 0.80` and `optimal × 0.90`, and between `optimal × 1.10` and `optimal × 1.20`
   - **0 zone** (gray, `DGTColors.textSecondary`): between `optimal × 0.60` and `optimal × 0.80`, and between `optimal × 1.20` and `optimal × 1.40`
   - **-1 zone** (orange, `DGTColors.orange`): between `optimal × 0.20` and `optimal × 0.60`, and between `optimal × 1.40` and `optimal × 1.80`
   - **-2 zone** (blue, `DGTColors.primary` at reduced opacity): below `optimal × 0.20`
2. THE BAC_Graph SHALL NOT render a separate zone band for the fine zone (-4); the Multa icon on the LicenseCard already indicates fines.
3. WHEN the current round is 1 or 2, THE BAC_Graph SHALL render Zone_Bands using the wider thresholds defined in `AppConstants` for early rounds (rounds 1–2 use `zoneClosePct = 0.20` as the sweet-spot boundary instead of `zoneSweetSpotPct = 0.10`). IF early threshold detection fails, THE BAC_Graph SHALL fall back to standard thresholds to ensure zone bands always appear.
4. WHEN the current round is 3 or greater, THE BAC_Graph SHALL render Zone_Bands using the standard proportional thresholds from `AppConstants`.
5. THE Zone_Bands SHALL be rendered with a fill opacity of 0.15 or less so that the BrAC line and optimal line remain clearly visible.
6. THE BAC_Graph SHALL continue to render the existing optimal line (dashed green) and the player's actual BrAC line (solid blue) on top of the Zone_Bands.
7. THE BAC_Graph SHALL render correctly when a player has only one reading (single-point chart with non-degenerate x-range).

---

### Requirement 4: Last Measurement Display on Leaderboard

**User Story:** As a player, I want to see my most recent BrAC reading and the round it was taken in on the leaderboard screen, so that I can quickly check my last result without navigating to the detail screen.

#### Acceptance Criteria

1. THE Leaderboard_Screen SHALL display a Last_Measurement_Widget for each player who has at least one BrAC reading.
2. THE Last_Measurement_Widget SHALL display the text `Último registro: 0.XX mg/L — Ronda N` where `0.XX` is the player's most recent BrAC value formatted to two decimal places and `N` is the round number of that reading.
3. THE Last_Measurement_Widget SHALL be visible within the player's LicenseCard or immediately below it without requiring any scroll or tap interaction.
4. WHEN a new BrAC reading is saved for a player, THE Last_Measurement_Widget SHALL update reactively via the Riverpod provider without requiring a screen reload.
5. THE Last_Measurement_Widget SHALL use a font size of at least 16sp and a color with sufficient contrast against the card background (contrast ratio ≥ 4.5:1).
6. IF a player has no readings, THEN THE Last_Measurement_Widget SHALL NOT be rendered for that player.

---

### Requirement 5: Keypad Confirmation Step

**User Story:** As a game operator, I want a confirmation step after entering a BrAC value on the keypad, so that accidental submissions are prevented and incorrect values can be corrected before being saved.

#### Acceptance Criteria

1. WHEN the operator taps the submit action on the Keypad, THE Confirmation_Step screen SHALL be displayed showing the entered BrAC value prominently before any data is saved. Transitioning to the Confirmation_Step screen is sufficient to satisfy this requirement.
2. THE Confirmation_Step SHALL display a "Confirmar" button with minHeight 80 that saves the BrAC reading and proceeds to the feedback flow.
3. THE Confirmation_Step SHALL display a "Corregir" button with minHeight 80 that returns the operator to the Keypad with the previously entered value pre-populated.
4. THE Confirmation_Step SHALL display the player's name and the entered value in a font size of at least 24sp.
5. THE Confirmation_Step SHALL NOT save any data to Hive while the user is on the Confirmation_Step screen; saving is only permitted after the "Confirmar" button is tapped.
6. WHEN the operator taps "Corregir", THE Keypad SHALL be presented with the previously entered value displayed so the operator can modify it.
7. THE Confirmation_Step SHALL be reachable from both the manual entry flow and the OCR flow (when OCR confidence is ≤ 0.90).

---

### Requirement 6: Siren Audio Fix

**User Story:** As a game operator, I want the police siren sound to play when a checkpoint alert fires, so that the audio-visual alert is complete and attention-grabbing.

#### Acceptance Criteria

1. THE `pubspec.yaml` SHALL declare `assets/sound/` as a registered Flutter asset directory so that all audio files in that directory are bundled with the app.
2. WHEN a checkpoint group's turn begins and the SirenAlertOverlay is displayed, THE AudioPlayer SHALL play `assets/sound/policia_control.mp3`.
3. WHEN the SirenAlertOverlay is dismissed, THE AudioPlayer SHALL stop playback if the audio is still playing.
4. IF the AudioPlayer fails to load or play the audio file, THEN THE SirenAlertOverlay SHALL continue to display the visual siren animation without crashing.
5. THE AudioPlayer call in SirenAlertOverlay SHALL be uncommented and active in the production code path (not gated behind `kDebugMode`).

---

### Requirement 7: DGT Title System Finalization

**User Story:** As a player, I want all five DGT title evaluators to be complete and my earned title badges to be visible on the leaderboard, so that the cosmetic title system is fully functional.

#### Acceptance Criteria

1. THE TitleEvaluator SHALL implement all five per-round title evaluators: `velocidadDeCrucero`, `multaPorExceso`, `lDePracticas`, `vehiculoHibrido`, and `itvPassed`.
2. THE TitleEvaluator SHALL award `velocidadDeCrucero` to the player whose BrAC reading is closest to their per-round optimal BrAC in the current round. WHEN two players tie with the same distance, THE TitleEvaluator SHALL award the title to the player who appears first in the sorted player list (alphabetical by name as tiebreaker).
3. THE TitleEvaluator SHALL award `multaPorExceso` to all players tied with the highest positive BrAC delta (spike) from the previous round; this title SHALL NOT be awarded in round 1 (no previous round exists).
4. THE TitleEvaluator SHALL award `lDePracticas` to the player with the lowest BrAC reading in the current round.
5. THE TitleEvaluator SHALL award `itvPassed` to every player who had a negative points result in the previous round AND whose current round reading falls within the sweet-spot zone (±10% of optimal).
6. WHERE the team has defined a replacement for `vehiculoHibrido`, THE TitleEvaluator SHALL implement that replacement logic; until the replacement is defined, THE TitleEvaluator SHALL return no awards for `vehiculoHibrido`.
7. THE Leaderboard_Screen SHALL display each player's earned title badges with their accumulation counters (e.g., `🟢 ×3`) within the player's LicenseCard.
8. THE TitleEvaluator unit tests SHALL cover all five evaluators with at least one passing case and one non-awarding case per evaluator.
9. THE TitleEvaluator unit tests SHALL verify that `multaPorExceso` is not awarded in round 1.

---

### Requirement 8: Two-Sided License Viewing

**User Story:** As a player, I want to view my full DGT license in full-screen with both front and back sides, so that I can see my photo, stats, and complete measurement history in a satisfying way.

#### Acceptance Criteria

1. WHEN a player card is tapped on the Leaderboard_Screen, THE License_Viewer_Screen SHALL open displaying the player's license in full-screen.
2. THE License_Viewer_Screen SHALL present a swipeable `PageView` with exactly two pages: License_Front (page 1) and License_Back (page 2).
3. EACH page in the License_Viewer_Screen SHALL be wrapped in an `InteractiveViewer` that allows pinch-to-zoom with a minimum scale of 1.0 and a maximum scale of 4.0.
4. THE License_Front SHALL display: the player's circular photo (or initials fallback), name, surname, sex, body size, current points, DGT title badge PNGs from `assets/titles/` with `×N` counters, a fine indicator when `fineCount > 0`, and an environmental badge slot.
5. THE License_Back SHALL display: a round-by-round table with columns Round N, BrAC reading, and points change for each round the player has been measured; a fine log listing each fine as `Multa N — Ronda N — 100€`; total money lost; and the player's perfection score formatted to two decimal places.
6. THE LicenseGenerator SHALL be extended with a `generateBack(PlayerProfile player)` method that renders the License_Back PNG using `assets/license/back.png` as the template and returns the absolute file path.
7. THE PlayerProfile Hive model SHALL be extended with a `licenseBackImagePath` field (nullable `String`) that stores the path to the License_Back PNG.
8. THE LicenseUpdateService SHALL call both `LicenseGenerator.generate()` (front) and `LicenseGenerator.generateBack()` (back) after each round and persist both paths to the PlayerProfile.
9. WHEN `licenseBackImagePath` is null (player registered before Phase 3), THE License_Viewer_Screen SHALL render the License_Back content dynamically from `PlayerProfile` data without crashing.
10. THE License_Viewer_Screen SHALL display a page indicator (e.g., two dots) showing which side is currently visible.

---

### Requirement 9: Game State Recovery

**User Story:** As a game operator, I want the app to detect and resume an in-progress game after a crash or forced close, so that a party is never interrupted by a technical failure.

#### Acceptance Criteria

1. WHEN the app launches, THE Recovery_Provider SHALL read the GameStateRepository and determine whether a game is currently in progress (i.e., `GameState.currentRound` is not null and the game has not been finished).
2. WHEN an in-progress game is detected at launch, THE Recovery_Provider SHALL navigate the user to the appropriate screen based on the saved game state: the checkpoint screen if a round is active or if a game is in progress but no round is currently active, or the leaderboard if between rounds.
3. WHEN an in-progress game is detected at launch, THE Recovery_Provider SHALL restore the checkpoint timer from the saved elapsed time so that the timer continues from where it left off.
4. WHEN no in-progress game is detected at launch, THE Recovery_Provider SHALL navigate to the main menu screen.
5. THE GameStateRepository SHALL persist the current round number, timer elapsed time, and player group assignments to Hive after every state change.
6. THE Recovery_Provider integration tests SHALL verify that a simulated crash (app restart with pre-seeded Hive data) results in navigation to the correct screen with the correct round number.
7. THE Recovery_Provider integration tests SHALL verify that a clean launch (empty Hive) results in navigation to the main menu.

---

### Requirement 10: Player Management — Edit and Delete

**User Story:** As a game operator, I want to edit a player's details and delete players from the list, so that registration mistakes can be corrected and unwanted entries can be removed before the game starts.

#### Acceptance Criteria

1. THE player list in the "Mis Vehículos" section SHALL support swipe-to-delete on each LicenseCard, revealing a delete action.
2. WHEN the operator initiates a swipe-to-delete, THE App SHALL display a confirmation dialog with the text `¿Eliminar a [Name]?` and two buttons: "Eliminar" (destructive) and "Cancelar".
3. WHEN the operator confirms deletion, THE PlayerRepository SHALL remove the player and THE player list SHALL update reactively.
4. WHEN the operator cancels deletion, THE player list SHALL remain unchanged and the swipe action SHALL be reset.
5. THE LicenseCard in the player list SHALL display an "Editar" icon button that opens the Edit_Screen for that player.
6. THE Edit_Screen SHALL reuse `PlayerRegistrationScreen` in edit mode, pre-populating all fields (name, surname, sex, body size, photo) with the player's current values.
7. WHEN the operator saves changes in the Edit_Screen, THE PlayerRepository SHALL update the player record and THE LicenseGenerator SHALL regenerate the license image with the updated data.
8. WHEN the operator cancels the Edit_Screen, THE player record SHALL remain unchanged.
9. THE swipe-to-delete and edit actions SHALL only be available when no game is currently in progress, preventing mid-game roster changes.

---

### Requirement 11: "Finish Game" Button (Post-Round 5)

**User Story:** As a game operator, I want a "Finish Game" button that becomes available after Round 5 is complete, so that the game can be formally ended and the final ceremony can begin.

#### Acceptance Criteria

1. THE Finish_Game_Button SHALL be accessible from the main menu screen when a game is in progress.
2. THE Finish_Game_Button SHALL be disabled (visually grayed out and non-interactive) when the current round is less than 5.
3. WHEN the current round is 5 or greater and all players in the current round have been measured, THE Finish_Game_Button SHALL become enabled.
4. WHEN the operator taps the enabled Finish_Game_Button, THE App SHALL display a confirmation dialog with the text `¿Finalizar la partida? Mínimo 5 rondas completadas.` and two buttons: "Finalizar" and "Cancelar".
5. WHEN the operator confirms game end, THE App SHALL navigate to the Final_Ceremony_Screen.
6. THE Final_Ceremony_Screen SHALL display a placeholder message `Ceremonia Final — Próximamente` and a "Volver al Menú" button with minHeight 80.
7. WHEN the operator taps "Volver al Menú" on the Final_Ceremony_Screen, THE GameStateRepository SHALL clear the current game state and, only after successful clearing, THE App SHALL navigate to the main menu screen.
8. WHEN the game state is cleared, THE Leaderboard_Screen and all game-related screens SHALL reflect the cleared state (no active game).

---

### Requirement 12: BAC Curve Calibration System

**User Story:** As a game operator, I want to adjust a curve multiplier that scales all optimal BrAC targets proportionally, so that the game difficulty can be tuned to match the actual drinking pace of the group.

#### Acceptance Criteria

1. THE Settings_Screen SHALL be accessible from the main menu via a settings icon or button.
2. THE Settings_Screen SHALL display a slider or stepper control for the Curve_Multiplier with a range of 0.80 to 1.20, a step size of 0.05, and a default value of 1.00.
3. THE Settings_Screen SHALL display a human-readable label describing the current multiplier value, for example: `Curva: 1.00× — Estándar`, `Curva: 0.95× — Menos agresiva`, `Curva: 1.10× — Más agresiva`.
4. THE Settings_Screen SHALL display the warning text `El ajuste de curva afecta a todos los jugadores por igual. No se devolverán puntos.` whenever the Curve_Multiplier is not 1.00.
5. WHEN a game is in progress (current round ≥ 1), THE Settings_Screen SHALL disable the Curve_Multiplier control and display the message `No se puede cambiar la curva durante una ronda activa.`.
6. WHEN the operator saves a new Curve_Multiplier value, THE CurveSettingsRepository SHALL persist the value to Hive.
7. THE BACCalculator.calculateOptimalBrAC() method SHALL apply the Curve_Multiplier by multiplying the raw party-mode target by the stored multiplier value before returning it.
8. THE BACCalculator unit tests SHALL verify that `calculateOptimalBrAC()` returns `rawTarget × multiplier` for multiplier values 0.80, 1.00, and 1.20.
9. WHEN the app launches, THE CurveSettingsRepository SHALL load the persisted Curve_Multiplier; IF no value is persisted, THEN THE CurveSettingsRepository SHALL use the default value of 1.00.
10. THE Curve_Multiplier SHALL affect all zone threshold calculations (sweet spot, close, neutral, far, fine) because those thresholds are proportional to the optimal BrAC value returned by BACCalculator.
11. FOR ALL valid Curve_Multiplier values in [0.80, 1.20], the round-trip property SHALL hold: persisting a multiplier value and then loading it SHALL produce the same value (round-trip property).
