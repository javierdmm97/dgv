import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/utils/title_evaluator.dart';

part 'ceremony_provider.g.dart';

/// Computed end-of-game ceremony data.
class CeremonyData {
  const CeremonyData({
    required this.top3,
    required this.coleccionista,
    required this.environmentals,
  });

  /// Top 3 players sorted by points desc, perfection score as tiebreaker.
  final List<PlayerProfile> top3;

  /// Player who accumulated the most DGT titles over the game.
  final PlayerProfile? coleccionista;

  /// Top 5 players by maximum BAC ("Los más contaminantes").
  final List<PlayerProfile> environmentals;
}

@riverpod
Future<CeremonyData> ceremonyData(CeremonyDataRef ref) async {
  final allPlayers = ref.watch(playerListNotifierProvider).value ?? [];
  final gameState = ref.watch(gameStateNotifierProvider).value;

  // Scope to players in this game session when available.
  final players = gameState != null && gameState.playerIds.isNotEmpty
      ? allPlayers.where((p) => gameState.playerIds.contains(p.id)).toList()
      : allPlayers;

  final sorted = TitleEvaluator.calculateLeaderboard(players);

  return CeremonyData(
    top3: sorted.take(3).toList(),
    coleccionista: TitleEvaluator.getMostTitlesPlayer(players),
    environmentals: TitleEvaluator.getEnvironmentalDistinctives(players),
  );
}
