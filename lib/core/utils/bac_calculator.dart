import '../constants/app_constants.dart';
import '../models/player_profile.dart';

/// BAC Calculator for breathalyzer readings (BrAC in mg/L)
///
/// IMPORTANT: Breathalyzers measure BrAC (Breath Alcohol Content) in mg/L of exhaled air
///
/// DGT Reference Data (immediate consumption, no metabolism):
/// Men 70kg:  1 beer = 0.3 mg/L | 2 beers = 0.6 mg/L | 3 beers = 0.8 mg/L
/// Men 80kg:  1 beer = 0.2 mg/L | 2 beers = 0.5 mg/L | 3 beers = 0.7 mg/L
/// Women 50kg: 1 beer = 0.5 mg/L | 2 beers = 1.0 mg/L | 3 beers = 1.5 mg/L
/// Women 60kg: 1 beer = 0.5 mg/L | 2 beers = 0.8 mg/L | 3 beers = 1.2 mg/L
///
/// Party Context (6-8 hours, 10-12 beers with metabolism):
/// - Small person (50-60kg): Peak ~4.0-5.0 mg/L, Optimal ~2.5 mg/L
/// - Medium person (65-75kg): Peak ~3.0-3.5 mg/L, Optimal ~2.0 mg/L
/// - Large person (80-90kg): Peak ~2.5-3.0 mg/L, Optimal ~1.8 mg/L
///
/// Game Thresholds:
/// - Optimal zone: ±0.2 mg/L from target
/// - Close: ±0.4 mg/L from target
/// - Impoundment: 3.5 mg/L (sit out next round)
/// - Dangerous spike: >0.8 mg/L per hour (3 beers/hour)
///
/// The breathalyzer reading is the actual measurement - we personalize targets
/// by body size to level the playing field between different players.
class BACCalculator {
  BACCalculator._();

  /// Calculate theoretical BAC from drinks consumed (for estimation only)
  /// In the actual game, we use breathalyzer readings directly!
  /// Formula: BAC = (Alcohol consumed in grams / (Body weight in grams × r)) × 100
  /// r = 0.68 for men, 0.55 for women
  static double calculateBAC({
    required double alcoholGrams,
    required Sex sex,
    required BodySize bodySize,
  }) {
    final bodyWeight = _getBodyWeight(bodySize);
    final r = sex == Sex.male
        ? AppConstants.widmarkRMale
        : AppConstants.widmarkRFemale;
    return (alcoholGrams / (bodyWeight * 1000 * r)) * 100;
  }

  /// Get body weight estimate based on body size
  static double _getBodyWeight(BodySize size) {
    switch (size) {
      case BodySize.small:
        return AppConstants.bodyWeightSmall;
      case BodySize.medium:
        return AppConstants.bodyWeightMedium;
      case BodySize.large:
        return AppConstants.bodyWeightLarge;
    }
  }

  /// Calculate optimal breathalyzer reading zone based on body size
  /// These are "sweet spot" targets for sustained drinking over 6-8 hours
  /// Based on DGT data extrapolated for party context
  /// Breathalyzer readings in mg/L:
  /// - Small (50-60kg): 2.5 mg/L (~6-7 beers sustained)
  /// - Medium (65-75kg): 2.0 mg/L (~7-8 beers sustained)
  /// - Large (80-90kg): 1.8 mg/L (~8-9 beers sustained)
  ///
  /// Note: Larger people have LOWER optimal readings because they metabolize
  /// alcohol more efficiently and feel comfortable at lower BrAC levels
  static double calculateOptimalBAC(BodySize size) {
    switch (size) {
      case BodySize.small:
        return AppConstants.optimalBACSmall;
      case BodySize.medium:
        return AppConstants.optimalBACMedium;
      case BodySize.large:
        return AppConstants.optimalBACLarge;
    }
  }

  /// Check if BAC is in the "sweet spot" (±0.02 tolerance)
  static bool isInOptimalZone(double currentBAC, double optimalBAC) {
    return (currentBAC - optimalBAC).abs() <=
        AppConstants.optimalToleranceClose;
  }

  /// Check if BAC is close to optimal (±0.02-0.05)
  static bool isCloseToOptimal(double currentBAC, double optimalBAC) {
    final diff = (currentBAC - optimalBAC).abs();
    return diff > AppConstants.optimalToleranceClose &&
        diff <= AppConstants.optimalToleranceFar;
  }

  /// Check if player crossed the optimal line (>+0.05)
  static bool crossedOptimalLine(double currentBAC, double optimalBAC) {
    return currentBAC > (optimalBAC + AppConstants.optimalToleranceFar);
  }

  /// Check if BAC is too low (<-0.05 from optimal)
  static bool isTooLow(double currentBAC, double optimalBAC) {
    return currentBAC < (optimalBAC - AppConstants.optimalToleranceFar);
  }

  /// Calculate BAC change rate per hour
  static double calculateBACRatePerHour(
    double currentBAC,
    double previousBAC,
    Duration timeDelta,
  ) {
    if (timeDelta.inMinutes == 0) return 0.0;
    final delta = currentBAC - previousBAC;
    return delta / (timeDelta.inMinutes / 60.0);
  }

  /// Check if BAC spike is dangerous (>0.15/hr)
  static bool isDangerousSpike(
    double currentBAC,
    double previousBAC,
    Duration timeDelta,
  ) {
    final ratePerHour = calculateBACRatePerHour(
      currentBAC,
      previousBAC,
      timeDelta,
    );
    return ratePerHour > AppConstants.dangerousSpikeRate;
  }
}
