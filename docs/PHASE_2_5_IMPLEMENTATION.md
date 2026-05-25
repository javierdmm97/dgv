# Phase 2.5 — Implementation Guide

**For:** Claude in a new chat session  
**Branch target:** `feature/develop_2_5` → merge to `main` before Phase 3  
**Created:** May 25, 2026  
**Status:** Ready to implement — no code changes made yet

This document is the technical specification for implementing Phase 2.5. Read `AI_INSTRUCTIONS.md` (the project source of truth) before starting, then use this file as the implementation checklist.

> **All code changes go into `feature/develop_2_5`.** Run `flutter analyze` and `flutter test` before every commit.

---

## Context

Phase 2.5 revises the current game mechanics before Phase 3 adds new features. The app currently has a working game loop (Phase 1+2 complete, 225 tests passing) but the scoring, impoundment, and some title logic need to be updated based on real playtesting feedback. See `changes_2_5.md` at the project root for the original design decisions.

---

## Task List (implement in this order)

---

### Task 1 — BrAC Calculator: DGT Table-Based Progressive Optimal (CRITICAL)

**This is the most fundamental architecture change.** The current `optimalBAC` is a fixed value (2.0–2.5 mg/L) stored per player — those numbers are wrong and physically impossible. The sweet spot must grow each round because players consume more drinks as the night progresses.

**File:** `lib/core/utils/bac_calculator.dart`

**Replace the entire class** with a table-driven approach. The Widmark formula is removed — the breathalyzer gives us BrAC directly; we only need the expected optimal per round.

```dart
class BACCalculator {
  // DGT official BrAC table — midpoints (mg/L) per drink count.
  // Index 0 = 1 drink, index 9 = 10 drinks.
  // Source: DGT official breathalyser equivalence tables (BrAC in mg/L exhaled air).
  //
  // MEN: Small(60-70 kg), Medium(70-90 kg), Large(90-110 kg)
  static const Map<BodySize, List<double>> _menBrACTable = {
    BodySize.small:  [0.15, 0.30, 0.46, 0.61, 0.76, 0.90, 1.05, 1.21, 1.36, 1.51],
    BodySize.medium: [0.13, 0.25, 0.38, 0.50, 0.62, 0.74, 0.87, 0.99, 1.11, 1.24],
    BodySize.large:  [0.10, 0.20, 0.30, 0.40, 0.49, 0.59, 0.69, 0.79, 0.89, 0.98],
  };

  // WOMEN: Small(40-50 kg), Medium(50-70 kg), Large(70-90 kg)
  static const Map<BodySize, List<double>> _womenBrACTable = {
    BodySize.small:  [0.27, 0.54, 0.81, 1.08, 1.35, 1.62, 1.89, 2.16, 2.43, 2.70],
    BodySize.medium: [0.21, 0.42, 0.62, 0.83, 1.03, 1.24, 1.44, 1.65, 1.86, 2.06],
    BodySize.large:  [0.16, 0.31, 0.46, 0.62, 0.77, 0.92, 1.07, 1.22, 1.38, 1.53],
  };

  /// Optimal BrAC for round N. Round 0 = 0.0 (baseline, no target).
  /// Assumes 1 drink per round. Rounds > 10 are capped at round 10.
  static double calculateOptimalBrAC(int roundNumber, Sex sex, BodySize bodySize) {
    if (roundNumber <= 0) return 0.0;
    final drinks = roundNumber.clamp(1, 10);
    final table = sex == Sex.male ? _menBrACTable : _womenBrACTable;
    return table[bodySize]![drinks - 1];
  }

  static bool isInOptimalZone(double currentBrAC, double optimalBrAC) =>
      (currentBrAC - optimalBrAC).abs() <= 0.2;

  static bool isCloseToOptimal(double currentBrAC, double optimalBrAC) {
    final diff = (currentBrAC - optimalBrAC).abs();
    return diff > 0.2 && diff <= 0.4;
  }

  static bool crossedOptimalLine(double currentBrAC, double optimalBrAC) =>
      currentBrAC > (optimalBrAC + 0.4);
}
```

**Where to use it:** Every time points are calculated, pass the current round's optimal:
```dart
final optimal = BACCalculator.calculateOptimalBrAC(currentRound, player.sex, player.bodySize);
final delta = PointsCalculator.calculatePointsChange(currentBrAC: reading, optimalBAC: optimal);
```

