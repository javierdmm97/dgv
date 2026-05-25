# 🚔 Operación DGV - AI System Instructions

**Version:** 1.2  
**Last Updated:** May 25, 2026  
**Project:** Party Breathalyzer Tracker with DGT Theme

---

## 🎯 Project Mission

**Operación DGV** (Dirección General de Vitis) is a Flutter mobile app that gamifies responsible drinking at parties through a satirical Spanish traffic authority (DGT) theme. Players compete to maintain the most "license points" by pacing their alcohol consumption, not by drinking the most.

---

## 🗺️ App Flow Overview

### Main App Flow
```
App Launch → Check Hive for game state
    ↓
Main Menu (Persistent Home Screen)
├── Add Player → Registration → License Auto-Generated
├── Fake News (joke)
├── Fake Error (joke)
├── Start Game → Round 0 (baseline, no feedback)
└── Resume Game → Continue from saved state
    ↓
Round 1+ (Active Rounds)
├── Checkpoint Timer → BAC Entry → Full Feedback
├── Points Change → License Update → Title Awards
└── Leaderboard (tap player → view license)
    ↓
Finish Game → Final Report → Grand Prizes → Environmental Distinctives
```

### Round System Flow
```
Round 0 (Baseline):
- Measure all players
- NO feedback, NO points, NO titles
- Just "Reading recorded"
- Save as roundNumber: 0

Round 1+ (Active):
- Measure player
- Calculate points change
- Show FULL-SCREEN feedback (color-coded)
- Update license with new badges
- Award per-round titles
- Save everything to Hive
```

### Key User Journeys

**First Time User:**
1. Launch app → Main Menu
2. Add players (name, surname, sex, size, photo)
3. License auto-generated for each
4. Start Game → Round 0 (silent baseline)
5. Round 1+ → Full feedback after each measurement
6. Tap player in leaderboard → View license
7. Finish Game → Final ceremony

**Returning User (Crash Recovery):**
1. Launch app → Main Menu shows "Resume Game"
2. Tap Resume → Load saved state from Hive
3. Continue from exact point (round, timer, all data)

---

## 🏗️ Core Architecture Rules

### Framework & Language
- **Framework:** Flutter (Dart 3.0+)
- **Null Safety:** MANDATORY. All code must be null-safe.
- **Minimum SDK:** Flutter 3.10+

### State Management
- **EXCLUSIVE:** Riverpod 2.0+ with code generation (`@riverpod` annotations)
- **FORBIDDEN:** Provider, GetX, Bloc, or any other state management solution
- **Pattern:** Separate business logic from UI completely
- **File Naming:** `*_provider.dart` for all Riverpod providers

### Local Storage
- **Primary:** Hive 2.0+ for structured data (profiles, BAC logs, achievements)
- **Secondary:** Shared Preferences only for simple key-value pairs (settings, flags)
- **Models:** Use `@HiveType` annotations with TypeAdapters

### Code Generation
- **Required Packages:** 
  - `freezed` + `freezed_annotation` (immutable models)
  - `json_serializable` (JSON parsing)
  - `riverpod_generator` (Riverpod providers)
  - `hive_generator` (Hive adapters)
- **Build Command:** `dart run build_runner build -d`
- **Watch Mode:** `dart run build_runner watch -d` (during active development)

---

## 📁 Folder Structure (Feature-First)

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp configuration
│
├── core/                              # App-wide shared resources
│   ├── theme/
│   │   ├── dgt_colors.dart           # DGT color palette (Blue, Yellow, Red, Green)
│   │   ├── dgt_typography.dart       # Oversized, high-contrast text styles
│   │   └── dgt_theme.dart            # ThemeData configuration
│   │
│   ├── constants/
│   │   ├── app_constants.dart        # BAC limits, point values, timing rules
│   │   ├── asset_paths.dart          # Image/audio asset paths
│   │   └── dgt_strings.dart          # Spanish DGT-themed strings
│   │
│   ├── utils/
│   │   ├── bac_calculator.dart       # Widmark formula (sex + weight → BAC)
│   │   ├── points_calculator.dart    # Delta-based point deduction logic
│   │   └── title_evaluator.dart      # Award DGT titles based on behavior
│   │
│   └── models/
│       ├── player_profile.dart       # Freezed model for player data
│       ├── bac_reading.dart          # Freezed model for breathalyzer logs
│       └── achievement.dart          # Freezed model for earned titles
│
├── widgets/                           # Reusable UI components
│   ├── massive_button.dart           # Oversized touch-friendly button
│   ├── custom_keypad.dart            # Drunk-proof number pad (no native keyboard)
│   ├── license_card.dart             # "Carnet por Puntos" visual card
│   ├── title_badge.dart              # DGT title badge with counter (🟢×3)
│   └── siren_animation.dart          # Police siren flash effect
│
└── features/                          # Isolated feature modules
    │
    ├── main_menu/                     # Persistent home screen
    │   ├── presentation/
    │   │   ├── main_menu_screen.dart  # Main DGT home screen
    │   │   └── widgets/
    │   │       ├── fake_error_notification.dart  # Top notification with X to close
    │   │       └── fake_news_section.dart        # "Actualidad DGT" section
    │   └── providers/
    │       └── game_state_provider.dart   # Track if game in progress
    │
    ├── onboarding/                    # App introduction & rules (optional)
    │   ├── presentation/
    │   │   ├── onboarding_screen.dart
    │   │   └── widgets/
    │   └── providers/
    │       └── onboarding_provider.dart
    │
    ├── player_registration/           # Player creation & setup
    │   ├── data/
    │   │   ├── player_repository.dart
    │   │   └── hive_player_datasource.dart
    │   ├── domain/
    │   │   └── models/
    │   │       └── player.dart        # Freezed + Hive model
    │   ├── presentation/
    │   │   ├── registration_screen.dart
    │   │   ├── photo_capture_screen.dart  # Camera for fake ID
    │   │   └── widgets/
    │   └── providers/
    │       ├── player_list_provider.dart
    │       └── registration_form_provider.dart
    │
    ├── breathalyzer/                  # BAC data entry & OCR
    │   ├── data/
    │   │   ├── bac_repository.dart
    │   │   └── ocr_service.dart       # ML Kit text recognition
    │   ├── presentation/
    │   │   ├── manual_entry_screen.dart
    │   │   ├── camera_ocr_screen.dart
    │   │   ├── round_robin_screen.dart  # "El Retén" lineup
    │   │   └── widgets/
    │   └── providers/
    │       ├── bac_entry_provider.dart
    │       └── ocr_provider.dart
    │
    ├── checkpoint/                    # Round management & timers
    │   ├── presentation/
    │   │   ├── checkpoint_screen.dart
    │   │   ├── shot_clock_widget.dart
    │   │   └── siren_alert_screen.dart
    │   └── providers/
    │       ├── checkpoint_timer_provider.dart
    │       └── round_manager_provider.dart
    │
    ├── scoring/                       # Points calculation & penalties
    │   ├── domain/
    │   │   ├── points_engine.dart     # Core scoring logic
    │   │   └── penalty_rules.dart     # Threshold violations
    │   └── providers/
    │       └── scoring_provider.dart
    │
    ├── leaderboard/                   # "Carnet por Puntos" display
    │   ├── presentation/
    │   │   ├── leaderboard_screen.dart
    │   │   ├── player_detail_screen.dart
    │   │   └── widgets/
    │   │       ├── points_card.dart
    │   │       └── bac_graph.dart
    │   └── providers/
    │       └── leaderboard_provider.dart
    │
    ├── achievements/                  # DGT titles & awards
    │   ├── domain/
    │   │   └── title_definitions.dart
    │   ├── presentation/
    │   │   ├── achievements_screen.dart
    │   │   └── title_award_animation.dart
    │   └── providers/
    │       └── achievements_provider.dart
    │
    └── fake_id/                       # DGT License generation
        ├── presentation/
        │   ├── id_generator_screen.dart
        │   ├── final_ceremony_screen.dart  # "Mario Party" style reveal
        │   └── widgets/
        │       ├── fake_license_card.dart
        │       └── envelope_animation.dart
        └── providers/
            └── id_generator_provider.dart
