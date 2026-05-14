# Design Document: Phase 1 Completion

## Overview

This document describes the technical design for completing Phase 1 of the Operación DGV Flutter application. The work covers four areas: (1) the checkpoint provider for per-group timer management, (2) comprehensive unit tests for existing business logic utilities and repositories, (3) the main menu and supporting screens, and (4) reusable drunk-proof UI widgets.

The existing foundation is solid — Freezed models, Hive-backed repositories, and base Riverpod providers are all in place. This phase wires them together into a working UI and adds the test coverage needed to ship with confidence.

### Key Design Decisions

- **Checkpoint timers are absolute, not relative.** Each `GroupCheckpoint` stores `lastMeasurement` as a `DateTime`. Remaining time is always computed as `nextCheckpoint - DateTime.now()`. This means timers survive app restarts and system clock changes without drift.
- **UI lock is provider state, not widget state.** `isCheckpointActive` and `activeGroupIndex` live in `CheckpointState` (persisted to Hive), so a crash during a checkpoint does not lose the lock.
- **Fake Hive for unit tests.** Repository tests use an in-memory `FakeBox` that implements the same interface as a real Hive box, avoiding the need for `hive_test` or platform channels in unit tests.
- **`fake_async` for timer tests.** All timer-dependent tests use `fake_async` to control time deterministically without real delays.
- **No PBT library for UI widgets.** Widget tests (screens, buttons, keypad) use example-based `flutter_test` widget tests. PBT applies to pure business logic only.

---

## Architecture

The feature-first folder structure is preserved. New files slot into existing layers without restructuring.

```
lib/
├── core/
│   └── providers/
│       └── checkpoint_providers.dart      ← NEW: per-group timer management
├── widgets/
│   ├── massive_button.dart                ← NEW
│   ├── custom_keypad.dart                 ← NEW
│   ├── title_badge.dart                   ← NEW
│   └── license_card.dart                  ← NEW
└── features/
    └── main_menu/
        ├── presentation/
        │   ├── main_menu_screen.dart       ← NEW
        │   ├── fake_news_screen.dart       ← NEW
        │   ├── fake_error_screen.dart      ← NEW
        │   └── widgets/
        │       ├── fake_error_notification.dart  ← NEW
        │       └── fake_news_section.dart         ← NEW
        └── providers/
            └── main_menu_provider.dart     ← NEW

test/
├── unit/
│   ├── core/utils/
│   │   ├── bac_calculator_test.dart       ← NEW
│   │   ├── points_calculator_test.dart    ← NEW
│   │   ├── title_evaluator_test.dart      ← NEW
│   │   └── checkpoint_calculator_test.dart ← NEW
│   └── data/repositories/
│       ├── player_repository_test.dart    ← NEW
│       ├── game_state_repository_test.dart ← NEW
│       └── checkpoint_repository_test.dart ← NEW

integration_test/
└── checkpoint_provider_test.dart          ← NEW
```

### Data Flow

```
Hive Storage
    │
    ▼
CheckpointRepository ──────────────────────────────────────────────┐
    │                                                               │
    ▼                                                               │
CheckpointNotifier (Riverpod)                                       │
    │  - Loads state on build()                                     │
    │  - Runs per-second tick via Timer.periodic                    │
    │  - Persists every state change back to Hive ──────────────────┘
    │
    ▼
CheckpointState (Freezed)
    │  - List<GroupCheckpoint> groups
    │  - bool isCheckpointActive
    │  - int? activeGroupIndex
    │
    ▼
UI Widgets (ConsumerWidget)
    │  - Watch CheckpointNotifier
    │  - Show countdown per group
    │  - Lock navigation when isCheckpointActive
```

---

## Components and Interfaces

### 1. CheckpointNotifier (`lib/core/providers/checkpoint_providers.dart`)

The central provider for all checkpoint timer logic. It owns a single `Timer.periodic` that ticks every second and updates the in-memory state. All mutations persist to Hive immediately.

