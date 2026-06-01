import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/game_state.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/repository_providers.dart';
import 'package:dgv/data/repositories/game_state_repository.dart';
import 'package:dgv/data/repositories/player_repository.dart';
import 'package:dgv/features/main_menu/presentation/final_ceremony_screen.dart';

// ---------------------------------------------------------------------------
// Fake game state repository
// ---------------------------------------------------------------------------

class _FakeGameStateRepository implements GameStateRepository {
  GameState? _state;

  @override
  Future<GameState?> getCurrent() async => _state;

  @override
  Future<void> save(GameState state) async {
    _state = state;
  }

  @override
  Future<void> delete() async {
    _state = null;
  }

  @override
  Future<bool> isGameInProgress() async => _state?.isInProgress ?? false;

  @override
  Stream<GameState?> watch() => Stream.value(_state);
}

// ---------------------------------------------------------------------------
// Fake player repository (needed because _returnToMenu resets player data)
// ---------------------------------------------------------------------------

class _FakePlayerRepository implements PlayerRepository {
  final _players = <String, PlayerProfile>{};

  @override
  Future<List<PlayerProfile>> getAll() async => _players.values.toList();
  @override
  Future<PlayerProfile?> getById(String id) async => _players[id];
  @override
  Future<void> save(PlayerProfile p) async => _players[p.id] = p;
  @override
  Future<void> update(PlayerProfile p) async => _players[p.id] = p;
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

// ---------------------------------------------------------------------------
// Test widget
// ---------------------------------------------------------------------------

Widget _wrap({GameState? initialState}) {
  final gameRepo = _FakeGameStateRepository();
  if (initialState != null) {
    gameRepo.save(initialState);
  }

  return ProviderScope(
    overrides: [
      gameStateRepositoryProvider.overrideWithValue(gameRepo),
      playerRepositoryProvider.overrideWithValue(_FakePlayerRepository()),
    ],
    child: const MaterialApp(home: FinalCeremonyScreen()),
  );
}

GameState _activeGame() => GameState(
  id: 'g1',
  startTime: DateTime.fromMillisecondsSinceEpoch(0),
  currentRound: 5,
  isInProgress: true,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FinalCeremonyScreen', () {
    testWidgets('shows ceremony content when data loads', (tester) async {
      await tester.pumpWidget(_wrap(initialState: _activeGame()));
      await tester.pumpAndSettle();

      expect(find.text('Ceremonia Final'), findsWidgets);
      expect(find.text('Premio Especial'), findsOneWidget);
    });

    testWidgets('shows Volver al Menú button', (tester) async {
      await tester.pumpWidget(_wrap(initialState: _activeGame()));
      await tester.pumpAndSettle();

      expect(find.text('Volver al Menú'), findsOneWidget);
    });

    testWidgets('Volver al Menú clears game state', (tester) async {
      final repo = _FakeGameStateRepository();
      repo.save(_activeGame());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateRepositoryProvider.overrideWithValue(repo),
            playerRepositoryProvider.overrideWithValue(_FakePlayerRepository()),
          ],
          child: const MaterialApp(home: FinalCeremonyScreen()),
        ),
      );
      await tester.pumpAndSettle(); // wait for async GameStateNotifier to load

      await tester.tap(find.text('Volver al Menú'));
      await tester.pumpAndSettle();

      final saved = await repo.getCurrent();
      expect(saved?.isInProgress, isFalse);
    });
  });
}