```

---

## 🎨 UI/UX Guidelines (Drunk-Proof Design)

### Critical UX Principles
1. **Oversized Touch Targets:** Minimum `minHeight: 60`, recommended `minHeight: 80`
2. **No Native Keyboards:** Always use custom UI keypads for numerical input
3. **High Contrast:** Assume impaired vision. Use DGT colors with strong contrast
4. **Minimal Navigation:** Reduce cognitive load. Use full-screen flows, not complex menus
5. **Instant Feedback:** Audio + visual confirmation for every action

### DGT Color Palette
```dart
// core/theme/dgt_colors.dart
class DGTColors {
  static const primary = Color(0xFF0F5993);      // DGT Blue
  static const background = Color(0xFFF6F4F5);   // Light Gray
  static const licenseId = Color(0xFFF3E8EC);    // Light Pink (for ID card)
  static const green = Color(0xFFD2D667);        // Lime Green
  static const yellow = Color(0xFFF4E944);       // Bright Yellow
  static const orange = Color(0xFFF3910E);       // Traffic Orange
  static const red = Color(0xFFEF6B6A);          // Violation Red
  static const surface = Color(0xFFFFFFFF);      // White for cards
  static const textPrimary = Color(0xFF000000);  // Black text
  static const textSecondary = Color(0xFF666666); // Gray text
}
```

### Typography Rules
- **Minimum Font Size:** 18sp for body text
- **Button Text:** 24sp minimum, bold weight
- **Headers:** 32sp+, extra bold
- **Use:** Google Fonts `Roboto` or `Montserrat` for clarity

### Custom Keypad Requirements
```dart
// widgets/custom_keypad.dart
// - Grid layout: 3 columns × 4 rows
// - Buttons: 80×80 minimum
// - Hardcoded decimal point (e.g., "4" + "5" → "0.45")
// - Haptic feedback on tap
// - Large backspace button
```

---

## 🧮 Game Mechanics & Calculations

### Player Profile Data Model
```dart
@freezed
@HiveType(typeId: 0)
class PlayerProfile with _$PlayerProfile {
  factory PlayerProfile({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required String surname,       // Added surname field
    @HiveField(3) required String photoPath,     // Camera photo for fake ID
    @HiveField(4) required Sex sex,              // Male, Female
    @HiveField(5) required BodySize bodySize,    // S, M, L
    @HiveField(6) @Default(15) int points,       // Starting points
    @HiveField(7) @Default([]) List<BACReading> readings,
    @HiveField(8) @Default({}) Map<DGTTitle, int> titleCounts, // Track title accumulation
    @HiveField(9) @Default(false) bool crossedOptimalLine, // Penalización acumulada por exceso
    @HiveField(10) @Default(0) int fineCount,      // Number of fines received (-4 pts each)
    @HiveField(11) @Default(0) int moneyLost,      // Money lost (next-day game, 100 per fine)
    @HiveField(12) required String licenseImagePath, // Auto-generated license (updated throughout game)
    // NOTE: optimalBAC is NO LONGER stored on the player — it is computed per-round via
    // BACCalculator.calculateOptimalBrAC(roundNumber, sex, bodySize) using DGT BrAC tables.
  }) = _PlayerProfile;
}

enum Sex { male, female }
enum BodySize { small, medium, large }

// PHASE 2.5 NOTE: vehiculoHibrido replacement title is TBD (dropped reading logic removed as BAC drops
// are physically impossible within a 5-hour party window).
// itvPassed now means: lost points last round AND back in the zone this round ("Redemption").
enum DGTTitle {
  velocidadDeCrucero,  // 🟢 Closest to their optimal zone this round
  multaPorExceso,      // 🔴 Highest BAC spike from last round
  lDePracticas,        // 🔰 Lowest BAC reading in the round
  vehiculoHibrido,     // 🔋 [TBD — replacement title, pending definition]
  itvPassed,           // 🔧 Lost points last round but now back in zone ("Redemption")
}
```

### BrAC Calculation (DGT Official Tables)

**Critical architecture note (Phase 2.5):**
The app measures **BrAC** (Breath Alcohol Concentration, mg/L exhaled air) directly from the breathalyzer — NOT blood alcohol. The "sweet spot" is **NOT a fixed value**. It grows each round because players consume more drinks as the night progresses. Round N ≈ N drinks consumed.

The optimal BrAC target at round N is derived from **official DGT BrAC tables** (midpoint of the published range), indexed by sex and body size. The Widmark formula is no longer used.

**Body size weight groups (from DGT):**
- Men: Small = 60–70 kg, Medium = 70–90 kg, Large = 90–110 kg
- Women: Small = 40–50 kg, Medium = 50–70 kg, Large = 70–90 kg

```dart
// core/utils/bac_calculator.dart  (class kept as BACCalculator for backwards compat)
class BACCalculator {
  // DGT official BrAC table — midpoints (mg/L) per drink count, per sex/body-size.
  // Row index = drinks consumed (index 0 = 1 drink, index 9 = 10 drinks).
  // Source: DGT official breathalyser equivalence tables.
  //
  // MEN: Small(60-70 kg), Medium(70-90 kg), Large(90-110 kg)
  static const Map<BodySize, List<double>> _menBrACTable = {
    BodySize.small:  [0.15, 0.30, 0.46, 0.61, 0.76, 0.90, 1.05, 1.21, 1.36, 1.51],
    BodySize.medium: [0.13, 0.25, 0.38, 0.50, 0.62, 0.74, 0.87, 0.99, 1.11, 1.24],
    BodySize.large:  [0.10, 0.20, 0.30, 0.40, 0.49, 0.59, 0.69, 0.79, 0.89, 0.98],
  };

  // WOMEN: Small(40-50 kg), Medium(50-70 kg), Large(70-90 kg)
  static const Map<BodySize, List<double>> _womenBrACTable = {
    BodySize.small:  [0.27, 0.54, 0.81, 1.08, 1.35, 1.62, 1.89, 2.16, 2.43, 2.70],
    BodySize.medium: [0.21, 0.42, 0.62, 0.83, 1.03, 1.24, 1.44, 1.65, 1.86, 2.06],
    BodySize.large:  [0.16, 0.31, 0.46, 0.62, 0.77, 0.92, 1.07, 1.22, 1.38, 1.53],
  };

  /// Optimal BrAC for round N — assumes 1 drink consumed per round.
  /// Round 0 (baseline) always returns 0.0.
  /// Rounds > 10 are capped at round 10 (table maximum).
  static double calculateOptimalBrAC(int roundNumber, Sex sex, BodySize bodySize) {
    if (roundNumber <= 0) return 0.0;
    final drinks = roundNumber.clamp(1, 10);
    final table = sex == Sex.male ? _menBrACTable : _womenBrACTable;
    return table[bodySize]![drinks - 1];
  }

  /// Check if BrAC is in the "sweet spot" (within ±0.2 mg/L of the round's optimal)
  static bool isInOptimalZone(double currentBrAC, double optimalBrAC) {
    return (currentBrAC - optimalBrAC).abs() <= 0.2;
  }

