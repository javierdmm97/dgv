import 'dart:async';
import 'dart:convert';
import '../../core/models/checkpoint_state.dart';
import '../../core/storage/hive_service.dart';
import 'checkpoint_repository.dart';

/// Checkpoint repository implementation using Hive
class CheckpointRepositoryImpl implements CheckpointRepository {
  static const String _currentCheckpointKey = 'current_checkpoint';
  final _streamController = StreamController<CheckpointState?>.broadcast();

  @override
  Future<CheckpointState?> getCurrent() async {
    final box = HiveService.getCheckpointBox();
    final json = box.get(_currentCheckpointKey) as String?;

    if (json == null) return null;

    return CheckpointState.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> save(CheckpointState state) async {
    final box = HiveService.getCheckpointBox();
    final json = jsonEncode(state.toJson());
    await box.put(_currentCheckpointKey, json);
    _notifyListeners();
  }

  @override
  Future<void> delete() async {
    final box = HiveService.getCheckpointBox();
    await box.delete(_currentCheckpointKey);
    _notifyListeners();
  }

  @override
  Stream<CheckpointState?> watch() {
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
