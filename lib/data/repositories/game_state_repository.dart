import '../../core/models/game_state.dart';

/// Game state repository interface
abstract interface class GameStateRepository {
  /// Get current game state
  Future<GameState?> getCurrent();

  /// Save game state
  Future<void> save(GameState state);

  /// Delete game state
  Future<void> delete();

  /// Check if game is in progress
  Future<bool> isGameInProgress();

  /// Watch game state (stream)
  Stream<GameState?> watch();
}