  /// Check if BrAC is close to optimal (±0.2–0.4 mg/L)
  static bool isCloseToOptimal(double currentBrAC, double optimalBrAC) {
    final diff = (currentBrAC - optimalBrAC).abs();
    return diff > 0.2 && diff <= 0.4;
  }

  /// Check if player has gone over the optimal line (>+0.4 mg/L above optimal)
  static bool crossedOptimalLine(double currentBrAC, double optimalBrAC) {
    return currentBrAC > (optimalBrAC + 0.4);
  }
}
```

**Example progression (men, medium body):**
| Round | Expected BrAC | "In Zone" band |
|-------|--------------|----------------|
| 0 | 0.00 (baseline) | — |
| 1 | 0.13 mg/L | 0.00–0.33 |
| 3 | 0.38 mg/L | 0.18–0.58 |
| 5 | 0.62 mg/L | 0.42–0.82 |
| 8 | 0.99 mg/L | 0.79–1.19 |
| 10 | 1.24 mg/L | 1.04–1.44 |

### Points System (Simplified — Phase 2.5)

**Scale:** -4 | -2 | 0 | +2 | +4 per round. Max points cap: 15.

| Zone | Condition | Points |
|------|-----------|--------|
| 🟢 Sweet Spot | ±0.2 mg/L from optimal | **+4** |
| 🟡 Close | ±0.4 mg/L from optimal | **+2** |
| ⬛ Neutral | — (neither condition applies) | **0** |
| 🔵 Too Low | >0.4 mg/L below optimal ("Policía de la Diversión") | **-2** |
| 🔴 Over the Line | >0.4 mg/L above optimal | **-4** → also triggers **Fine** |

**Fine Rule:** A -4 measurement issues one Fine:
- Deduct an additional `-4` points (already included in the -4 delta above — do not double-apply)
- Track `fineCount++` and `moneyLost += 100` on `PlayerProfile`
- Show `assets/fine.png` full-screen
- No impoundment, no sitting out — game continues normally

**"Policía de la Diversión":** Being well below the sweet spot (>0.4 mg/L under optimal) costs -2 points. Encourages players to pace up, not just coast low.

```dart
// core/utils/points_calculator.dart
class PointsCalculator {
  /// Simplified point system: -4 | -2 | 0 | +2 | +4
  /// All thresholds in mg/L (breathalyzer readings)
  static int calculatePointsChange({
    required double currentBAC,
    required double optimalBAC,
  }) {
    // +4: Sweet spot (±0.2 mg/L)
    if (BACCalculator.isInOptimalZone(currentBAC, optimalBAC)) {
      return 4;
    }
    
    // +2: Close to optimal (±0.4 mg/L)
    if (BACCalculator.isCloseToOptimal(currentBAC, optimalBAC)) {
      return 2;
    }
    
    // -4: Over the line (>+0.4 mg/L above optimal) → also triggers Fine
    if (BACCalculator.crossedOptimalLine(currentBAC, optimalBAC)) {
      return -4;
    }
    
    // -2: "Policía de la Diversión" — too far below optimal
    if (currentBAC < (optimalBAC - 0.4)) {
      return -2;
    }
    
    return 0; // Neutral
  }
  
  /// A fine is triggered when a measurement results in -4 points
  static bool shouldIssueFine(int pointsChange) => pointsChange <= -4;
  
  /// Average distance from the per-round optimal across all rounds (excludes round 0).
  /// Each reading is compared against the optimal BrAC for THAT round (from DGT table).
  static double calculateAverageDistanceFromOptimal(
    List<BACReading> readings,
    Sex sex,
    BodySize bodySize,
  ) {
    final activeReadings = readings.where((r) => r.roundNumber > 0).toList();
    if (activeReadings.isEmpty) return double.infinity;
    final distances = activeReadings.map((r) {
      final optimal = BACCalculator.calculateOptimalBrAC(r.roundNumber, sex, bodySize);
      return (r.bac - optimal).abs();
    });
    return distances.reduce((a, b) => a + b) / activeReadings.length;
  }

  /// Perfection score for tiebreaking: lower = better. Combines average distance
  /// from the per-round optimal with its variance (penalises inconsistency).
  static double calculatePerfectionScore(
    List<BACReading> readings,
    Sex sex,
    BodySize bodySize,
  ) {
    if (readings.isEmpty) return double.infinity;
    final avg = calculateAverageDistanceFromOptimal(readings, sex, bodySize);
    final activeReadings = readings.where((r) => r.roundNumber > 0).toList();
    if (activeReadings.isEmpty) return double.infinity;
    final variance = activeReadings.map((r) {
      final optimal = BACCalculator.calculateOptimalBrAC(r.roundNumber, sex, bodySize);
      final diff = (r.bac - optimal).abs() - avg;
      return diff * diff;
    }).reduce((a, b) => a + b) / activeReadings.length;
    return avg + variance;
  }
}
```

### DGT Title Evaluation (Per-Round Awards)

**Phase 2.5 Note:** DGT Titles are now **visual/cosmetic only** — they accumulate on the license throughout the game and are shown at the end, but they do not determine winners. The Leaderboard (points) is the sole source of truth for ranking.

```dart
// core/utils/title_evaluator.dart
// Titles are VISUAL ONLY — cosmetic accumulation on license cards.
enum DGTTitle {
  velocidadDeCrucero,  // 🟢 Closest to their optimal zone this round
  multaPorExceso,      // 🔴 Highest BAC spike from last round
  lDePracticas,        // 🔰 Lowest BAC reading in the round
  vehiculoHibrido,     // 🔋 [TBD — pending replacement definition]
  itvPassed,           // 🔧 Lost points last round but now back in zone ("Redemption")
}

class TitleEvaluator {
  /// Evaluate and award titles for the current round
  /// Returns a map of player IDs to awarded titles
  static Map<String, DGTTitle> evaluateRound(
    List<PlayerProfile> players,
    int currentRound,
  ) {
    final awards = <String, DGTTitle>{};
    
    // 🟢 Velocidad de Crucero: Closest to their optimal zone
    final closestPlayer = _findClosestToOptimal(players);
    if (closestPlayer != null) {
      awards[closestPlayer.id] = DGTTitle.velocidadDeCrucero;
    }
    
    // 🔴 Multa por Exceso: Highest BAC spike from last round
    final highestSpikePlayer = _findHighestSpike(players);
    if (highestSpikePlayer != null) {
      awards[highestSpikePlayer.id] = DGTTitle.multaPorExceso;
    }
    
    // 🔰 L de Prácticas: Lowest BAC in the round
    final lowestBACPlayer = _findLowestBAC(players);
    if (lowestBACPlayer != null) {
      awards[lowestBACPlayer.id] = DGTTitle.lDePracticas;
    }
    
    // 🔋 Vehículo Híbrido: BAC dropped (drank water)
    final hybridPlayers = _findHybridVehicles(players);
    for (final player in hybridPlayers) {
      awards[player.id] = DGTTitle.vehiculoHibrido;
    }
    
    // 🛠️ ITV Passed: Same reading twice in a row (±0.01)
    final itvPlayers = _findITVPassed(players);
    for (final player in itvPlayers) {
      awards[player.id] = DGTTitle.itvPassed;
    }
    
    return awards;
  }
  
  static PlayerProfile? _findClosestToOptimal(List<PlayerProfile> players) {
    // Implementation: Find player with smallest distance from optimal
  }
  
  static PlayerProfile? _findHighestSpike(List<PlayerProfile> players) {
    // Implementation: Find player with highest BAC delta from previous reading
  }
  
