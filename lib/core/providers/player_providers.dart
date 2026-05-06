import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/player_profile.dart';
import 'repository_providers.dart';

part 'player_providers.g.dart';

/// Player list provider
@riverpod
Future<List<PlayerProfile>> playerList(PlayerListRef ref) async {
  final repository = ref.watch(playerRepositoryProvider);
  return repository.getAll();
}

/// Player by ID provider
@riverpod
Future<PlayerProfile?> playerById(PlayerByIdRef ref, String id) async {
  final repository = ref.watch(playerRepositoryProvider);
  return repository.getById(id);
}

/// Player count provider
@riverpod
Future<int> playerCount(PlayerCountRef ref) async {
  final repository = ref.watch(playerRepositoryProvider);
  return repository.count();
}

/// Player list notifier (for mutations)
@riverpod
class PlayerListNotifier extends _$PlayerListNotifier {
  @override
  Future<List<PlayerProfile>> build() async {
    final repository = ref.watch(playerRepositoryProvider);
    return repository.getAll();
  }

  /// Add a new player
  Future<void> addPlayer(PlayerProfile player) async {
    final repository = ref.read(playerRepositoryProvider);
    await repository.save(player);
    ref.invalidateSelf();
  }

  /// Update a player
  Future<void> updatePlayer(PlayerProfile player) async {
    final repository = ref.read(playerRepositoryProvider);
    await repository.update(player);
    ref.invalidateSelf();
  }

  /// Delete a player
  Future<void> deletePlayer(String id) async {
    final repository = ref.read(playerRepositoryProvider);
    await repository.delete(id);
    ref.invalidateSelf();
  }

  /// Clear all players
  Future<void> clearAll() async {
    final repository = ref.read(playerRepositoryProvider);
    await repository.clearAll();
    ref.invalidateSelf();
  }
}
