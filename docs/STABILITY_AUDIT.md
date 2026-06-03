# Operación DGV — Stability Audit
**Pass 1 of N** | Goal: zero surprises on Friday

---

## Context

The app works correctly after a clean install / cache clear. Random bugs (timers
auto-firing, "0/N players measured", always stuck on "Ir al Retén") appear after
restarts, debug seeding, or round-robin aborts. Root cause: **stale persisted state
that survives app restarts without being sanitized**.

---

## Issues Found — Pass 1

---

### 🔴 ISSUE-01 — Timer auto-fires on app restart → immediate "Ir al Retén"

**Severity:** Critical (party-day risk)  
**File:** `lib/core/providers/checkpoint_providers.dart`  
**Method:** `CheckpointNotifier.build()` (lines 38–46)

**What happens:**

```dart
final existing = await repo.getCurrent();
if (existing != null) {
  _startTicker();
}
return existing;
```

`CheckpointState` is persisted to Hive on every tick. Each `GroupCheckpoint` stores
an **absolute `nextCheckpoint: DateTime`**. When Android kills the app (low memory,
screen off for the interval duration, OS decides to reclaim resources) and the user
reopens it, `CheckpointNotifier.build()` restores the Hive state verbatim.

Those `nextCheckpoint` timestamps are **in the past**. Within 1 second, `_tick()`
fires and evaluates `g.isDue` for every group:

```dart
// GroupCheckpointX.isDue:
bool get isDue => timeRemaining.inSeconds <= 0;
// timeRemaining computes: nextCheckpoint.difference(DateTime.now())
// If nextCheckpoint was 45 min ago → timeRemaining is negative → isDue = true
```

Every group is immediately `isDue`. The notifier activates all of them
simultaneously, `isCheckpointActive` flips to `true`, and the CheckpointScreen
shows "Ir al Retén" the instant the app opens — before anyone has touched anything.

**Why the jitter fix in `initialize()` doesn't help here:**  
The 10–40 s random jitter is applied when groups are first created. That value is
already baked into `nextCheckpoint` in Hive. On restore it has no effect.

**Scenario that reliably reproduces it:**  
1. Start a game, let the checkpoint run for one interval (or use skip-to-next).  
2. Force-stop the app from Android Settings (or let the OS kill it).  
3. Re-open the app.  
4. The checkpoint screen immediately shows all groups as due.

**Fix (not applied yet):**  
In `build()`, after loading from Hive, check if any group's `nextCheckpoint` is in
the past. If so, push it forward by `intervalMinutes` from `now` and save the
sanitized state before starting the ticker. Also clear `isCheckpointActive` and
`activeGroupIndex` so the UI doesn't open in "measuring" mode.

```dart
var existing = await repo.getCurrent();
if (existing != null) {
  final now = DateTime.now();
  if (existing.groups.any((g) => g.isDue)) {
    final sanitized = existing.copyWith(
      groups: existing.groups.map((g) {
        if (!g.isDue) return g;
        return g.copyWith(
          nextCheckpoint: now.add(Duration(minutes: g.intervalMinutes)),
        );
      }).toList(),
      isCheckpointActive: false,
      activeGroupIndex: null,
    );
    await repo.save(sanitized);
    existing = sanitized;
  }
  _startTicker();
}
return existing;
```

---

### 🔴 ISSUE-02 — `resetGame()` does not reset `isIncautado`

**Severity:** High (wrong game state carried into new game)  
**File:** `lib/features/main_menu/providers/main_menu_provider.dart`  
**Method:** `MainMenuNotifier.resetGame()` (lines 59–83)

**What happens:**

```dart
await repo.update(
  player.copyWith(
    points: 15,
    readings: const [],
    titleCounts: const {},
    crossedOptimalLine: false,
    fineCount: 0,
    moneyLost: 0,
    licenseImagePath: '',
    licenseBackImagePath: '',
    // ← isIncautado is NOT reset
  ),
);
```

Pressing "Nueva Partida" from the main menu calls `resetGame()`. An incautado player
will carry `isIncautado: true` into the new game, remaining blocked from
measurements permanently.

**Note:** The parallel bug in `_returnToMenu` (final ceremony → menu) was already
fixed in a prior session. This is the same omission in a different code path.

**Fix (not applied yet):**  
Add `isIncautado: false` to the `copyWith` call.

---

### 🟡 ISSUE-03 — Debug "Borrar todos" leaves orphaned game + checkpoint state

**Severity:** Medium during testing, zero on party day  
**File:** `lib/features/main_menu/presentation/main_menu_screen.dart`  
**Method:** `_DebugSeedSection._clear()` (lines 675–679)

**What happens:**

```dart
Future<void> _clear(WidgetRef ref) async {
  final repo = ref.read(playerRepositoryProvider);
  await repo.clearAll();          // ← wipes player Hive box
  ref.invalidate(playerListNotifierProvider);
  // ← game state NOT cleared
  // ← checkpoint state NOT cleared (timer still running!)
}
```