  static PlayerProfile? _findLowestBAC(List<PlayerProfile> players) {
    // Implementation: Find player with lowest current BAC
  }
  
  static List<PlayerProfile> _findHybridVehicles(List<PlayerProfile> players) {
    // Implementation: Find players whose BAC dropped
  }
  
  static List<PlayerProfile> _findITVPassed(List<PlayerProfile> players) {
    // Implementation: Find players with same reading twice (±0.01)
  }
  
  /// Calculate leaderboard with tiebreaker for top 3.
  /// Primary sort: points (descending).
  /// Tiebreaker: perfection score (ascending = closer to per-round optimal line).
  static List<PlayerProfile> calculateLeaderboard(List<PlayerProfile> players) {
    final sorted = [...players];
    sorted.sort((a, b) {
      if (a.points != b.points) return b.points.compareTo(a.points);
      // Tiebreaker: lower perfection score = stayed closer to optimal line each round
      final aScore = PointsCalculator.calculatePerfectionScore(a.readings, a.sex, a.bodySize);
      final bScore = PointsCalculator.calculatePerfectionScore(b.readings, b.sex, b.bodySize);
      return aScore.compareTo(bScore);
    });
    return sorted;
  }
  
  /// Get the player who collected the most DGT titles (shown at end as a joke).
  static PlayerProfile? getMostTitlesPlayer(List<PlayerProfile> players) {
    if (players.isEmpty) return null;
    return players.reduce((a, b) {
      final aTotal = a.titleCounts.values.fold(0, (sum, count) => sum + count);
      final bTotal = b.titleCounts.values.fold(0, (sum, count) => sum + count);
      return aTotal >= bTotal ? a : b;
    });
  }
  
  /// Get top 5 highest BAC players for Environmental Distinctive badges
  static List<PlayerProfile> getEnvironmentalDistinctives(
    List<PlayerProfile> players,
  ) {
    final sorted = [...players]..sort((a, b) {
      final aMax = a.readings.isEmpty ? 0.0 : a.readings.map((r) => r.bac).reduce(max);
      final bMax = b.readings.isEmpty ? 0.0 : b.readings.map((r) => r.bac).reduce(max);
      return bMax.compareTo(aMax); // Descending
    });
    return sorted.take(5).toList();
  }
}
```

---

## 🎮 Feature Specifications

### 1. Main Menu (Persistent Home Screen)
**Purpose:** Central hub that persists throughout the app lifecycle

**Layout (mimicking DGT app):**
```
┌─────────────────────────────────────┐
│  ☰  [DGT Logo]              🔔      │ ← Header
├─────────────────────────────────────┤
│  ⚠️ [Fake Error Notification]  ✕   │ ← Top notification (dismissible)
├─────────────────────────────────────┤
│                                     │
│  [Start Game] / [Resume Game]       │ ← Replaces "Hola, Antonio" section
│  (Large button, conditional)        │
│                                     │
├─────────────────────────────────────┤
│  MIS VEHÍCULOS 🚗                   │ ← Keep to mimic DGT app
│  ┌─────────────────────────────┐   │
│  │  [Add Player]               │   │ ← Player registration
│  │  (Shows list if players      │   │
│  │   already added)             │   │
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│  ACTUALIDAD DGT                     │ ← Fake News section
│  ┌─────────────────────────────┐   │
│  │  📰 Satirical DGT articles  │   │
│  │  (Scrollable list)           │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

**Components:**
- **Fake Error Notification (Top):**
  - Dismissible notification bar at top
  - Shows fake error message (assets/msg_error.png or text)
  - X button to close
  - Reappears randomly or on certain events
  
- **Start/Resume Game Section:**
  - Replaces "Hola, Antonio" + photo section
  - Shows "Start Game" button if no game in progress
  - Shows "Resume Game" button if game in progress
  - Large, prominent button

- **Mis Vehículos Section:**
  - Keep to mimic DGT app better
  - "Add Player" button
  - Shows list of added players (if any)
  - Tap player → view their license

- **Actualidad DGT Section:**
  - Fake news articles (satirical)
  - Scrollable list
  - Tap article → show full fake article

- **Ayuda (Help) Button:**
  - Accessible from the navigation drawer (end drawer) or a visible button in the main menu
  - Shows a full-screen or dialog joke screen with:
    - Title: **"¿Necesitas Ayuda?"**
    - Main message: **"Espabila y tómate una bien fría."**
    - Sub-message (DGT joke slogan): **"Si bebes, conduce."** *(reversed intentionally — satirical)*
    - Image: TBD — placeholder for a satirical DGT-themed illustration
  - "Cerrar" button to dismiss
  - Drunk-proof: oversized text, MassiveButton to close

**State Management:**
- Check Hive for existing game state on app launch
- Show appropriate buttons based on game state
- Allow recovery from app crash or memory issues

**Riverpod Provider:**
```dart
@riverpod
class GameState extends _$GameState {
  @override
  Future<GameStateModel> build() async {
    final repo = ref.watch(gameRepositoryProvider);
    return repo.loadGameState();
  }
  
  bool get isGameInProgress => state.value?.currentRound != null;
  bool get canStartNewGame => !isGameInProgress;
}
```

### 2. Player Registration Flow
**Screens:**
1. Name input (custom keyboard)
2. Surname input (custom keyboard)
3. Sex selection (Male/Female buttons)
4. Body size selection (S/M/L visual buttons with weight ranges per sex):
   - Men: Small = 60–70 kg, Medium = 70–90 kg, Large = 90–110 kg
   - Women: Small = 40–50 kg, Medium = 50–70 kg, Large = 70–90 kg
5. Photo capture (camera with countdown timer for license ID)
6. Confirmation screen (shows BrAC target progression: round 1 → round 5 → round 10)

**License Generation:**
- **Immediately after photo capture:** Generate fake license ID
- Use template image with placeholders for:
  - Photo (circular or rectangular crop)
  - Name + Surname
  - Sex and body size
  - ID number (UUID)
  - Points (starts at 15)
  - Empty badge slots (filled throughout game)
- Save license image to app documents directory
- Store path in `PlayerProfile.licenseImagePath`

**Data Storage:**
- Save to Hive immediately after confirmation
- Generate unique UUID for player ID
- Store photo in app documents directory
- Calculate and store optimal BAC based on body size
- Generate and store initial license image

### 3. Round 0 (Baseline Measurement)
**Purpose:** Establish baseline BAC for all players at start of game

**Flow:**
1. After clicking "Start Game" from main menu
2. Navigate to round-robin screen
3. Measure each player's initial BAC
4. **NO feedback messages** (silent baseline)
5. **NO title awards**
6. **NO points changes**
7. Only show: "Reading recorded for [Player Name]"
8. After all players measured → Round 1 begins

**Data Storage:**
- Save as first `BACReading` for each player
- Mark as `roundNumber: 0`
- Use as baseline for delta calculations in future rounds

### 4. Breathalyzer Data Entry (Round 1+)
**Three Input Methods:**

#### A. Manual Entry (Custom Keypad)
- Full-screen keypad
- Display format: `0.XX` (always 2 decimals)
- Confirm button triggers save

#### B. Camera OCR ("El Radar")
- Use `google_ml_kit_text_recognition`
- Detect numbers in format `X.XX` or `0.XX`
- Auto-confirm if confidence > 90%
- Fallback to manual entry if OCR fails

#### C. Round-Robin ("El Retén")
- Full-screen player carousel (show photo + name)
- **No auto-advance** — player manually moves to next after confirming each entry
- Tap player → open data entry for that player
- Progress indicator (e.g., "3/8 players logged")

