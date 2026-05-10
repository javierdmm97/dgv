# Requirements Document: Phase 1 Completion

## Introduction

This document specifies the requirements for completing Phase 1 of the Operación DGV Flutter application. Phase 1 completion includes implementing checkpoint timer providers with per-group management, writing comprehensive unit tests for existing utilities and repositories, building the main menu and related screens, and creating reusable drunk-proof UI widgets.

Operación DGV is a party breathalyzer tracker with a satirical Spanish traffic authority (DGT) theme that gamifies responsible drinking. The app tracks players' Blood Alcohol Content (BAC) readings via breathalyzer measurements and awards points based on how well players maintain their personalized optimal BAC zone.

**Phase 1 Foundation Status:**
- ✅ Core infrastructure (theme, constants, models) - Complete
- ✅ Domain models (PlayerProfile, BACReading, GameState, CheckpointState, DGTTitle, GrandPrize) - Complete
- ✅ Business logic utilities (BACCalculator, PointsCalculator, TitleEvaluator, CheckpointCalculator) - Complete
- ✅ Data layer (PlayerRepository, GameStateRepository, CheckpointRepository with Hive) - Complete
- ✅ Basic Riverpod providers (player and game state) - Complete
- ⏳ Checkpoint providers - **TO BE IMPLEMENTED**
- ⏳ Unit tests - **TO BE IMPLEMENTED**
- ⏳ Main menu and screens - **TO BE IMPLEMENTED**
- ⏳ Reusable widgets - **TO BE IMPLEMENTED**

## Glossary

- **System**: The Operación DGV Flutter application
- **Player**: A user registered in the app with profile data (name, surname, sex, body size, photo)
- **Group**: A subset of players who measure BAC at the same checkpoint intervals
- **Checkpoint**: A scheduled time when a group of players must log their BAC readings
- **Checkpoint_Timer**: A countdown timer tracking time until the next checkpoint for a specific group
- **BAC_Reading**: A breathalyzer measurement in mg/L (milligrams per liter of exhaled air)
- **Optimal_BAC**: A personalized target BAC zone calculated from player body size (Small: 2.5 mg/L, Medium: 2.0 mg/L, Large: 1.8 mg/L)
- **Round**: A measurement cycle where all active groups complete their BAC readings
- **Round_0**: The baseline measurement round with no feedback or points awarded
- **Active_Round**: Any round after Round 0 where full feedback and points are awarded
- **Game_State**: Persistent data tracking current round, player IDs, and game progress
- **Checkpoint_State**: Persistent data tracking per-group timers, intervals, and measurement times
- **Hive**: Local storage database for persistent state management
- **Riverpod_Provider**: State management component using Riverpod 2.0+ with code generation
- **Main_Menu**: The persistent home screen that serves as the central hub throughout app lifecycle
- **Fake_Error_Notification**: A dismissible satirical error message displayed at the top of the main menu
- **Fake_News**: Satirical DGT-themed articles displayed in the "Actualidad DGT" section
- **License_Card**: A visual representation of a player's DGT license with photo, points, and title badges
- **Title_Badge**: A visual indicator showing a DGT title with accumulation counter (e.g., 🟢×3)
- **Massive_Button**: An oversized, high-contrast button with minimum 80px height for drunk-proof interaction
- **Custom_Keypad**: A 3×4 grid numerical input widget with 80×80px buttons and hardcoded decimal point
- **Police_Siren**: An audio and visual alert (red/blue flashing) triggered when a checkpoint is due
- **UI_Lock**: A state where user interface is disabled until all players in active group complete BAC entry
- **DGT**: Dirección General de Tráfico (Spanish traffic authority) - the satirical theme of the app
- **Drunk_Proof_Design**: UX principles ensuring usability for impaired users (oversized targets, high contrast, no native keyboards)

## Requirements

### Requirement 1: Checkpoint Provider State Management

**User Story:** As a game coordinator, I want each group to have independent checkpoint timers, so that groups can measure BAC at different times without interfering with each other.

#### Acceptance Criteria

