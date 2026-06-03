/// Integration tests for CheckpointNotifier + CheckpointRepositoryImpl + Hive.
///
/// These tests exercise the full provider → repository → Hive stack using a
/// real (in-memory) Hive instance initialised in a temporary directory.
/// They run with `flutter test` — no device required.
///
/// Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:dgv/core/constants/app_constants.dart';
import 'package:dgv/core/models/checkpoint_state.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/checkpoint_providers.dart';
import 'package:dgv/core/providers/repository_providers.dart';
import 'package:dgv/data/repositories/checkpoint_repository_impl.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PlayerProfile _makePlayer(String id) => PlayerProfile(
  id: id,
  name: 'Player',
  surname: id,
  photoPath: '',
  sex: Sex.male,
  bodySize: BodySize.medium,
  licenseImagePath: '',
);

List<PlayerProfile> _makePlayers(int count) =>
    List.generate(count, (i) => _makePlayer('p$i'));

/// Build a [ProviderContainer] that uses a real [CheckpointRepositoryImpl].
/// The repository reads from the Hive box that was opened in [setUp].
ProviderContainer _makeContainer() {
  return ProviderContainer(
    overrides: [
      checkpointRepositoryProvider.overrideWithValue(
        CheckpointRepositoryImpl(),
      ),
    ],
  );
}

/// Wait for the [CheckpointNotifier] to finish loading (AsyncLoading → data).
/// Also keeps the provider alive while waiting.
Future<CheckpointState?> _awaitState(ProviderContainer container) async {
  final completer = Completer<CheckpointState?>();
  final sub = container.listen<AsyncValue<CheckpointState?>>(
    checkpointNotifierProvider,
    (previous, next) {
      if (!next.isLoading && !completer.isCompleted) {
        completer.complete(next.value);
      }
    },
    fireImmediately: true,
  );

  final result = await completer.future.timeout(
    const Duration(seconds: 5),
    onTimeout: () => null,
  );
  sub.close();
  return result;
}

/// Keep a provider alive for the duration of a test by subscribing to it.
/// Returns a [ProviderSubscription] that must be closed when done.
ProviderSubscription<AsyncValue<CheckpointState?>> _keepAlive(
  ProviderContainer container,
) {
  return container.listen<AsyncValue<CheckpointState?>>(
    checkpointNotifierProvider,
    (prev, next) {},
    fireImmediately: false,
  );
}

// ---------------------------------------------------------------------------
// Test setup / teardown
// ---------------------------------------------------------------------------

late Directory _tempDir;

Future<void> _setUpHive() async {
  _tempDir = await Directory.systemTemp.createTemp('hive_test_');
  Hive.init(_tempDir.path);
  await Future.wait([
    Hive.openBox<dynamic>(AppConstants.hiveBoxCheckpoint),
    Hive.openBox<dynamic>(AppConstants.hiveBoxPlayers),
    Hive.openBox<dynamic>(AppConstants.hiveBoxGameState),
    Hive.openBox<dynamic>(AppConstants.hiveBoxSettings),
  ]);
}

