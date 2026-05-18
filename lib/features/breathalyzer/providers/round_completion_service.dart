import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/utils/title_evaluator.dart';
import 'package:dgv/data/repositories/player_repository.dart';

/// Evaluates and applies per-round title awards after all groups complete.
///
/// Called from [CheckpointNotifier._completeCheckpoint] after all groups
/// in a checkpoint have been measured.
class RoundCompletionService {
  RoundCompletionService._();

  static Future<Map<String, DGTTitle>> evaluateAndApply({
    required List<PlayerProfile> players,
    required int round,
    required PlayerRepository repo,
  }) async {
    final awards = TitleEvaluator.evaluateRound(players, round);

    for (final entry in awards.entries) {
      final idx = players.indexWhere((p) => p.id == entry.key);
      if (idx < 0) continue;

      final player = players[idx];
      final newCounts = Map<DGTTitle, int>.from(player.titleCounts);
      newCounts[entry.value] = (newCounts[entry.value] ?? 0) + 1;

      final updated = player.copyWith(titleCounts: newCounts);
      await repo.update(updated);
    }

    return awards;
  }
}
