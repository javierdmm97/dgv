# Implementation Plan: Phase 1 Completion

## Overview

Wire the existing foundation (Freezed models, Hive repositories, base Riverpod providers) into a working UI with full test coverage. Work proceeds in four parallel tracks: checkpoint provider, reusable widgets, main menu screens, and test suites. Each track is independently buildable; integration happens in the final wiring task.

## Tasks

- [x] 1. Implement CheckpointNotifier provider
  - [x] 1.1 Create `lib/core/providers/checkpoint_providers.dart` with `CheckpointNotifier`
    - Declare `@riverpod class CheckpointNotifier extends _$CheckpointNotifier` with `Future<CheckpointState?> build()`
    - Load existing state from `checkpointRepositoryProvider` on build; call `_startTicker()` if state is non-null
    - Register `ref.onDispose(() => _ticker?.cancel())` to prevent timer leaks
    - Implement `_startTicker()` using `Timer.periodic(const Duration(seconds: 1), (_) => _tick())`
    - Implement `_tick()`: recompute `timeRemaining` for each group from absolute `lastMeasurement` timestamps; set `isCheckpointActive = true` when any group becomes due; persist updated state to Hive
    - Implement `initialize({required List<PlayerProfile> players, required int intervalMinutes})`: call `CheckpointCalculator.divideIntoGroups`, build `GroupCheckpoint` list, save to Hive, start ticker
    - Implement `completeGroupMeasurement(int groupIndex)`: update `lastMeasurement` for that group, clear `activeGroupIndex` if no other groups are due, persist
    - Implement `recordPlayerMeasurement(String playerId)`: track per-player progress within the active group window; unlock when all players in group are measured
    - Implement `reset()`: cancel ticker, delete Hive state, set state to `AsyncData(null)`
    - Run `dart run build_runner build -d` after file creation
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.7, 1.8_

  - [x] 1.2 Add supporting read-only providers in the same file
    - `@riverpod Stream<CheckpointState?> checkpointStream(...)` — delegates to `checkpointRepositoryProvider.watch()`
    - `@riverpod bool isCheckpointDue(...)` — reads `checkpointNotifierProvider.value?.isCheckpointActive ?? false`
    - `@riverpod (int, int) activeGroupProgress(...)` — counts players with readings in the current checkpoint window vs. total in active group
    - Run `dart run build_runner build -d` after adding providers
    - _Requirements: 1.6, 2.3, 2.5_

- [x] 2. Implement MainMenuProvider
  - [x] 2.1 Create `lib/features/main_menu/providers/main_menu_provider.dart`
    - Define `@freezed class MainMenuState` with fields: `isGameInProgress`, `players`, `isFakeErrorVisible` (default `true`)
    - Declare `@riverpod class MainMenuNotifier extends _$MainMenuNotifier` with `Future<MainMenuState> build()`
    - In `build()`, watch `currentGameStateProvider` and `playerListProvider` concurrently; compose into `MainMenuState`
    - Implement `dismissFakeError()`: `state = AsyncData(state.value!.copyWith(isFakeErrorVisible: false))`
    - Run `dart run build_runner build -d` after file creation
    - _Requirements: 8.2, 8.3, 8.4, 8.5, 8.14_

