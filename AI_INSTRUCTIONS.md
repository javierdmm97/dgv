# 🚔 Operación DGV - AI System Instructions

**Version:** 1.0  
**Last Updated:** May 4, 2026  
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
    │   │   ├── main_menu_screen.dart
    │   │   ├── fake_news_screen.dart      # Joke: fake DGT news articles
    │   │   ├── fake_error_screen.dart     # Joke: fake error message
    │   │   └── widgets/
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
    @HiveField(9) @Default(false) bool crossedOptimalLine, // Lost Grand Prize eligibility
    @HiveField(10) @Default(false) bool isImpounded,  // "Vehículo Inmovilizado"
    @HiveField(11) required double optimalBAC,   // Personalized optimal zone
    @HiveField(12) required String licenseImagePath, // Auto-generated license (updated throughout game)
  }) = _PlayerProfile;
}

enum Sex { male, female }
enum BodySize { small, medium, large }

enum DGTTitle {
  velocidadDeCrucero,  // 🟢 Closest to optimal zone
  multaPorExceso,      // 🔴 Highest BAC spike
  lDePracticas,        // 🔰 Lowest BAC in round
  vehiculoHibrido,     // 🔋 BAC dropped (water)
  itvPassed,           // 🛠️ Same reading twice
}
```

### BAC Calculation (Widmark Formula)
```dart
// core/utils/bac_calculator.dart
class BACCalculator {
  /// Calculate theoretical BAC based on drinks consumed
  /// Formula: BAC = (Alcohol consumed in grams / (Body weight in grams × r)) × 100
  /// r = 0.68 for men, 0.55 for women
  static double calculateBAC({
    required double alcoholGrams,
    required Sex sex,
    required BodySize bodySize,
  }) {
    final bodyWeight = _getBodyWeight(bodySize);
    final r = sex == Sex.male ? 0.68 : 0.55;
    return (alcoholGrams / (bodyWeight * 1000 * r)) * 100;
  }

  static double _getBodyWeight(BodySize size) {
    switch (size) {
      case BodySize.small: return 55.0;   // kg
      case BodySize.medium: return 70.0;
      case BodySize.large: return 90.0;
    }
  }
  
  /// Calculate optimal BAC zone based on body size
  /// Small: 0.05, Medium: 0.07, Large: 0.09
  /// TODO: Later implement real formula based on weight and sex
  static double calculateOptimalBAC(BodySize size) {
    switch (size) {
      case BodySize.small: return 0.05;
      case BodySize.medium: return 0.07;
      case BodySize.large: return 0.09;
    }
  }
  
  /// Check if BAC is in the "sweet spot" (±0.02 tolerance)
  static bool isInOptimalZone(double currentBAC, double optimalBAC) {
    return (currentBAC - optimalBAC).abs() <= 0.02;
  }
  
  /// Check if BAC is close to optimal (±0.02-0.05)
  static bool isCloseToOptimal(double currentBAC, double optimalBAC) {
    final diff = (currentBAC - optimalBAC).abs();
    return diff > 0.02 && diff <= 0.05;
  }
  
  /// Check if player crossed the optimal line (>+0.05)
  static bool crossedOptimalLine(double currentBAC, double optimalBAC) {
    return currentBAC > (optimalBAC + 0.05);
  }
}
```

### Points Deduction Logic (Hybrid System)
```dart
// core/utils/points_calculator.dart
class PointsCalculator {
  /// Calculate points change based on BAC relative to optimal zone
  /// Returns positive for gains, negative for penalties
  static int calculatePointsChange({
    required double currentBAC,
    required double optimalBAC,
    required double previousBAC,
    required Duration timeDelta,
  }) {
    // Check if in optimal zone (±0.02)
    if (BACCalculator.isInOptimalZone(currentBAC, optimalBAC)) {
      return 2; // +2 points for being in the sweet spot
    }
    
    // Check if close to optimal (±0.02-0.05)
    if (BACCalculator.isCloseToOptimal(currentBAC, optimalBAC)) {
      return 1; // +1 point for being close
    }
    
    // Check if crossed the optimal line (>+0.05)
    if (BACCalculator.crossedOptimalLine(currentBAC, optimalBAC)) {
      return -3; // -3 points + lose Grand Prize eligibility
    }
    
    // Check if too low (<-0.05 from optimal)
    if (currentBAC < (optimalBAC - 0.05)) {
      return 0; // No points (not drinking enough)
    }
    
    // Check for dangerous spike (>0.15/hr)
    final delta = currentBAC - previousBAC;
    final ratePerHour = delta / (timeDelta.inMinutes / 60.0);
    if (ratePerHour > 0.15) {
      return -2; // -2 points for spiking too fast
    }
    
    return 0; // Default: no change
  }
  
