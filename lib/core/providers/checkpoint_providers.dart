import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dgv/core/models/checkpoint_state.dart';
import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/providers/repository_providers.dart';
import 'package:dgv/core/utils/checkpoint_calculator.dart';
import 'package:dgv/core/services/notification_service.dart';
import 'package:dgv/features/breathalyzer/providers/round_completion_service.dart';

part 'checkpoint_providers.g.dart';

/// In-memory provider that holds the title awards from the most recent round.
/// Set to non-null after a round completes; UI clears it after showing the sheet.
final lastRoundAwardsProvider = StateProvider<Map<String, DGTTitle>?>(
  (ref) => null,
);

/// Central provider for per-group checkpoint timer management.
///
/// Owns a single [Timer.periodic] that ticks every second and recomputes
/// [timeRemaining] for each group from absolute [lastMeasurement] timestamps.
/// All mutations are persisted to Hive immediately.
@riverpod
class CheckpointNotifier extends _$CheckpointNotifier {
  Timer? _ticker;

  @override
  Future<CheckpointState?> build() async {
    ref.onDispose(() => _ticker?.cancel());
    final repo = ref.watch(checkpointRepositoryProvider);
    final existing = await repo.getCurrent();
    if (existing != null) {
      _startTicker();
    }
    return existing;
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Initialize checkpoint state for a new game.
  ///
  /// Divides [players] into groups using [CheckpointCalculator.divideIntoGroups],
  /// builds a [GroupCheckpoint] list, saves to Hive, and starts the ticker.
  ///
  /// In debug builds, [intervalMinutes] is overridden to 1 minute for fast testing.
  Future<void> initialize({
    required List<PlayerProfile> players,
    required int intervalMinutes,
  }) async {
    if (players.isEmpty) return;

    final numberOfGroups = CheckpointCalculator.suggestNumberOfGroups(
      players.length,
    );
    final playerGroups = CheckpointCalculator.divideIntoGroups(
      players,
      numberOfGroups,
    );

    final now = DateTime.now();
    final rng = Random();
    final groups = playerGroups.asMap().entries.map((entry) {
      // Add a small random offset (10–40 s) per group so timers never fire
      // simultaneously. Simultaneous expiry causes _tick() to activate both
      // groups at once, creating a state race in completeGroupMeasurement.
      final jitterSeconds = 10 + rng.nextInt(31); // 10..40 s
      final nextTime = now.add(
        Duration(minutes: intervalMinutes, seconds: jitterSeconds),
      );
      return GroupCheckpoint(
        groupIndex: entry.key,
        playerIds: entry.value.map((p) => p.id).toList(),
        lastMeasurement: now,
        intervalMinutes: intervalMinutes,
        nextCheckpoint: nextTime,
      );
    }).toList();

    final newState = CheckpointState(
      currentRound: 1,
      intervalMinutes: intervalMinutes,
      groups: groups,
    );

    final repo = ref.read(checkpointRepositoryProvider);
    await repo.save(newState);
    state = AsyncData(newState);
    _startTicker();

    // Show an ongoing countdown notification for each group.
    for (final group in groups) {
      final next = group.nextCheckpoint;
      if (next != null) {
        unawaited(
          NotificationService.showGroupTimer(
            group.groupIndex,
            'Grupo ${group.groupIndex + 1}',
            next,
            newState.currentRound,
          ),
        );
      }
    }
  }

  /// Mark all players in the group at [groupIndex] as measured.
  ///
  /// Resets that group's timer and clears [activeGroupIndex] if no other
  /// groups are still due.
  Future<void> completeGroupMeasurement(int groupIndex) async {
    final current = state.value;
    if (current == null) return;
    if (groupIndex < 0 || groupIndex >= current.groups.length) return;

    final now = DateTime.now();
    final updatedGroups = current.groups.map((group) {
      if (group.groupIndex != groupIndex) return group;
      final nextTime = now.add(Duration(minutes: group.intervalMinutes));
      // Cancel the old timer notification and show a fresh one for next round.
      unawaited(NotificationService.cancelGroupTimer(group.groupIndex));
      unawaited(
        NotificationService.showGroupTimer(
          group.groupIndex,
          'Grupo ${group.groupIndex + 1}',
          nextTime,
          current.currentRound + 1,
        ),
      );
      return group.copyWith(lastMeasurement: now, nextCheckpoint: nextTime);
    }).toList();

    // Find any other group that is still due after this one is completed.
    final remainingDue = updatedGroups
        .where((g) => g.groupIndex != groupIndex && g.isDue)
        .toList();
    final nextActiveIndex = remainingDue.isEmpty
        ? null
        : remainingDue.map((g) => g.groupIndex).reduce((a, b) => a < b ? a : b);

    final updatedState = current.copyWith(
      groups: updatedGroups,
      isCheckpointActive: nextActiveIndex != null,
      activeGroupIndex: nextActiveIndex,
    );

    final repo = ref.read(checkpointRepositoryProvider);
    await repo.save(updatedState);
    state = AsyncData(updatedState);

    // Allow re-announcing this group when it becomes due next round.
    _announcedDueGroups.remove(groupIndex);

    // Advance the round only when every group has measured once this cycle.
    _measuredGroupsThisRound.add(groupIndex);
    if (_measuredGroupsThisRound.length >= updatedState.groups.length) {
      _measuredGroupsThisRound.clear();
      await _onRoundComplete(updatedState.currentRound);
    }
  }

  Future<void> _onRoundComplete(int completedRound) async {
    // Read directly from the repository — playerListProvider may still hold
    // a cached snapshot that predates the round's BAC submissions.
    final playerRepo = ref.read(playerRepositoryProvider);
    final players = await playerRepo.getAll();

    unawaited(
      RoundCompletionService.evaluateAndApply(
        players: players,
        round: completedRound,
        repo: playerRepo,
      ).then((awards) {
        ref.invalidate(playerListNotifierProvider);
        // Expose awards so CheckpointScreen can show the round summary sheet.
        if (awards.isNotEmpty) {
          ref.read(lastRoundAwardsProvider.notifier).state = awards;
        }
      }),
    );

    await ref.read(gameStateNotifierProvider.notifier).advanceRound();

    // Keep CheckpointState.currentRound in sync with the new game round.
    final current = state.value;
    if (current != null) {
      final updated = current.copyWith(currentRound: completedRound + 1);
      final repo = ref.read(checkpointRepositoryProvider);
      await repo.save(updated);
      state = AsyncData(updated);
    }
  }

  /// Record a BAC measurement for a single player within the active group window.
  ///
  /// Tracks per-player progress. When all players in the active group have been
  /// measured, the UI lock is released (delegates to [completeGroupMeasurement]).
  Future<void> recordPlayerMeasurement(String playerId) async {
    final current = state.value;
    if (current == null) return;

    // Derive the group from the player's own membership — do NOT rely on
    // activeGroupIndex, which always points to the lowest-index due group and
    // would be wrong when the user taps a higher-index group's "Ir al Retén".
    final playerGroup = current.groups
        .where((g) => g.playerIds.contains(playerId))
        .firstOrNull;
    if (playerGroup == null) return;

    final groupIndex = playerGroup.groupIndex;
    (_measuredPlayerIdsByGroup[groupIndex] ??= {}).add(playerId);

    final allMeasured = playerGroup.playerIds.every(
      (id) => _measuredPlayerIdsByGroup[groupIndex]!.contains(id),
    );

    if (allMeasured) {
      _measuredPlayerIdsByGroup.remove(groupIndex);
      await completeGroupMeasurement(groupIndex);
    }
  }

  /// Count an incautado player as measured without recording a BAC reading.
  ///
  /// Called from RoundRobinScreen when a player is marked as Vehículo Incautado
  /// so they don't block group completion.
  Future<void> skipPlayerMeasurement(String playerId) async {
    final current = state.value;
    if (current == null) return;

    final playerGroup = current.groups
        .where((g) => g.playerIds.contains(playerId))
        .firstOrNull;
    if (playerGroup == null) return;

    final groupIndex = playerGroup.groupIndex;
    (_measuredPlayerIdsByGroup[groupIndex] ??= {}).add(playerId);

    final allMeasured = playerGroup.playerIds.every(
      (id) => _measuredPlayerIdsByGroup[groupIndex]!.contains(id),
    );

    if (allMeasured) {
      _measuredPlayerIdsByGroup.remove(groupIndex);
      await completeGroupMeasurement(groupIndex);
    }
  }

  /// Skip immediately to the next checkpoint (debug builds only).
  void skipToNextCheckpoint() {
    final current = state.value;
    if (current == null) return;

    // Force the earliest upcoming group to become due now.
    final earliestGroup = current.groups.reduce((a, b) {
      final aNext =
          a.nextCheckpoint ??
          a.lastMeasurement.add(Duration(minutes: a.intervalMinutes));
      final bNext =
          b.nextCheckpoint ??
          b.lastMeasurement.add(Duration(minutes: b.intervalMinutes));
      return aNext.isBefore(bNext) ? a : b;
    });
    final forceDueAt = DateTime.now().subtract(const Duration(seconds: 1));
    final forcedGroups = current.groups.map((group) {
      if (group.groupIndex != earliestGroup.groupIndex) return group;
      return group.copyWith(nextCheckpoint: forceDueAt);
    }).toList();

    state = AsyncData(current.copyWith(groups: forcedGroups));
    _tick();
  }

  /// Cancel the ticker, delete Hive state, and reset to null.
  Future<void> reset() async {
    _ticker?.cancel();
    _ticker = null;
    _measuredPlayerIdsByGroup.clear();

    unawaited(NotificationService.cancelAll());

    final repo = ref.read(checkpointRepositoryProvider);
    await repo.delete();
    state = const AsyncData(null);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Per-group in-memory tracking of which players have been measured this window.
  /// Keyed by groupIndex so measuring group 2 never interferes with group 1.
  final Map<int, Set<String>> _measuredPlayerIdsByGroup = {};

  /// Tracks which group indices have completed measurement in the current round.
  /// Reset when the round advances. In-memory only — acceptable because if the
  /// app restarts mid-round the players just re-measure (party game context).
  final Set<int> _measuredGroupsThisRound = {};

  /// Tracks which group indices have already had their "due" notification shown.
  /// Prevents re-firing vibration every tick once a group is already announced.
  final Set<int> _announcedDueGroups = {};

  /// Returns true if [playerId] has been measured in the current window.
  /// Used by [activeGroupProgress] to compute progress without persisting.
  bool hasMeasuredInWindow(String playerId, DateTime windowStart) {
    return _measuredPlayerIdsByGroup.values.any((s) => s.contains(playerId));
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final current = state.value;
    if (current == null) return;

    // Recompute timeRemaining for each group from absolute lastMeasurement.
    final updatedGroups = current.groups.map((group) {
      final next =
          group.nextCheckpoint ??
          group.lastMeasurement.add(Duration(minutes: group.intervalMinutes));
      return group.copyWith(nextCheckpoint: next);
    }).toList();

    // Determine if any group is now due.
    final dueGroups = updatedGroups.where((g) => g.isDue).toList();
    final anyDue = dueGroups.isNotEmpty;

    // Fire a high-priority "measure now" notification for newly-due groups.
    for (final group in dueGroups) {
      if (!_announcedDueGroups.contains(group.groupIndex)) {
        _announcedDueGroups.add(group.groupIndex);
        unawaited(
          NotificationService.showGroupDue(
            group.groupIndex,
            'Grupo ${group.groupIndex + 1}',
            current.currentRound,
          ),
        );
      }
    }

    // Only activate if not already active (avoid overwriting active group).
    int? newActiveIndex = current.activeGroupIndex;
    if (anyDue && !current.isCheckpointActive) {
      // Pick the lowest-index due group.
      newActiveIndex = dueGroups
          .map((g) => g.groupIndex)
          .reduce((a, b) => a < b ? a : b);
    } else if (!anyDue) {
      newActiveIndex = null;
    }

    final updatedState = current.copyWith(
      groups: updatedGroups,
      isCheckpointActive: anyDue || current.isCheckpointActive,
      activeGroupIndex: newActiveIndex,
    );

    // Only persist and notify if something actually changed.
    if (updatedState == current) return;

    state = AsyncData(updatedState);

    // Persist asynchronously — fire-and-forget is acceptable here since the
    // in-memory state is already updated and the next tick will re-persist.
    final repo = ref.read(checkpointRepositoryProvider);
    unawaited(repo.save(updatedState));
  }
}

// ---------------------------------------------------------------------------
// Supporting read-only providers
// ---------------------------------------------------------------------------

/// Stream of checkpoint state for reactive widgets.
@riverpod
Stream<CheckpointState?> checkpointStream(CheckpointStreamRef ref) {
  final repo = ref.watch(checkpointRepositoryProvider);
  return repo.watch();
}

/// Whether any group is currently due for measurement.
@riverpod
bool isCheckpointDue(IsCheckpointDueRef ref) {
  final asyncState = ref.watch(checkpointNotifierProvider);
  return asyncState.value?.isCheckpointActive ?? false;
}

/// Progress for the active group: (completed, total).
///
/// Returns `(0, 0)` when no group is active.
@riverpod
(int, int) activeGroupProgress(ActiveGroupProgressRef ref) {
  final asyncState = ref.watch(checkpointNotifierProvider);
  final checkpointState = asyncState.value;
  if (checkpointState == null) return (0, 0);

  final activeGroup = checkpointState.activeGroup;
  if (activeGroup == null) return (0, 0);

  final total = activeGroup.playerIds.length;

  // Count players who have a reading in the current checkpoint window.
  // The window starts at lastMeasurement for the active group.
  final windowStart = activeGroup.lastMeasurement;
  final notifier = ref.watch(checkpointNotifierProvider.notifier);
  final measured = activeGroup.playerIds
      .where((id) => notifier.hasMeasuredInWindow(id, windowStart))
      .length;

  return (measured, total);
}