- [x] 3. Implement reusable widgets
  - [x] 3.1 Create `lib/widgets/massive_button.dart`
    - `const` constructor with `required String text`, `required VoidCallback? onPressed`, optional `IconData? icon`, `bool isEnabled = true`, `Color? backgroundColor`
    - Use `ElevatedButton` with `ButtonStyle` setting `minimumSize: MaterialStatePropertyAll(Size(double.infinity, 80))`
    - Text style: `Theme.of(context).textTheme.titleLarge` (24sp bold)
    - Background: `backgroundColor ?? DGTColors.primary`; disabled: wrap with `Opacity(opacity: 0.5)` when `!isEnabled`
    - Call `HapticFeedback.mediumImpact()` inside `onPressed` wrapper before invoking the callback
    - `BorderRadius.circular(12)` via `shape` in `ButtonStyle`
    - Pass `null` to `onPressed` when `!isEnabled` to disable the button natively
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7_

  - [x] 3.2 Create `lib/widgets/title_badge.dart`
    - `const` constructor with `required DGTTitle title`, `required int count`
    - When `count == 0`: render icon with `color: Colors.grey` (from `Theme.of(context).colorScheme.outline`), no counter text
    - When `count >= 1`: render full-color icon + `Text('×$count')`
    - Layout: `Row([icon, if (count > 0) Text('×$count')])`
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6_

  - [x] 3.3 Create `lib/widgets/custom_keypad.dart`
    - `StatefulWidget` with `const` constructor: `required void Function(double) onConfirm`, optional `double? initialValue`
    - State holds `List<int> _buffer` (max 2 digits); display value formatted as `'0.${_buffer.map((d) => d.toString()).join().padRight(2, '0')}'`
    - Layout: `Column([display text at 32sp, GridView with crossAxisCount: 3, childAspectRatio: 1.0, cells 80×80])`
    - Button rows: `[1,2,3]`, `[4,5,6]`, `[7,8,9]`, `[⌫, 0, ✓]`
    - Digit tap: if `_buffer.length < 2`, append digit; call `HapticFeedback.lightImpact()`
    - Backspace tap: if buffer non-empty, remove last; call `HapticFeedback.lightImpact()`
    - Confirm tap: disabled (grey, no callback) when `_buffer.isEmpty`; otherwise call `onConfirm(double.parse('0.${_buffer.join()}'))` and `HapticFeedback.mediumImpact()`
    - Use `DGTColors` for button backgrounds; display text uses `Theme.of(context).textTheme.displaySmall`
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9, 12.10_

  - [x] 3.4 Create `lib/widgets/license_card.dart`
    - `const` constructor with `required PlayerProfile player`, optional `VoidCallback? onTap`
    - Header: `CircleAvatar` with `backgroundImage: AssetImage(player.photoPath)`; fallback to initials when path is empty
    - Name/surname: `Text('${player.name} ${player.surname}')` using `textTheme.titleMedium`
    - Points: `Text('${player.points}')` using `textTheme.displaySmall` with `DGTColors.primary` color
    - Badges: `Row` of `TitleBadge` for each `DGTTitle` value with `player.titleCounts[title] ?? 0`
    - Impounded overlay: `if (player.isImpounded)` show `Banner` or `Stack` child with `'VEHÍCULO INMOVILIZADO'` text
    - Optimal BAC: small `Text('Óptimo: ${player.optimalBAC} mg/L')` at bottom
    - Wrap in `Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), color: DGTColors.licenseId)`
    - Wrap card in `GestureDetector(onTap: onTap)`
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 14.6, 14.7, 14.8, 14.9_