1. THE Checkpoint_Provider SHALL manage multiple Group timers independently
2. WHEN a Group is created, THE Checkpoint_Provider SHALL initialize a Checkpoint_Timer with configurable interval (30, 45, or 60 minutes)
3. WHEN a Group completes measurement, THE Checkpoint_Provider SHALL update that Group's last measurement time and reset its Checkpoint_Timer
4. THE Checkpoint_Provider SHALL persist Checkpoint_State to Hive after every state change
5. WHEN the app restarts, THE Checkpoint_Provider SHALL restore all Group timers from Hive with remaining time calculated from last measurement time
6. THE Checkpoint_Provider SHALL expose a stream of Checkpoint_State for reactive UI updates
7. WHEN any Group's Checkpoint_Timer reaches zero, THE Checkpoint_Provider SHALL mark that Group as due for measurement
8. THE Checkpoint_Provider SHALL calculate time remaining for each Group based on last measurement time and interval duration

**Testing Guidance:**
- Property: Round-trip persistence (save state → restart → load state produces equivalent timers)
- Property: Timer calculations are deterministic (same inputs always produce same remaining time)
- Property: State transitions preserve invariants (total players = sum of players across all groups)
- Example: Create 3 groups with different intervals, verify each timer counts down independently
- Example: Simulate app crash and restart, verify timers resume with correct remaining time
- Edge case: Handle zero players, single player, and maximum players (50+)
- Edge case: Handle timer expiration during app suspension

### Requirement 2: Checkpoint Timer UI Lock

**User Story:** As a game coordinator, I want the UI to lock when a checkpoint is due, so that all players in the active group must log their BAC before continuing.

#### Acceptance Criteria

1. WHEN a Group's Checkpoint_Timer reaches zero, THE System SHALL trigger a Police_Siren alert (audio and visual)
2. WHEN a Police_Siren is triggered, THE System SHALL display a full-screen alert with red and blue flashing animation
3. WHEN a Police_Siren alert is displayed, THE System SHALL lock all UI navigation except BAC entry for the active Group
4. WHEN all players in the active Group have logged BAC readings, THE System SHALL unlock the UI and dismiss the alert
5. THE System SHALL display a progress indicator showing how many players in the active Group have logged readings (e.g., "3/5 players measured")
6. WHEN multiple Groups are due simultaneously, THE System SHALL process them sequentially in group index order
7. THE System SHALL save UI_Lock state to Hive to survive app restarts

**Testing Guidance:**
- Property: UI lock is idempotent (locking twice has same effect as locking once)
- Property: Progress counter equals number of completed readings (invariant)
- Example: Trigger checkpoint for group of 5 players, verify UI locks until all 5 complete
- Example: Simulate app restart during UI lock, verify lock persists and progress is preserved
- Edge case: Handle checkpoint due during active BAC entry
- Edge case: Handle multiple groups becoming due within seconds of each other

### Requirement 3: Unit Tests for BAC Calculator

**User Story:** As a developer, I want comprehensive unit tests for BACCalculator, so that I can verify all BAC calculations are correct and handle edge cases.

#### Acceptance Criteria

1. THE Test_Suite SHALL verify calculateOptimalBAC returns correct values for all BodySize variants (Small: 2.5, Medium: 2.0, Large: 1.8 mg/L)
2. THE Test_Suite SHALL verify isInOptimalZone returns true when BAC is within ±0.2 mg/L of optimal
3. THE Test_Suite SHALL verify isCloseToOptimal returns true when BAC is between ±0.2 and ±0.4 mg/L of optimal
4. THE Test_Suite SHALL verify crossedOptimalLine returns true when BAC exceeds optimal + 0.4 mg/L
5. THE Test_Suite SHALL verify isTooLow returns true when BAC is below optimal - 0.4 mg/L
6. THE Test_Suite SHALL verify calculateBACRatePerHour correctly calculates rate from BAC delta and time duration
7. THE Test_Suite SHALL verify isDangerousSpike returns true when rate exceeds 0.8 mg/L per hour
8. THE Test_Suite SHALL test boundary conditions (exactly at thresholds, zero BAC, negative time delta)
9. THE Test_Suite SHALL achieve minimum 90% line coverage for BACCalculator

