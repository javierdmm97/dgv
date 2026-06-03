import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/checkpoint_repository.dart';
import '../../data/repositories/checkpoint_repository_impl.dart';
import '../../data/repositories/game_state_repository.dart';
import '../../data/repositories/game_state_repository_impl.dart';
import '../../data/repositories/hive_visual_style_repository.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/repositories/player_repository_impl.dart';
import '../../data/repositories/visual_style_repository.dart';

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

/// Visual style repository provider
@riverpod
VisualStyleRepository visualStyleRepository(VisualStyleRepositoryRef ref) {
  final box = Hive.box<Map<dynamic, dynamic>>('visual_style');
  return HiveVisualStyleRepository(box);
}