- [x] 4. Implement main menu screens
  - [x] 4.1 Create `lib/features/main_menu/presentation/widgets/fake_error_notification.dart`
    - `ConsumerWidget` watching `mainMenuNotifierProvider`
    - Dismissible top bar with error icon, satirical Spanish text, and `IconButton(icon: Icon(Icons.close))` that calls `notifier.dismissFakeError()`
    - Return `SizedBox.shrink()` when `!state.isFakeErrorVisible`
    - _Requirements: 8.2, 8.3_

  - [x] 4.2 Create `lib/features/main_menu/presentation/widgets/fake_news_section.dart`
    - `StatelessWidget` accepting `List<FakeNewsArticle> articles` and `VoidCallback onViewAll`
    - Horizontal `ListView.builder` of article preview tiles (title + date)
    - "Ver todo" button that calls `onViewAll`
    - _Requirements: 8.12_

  - [x] 4.3 Create `lib/features/main_menu/presentation/main_menu_screen.dart`
    - `ConsumerWidget` watching `mainMenuNotifierProvider`
    - Handle all three `AsyncValue` states (loading, error, data) in `build()`
    - Decompose into private widget classes to keep `build()` under 80 lines:
      - `_MainMenuHeader`: DGT logo + menu icon row
      - `_GameActionSection`: shows `MassiveButton('Iniciar Partida')` or `MassiveButton('Reanudar Partida')` based on `state.isGameInProgress`
      - `_MisVehiculosSection`: "Mis Vehículos" heading + "Añadir Jugador" button + `ListView` of `LicenseCard` widgets
    - Compose `FakeErrorNotification`, `_MainMenuHeader`, `_GameActionSection`, `_MisVehiculosSection`, `FakeNewsSection` in a `CustomScrollView` with `SliverList`
    - Navigation stubs: `Navigator.pushNamed` to player selection and game screen routes
    - _Requirements: 8.1, 8.2, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9, 8.10, 8.11, 8.12, 8.13, 8.14_

  - [x] 4.4 Create `lib/features/main_menu/presentation/fake_error_screen.dart`
    - Full-screen modal `StatelessWidget`
    - Display `assets/msg_error.png` via `Image.asset` with error fallback
    - Satirical Spanish error text using `Theme.of(context).textTheme.bodyLarge`
    - `MassiveButton('Cerrar', onPressed: () => Navigator.pop(context))` at bottom
    - DGT color scheme: blue header container, light grey scaffold background
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

  - [x] 4.5 Create `lib/features/main_menu/presentation/fake_news_screen.dart` and `fake_news_detail_screen.dart`
    - `FakeNewsScreen`: `StatelessWidget` with `ListView.builder` of article tiles from static `dgt_strings.dart` list; empty state shows `Center(child: Text('No hay noticias'))`; `AppBar` with back button
    - `FakeNewsDetailScreen`: accepts `FakeNewsArticle`; displays full article with DGT-styled header, body text, and back button
    - Define `FakeNewsArticle` Freezed model and static article list in `lib/core/constants/dgt_strings.dart`
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [x] 5. Checkpoint — Ensure widgets and providers compile
  - Run `dart run build_runner build -d` to regenerate all `.g.dart` and `.freezed.dart` files
  - Run `flutter analyze` and fix all warnings and errors before proceeding
  - Ensure all `package:` imports are used (no relative `../` cross-feature imports)

- [x] 6. Write unit tests for BACCalculator
  - [x] 6.1 Create `test/unit/core/utils/bac_calculator_test.dart`
    - Concrete examples: `calculateOptimalBAC` for all three `BodySize` values (small→2.5, medium→2.0, large→1.8)x
    - Boundary examples: BAC exactly at `optimalBAC ± optimalToleranceClose` and `± optimalToleranceFar`
    - Edge cases: zero time delta returns `0.0` rate; negative BAC delta (BAC decreased)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8_

  - *[ ] 6.2 Write property test — Property 1: BAC zone mutual exclusivity
    - **Property 1: BAC zone functions are mutually exclusive**
    - Loop 200 iterations with `Random(42)`; generate random `bac ∈ [0, 5)` and `optimal ∈ [0.5, 3.5)`
    - Assert at most one of `isInOptimalZone`, `isCloseToOptimal`, `crossedOptimalLine`, `isTooLow` returns `true`
    - **Validates: Requirements 3.2, 3.3, 3.4, 3.5**

  - *[ ] 6.3 Write property test — Property 2: BAC rate linearity
    - **Property 2: BAC rate calculation is linear in time**
    - Loop 200 iterations; generate random `delta ∈ [-2, 2)` and `minutes ∈ (1, 120)`
    - Assert `calculateBACRatePerHour(prev + delta, prev, Duration(minutes: m)) == delta / (m / 60.0)`
    - Assert doubling duration halves rate; doubling delta doubles rate
    - **Validates: Requirements 3.6, 3.7**

