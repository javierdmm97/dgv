import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/utils/title_evaluator.dart';

part 'leaderboard_provider.g.dart';

/// Players sorted for leaderboard: primary = points desc, tiebreaker = perfection score asc.
///
/// When a game is in progress, only players in GameState.playerIds are shown —
/// avoids showing all registered players when only a subset was selected for control.
@riverpod
List<PlayerProfile> sortedLeaderboard(SortedLeaderboardRef ref) {
  final allPlayers = ref.watch(playerListNotifierProvider).value ?? [];
  final gameState = ref.watch(gameStateNotifierProvider).value;

  final players =
      gameState != null &&
          gameState.isInProgress &&
          gameState.playerIds.isNotEmpty
      ? allPlayers.where((p) => gameState.playerIds.contains(p.id)).toList()
      : allPlayers;

  return List.unmodifiable(TitleEvaluator.calculateLeaderboard(players));
}