```dart
@riverpod
class CheckpointNotifier extends _$CheckpointNotifier {
  Timer? _ticker;

  @override
  Future<CheckpointState?> build() async {
    ref.onDispose(() => _ticker?.cancel());
    final repo = ref.watch(checkpointRepositoryProvider);
    final state = await repo.getCurrent();
    if (state != null) _startTicker();
    return state;
  }

  /// Initialize checkpoint state for a new game.
  /// Divides [players] into groups using CheckpointCalculator.
  Future<void> initialize({
    required List<PlayerProfile> players,
    required int intervalMinutes,
  }) async { ... }

  /// Mark all players in the active group as measured.
  /// Resets that group's timer and advances to the next due group (if any).
  Future<void> completeGroupMeasurement(int groupIndex) async { ... }

  /// Called when a single player in the active group logs a reading.
  /// Updates progress but does not unlock until all players are done.
  Future<void> recordPlayerMeasurement(String playerId) async { ... }

  /// Tear down all timers and clear Hive state.
  Future<void> reset() async { ... }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    // Recompute timeRemaining for each group from absolute timestamps.
    // If any group becomes due, set isCheckpointActive = true.
    // Persist updated state to Hive.
  }
}
```

**Supporting read-only providers:**

```dart
/// Stream of checkpoint state for reactive widgets.
@riverpod
Stream<CheckpointState?> checkpointStream(CheckpointStreamRef ref) {
  final repo = ref.watch(checkpointRepositoryProvider);
  return repo.watch();
}

/// Whether any group is currently due for measurement.
@riverpod
bool isCheckpointDue(IsCheckpointDueRef ref) {
  final state = ref.watch(checkpointNotifierProvider).value;
  return state?.isCheckpointActive ?? false;
}

/// Progress for the active group: (completed, total).
@riverpod
(int, int) activeGroupProgress(ActiveGroupProgressRef ref) {
  final state = ref.watch(checkpointNotifierProvider).value;
  if (state?.activeGroup == null) return (0, 0);
  // Count players who have a reading in the current checkpoint window.
  ...
}
```

### 2. MainMenuProvider (`lib/features/main_menu/providers/main_menu_provider.dart`)

Thin provider that aggregates game state and player list for the main menu screen.

```dart
@riverpod
class MainMenuNotifier extends _$MainMenuNotifier {
  @override
  Future<MainMenuState> build() async {
    final gameState = await ref.watch(currentGameStateProvider.future);
    final players = await ref.watch(playerListProvider.future);
    return MainMenuState(
      isGameInProgress: gameState?.isInProgress ?? false,
      players: players,
      isFakeErrorVisible: true, // shown by default, dismissed by user
    );
  }

  void dismissFakeError() {
    state = AsyncData(state.value!.copyWith(isFakeErrorVisible: false));
  }
}

@freezed
class MainMenuState with _$MainMenuState {
  const factory MainMenuState({
    required bool isGameInProgress,
    required List<PlayerProfile> players,
    @Default(true) bool isFakeErrorVisible,
  }) = _MainMenuState;
}
```

### 3. Reusable Widgets

#### MassiveButton (`lib/widgets/massive_button.dart`)

```dart
class MassiveButton extends StatelessWidget {
  const MassiveButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isEnabled = true,
    this.backgroundColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isEnabled;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) { ... }
}
```

Constraints:
- `minHeight: 80` via `ButtonStyle.minimumSize`
- Font: `Theme.of(context).textTheme.titleLarge` (24sp bold)
- Background: `DGTColors.primary` (overridable)
- Disabled: `opacity: 0.5`, `onPressed: null`
- Haptic: `HapticFeedback.mediumImpact()` on tap
- Border radius: `BorderRadius.circular(12)`

#### CustomKeypad (`lib/widgets/custom_keypad.dart`)

Manages its own input buffer as local state (a `List<int>` of up to 2 digits). Formats display as `0.XX`.

```dart
class CustomKeypad extends StatefulWidget {
  const CustomKeypad({
    super.key,
    required this.onConfirm,
    this.initialValue,
  });

  final void Function(double value) onConfirm;
  final double? initialValue;
}
```

Layout: `GridView` with `crossAxisCount: 3`, cells `80×80`. Rows: `[1,2,3]`, `[4,5,6]`, `[7,8,9]`, `[⌫, 0, ✓]`.

Input logic:
- Buffer holds 0–2 digits (e.g., `[4, 5]` → displays `0.45`)
- Backspace removes last digit
- Confirm disabled when buffer is empty
- Haptic on every tap

#### TitleBadge (`lib/widgets/title_badge.dart`)

```dart
class TitleBadge extends StatelessWidget {
  const TitleBadge({
    super.key,
    required this.title,
    required this.count,
  });

  final DGTTitle title;
  final int count;
}
```

- `count == 0`: grayed-out icon, no counter text
- `count >= 1`: full-color icon + `×N` counter
- Layout: `Row([icon, Text('×$count')])`

#### LicenseCard (`lib/widgets/license_card.dart`)

