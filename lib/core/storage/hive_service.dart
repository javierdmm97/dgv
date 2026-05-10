import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

/// Hive initialization and box management service
class HiveService {
  HiveService._();

  static bool _initialized = false;

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Register adapters here when using Hive TypeAdapters
    // For now, we'll use JSON serialization

    // Open boxes
    await Future.wait([
      Hive.openBox(AppConstants.hiveBoxPlayers),
      Hive.openBox(AppConstants.hiveBoxGameState),
      Hive.openBox(AppConstants.hiveBoxCheckpoint),
      Hive.openBox(AppConstants.hiveBoxSettings),
    ]);

    _initialized = true;
  }

  /// Get players box
  static Box getPlayersBox() {
    return Hive.box(AppConstants.hiveBoxPlayers);
  }

  /// Get game state box
  static Box getGameStateBox() {
    return Hive.box(AppConstants.hiveBoxGameState);
  }

  /// Get checkpoint box
  static Box getCheckpointBox() {
    return Hive.box(AppConstants.hiveBoxCheckpoint);
  }

  /// Get settings box
  static Box getSettingsBox() {
    return Hive.box(AppConstants.hiveBoxSettings);
  }

  /// Clear all data (for testing or reset)
  static Future<void> clearAll() async {
    await Future.wait([
      getPlayersBox().clear(),
      getGameStateBox().clear(),
      getCheckpointBox().clear(),
      getSettingsBox().clear(),
    ]);
  }

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }
}
