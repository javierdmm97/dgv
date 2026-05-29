import 'package:dgv/core/storage/hive_service.dart';

/// Repository for persisting the BAC curve multiplier setting.
///
/// The multiplier scales all optimal BrAC targets proportionally.
/// Range: [0.80, 1.20], default: 1.00.
abstract interface class CurveSettingsRepository {
  /// Returns the persisted multiplier, or [defaultMultiplier] if none saved.
  Future<double> getMultiplier();

  /// Persists [value] to storage.
  Future<void> saveMultiplier(double value);
}

/// Hive-backed implementation of [CurveSettingsRepository].
class HiveCurveSettingsRepository implements CurveSettingsRepository {
  static const String _key = 'curve_multiplier';
  static const double defaultMultiplier = 1.00;

  @override
  Future<double> getMultiplier() async {
    final box = HiveService.getSettingsBox();
    return (box.get(_key) as double?) ?? defaultMultiplier;
  }

  @override
  Future<void> saveMultiplier(double value) async {
    final box = HiveService.getSettingsBox();
    await box.put(_key, value);
  }
}