**Post-Measurement Feedback (Round 1+ only):**
After each BAC entry, show full-screen feedback:
- Points gained/lost (e.g., "+2 points: In the zone!")
- DGT titles won (e.g., "🟢 Velocidad de Crucero")
- Warnings (e.g., "⚠️ Approaching optimal line")
- Penalties (e.g., "-3 points: Over the line!")
- Impoundment alert (if BAC ≥ 1.2)

**License Update:**
- After feedback, automatically update player's license image
- Add new title badges to license
- Update points display
- Save updated license to storage

### 5. Checkpoint System ("Control Sorpresa") - Group-Based Measurement

**Group-Based Timer Logic:**

The checkpoint system divides players into groups to manage measurement sequentially rather than all at once. This prevents bottlenecks when many players need to be measured simultaneously.

#### Group Calculation

```dart
// core/utils/checkpoint_calculator.dart
class CheckpointCalculator {
  /// Calculate group size based on number of players
  /// Ensures manageable measurement flow
  static int calculateGroupSize(int playerCount) {
    // Recommended group sizes:
    // 1-4 players: 1 group (measure all at once)
    // 5-8 players: 2 groups (measure 2-4 at a time)
    // 9-16 players: 3 groups (measure 3-5 at a time)
    // 17-24 players: 4 groups (measure 4-6 at a time)
    // 25+ players: 5-6 groups (measure 5-6 at a time)
    
    if (playerCount <= 4) return playerCount; // All in one group
    if (playerCount <= 8) return (playerCount / 2).ceil();
    if (playerCount <= 16) return (playerCount / 3).ceil();
    if (playerCount <= 24) return (playerCount / 4).ceil();
    return (playerCount / 5).ceil();
  }
  
  /// Divide players into groups for sequential measurement
  static List<List<PlayerProfile>> divideIntoGroups(
    List<PlayerProfile> players,
  ) {
    final groupSize = calculateGroupSize(players.length);
    final groups = <List<PlayerProfile>>[];
    
    for (int i = 0; i < players.length; i += groupSize) {
      final end = (i + groupSize < players.length) 
        ? i + groupSize 
        : players.length;
      groups.add(players.sublist(i, end));
    }
    
    return groups;
  }
  
  /// Calculate time per group (in seconds)
  /// Assumes ~30 seconds per player for measurement + entry
  static int calculateTimePerGroup(int groupSize) {
    const secondsPerPlayer = 30;
    return groupSize * secondsPerPlayer;
  }
  
  /// Calculate total checkpoint interval based on player count
  /// Formula: (number_of_groups × time_per_group) + buffer
  static Duration calculateCheckpointInterval(int playerCount) {
    final groups = divideIntoGroups(
      List.generate(playerCount, (i) => i), // Dummy list for calculation
    );
    final groupSize = calculateGroupSize(playerCount);
    final timePerGroup = calculateTimePerGroup(groupSize);
    final totalSeconds = (groups.length * timePerGroup) + 300; // 5 min buffer
    
    return Duration(seconds: totalSeconds);
  }
}
```

#### Checkpoint State Model

```dart
@freezed
@HiveType(typeId: 11)
class CheckpointState with _$CheckpointState {
  factory CheckpointState({
    @HiveField(0) required int currentRound,
    @HiveField(1) required Duration totalInterval,      // Total time for all groups
    @HiveField(2) required Duration remainingTime,      // Time until next checkpoint
    @HiveField(3) required int currentGroupIndex,       // Which group is being measured (0-based)
    @HiveField(4) required List<List<String>> playerGroups, // Player IDs grouped
    @HiveField(5) @Default(false) bool isCheckpointActive,
    @HiveField(6) required DateTime lastCheckpointTime,
  }) = _CheckpointState;
}
```

#### Timer Logic

**Timer Behavior:**
1. **Checkpoint Triggered:** Divide all players into groups
2. **Group 1 Measurement:** Show round-robin for Group 1 only
3. **Group 1 Complete:** Move to Group 2, reset group timer
4. **All Groups Complete:** Evaluate titles, award points, reset main timer
5. **Main Timer Restarts:** Wait for next checkpoint interval

**Example Timeline (20 players):**
```
Total Players: 20
Group Size: 5 players per group
Number of Groups: 4
Time per Group: 5 × 30s = 150s (2.5 min)
Total Checkpoint Time: (4 × 150s) + 300s buffer = 900s (15 min)
Main Interval: 45 min (default)

Timeline:
00:00 - Checkpoint triggered, Group 1 starts
02:30 - Group 1 complete, Group 2 starts
05:00 - Group 2 complete, Group 3 starts
07:30 - Group 3 complete, Group 4 starts
10:00 - Group 4 complete, all measurements done
10:00 - Evaluate titles, award points
10:00 - Main timer resets to 45 min
45:00 - Next checkpoint triggered
```

**Riverpod Provider:**
```dart
@riverpod
class CheckpointTimer extends _$CheckpointTimer {
  Timer? _mainTimer;      // Main interval timer (45 min)
  Timer? _groupTimer;     // Current group measurement timer
  
  @override
  Future<CheckpointState> build() async {
    // Load saved checkpoint state from Hive
    final repo = ref.watch(gameRepositoryProvider);
    return repo.loadCheckpointState();
  }
  
  /// Start the main checkpoint interval timer
  void startMainTimer() {
    final players = ref.read(playerListProvider).value ?? [];
    final interval = CheckpointCalculator.calculateCheckpointInterval(
      players.length,
    );
    
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.value!.remainingTime.inSeconds <= 0) {
        _triggerCheckpoint();
      } else {
        final newState = state.value!.copyWith(
          remainingTime: state.value!.remainingTime - const Duration(seconds: 1),
        );
        state = AsyncValue.data(newState);
        _saveToHive(newState);
      }
    });
  }
  
  /// Trigger checkpoint: divide players into groups and start group measurement
  void _triggerCheckpoint() {
    _mainTimer?.cancel();
    
    final players = ref.read(playerListProvider).value ?? [];
    final groups = CheckpointCalculator.divideIntoGroups(players);
    final playerGroups = groups
        .map((group) => group.map((p) => p.id).toList())
        .toList();
    
    final newState = state.value!.copyWith(
      isCheckpointActive: true,
      currentGroupIndex: 0,
      playerGroups: playerGroups,
    );
    state = AsyncValue.data(newState);
    _saveToHive(newState);
    
    // Play siren and show alert
    _playSirenAlert();
    
    // Start measuring first group
    _startGroupMeasurement(0);
  }
  
  /// Start measurement timer for a specific group
  void _startGroupMeasurement(int groupIndex) {
    final groupSize = state.value!.playerGroups[groupIndex].length;
    final timePerGroup = CheckpointCalculator.calculateTimePerGroup(groupSize);
    
    _groupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Group measurement logic
      // When group complete, move to next group or finish checkpoint
    });
  }
  
  /// Complete current group and move to next
  void completeGroupMeasurement() {
    _groupTimer?.cancel();
    
    final currentState = state.value!;
    final nextGroupIndex = currentState.currentGroupIndex + 1;
    
    if (nextGroupIndex < currentState.playerGroups.length) {
      // More groups to measure
      final newState = currentState.copyWith(
        currentGroupIndex: nextGroupIndex,
      );
      state = AsyncValue.data(newState);
      _saveToHive(newState);
      _startGroupMeasurement(nextGroupIndex);
    } else {
      // All groups complete
      _completeCheckpoint();
    }
  }
  
  /// Complete checkpoint: evaluate titles, award points, reset main timer
  void _completeCheckpoint() {
    // Evaluate titles for all players
    final players = ref.read(playerListProvider).value ?? [];
    final titles = TitleEvaluator.evaluateRound(players, state.value!.currentRound);
    
    // Award titles and update licenses
    // ... (title award logic)
    
    // Reset checkpoint state
    final newState = state.value!.copyWith(
      isCheckpointActive: false,
      currentGroupIndex: 0,
      playerGroups: [],
      currentRound: state.value!.currentRound + 1,
      remainingTime: CheckpointCalculator.calculateCheckpointInterval(
        players.length,
      ),
    );
    state = AsyncValue.data(newState);
    _saveToHive(newState);
    
    // Restart main timer
    startMainTimer();
  }
  
  void _playSirenAlert() {
    // Play police siren (3 seconds)
    // Flash screen red/blue
  }
  
  void _saveToHive(CheckpointState state) {
    // Save to Hive for persistence
  }
  
  @override
  void dispose() {
    _mainTimer?.cancel();
    _groupTimer?.cancel();
    super.dispose();
  }
}
```

