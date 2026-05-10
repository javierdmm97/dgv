/// App-wide constants for game mechanics and rules
class AppConstants {
  AppConstants._();

  // Game Rules
  static const int startingPoints = 15;
  static const int maxPoints = 15;
  static const int minPoints = 0;

  // BAC Thresholds (breathalyzer readings in mg/L - based on DGT data)
  // DGT Reference (3 beers): Men 70kg = 0.8, Men 80kg = 0.7, Women 50kg = 1.5, Women 60kg = 1.2
  // Party context: 10-12 beers over 6-8 hours with metabolism
  // Expected peak readings: Men 2.0-3.0 mg/L, Women 3.5-5.0 mg/L
  static const double optimalToleranceClose =
      0.2; // ±0.2 mg/L for "in the zone"
  static const double optimalToleranceFar =
      0.4; // ±0.4 mg/L for "close to optimal"
  static const double impoundmentThreshold =
      3.5; // >= 3.5 mg/L = impounded (sit out next round)
  static const double dangerousSpikeRate =
      0.8; // >0.8 mg/L per hour = dangerous spike (3 beers/hour)

  // Points Changes
  static const int pointsInOptimalZone = 2; // +2 for being in sweet spot
  static const int pointsCloseToOptimal = 1; // +1 for being close
  static const int pointsCrossedOptimalLine = -3; // -3 for crossing the line
  static const int pointsDangerousSpike = -2; // -2 for spiking too fast
  static const int pointsImpounded = -5; // -5 for impoundment

  // Optimal BAC by Body Size (breathalyzer readings in mg/L - based on DGT data)
  // These are "sweet spot" targets for sustained drinking over 6-8 hours
  // Based on DGT data extrapolated for party context (6-8 beers sustained)
  // Small (50-60kg, mostly women): 6-7 beers ≈ 2.5 mg/L
  // Medium (65-75kg, mixed): 7-8 beers ≈ 2.0 mg/L
  // Large (80-90kg, mostly men): 8-9 beers ≈ 1.8 mg/L
  static const double optimalBACSmall = 2.5;
  static const double optimalBACMedium = 2.0;
  static const double optimalBACLarge = 1.8;

  // Body Weight Estimates (kg)
  static const double bodyWeightSmall = 55.0;
  static const double bodyWeightMedium = 70.0;
  static const double bodyWeightLarge = 90.0;

  // Widmark Formula Constants
  static const double widmarkRMale = 0.68;
  static const double widmarkRFemale = 0.55;

  // Checkpoint Timer (per-group intervals, configurable)
  static const List<int> availableIntervalMinutes = [
    30,
    45,
    60,
  ]; // User-selectable
  static const int defaultIntervalMinutes = 45;
  static const Duration defaultCheckpointInterval = Duration(minutes: 45);

  // Beer consumption constants
  static const double standardBeerML = 330.0;
  static const double standardBeerAlcoholPercent = 5.0;
  static const double gramsAlcoholPerStandardBeer =
      13.0; // 330ml @ 5% = ~13g alcohol

  // Round System
  static const int baselineRound = 0; // Round 0 = baseline (no feedback)
  static const int firstActiveRound = 1; // Round 1+ = active (full feedback)

  // UI Constants
  static const double minTouchTargetSize = 60.0;
  static const double recommendedTouchTargetSize = 80.0;
  static const double minFontSize = 18.0;
  static const double buttonFontSize = 24.0;

  // Storage Keys
  static const String hiveBoxPlayers = 'players';
  static const String hiveBoxGameState = 'game_state';
  static const String hiveBoxCheckpoint = 'checkpoint';
  static const String hiveBoxSettings = 'settings';

  // Shared Preferences Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyDarkMode = 'dark_mode';
  static const String keyLastGameId = 'last_game_id';

  // OCR Confidence
  static const double ocrMinConfidence = 0.90;

  // Animation Durations
  static const Duration sirenDuration = Duration(seconds: 3);
  static const Duration feedbackDuration = Duration(seconds: 5);
  static const Duration titleAwardDuration = Duration(seconds: 3);
  static const Duration confettiDuration = Duration(seconds: 5);

  // Environmental Distinctive Ranks
  static const int environmentalDistinctiveCount = 5; // Top 5 highest BAC
}