If you tap "Borrar todos" mid-game:
- The game state still says `isInProgress: true` with the old player IDs.
- The checkpoint timer is still ticking with group memberships pointing to
  now-deleted player IDs.
- The next `_tick()` tries to evaluate groups whose `playerIds` have no
  corresponding players in the player repository.
- `_measuredPlayerIdsByGroup` accumulates counts for ghost IDs that can never
  complete a group → group never advances → checkpoint never completes.

After seeding again with "Seed 7 jugadores", new players get new UUIDs. The old
player IDs in the checkpoint groups will never match, so the "0/N measured" counter
stays broken until a fresh `initialize()` call.

**Why this doesn't matter on Friday:**  
`_DebugSeedSection` is wrapped in `if (kDebugMode)` in the build method. A release
APK (`flutter build apk --release`) sets `kDebugMode = false` at compile time, so
the entire widget is dead code and never rendered.

**Fix (not applied yet — low priority):**  
`_clear()` should also call `checkpointNotifierProvider.notifier.reset()` and
`gameStateNotifierProvider.notifier.deleteGame()` before clearing players.

---

### 🟡 ISSUE-04 — `_onRoundComplete` fire-and-forget race with `advanceRound()`

**Severity:** Low (data loss only if app is killed in a narrow window)  
**File:** `lib/core/providers/checkpoint_providers.dart`  
**Method:** `CheckpointNotifier._onRoundComplete()` (lines 173–235)

**What happens:**

```dart
unawaited(
  RoundCompletionService.evaluateAndApply(   // ← writes title counts to Hive
    players: players,
    round: completedRound,
    repo: playerRepo,
  ).then((awards) {
    ref.invalidate(playerListNotifierProvider);
    // ...sync, notifications...
  }),
);

await ref.read(gameStateNotifierProvider.notifier).advanceRound(); // ← runs immediately
```

`evaluateAndApply` writes title awards (`titleCounts`) and license images to Hive
for each player. This happens **concurrently** with `advanceRound()`. If the OS
kills the app in the window between `_onRoundComplete` being called and
`evaluateAndApply` finishing, the round's title awards are lost. The round counter
advances but no player received their titles.

**Additional concern:** `ref.invalidate(playerListNotifierProvider)` inside the
`then` callback fires after `advanceRound()` completes. If the checkpoint screen
reads the player list immediately after the round advances, it may see stale data
(no title counts yet) for a brief moment. In practice this is fine since the
leaderboard screen navigates after a short delay.

**Why it's acceptable:**  
The comment at line 341 already acknowledges that in-memory state is acceptable for
a party game context. The `unawaited` pattern here is consistent with that design
philosophy. The window for data loss is very small (milliseconds).

**Fix if desired (not applied):**  
`await` the `evaluateAndApply` call before `advanceRound()`. The tradeoff is a
slightly longer pause before the round advances (sequential instead of concurrent).

---

### 🟡 ISSUE-05 — `_measuredPlayerIdsByGroup` is in-memory; resets on provider rebuild

**Severity:** Low in production, reproducible in testing  
**File:** `lib/core/providers/checkpoint_providers.dart`  
**Field:** `_measuredPlayerIdsByGroup` (line 337)

**What happens:**

```dart
final Map<int, Set<String>> _measuredPlayerIdsByGroup = {};
```

This map tracks which players have submitted a measurement in the current checkpoint
window. It is an instance field on `CheckpointNotifier` — it exists only in memory.

`hasMeasuredInWindow()` reads it:

```dart
bool hasMeasuredInWindow(String playerId, DateTime windowStart) {
  return _measuredPlayerIdsByGroup.values.any((s) => s.contains(playerId));
}
```

And `activeGroupProgress` uses it to compute the "X/N measured" counter shown in
the UI.

If `CheckpointNotifier` is rebuilt (because its `build()` is re-invoked), the
instance is recreated and the map starts empty. Players who already measured now
show as unmeasured ("0/N") even though their BAC readings are already in Hive.

**What causes a rebuild:**  
Any provider that `CheckpointNotifier.build()` watches (`checkpointRepositoryProvider`)
getting invalidated would trigger a rebuild. In practice this doesn't happen in
production (nothing invalidates it). During testing, hot reload can trigger it.

**The comment acknowledges this:**
> "In-memory only — acceptable because if the app restarts mid-round the players
> just re-measure (party game context)."

**Fix if desired (not applied):**  
On rebuild, cross-reference `_measuredPlayerIdsByGroup` against recent BAC readings
in the restored `CheckpointState` to partially reconstruct who has measured this
window. But this adds complexity and the existing behavior is documented as
intentional.

---

---

---

## Issues Found — Pass 2

Pass 2 covered: player selection flow, game start / cancel flow, round-robin submit
logic, checkpoint screen, leaderboard provider, Firebase sync, notification service,
and the awards bottom sheet.

---

### 🔴 ISSUE-06 — `skipToNextCheckpoint` FAB is visible in production builds