**Tests to add:**
```dart
test('round 0 returns 0 for all body types', () {
  expect(BACCalculator.calculateOptimalBrAC(0, Sex.male, BodySize.medium), 0.0);
});
test('men medium at round 5 is 0.62', () {
  expect(BACCalculator.calculateOptimalBrAC(5, Sex.male, BodySize.medium), 0.62);
});
test('women small at round 3 is 0.81', () {
  expect(BACCalculator.calculateOptimalBrAC(3, Sex.female, BodySize.small), 0.81);
});
test('round 11 caps at round 10 value', () {
  expect(
    BACCalculator.calculateOptimalBrAC(11, Sex.male, BodySize.medium),
    BACCalculator.calculateOptimalBrAC(10, Sex.male, BodySize.medium),
  );
});
```

---

### Task 2 — PlayerProfile model changes

**File:** `lib/core/models/player_profile.dart`

**Remove:**
- `@HiveField(10) @Default(false) bool isImpounded`
- `required double optimalBAC` (any HiveField index) — the optimal is now computed per-round, not stored

**Add after `crossedOptimalLine`:**
```dart
@HiveField(10) @Default(0) int fineCount,      // Number of fines received
@HiveField(11) @Default(0) int moneyLost,      // Money lost (next-day game, 100 per fine)
```

**Shift `licenseImagePath` to `@HiveField(12)`** (remove the old HiveField indices for optimalBAC).

**Final field order:**
```dart
@HiveField(0)  required String id,
@HiveField(1)  required String name,
@HiveField(2)  required String surname,
@HiveField(3)  required String photoPath,
@HiveField(4)  required Sex sex,
@HiveField(5)  required BodySize bodySize,
@HiveField(6)  @Default(15) int points,
@HiveField(7)  @Default([]) List<BACReading> readings,
@HiveField(8)  @Default({}) Map<DGTTitle, int> titleCounts,
@HiveField(9)  @Default(false) bool crossedOptimalLine,
@HiveField(10) @Default(0) int fineCount,
@HiveField(11) @Default(0) int moneyLost,
@HiveField(12) required String licenseImagePath,
```

**Run after editing:**
```bash
dart run build_runner build -d
```

**Search for all `player.optimalBAC` usages and replace with the dynamic calculation:**
```bash
grep -rn "\.optimalBAC\|optimalBAC:" lib/ test/
```
Each site should become:
```dart
BACCalculator.calculateOptimalBrAC(currentRound, player.sex, player.bodySize)
```

**Impact:** Any code reading `isImpounded` or `optimalBAC` will fail to compile — use compiler errors as a complete list of sites to fix.

---

### Task 2 — PointsCalculator overhaul

**File:** `lib/core/utils/points_calculator.dart`

Replace the entire `calculatePointsChange` method with the simplified scale. The `timeDelta` and `previousBAC` parameters are removed — the new system does not use spike rate.

**New method signature:**
```dart
static int calculatePointsChange({
  required double currentBAC,
  required double optimalBAC,
})
```

**New logic:**
```dart
// +4: Sweet spot (±0.2 mg/L)
if (BACCalculator.isInOptimalZone(currentBAC, optimalBAC)) return 4;
// +2: Close (±0.4 mg/L)  
if (BACCalculator.isCloseToOptimal(currentBAC, optimalBAC)) return 2;
// -4: Over the line → also triggers Fine
if (BACCalculator.crossedOptimalLine(currentBAC, optimalBAC)) return -4;
// -2: "Policía de la Diversión" — too far below optimal
if (currentBAC < (optimalBAC - 0.4)) return -2;
return 0;
```

**Add new helpers:**
```dart
/// A fine is issued when a measurement gives -4 points.
static bool shouldIssueFine(int pointsChange) => pointsChange <= -4;

/// Perfection score for leaderboard tiebreaker (lower = better).
/// Combines average distance from optimal with its variance.
static double calculatePerfectionScore(
  List<BACReading> readings,
  double optimalBAC,
) {
  if (readings.isEmpty) return double.infinity;
  final avg = calculateAverageDistanceFromOptimal(readings, optimalBAC);
  final variance = readings.map((r) {
    final diff = (r.bac - optimalBAC).abs() - avg;
    return diff * diff;
  }).reduce((a, b) => a + b) / readings.length;
  return avg + variance;
}
```

**Remove:**
- `static bool isImpounded(double currentBAC)` — delete entirely

