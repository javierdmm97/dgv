import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/utils/title_evaluator.dart';

part 'leaderboard_provider.g.dart';

/// Players sorted for leaderboard: primary = points desc, tiebreaker = perfection score asc.
///
/// Uses ref.watch so the leaderboard rebuilds immediately when any player changes.
@riverpod
List<PlayerProfile> sortedLeaderboard(SortedLeaderboardRef ref) {
  final players = ref.watch(playerListNotifierProvider).value ?? [];
  return List.unmodifiable(TitleEvaluator.calculateLeaderboard(players));
}
