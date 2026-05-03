# 🚔 Operación DGV - AI System Instructions

**Version:** 1.0  
**Last Updated:** May 4, 2026  
**Project:** Party Breathalyzer Tracker with DGT Theme

---

## 🎯 Project Mission

**Operación DGV** (Dirección General de Vitis) is a Flutter mobile app that gamifies responsible drinking at parties through a satirical Spanish traffic authority (DGT) theme. Players compete to maintain the most "license points" by pacing their alcohol consumption, not by drinking the most.

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
│   ├── dgt_avatar.dart               # Player avatar display
│   ├── license_card.dart             # "Carnet por Puntos" visual card
│   └── siren_animation.dart          # Police siren flash effect
│
└── features/                          # Isolated feature modules
    │
    ├── onboarding/                    # App introduction & rules
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
    │   │   ├── avatar_selection_screen.dart
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
  static const primary = Color(0xFF003DA5);      // DGT Blue
  static const warning = Color(0xFFFFC107);      // Traffic Yellow
  static const danger = Color(0xFFD32F2F);       // Violation Red
  static const success = Color(0xFF388E3C);      // Safe Green
  static const background = Color(0xFF121212);   // Dark mode default
  static const surface = Color(0xFF1E1E1E);      // Card backgrounds
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
    @HiveField(2) required String avatarPath,
    @HiveField(3) required Sex sex,              // Male, Female
    @HiveField(4) required BodySize bodySize,    // S, M, L
    @HiveField(5) required String photoPath,     // For fake ID
    @HiveField(6) @Default(15) int points,       // Starting points
    @HiveField(7) @Default([]) List<BACReading> readings,
    @HiveField(8) @Default([]) List<Achievement> achievements,
    @HiveField(9) @Default(false) bool isImpounded,  // "Vehículo Inmovilizado"
  }) = _PlayerProfile;
}

enum Sex { male, female }
enum BodySize { small, medium, large }
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
}
```

### Points Deduction Logic
```dart
// core/utils/points_calculator.dart
class PointsCalculator {
  /// Calculate points to deduct based on BAC delta
  static int calculatePenalty(double previousBAC, double currentBAC, Duration timeDelta) {
    final delta = currentBAC - previousBAC;
    final ratePerHour = delta / (timeDelta.inMinutes / 60.0);
    
    // Penalties:
    // - Safe pace (0.00-0.02/hr): 0 points
    // - Moderate (0.02-0.05/hr): -1 point
    // - Fast (0.05-0.10/hr): -3 points
    // - Dangerous (>0.10/hr): -5 points
    
    if (ratePerHour < 0.02) return 0;
    if (ratePerHour < 0.05) return 1;
    if (ratePerHour < 0.10) return 3;
    return 5;
  }
  
  /// Check if player exceeded maximum BAC threshold
  static bool isImpounded(double currentBAC, double maxBAC) {
    return currentBAC >= maxBAC;
  }
}
```

### DGT Title Evaluation
```dart
// core/utils/title_evaluator.dart
enum DGTTitle {
  cruiseControl,      // 🟢 Most consistent pace
  speedingTicket,     // 🔴 Aggressive BAC spike
  learnerPlate,       // 🔰 Lowest overall score
  hybrid,             // 🔋 Drank water (BAC dropped)
  itvPassed,          // 🛠️ Same reading twice in a row
}

class TitleEvaluator {
  static DGTTitle? evaluateRound(PlayerProfile player, List<PlayerProfile> allPlayers) {
    // Implementation: Compare deltas, detect patterns, award titles
  }
}
```

---

## 🎮 Feature Specifications

### 1. Player Registration Flow
**Screens:**
1. Name input (custom keyboard)
2. Avatar selection (grid of 12+ options)
3. Sex selection (Male/Female buttons)
4. Body size selection (S/M/L visual buttons)
5. Photo capture (camera with countdown timer)
6. Confirmation screen

**Data Storage:**
- Save to Hive immediately after confirmation
- Generate unique UUID for player ID
- Store photo in app documents directory

### 2. Breathalyzer Data Entry
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
- Full-screen avatar carousel
- Auto-advance every 10 seconds
- Tap avatar → open data entry for that player
- Progress indicator (e.g., "3/8 players logged")

### 3. Checkpoint System ("Control Sorpresa")
**Timer Logic:**
- Configurable interval (default: 45 minutes)
- Visual countdown in app bar
- Audio alert: police siren (3 seconds)
- Screen flash: alternating red/blue
- Lock UI until all players log BAC

**Riverpod Provider:**
```dart
@riverpod
class CheckpointTimer extends _$CheckpointTimer {
  Timer? _timer;
  
  @override
  Duration build() {
    return const Duration(minutes: 45);
  }
  
  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.inSeconds <= 0) {
        _triggerCheckpoint();
      } else {
        state = state - const Duration(seconds: 1);
      }
    });
  }
  
  void _triggerCheckpoint() {
    // Play siren, show alert, navigate to round-robin screen
  }
}
```

### 4. Penalty System
**Automatic Deductions:**
- After each BAC entry, calculate delta from previous reading
- Apply points penalty using `PointsCalculator`
- Update player's points in Hive
- Show penalty notification (e.g., "-3 points: Speeding!")

**Impoundment ("Vehículo Inmovilizado"):**
- Trigger when `currentBAC >= maxBAC` (configurable, default: 1.2)
- Play error buzzer sound
- Show full-screen red warning
- Mark player as `isImpounded = true`
- Deduct 5 points
- Player cannot participate in next round

### 5. Leaderboard Display
**Sort Order:** Descending by points
**Card Layout:**
```
┌─────────────────────────────────┐
│ 🏆 1st Place                    │
│ [Avatar] Juan                   │
│ 12 points | 0.45 BAC            │
│ 🟢 Velocidad de Crucero         │
└─────────────────────────────────┘
```

**Graph:** Line chart showing BAC progression over time (use `fl_chart` package)

### 6. Fake DGT License Generation
**Components:**
- Background: DGT license template (blue/yellow)
- Player photo (circular crop)
- Name, ID number (UUID)
- Points remaining (large, bold)
- Achievement badges (icons in grid)

**Export:** Save as PNG to gallery using `image_gallery_saver`

### 7. Final Ceremony ("La Multa")
**Flow:**
1. Trigger manually or at end of night
2. Show envelope animation for each category:
   - "Velocidad de Crucero" (most consistent)
   - "Multa por Exceso" (most penalties)
   - "La 'L' de Prácticas" (lowest score)
   - "Vehículo Híbrido" (most water breaks)
   - "ITV Passed" (most identical readings)
3. Envelope opens → reveal fake license with winner's photo
4. Confetti animation
5. Share button → export all licenses as images

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
- [ ] Player registration flow
- [ ] Hive storage implementation

### Phase 2: Core Gameplay (Week 2)
- [ ] Manual BAC entry with custom keypad
- [ ] Points calculation logic
- [ ] Checkpoint timer system
- [ ] Basic leaderboard

### Phase 3: Advanced Features (Week 3)
- [ ] OCR camera integration
- [ ] Round-robin "El Retén" flow
- [ ] Penalty system with audio/visual alerts
- [ ] DGT title evaluation

### Phase 4: Polish (Week 4)
- [ ] Fake license generation
- [ ] Final ceremony animations
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
