import '../constants/app_constants.dart';
import '../models/player_profile.dart';

/// Predictive BrAC calculator for party mode pacing.
///
/// Targets are calibrated for a 6-hour party window (rounds 1-6) with peak
/// euphoria at round 4 (~0.35-0.48 mg/L), followed by gradual wind-down.
/// Rounds 7+ use linear elimination from round 5 baseline.
class BACCalculator {
  BACCalculator._();

  // Party mode optimal BrAC targets for rounds 1-10 (mg/L)
  // Calibrated for high-energy party state with peak at round 6
  // Based on real consumption patterns: gradual build-up, plateau, wind-down
  static const Map<Sex, Map<BodySize, List<double>>> _partyModeTargets = {
    Sex.male: {
      // M-S (~65kg)
      BodySize.small: [
        0.105, 0.210, 0.315, 0.420, 0.525, 0.630, 0.735, // R1–R7, peak at R7
        0.735, 0.735, 0.735, // R8–R10 plateau
      ],
      // M-M (~78kg)
      BodySize.medium: [
        0.111, 0.223, 0.335, 0.446, 0.558, 0.670, 0.782, // R1–R7, peak at R7
        0.782, 0.782, 0.782, // R8–R10 plateau
      ],
      // M-L (~95kg)
      BodySize.large: [
        0.125, 0.250, 0.375, 0.500, 0.625, 0.750, 0.875, // R1–R7, peak at R7
        0.875, 0.875, 0.875, // R8–R10 plateau
      ],
    },
    Sex.female: {
      // F-S (~55kg)
      BodySize.small: [
        0.086, 0.173, 0.260, 0.346, 0.433, 0.520, 0.607, // R1–R7, peak at R7
        0.607, 0.607, 0.607, // R8–R10 plateau
      ],
      // F-M (~65kg)
      BodySize.medium: [
        0.108, 0.216, 0.325, 0.433, 0.541, 0.650, 0.758, // R1–R7, peak at R7
        0.758, 0.758, 0.758, // R8–R10 plateau
      ],
      // F-L (~80kg)
      BodySize.large: [
        0.118, 0.236, 0.355, 0.473, 0.591, 0.710, 0.828, // R1–R7, peak at R7
        0.828, 0.828, 0.828, // R8–R10 plateau
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