  /// Check if player exceeded maximum BAC threshold (impoundment)
  static bool isImpounded(double currentBAC) {
    return currentBAC >= 1.2; // -5 points + sit out next round
  }
  
  /// Calculate average distance from optimal zone across all readings
  static double calculateAverageDistanceFromOptimal(
    List<BACReading> readings,
    double optimalBAC,
  ) {
    if (readings.isEmpty) return double.infinity;
    
    final distances = readings.map((r) => (r.bac - optimalBAC).abs());
    return distances.reduce((a, b) => a + b) / readings.length;
  }
}
```

### DGT Title Evaluation (Per-Round Awards)
```dart
// core/utils/title_evaluator.dart
enum DGTTitle {
  velocidadDeCrucero,  // 🟢 Closest to optimal zone
  multaPorExceso,      // 🔴 Highest BAC spike
  lDePracticas,        // 🔰 Lowest BAC in round
  vehiculoHibrido,     // 🔋 BAC dropped (water)
  itvPassed,           // 🛠️ Same reading twice
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
  
  /// Calculate grand prize winners at the end
  static Map<String, String> calculateGrandPrizes(List<PlayerProfile> players) {
    final prizes = <String, String>{};
    
    // 🏆 El Conductor Perfecto: Highest points + never crossed optimal line
    final perfectDriver = players
        .where((p) => !p.crossedOptimalLine)
        .reduce((a, b) => a.points > b.points ? a : b);
    prizes['conductor_perfecto'] = perfectDriver.id;
    
    // 🎯 Precisión Absoluta: Closest average to optimal zone
    final mostPrecise = players.reduce((a, b) {
      final aAvg = PointsCalculator.calculateAverageDistanceFromOptimal(
        a.readings, a.optimalBAC,
      );
      final bAvg = PointsCalculator.calculateAverageDistanceFromOptimal(
        b.readings, b.optimalBAC,
      );
      return aAvg < bAvg ? a : b;
    });
    prizes['precision_absoluta'] = mostPrecise.id;
    
    // 👑 Coleccionista de Títulos: Most DGT titles accumulated
    final collector = players.reduce((a, b) {
      final aTotal = a.titleCounts.values.fold(0, (sum, count) => sum + count);
      final bTotal = b.titleCounts.values.fold(0, (sum, count) => sum + count);
      return aTotal > bTotal ? a : b;
    });
    prizes['coleccionista_titulos'] = collector.id;
    
    return prizes;
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

**Buttons:**
- **Add Player** → Navigate to player registration
- **Fake News** → Show satirical DGT/DGV news articles (joke feature)
- **Fake Error Message** → Show fake error screen (joke feature)
- **Start Game** → Begin Round 0 (only visible if no game in progress)
- **Resume Game** → Continue existing game (only visible if game in progress)

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
4. Body size selection (S/M/L visual buttons with weight indicators)
5. Photo capture (camera with countdown timer for license ID)
6. Confirmation screen (shows calculated optimal BAC zone)

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
- Auto-advance every 10 seconds
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

### 5. Checkpoint System ("Control Sorpresa")
**Timer Logic:**
- Configurable interval (default: 45 minutes)
- Visual countdown in app bar
- Audio alert: police siren (3 seconds)
- Screen flash: alternating red/blue
- Lock UI until all players log BAC
- **Timer state saved to Hive** (persists across app restarts)

**Riverpod Provider:**
```dart
@riverpod
class CheckpointTimer extends _$CheckpointTimer {
  Timer? _timer;
  
  @override
  Future<CheckpointState> build() async {
    // Load saved timer state from Hive
    final repo = ref.watch(gameRepositoryProvider);
    return repo.loadCheckpointState();
  }
  
  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.value!.remainingTime.inSeconds <= 0) {
        _triggerCheckpoint();
      } else {
        final newState = state.value!.copyWith(
          remainingTime: state.value!.remainingTime - const Duration(seconds: 1),
        );
        state = AsyncValue.data(newState);
        _saveToHive(newState); // Persist timer state
      }
    });
  }
  
  void _triggerCheckpoint() {
    // Play siren, show alert, navigate to round-robin screen
    // Increment round number and save to Hive
  }
}
```

### 6. Penalty & Reward System
**Automatic Points Changes (Round 1+ only):**
- After each BAC entry, calculate position relative to optimal zone
- Apply points change using `PointsCalculator.calculatePointsChange()`
- Update player's points in Hive
- Show full-screen feedback notification:
  - "+2 points: In the zone!" (green background)
  - "+1 point: Close to optimal" (yellow background)
  - "-3 points: Over the line!" (red background)
  - "-2 points: Dangerous spike!" (red background)
- Mark `crossedOptimalLine = true` if player exceeds optimal + 0.05
- Update license image with new points value

**Impoundment ("Vehículo Inmovilizado"):**
- Trigger when `currentBAC >= 1.2`
- Show fake error message (assets/msg_error.png) full-screen
- Play error buzzer sound
- Mark player as `isImpounded = true`
- Deduct 5 points
- Player cannot participate in next round
- Show "IMPOUNDED" badge on license

**Per-Round Title Awards:**
- After all players log BAC for a checkpoint, evaluate titles
- Award 5 titles per round (Velocidad de Crucero, Multa por Exceso, etc.)
- Increment title counters in player profiles
- Show title award animation with logo
- Update license image with new title badge
- Display title badges on leaderboard

### 7. Leaderboard Display
**Sort Order:** Descending by points

**Card Layout:**
```
┌─────────────────────────────────┐
│ 🏆 1st Place                    │
│ [Photo] Juan García             │
│ 12 points | 0.45 BAC            │
│ Optimal: 0.07 (±0.02)           │
│ 🟢×3 🔴×1 🔰×0 🔋×2 🛠️×1       │
│ [Tap to view license]           │
└─────────────────────────────────┘
```

**Tap Interaction:**
- Tap player card → Navigate to full license view
- Show current license image with all badges
- Display BAC progression graph
- Show detailed stats

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
- Add "IMPOUNDED" badge (if applicable)
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

### 9. Final Ceremony ("La Multa")
**Trigger:**
- "Finish Game" button on main menu (only visible if game in progress)
- Shows confirmation dialog before proceeding

**Flow:**
1. **Final Report Screen:**
   - Show summary statistics for all players
   - Display BAC progression graphs
   - Show final leaderboard
   - "Continue to Ceremony" button

2. **Grand Prize Reveals (Envelope Animations):**
   - 🏆 **El Conductor Perfecto** (Highest points + never crossed line)
     - Envelope animation → reveal license with winner's photo
     - Confetti animation
   - 🎯 **Precisión Absoluta** (Closest average to optimal zone)
     - Envelope animation → reveal license with winner's photo
     - Confetti animation
   - 👑 **Coleccionista de Títulos** (Most DGT titles accumulated)
     - Envelope animation → reveal license with winner's photo
     - Confetti animation

3. **Environmental Distinctive Reveal:**
   - Show top 5 highest BAC players
   - Display as satirical eco-style badges
   - Show each player's license with environmental badge
   - Update licenses with environmental badges

4. **Final Actions:**
   - Share button → export all licenses as images
   - "Return to Menu" → clear game state, return to main menu
   - "View All Licenses" → gallery view of all final licenses

**Fake Error Message Easter Egg:**
- 10% chance to show fake error (assets/msg_error.png) during ceremony as a joke
- Also shown when player hits impoundment threshold

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

### When to Sync
- Before starting work on a new feature
- After completing a major component
- When encountering architectural decisions
- Before merging to `develop`

### What to Communicate
- "I'm working on [feature]"
- "I've pushed [component], ready for review"
- "I need [data model/API] from you to proceed"
- "I'm blocked on [issue], can you help?"

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

### Phase 1: Foundation (Week 1)
- [ ] Project setup (packages, folder structure)
- [ ] Core theme and constants
- [ ] Main menu (persistent home screen)
- [ ] Fake News screen (joke feature)
- [ ] Fake Error screen (joke feature)
- [ ] Player registration flow (name + surname)
- [ ] License generation system (template + placeholders)
- [ ] Hive storage implementation (persistent state)

### Phase 2: Core Gameplay (Week 2)
- [ ] Round 0 (baseline measurement, no feedback)
- [ ] Manual BAC entry with custom keypad
- [ ] Points calculation logic (hybrid system)
- [ ] Real-time feedback system (Round 1+)
- [ ] License update system (after each round)
- [ ] Checkpoint timer system (with persistence)
- [ ] Basic leaderboard (tap to view license)

### Phase 3: Advanced Features (Week 3)
- [ ] OCR camera integration
- [ ] Round-robin "El Retén" flow
- [ ] Penalty system with audio/visual alerts
- [ ] DGT title evaluation (per-round awards)
- [ ] License viewing (full-screen, tap from leaderboard)
- [ ] Game state recovery (resume after crash)

### Phase 4: Polish (Week 4)
- [ ] Final report screen (statistics + graphs)
- [ ] Final ceremony animations (3 Grand Prizes + Environmental Distinctives)
- [ ] License export to gallery
- [ ] Comprehensive testing
- [ ] Performance optimization
- [ ] APK distribution via Firebase

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
