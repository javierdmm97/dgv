import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/game_state.dart';
import '../models/player_profile.dart';
import '../utils/title_evaluator.dart';
import 'player_providers.dart';
import 'repository_providers.dart';
import 'package:dgv/features/firebase/providers/firebase_providers.dart';

part 'game_state_providers.g.dart';

/// Current game state provider
@riverpod
Future<GameState?> currentGameState(CurrentGameStateRef ref) async {
  final repository = ref.watch(gameStateRepositoryProvider);
  return repository.getCurrent();
}

/// Is game in progress provider
@riverpod
Future<bool> isGameInProgress(IsGameInProgressRef ref) async {
  final repository = ref.watch(gameStateRepositoryProvider);
  return repository.isGameInProgress();
}

/// Game state notifier (for mutations)
@riverpod
class GameStateNotifier extends _$GameStateNotifier {
  @override
  Future<GameState?> build() async {
    final repository = ref.watch(gameStateRepositoryProvider);
    return repository.getCurrent();
  }

  /// Start a new game
  Future<void> startGame(
    List<String> playerIds, {
    double preGameBeers = 0.0,
  }) async {
    final repository = ref.read(gameStateRepositoryProvider);

    final newGame = GameState(
      id: const Uuid().v4(),
      startTime: DateTime.now(),
      currentRound: 0,
      isInProgress: true,
      playerIds: playerIds,
      lastCheckpointTime: DateTime.now(),
      preGameBeers: preGameBeers,
    );

    await repository.save(newGame);
    unawaited(ref.read(firebaseSyncServiceProvider).syncSessionCreate(newGame));
    ref.invalidateSelf();
  }

  /// Resume existing game
  Future<void> resumeGame() async {
    // Game state is already loaded, just navigate to appropriate screen
    ref.invalidateSelf();
  }

  /// Advance to next round
  Future<void> advanceRound() async {
    final currentState = state.value;
    if (currentState == null) return;

    final repository = ref.read(gameStateRepositoryProvider);
    final updatedState = currentState.copyWith(
      currentRound: currentState.currentRound + 1,
      lastCheckpointTime: DateTime.now(),
    );

    await repository.save(updatedState);
    ref.invalidateSelf();
  }

  /// Finish game
  Future<void> finishGame() async {
    final repository = ref.read(gameStateRepositoryProvider);
    final currentState = state.value ?? await repository.getCurrent();
    if (currentState == null) return;

    final updatedState = currentState.copyWith(
      isInProgress: false,
      isFinished: true,
      finishTime: DateTime.now(),
    );

    await repository.save(updatedState);
    final playerRepo = ref.read(playerRepositoryProvider);
    final syncService = ref.read(firebaseSyncServiceProvider);
    unawaited(
      playerRepo.getAll().then(
        (p) => syncService.syncGameFinish(updatedState, p, _buildCeremony(p)),
      ),
    );
    // Flush player cache so post-game screens (main menu, ceremony) see
    // the final readings and title counts without stale data.
    ref.invalidate(playerListNotifierProvider);
    ref.invalidateSelf();
  }

  /// Delete game state (reset)
  Future<void> deleteGame() async {
    final repository = ref.read(gameStateRepositoryProvider);
    await repository.delete();
    ref.invalidateSelf();
  }

  /// Update game state
  Future<void> updateGameState(GameState state) async {
    final repository = ref.read(gameStateRepositoryProvider);
    await repository.save(state);
    ref.invalidateSelf();
  }
}

const _kStickerKeys = [
  'sin_pegatina',
  'pegatina_b',
  'pegatina_c',
  'pegatina_eco',
  'pegatina_0_emisiones',
];

Map<String, dynamic> _buildCeremony(List<PlayerProfile> players) {
  final podium = TitleEvaluator.calculateLeaderboard(players).take(3).toList();
  final coleccionista = TitleEvaluator.getMostTitlesPlayer(players);
  final environmentals = TitleEvaluator.getEnvironmentalDistinctives(players);

  return {
    'podium': [
      for (var i = 0; i < podium.length; i++)
        {
          'rank': i + 1,
          'playerId': podium[i].id,
          'name': podium[i].name,
          'surname': podium[i].surname,
          'points': podium[i].points,
        },
    ],
    'coleccionista': coleccionista == null
        ? null
        : {
            'playerId': coleccionista.id,
            'name': coleccionista.name,
            'surname': coleccionista.surname,
            'totalTitles': coleccionista.titleCounts.values
                .fold(0, (s, c) => s + c),
          },
    'environmentals': [
      for (var i = 0; i < environmentals.length; i++)
        {
          'rank': i + 1,
          'stickerKey': _kStickerKeys[i],
          'playerId': environmentals[i].id,
          'name': environmentals[i].name,
          'surname': environmentals[i].surname,
          'maxBAC': environmentals[i].maxBAC,
        },
    ],
  };
}