**Severity:** Critical (party-day risk)  
**File:** `lib/features/checkpoint/presentation/checkpoint_screen.dart`  
**Lines:** 79–98 (the `floatingActionButton` in `CheckpointScreen.build()`)

**What happens:**

```dart
floatingActionButton: FloatingActionButton.small(
  onPressed: () {
    ref.read(checkpointNotifierProvider.notifier).skipToNextCheckpoint();
    // also fires a test notification
  },
  tooltip: 'Saltar timer + probar notificación',
  child: const Icon(Icons.fast_forward),
),
```

This button is **always rendered** — there is no `kDebugMode` guard. In a release
APK (`flutter build apk --release`), any player at the party who sees the ⏩ button
and taps it immediately forces the earliest group's timer to expire and triggers
"Ir al Retén". The game timer is corrupted.

Compare with the debug seed section in `main_menu_screen.dart`, which is correctly
gated with `if (kDebugMode) const _DebugSeedSection()`. This FAB has no equivalent
guard.

**Fix (not applied yet):**  
Wrap the `floatingActionButton` parameter with `kDebugMode ? FloatingActionButton.small(...) : null`.

---

### 🟡 ISSUE-07 — `_cancelGame` in round 0 does not reset checkpoint state if somehow initialized

**Severity:** Low (edge case only)  
**File:** `lib/features/breathalyzer/presentation/round_robin_screen.dart`  
**Method:** `_cancelGame()` (lines 160–185)

**What happens:**

```dart
Future<void> _cancelGame() async {
  // ... dialog ...
  await ref.read(gameStateNotifierProvider.notifier).deleteGame();
  if (mounted) Navigator.pop(context);
  // ← checkpointNotifier.reset() is NOT called
}
```

Round 0 is the initial measurements screen (`_round == 0`). `initialize()` is called
**after** `_submitAll()` completes in `_finishGroup()`. So normally, cancelling
during round 0 leaves no checkpoint state to clean up.

However: if someone presses "Iniciar Control", enters the round-robin screen, then
taps the back button to cancel — and an old checkpoint state from a previous game
was NOT properly cleaned up (e.g., due to ISSUE-01 scenario) — that stale
checkpoint state remains in Hive and keeps its timer running. `deleteGame()` only
deletes the game state box, not the checkpoint box.

**Why it's low severity:**  
In a properly reset game (`resetGame()` was called), the checkpoint state IS cleared
before the game starts. Only matters if a previous game ended without calling
`resetGame()` or `finishGame()`.

**Fix (not applied yet):**  
In `_cancelGame()`, also call `checkpointNotifier.reset()`:
```dart
await ref.read(checkpointNotifierProvider.notifier).reset();
await ref.read(gameStateNotifierProvider.notifier).deleteGame();
```

---

### 🟡 ISSUE-08 — Round awards bottom sheet can be dismissed without clearing provider

**Severity:** Medium (UX glitch, not a data loss)  
**File:** `lib/features/checkpoint/presentation/checkpoint_screen.dart`  
**Method:** `_showAwardsSheet()` (lines 43–56)

**What happens:**

The `lastRoundAwardsProvider` is set to the current round's awards inside
`_onRoundComplete`. The CheckpointScreen listens to it and shows a bottom sheet:

```dart
showModalBottomSheet<void>(
  context: context,
  builder: (ctx) => _RoundAwardsSheet(
    onClose: () {
      ref.read(lastRoundAwardsProvider.notifier).state = null;
      Navigator.pop(ctx);
    },
  ),
);
```

The `lastRoundAwardsProvider` is only cleared when the user taps the "Cerrar"
button. But `showModalBottomSheet` is **dismissible by default** — tapping outside
or swiping down closes the sheet without calling `onClose`.

Consequence:
1. Round 1 awards sheet appears. User swipes it away.
2. `lastRoundAwardsProvider` still holds round 1 awards.
3. Round 2 completes → provider is set to round 2 awards (replacing round 1) →
   listener fires again → `_showAwardsSheet` is called again → **a second sheet
   stacks on top of whatever is showing**.

Additionally, if the CheckpointScreen is rebuilt while the sheet is open (e.g., due
to a player list update), `initState` runs `listenManual` again. If the provider
still has a non-null value, it will immediately re-show the sheet.

**Fix (not applied yet):**  
Set `isDismissible: false` and `enableDrag: false` on the `showModalBottomSheet`
call to force users through the "Cerrar" button. Alternatively, clear the provider
in a `.whenComplete()` callback on the returned Future from `showModalBottomSheet`.

```dart
showModalBottomSheet<void>(
  context: context,
  isDismissible: false,
  enableDrag: false,
  builder: (ctx) => _RoundAwardsSheet(...),
).whenComplete(() {
  // Safety net: clear even if sheet was force-dismissed.
  ref.read(lastRoundAwardsProvider.notifier).state = null;
});
```

---

### 🟢 ISSUE-09 — Firebase `syncRoundComplete` sends pre-title-evaluation player data

