import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dgv/core/models/checkpoint_state.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/utils/checkpoint_calculator.dart';
import 'package:dgv/core/providers/repository_providers.dart';

part 'checkpoint_providers.g.dart';

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
    final groups = playerGroups.asMap().entries.map((entry) {
      return GroupCheckpoint(
        groupIndex: entry.key,
        playerIds: entry.value.map((p) => p.id).toList(),
        lastMeasurement: now,
        intervalMinutes: intervalMinutes,
        nextCheckpoint: now.add(Duration(minutes: intervalMinutes)),
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
      return group.copyWith(
        lastMeasurement: now,
        nextCheckpoint: now.add(Duration(minutes: group.intervalMinutes)),
      );
    }).toList();

    // Determine if any other group is still due after this update.
    final otherGroupsDue = updatedGroups.any(
      (g) => g.groupIndex != groupIndex && g.isDue,
    );

    final nextActiveIndex = otherGroupsDue
        ? updatedGroups
              .where((g) => g.groupIndex != groupIndex && g.isDue)
              .map((g) => g.groupIndex)
              .reduce((a, b) => a < b ? a : b)
        : null;

    final updatedState = current.copyWith(
      groups: updatedGroups,
      isCheckpointActive: otherGroupsDue,
      activeGroupIndex: nextActiveIndex,
    );

    final repo = ref.read(checkpointRepositoryProvider);
    await repo.save(updatedState);
    state = AsyncData(updatedState);
  }

  /// Record a BAC measurement for a single player within the active group window.
  ///
  /// Tracks per-player progress. When all players in the active group have been
  /// measured, the UI lock is released (delegates to [completeGroupMeasurement]).
  Future<void> recordPlayerMeasurement(String playerId) async {
    final current = state.value;
    if (current == null) return;

    final activeIdx = current.activeGroupIndex;
    if (activeIdx == null) return;
    if (activeIdx >= current.groups.length) return;

    final activeGroup = current.groups[activeIdx];

    // Track which players in the active group have been measured this window.
    // We use a Set stored as a transient field; since CheckpointState is
    // persisted, we derive "measured" from the group's playerIds minus those
    // still pending. We keep a lightweight in-memory set per notifier instance.
    _measuredPlayerIds.add(playerId);

    final allMeasured = activeGroup.playerIds.every(
      (id) => _measuredPlayerIds.contains(id),
    );

    if (allMeasured) {
      _measuredPlayerIds.clear();
      await completeGroupMeasurement(activeIdx);
    }
  }

  /// Cancel the ticker, delete Hive state, and reset to null.
  Future<void> reset() async {
    _ticker?.cancel();
    _ticker = null;
    _measuredPlayerIds.clear();

    final repo = ref.read(checkpointRepositoryProvider);
    await repo.delete();
    state = const AsyncData(null);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// In-memory set of player IDs that have been measured in the current window.
  final Set<String> _measuredPlayerIds = {};

  /// Returns true if [playerId] has been measured in the current window.
  /// Used by [activeGroupProgress] to compute progress without persisting.
  bool hasMeasuredInWindow(String playerId, DateTime windowStart) {
    // windowStart is the lastMeasurement of the active group at the time the
    // window opened. We track in-memory via _measuredPlayerIds.
    return _measuredPlayerIds.contains(playerId);
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
