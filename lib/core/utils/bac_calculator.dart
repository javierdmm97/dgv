import '../constants/app_constants.dart';
import '../models/player_profile.dart';

/// Predictive BrAC calculator for party mode pacing.
///
/// Targets use Widmark net accumulation: (absorption × rate) − 0.07 mg/L/hr elimination.
/// Males: 1.3 beers/hr (R1–R6) → 1.0 beers/hr (R7–R10).
/// Females: 1.0 beers/hr (R1–R6) → 0.7 beers/hr (R7–R10).
/// Smaller bodies and females reach higher BrAC at the same drinking pace.
class BACCalculator {
  BACCalculator._();

  // Party mode optimal BrAC targets for rounds 1-10 (mg/L)
  // Net increment = (beers/hr × Widmark absorption) − 0.07 mg/L/hr elimination
  // Males: 1.3 beers/hr R1-6, 1.0 beers/hr R7-10
  // Females: 1.0 beers/hr R1-6, 0.7 beers/hr R7-10
  static const Map<Sex, Map<BodySize, List<double>>> _partyModeTargets = {
    Sex.male: {
      // M-S (~65kg): +0.112 (R1-6), +0.070 (R7-10)
      BodySize.small: [
        0.112, 0.224, 0.336, 0.448, 0.560, 0.672, // R1-R6
        0.742, 0.812, 0.882, 0.952, // R7-R10
      ],
      // M-M (~78kg): +0.082 (R1-6), +0.047 (R7-10)
      BodySize.medium: [
        0.082, 0.164, 0.246, 0.328, 0.410, 0.492, // R1-R6
        0.539, 0.586, 0.633, 0.680, // R7-R10
      ],
      // M-L (~95kg): +0.055 (R1-6), +0.026 (R7-10)
      BodySize.large: [
        0.055, 0.110, 0.165, 0.220, 0.275, 0.330, // R1-R6
        0.356, 0.382, 0.408, 0.434, // R7-R10
      ],
    },
    Sex.female: {
      // F-S (~55kg): +0.135 (R1-6), +0.074 (R7-10)
      BodySize.small: [
        0.135, 0.270, 0.405, 0.540, 0.675, 0.810, // R1-R6
        0.884, 0.958, 1.032, 1.106, // R7-R10
      ],
      // F-M (~65kg): +0.103 (R1-6), +0.051 (R7-10)
      BodySize.medium: [
        0.103, 0.206, 0.309, 0.412, 0.515, 0.618, // R1-R6
        0.669, 0.720, 0.771, 0.822, // R7-R10
      ],
      // F-L (~80kg): +0.071 (R1-6), +0.029 (R7-10)
      BodySize.large: [
        0.071, 0.142, 0.213, 0.284, 0.355, 0.426, // R1-R6
        0.455, 0.484, 0.513, 0.542, // R7-R10
      ],
    },
  };

  /// Optimal BrAC for round N. Round 0 = 0.0 (baseline, no target).
  ///
  /// Rounds 1-10 use hardcoded party mode targets.
  /// Rounds 11+ extrapolate using the last known value (round 10).
  ///
  /// [curveMultiplier] scales the raw target proportionally.
  /// Range: [0.80, 1.20], default: 1.0 (no scaling).
  static double calculateOptimalBrAC(
    int roundNumber,
    Sex sex,
    BodySize bodySize, {
    double curveMultiplier = 1.0,
  }) {
    if (roundNumber <= 0) return 0.0;

    final targets = _partyModeTargets[sex]![bodySize]!;

    // Rounds 1-10: Use hardcoded targets
    final raw = roundNumber <= targets.length
        ? targets[roundNumber - 1]
        : targets[9]; // Rounds 11+: Use round 10 value (party is winding down)

    return raw * curveMultiplier;
  }