**Testing Guidance:**
- Property: Zone checking functions are mutually exclusive (a BAC value cannot be in multiple zones)
- Property: Rate calculation is linear (doubling time halves the rate)
- Example: Test optimal zone with BAC = 2.0, optimal = 2.0 (exactly at target)
- Example: Test boundary at optimal + 0.2 (should be in zone, not close)
- Edge case: Zero time delta (should return 0 rate, not divide by zero)
- Edge case: Negative BAC delta (BAC decreased)

### Requirement 4: Unit Tests for Points Calculator

**User Story:** As a developer, I want comprehensive unit tests for PointsCalculator, so that I can verify point awards and penalties are calculated correctly.

#### Acceptance Criteria

1. THE Test_Suite SHALL verify calculatePointsChange returns +2 when BAC is in optimal zone
2. THE Test_Suite SHALL verify calculatePointsChange returns +1 when BAC is close to optimal
3. THE Test_Suite SHALL verify calculatePointsChange returns -3 when BAC crosses optimal line
4. THE Test_Suite SHALL verify calculatePointsChange returns -2 when BAC spike is dangerous
5. THE Test_Suite SHALL verify calculatePointsChange returns 0 when BAC is too low
6. THE Test_Suite SHALL verify isImpounded returns true when BAC >= 3.5 mg/L
7. THE Test_Suite SHALL verify getImpoundmentPenalty returns -5 points
8. THE Test_Suite SHALL verify calculateTotalPoints clamps values between min (0) and max (20) points
9. THE Test_Suite SHALL verify getFeedbackMessage returns correct Spanish message for each points change scenario
10. THE Test_Suite SHALL verify getFeedbackColor returns correct color (green, yellow, red, neutral) for each scenario
11. THE Test_Suite SHALL achieve minimum 90% line coverage for PointsCalculator

**Testing Guidance:**
- Property: Total points are always clamped (never negative, never > 20)
- Property: Feedback message and color are deterministic functions of points change
- Example: Test in-zone scenario (BAC = 2.0, optimal = 2.0, expect +2 points, green color)
- Example: Test crossed-line scenario (BAC = 2.5, optimal = 2.0, expect -3 points, red color)
- Edge case: Points change would exceed maximum (15 + 10 = 20, not 25)
- Edge case: Points change would go negative (2 - 5 = 0, not -3)

### Requirement 5: Unit Tests for Title Evaluator

**User Story:** As a developer, I want comprehensive unit tests for TitleEvaluator, so that I can verify DGT titles are awarded correctly each round.

#### Acceptance Criteria

1. THE Test_Suite SHALL verify evaluateRound awards Velocidad_de_Crucero to player closest to their optimal zone
2. THE Test_Suite SHALL verify evaluateRound awards Multa_por_Exceso to player with highest BAC spike from previous round
3. THE Test_Suite SHALL verify evaluateRound awards L_de_Practicas to player with lowest BAC in current round
4. THE Test_Suite SHALL verify evaluateRound awards Vehiculo_Hibrido to all players whose BAC decreased from previous round
5. THE Test_Suite SHALL verify evaluateRound awards ITV_Passed to all players with same reading twice (±0.01 mg/L tolerance)
6. THE Test_Suite SHALL verify evaluateRound returns empty map when no players have readings for current round
7. THE Test_Suite SHALL verify evaluateRound handles Round 1 correctly (no spike or hybrid titles due to lack of previous round)
8. THE Test_Suite SHALL verify calculateGrandPrizes awards Conductor_Perfecto to highest points player who never crossed optimal line
9. THE Test_Suite SHALL verify calculateGrandPrizes awards Precision_Absoluta to player with smallest average distance from optimal
10. THE Test_Suite SHALL verify calculateGrandPrizes awards Coleccionista_Titulos to player with most accumulated titles
11. THE Test_Suite SHALL verify getEnvironmentalDistinctives returns top 5 players sorted by maximum BAC (descending)
12. THE Test_Suite SHALL achieve minimum 90% line coverage for TitleEvaluator

**Testing Guidance:**
- Property: Each per-round title is awarded to at most one player (except Hibrido and ITV which can have multiple winners)
- Property: Grand prizes are mutually exclusive (one player per prize)
- Property: Environmental distinctives list is sorted descending by max BAC
- Example: Create 5 players with different BAC patterns, verify correct title awards
- Example: Test tie-breaking (two players equidistant from optimal, first in list wins)
- Edge case: Round 1 with no previous round (spike and hybrid titles not awarded)
- Edge case: All players crossed optimal line (Conductor_Perfecto not awarded)
- Edge case: Fewer than 5 players (Environmental distinctives returns all players)

