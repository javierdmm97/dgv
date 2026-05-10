import 'dart:async';
import 'dart:convert';
import '../../core/models/game_state.dart';
import '../../core/storage/hive_service.dart';
import 'game_state_repository.dart';

/// Game state repository implementation using Hive
class GameStateRepositoryImpl implements GameStateRepository {
  static const String _currentGameKey = 'current_game';
  final _streamController = StreamController<GameState?>.broadcast();

  @override
  Future<GameState?> getCurrent() async {
    final box = HiveService.getGameStateBox();
    final json = box.get(_currentGameKey) as String?;

    if (json == null) return null;

    return GameState.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<void> save(GameState state) async {
    final box = HiveService.getGameStateBox();
    final json = jsonEncode(state.toJson());
    await box.put(_currentGameKey, json);
    _notifyListeners();
  }

  @override
  Future<void> delete() async {
    final box = HiveService.getGameStateBox();
    await box.delete(_currentGameKey);
    _notifyListeners();
  }

  @override
  Future<bool> isGameInProgress() async {
    final state = await getCurrent();
    return state?.isInProgress ?? false;
  }

  @override
  Stream<GameState?> watch() {
    // Initial emit
    getCurrent().then((state) => _streamController.add(state));
    return _streamController.stream;
  }

  void _notifyListeners() {
    getCurrent().then((state) => _streamController.add(state));
  }

  void dispose() {
    _streamController.close();
  }
}
