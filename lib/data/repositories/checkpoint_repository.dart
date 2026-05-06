import '../../core/models/checkpoint_state.dart';

/// Checkpoint repository interface
abstract interface class CheckpointRepository {
  /// Get current checkpoint state
  Future<CheckpointState?> getCurrent();

  /// Save checkpoint state
  Future<void> save(CheckpointState state);

  /// Delete checkpoint state
  Future<void> delete();

  /// Watch checkpoint state (stream)
  Stream<CheckpointState?> watch();
}