### Requirement 6: Unit Tests for Checkpoint Calculator

**User Story:** As a developer, I want comprehensive unit tests for CheckpointCalculator, so that I can verify group division and timer calculations are correct.

#### Acceptance Criteria

1. THE Test_Suite SHALL verify calculateNextCheckpoint adds interval duration to last measurement time
2. THE Test_Suite SHALL verify isCheckpointDue returns true when current time is after next checkpoint time
3. THE Test_Suite SHALL verify getTimeRemaining returns correct duration until next checkpoint
4. THE Test_Suite SHALL verify getTimeRemaining returns Duration.zero when checkpoint is overdue
5. THE Test_Suite SHALL verify divideIntoGroups creates correct number of groups based on player count and group size
6. THE Test_Suite SHALL verify divideIntoGroups distributes players evenly (last group may be smaller)
7. THE Test_Suite SHALL verify suggestNumberOfGroups returns 1 for <= 8 players, 2 for <= 16 players, 3 for <= 24 players
8. THE Test_Suite SHALL verify formatTimeRemaining returns MM:SS format with zero-padding
9. THE Test_Suite SHALL verify formatTimeRemainingHuman returns human-readable format (hours, minutes, or seconds)
10. THE Test_Suite SHALL achieve minimum 90% line coverage for CheckpointCalculator

**Testing Guidance:**
- Property: Dividing players into groups preserves total player count (sum of group sizes = total players)
- Property: Time remaining decreases monotonically as current time advances
- Property: Formatting functions are inverses of parsing (format then parse returns original duration)
- Example: Test 20 players divided into 3 groups (7, 7, 6 distribution)
- Example: Test checkpoint due calculation with past, present, and future times
- Edge case: Zero players (should return empty groups list)
- Edge case: Negative time remaining (checkpoint overdue, should return zero)

### Requirement 7: Unit Tests for Repositories

**User Story:** As a developer, I want comprehensive unit tests for all repository implementations, so that I can verify data persistence and retrieval work correctly.

#### Acceptance Criteria

1. THE Test_Suite SHALL verify PlayerRepository saves and retrieves PlayerProfile correctly
2. THE Test_Suite SHALL verify PlayerRepository getAll returns all saved players
3. THE Test_Suite SHALL verify PlayerRepository delete removes player and subsequent getById returns null
4. THE Test_Suite SHALL verify PlayerRepository update modifies existing player data
5. THE Test_Suite SHALL verify PlayerRepository count returns correct number of saved players
6. THE Test_Suite SHALL verify PlayerRepository clearAll removes all players
7. THE Test_Suite SHALL verify GameStateRepository saves and retrieves GameState correctly
8. THE Test_Suite SHALL verify GameStateRepository isGameInProgress returns true when game exists and is in progress
9. THE Test_Suite SHALL verify GameStateRepository delete removes game state
10. THE Test_Suite SHALL verify CheckpointRepository saves and retrieves CheckpointState correctly
11. THE Test_Suite SHALL verify CheckpointRepository delete removes checkpoint state
12. THE Test_Suite SHALL verify all repository watch streams emit updates when data changes
13. THE Test_Suite SHALL achieve minimum 85% line coverage for all repository implementations

**Testing Guidance:**
- Property: Round-trip persistence (save entity → retrieve entity produces equivalent data)
- Property: Delete is idempotent (deleting twice has same effect as deleting once)
- Property: Count equals length of getAll result (invariant)
- Example: Save 3 players, verify getAll returns 3 players with correct data
- Example: Update player points, verify getById returns updated points
- Example: Save game state, restart app (simulate with new repository instance), verify state persists
- Edge case: Retrieve non-existent ID (should return null, not throw)
- Edge case: Update non-existent entity (should handle gracefully)

### Requirement 8: Main Menu Screen

**User Story:** As a player, I want a persistent home screen that mimics the DGT app layout, so that I can easily navigate to all app features and resume games after crashes.

#### Acceptance Criteria