**Points cap:** Where points are written to Hive/state, enforce `points = min(points + delta, 15)` to prevent exceeding the max. Find all write sites via:
```
grep -r "points +" lib/
```

---

### Task 3 — Fine system (replace impoundment UI)

**Files to change:**

1. **`lib/features/scoring/` (or wherever `FeedbackScreen` / measurement result logic lives)**
   - After calling `calculatePointsChange()`, check `shouldIssueFine(pointsChange)`
   - If true: increment `player.fineCount`, add 100 to `player.moneyLost`, save to Hive
   - Navigate to / show the Fine screen before the regular feedback screen

2. **Create `lib/features/scoring/presentation/fine_screen.dart`** (or similar):
   - Full-screen display of `assets/fine.png`
   - Player name + fine count + money lost so far
   - "Continuar" `MassiveButton` to proceed
   - DGT red color scheme

3. **Delete / disable the Impoundment screen** (find it via `grep -r "isImpounded\|Inmovilizado\|impound" lib/`)
   - Remove navigation to it
   - Remove the "IMPOUNDED" badge overlay from `LicenseCard` and `LicenseGenerator`

4. **Feedback screen messages update:**
   - "+4 points: ¡En la zona!" (green)
   - "+2 points: Cerca del óptimo" (yellow)
   - "0 points: Sin cambios" (neutral gray)
   - "-2 points: ¡Policía de la Diversión!" (blue/dark)
   - "-4 points: ¡Te has pasado! — Multa emitida" (red → triggers FineScreen)

---

### Task 4 — TitleEvaluator updates

**File:** `lib/core/utils/title_evaluator.dart`

**Change `itvPassed` logic:**
- Old: same reading twice (±0.01 mg/L)
- New: player had **negative points last round** AND is **in the zone this round**
- Implementation: check `player.readings` to compare last two rounds

```dart
static List<PlayerProfile> _findITVPassed(List<PlayerProfile> players) {
  return players.where((p) {
    final readings = p.readings.where((r) => r.roundNumber > 0).toList()
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));
    if (readings.length < 2) return false;
    final lastReading = readings[readings.length - 1];
    final prevReading = readings[readings.length - 2];
    // Lost points last round (reading was over or under optimal)
    final wasOutOfZone = !BACCalculator.isInOptimalZone(prevReading.bac, p.optimalBAC) &&
                         !BACCalculator.isCloseToOptimal(prevReading.bac, p.optimalBAC);
    // Now back in zone
    final nowInZone = BACCalculator.isInOptimalZone(lastReading.bac, p.optimalBAC);
    return wasOutOfZone && nowInZone;
  }).toList();
}
```

**Change `vehiculoHibrido` logic:**
- Old: BAC dropped from last round
- New: **Stub — return empty list**. Title is TBD. Leave the enum value in place.

```dart
static List<PlayerProfile> _findHybridVehicles(List<PlayerProfile> players) {
  // vehiculoHibrido title replacement is TBD — returning empty until defined
  return [];
}
```

**Replace `calculateGrandPrizes` with leaderboard sort + titles collector:**

```dart
/// Sort players for leaderboard: primary = points desc, tiebreaker = perfection score asc.
static List<PlayerProfile> calculateLeaderboard(List<PlayerProfile> players) {
  final sorted = [...players];
  sorted.sort((a, b) {
    if (a.points != b.points) return b.points.compareTo(a.points);
    final aScore = PointsCalculator.calculatePerfectionScore(a.readings, a.sex, a.bodySize);
    final bScore = PointsCalculator.calculatePerfectionScore(b.readings, b.sex, b.bodySize);
    return aScore.compareTo(bScore);
  });
  return sorted;
}

/// Returns the player with most accumulated DGT titles (cosmetic joke at end).
static PlayerProfile? getMostTitlesPlayer(List<PlayerProfile> players) {
  if (players.isEmpty) return null;
  return players.reduce((a, b) {
    final aTotal = a.titleCounts.values.fold(0, (s, c) => s + c);
    final bTotal = b.titleCounts.values.fold(0, (s, c) => s + c);
    return aTotal >= bTotal ? a : b;
  });
}
```

---

### Task 5 — Leaderboard provider & reactivity fix

**File:** `lib/features/leaderboard/providers/leaderboard_provider.dart` (or similar)

**Problem:** Leaderboard does not update until screen is reloaded.

**Fix:** Change from a one-shot read to a watched provider. Find the provider that sorts players and make sure it uses `ref.watch` on `playerListNotifierProvider` (not `playerListProvider` or a one-time read).

