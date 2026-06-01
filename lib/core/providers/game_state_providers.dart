import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/game_state.dart';
import 'player_providers.dart';
import 'repository_providers.dart';

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