- [x] 7. Write unit tests for PointsCalculator
  - [x] 7.1 Create `test/unit/core/utils/points_calculator_test.dart`
    - Concrete examples for each `calculatePointsChange` scenario: optimal zone (+2), close (+1), crossed (-3), dangerous spike (-2), too low (0)
    - Examples for `isImpounded` (BAC = 3.5 → true, BAC = 3.49 → false) and `getImpoundmentPenalty` (-5)
    - Clamping examples: `calculateTotalPoints(19, 5) == 20`, `calculateTotalPoints(1, -5) == 0`
    - `getFeedbackMessage` and `getFeedbackColor` concrete examples for each scenario
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 4.10_

  - *[ ] 7.2 Write property test — Property 3: Points change consistent with zone
    - **Property 3: Points change is determined by zone classification**
    - Loop 200 iterations; generate random `bac` and `optimal`; compute zone; assert `calculatePointsChange` matches expected value for that zone
    - **Validates: Requirements 4.1, 4.2, 4.3, 4.5**

  - *[ ] 7.3 Write property test — Property 4: Total points always clamped
    - **Property 4: Total points are always clamped**
    - Loop 200 iterations; generate random `current ∈ [0, 20]` and `change ∈ [-10, 10]`
    - Assert result is always in `[AppConstants.minPoints, AppConstants.maxPoints]`
    - **Validates: Requirements 4.8**

  - *[ ] 7.4 Write property test — Property 5: Feedback determinism
    - **Property 5: Feedback message and color are deterministic**
    - Loop 200 iterations; generate random `pointsChange ∈ [-10, 10]`
    - Assert calling `getFeedbackMessage` and `getFeedbackColor` twice with same input returns identical non-null results
    - **Validates: Requirements 4.9, 4.10**

- [x] 8. Write unit tests for TitleEvaluator
  - [x] 8.1 Create `test/unit/core/utils/title_evaluator_test.dart`
    - Concrete examples: 5 players with distinct BAC patterns; verify correct title awards for `velocidadDeCrucero`, `lDePracticas`, `vehiculoHibrido`, `itvPassed`
    - Edge cases: Round 1 (no `multaPorExceso` or `vehiculoHibrido`); empty player list; all players crossed optimal line (no `conductorPerfecto`)
    - `getEnvironmentalDistinctives` with fewer than 5 players returns all players
    - `calculateGrandPrizes` concrete examples for each prize
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 5.10, 5.11_

  - *[ ] 8.2 Write property test — Property 6: Per-round title criteria
    - **Property 6: Per-round title winners satisfy their selection criteria**
    - Loop 100 iterations; generate 2–8 players with random BAC readings for rounds 1 and 2
    - Assert `velocidadDeCrucero` winner has minimum `|bac - optimalBAC|`; `lDePracticas` winner has minimum BAC; `vehiculoHibrido` winners all have `currentBAC < previousBAC`; `itvPassed` winners all have `|current - previous| <= 0.01`
    - **Validates: Requirements 5.1, 5.3, 5.4, 5.5**

  - *[ ] 8.3 Write property test — Property 7: Grand prize criteria
    - **Property 7: Grand prize winners satisfy their selection criteria**
    - Loop 100 iterations; generate 2–8 players with random readings and points
    - Assert `conductorPerfecto` winner has max points among players where `crossedOptimalLine == false`; `precisionAbsoluta` winner has minimum average distance; `coleccionistaTitulos` winner has maximum `totalTitles`
    - **Validates: Requirements 5.8, 5.9, 5.10**

  - *[ ] 8.4 Write property test — Property 8: Environmental distinctives sorted descending
    - **Property 8: Environmental distinctives are sorted descending by max BAC**
    - Loop 100 iterations; generate random player lists
    - Assert result length ≤ 5; assert each player's `maxBAC >= nextPlayer.maxBAC`
    - **Validates: Requirements 5.11**

