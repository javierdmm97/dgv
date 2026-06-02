import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/models/checkpoint_state.dart';
import 'package:dgv/core/models/game_state.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/checkpoint_providers.dart';
import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/providers/repository_providers.dart';
import 'package:dgv/data/repositories/player_repository.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_provider.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakePlayerRepo implements PlayerRepository {
  final _players = <String, PlayerProfile>{};
  PlayerProfile? lastUpdated;

  void seed(PlayerProfile p) => _players[p.id] = p;

  @override
  Future<PlayerProfile?> getById(String id) async => _players[id];

  @override
  Future<List<PlayerProfile>> getAll() async => _players.values.toList();

  @override
  Future<void> save(PlayerProfile player) async {
    _players[player.id] = player;
  }

  @override
  Future<void> update(PlayerProfile player) async {
    _players[player.id] = player;
    lastUpdated = player;
  }

  @override
  Future<void> delete(String id) async => _players.remove(id);

  @override
  Future<bool> exists(String id) async => _players.containsKey(id);

  @override
  Future<int> count() async => _players.length;

  @override
  Future<void> clearAll() async => _players.clear();

  @override
  Stream<List<PlayerProfile>> watchAll() =>
      Stream.value(_players.values.toList());
}

class _FakeCheckpointNotifier extends CheckpointNotifier {
  final List<String> measuredIds = [];

  @override
  Future<CheckpointState?> build() async => null;

  @override
  Future<void> recordPlayerMeasurement(String playerId) async {
    measuredIds.add(playerId);
  }
}

