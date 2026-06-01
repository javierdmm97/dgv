import 'package:dgv/core/constants/asset_paths.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/utils/title_evaluator.dart';
import 'package:dgv/features/fake_id/services/license_generator.dart';

/// Generates final PNG licenses for all players with end-of-game awards baked in.
///
/// Call [exportAll] at the end of the game (from the ceremony screen) to
/// produce PNGs that include podium medals, Coleccionista crown, and
/// environmental stickers. Returns all file paths for sharing.
class LicenseExportService {
  LicenseExportService._();

  /// Regenerates front and back PNGs for every player with final awards.
  ///
  /// Returns a flat list of file paths: [front1, back1, front2, back2, ...].
  static Future<List<String>> exportAll(List<PlayerProfile> players) async {
    if (players.isEmpty) return const [];

    final leaderboard = TitleEvaluator.calculateLeaderboard(players);
    final coleccionista = TitleEvaluator.getMostTitlesPlayer(players);
    final environmentals = TitleEvaluator.getEnvironmentalDistinctives(players);

    final paths = <String>[];

    for (final player in players) {
      final rank =
          leaderboard.indexWhere((p) => p.id == player.id) + 1; // 1-based
      final podium = rank >= 1 && rank <= 3 ? rank : null;
      final isColeccionista = coleccionista?.id == player.id;
      final envIndex = environmentals.indexWhere((p) => p.id == player.id);
      final envPath = envIndex >= 0 ? _environmentalPathFor(envIndex) : null;

      final front = await LicenseGenerator.generate(
        player,
        podiumPosition: podium,
        isColeccionista: isColeccionista,
      );
      final back = await LicenseGenerator.generateBack(
        player,
        environmentalAssetPath: envPath,
      );

      paths.addAll([front, back]);
    }

    return paths;
  }

  static String? _environmentalPathFor(int index) {
    return switch (index) {
      0 => AssetPaths.pegatina0Emisiones,
      1 => AssetPaths.pegatinaEco,
      2 => AssetPaths.pegatinab,
      3 => AssetPaths.pegatinac,
      4 => AssetPaths.sinPegatina,
      _ => null,
    };
  }
}
