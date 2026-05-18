import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/constants/app_constants.dart';
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

PlayerProfile _makePlayer({
  String id = 'p1',
  int points = 15,
  double optimalBAC = 2.0,
}) {
  return PlayerProfile(
    id: id,
    name: 'Test',
    surname: 'Player',
    photoPath: '',
    sex: Sex.male,
    bodySize: BodySize.medium,
    points: points,
    optimalBAC: optimalBAC,
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
        expect(result.isImpounded, isFalse);
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
        const optimal = 2.0;
        final repo = _FakePlayerRepo()
          ..seed(_makePlayer(points: 10, optimalBAC: optimal));
        final container = _makeContainer(repo: repo, currentRound: 1);
        addTearDown(container.dispose);

        // 2.0 is exactly at optimal → +2
        final result = await container
            .read(bACEntryNotifierProvider.notifier)
            .submitBAC('p1', optimal);

        expect(result.pointsChange, equals(AppConstants.pointsInOptimalZone));
      });

      test(
        'returns -5 and marks isImpounded when BAC >= impoundment threshold',
        () async {
          final repo = _FakePlayerRepo()..seed(_makePlayer(points: 10));
          final container = _makeContainer(repo: repo, currentRound: 1);
          addTearDown(container.dispose);

          final result = await container
              .read(bACEntryNotifierProvider.notifier)
              .submitBAC('p1', AppConstants.impoundmentThreshold);

          expect(result.pointsChange, equals(AppConstants.pointsImpounded));
          expect(result.isImpounded, isTrue);
        },
      );

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

        await container
            .read(bACEntryNotifierProvider.notifier)
            .submitBAC('p1', 2.0);

        expect(repo.lastUpdated, isNotNull);
        // +2 for optimal zone, 10+2=12
        expect(repo.lastUpdated!.points, equals(12));
      });

      test('player points never exceed maxPoints after submitBAC', () async {
        final repo = _FakePlayerRepo()
          ..seed(_makePlayer(points: AppConstants.maxPoints));
        final container = _makeContainer(repo: repo, currentRound: 1);
        addTearDown(container.dispose);

        await container
            .read(bACEntryNotifierProvider.notifier)
            .submitBAC('p1', 2.0); // +2

        expect(repo.lastUpdated!.points, equals(AppConstants.maxPoints));
      });
    });
  });
}