class _FakePlayerListNotifier extends PlayerListNotifier {
  @override
  Future<List<PlayerProfile>> build() async => [];
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PlayerProfile _makePlayer({String id = 'p1', int points = 15}) {
  return PlayerProfile(
    id: id,
    name: 'Test',
    surname: 'Player',
    photoPath: '',
    sex: Sex.male,
    bodySize: BodySize.medium,
    points: points,
    licenseImagePath: '',
  );
}

GameState _makeGameState({int round = 0}) {
  return GameState(
    id: 'game1',
    startTime: DateTime.now(),
    currentRound: round,
    isInProgress: true,
  );
}

ProviderContainer _makeContainer({
  required _FakePlayerRepo repo,
  required int currentRound,
  _FakeCheckpointNotifier? checkpointFake,
}) {
  final checkNotifier = checkpointFake ?? _FakeCheckpointNotifier();
  return ProviderContainer(
    overrides: [
      playerRepositoryProvider.overrideWithValue(repo),
      currentGameStateProvider.overrideWith(
        (ref) async => _makeGameState(round: currentRound),
      ),
      checkpointNotifierProvider.overrideWith(() => checkNotifier),
      playerListNotifierProvider.overrideWith(() => _FakePlayerListNotifier()),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BACEntryNotifier.submitBAC', () {
    // ── Round 0 — baseline ────────────────────────────────────────────────────

    group('Round 0 (baseline)', () {
      test('returns result with 0 points change', () async {
        final repo = _FakePlayerRepo()..seed(_makePlayer());
        final container = _makeContainer(repo: repo, currentRound: 0);
        addTearDown(container.dispose);

        final result = await container
            .read(bACEntryNotifierProvider.notifier)
            .submitBAC('p1', 1.5);

        expect(result.pointsChange, equals(0));
        expect(result.roundNumber, equals(0));
      });

      test('saves a BACReading with roundNumber 0', () async {
        final repo = _FakePlayerRepo()..seed(_makePlayer());
        final container = _makeContainer(repo: repo, currentRound: 0);
        addTearDown(container.dispose);

        await container
            .read(bACEntryNotifierProvider.notifier)
            .submitBAC('p1', 1.5);

        expect(repo.lastUpdated, isNotNull);
        expect(repo.lastUpdated!.readings.length, equals(1));
        expect(repo.lastUpdated!.readings.first.roundNumber, equals(0));
        expect(repo.lastUpdated!.readings.first.bac, closeTo(1.5, 0.001));
      });

      test('does not call recordPlayerMeasurement on checkpoint', () async {
        final repo = _FakePlayerRepo()..seed(_makePlayer());
        final checkFake = _FakeCheckpointNotifier();
        final container = _makeContainer(
          repo: repo,
          currentRound: 0,
          checkpointFake: checkFake,
        );
        addTearDown(container.dispose);

        await container
            .read(bACEntryNotifierProvider.notifier)
            .submitBAC('p1', 1.5);

        expect(checkFake.measuredIds, isEmpty);
      });

      test('throws StateError if player not found', () async {
        final repo = _FakePlayerRepo(); // empty — no players seeded
        final container = _makeContainer(repo: repo, currentRound: 0);
        addTearDown(container.dispose);

        expect(
          () => container
              .read(bACEntryNotifierProvider.notifier)
              .submitBAC('missing', 1.5),
          throwsA(isA<StateError>()),
        );
      });
    });

    // ── Round 1+ — active scoring ─────────────────────────────────────────────

    group('Round 1 (active)', () {
      test('returns +2 points when BAC is in optimal zone', () async {
        final repo = _FakePlayerRepo()..seed(_makePlayer(points: 10));
        final container = _makeContainer(repo: repo, currentRound: 1);
        addTearDown(container.dispose);

        // Round 1 optimal for medium male = 0.111, so 0.111 is in sweet spot
        final result = await container
            .read(bACEntryNotifierProvider.notifier)
            .submitBAC('p1', 0.111);

        expect(result.pointsChange, equals(2));
      });

      test('returns -4 and issues fine when BAC crosses optimal line', () async {
        final repo = _FakePlayerRepo()..seed(_makePlayer(points: 10));
        final container = _makeContainer(repo: repo, currentRound: 1);
        addTearDown(container.dispose);

        // Round 1 optimal for medium male = 0.111, fine threshold = 0.111 * 1.8 = 0.200
        // 0.35 is well above threshold
        final result = await container
            .read(bACEntryNotifierProvider.notifier)
            .submitBAC('p1', 0.35);

        expect(result.pointsChange, equals(-4));
        expect(result.fineCount, equals(1));
      });

      test('calls recordPlayerMeasurement on checkpoint notifier', () async {
        final repo = _FakePlayerRepo()..seed(_makePlayer());
        final checkFake = _FakeCheckpointNotifier();
        final container = _makeContainer(
          repo: repo,
          currentRound: 1,
          checkpointFake: checkFake,
        );
        addTearDown(container.dispose);

        await container
            .read(bACEntryNotifierProvider.notifier)
            .submitBAC('p1', 2.0);

        expect(checkFake.measuredIds, contains('p1'));
      });

      test('saves updated player to repository', () async {
        final repo = _FakePlayerRepo()..seed(_makePlayer(points: 10));
        final container = _makeContainer(repo: repo, currentRound: 1);
        addTearDown(container.dispose);

        // Round 1 optimal = 0.111, submit 0.111 for +2
        await container
            .read(bACEntryNotifierProvider.notifier)
            .submitBAC('p1', 0.111);

        expect(repo.lastUpdated, isNotNull);
        // +2 for sweet spot: 10+2=12
        expect(repo.lastUpdated!.points, equals(12));
      });

      test('player points never exceed 15 after submitBAC', () async {
        final repo = _FakePlayerRepo()..seed(_makePlayer(points: 15));
        final container = _makeContainer(repo: repo, currentRound: 1);
        addTearDown(container.dispose);

        // Round 1 optimal = 0.111, submit 0.111 for +2 (15+2 clamped to 15)
        await container
            .read(bACEntryNotifierProvider.notifier)
            .submitBAC('p1', 0.111);

        expect(repo.lastUpdated!.points, equals(15));
      });

      test('uses explicit roundNumber instead of mutable game round', () async {
        final repo = _FakePlayerRepo()..seed(_makePlayer(points: 10));
        final container = _makeContainer(repo: repo, currentRound: 2);
        addTearDown(container.dispose);

        await container
            .read(bACEntryNotifierProvider.notifier)
            .submitBAC('p1', 0.111, roundNumber: 1);

        expect(repo.lastUpdated, isNotNull);
        expect(repo.lastUpdated!.readings.single.roundNumber, equals(1));
      });

      test(
        'does not append or score duplicate reading for same round',
        () async {
          final existingReading = BACReading(
            id: 'r1',
            playerId: 'p1',
            bac: 0.111,
            timestamp: DateTime(2026, 6, 2, 10),
            roundNumber: 1,
            entryMethod: BACEntryMethod.manual,
            pointsChange: 2,
          );
          final player = _makePlayer(
            points: 12,
          ).copyWith(readings: [existingReading]);
          final repo = _FakePlayerRepo()..seed(player);
          final checkFake = _FakeCheckpointNotifier();
          final container = _makeContainer(
            repo: repo,
            currentRound: 2,
            checkpointFake: checkFake,
          );
          addTearDown(container.dispose);

          final result = await container
              .read(bACEntryNotifierProvider.notifier)
              .submitBAC('p1', 0.35, roundNumber: 1);

          final stored = await repo.getById('p1');
          expect(result.bac, equals(0.111));
          expect(result.roundNumber, equals(1));
          expect(stored!.points, equals(12));
          expect(stored.readings, hasLength(1));
          expect(repo.lastUpdated, isNull);
          expect(checkFake.measuredIds, contains('p1'));
        },
      );
    });
  });
}
