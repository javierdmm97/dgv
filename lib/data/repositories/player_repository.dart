import '../../core/models/player_profile.dart';

/// Player repository interface
abstract interface class PlayerRepository {
  /// Get all players
  Future<List<PlayerProfile>> getAll();

  /// Get player by ID
  Future<PlayerProfile?> getById(String id);

  /// Save player
  Future<void> save(PlayerProfile player);

  /// Delete player
  Future<void> delete(String id);

  /// Update player
  Future<void> update(PlayerProfile player);

  /// Check if player exists
  Future<bool> exists(String id);

  /// Get player count
  Future<int> count();

  /// Clear all players
  Future<void> clearAll();

  /// Watch all players (stream)
  Stream<List<PlayerProfile>> watchAll();
}
