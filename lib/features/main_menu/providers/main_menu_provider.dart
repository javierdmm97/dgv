import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';

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
    final gameState = await ref.watch(currentGameStateProvider.future);
    final players = await ref.watch(playerListProvider.future);

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
}