1. THE Main_Menu SHALL display a header with DGT logo and menu icon
2. THE Main_Menu SHALL display a dismissible Fake_Error_Notification at the top with X button
3. WHEN the X button is tapped, THE Main_Menu SHALL hide the Fake_Error_Notification
4. THE Main_Menu SHALL display a "Start Game" Massive_Button when no game is in progress
5. THE Main_Menu SHALL display a "Resume Game" Massive_Button when a game is in progress
6. WHEN "Start Game" is tapped, THE Main_Menu SHALL navigate to player selection screen
7. WHEN "Resume Game" is tapped, THE Main_Menu SHALL navigate to the current game screen based on Game_State
8. THE Main_Menu SHALL display a "Mis Vehículos" section with "Add Player" button
9. WHEN "Add Player" is tapped, THE Main_Menu SHALL navigate to player registration flow
10. THE Main_Menu SHALL display a list of registered players in "Mis Vehículos" section when players exist
11. WHEN a player card is tapped, THE Main_Menu SHALL navigate to full-screen license view
12. THE Main_Menu SHALL display an "Actualidad DGT" section with scrollable Fake_News articles
13. WHEN a Fake_News article is tapped, THE Main_Menu SHALL navigate to full article view
14. WHEN the app launches, THE Main_Menu SHALL check Hive for existing Game_State and display appropriate button

**Testing Guidance:**
- Widget test: Verify "Start Game" button appears when no game in progress
- Widget test: Verify "Resume Game" button appears when game exists
- Widget test: Verify Fake_Error_Notification dismisses when X is tapped
- Widget test: Verify player list displays when players exist
- Integration test: Launch app with saved game state, verify "Resume Game" appears
- Edge case: No players registered (should show empty state in "Mis Vehículos")
- Edge case: Game state corrupted (should default to "Start Game")

### Requirement 9: Fake News Screen

**User Story:** As a player, I want to view satirical DGT-themed news articles, so that I can enjoy the humorous theme while waiting for checkpoints.

#### Acceptance Criteria

1. THE Fake_News_Screen SHALL display a list of satirical DGT articles with title, image, and date
2. WHEN an article is tapped, THE Fake_News_Screen SHALL navigate to full article view
3. THE Fake_News_Screen SHALL display article content with DGT-themed formatting (blue header, official-looking layout)
4. THE Fake_News_Screen SHALL include a back button to return to Main_Menu
5. THE Fake_News_Screen SHALL use high-contrast text and oversized touch targets (Drunk_Proof_Design)

**Testing Guidance:**
- Widget test: Verify article list displays with correct titles and images
- Widget test: Verify tapping article navigates to detail view
- Widget test: Verify back button returns to Main_Menu
- Edge case: No articles available (should show empty state)

### Requirement 10: Fake Error Screen

**User Story:** As a player, I want to see a satirical error message screen, so that I can experience the humorous DGT theme.

#### Acceptance Criteria

1. THE Fake_Error_Screen SHALL display the fake error image (assets/msg_error.png)-> that a reference image, not the real implementation. 
2. THE Fake_Error_Screen SHALL display satirical error text in Spanish
3. THE Fake_Error_Screen SHALL include a "Cerrar" (Close) Massive_Button
4. WHEN "Cerrar" is tapped, THE Fake_Error_Screen SHALL dismiss and return to previous screen
5. THE Fake_Error_Screen SHALL use DGT color scheme (blue header, light gray background)

**Testing Guidance:**
- Widget test: Verify error image displays
- Widget test: Verify close button dismisses screen
- Widget test: Verify DGT color scheme is applied

### Requirement 11: Massive Button Widget

**User Story:** As a player with impaired coordination, I want oversized buttons with high contrast, so that I can reliably tap them even when drunk.

#### Acceptance Criteria

1. THE Massive_Button SHALL have a minimum height of 80 pixels
2. THE Massive_Button SHALL use high-contrast DGT colors (primary blue background, white text)
3. THE Massive_Button SHALL display text at minimum 24sp font size with bold weight
4. THE Massive_Button SHALL provide haptic feedback when tapped
5. THE Massive_Button SHALL support disabled state with reduced opacity
6. THE Massive_Button SHALL accept custom text, onPressed callback, and optional icon
7. THE Massive_Button SHALL use rounded corners (border radius 12px) for visual appeal

