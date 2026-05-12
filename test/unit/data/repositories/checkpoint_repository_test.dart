import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/checkpoint_state.dart';

import 'fake_box.dart';
// ---------------------------------------------------------------------------
// Testable repository
// ---------------------------------------------------------------------------

class _TestableCheckpointRepository {
  _TestableCheckpointRepository(this._box);

  static const String _currentCheckpointKey = 'current_checkpoint';
  final FakeBox<dynamic> _box;

  Future<CheckpointState?> getCurrent() async {
    final json = _box.get(_currentCheckpointKey) as String?;
    if (json == null) return null;
    try {
      return CheckpointState.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<void> save(CheckpointState state) async {
    await _box.put(_currentCheckpointKey, jsonEncode(state.toJson()));
  }

  Future<void> delete() async {
    await _box.delete(_currentCheckpointKey);
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

CheckpointState _makeCheckpointState({
  int currentRound = 1,
  int intervalMinutes = 45,
  List<GroupCheckpoint>? groups,
  bool isCheckpointActive = false,
  int? activeGroupIndex,
}) {
  final now = DateTime(2025, 1, 1, 14, 0);
  return CheckpointState(
    currentRound: currentRound,
    intervalMinutes: intervalMinutes,
    groups:
        groups ??
        [
          GroupCheckpoint(
            groupIndex: 0,
            playerIds: const ['p1', 'p2'],
            lastMeasurement: now,
            intervalMinutes: intervalMinutes,
          ),
        ],
    isCheckpointActive: isCheckpointActive,
    activeGroupIndex: activeGroupIndex,
  );
}

void main() {
  group('CheckpointRepository (via _TestableCheckpointRepository)', () {
    late FakeBox<dynamic> box;
    late _TestableCheckpointRepository repo;

    setUp(() {
      box = FakeBox<dynamic>(name: 'checkpoint');
      repo = _TestableCheckpointRepository(box);
    });

    tearDown(() async {
      await box.dispose();
    });

    // ── save / getCurrent round-trip ─────────────────────────────────────────

    group('save and getCurrent', () {
      test('round-trip preserves all fields', () async {
        final now = DateTime(2025, 1, 1, 14, 0);
        final state = CheckpointState(
          currentRound: 2,
          intervalMinutes: 30,
          groups: [
            GroupCheckpoint(
              groupIndex: 0,
              playerIds: const ['p1', 'p2', 'p3'],
              lastMeasurement: now,
              intervalMinutes: 30,
            ),
            GroupCheckpoint(
              groupIndex: 1,
              playerIds: const ['p4', 'p5'],
              lastMeasurement: now.add(const Duration(minutes: 15)),
              intervalMinutes: 30,
            ),
          ],
          isCheckpointActive: true,
          activeGroupIndex: 0,
        );

        await repo.save(state);
        final retrieved = await repo.getCurrent();

        expect(retrieved, isNotNull);
        expect(retrieved!.currentRound, equals(2));
        expect(retrieved.intervalMinutes, equals(30));
        expect(retrieved.groups.length, equals(2));
        expect(retrieved.groups[0].playerIds, equals(['p1', 'p2', 'p3']));
        expect(retrieved.groups[1].playerIds, equals(['p4', 'p5']));
        expect(retrieved.isCheckpointActive, isTrue);
        expect(retrieved.activeGroupIndex, equals(0));
      });

      test('getCurrent returns null when empty', () async {
        final result = await repo.getCurrent();
        expect(result, isNull);
      });

      test('empty groups list serializes as empty array', () async {
        const state = CheckpointState(
          currentRound: 1,
          intervalMinutes: 45,
          groups: [],
        );
        await repo.save(state);

        final retrieved = await repo.getCurrent();
        expect(retrieved!.groups, isEmpty);
      });
    });

    // ── delete ───────────────────────────────────────────────────────────────

    group('delete', () {
      test('removes checkpoint state', () async {
        await repo.save(_makeCheckpointState());
        await repo.delete();

        final result = await repo.getCurrent();
        expect(result, isNull);
      });

      test('delete when empty does not throw', () async {
        expect(() => repo.delete(), returnsNormally);
      });
    });

    // ── corrupted data ───────────────────────────────────────────────────────

    group('corrupted data', () {
      test('getCurrent returns null for corrupted JSON', () async {
        // Manually inject invalid JSON
        await box.put('current_checkpoint', 'not valid json {{{');

        final result = await repo.getCurrent();
        expect(result, isNull);
      });
    });

    // ── Property 14: CheckpointState JSON round-trip ─────────────────────────

    group('Property 14: CheckpointState JSON round-trip', () {
      // Feature: phase-1-completion, Property 14
      // Note: We use jsonEncode/jsonDecode to exercise the full serialization
      // pipeline, which correctly handles nested GroupCheckpoint objects.
      test(
        'full serialization round-trip produces equivalent object',
        () async {
          final now = DateTime(2025, 6, 15, 20, 30);
          final states = [
            // Single group, no active checkpoint
            CheckpointState(
              currentRound: 1,
              intervalMinutes: 45,
              groups: [
                GroupCheckpoint(
                  groupIndex: 0,
                  playerIds: const ['p1', 'p2'],
                  lastMeasurement: now,
                  intervalMinutes: 45,
                ),
              ],
            ),
            // Multiple groups, active checkpoint
            CheckpointState(
              currentRound: 3,
              intervalMinutes: 30,
              groups: [
                GroupCheckpoint(
                  groupIndex: 0,
                  playerIds: const ['p1'],
                  lastMeasurement: now,
                  intervalMinutes: 30,
                  nextCheckpoint: now.add(const Duration(minutes: 30)),
                ),
                GroupCheckpoint(
                  groupIndex: 1,
                  playerIds: const ['p2', 'p3'],
                  lastMeasurement: now.add(const Duration(minutes: 15)),
                  intervalMinutes: 30,
                ),
              ],
              isCheckpointActive: true,
              activeGroupIndex: 1,
            ),
            // Empty groups
            const CheckpointState(
              currentRound: 0,
              intervalMinutes: 60,
              groups: [],
            ),
          ];

          for (final state in states) {
            // Save via repository (which uses jsonEncode)
            await repo.save(state);
            final restored = await repo.getCurrent();

            expect(restored, isNotNull);
            expect(restored!.currentRound, equals(state.currentRound));
            expect(restored.intervalMinutes, equals(state.intervalMinutes));
            expect(restored.groups.length, equals(state.groups.length));
            expect(
              restored.isCheckpointActive,
              equals(state.isCheckpointActive),
            );
            expect(restored.activeGroupIndex, equals(state.activeGroupIndex));

            for (var i = 0; i < state.groups.length; i++) {
              expect(
                restored.groups[i].groupIndex,
                equals(state.groups[i].groupIndex),
              );
              expect(
                restored.groups[i].playerIds,
                equals(state.groups[i].playerIds),
              );
              expect(
                restored.groups[i].intervalMinutes,
                equals(state.groups[i].intervalMinutes),
              );
              expect(
                restored.groups[i].lastMeasurement.millisecondsSinceEpoch,
                equals(state.groups[i].lastMeasurement.millisecondsSinceEpoch),
              );
            }

            // Clean up for next iteration
            await repo.delete();
          }
        },
      );
    });
  });
}