```dart
@riverpod
List<PlayerProfile> sortedLeaderboard(SortedLeaderboardRef ref) {
  final players = ref.watch(playerListNotifierProvider).value ?? [];
  return TitleEvaluator.calculateLeaderboard(players);
}
```

If using `FutureProvider`, convert to a regular `@riverpod` provider that watches the player list directly so it rebuilds when any player changes.

---

### Task 6 — Round-Robin auto-advance removal

**File:** `lib/features/breathalyzer/presentation/round_robin_screen.dart`

Find any `Timer.periodic` or countdown that auto-advances to the next player and **remove it**. Navigation to the next player should only happen after the user explicitly confirms the BAC entry (taps OK/Confirmar).

---

### Task 7 — Debug skip button for checkpoint timer

**File:** `lib/features/checkpoint/presentation/checkpoint_screen.dart` (or wherever the timer is displayed)

Add a floating button or long-press gesture (in `kDebugMode` only) that calls the equivalent of "skip to now" on the checkpoint timer, triggering an immediate measurement:

```dart
if (kDebugMode)
  FloatingActionButton.small(
    onPressed: () => ref.read(checkpointTimerProvider.notifier).skipToNextCheckpoint(),
    tooltip: 'DEBUG: Skip timer',
    child: const Icon(Icons.fast_forward),
  ),
```

Add `skipToNextCheckpoint()` to `CheckpointTimerNotifier`:
```dart
void skipToNextCheckpoint() {
  _mainTimer?.cancel();
  _triggerCheckpoint();
}
```

---

### Task 8 — OS Push Notifications for checkpoint alerts

**Package to add:** `flutter_local_notifications: ^17.x.x` (check pub.dev for latest)

**Steps:**
1. Add to `pubspec.yaml` dependencies
2. Add `assets/sound/` to `pubspec.yaml` flutter assets (if not already registered):
   ```yaml
   flutter:
     assets:
       - assets/sound/
   ```