#### UI Considerations

**During Group Measurement:**
- Show which group is being measured: "Group 1 of 4"
- Show progress: "3/5 players measured"
- Show time remaining for current group
- Lock UI until group complete
- Allow skipping to next group (admin only)

**After All Groups Complete:**
- Show summary: "All 20 players measured"
- Display title awards
- Update leaderboard
- Show next checkpoint countdown

### 6. Penalty & Fine System (Phase 2.5)
**Automatic Points Changes (Round 1+ only):**
- After each BAC entry, calculate position relative to optimal zone
- Apply points change using `PointsCalculator.calculatePointsChange()`
- Enforce max cap: points cannot exceed 15
- Update player's points in Hive
- Show full-screen feedback notification:
  - "+4 points: ¡En la zona!" (green background)
  - "+2 points: Cerca del óptimo" (yellow background)
  - "0 points: Sin cambios" (neutral)
  - "-2 points: Policía de la Diversión 🚔" (blue background — too low)
  - "-4 points: ¡Te has pasado!" (red background → triggers Fine)
- Mark `crossedOptimalLine = true` when player exceeds optimal + 0.4 mg/L

**Fine System ("La Multa") — replaces Impoundment:**
- Triggered when a measurement gives -4 points
- Show `assets/fine.png` full-screen (DGT fine image)
- Track on PlayerProfile: `fineCount++`, `moneyLost += 100`
- Money lost is informational only (used in a separate next-day game)
- Player continues normally — no sitting out
- No impoundment, no "IMPOUNDED" badge

**"Policía de la Diversión" Rule:**
- If BAC is >0.4 mg/L below optimal, player loses 2 points
- Encourages pacing — being too low is penalized
- Message: "La Policía de la Diversión te ha pillado bebiendo poco 🚔"

**Debug Skip Button:**
- A debug button must be available (hidden or in dev menu) to trigger the next checkpoint measurement immediately without waiting the full timer interval
- Useful for testing the full game loop without waiting 30–60 minutes

**Per-Round Title Awards (Visual Only):**
- After all players log BAC for a checkpoint, evaluate titles
- Award up to 5 titles per round (Velocidad de Crucero, Multa por Exceso, etc.)
- Titles are cosmetic — they accumulate on licenses throughout the game
- Increment title counters in player profiles
- Show title award animation with logo
- Update license image with new title badge
- Display title badges on leaderboard

### 7. Leaderboard Display
**Sort Order:** Descending by points. Tiebreaker = perfection score (lower = better, calculated via `PointsCalculator.calculatePerfectionScore()`).

**Winners:** Only the **top 3** are considered winners. Show medals: 🥇 🥈 🥉.

**Card Layout:**
```
┌─────────────────────────────────┐
│ 🥇 1st Place                    │
│ [Photo] Juan García             │
│ 12 puntos | BAC: 1.8 mg/L       │
│ Óptimo: 2.0 mg/L (±0.2)        │
│ 🟢×3 🔴×1 🔰×0 🔋×2 🔧×1       │
│ Multas: 0 | Precisión: 0.14     │
│ [Tap to view license]           │
└─────────────────────────────────┘
```

**Tap Interaction:**
- Tap player card → Navigate to full license view
- Show current license image with all badges
- Display BAC progression graph
- Show detailed stats

**Leaderboard Reactivity Bug (Fixed in Phase 2.5):**
- Leaderboard must update immediately when any player's data changes
- Use `ref.watch` on the player list provider, not one-time reads
- Do NOT require app restart or screen navigation to see updates

**Graph:** Line chart showing:
- BAC progression over time (use `fl_chart` package)
- Optimal zone highlighted (green band)
- Checkpoints marked on timeline
- Round 0 marked as baseline

