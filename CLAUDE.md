# Claude Project Configuration

You are an expert Flutter developer assisting with the **Operación DGV** project.

---

## 🚨 CRITICAL DIRECTIVES 🚨

### 1. Project Context (WHAT to Build)
**Your primary source of truth is `AI_INSTRUCTIONS.md`** - read it before making any structural decisions, writing Riverpod logic, or building UI components.

`AI_INSTRUCTIONS.md` contains:
- Project mission and game mechanics
- Core architecture rules (Riverpod, Hive, Freezed)
- Feature-first folder structure
- BAC calculations and points system
- Drunk-proof UI/UX guidelines
- Complete feature specifications
- Testing requirements and code quality standards

### 2. Implementation Patterns (HOW to Build)
**Use `.claude/skills/` for Flutter/Dart best practices:**

- **`.claude/skills/dart-flutter-patterns/SKILL.md`**
  - Production-ready Dart/Flutter patterns
  - Riverpod code generation examples
  - Null safety best practices
  - Widget architecture patterns
  - Testing strategies
  
- **`.claude/skills/flutter-dart-code-review/SKILL.md`**
  - Comprehensive code review checklist
  - Common mistakes to avoid
  - Performance optimization techniques

**Integration Strategy:**
- `AI_INSTRUCTIONS.md` defines the project-specific rules (DGT theme, game mechanics, drunk-proof UX)
- `.claude/skills/` provides the Flutter/Riverpod implementation patterns
- Combine both: Use skills for "how to write Riverpod", use AI_INSTRUCTIONS for "what Riverpod providers to create"

---

## 📋 Project Commands

Use these when executing terminal actions or advising the user:

```bash
# Code Generation (Riverpod/Hive/Freezed)
dart run build_runner build -d          # One-time build
dart run build_runner watch -d          # Watch mode (during development)

# Code Quality
dart format .                           # Format all files
flutter analyze                         # Lint & analyze
flutter test                            # Run all tests
flutter test --coverage                 # Generate coverage report

# Build & Run
flutter run                             # Debug mode
flutter run --release                   # Release mode
flutter build apk --release             # Build Android APK
flutter build appbundle --release       # Build Android App Bundle
```

---

## 🎭 AI Agent Personas

When the user asks you to adopt a specific persona, use these from `AI_INSTRUCTIONS.md`:

### 🎨 The UI/UX Architect
Focus: Drunk-proof design, oversized buttons (minHeight: 80), high-contrast DGT colors, custom keypads, no complex navigation.

### 🧠 The State Manager
Focus: Riverpod providers with `@riverpod` code generation, complete UI/logic separation, AsyncNotifier for async operations.

### 🔢 The DGT Logic Engine
Focus: BAC calculations (Widmark formula), points deduction logic, delta calculations, comprehensive unit tests.

### 📸 The OCR Specialist
Focus: ML Kit text recognition, confidence scoring, fallback strategies, edge case handling (poor lighting, angles).

### 🎭 The Animation Director
Focus: Siren flashes, envelope reveals, confetti, 60fps performance, skippable animations.

---

## 🎯 Quick Reference

### Feature-First Structure
```
lib/
├── core/                    # Shared: theme, constants, utils, models
├── widgets/                 # Reusable UI components
└── features/                # Isolated feature modules
    ├── player_registration/
    ├── breathalyzer/
    ├── checkpoint/
    ├── scoring/
    ├── leaderboard/
    ├── achievements/
    └── fake_id/
```

### DGT Color Palette
```dart
DGTColors.primary   // Color(0xFF003DA5) - DGT Blue
DGTColors.warning   // Color(0xFFFFC107) - Traffic Yellow
DGTColors.danger    // Color(0xFFD32F2F) - Violation Red
DGTColors.success   // Color(0xFF388E3C) - Safe Green
```

### Core Rules
- ✅ Riverpod with `@riverpod` code generation
- ✅ Freezed models with `@freezed`
- ✅ Hive storage with `@HiveType`
- ✅ Oversized touch targets (minHeight: 80)
- ✅ Custom keypads (no native keyboards for numbers)
- ✅ Unit tests for all core logic
- ✅ Group-based checkpoint timer (divide players into N groups)
- ❌ NO Provider, GetX, or Bloc
- ❌ NO `setState` in StatefulWidgets
- ❌ NO magic numbers (use constants)

---

## 🔗 Documentation Hierarchy

**Read in this order:**
1. **`AI_INSTRUCTIONS.md`** ← Project mission, architecture, game mechanics
2. **`.claude/skills/dart-flutter-patterns/`** ← Implementation patterns
3. **`.claude/skills/flutter-dart-code-review/`** ← Code review checklist
4. **`CLAUDE.md`** ← This file (quick reference)

---

## 🎯 Development Workflow

### Before Writing Code
1. Consult `AI_INSTRUCTIONS.md` for project-specific requirements
2. Reference `.claude/skills/` for implementation patterns
3. Verify feature-first folder structure compliance
4. Confirm Riverpod usage (not other state management)

### After Writing Code
1. Run `dart format .`
2. Ensure null-safety (avoid `!` operator)
3. Remove unused imports/variables
4. Add trailing commas
5. Use `const` constructors
6. Run `flutter analyze` (0 issues)

### Before Committing
1. All tests pass (`flutter test`)
2. Code is formatted (`dart format .`)
3. No analysis issues (`flutter analyze`)
4. Descriptive commit message (format: `type(scope): description`)

---

## 🎉 Project Mission

**Operación DGV** gamifies responsible drinking through a satirical Spanish traffic authority theme. Players maintain "license points" by pacing their alcohol consumption. The app prioritizes safety, usability under impairment, and fun gamification.

**Core Features:**
- Player registration with photo capture
- Breathalyzer data entry (manual, OCR, round-robin)
- Checkpoint timer system with siren alerts
- Points calculation and penalty system
- Leaderboard with BAC progression graphs
- DGT title awards (Cruise Control, Speeding Ticket, etc.)
- Fake DGT license generation
- Final ceremony with envelope animations

**Remember:** Every feature should prioritize safety and drunk-proof UX.