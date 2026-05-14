import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/data/repositories/player_repository.dart';
import 'package:dgv/features/fake_id/services/license_generator.dart';

/// Re-generates a player's license image after points or titles change.
///
/// Delegates rendering to [LicenseGenerator] and persists the updated
/// [PlayerProfile.licenseImagePath] via the repository.
class LicenseUpdateService {
  const LicenseUpdateService._();

  static Future<void> updateForPlayer({
    required PlayerProfile player,
    required PlayerRepository repo,
  }) async {
    final newPath = await LicenseGenerator.generate(player);
    final updated = player.copyWith(licenseImagePath: newPath);
    await repo.update(updated);
  }
}
