import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/player_providers.dart';

part 'leaderboard_provider.g.dart';

/// Players sorted descending by points for leaderboard display.
@riverpod
Future<List<PlayerProfile>> sortedLeaderboard(SortedLeaderboardRef ref) async {
  final players = await ref.watch(playerListProvider.future);
  final sorted = [...players]..sort((a, b) => b.points.compareTo(a.points));
  return List.unmodifiable(sorted);
}