**Severity:** Informational (Firebase only, does not affect local game)  
**File:** `lib/core/providers/checkpoint_providers.dart`  
**Method:** `CheckpointNotifier._onRoundComplete()` (lines 173–235)

**What happens:**

```dart
final players = await playerRepo.getAll(); // captured before titles are applied

unawaited(
  RoundCompletionService.evaluateAndApply(
    players: players,           // ← mutates Hive
    round: completedRound,
    repo: playerRepo,
  ).then((awards) {
    // ...
    unawaited(
      syncService.syncRoundComplete(
        sessionId: sessionId,
        players: players,       // ← SAME list: no title counts yet
        round: completedRound,
      ),
    );
  }),
);
```

The `players` snapshot is captured BEFORE `evaluateAndApply` runs. The
`syncRoundComplete` call inside the `.then()` block uses the same (stale) snapshot.
So title counts for the just-completed round are NOT included in the Firestore batch
sync for that round — they will only appear in the NEXT sync.

`syncPlayerUpdate` (called per-player inside `submitBAC`) already synced each
player's BAC changes, so the web dashboard is not completely out of date. Only the
title counts from this specific round are delayed by one round.

**Fix (not applied yet — low priority):**  
Re-read players from the repo after `evaluateAndApply` completes, inside the `.then()`:
```dart
.then((awards) async {
  ref.invalidate(playerListNotifierProvider);
  final freshPlayers = await playerRepo.getAll(); // re-read after title writes
  unawaited(syncService.syncRoundComplete(
    sessionId: sessionId,
    players: freshPlayers,   // ← includes new title counts
    round: completedRound,
  ));
  // ...
})
```

---

### 🟢 ISSUE-10 — `submitBAC` calls `recordPlayerMeasurement` internally; ordering with `skipPlayerMeasurement` requires careful reading

**Severity:** Informational (works correctly as-is, but fragile)  
**Files:** `bac_entry_provider.dart:154`, `round_robin_screen.dart:116–143`

**What happens:**

`submitBAC` (called per active player) internally calls
`checkpointNotifier.recordPlayerMeasurement(playerId)`. The group completion check
inside `recordPlayerMeasurement` is:

```dart
final allMeasured = playerGroup.playerIds.every(
  (id) => _measuredPlayerIdsByGroup[groupIndex]!.contains(id),
);
```

`playerGroup.playerIds` includes **incautado player IDs** in the group. So as long
as there is at least one incautado player in a group, `allMeasured` will remain
`false` after all active players submit — the group will NOT complete yet. Completion
is only triggered by the subsequent `skipPlayerMeasurement` calls in `_submitAll`'s
second loop.

This is the **correct and intended behavior** — it ensures all readings are written
before group completion fires. But:

- If `skipPlayerMeasurement` calls are accidentally removed or their loop is short-
  circuited, the group will NEVER complete.
- If an incautado player is added to a group after `initialize()` creates the groups
  (not currently possible via the UI, but worth knowing), the new player's ID would
  not be in the group's `playerIds` and would not block or unblock completion.

**No fix needed** — document for future maintainers.

---

## Status

| ID | Description | Severity | Applied |
|----|-------------|----------|---------|
| ISSUE-01 | Timer auto-fires on restart | 🔴 Critical | ❌ No |
| ISSUE-02 | `resetGame()` missing `isIncautado: false` | 🔴 High | ❌ No |
| ISSUE-03 | Debug clear leaves orphaned state | 🟡 Medium (testing only) | ❌ No |
| ISSUE-04 | `unawaited` race in `_onRoundComplete` | 🟡 Low | ❌ No |
| ISSUE-05 | `_measuredPlayerIdsByGroup` resets on rebuild | 🟡 Low | ❌ No |
| ISSUE-06 | Skip-timer FAB visible in production builds | 🔴 Critical | ❌ No |
| ISSUE-07 | `_cancelGame` doesn't reset checkpoint state | 🟡 Low | ❌ No |
| ISSUE-08 | Awards sheet dismissible, clears provider only on "Cerrar" | 🟡 Medium | ❌ No |
| ISSUE-09 | `syncRoundComplete` sends stale player data to Firebase | 🟢 Info | ❌ No |
| ISSUE-10 | `submitBAC`+`skipPlayerMeasurement` ordering is fragile | 🟢 Info | ❌ No |

---

---

---

## Issues Found — Pass 3

Pass 3 covered: all remaining files — `main.dart`, `app.dart`, `splash_screen.dart`,
`recovery_provider.dart`, `hive_service.dart`, `bac_calculator.dart`,
`points_calculator.dart`, `checkpoint_calculator.dart`, `app_constants.dart`,
`player_repository_impl.dart`, `bac_entry_provider.dart` (editBAC),
`registration_provider.dart`, `license_update_service.dart`,
`bac_confirmation_screen.dart`, `feedback_screen.dart`, `fine_screen.dart`,
`leaderboard_screen.dart`, `manual_entry_screen.dart`, `group_countdown_card.dart`,
`firebase_providers.dart`.

