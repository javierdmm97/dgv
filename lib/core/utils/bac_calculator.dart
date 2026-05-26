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
      // M-S (~65kg): 7.3 tercios total (~2.4L)
      BodySize.small: [
        0.105,
        0.210,
        0.315,
        0.420,
        0.525,
        0.630, // Consumo constante hasta Peak en H6
        0.555, 0.480, 0.405, 0.330, // Wind-down (-0.075 mg/L por hora)
      ],
      // M-M (~78kg): 9.1 tercios total (~3.0L)
      BodySize.medium: [
        0.111, 0.223, 0.335, 0.446, 0.558, 0.670, // Peak en H6
        0.595, 0.520, 0.445, 0.370, // Wind-down
      ],
      // M-L (~95kg): 11.8 tercios total (~3.9L)
      BodySize.large: [
        0.125, 0.250, 0.375, 0.500, 0.625, 0.750, // Peak en H6
        0.675, 0.600, 0.525, 0.450, // Wind-down
      ],
    },
    Sex.female: {
      // F-S (~55kg): 4.5 tercios total (~1.5L)
      BodySize.small: [
        0.086, 0.173, 0.260, 0.346, 0.433, 0.520, // Peak en H6
        0.445, 0.370, 0.295, 0.220, // Wind-down
      ],
      // F-M (~65kg): 6.0 tercios total (~2.0L)
      BodySize.medium: [
        0.108, 0.216, 0.325, 0.433, 0.541, 0.650, // Peak en H6
        0.575, 0.500, 0.425, 0.350, // Wind-down
      ],
      // F-L (~80kg): 7.8 tercios total (~2.6L)
      BodySize.large: [
        0.118, 0.236, 0.355, 0.473, 0.591, 0.710, // Peak en H6
        0.635, 0.560, 0.485, 0.410, // Wind-down
      ],
    },
  };

  /// Optimal BrAC for round N. Round 0 = 0.0 (baseline, no target).
  ///
  /// Rounds 1-10 use hardcoded party mode targets.
  /// Rounds 11+ extrapolate using the last known value (round 10).
  static double calculateOptimalBrAC(
    int roundNumber,
    Sex sex,
    BodySize bodySize,
  ) {
    if (roundNumber <= 0) return 0.0;

    final targets = _partyModeTargets[sex]![bodySize]!;

    // Rounds 1-10: Use hardcoded targets
    if (roundNumber <= targets.length) {
      return targets[roundNumber - 1];
    }

    // Rounds 11+: Use round 10 value (party is winding down)
    return targets[9]; // Index 9 = round 10
  }

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