**Testing Guidance:**
- Widget test: Verify button renders with minimum 80px height
- Widget test: Verify text is bold and 24sp
- Widget test: Verify onPressed callback is invoked when tapped
- Widget test: Verify disabled state prevents tap and reduces opacity
- Widget test: Verify icon displays when provided
- Edge case: Very long text (should wrap or truncate gracefully)

### Requirement 12: Custom Keypad Widget

**User Story:** As a player with impaired coordination, I want a large custom keypad for entering BAC readings, so that I can accurately input numbers without using the native keyboard.

#### Acceptance Criteria

1. THE Custom_Keypad SHALL display a 3×4 grid of buttons (1-9, 0, backspace, confirm)
2. THE Custom_Keypad SHALL render each button at 80×80 pixels minimum
3. THE Custom_Keypad SHALL automatically format input as 0.XX (two decimal places)
4. WHEN a digit button is tapped, THE Custom_Keypad SHALL append the digit and update display
5. WHEN backspace button is tapped, THE Custom_Keypad SHALL remove the last digit
6. WHEN confirm button is tapped, THE Custom_Keypad SHALL invoke onConfirm callback with formatted value
7. THE Custom_Keypad SHALL provide haptic feedback on every button tap
8. THE Custom_Keypad SHALL disable confirm button when input is empty or invalid
9. THE Custom_Keypad SHALL use high-contrast DGT colors for buttons
10. THE Custom_Keypad SHALL display current input value above the keypad in large font (32sp)

**Testing Guidance:**
- Widget test: Verify 3×4 grid layout with correct button labels
- Widget test: Verify digit buttons append to input
- Widget test: Verify backspace removes last digit
- Widget test: Verify confirm button invokes callback with correct value
- Widget test: Verify input formats as 0.XX (e.g., "4" "5" → "0.45")
- Widget test: Verify confirm button is disabled when input is empty
- Edge case: Maximum input length (should prevent input beyond 2 digits)
- Edge case: Rapid tapping (should handle debouncing)

### Requirement 13: Title Badge Widget

**User Story:** As a player, I want to see my accumulated DGT titles with counters, so that I can track my achievements throughout the game.

#### Acceptance Criteria

1. THE Title_Badge SHALL display a DGT title icon (🟢, 🔴, 🔰, 🔋, 🛠️)
2. THE Title_Badge SHALL display a counter showing accumulation (e.g., "×3")
3. WHEN counter is 0, THE Title_Badge SHALL display grayed-out icon with no counter
4. WHEN counter is >= 1, THE Title_Badge SHALL display full-color icon with counter
5. THE Title_Badge SHALL use a compact layout (icon + counter in a row)
6. THE Title_Badge SHALL accept title type and count as parameters
7. THE Title_Badge SHALL use DGT color scheme for background and text

**Testing Guidance:**
- Widget test: Verify icon displays for each title type
- Widget test: Verify counter displays when count >= 1
- Widget test: Verify grayed-out appearance when count = 0
- Widget test: Verify counter text format (×N)
- Edge case: Very high count (×99, should display without overflow)

### Requirement 14: License Card Widget

**User Story:** As a player, I want to view my DGT license card with photo, points, and title badges, so that I can see my current game status.

#### Acceptance Criteria

