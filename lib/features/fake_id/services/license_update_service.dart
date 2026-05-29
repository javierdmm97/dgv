import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/data/repositories/player_repository.dart';
import 'package:dgv/features/fake_id/services/license_generator.dart';

/// Re-generates a player's license images (front and back) after points or
/// titles change.
///
/// Delegates rendering to [LicenseGenerator] and persists both updated paths
/// via the repository.
class LicenseUpdateService {
  const LicenseUpdateService._();

  static Future<void> updateForPlayer({
    required PlayerProfile player,
    required PlayerRepository repo,
  }) async {
    final frontPath = await LicenseGenerator.generate(player);
    final backPath = await LicenseGenerator.generateBack(player);
    final updated = player.copyWith(
      licenseImagePath: frontPath,
      licenseBackImagePath: backPath,
    );
    await repo.update(updated);
  }
}
