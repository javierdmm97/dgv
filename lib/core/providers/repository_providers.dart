import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/repositories/player_repository_impl.dart';
import '../../data/repositories/game_state_repository.dart';
import '../../data/repositories/game_state_repository_impl.dart';
import '../../data/repositories/checkpoint_repository.dart';
import '../../data/repositories/checkpoint_repository_impl.dart';
import '../../data/repositories/curve_settings_repository.dart';

part 'repository_providers.g.dart';

/// Player repository provider
@riverpod
PlayerRepository playerRepository(PlayerRepositoryRef ref) {
  return PlayerRepositoryImpl();
}

/// Game state repository provider
@riverpod
GameStateRepository gameStateRepository(GameStateRepositoryRef ref) {
  return GameStateRepositoryImpl();
}

/// Checkpoint repository provider
@riverpod
CheckpointRepository checkpointRepository(CheckpointRepositoryRef ref) {
  return CheckpointRepositoryImpl();
}

/// Curve settings repository provider
@riverpod
CurveSettingsRepository curveSettingsRepository(
  CurveSettingsRepositoryRef ref,
) {
  return HiveCurveSettingsRepository();
}

/// Current curve multiplier value (defaults to 1.00 if not persisted)
@riverpod
Future<double> curveMultiplier(CurveMultiplierRef ref) async {
  final repo = ref.watch(curveSettingsRepositoryProvider);
  return repo.getMultiplier();
}
