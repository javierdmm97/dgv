import 'dart:async';
import 'dart:io';

import 'package:flutter/painting.dart';

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

  /// Regenerates the license PNGs for [player] and persists the updated paths.
  ///
  /// Silently skips if asset loading fails (e.g. in unit-test environments
  /// where Flutter's rootBundle is unavailable). License generation is a
  /// non-critical visual update — game state remains correct either way.
  static Future<void> updateForPlayer({
    required PlayerProfile player,
    required PlayerRepository repo,
  }) async {
    try {
      final frontPath = await LicenseGenerator.generate(player);
      final backPath = await LicenseGenerator.generateBack(player);
      final updated = player.copyWith(
        licenseImagePath: frontPath,
        licenseBackImagePath: backPath,
      );
      await repo.update(updated);
      // The generator overwrites the same file path each round.
      // Evict from Flutter's image cache so the next load reads fresh from disk.
      unawaited(FileImage(File(frontPath)).evict());
      unawaited(FileImage(File(backPath)).evict());
    } catch (_) {
      // License generation is non-critical; skip silently on failure.
      // Uses bare catch to also handle FlutterError (no binding in unit tests).
    }
  }
}