---

### 🔴 ISSUE-11 — `3 min` interval visible in the production interval picker

**Severity:** High party-day UX risk  
**File:** `lib/core/constants/app_constants.dart` (line 49–54)  
**Used in:** `lib/features/player_registration/presentation/player_selection_screen.dart`

**What happens:**

```dart
static const List<int> availableIntervalMinutes = [3, 30, 45, 60];
```

The `PlayerSelectionScreen` renders a `SegmentedButton` with all four options,
including `3 min`, in ALL builds — release included. At the start of the party, if
someone accidentally taps `3 min` instead of `30 min` (they're adjacent), the
checkpoint fires every 3 minutes. With 5–10 players per group that is physically
impossible to complete before the next one fires — you'd immediately be stuck in
a permanent "Ir al Retén" loop.

The `3 min` option only exists as a de-facto fast-test interval. There is also a
stale comment in `checkpoint_providers.dart` (line 57) that says:
`/// In debug builds, [intervalMinutes] is overridden to 1 minute for fast testing.`
— but there is no such override code. The `3 min` picker option replaced that
planned override and was never guarded.

**Fix (not applied yet):**  
Either remove `3` from the list in release builds:
```dart
static List<int> get availableIntervalMinutes =>
    kDebugMode ? [3, 30, 45, 60] : [30, 45, 60];
```
Or remove `3` entirely and rely on the checkpoint skip FAB (once gated by
`kDebugMode`) for fast testing.

---

### 🟡 ISSUE-12 — Recovery routing reads stale `isCheckpointActive` from Hive

**Severity:** Low standalone; compounding with ISSUE-01  
**File:** `lib/core/providers/recovery_provider.dart` (lines 43–52)

**What happens:**

```dart
final checkpointState = await checkpointRepo.getCurrent();
if (checkpointState != null) {
  ref.watch(checkpointNotifierProvider); // starts ticker
  if (checkpointState.isCheckpointActive) {
    return RecoveryRoute.checkpoint;
  }
}
return RecoveryRoute.leaderboard;
```

Recovery reads `isCheckpointActive` directly from the Hive snapshot — the value
saved at the last moment before the app was killed. If that value was `false` (e.g.,
a group had just finished and the next one hadn't yet expired), recovery routes to
`leaderboard`. Then `CheckpointNotifier.build()` runs (triggered by
`ref.watch(checkpointNotifierProvider)`), starts the ticker, and ISSUE-01 fires:
all groups immediately become due and "Ir al Retén" appears on the checkpoint
screen — but the user is already on the leaderboard.

If `isCheckpointActive` was `true`, recovery routes to checkpoint, but ISSUE-01
still fires immediately and re-activates all groups at once.

**This issue is downstream of ISSUE-01.** Fixing ISSUE-01 (sanitizing stale
timestamps in `build()`) means all groups get fresh intervals on restart, so
`isCheckpointActive` becomes `false` after sanitization, and the Hive value is
overwritten before recovery reads it... actually recovery reads from the repo
DIRECTLY (not from the notifier's state), so it reads the old Hive value before
the notifier writes the sanitized value.

**Fix (not applied yet):**  
After ISSUE-01 is fixed, recovery should re-read checkpoint state from the notifier
(which has the sanitized value) rather than directly from the repo. Or: recovery
should check if any group is currently due (by looking at group timestamps) rather
than relying on the persisted `isCheckpointActive` flag.

---

### 🟡 ISSUE-13 — `LicenseUpdateService` called twice per round for titled players

**Severity:** Low (performance only, no correctness impact)  
**Files:** `lib/features/breathalyzer/providers/bac_entry_provider.dart` (line 145),
`lib/features/breathalyzer/providers/round_completion_service.dart` (line 31)

**What happens:**

For every BAC submission, `submitBAC` calls `LicenseUpdateService.updateForPlayer`
(generates front + back PNG, writes to disk, evicts image cache). Then after all
submissions, `RoundCompletionService.evaluateAndApply` calls
`LicenseUpdateService.updateForPlayer` again for each player who earned a title.

A player who earns a title in a round triggers **two full license regenerations**:
1. After BAC recorded — license has new points but no new title.
2. After title evaluated — license has new points AND new title.

The second call correctly overwrites the first. With 10 players, up to 20 license
regenerations happen per round. License generation calls Flutter's rendering
pipeline (`PictureRecorder`, `Canvas`) and does disk I/O — it is not free.

**Fix (not applied yet — low priority):**  
Remove the `LicenseUpdateService` call from `submitBAC` and only call it from
`evaluateAndApply` (after both points and titles are final). This requires
`evaluateAndApply` to handle all players (not just title winners).

---

### 🟢 ISSUE-14 — Growing navigation stack via drawer "Control Activo"

**Severity:** Informational  
**File:** `lib/features/main_menu/presentation/main_menu_screen.dart` (lines 63–69)

**What happens:**

From the drawer, "Control Activo" pushes `AppRoutes.game` on top of whatever is
on the stack. If the user is on the leaderboard, the stack becomes:
`[MainMenu → Checkpoint → Leaderboard → Checkpoint]`.

"Ver Clasificación" on the checkpoint screen pushes the leaderboard again:
`[MainMenu → Checkpoint → Leaderboard → Checkpoint → Leaderboard]`.

Each such cycle grows the stack. `Navigator.popUntil(route.isFirst)` (called by
`_returnToMenu`) still clears it correctly. But during a session, the Android
back-gesture would reveal intermediate screens the user didn't expect.

**Not a party-day risk** — the main flow (Checkpoint → "Ir al Retén" → measure →
pop back to Checkpoint) doesn't grow the stack. Only deliberate drawer navigation
during idle time does.

**Fix if desired:**  
Use `Navigator.pushReplacementNamed` or `Navigator.pushNamedAndRemoveUntil` in
the drawer navigation to avoid stack growth.

---

### 🟢 ISSUE-15 — Stale comment: "debug overrides to 1 minute" never implemented

**Severity:** Informational  
**File:** `lib/core/providers/checkpoint_providers.dart` (line 57)

```dart
/// In debug builds, [intervalMinutes] is overridden to 1 minute for fast testing.
Future<void> initialize({
  required List<PlayerProfile> players,
  required int intervalMinutes,
}) async {
  // ← no override code exists
```

The comment describes behavior that was planned but never implemented. The `3 min`
picker option (ISSUE-11) is the actual replacement. The comment should be removed.

---

### 🟢 ISSUE-16 — `SplashScreen` and `_RecoveryGate` are parallel recovery paths

**Severity:** Informational  
**Files:** `lib/features/main_menu/presentation/splash_screen.dart`,
`lib/app.dart` (lines 157–191)

**What happens:**

Both `SplashScreen._navigateToMainMenu()` and `_RecoveryGate.build()` independently
read `recoveryNotifierProvider` and navigate to the correct screen. They are
separate implementations of the same logic.

In practice only one is ever active: `SplashScreen` is the `home:` widget; after
`pushReplacement` to `MainMenuScreen`, it's gone from the stack.
`_RecoveryGate` is the `'/'` route in `onGenerateRoute`, but nothing in the
codebase calls `Navigator.pushNamed(context, '/')` — making `_RecoveryGate` dead
code.

**Not a runtime risk.** But if `_RecoveryGate` is dead code, it can be deleted.
If `SplashScreen` is removed in the future, `_RecoveryGate` would need to be
activated.

---

---

---

## Issues Found — Pass 4 (final sweep)

Pass 4 covered: `dgt_title.dart`, `license_generator.dart`, `bac_entry_result.dart`,
`custom_keypad.dart`, `license_card.dart`, `player_detail_screen.dart`,
`siren_alert_overlay.dart`, `firebase_storage_service.dart`,
`notification_composer_screen.dart`, `settings_screen.dart`.

---

### 🟡 ISSUE-17 — `SirenAlertOverlay` is dead code — never triggered in-game

**Severity:** Medium (missing party feature, not a crash)  
**File:** `lib/features/checkpoint/presentation/siren_alert_overlay.dart`

**What happens:**

```dart
class SirenAlertOverlay extends StatefulWidget {
  // Red/blue flashing screen + auto-dismiss after sirenDuration
}
```

The entire `SirenAlertOverlay` widget exists but is **never pushed anywhere in the
codebase**. A `grep` for `SirenAlertOverlay` finds only the file itself — no call
site in the checkpoint screen or anywhere else.

When a group becomes due, the `CheckpointScreen` shows the group card in red with
an "Ir al Retén" button, and fires a high-priority OS notification via
`NotificationService.showGroupDue`. There is no in-app flash or alarm.

**Party-day consequence:** If the phone screen is on and the app is in the
foreground, the only visual signal that a group is due is the card turning red.
There is no siren flash, no vibration from inside the app (OS notification
vibration exists if notifications are enabled). Easy to miss.

**Fix (not applied yet):**  
Push `SirenAlertOverlay` from `CheckpointScreen._goReten()` — or from the
`_tick()` listener using `addPostFrameCallback` — when a group first becomes due.

---

### 🟡 ISSUE-18 — `LicenseGenerator` force-unwraps nullable `ByteData?`

**Severity:** Low (crash risk in licence generation, silently caught)  
**File:** `lib/features/fake_id/services/license_generator.dart` (lines 126–127, 197–198)

**What happens:**

```dart
final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
final pngBytes = byteData!.buffer.asUint8List();  // ← ! on nullable
```

`ui.Image.toByteData()` returns `Future<ByteData?>`. The `!` operator will throw
a `Null check operator used on a null value` error if it returns null. In practice
this shouldn't happen for PNG format, but it's technically possible under memory
pressure.

Since `LicenseUpdateService` wraps all generator calls in `try { ... } catch (_) {}`,
a crash here is silently swallowed. The player's license image would not be updated
for that round. Game state remains correct; only the visual card is stale.

**Fix (not applied yet — low priority):**  
Use `??` to throw a descriptive error or fall back gracefully:
```dart
final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
if (byteData == null) return <current_path_or_throw>;
```

---

### 🟢 ISSUE-19 — `FirebaseStorage` SDK initialized but never used for uploads

**Severity:** Informational  
**File:** `lib/features/firebase/services/firebase_storage_service.dart`

**What happens:**

```dart
class FirebaseStorageService {
  FirebaseStorageService(this._storage);
  // ignore: unused_field
  final FirebaseStorage _storage;  // ← intentionally suppressed warning

  Future<String> uploadPlayerPhoto(String playerId, String localPath) async {
    // ... compresses to base64 in-memory, no _storage used
    return 'data:image/jpeg;base64,${base64Encode(compressed)}';
  }
}
```

The `FirebaseStorage` SDK is imported and injected but never actually used. Photo
"upload" is actually base64 encoding embedded directly in the Firestore player
document. The suppressed warning (`// ignore: unused_field`) confirms this is
intentional.

**Consequence:** No files are stored in Firebase Storage. Photos are embedded as
base64 data URLs in Firestore documents. For party use (few players, small photos
compressed to 60% JPEG quality) this is fine. Just noting it in case the web
frontend expects Storage URLs.

---

---

---

## Issues Found — Pass 5 (user-reported)

### 🔴 ISSUE-20 — Checkpoint notifications don't fire in background; timer goes negative

**Severity:** Critical (party-day risk)
**Files:** `lib/core/services/notification_service.dart`,
`lib/core/providers/checkpoint_providers.dart`

**Two symptoms, one root cause.**

---

#### Symptom A — Notification timer goes negative

`showGroupTimer` creates an Android chronometer notification:

```dart
// notification_service.dart
when: expiresAt.millisecondsSinceEpoch,
usesChronometer: true,
chronometerCountDown: true,
```

Android renders `remaining = when - now` in the notification shade. Once `now`
passes `when`, Android keeps the chronometer running — it displays negative elapsed
time. There is no Android API to auto-stop it at zero.

The intended fix is for `showGroupDue` to replace the same notification (same ID:
`_baseId + groupIndex`) when the group becomes due. But that replacement is
triggered by `_tick()` — see Symptom B.

---

#### Symptom B — "¡Medir ahora!" notification and vibration don't fire when screen
is locked or app is in another app

`showGroupDue` and the vibration pattern are called exclusively from `_tick()`:

```dart
// checkpoint_providers.dart _tick()
for (final group in dueGroups) {
  if (!_announcedDueGroups.contains(group.groupIndex)) {
    _announcedDueGroups.add(group.groupIndex);
    unawaited(NotificationService.showGroupDue(...)); // ← only called from here
  }
}
```

`_tick()` runs via `Timer.periodic(const Duration(seconds: 1), ...)` — a **Dart
timer inside the Flutter isolate**. Android does not guarantee that Flutter
background isolates keep running when:
- The screen is locked
- The user switches to another app
- The OS is under memory pressure

Once the Dart isolate is throttled or suspended, `_tick()` stops firing. The group
becomes due but neither `showGroupDue` nor any vibration is ever triggered. The
countdown notification just keeps counting negatively in the notification shade.

The app resumes correctly once the user opens it (the `_tick()` ticker restarts and
immediately fires `showGroupDue`), but by then the moment has been missed.

---

#### Root cause

The entire "group due" detection and notification system is **app-alive dependent**.
All notification triggers live in Dart code, not in the OS scheduler. There is no
Android alarm, WorkManager job, or foreground service keeping the process alive.

Notably, `tz_data.initializeTimeZones()` is already called in
`NotificationService.init()`, which means the timezone package is set up for
scheduled notifications — but `zonedSchedule` is never used anywhere. Every call
goes through `_plugin.show()` (fire immediately, app must be alive).

---

#### Fix

Pre-schedule the "medir ahora" notification at the exact `nextCheckpoint` time
using `flutter_local_notifications`' `zonedSchedule`. The OS fires this as a
native alarm at the right time regardless of app state. It replaces the countdown
notification (same ID), stopping the negative display and triggering vibration.

**Step 1 — Add `scheduleGroupDue` to `NotificationService`:**

```dart
import 'package:timezone/timezone.dart' as tz;

static Future<void> scheduleGroupDue(
  int groupIndex,
  String groupLabel,
  DateTime scheduledAt,
  int round,
) async {
  try {
    final scheduledTZ = tz.TZDateTime.from(scheduledAt, tz.local);
    final androidDetails = AndroidNotificationDetails(
      _dueChannelId,
      _dueChannelName,
      channelDescription: _dueChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      playSound: false,
      color: const Color(0xFFD32F2F),
      colorized: true,
      channelShowBadge: false,
    );
    await _plugin.zonedSchedule(
      _baseId + groupIndex,          // same ID — replaces the countdown
      '🚨 $groupLabel — Ronda $round',
      '¡Puedes medir al $groupLabel ahora!',
      scheduledTZ,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  } catch (e) {
    if (kDebugMode) debugPrint('[NotificationService] scheduleGroupDue failed: $e');
  }
}
```

**Step 2 — Call it wherever `showGroupTimer` is called** (in `initialize()` and
`completeGroupMeasurement()` in `checkpoint_providers.dart`):

```dart
// After showGroupTimer:
unawaited(NotificationService.scheduleGroupDue(
  group.groupIndex,
  'Grupo ${group.groupIndex + 1}',
  nextTime,          // the absolute DateTime when the group becomes due
  newState.currentRound,
));
```

**Step 3 — Cancel the scheduled alarm when the group is measured** (already handled
— `cancelGroupTimer(group.groupIndex)` in `completeGroupMeasurement()` cancels by
ID, which also cancels any `zonedSchedule` pending for the same ID).

**Step 4 — Android manifest permission** (required for Android 12+):

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

Without this, `exactAllowWhileIdle` degrades to inexact timing on API 31+. On API
33+ `USE_EXACT_ALARM` can be used instead (no runtime prompt required, but the app
must target API 33).

**The `_tick()` path (`showGroupDue` from in-app) can remain** as a fallback for
the case where the app IS in the foreground — it fires within ~1 second of expiry
and the `_announcedDueGroups` guard prevents double-showing. The scheduled alarm
covers the background case.

---

## Final Status Table

| ID | Description | Severity | Party-day risk | Applied |
|----|-------------|----------|---------------|---------|
| ISSUE-01 | Timer auto-fires on restart | 🔴 Critical | ✅ YES | ❌ No |
| ISSUE-02 | `resetGame()` missing `isIncautado: false` | 🔴 High | ✅ Yes | ❌ No |
| ISSUE-03 | Debug clear leaves orphaned state | 🟡 Medium | ❌ Release-only | ❌ No |
| ISSUE-04 | `unawaited` race in `_onRoundComplete` | 🟡 Low | ⚠️ Edge case | ❌ No |
| ISSUE-05 | `_measuredPlayerIdsByGroup` resets on rebuild | 🟡 Low | ⚠️ Edge case | ❌ No |
| ISSUE-06 | Skip-timer FAB visible in production | 🔴 Critical | ✅ YES | ❌ No |
| ISSUE-07 | `_cancelGame` doesn't reset checkpoint | 🟡 Low | ❌ Unlikely | ❌ No |
| ISSUE-08 | Awards sheet dismissible without clearing state | 🟡 Medium | ⚠️ Yes | ❌ No |
| ISSUE-09 | `syncRoundComplete` sends stale player data | 🟢 Info | ❌ Firebase only | ❌ No |
| ISSUE-10 | `submitBAC`+`skip` ordering is fragile | 🟢 Info | ❌ Works correctly | ❌ No |
| ISSUE-11 | `3 min` interval selectable in production | 🔴 High | ✅ YES | ❌ No |
| ISSUE-12 | Recovery reads stale `isCheckpointActive` | 🟡 Low | ⚠️ With ISSUE-01 | ❌ No |
| ISSUE-13 | Double license generation for titled players | 🟡 Low | ❌ Performance only | ❌ No |
| ISSUE-14 | Growing nav stack via drawer | 🟢 Info | ❌ No | ❌ No |
| ISSUE-15 | Stale comment: "debug overrides interval" | 🟢 Info | ❌ No | ❌ No |
| ISSUE-16 | `_RecoveryGate` is likely dead code | 🟢 Info | ❌ No | ❌ No |
| ISSUE-17 | `SirenAlertOverlay` never triggered — dead code | 🟡 Medium | ⚠️ Missing feature | ❌ No |
| ISSUE-18 | `LicenseGenerator` force-unwraps nullable `ByteData?` | 🟡 Low | ❌ Caught silently | ❌ No |
| ISSUE-19 | Firebase Storage SDK initialized but unused | 🟢 Info | ❌ No | ❌ No |
| ISSUE-20 | Background notifications don't fire; timer goes negative | 🔴 Critical | ✅ YES | ❌ No |

---

## Must-fix Before Friday

In priority order:

1. **ISSUE-01** — Sanitize stale timestamps in `CheckpointNotifier.build()`
2. **ISSUE-20** — Use `zonedSchedule` for group-due notifications + add manifest permission
3. **ISSUE-06** — Gate `skipToNextCheckpoint` FAB with `kDebugMode`
4. **ISSUE-11** — Remove `3 min` from `availableIntervalMinutes` in release builds
5. **ISSUE-02** — Add `isIncautado: false` to `resetGame()` in `main_menu_provider.dart`
6. **ISSUE-08** — Set `isDismissible: false` on the round awards bottom sheet
7. **ISSUE-17** — Wire up `SirenAlertOverlay` so there's an in-app visual alert when a group fires