### 8. Fake DGT License Generation & Updates
**Initial Generation (After Registration):**
- Create license immediately after photo capture
- Use template image with placeholders
- Background: DGT license template (use color #F3E8EC for card)
- Player photo (circular or rectangular crop)
- Name + Surname
- ID number (UUID)
- Sex and body size indicators
- Points: 15 (starting value)
- Empty badge slots (reserved space for titles)
- Save as PNG to app documents directory

**Real-time Updates (After Each Round):**
- Load existing license image
- Update points value
- Add new title badges to reserved slots (🟢×3, 🔴×1, etc.)
- Add Environmental Distinctive badge (if in top 5 at end)
- Add Fine count indicator (if player received fines)
- Save updated license image
- Replace old image in storage

**Viewing License:**
- Tap player in leaderboard → Full-screen license view
- Show current license image with all badges
- Pinch to zoom
- Share button → Export to gallery

**Template Placeholders:**
```dart
// Define placeholder positions in template image
class LicenseTemplate {
  static const photoRect = Rect.fromLTWH(20, 20, 100, 100);
  static const namePosition = Offset(140, 30);
  static const surnamePosition = Offset(140, 50);
  static const idPosition = Offset(140, 70);
  static const pointsPosition = Offset(140, 90);
  static const badge1Position = Offset(20, 140);
  static const badge2Position = Offset(70, 140);
  static const badge3Position = Offset(120, 140);
  static const badge4Position = Offset(170, 140);
  static const badge5Position = Offset(220, 140);
  static const envBadgePosition = Offset(270, 140);
}
```

**Export:** Save as PNG to gallery using `image_gallery_saver`

### 9. Final Ceremony ("La Ceremonia Final")

**Phase 2.5 note:** Grand Prizes (El Conductor Perfecto, Precisión Absoluta, Coleccionista de Títulos) are removed as separate awards. The Leaderboard is the sole source of truth for winners. The ceremony focuses on the top 3 leaderboard reveal, Environmental Distinctives, and the DGT title collector as a cosmetic joke.

**Trigger:**
- "Finish Game" button — moved to **Phase 3** (accessible from game flow / main menu when game is in progress)
- Shows confirmation dialog before proceeding

**Flow:**
1. **Final Leaderboard Screen:**
   - Show final sorted leaderboard (primary: points descending; tiebreaker: perfection score ascending)
   - Highlight top 3 with medals 🥇🥈🥉 and confetti
   - Show each player's points, fine count, BAC progression summary
   - "Continue to Environmental Distinctives" button

2. **Environmental Distinctive Reveal (Envelope Animations):**
   - Show top 5 **highest** BAC players — they receive the badge as a **satirical joke** (like a DGT F/G pollution label — least eco-friendly)
   - Envelope animation for each → reveals their DGT license with the environmental badge
   - Framing: "Los más contaminantes de la noche 🏭💨"
   - Update licenses with environmental badges

3. **DGT Title Collector (Cosmetic Joke):**
   - Show which player accumulated the most DGT titles overall ("El Coleccionista de Títulos 👑")
   - Cosmetic only — possibly earns money for the next-day game
   - Simple reveal screen, no envelope animation required

4. **Final Actions:**
   - "Return to Menu" → clear game state, return to main menu
   - "View All Licenses" → gallery view of all final licenses with badges

**Fake Error Message Easter Egg:**
- 10% chance to show fake error (assets/msg_error.png) during ceremony as a joke

---

## 🧪 Testing Requirements

### Unit Tests (MANDATORY for Core Logic)
**Files to Test:**
- `bac_calculator.dart`
- `points_calculator.dart`
- `title_evaluator.dart`

**Example Test:**
```dart
// test/core/utils/points_calculator_test.dart
void main() {
  group('PointsCalculator', () {
    test('should deduct 3 points for fast BAC increase', () {
      final penalty = PointsCalculator.calculatePenalty(
        0.20, // previous
        0.60, // current
        const Duration(minutes: 30),
      );
      expect(penalty, 3);
    });
  });
}
```

### Widget Tests
- Test `CustomKeypad` input logic
- Test `MassiveButton` tap behavior
- Golden tests for `FakeLicenseCard`

### Integration Tests
- Full registration flow
- BAC entry → points update → leaderboard refresh

---

## 💾 Persistent State Management

### Critical: All Game State Must Persist

**Why:** App stays open all day, must survive crashes and memory issues

**What to Save to Hive:**
1. **Game State:**
   - Current round number (0, 1, 2, ...)
   - Game start timestamp
   - Is game in progress flag
   - Checkpoint timer state (remaining time)

2. **Player Profiles:**
   - All player data (name, surname, photo, sex, size, etc.)
   - All BAC readings with timestamps
   - Current points
   - Title counts
   - License image path
   - Impoundment status

3. **Round History:**
   - All BAC readings for all players
   - Title awards per round
   - Points changes per round

**When to Save:**
- After every BAC entry
- After every points change
- After every title award
- Every second (timer state)
- After license update
- On app pause/background

**Recovery Strategy:**
```dart
@riverpod
class GameRecovery extends _$GameRecovery {
  @override
  Future<void> build() async {
    // On app launch, check for existing game state
    final gameState = await ref.read(gameRepositoryProvider).loadGameState();
    
    if (gameState.isInProgress) {
      // Resume game from saved state
      ref.read(checkpointTimerProvider.notifier).resume(gameState.timerState);
      ref.read(playerListProvider.notifier).loadPlayers(gameState.players);
      // Navigate to appropriate screen based on round state
    }
  }
}
```

## 🔒 Code Quality Standards

### Linting
**Required Packages:**
```yaml
dev_dependencies:
  flutter_lints: ^3.0.0
  custom_lint: ^0.5.0
  riverpod_lint: ^2.0.0
```

**analysis_options.yaml:**
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    invalid_annotation_target: ignore
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    - always_declare_return_types
    - avoid_print
    - prefer_const_constructors
    - prefer_final_fields
    - require_trailing_commas
```

### Pre-Commit Hooks
**Install:** `lefthook` (add to `pubspec.yaml`)

**lefthook.yml:**
```yaml
pre-commit:
  commands:
    format:
      run: dart format .
    analyze:
      run: flutter analyze
    test:
      run: flutter test
```

### Formatting
- **Command:** `dart format .`
- **Line Length:** 120 characters
- **Trailing Commas:** Required for all function calls with multiple parameters

---

## 🚀 Git Workflow

### Branch Strategy
- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: New features (e.g., `feature/ocr-integration`)
- `fix/*`: Bug fixes

### Commit Messages
**Format:** `<type>(<scope>): <description>`

**Examples:**
- `feat(breathalyzer): add OCR camera screen`
- `fix(scoring): correct points deduction formula`
- `refactor(ui): extract massive button widget`
- `test(calculator): add BAC calculation tests`

### Pull Request Rules
1. Must pass CI/CD checks (format, analyze, test)
2. Requires 1 approval from partner
3. Squash merge to keep history clean

---

## 🤖 AI Agent Personas (Skills)

When asking an AI to work on a specific part of the app, assign it one of these personas:

### 🎨 The UI/UX Architect
**Prompt:**
> "Act as the UI/UX Architect. Generate this screen prioritizing Drunk-Proof UX. Use massive buttons (minHeight: 80), high-contrast DGT colors (Yellow/Black/Blue), and ensure no complex navigation is required. Hardcode decimal points on number pads. Assume users have impaired motor skills and vision."

### 🧠 The State Manager
**Prompt:**
> "Act as the State Manager. Implement Riverpod providers for this feature using code generation (@riverpod). Keep the UI completely separated from business logic. Ensure state updates trigger the DGT gamification rules. Use AsyncNotifier for async operations."

### 🔢 The DGT Logic Engine
**Prompt:**
> "Act as the DGT Logic Engine. Write the mathematical utility classes for BAC progression and points calculation. Calculate the delta between the current reading and the previous reading to apply points deductions accurately. Include comprehensive unit tests with edge cases."

### 📸 The OCR Specialist
**Prompt:**
> "Act as the OCR Specialist. Implement ML Kit text recognition to read breathalyzer displays. Handle edge cases: poor lighting, angled photos, multiple numbers in frame. Provide confidence scores and fallback to manual entry if confidence < 90%."

### 🎭 The Animation Director
**Prompt:**
> "Act as the Animation Director. Create engaging animations for the final ceremony (envelope reveals, confetti, siren flashes). Use Flutter's implicit animations where possible. Ensure animations are performant (60fps) and can be skipped."

---

## 📦 Required Packages

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.0
  
  # Models & Serialization
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.1
  
  # OCR
  google_mlkit_text_recognition: ^0.11.0
  camera: ^0.10.5
  
  # UI
  fl_chart: ^0.65.0
  image_picker: ^1.0.4
  image_gallery_saver: ^2.0.3
  
  # Audio
  audioplayers: ^5.2.0
  
  # Utilities
  uuid: ^4.2.0
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  hive_generator: ^2.0.1
  
  # Linting
  flutter_lints: ^3.0.0
  custom_lint: ^0.5.0
  riverpod_lint: ^2.3.0
  
  # Testing
  mockito: ^5.4.0
  mocktail: ^1.0.0
```

---

## 🎯 Development Workflow

### Daily Routine
1. **Pull latest changes:** `git pull origin develop`
2. **Run code generation:** `dart run build_runner build -d`
3. **Check for issues:** `flutter analyze`
4. **Run tests:** `flutter test`
5. **Format code:** `dart format .`

### Before Committing
1. Ensure all tests pass
2. Run `flutter analyze` (0 issues)
3. Format code with `dart format .`
4. Write descriptive commit message
5. Push to feature branch
6. Create PR to `develop`

### Before Merging to Main
1. All CI/CD checks pass
2. Partner has reviewed and approved
3. Manual testing on physical device
4. No merge conflicts

---

## 🚨 Common AI Pitfalls to Avoid

### ❌ DON'T
- Use `setState` in StatefulWidgets (use Riverpod instead)
- Modify state directly inside `build()` methods
- Use `print()` for debugging (use `debugPrint()` or proper logging)
- Leave unused imports or variables
- Use magic numbers (define constants in `app_constants.dart`)
- Create deeply nested widget trees (extract to separate widgets)
- Use native keyboards for numerical input
- Forget to dispose controllers/timers
- Ignore null safety warnings

### ✅ DO
- Use `@riverpod` code generation for all providers
- Separate business logic from UI (repository pattern)
- Write tests for all core logic before considering it complete
- Use `const` constructors wherever possible
- Extract reusable widgets to `widgets/` directory
- Add trailing commas for better formatting
- Use named parameters for functions with 3+ arguments
- Handle loading/error states in UI
- Add comments for complex logic

---

## 📞 Communication Protocol (Between Developers)

**Team:** 3 developers as of Phase 2.5.
- **Developer A (Javier):** Core infrastructure, architecture decisions, Firebase integration
- **Developer B (Kristian):** UI/UX, screens, animations, Flutter frontend
- **Developer C (Josema):** Phase 4 — Firebase backend + Web frontend

### When to Sync
- Before starting work on a new feature
- After completing a major component
- When encountering architectural decisions
- Before merging to `develop`
- When Firebase schema changes (Developer C must be consulted)

### What to Communicate
- "I'm working on [feature]"
- "I've pushed [component], ready for review"
- "I need [data model/API] from you to proceed"
- "I'm blocked on [issue], can you help?"
- **Developer C sync point:** Before Phase 4 begins, align on Firestore schema and offline-first strategy

### Code Review Checklist
- [ ] Follows folder structure
- [ ] Uses Riverpod (no other state management)
- [ ] Includes tests for core logic
- [ ] Passes `flutter analyze`
- [ ] Formatted with `dart format`
- [ ] No hardcoded strings (use constants)
- [ ] Follows DGT theme colors
- [ ] Touch targets are oversized (minHeight: 60+)
- [ ] No native keyboards for numerical input

---

## 🎓 Learning Resources

### Riverpod
- [Official Docs](https://riverpod.dev)
- [Code Generation Guide](https://riverpod.dev/docs/concepts/about_code_generation)

### Hive
- [Official Docs](https://docs.hivedb.dev)
- [Type Adapters](https://docs.hivedb.dev/#/custom-objects/type_adapters)

### ML Kit
- [Text Recognition](https://pub.dev/packages/google_mlkit_text_recognition)

### Flutter Testing
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/cookbook/testing/integration/introduction)

---

## 🏁 Project Milestones

### ✅ Phase 1: Foundation (Week 1) - COMPLETED
- [x] Project setup (packages, folder structure)
- [x] Core theme and constants
- [x] Main menu (persistent home screen)
- [x] Fake News / Fake Error screens
- [x] Player registration flow
- [x] License generation system
- [x] Hive storage implementation

### ✅ Phase 2: Core Gameplay (Week 2) - COMPLETED
- [x] Round 0 (baseline measurement, no feedback)
- [x] Manual BAC entry with custom keypad
- [x] Points calculation logic
- [x] Real-time feedback system (Round 1+)
- [x] License update system
- [x] Checkpoint timer system (with persistence)
- [x] Leaderboard with BAC graphs

### 🚧 Phase 2.5: Mechanics Revision (Pre-Phase 3) - IN PROGRESS
- [ ] Replace impoundment with Fine system (fine.png, fineCount, moneyLost)
- [ ] Simplify points scale to -4 / -2 / 0 / +2 / +4
- [ ] Add "Policía de la Diversión" penalty (too low = -2 pts)
- [ ] Fix leaderboard reactivity (real-time updates without reload)
- [ ] Update title logic: ITV Passed → "Redemption" (lost pts → back in zone)
- [ ] Remove Vehículo Híbrido logic (TBD replacement title)
- [ ] Remove Round-Robin auto-advance (manual progression only)
- [ ] Add debug button to skip timer and trigger next measurement immediately
- [ ] OS push notifications for checkpoint alerts (`flutter_local_notifications`)
  - Sound: `assets/sound/policia_control.mp3`
- [ ] Update tiebreaker logic (perfection score)
- [ ] DGT Titles now cosmetic-only (no impact on winners)

### 🚀 Phase 3: Advanced Features (Week 3)
- [ ] OCR camera integration ("El Radar")
- [ ] Complete Round-Robin "El Retén" flow audit
- [ ] DGT title evaluation finalized (cosmetic, per-round)
- [ ] License viewing (full-screen, tap from leaderboard)
- [ ] Game state recovery (resume after crash)
- [ ] Player management (edit & delete)
- [ ] "Finish Game" button (triggers Final Ceremony)
- [ ] Siren audio fix (`assets/sound/` in pubspec.yaml)

### 🔥 Phase 4: Firebase & Web Frontend
- [ ] Firebase Firestore integration (Players + Notifications tables)
  - Offline-first: app works without internet, writes to Firebase when available
- [ ] Firebase Player sync (points history, BAC history, fines, photo, name/id)
- [ ] Notification system: custom notifications + predefined events (fines, streaks, MOAB)
- [ ] Web frontend (leaderboard display + notifications ticker)
  - Real-time leaderboard with top 3 medals
  - Notification ticker (30s/1min per message with countdown bar)
  - Sound effects on leaderboard update / new notification
  - End-of-game summary (top 3, Environmental Distinctives, most titles)
- [ ] Send notification UI in app (custom text, predefined templates)

### 🎨 Phase 5: Polish & Release (formerly Phase 4)
- [ ] Final ceremony screen (top 3 reveal + Environmental Distinctives envelopes)
- [ ] Splash / landing screen
- [ ] App branding (logo + launcher icon)
- [ ] BAC Progression graphs audit (may already be implemented)
- [ ] Comprehensive testing (80%+ coverage)
- [ ] Performance optimization (60fps animations)
- [ ] App size optimization
- [ ] APK distribution via Firebase App Distribution
- [ ] Visual style mod (roundness → boxy, font selection)

---

## 📋 Quick Reference Commands

```bash
# Code Generation
dart run build_runner build -d          # One-time build
dart run build_runner watch -d          # Watch mode

# Quality Checks
dart format .                           # Format all files
flutter analyze                         # Static analysis
flutter test                            # Run all tests
flutter test --coverage                 # Generate coverage report

# Build
flutter build apk --release             # Android APK
flutter build appbundle --release       # Android App Bundle
flutter build ios --release             # iOS (requires macOS)

# Run
flutter run                             # Debug mode
flutter run --release                   # Release mode
flutter run -d chrome                   # Web (for testing UI)
```

---

## 🎉 Final Notes

This document is the **single source of truth** for the Operación DGV project. Both AI assistants (Claude Web and Cursor) must consult this file before generating any code, proposing architecture changes, or refactoring existing code.

**Documentation Hierarchy:**
1. **`AI_INSTRUCTIONS.md`** (this file) - Project mission, architecture, game mechanics
2. **`.claude/skills/dart-flutter-patterns/`** - Flutter/Riverpod implementation patterns
3. **`.claude/skills/flutter-dart-code-review/`** - Code review checklist and best practices
4. **`.cursorrules`** / **`CLAUDE.md`** - AI assistant configuration files

**When in doubt:**
1. Check this document first for project-specific requirements
2. Consult `.claude/skills/` for Flutter/Dart implementation patterns
3. Ask your development partner
4. Test on a physical device (drunk-proof UX cannot be validated in simulators)

**Integration Strategy:**
- This file defines **WHAT** to build (features, game mechanics, DGT theme)
- `.claude/skills/` defines **HOW** to build it (Riverpod patterns, widget architecture, testing)
- Combine both: Use skills for implementation patterns, use this file for project requirements

**Remember:** The goal is to create a fun, safe, and technically excellent party app that gamifies responsible drinking. Every line of code should serve that mission.

---

**Version History:**
- v1.0 (May 4, 2026): Initial comprehensive specification