1. THE License_Card SHALL display player photo in circular crop
2. THE License_Card SHALL display player name and surname
3. THE License_Card SHALL display current points value prominently
4. THE License_Card SHALL display all earned Title_Badge widgets in a row
5. THE License_Card SHALL use DGT license color scheme (light pink background #F3E8EC)
6. THE License_Card SHALL display "VEHÍCULO INMOVILIZADO" badge when player is impounded
7. WHEN License_Card is tapped, THE License_Card SHALL invoke onTap callback
8. THE License_Card SHALL use card elevation and rounded corners for visual depth
9. THE License_Card SHALL display optimal BAC value for reference

**Testing Guidance:**
- Widget test: Verify all player data displays correctly
- Widget test: Verify title badges render in correct order
- Widget test: Verify impounded badge appears when player is impounded
- Widget test: Verify onTap callback is invoked when card is tapped
- Widget test: Verify photo displays with circular crop
- Edge case: Player with no titles (should show empty badge slots)
- Edge case: Player with all 5 titles (should display all badges without overflow)

### Requirement 15: Checkpoint Provider Integration Tests

**User Story:** As a developer, I want integration tests for checkpoint providers, so that I can verify timer management works correctly with Hive persistence.

#### Acceptance Criteria

1. THE Integration_Test SHALL verify creating checkpoint state with 3 groups persists to Hive
2. THE Integration_Test SHALL verify restarting app restores all group timers with correct remaining time
3. THE Integration_Test SHALL verify updating one group's timer does not affect other groups
4. THE Integration_Test SHALL verify checkpoint due triggers Police_Siren alert
5. THE Integration_Test SHALL verify completing all players in active group unlocks UI
6. THE Integration_Test SHALL verify multiple groups becoming due are processed sequentially
7. THE Integration_Test SHALL verify timer state survives app suspension and resume

**Testing Guidance:**
- Integration test: Create checkpoint state, kill app, restart, verify timers resume
- Integration test: Simulate time passing, verify checkpoint becomes due at correct time
- Integration test: Complete measurements for active group, verify next group activates
- Edge case: App suspended for longer than checkpoint interval (should trigger immediately on resume)
- Edge case: System time changes (should recalculate based on absolute timestamps)

## Parser and Serializer Requirements

### Requirement 16: Checkpoint State Serialization

**User Story:** As a developer, I want reliable JSON serialization for CheckpointState, so that checkpoint timers persist correctly across app restarts.

#### Acceptance Criteria

1. WHEN CheckpointState is serialized to JSON, THE Serializer SHALL produce valid JSON with all fields
2. WHEN JSON is deserialized to CheckpointState, THE Parser SHALL reconstruct the object with all fields intact
3. THE Pretty_Printer SHALL format CheckpointState as human-readable JSON with indentation
4. FOR ALL valid CheckpointState objects, parsing then printing then parsing SHALL produce an equivalent object (round-trip property)
5. WHEN JSON contains invalid data types, THE Parser SHALL return a descriptive error
6. WHEN JSON is missing required fields, THE Parser SHALL return a descriptive error

**Testing Guidance:**
- Property: Round-trip (toJson → fromJson produces equivalent object)
- Property: Serialization is deterministic (same object always produces same JSON)
- Example: Serialize checkpoint state with 3 groups, verify all group data is preserved
- Example: Deserialize JSON with missing field, verify error message is descriptive
- Edge case: DateTime serialization (should use ISO 8601 format)
- Edge case: Empty groups list (should serialize as empty array, not null)

### Requirement 17: Game State Serialization

**User Story:** As a developer, I want reliable JSON serialization for GameState, so that game progress persists correctly across app restarts.

#### Acceptance Criteria

1. WHEN GameState is serialized to JSON, THE Serializer SHALL produce valid JSON with all fields
2. WHEN JSON is deserialized to GameState, THE Parser SHALL reconstruct the object with all fields intact
3. THE Pretty_Printer SHALL format GameState as human-readable JSON with indentation
4. FOR ALL valid GameState objects, parsing then printing then parsing SHALL produce an equivalent object (round-trip property)
5. WHEN JSON contains invalid data types, THE Parser SHALL return a descriptive error
6. WHEN JSON is missing required fields, THE Parser SHALL return a descriptive error

**Testing Guidance:**
- Property: Round-trip (toJson → fromJson produces equivalent object)
- Example: Serialize game state with 10 player IDs, verify all IDs are preserved
- Edge case: Null finishTime (game in progress, should serialize as null)
- Edge case: Empty player IDs list (should serialize as empty array)

## Notes

- All breathalyzer readings are in mg/L (milligrams per liter of exhaled air), not blood alcohol percentage
- Optimal BAC zones are personalized by body size to level the playing field
- Checkpoint timers are per-group, allowing groups to measure at different times
- All state must persist to Hive to survive app crashes and restarts
- All UI widgets must follow Drunk_Proof_Design principles (oversized, high contrast, no native keyboards)
- All tests must achieve minimum 80% coverage for business logic, 85% for repositories
- Round 0 is a special baseline round with no feedback or points awarded
- Active rounds (Round 1+) provide full feedback, points, and title awards
