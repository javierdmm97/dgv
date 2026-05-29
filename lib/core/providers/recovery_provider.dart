import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dgv/core/providers/checkpoint_providers.dart';
import 'package:dgv/core/providers/repository_providers.dart';

part 'recovery_provider.g.dart';

/// The screen the app should navigate to on launch based on saved state.
enum RecoveryRoute {
  /// No game in progress — show main menu.
  mainMenu,

  /// A checkpoint is active — show checkpoint screen.
  checkpoint,

  /// Game in progress but no active checkpoint — show leaderboard.
  leaderboard,
}

/// Reads Hive on app launch and determines the correct initial route.
///
/// - No game in progress → [RecoveryRoute.mainMenu]
/// - Game in progress + checkpoint active → [RecoveryRoute.checkpoint]
/// - Game in progress + no active checkpoint → [RecoveryRoute.leaderboard]
///
/// Also restores the checkpoint timer when a game is in progress.
@riverpod
class RecoveryNotifier extends _$RecoveryNotifier {
  @override
  Future<RecoveryRoute> build() async {
    final gameStateRepo = ref.watch(gameStateRepositoryProvider);
    final gameState = await gameStateRepo.getCurrent();

    // No game or already finished → main menu.
    if (gameState == null || gameState.isFinished || !gameState.isInProgress) {
      return RecoveryRoute.mainMenu;
    }

    // Game is in progress — check if a checkpoint is active.
    final checkpointRepo = ref.watch(checkpointRepositoryProvider);
    final checkpointState = await checkpointRepo.getCurrent();

    if (checkpointState != null) {
      // The CheckpointNotifier already loads from Hive in its build() method
      // and restarts the ticker automatically. Watching it here ensures it's
      // initialized before we check its state.
      ref.watch(checkpointNotifierProvider);

      if (checkpointState.isCheckpointActive) {
        return RecoveryRoute.checkpoint;
      }
    }

    return RecoveryRoute.leaderboard;
  }
}
