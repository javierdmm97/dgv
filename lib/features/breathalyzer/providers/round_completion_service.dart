import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/utils/title_evaluator.dart';
import 'package:dgv/data/repositories/player_repository.dart';
import 'package:dgv/features/fake_id/services/license_update_service.dart';

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

    // Single pass over all players: apply title award if earned, then regenerate
    // the license. This replaces the per-submitBAC license call so every player
    // gets exactly one license write per round (after both points and title are final).
    for (final player in players) {
      final awarded = awards[player.id];
      PlayerProfile updated = player;
      if (awarded != null) {
        final newCounts = Map<DGTTitle, int>.from(player.titleCounts);
        newCounts[awarded] = (newCounts[awarded] ?? 0) + 1;
        updated = player.copyWith(titleCounts: newCounts);
        await repo.update(updated);
      }
      await LicenseUpdateService.updateForPlayer(player: updated, repo: repo);
    }

    return awards;
  }
}
