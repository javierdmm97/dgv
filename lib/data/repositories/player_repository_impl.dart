import 'dart:async';
import 'dart:convert';
import '../../core/models/player_profile.dart';
import '../../core/storage/hive_service.dart';
import 'player_repository.dart';

/// Player repository implementation using Hive
class PlayerRepositoryImpl implements PlayerRepository {
  final _streamController = StreamController<List<PlayerProfile>>.broadcast();

  @override
  Future<List<PlayerProfile>> getAll() async {
    final box = HiveService.getPlayersBox();
    final players = <PlayerProfile>[];

    for (final key in box.keys) {
      final json = box.get(key) as String?;
      if (json != null) {
        final player = PlayerProfile.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        );
        players.add(player);
      }
    }

    // Sort by creation date (newest first)
    players.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    return players;
  }

  @override
  Future<PlayerProfile?> getById(String id) async {
    final box = HiveService.getPlayersBox();
    final json = box.get(id) as String?;

    if (json == null) return null;

    return PlayerProfile.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> save(PlayerProfile player) async {
    final box = HiveService.getPlayersBox();
    final json = jsonEncode(player.toJson());
    await box.put(player.id, json);
    _notifyListeners();
  }

  @override
  Future<void> delete(String id) async {
    final box = HiveService.getPlayersBox();
    await box.delete(id);
    _notifyListeners();
  }

  @override
  Future<void> update(PlayerProfile player) async {
    await save(player); // Same as save for Hive
  }

  @override
  Future<bool> exists(String id) async {
    final box = HiveService.getPlayersBox();
    return box.containsKey(id);
  }

  @override
  Future<int> count() async {
    final box = HiveService.getPlayersBox();
    return box.length;
  }

  @override
  Future<void> clearAll() async {
    final box = HiveService.getPlayersBox();
    await box.clear();
    _notifyListeners();
  }

  @override
  Stream<List<PlayerProfile>> watchAll() {
    // Initial emit
    getAll().then((players) => _streamController.add(players));
    return _streamController.stream;
  }

  void _notifyListeners() {
    getAll().then((players) => _streamController.add(players));
  }

  void dispose() {
    _streamController.close();
  }
}