- [x] 9. Write unit tests for CheckpointCalculator
  - [x] 9.1 Create `test/unit/core/utils/checkpoint_calculator_test.dart`
    - Concrete examples: `calculateNextCheckpoint`, `isCheckpointDue` with past/future times, `getTimeRemaining` returns `Duration.zero` when overdue
    - `divideIntoGroups` examples: 20 players into 3 groups → sizes [7, 7, 6]; 1 player into 1 group
    - `suggestNumberOfGroups` boundary examples: 8→1, 9→2, 16→2, 17→3, 24→3, 25→4
    - `formatTimeRemaining` examples: `Duration(minutes: 5, seconds: 3)` → `'05:03'`
    - Edge cases: zero players, `numberOfGroups > players.length` (clamps to player count)
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9_

  - *[ ] 9.2 Write property test — Property 9: Group division preserves count and balances sizes
    - **Property 9: Group division preserves total player count and balances sizes**
    - Loop 100 iterations; generate random player counts (1–50) and group counts (1–10)
    - Assert sum of group sizes equals total player count; assert no two groups differ in size by more than 1
    - **Validates: Requirements 6.5, 6.6**

  - *[ ] 9.3 Write property test — Property 10: Time remaining monotonically decreasing
    - **Property 10: Time remaining is non-negative and monotonically decreasing**
    - Use `fake_async`; generate random `lastMeasurement` and `intervalMinutes`
    - Advance fake time in steps; assert `getTimeRemaining` never increases and returns `Duration.zero` when overdue
    - **Validates: Requirements 6.3, 6.4**

  - *[ ] 9.4 Write property test — Property 11: formatTimeRemaining always produces MM:SS
    - **Property 11: formatTimeRemaining always produces MM:SS format**
    - Loop 100 iterations; generate random non-negative `Duration` values
    - Assert result matches `RegExp(r'^\d{2}:\d{2}$')`
    - **Validates: Requirements 6.8**

- [x] 10. Write unit tests for repositories
  - [x] 10.1 Create `FakeBox` helper in `test/unit/data/repositories/fake_box.dart`
    - Implement `Box<dynamic>` interface (or the minimal subset used by repository impls) using `Map<String, dynamic> _data`
    - Implement `get(key, {defaultValue})`, `put(key, value)`, `delete(key)`, `keys`, `length`, `clear()`, `containsKey(key)`
    - Add a `StreamController` to support `watch()` / `listenable` if repository impls use it
    - _Requirements: 7.1–7.12_

  - [x] 10.2 Create `test/unit/data/repositories/player_repository_test.dart`
    - Inject `FakeBox` into `PlayerRepositoryImpl`; test `save`/`getById` round-trip, `getAll`, `delete`, `update`, `count`, `clearAll`
    - Edge cases: `getById` non-existent ID returns `null`; `delete` non-existent ID does not throw; `update` non-existent entity handles gracefully
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

  - [x] 10.3 Create `test/unit/data/repositories/game_state_repository_test.dart`
    - Inject `FakeBox`; test `save`/`getCurrent` round-trip, `isGameInProgress`, `delete`
    - Edge cases: `getCurrent` when empty returns `null`; `isGameInProgress` returns `false` when no state
    - _Requirements: 7.7, 7.8, 7.9_

  - [x] 10.4 Create `test/unit/data/repositories/checkpoint_repository_test.dart`
    - Inject `FakeBox`; test `save`/`getCurrent` round-trip, `delete`
    - Edge cases: `getCurrent` when empty returns `null`; corrupted JSON returns `null` (not throw)
    - _Requirements: 7.10, 7.11_

  - *[ ] 10.5 Write property test — Property 12: Repository round-trip preserves entity data
    - **Property 12: Repository round-trip preserves entity data**
    - Loop 100 iterations per repository; generate random `PlayerProfile`, `GameState`, `CheckpointState`
    - Assert `save` then `getById`/`getCurrent` returns object equal to original (all fields preserved)
    - **Validates: Requirements 7.1, 7.2, 7.7, 7.10**

  - *[ ] 10.6 Write property test — Property 13: Repository count equals getAll length
    - **Property 13: Repository count equals length of getAll**
    - Loop 100 random sequences of save/delete operations on `PlayerRepository`
    - Assert `count() == (await getAll()).length` after every operation
    - **Validates: Requirements 7.5**

  - *[ ] 10.7 Write property test — Property 14: CheckpointState JSON round-trip
    - **Property 14: CheckpointState JSON round-trip**
    - Loop 100 iterations; generate random `CheckpointState` with arbitrary `DateTime` values and group lists
    - Assert `CheckpointState.fromJson(state.toJson()) == state`
    - **Validates: Requirements 16.2, 16.4**

  - *[ ] 10.8 Write property test — Property 15: GameState JSON round-trip
    - **Property 15: GameState JSON round-trip**
    - Loop 100 iterations; generate random `GameState` with nullable `finishTime` and arbitrary `playerIds`
    - Assert `GameState.fromJson(state.toJson()) == state`
    - **Validates: Requirements 17.2, 17.4**