  /// BrAC offset (mg/L) for a given number of pre-game beers.
  ///
  /// Uses the Widmark formula: BrAC = grams_alcohol / (weight × r × 2.1)
  /// The 2.1 factor converts g/L blood to mg/L breath (Henry's law).
  /// Each player profile produces a different offset from the same beer count.
  static double preGameBacOffset(double beers, Sex sex, BodySize bodySize) {
    if (beers <= 0) return 0.0;
    final weight = _bodyWeight(bodySize);
    final r = sex == Sex.male
        ? AppConstants.widmarkRMale
        : AppConstants.widmarkRFemale;
    final grams = beers * AppConstants.gramsAlcoholPerStandardBeer;
    return grams / (weight * r * 2.1);
  }

  static double _bodyWeight(BodySize size) => switch (size) {
    BodySize.small => AppConstants.bodyWeightSmall,
    BodySize.medium => AppConstants.bodyWeightMedium,
    BodySize.large => AppConstants.bodyWeightLarge,
  };

  /// Raw party-mode target for a given round (1–10) directly from the table.
  /// Returns null for rounds outside [1, 10].
  /// Use this in tests to avoid hardcoding values that must change with the table.
  static double? optimalTargetAt(int round, Sex sex, BodySize size) {
    if (round < 1 || round > 10) return null;
    return _partyModeTargets[sex]![size]![round - 1];
  }

  /// Full target list (R1–R10) for a given profile.
  static List<double> getTargets(Sex sex, BodySize size) =>
      _partyModeTargets[sex]![size]!;

  static double _pct(double currentBrAC, double optimalBrAC) =>
      (currentBrAC - optimalBrAC).abs() / optimalBrAC;

  /// Get zone thresholds (party mode uses consistent thresholds for all rounds).
  static _ZoneThresholds _getThresholds(int roundNumber) {
    return _ZoneThresholds(
      sweetSpot: AppConstants.zoneSweetSpotPct,
      close: AppConstants.zoneClosePct,
      neutral: AppConstants.zoneNeutralPct,
      far: AppConstants.zoneFarPct,
    );
  }

  /// True when currentBrAC is within sweet spot range (+2).
  static bool isInOptimalZone(
    double currentBrAC,
    double optimalBrAC, {
    int roundNumber = 3,
  }) {
    if (optimalBrAC <= 0) return false;
    final thresholds = _getThresholds(roundNumber);
    return _pct(currentBrAC, optimalBrAC) <= thresholds.sweetSpot;
  }

  /// True when currentBrAC is within close range (+1).
  static bool isCloseToOptimal(
    double currentBrAC,
    double optimalBrAC, {
    int roundNumber = 3,
  }) {
    if (optimalBrAC <= 0) return false;
    final thresholds = _getThresholds(roundNumber);
    final pct = _pct(currentBrAC, optimalBrAC);
    return pct > thresholds.sweetSpot && pct <= thresholds.close;
  }

  /// True when currentBrAC is within neutral range (0).
  static bool isNeutralZone(
    double currentBrAC,
    double optimalBrAC, {
    int roundNumber = 3,
  }) {
    if (optimalBrAC <= 0) return false;
    final thresholds = _getThresholds(roundNumber);
    final pct = _pct(currentBrAC, optimalBrAC);
    return pct > thresholds.close && pct <= thresholds.neutral;
  }

  /// True when currentBrAC is within far range (-1).
  static bool isFarFromOptimal(
    double currentBrAC,
    double optimalBrAC, {
    int roundNumber = 3,
  }) {
    if (optimalBrAC <= 0) return false;
    final thresholds = _getThresholds(roundNumber);
    final pct = _pct(currentBrAC, optimalBrAC);
    return pct > thresholds.neutral && pct <= thresholds.far;
  }

  /// True when currentBrAC exceeds fine threshold (-4).
  static bool crossedOptimalLine(
    double currentBrAC,
    double optimalBrAC, {
    int roundNumber = 3,
  }) {
    if (optimalBrAC <= 0) return false;
    final thresholds = _getThresholds(roundNumber);
    return currentBrAC > optimalBrAC * (1 + thresholds.far);
  }
}

/// Internal helper for zone threshold values.
class _ZoneThresholds {
  final double sweetSpot;
  final double close;
  final double neutral;
  final double far;

  _ZoneThresholds({
    required this.sweetSpot,
    required this.close,
    required this.neutral,
    required this.far,
  });
}