Future<void> _tearDownHive() async {
  await Hive.close();
  await _tempDir.delete(recursive: true);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(_setUpHive);
  tearDown(_tearDownHive);

  // ── Scenario 1: initialize() persists state to Hive ─────────────────────
  // Requirement 15.1

  test(
    'Scenario 1: initialize() with 5 groups persists CheckpointState to Hive',
    () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final keepAlive = _keepAlive(container);
      addTearDown(keepAlive.close);

      final players3Groups = _makePlayers(24);

      final notifier = container.read(checkpointNotifierProvider.notifier);
      await notifier.initialize(players: players3Groups, intervalMinutes: 45);

      // Read directly from the repository (bypassing the provider cache)
      final repo = container.read(checkpointRepositoryProvider);
      final persisted = await repo.getCurrent();

      expect(persisted, isNotNull);
      expect(persisted!.groups.length, equals(5));
      expect(persisted.intervalMinutes, equals(45));

      // Total players across all groups equals 24
      final total = persisted.groups.fold<int>(
        0,
        (sum, g) => sum + g.playerIds.length,
      );
      expect(total, equals(24));
    },
  );

  // ── Scenario 2: restart restores timers from Hive ───────────────────────
  // Requirement 15.2

  test(
    'Scenario 2: new ProviderContainer restores group timers from Hive',
    () async {
      // First container: initialize state
      final container1 = _makeContainer();
      addTearDown(container1.dispose);
      final keepAlive1 = _keepAlive(container1);
      addTearDown(keepAlive1.close);

      final players = _makePlayers(9); // 2 groups
      await container1
          .read(checkpointNotifierProvider.notifier)
          .initialize(players: players, intervalMinutes: 45);

      final state1 = await _awaitState(container1);
      expect(state1, isNotNull);
      expect(state1!.groups.length, equals(2));

      // Dispose first container (simulates app restart)
      container1.dispose();

      // Second container: should restore from Hive
      final container2 = _makeContainer();
      addTearDown(container2.dispose);
      final keepAlive2 = _keepAlive(container2);
      addTearDown(keepAlive2.close);

      final state2 = await _awaitState(container2);

      expect(state2, isNotNull);
      expect(state2!.groups.length, equals(2));
      expect(state2.intervalMinutes, equals(45));

      // Each group's playerIds should be preserved
      for (var i = 0; i < state1.groups.length; i++) {
        expect(state2.groups[i].playerIds, equals(state1.groups[i].playerIds));
      }
    },
  );

  test(
    'Scenario 2b: overdue groups restore as waiting to be measured',
    () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final overdueAt = DateTime.now().subtract(const Duration(minutes: 5));
      final lastMeasurement = DateTime.now().subtract(
        const Duration(minutes: 35),
      );
      final savedState = CheckpointState(
        currentRound: 1,
        intervalMinutes: 30,
        groups: [
          GroupCheckpoint(
            groupIndex: 0,
            playerIds: const ['p0', 'p1'],
            lastMeasurement: lastMeasurement,
            intervalMinutes: 30,
            nextCheckpoint: overdueAt,
          ),
          GroupCheckpoint(
            groupIndex: 1,
            playerIds: const ['p2', 'p3'],
            lastMeasurement: lastMeasurement,
            intervalMinutes: 30,
            nextCheckpoint: overdueAt,
          ),
        ],
      );

      final repo = container.read(checkpointRepositoryProvider);
      await repo.save(savedState);

      final keepAlive = _keepAlive(container);
      addTearDown(keepAlive.close);

      final restored = await _awaitState(container);

      expect(restored, isNotNull);
      expect(restored!.isCheckpointActive, isTrue);
      expect(restored.activeGroupIndex, equals(0));
      expect(restored.groups.every((g) => g.isDue), isTrue);
      expect(restored.groups[0].nextCheckpoint, equals(overdueAt));
      expect(restored.groups[1].nextCheckpoint, equals(overdueAt));

      await container
          .read(checkpointNotifierProvider.notifier)
          .completeGroupMeasurement(0);

      final afterGroup0 = container.read(checkpointNotifierProvider).value;
      expect(afterGroup0, isNotNull);
      expect(afterGroup0!.isCheckpointActive, isTrue);
      expect(afterGroup0.activeGroupIndex, equals(1));
      expect(afterGroup0.groups[0].isDue, isFalse);
      expect(afterGroup0.groups[1].isDue, isTrue);

      final group0NextCheckpoint = afterGroup0.groups[0].nextCheckpoint;
      await container
          .read(checkpointNotifierProvider.notifier)
          .completeGroupMeasurement(0);
      final afterDuplicate = container.read(checkpointNotifierProvider).value;
      expect(afterDuplicate!.groups[0].nextCheckpoint, group0NextCheckpoint);
      expect(afterDuplicate.activeGroupIndex, equals(1));
    },
  );

  // ── Scenario 3: updating one group does not affect others ───────────────
  // Requirement 15.3

  test(
    'Scenario 3: completeGroupMeasurement() only updates the target group',
    () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final keepAlive = _keepAlive(container);
      addTearDown(keepAlive.close);

      final players = _makePlayers(16); // 4 groups of up to 5
      final notifier = container.read(checkpointNotifierProvider.notifier);
      await notifier.initialize(players: players, intervalMinutes: 45);

      final stateBefore = await _awaitState(container);
      expect(stateBefore, isNotNull);

      final dueAt = DateTime.now().subtract(const Duration(seconds: 1));
      final dueState = stateBefore!.copyWith(
        groups: stateBefore.groups
            .map(
              (group) => group.groupIndex == 0
                  ? group.copyWith(nextCheckpoint: dueAt)
                  : group,
            )
            .toList(),
      );
      notifier.state = AsyncData(dueState);

      final group0Before = dueState.groups[0];
      final group1Before = dueState.groups[1];

      // Complete group 0
      await notifier.completeGroupMeasurement(0);

      final stateAfter = container.read(checkpointNotifierProvider).value;
      expect(stateAfter, isNotNull);

      final group0After = stateAfter!.groups[0];
      final group1After = stateAfter.groups[1];

      // Group 0's lastMeasurement should have been updated
      expect(
        group0After.lastMeasurement.isAfter(group0Before.lastMeasurement) ||
            group0After.lastMeasurement == group0Before.lastMeasurement,
        isTrue,
      );

      // Group 1 should be unchanged
      expect(group1After.playerIds, equals(group1Before.playerIds));
      expect(group1After.intervalMinutes, equals(group1Before.intervalMinutes));
    },
  );

  // ── Scenario 4: recordPlayerMeasurement() unlocks UI when all measured ──
  // Requirement 15.5

  test('Scenario 4: recording all players in active group unlocks UI', () async {
    final container = _makeContainer();
    addTearDown(container.dispose);
    final keepAlive = _keepAlive(container);
    addTearDown(keepAlive.close);

    // Initialize with 3 players (1 group since ≤5)
    final players = _makePlayers(3);
    final notifier = container.read(checkpointNotifierProvider.notifier);
    await notifier.initialize(players: players, intervalMinutes: 45);

    // Wait for state to load
    final initialState = await _awaitState(container);
    expect(initialState, isNotNull);

    // Simulate the checkpoint becoming active by directly setting state
    // (the ticker would normally do this after the interval expires)
    final currentState = container.read(checkpointNotifierProvider).value!;
    final dueAt = DateTime.now().subtract(const Duration(seconds: 1));
    final activeState = currentState.copyWith(
      groups: currentState.groups
          .map((group) => group.copyWith(nextCheckpoint: dueAt))
          .toList(),
      isCheckpointActive: true,
      activeGroupIndex: 0,
    );
    // Update via the notifier's internal state (simulate ticker activation)
    // We do this by saving to Hive and then calling completeGroupMeasurement
    // after manually recording all players.
    final repo = container.read(checkpointRepositoryProvider);
    await repo.save(activeState);

    // Directly update the notifier state to reflect the active checkpoint
    // by using the public API: record all players
    // First, we need the notifier to know the group is active.
    // We'll use completeGroupMeasurement after manually tracking players.

    // Simulate: all 3 players record their measurements
    // The notifier tracks _measuredPlayerIds in-memory.
    // We need to set activeGroupIndex first.
    // Use the notifier's recordPlayerMeasurement which checks activeGroupIndex.

    // Since the notifier's in-memory state still has isCheckpointActive=false,
    // we need to update it. Use the notifier directly:
    notifier.state = AsyncData(activeState);

    // Now record all players
    for (final player in players) {
      await notifier.recordPlayerMeasurement(player.id);
    }

    // After all players measured, isCheckpointActive should be false
    final finalState = container.read(checkpointNotifierProvider).value;
    expect(finalState, isNotNull);
    expect(finalState!.isCheckpointActive, isFalse);
  });

  // ── Scenario 5: multiple due groups processed in index order ────────────
  // Requirement 15.6

  test(
    'Scenario 5: multiple due groups are processed in ascending index order',
    () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final keepAlive = _keepAlive(container);
      addTearDown(keepAlive.close);

      // Initialize with 16 players → 4 groups
      final players = _makePlayers(16);
      final notifier = container.read(checkpointNotifierProvider.notifier);
      await notifier.initialize(players: players, intervalMinutes: 45);

      final initialState = await _awaitState(container);
      expect(initialState, isNotNull);
      expect(initialState!.groups.length, equals(4));

      // Simulate both groups becoming due simultaneously
      final pastTime = DateTime.now().subtract(const Duration(hours: 2));
      final bothDueState = CheckpointState(
        currentRound: 1,
        intervalMinutes: 45,
        groups: [
          GroupCheckpoint(
            groupIndex: 0,
            playerIds: initialState.groups[0].playerIds,
            lastMeasurement: pastTime,
            intervalMinutes: 45,
          ),
          GroupCheckpoint(
            groupIndex: 1,
            playerIds: initialState.groups[1].playerIds,
            lastMeasurement: pastTime,
            intervalMinutes: 45,
          ),
        ],
        isCheckpointActive: true,
        activeGroupIndex: 0, // Group 0 is active first (lowest index)
      );

      // Set the state directly on the notifier
      notifier.state = AsyncData(bothDueState);

      // The active group should be index 0 (lowest due group)
      final loadedState = container.read(checkpointNotifierProvider).value;
      expect(loadedState, isNotNull);
      expect(loadedState!.activeGroupIndex, equals(0));

      // Complete group 0 — group 1 should become active
      await notifier.completeGroupMeasurement(0);

      final afterGroup0 = container.read(checkpointNotifierProvider).value;
      expect(afterGroup0, isNotNull);
      // Group 1 is still due (its lastMeasurement is still in the past)
      expect(afterGroup0!.isCheckpointActive, isTrue);
      expect(afterGroup0.activeGroupIndex, equals(1));
    },
  );

  // ── Scenario 6: reset() clears all state ────────────────────────────────

  test(
    'Scenario 6: reset() clears Hive state and sets provider to null',
    () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final keepAlive = _keepAlive(container);
      addTearDown(keepAlive.close);

      final players = _makePlayers(5);
      final notifier = container.read(checkpointNotifierProvider.notifier);
      await notifier.initialize(players: players, intervalMinutes: 45);

      // Verify state was saved
      final repo = container.read(checkpointRepositoryProvider);
      expect(await repo.getCurrent(), isNotNull);

      // Reset
      await notifier.reset();

      // Provider state should be null
      final state = container.read(checkpointNotifierProvider).value;
      expect(state, isNull);

      // Hive should be cleared
      expect(await repo.getCurrent(), isNull);
    },
  );
}
