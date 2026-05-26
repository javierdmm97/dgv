/// App-wide constants for game mechanics and rules
class AppConstants {
  AppConstants._();

  // Game Rules
  static const int startingPoints = 15;
  static const int maxPoints = 15;
  static const int minPoints = 0;

  // BAC Zone Thresholds — proportional to per-round optimal (mg/L)
  // Party Mode: Optimized for high-energy party state (0.35-0.48 mg/L peak)
  // Zones scale automatically with the Widmark-derived optimal for each sex/bodySize/round.

  // All rounds use consistent party-oriented thresholds
  static const double zoneSweetSpotPct = 0.10; // ±10% of optimal → +2
  static const double zoneClosePct = 0.20; // ±20% of optimal → +1
  static const double zoneNeutralPct = 0.40; // ±40% of optimal → 0
  static const double zoneFarPct = 0.80; // ±80% of optimal → -1
  // Above 80% over optimal triggers fine (-4)

  // Points Changes
  static const int pointsInOptimalZone = 2; // +2 sweet spot
  static const int pointsCloseToOptimal = 1; // +1 close
  static const int pointsNeutralZone = 0; // 0 neutral
  static const int pointsFarZone = -1; // -1 far from optimal
  static const int pointsVeryFarBelow = -2; // -2 way below optimal
  static const int pointsFine = -4; // -4 way above optimal → fine

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
