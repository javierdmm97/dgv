import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/checkpoint_providers.dart';
import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/providers/repository_providers.dart';

part 'main_menu_provider.freezed.dart';
part 'main_menu_provider.g.dart';

/// State for the main menu screen
@freezed
class MainMenuState with _$MainMenuState {
  const factory MainMenuState({
    required bool isGameInProgress,
    required List<PlayerProfile> players,
    @Default(true) bool isFakeErrorVisible,
  }) = _MainMenuState;
}

/// Notifier for the main menu screen
@riverpod
class MainMenuNotifier extends _$MainMenuNotifier {
  @override
  Future<MainMenuState> build() async {
    // Watch the mutating notifier — it calls ref.invalidateSelf() after every
    // startGame/deleteGame/advanceRound, so this rebuilds reactively in-session.
    final gameState = await ref.watch(gameStateNotifierProvider.future);
    // Watch the mutating notifier so the list rebuilds after addPlayer/deletePlayer
    final players = await ref.watch(playerListNotifierProvider.future);

    return MainMenuState(
      isGameInProgress: gameState?.isInProgress ?? false,
      players: players,
    );
  }

  /// Dismiss the fake error notification
  void dismissFakeError() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(isFakeErrorVisible: false));
  }

  /// Reset all game state and return to "no game in progress".
  /// Clears readings, points, titles and impoundment for every player,
  /// but keeps their registration data (name, photo, body size, etc.).
  Future<void> resetGame() async {
    await ref.read(checkpointNotifierProvider.notifier).reset();
    await ref.read(gameStateNotifierProvider.notifier).deleteGame();

    final repo = ref.read(playerRepositoryProvider);
    final players = await repo.getAll();
    for (final player in players) {
      await repo.update(
        player.copyWith(
          points: 15,
          readings: const [],
          titleCounts: const {},
          crossedOptimalLine: false,
          isImpounded: false,
          licenseImagePath: '',
        ),
      );
    }

    ref.invalidateSelf();
  }
}