- [x] 11. Checkpoint — Ensure all unit tests pass
  - Run `flutter test test/unit/` and fix all failures
  - Run `flutter analyze` and resolve any new warnings introduced by test files
  - Ensure all test files use `package:` imports only

- [x] 12. Write integration tests for CheckpointProvider
  - [x] 12.1 Create `integration_test/checkpoint_provider_test.dart`
    - Scenario 1: Create `CheckpointState` with 3 groups via `CheckpointNotifier.initialize()` → verify state persisted to Hive by reading `checkpointRepositoryProvider` directly
    - Scenario 2: Dispose `ProviderContainer` and create a new one → verify `CheckpointNotifier.build()` restores all group timers with `timeRemaining` computed from stored `lastMeasurement`
    - Scenario 3: Advance real time past one group's interval (use short interval, e.g., 1 minute, and `await Future.delayed`) → verify that group's `isDue == true`, other groups remain `isDue == false`
    - Scenario 4: Call `recordPlayerMeasurement` for all players in active group → verify `isCheckpointActive` becomes `false` after last player
    - Scenario 5: Two groups due simultaneously → verify `activeGroupIndex` processes them in ascending index order
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6_

- [x] 13. Final checkpoint — Ensure all tests pass
  - Run `flutter test` (all test suites) and fix any failures
  - Run `flutter analyze` and ensure zero warnings
  - Verify `dart run build_runner build -d` produces no conflicts or errors

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP
- Each task references specific requirements for traceability
- Run `dart run build_runner build -d` after any new `@riverpod`, `@freezed`, or `@JsonSerializable` annotation
- `FakeBox` must implement only the methods actually called by repository impls — check `PlayerRepositoryImpl`, `GameStateRepositoryImpl`, `CheckpointRepositoryImpl` before writing the fake
- Property tests use `dart:math` `Random(42)` for reproducibility — seed is fixed per test, not per iteration
- `fake_async` is required for all timer-dependent tests (Property 10, integration scenario 3 if using fake time)
- No `!` bang operator anywhere; use `?.`, `??`, or null guards
- All widget `build()` methods must stay under ~80–100 lines; extract private widget classes as needed
- Colors from `DGTColors`, text styles from `Theme.of(context).textTheme` — no hardcoded values

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "2.1", "3.1", "3.2", "3.3", "3.4"] },
    { "id": 1, "tasks": ["1.2", "4.1", "4.2"] },
    { "id": 2, "tasks": ["4.3", "4.4", "4.5"] },
    { "id": 3, "tasks": ["6.1", "7.1", "8.1", "9.1", "10.1"] },
    { "id": 4, "tasks": ["6.2", "6.3", "7.2", "7.3", "7.4", "8.2", "8.3", "8.4", "9.2", "9.3", "9.4", "10.2", "10.3", "10.4"] },
    { "id": 5, "tasks": ["10.5", "10.6", "10.7", "10.8"] },
    { "id": 6, "tasks": ["12.1"] }
  ]
}
```