```dart
class LicenseCard extends StatelessWidget {
  const LicenseCard({
    super.key,
    required this.player,
    this.onTap,
  });

  final PlayerProfile player;
  final VoidCallback? onTap;
}
```

Layout sections:
1. Header: circular photo crop (`CircleAvatar`) + name/surname
2. Points: large number, `DGTColors.primary`
3. Badges: `Row` of `TitleBadge` for each `DGTTitle`
4. Impounded overlay: `VEHÍCULO INMOVILIZADO` banner when `player.isImpounded`
5. Optimal BAC reference: small text at bottom

Background: `DGTColors.licenseId` (`#F3E8EC`). Card elevation: 4. Border radius: 12.

### 4. Screens

#### MainMenuScreen (`lib/features/main_menu/presentation/main_menu_screen.dart`)

`ConsumerWidget` watching `mainMenuNotifierProvider`. Decomposed into private widget classes to keep `build()` under 80 lines:

- `_MainMenuHeader` — DGT logo + menu icon
- `FakeErrorNotification` — dismissible top bar (extracted to `widgets/fake_error_notification.dart`)
- `_GameActionSection` — Start/Resume `MassiveButton`
- `_MisVehiculosSection` — Add Player button + `ListView` of `LicenseCard`
- `FakeNewsSection` — scrollable article list (extracted to `widgets/fake_news_section.dart`)

#### FakeNewsScreen (`lib/features/main_menu/presentation/fake_news_screen.dart`)

Two sub-screens via a simple `Navigator.push`:
- List view: `ListView.builder` of article tiles (title, thumbnail, date)
- Detail view: `FakeNewsDetailScreen` with full article content, DGT-styled header

Articles are static data defined in `dgt_strings.dart` (no network calls).

#### FakeErrorScreen (`lib/features/main_menu/presentation/fake_error_screen.dart`)

Full-screen modal. Shows a styled error card with satirical Spanish text and a `MassiveButton('Cerrar')` that calls `Navigator.pop`.

---

## Data Models

### CheckpointState (existing, verified)

```dart
@freezed
class GroupCheckpoint with _$GroupCheckpoint {
  const factory GroupCheckpoint({
    required int groupIndex,
    required List<String> playerIds,
    required DateTime lastMeasurement,
    required int intervalMinutes,
    @Default(null) DateTime? nextCheckpoint,
  }) = _GroupCheckpoint;
}

@freezed
class CheckpointState with _$CheckpointState {
  const factory CheckpointState({
    required int currentRound,
    required int intervalMinutes,
    required List<GroupCheckpoint> groups,
    @Default(false) bool isCheckpointActive,
    @Default(null) int? activeGroupIndex,
  }) = _CheckpointState;
}
```

The `nextCheckpoint` field on `GroupCheckpoint` is a cached value. The canonical source of truth is always `lastMeasurement + Duration(minutes: intervalMinutes)`. The provider recomputes this on every tick.

### GameState (existing, verified)

```dart
@freezed
class GameState with _$GameState {
  const factory GameState({
    required String id,
    required DateTime startTime,
    required int currentRound,
    @Default(false) bool isInProgress,
    @Default(false) bool isFinished,
    @Default([]) List<String> playerIds,
    @Default(null) DateTime? lastCheckpointTime,
    @Default(null) DateTime? finishTime,
  }) = _GameState;
}
```

Both models use `json_serializable` via Freezed. `DateTime` fields serialize to ISO 8601 strings. `List` fields serialize to JSON arrays (never `null`).

### FakeNewsArticle (new, static data)

```dart
@freezed
class FakeNewsArticle with _$FakeNewsArticle {
  const factory FakeNewsArticle({
    required String id,
    required String title,
    required String summary,
    required String body,
    required String date,
    required String imagePath,
  }) = _FakeNewsArticle;
}
```

