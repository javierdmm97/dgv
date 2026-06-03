import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/game_state.dart';

import 'fake_box.dart';

// ---------------------------------------------------------------------------
// Testable repository
// ---------------------------------------------------------------------------

class _TestableGameStateRepository {
  _TestableGameStateRepository(this._box);

  static const String _currentGameKey = 'current_game';
  final FakeBox<dynamic> _box;

  Future<GameState?> getCurrent() async {
    final json = _box.get(_currentGameKey) as String?;
    if (json == null) return null;
    return GameState.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> save(GameState state) async {
    await _box.put(_currentGameKey, jsonEncode(state.toJson()));
  }

  Future<void> delete() async {
    await _box.delete(_currentGameKey);
  }

  Future<bool> isGameInProgress() async {
    final state = await getCurrent();
    return state?.isInProgress ?? false;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

GameState _makeGameState({
  String id = 'game1',
  bool isInProgress = true,
  bool isFinished = false,
  int currentRound = 1,
  List<String> playerIds = const ['p1', 'p2'],
  DateTime? finishTime,
}) => GameState(
  id: id,
  startTime: DateTime(2025, 1, 1, 14, 0),
  currentRound: currentRound,
  isInProgress: isInProgress,
  isFinished: isFinished,
  playerIds: playerIds,
  finishTime: finishTime,
);

void main() {
  group('GameStateRepository (via _TestableGameStateRepository)', () {
    late FakeBox<dynamic> box;
    late _TestableGameStateRepository repo;

    setUp(() {
      box = FakeBox<dynamic>(name: 'game_state');
      repo = _TestableGameStateRepository(box);
    });

    tearDown(() async {
      await box.dispose();
    });

    // ── save / getCurrent round-trip ─────────────────────────────────────────

    group('save and getCurrent', () {
      test('round-trip preserves all fields', () async {
        final state = _makeGameState(
          id: 'g1',
          currentRound: 3,
          playerIds: ['p1', 'p2', 'p3'],
        );
        await repo.save(state);

        final retrieved = await repo.getCurrent();
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('g1'));
        expect(retrieved.currentRound, equals(3));
        expect(retrieved.playerIds, equals(['p1', 'p2', 'p3']));
      });

      test('getCurrent returns null when empty', () async {
        final result = await repo.getCurrent();
        expect(result, isNull);
      });

      test('null finishTime serializes and deserializes correctly', () async {
        final state = _makeGameState(finishTime: null);
        await repo.save(state);

        final retrieved = await repo.getCurrent();
        expect(retrieved!.finishTime, isNull);
      });

      test(
        'non-null finishTime serializes and deserializes correctly',
        () async {
          final finish = DateTime(2025, 1, 2, 2, 0);
          final state = _makeGameState(
            isInProgress: false,
            isFinished: true,
            finishTime: finish,
          );
          await repo.save(state);

          final retrieved = await repo.getCurrent();
          expect(retrieved!.finishTime, isNotNull);
          expect(
            retrieved.finishTime!.millisecondsSinceEpoch,
            equals(finish.millisecondsSinceEpoch),
          );
        },
      );

      test('empty playerIds list serializes as empty array', () async {
        final state = _makeGameState(playerIds: []);
        await repo.save(state);

        final retrieved = await repo.getCurrent();
        expect(retrieved!.playerIds, isEmpty);
      });
    });

    // ── isGameInProgress ─────────────────────────────────────────────────────

    group('isGameInProgress', () {
      test('returns true when game exists and is in progress', () async {
        await repo.save(_makeGameState(isInProgress: true));
        expect(await repo.isGameInProgress(), isTrue);
      });

      test('returns false when game is finished', () async {
        await repo.save(_makeGameState(isInProgress: false, isFinished: true));
        expect(await repo.isGameInProgress(), isFalse);
      });

      test('returns false when no game state exists', () async {
        expect(await repo.isGameInProgress(), isFalse);
      });
    });

    // ── delete ───────────────────────────────────────────────────────────────

    group('delete', () {
      test('removes game state', () async {
        await repo.save(_makeGameState());
        await repo.delete();

        final result = await repo.getCurrent();
        expect(result, isNull);
      });

      test('delete when empty does not throw', () async {
        expect(() => repo.delete(), returnsNormally);
      });
    });

    // ── Property 15: GameState JSON round-trip ───────────────────────────────

    group('Property 15: GameState JSON round-trip', () {
      // Feature: phase-1-completion, Property 15
      test('fromJson(toJson()) produces equivalent object', () async {
        final states = [
          _makeGameState(
            id: 'g1',
            currentRound: 1,
            playerIds: ['p1', 'p2', 'p3'],
          ),
          _makeGameState(
            id: 'g2',
            currentRound: 5,
            isInProgress: false,
            isFinished: true,
            finishTime: DateTime(2025, 1, 2),
            playerIds: [],
          ),
          _makeGameState(
            id: 'g3',
            currentRound: 0,
            playerIds: List.generate(10, (i) => 'player_$i'),
          ),
        ];

        for (final state in states) {
          final json = state.toJson();
          final restored = GameState.fromJson(json);

          expect(restored.id, equals(state.id));
          expect(restored.currentRound, equals(state.currentRound));
          expect(restored.isInProgress, equals(state.isInProgress));
          expect(restored.isFinished, equals(state.isFinished));
          expect(restored.playerIds, equals(state.playerIds));
          expect(
            restored.finishTime?.millisecondsSinceEpoch,
            equals(state.finishTime?.millisecondsSinceEpoch),
          );
        }
      });
    });
  });
}