3. Initialize `FlutterLocalNotificationsPlugin` in `main.dart`
4. Request permissions on Android (via plugin's `requestPermission()`)
5. Create a notification service: `lib/core/services/notification_service.dart`
6. Call `NotificationService.showCheckpointAlert(groupName)` when a group's measurement begins (`_startGroupMeasurement()` in `CheckpointTimerNotifier`)
7. Use custom sound: `assets/sound/policia_control.mp3`

**Android-specific:**
- Add `VIBRATE` and `SCHEDULE_EXACT_ALARM` (if needed) to `android/app/src/main/AndroidManifest.xml`
- Custom sound file must be placed in `android/app/src/main/res/raw/policia_control.mp3`

---

### Task 9 — Ayuda (Help) button joke screen

**Files:** `lib/features/main_menu/` (presentation layer)

Add a help screen or dialog accessible from the navigation drawer (Ayuda item) with:
- Title: **"¿Necesitas Ayuda?"**
- Line 1 (large): **"Espabila y tómate una bien fría."**
- Line 2 (DGT joke slogan): **"Si bebes, conduce."** *(intentionally reversed — satirical)*
- Image placeholder: use a `Container` with `DGTColors.primary` background for now; the actual image is TBD
- Close button: `MassiveButton` labeled "Cerrar"

This is a simple stateless screen — no Riverpod needed, navigate via `Navigator.push` or `showDialog`.

---

### Task 10 — Update all tests

After all logic changes, update the following test files:

1. **`test/unit/core/utils/bac_calculator_test.dart`** (new or update)
   - Test `calculateOptimalBrAC()` for all sex/bodySize at rounds 1, 5, 10
   - Test round 0 → 0.0 for all combinations
   - Test round > 10 caps at round 10 value
   - Test `isInOptimalZone`, `isCloseToOptimal`, `crossedOptimalLine` with realistic BrAC values

2. **`test/unit/core/utils/points_calculator_test.dart`**
   - Remove all tests for old values (+1, +2, -2, -3, -5)
   - Add tests for new scale (+4, +2, 0, -2, -4)
   - Add test for `shouldIssueFine()`
   - Update `calculatePerfectionScore()` — now takes `sex`+`bodySize`, not `optimalBAC`
   - Update `calculateAverageDistanceFromOptimal()` similarly
   - Remove tests for `isImpounded()`

3. **`test/unit/core/utils/title_evaluator_test.dart`**
   - Update `itvPassed` tests for new "redemption" logic
   - Update `vehiculoHibrido` tests to expect empty list
   - Update `calculateLeaderboard()` tiebreaker tests (no `optimalBAC`)
   - Add tests for `getMostTitlesPlayer()`
   - Remove grand prize tests

4. Any widget tests that assert impoundment badges, old point values, or `optimalBAC`

---

## Files to touch — summary

| File | Change type |
|------|-------------|
| `lib/core/utils/bac_calculator.dart` | **CRITICAL** — Replace with DGT BrAC table lookup, remove Widmark formula |
| `lib/core/models/player_profile.dart` | Remove `isImpounded` + `optimalBAC`, add `fineCount`+`moneyLost`, shift Hive indices |
| `lib/core/utils/points_calculator.dart` | New -4/-2/0/+2/+4 logic, updated signatures (sex+bodySize instead of optimalBAC param) |
| `lib/core/utils/title_evaluator.dart` | Update `itvPassed`/`vehiculoHibrido`, replace grand prizes with leaderboard sort |
| `lib/features/scoring/` (or wherever points are applied) | Fine screen, updated feedback messages, points cap |
| `lib/features/leaderboard/providers/` | Fix reactivity (`ref.watch`), update sort to use `calculateLeaderboard()` |
| `lib/features/breathalyzer/presentation/round_robin_screen.dart` | Remove auto-advance |
| `lib/features/checkpoint/presentation/checkpoint_screen.dart` | Debug skip button |
| `lib/core/services/notification_service.dart` | New file — local push notifications |
| `lib/widgets/license_card.dart` | Remove impoundment overlay |
| `lib/features/fake_id/` (LicenseGenerator) | Remove "IMPOUNDED" badge rendering |
| `lib/features/main_menu/` | Add Ayuda button → joke screen ("Espabila y tómate una bien fría." / "Si bebes, conduce.") |
| `pubspec.yaml` | Add `flutter_local_notifications`, ensure `assets/sound/` registered |
| `android/app/src/main/AndroidManifest.xml` | Notification permissions |
| `android/app/src/main/res/raw/` | Copy `policia_control.mp3` here |
| All affected test files | Update for new logic (see Task 10) |

---

## Search commands to find affected code

```bash
# Find all optimalBAC usages (must all be replaced with dynamic lookup)
grep -rn "\.optimalBAC\|optimalBAC:" lib/ test/

# Find impoundment references
grep -rn "isImpounded\|Inmovilizado\|impound\|IMPOUND" lib/ test/

# Find old point values
grep -rn "return 1\|return -3\|return -5\|return 2;" lib/core/utils/

# Find calculateOptimalBAC (old fixed method — should be gone)
grep -rn "calculateOptimalBAC\|optimalBAC\b" lib/

# Find auto-advance timer in round-robin
grep -rn "Timer.periodic\|autoAdvance\|auto_advance" lib/features/breathalyzer/

# Find calculateGrandPrizes callers
grep -rn "calculateGrandPrizes\|grandPrize\|conductor_perfecto\|precision_absoluta" lib/ test/

# Find where points are written to Hive (for cap enforcement)
grep -rn "\.copyWith(points" lib/
grep -rn "points:" lib/core/providers/ lib/features/scoring/
```

---

## Definition of Done for Phase 2.5

- [ ] `flutter analyze` returns 0 issues
- [ ] `flutter test` passes (all tests updated and passing)
- [ ] `dart format .` has been run
- [ ] `BACCalculator` uses DGT BrAC tables — no fixed optimal values remain in code
- [ ] `grep -rn "optimalBAC" lib/` returns 0 results (field removed from PlayerProfile and all callers updated)
- [ ] `isImpounded` is fully removed — `grep -rn "isImpounded" lib/ test/` returns 0 results
- [ ] Fine screen shows `assets/fine.png` correctly on device when a -4 measurement occurs
- [ ] Leaderboard updates immediately when a BAC entry is saved (no reload needed)
- [ ] Debug skip button works in debug build (`kDebugMode`), not visible in release
- [ ] Push notifications fire when a checkpoint group starts (sound: `policia_control.mp3`)
- [ ] Round-Robin does not auto-advance (manual progression only)
- [ ] Points cannot exceed 15 (hard cap enforced at write time)
- [ ] Ayuda button shows joke screen in navigation drawer
- [ ] PR raised against `main` with this branch (`feature/develop_2_5`)