Defined as a `const List<FakeNewsArticle>` in `dgt_strings.dart`. No persistence needed.

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Property-based testing applies to the pure business logic layer: `BACCalculator`, `PointsCalculator`, `TitleEvaluator`, `CheckpointCalculator`, repository round-trips, and JSON serialization. The PBT library used is [`dart_test`](https://pub.dev/packages/test) with a custom generator helper (since `dart` does not have a mainstream PBT library like QuickCheck, we implement lightweight generators using `dart:math` `Random` and run each property 200 times in a loop).

**Property Reflection:**

Before listing properties, redundancy is eliminated:
- Requirements 3.2–3.5 (zone membership) and 4.1–4.5 (points from zone) are related but not redundant: zone functions are tested independently, then points functions are tested as compositions. They are kept separate.
- Requirements 1.4 and 1.5 (Hive persistence and restart recovery) both test round-trip persistence. They are combined into a single "checkpoint state round-trip" property.
- Requirements 16.2 and 16.4 both describe the same JSON round-trip for `CheckpointState`. Combined into one property.
- Requirements 17.1 and 17.4 similarly combined for `GameState`.
- Requirements 6.5 and 6.6 (group division) are combined: total count preserved AND sizes differ by at most 1.
- Requirements 5.1–5.5 (per-round title awards) are kept separate because they test different winner-selection criteria.

---

### Property 1: BAC zone functions are mutually exclusive

*For any* non-negative BAC value and positive optimal BAC value, at most one of `isInOptimalZone`, `isCloseToOptimal`, `crossedOptimalLine`, and `isTooLow` returns `true`.

**Validates: Requirements 3.2, 3.3, 3.4, 3.5**

---

### Property 2: BAC rate calculation is linear in time

*For any* BAC delta and non-zero positive duration, `calculateBACRatePerHour(current, previous, duration)` equals `(current - previous) / (duration.inMinutes / 60.0)`. Doubling the duration halves the rate; doubling the delta doubles the rate.

**Validates: Requirements 3.6, 3.7**

---

### Property 3: Points change is determined by zone classification

*For any* BAC and optimal BAC pair, `calculatePointsChange` returns a value consistent with the zone classification: `+2` when `isInOptimalZone`, `+1` when `isCloseToOptimal`, `-3` when `crossedOptimalLine`, `0` when `isTooLow`.

**Validates: Requirements 4.1, 4.2, 4.3, 4.5**

---

### Property 4: Total points are always clamped

*For any* current points value and points change, `calculateTotalPoints(current, change)` always returns a value in `[AppConstants.minPoints, AppConstants.maxPoints]`.

**Validates: Requirements 4.8**

---

### Property 5: Feedback message and color are deterministic

*For any* points change value, calling `getFeedbackMessage` and `getFeedbackColor` twice with the same input always returns the same non-null result.

**Validates: Requirements 4.9, 4.10**

---

### Property 6: Per-round title winners satisfy their selection criteria

*For any* list of players with distinct BAC readings for a given round:
- The `velocidadDeCrucero` winner has the minimum `|bac - optimalBAC|` among all players with readings.
- The `lDePracticas` winner has the minimum current BAC.
- Every player awarded `vehiculoHibrido` has `currentBAC < previousBAC`.
- Every player awarded `itvPassed` has `|currentBAC - previousBAC| <= 0.01`.

**Validates: Requirements 5.1, 5.3, 5.4, 5.5**

---

### Property 7: Grand prize winners satisfy their selection criteria

*For any* list of players with readings:
- The `conductor_perfecto` winner has the maximum points among players where `crossedOptimalLine == false`.
- The `precision_absoluta` winner has the minimum average distance from their optimal BAC.
- The `coleccionista_titulos` winner has the maximum `totalTitles`.

**Validates: Requirements 5.8, 5.9, 5.10**

---

### Property 8: Environmental distinctives are sorted descending by max BAC

*For any* list of players, `getEnvironmentalDistinctives` returns a list of at most 5 players where each player's `maxBAC` is greater than or equal to the next player's `maxBAC`.

**Validates: Requirements 5.11**

---

### Property 9: Group division preserves total player count and balances sizes

*For any* list of players and valid `numberOfGroups`, `divideIntoGroups` produces groups whose sizes sum to the total player count, and no two groups differ in size by more than 1.

**Validates: Requirements 6.5, 6.6**

---

### Property 10: Time remaining is non-negative and monotonically decreasing

*For any* `lastMeasurement` and `intervalMinutes`, `getTimeRemaining` returns `Duration.zero` when the checkpoint is overdue, and a positive duration otherwise. As simulated time advances, the returned duration never increases.

**Validates: Requirements 6.3, 6.4**

---

### Property 11: formatTimeRemaining always produces MM:SS format

*For any* non-negative `Duration`, `formatTimeRemaining` returns a string matching the pattern `^\d{2}:\d{2}$` (two-digit minutes, colon, two-digit seconds).

**Validates: Requirements 6.8**

---

### Property 12: Repository round-trip preserves entity data

*For any* valid `PlayerProfile`, `GameState`, or `CheckpointState`, saving the entity to the repository and immediately retrieving it by key produces an object equal to the original (all fields preserved).

**Validates: Requirements 7.1, 7.2, 7.7, 7.10**

---

### Property 13: Repository count equals length of getAll

*For any* sequence of save and delete operations, `count()` always equals `getAll().length`.

**Validates: Requirements 7.5**

---

### Property 14: CheckpointState JSON round-trip

*For any* valid `CheckpointState` (including nested `GroupCheckpoint` list with arbitrary `DateTime` values), `CheckpointState.fromJson(state.toJson())` produces an object equal to the original.

**Validates: Requirements 16.2, 16.4**

---

### Property 15: GameState JSON round-trip

*For any* valid `GameState` (including nullable `finishTime` and arbitrary `playerIds` list), `GameState.fromJson(state.toJson())` produces an object equal to the original.

**Validates: Requirements 17.2, 17.4**

---

### Property 16: Checkpoint timer independence

*For any* `CheckpointState` with multiple groups, updating one group's `lastMeasurement` (via `completeGroupMeasurement`) does not change any other group's `lastMeasurement` or `intervalMinutes`.

**Validates: Requirements 1.1, 1.3**

---

### Property 17: Checkpoint state persistence round-trip

*For any* `CheckpointState`, saving it to Hive and loading it in a new `CheckpointNotifier` instance produces a state where each group's `timeRemaining` is correctly computed from the stored `lastMeasurement` and `intervalMinutes` relative to the current time.

**Validates: Requirements 1.4, 1.5**

---

### Property 18: UI lock is released exactly when all active group players are measured

*For any* group of N players, `isCheckpointActive` remains `true` until exactly N readings have been recorded for that group's checkpoint window, at which point it becomes `false`.

**Validates: Requirements 2.3, 2.4, 2.5**

---

### Property 19: CustomKeypad input always formats as 0.XX

*For any* sequence of 0–2 digit button taps, the displayed value is always in the format `0.XX` where XX are the entered digits (zero-padded on the right if fewer than 2 digits entered).

**Validates: Requirements 12.3**

---

## Error Handling

### Provider Error States

All `AsyncNotifier` providers use `AsyncValue` which carries `AsyncError` states. Widgets consuming providers must handle all three states:

```dart
ref.watch(checkpointNotifierProvider).when(
  data: (state) => _buildContent(state),
  loading: () => const CircularProgressIndicator(),
  error: (e, st) => _buildErrorFallback(e),
);
```

### Hive Read Failures

If Hive returns malformed JSON (e.g., after a partial write), `fromJson` will throw a `TypeError` or `FormatException`. Repository implementations catch these and return `null` (treating corrupted state as absent). The provider then initializes fresh state.

```dart
Future<CheckpointState?> getCurrent() async {
  try {
    final json = box.get(_key) as String?;
    if (json == null) return null;
    return CheckpointState.fromJson(jsonDecode(json) as Map<String, dynamic>);
  } on FormatException {
    return null; // Corrupted data — start fresh
  } on TypeError {
    return null;
  }
}
```

### Timer Edge Cases

- **App suspended longer than checkpoint interval:** On resume, `_tick()` runs immediately. If `timeRemaining <= 0`, the group is marked due. The provider does not attempt to "catch up" missed ticks — it simply marks all overdue groups as due simultaneously and processes them sequentially.
- **System clock change:** Because remaining time is always computed from absolute `DateTime` values, a clock change is handled correctly on the next tick.
- **Zero players in group:** `divideIntoGroups` with `numberOfGroups > players.length` clamps to `players.length`. An empty group list results in no timers being started.

### Widget Error Handling

- `LicenseCard` with a missing photo path: falls back to a `CircleAvatar` with initials.
- `CustomKeypad` rapid tapping: the input buffer is bounded to 2 digits; additional taps beyond the limit are silently ignored (no debounce needed since the buffer is the natural throttle).
- `FakeNewsScreen` with empty article list: shows a centered `Text('No hay noticias')` placeholder.

---

## Testing Strategy

### Unit Tests (test/unit/)

**Framework:** `flutter_test` / `dart:test`  
**Fakes:** Hand-written `FakeBox` implementing Hive's `Box` interface for repository tests  
**Timer control:** `fake_async` package for all timer-dependent tests  
**PBT approach:** Custom generator loop (200 iterations per property) using `dart:math` `Random`

#### BACCalculator tests (`test/unit/core/utils/bac_calculator_test.dart`)

- Property 1: Zone mutual exclusivity (200 random `(bac, optimal)` pairs)
- Property 2: Rate linearity (200 random `(delta, duration)` pairs)
- Examples: boundary values at exactly `±0.2`, `±0.4`, `0.0` BAC
- Edge cases: zero time delta returns `0.0` rate; negative delta (BAC decreased)

#### PointsCalculator tests (`test/unit/core/utils/points_calculator_test.dart`)

- Property 3: Points from zone (200 random pairs, verify consistency with zone functions)
- Property 4: Total points clamping (200 random `(current, change)` pairs)
- Property 5: Feedback determinism (200 random points change values)
- Examples: each scenario with concrete values

#### TitleEvaluator tests (`test/unit/core/utils/title_evaluator_test.dart`)

- Property 6: Per-round title criteria (100 random player lists, 2–8 players)
- Property 7: Grand prize criteria (100 random player lists)
- Property 8: Environmental distinctives sorting (100 random player lists)
- Edge cases: Round 1 (no spike/hybrid), all players crossed line, fewer than 5 players

#### CheckpointCalculator tests (`test/unit/core/utils/checkpoint_calculator_test.dart`)

- Property 9: Group division (100 random player counts and group counts)
- Property 10: Time remaining monotonicity (using `fake_async`)
- Property 11: Format string pattern (100 random durations)
- Examples: `suggestNumberOfGroups` boundary values

#### Repository tests (`test/unit/data/repositories/`)

Each repository test file uses a `FakeBox` that stores data in a `Map<String, String>`:

```dart
class FakeBox implements Box {
  final _data = <String, String>{};

  @override
  dynamic get(key, {defaultValue}) => _data[key as String] ?? defaultValue;

  @override
  Future<void> put(key, value) async => _data[key as String] = value as String;

  @override
  Future<void> delete(key) async => _data.remove(key as String);

  @override
  Iterable get keys => _data.keys;

  @override
  int get length => _data.length;

  @override
  Future<int> clear() async { _data.clear(); return 0; }

  @override
  bool containsKey(key) => _data.containsKey(key as String);
}
```

- Property 12: Round-trip persistence (100 random entities per repository)
- Property 13: Count invariant (100 random sequences of save/delete)
- Examples: CRUD operations with concrete data
- Edge cases: retrieve non-existent ID, delete non-existent ID, update non-existent entity

### Widget Tests (test/widget/)

**Framework:** `flutter_test`  
**Provider overrides:** `ProviderScope` with `overrideWithValue` / `overrideWith`

Key widget tests:
- `MassiveButton`: height >= 80, text style, disabled state, onPressed callback
- `CustomKeypad`: digit input, backspace, format as `0.XX`, confirm callback, disabled when empty
- `TitleBadge`: icon per title type, counter display, grayed-out at count=0
- `LicenseCard`: player data display, impounded badge, onTap callback
- `MainMenuScreen`: Start/Resume button conditional on game state, fake error dismissal, player list
- `FakeNewsScreen`: article list, navigation to detail, back button
- `FakeErrorScreen`: close button dismisses screen

### Integration Tests (integration_test/)

**Framework:** `integration_test` package  
**Target:** Real device or emulator with actual Hive initialization

`checkpoint_provider_test.dart` covers:
1. Create checkpoint state with 3 groups → verify persisted to Hive
2. Simulate app restart (dispose and recreate `ProviderContainer`) → verify timers restored
3. Advance time past one group's interval → verify that group becomes due, others remain active
4. Complete all players in active group → verify UI unlocks and next due group activates
5. Multiple groups due simultaneously → verify sequential processing in index order

### Coverage Targets

| Layer | Target |
|---|---|
| `BACCalculator` | ≥ 90% |
| `PointsCalculator` | ≥ 90% |
| `TitleEvaluator` | ≥ 90% |
| `CheckpointCalculator` | ≥ 90% |
| Repository implementations | ≥ 85% |
| `CheckpointNotifier` | ≥ 80% |

Run with: `flutter test --coverage`

### Property Test Configuration

Each property test runs a minimum of **200 iterations** using a seeded `Random` for reproducibility. Tag format in test comments:

```dart
// Feature: phase-1-completion, Property 1: BAC zone functions are mutually exclusive
test('zone functions are mutually exclusive', () {
  final rng = Random(42);
  for (var i = 0; i < 200; i++) {
    final bac = rng.nextDouble() * 5.0;
    final optimal = rng.nextDouble() * 3.0 + 0.5;
    // ... assertions
  }
});
```
