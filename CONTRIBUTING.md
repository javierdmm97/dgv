# Contributing to Operación DGV

Thank you for your interest in contributing to Operación DGV! This document provides guidelines and instructions for contributing to the project.

---

## 📋 Table of Contents

1. [Getting Started](#getting-started)
2. [Development Workflow](#development-workflow)
3. [Coding Standards](#coding-standards)
4. [Commit Convention](#commit-convention)
5. [Pull Request Process](#pull-request-process)
6. [Testing Requirements](#testing-requirements)
7. [Documentation](#documentation)

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.10+ installed
- Dart 3.0+ installed
- Git installed
- Android Studio or VS Code with Flutter extensions

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/dgv.git
   cd dgv
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up git hooks:**
   ```bash
   # Add lefthook to dev_dependencies first
   flutter pub add --dev lefthook
   lefthook install
   ```

4. **Run code generation:**
   ```bash
   dart run build_runner build -d
   ```

5. **Verify setup:**
   ```bash
   flutter analyze
   flutter test
   ```

### Read the Documentation

Before contributing, please read:

1. **[`AI_INSTRUCTIONS.md`](./AI_INSTRUCTIONS.md)** - Complete project specification
2. **[`.claude/skills/`](./.claude/skills/)** - Flutter/Riverpod best practices
3. **[`ROADMAP.md`](./ROADMAP.md)** - Project roadmap and current priorities

---

## 🔄 Development Workflow

### Branch Strategy

- **`main`** - Production-ready code (protected)
- **`develop`** - Integration branch (protected)
- **`feature/*`** - New features (e.g., `feature/player-registration`)
- **`fix/*`** - Bug fixes (e.g., `fix/points-calculation`)
- **`refactor/*`** - Code refactoring
- **`docs/*`** - Documentation updates

### Creating a New Branch

```bash
# Always branch from develop
git checkout develop
git pull origin develop

# Create your feature branch
git checkout -b feature/your-feature-name
```

### Daily Workflow

1. **Pull latest changes:**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout your-branch
   git merge develop
   ```

2. **Make your changes**

3. **Run code generation (if needed):**
   ```bash
   dart run build_runner build -d
   ```

4. **Test your changes:**
   ```bash
   flutter analyze
   flutter test
   dart format .
   ```

5. **Commit your changes:**
   ```bash
   git add .
   git commit -m "feat(scope): description"
   ```

6. **Push to your branch:**
   ```bash
   git push origin your-branch
   ```

7. **Create a Pull Request** on GitHub

---

## 📝 Coding Standards

### Architecture Rules

- **State Management:** Riverpod ONLY (no Provider, GetX, or Bloc)
- **Models:** Use Freezed for immutable data classes
- **Storage:** Use Hive for local storage
- **Folder Structure:** Follow feature-first architecture (see `AI_INSTRUCTIONS.md`)

### Code Style

- **Formatting:** Run `dart format .` before committing
- **Line Length:** 120 characters maximum
- **Trailing Commas:** Required for all function calls with multiple parameters
- **Const Constructors:** Use `const` wherever possible
- **Null Safety:** Avoid `!` operator, use `?.` and `??` instead

### UI/UX Guidelines

- **Touch Targets:** Minimum `minHeight: 60`, recommended `minHeight: 80`
- **No Native Keyboards:** Use custom keypads for numerical input
- **High Contrast:** Use DGT color palette for accessibility
- **Minimal Navigation:** Keep flows simple and linear

### Example Code

```dart
// ✅ GOOD
@riverpod
class PlayerList extends _$PlayerList {
  @override
  Future<List<PlayerProfile>> build() async {
    final repo = ref.watch(playerRepositoryProvider);
    return repo.getAll();
  }
  
  Future<void> addPlayer(PlayerProfile player) async {
    final repo = ref.read(playerRepositoryProvider);
    await repo.save(player);
    ref.invalidateSelf();
  }
}

// ❌ BAD
class PlayerListNotifier extends StateNotifier<List<PlayerProfile>> {
  PlayerListNotifier() : super([]);
  
  void addPlayer(PlayerProfile player) {
    state = [...state, player]; // Direct state mutation
  }
}
```

---

## 💬 Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/).

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- **feat** - New feature
- **fix** - Bug fix
- **docs** - Documentation changes
- **style** - Code style changes (formatting, no logic change)
- **refactor** - Code refactoring (no feature change)
- **test** - Adding or updating tests
- **chore** - Maintenance tasks (dependencies, build config)
- **perf** - Performance improvements
- **ci** - CI/CD changes
- **build** - Build system changes
- **revert** - Revert a previous commit

### Scopes

Use feature names or areas:
- `player-registration`
- `breathalyzer`
- `checkpoint`
- `scoring`
- `leaderboard`
- `achievements`
- `fake-id`
- `ui`
- `core`
- `tests`
- `docs`

### Examples

```bash
feat(breathalyzer): add OCR camera screen
fix(scoring): correct points deduction for negative deltas
docs(readme): update installation instructions
refactor(ui): extract massive button to reusable widget
test(calculator): add BAC calculation edge cases
chore(deps): update riverpod to 2.4.0
```

---

## 🔀 Pull Request Process

### Before Creating a PR

1. **Ensure all tests pass:**
   ```bash
   flutter test
   ```

2. **Run static analysis:**
   ```bash
   flutter analyze
   ```

3. **Format your code:**
   ```bash
   dart format .
   ```

4. **Update documentation** if needed

5. **Update `CHANGELOG.md`** under `[Unreleased]` section

### Creating a PR

1. **Push your branch** to GitHub

2. **Create a Pull Request** from your branch to `develop`

3. **Fill out the PR template** completely:
   - Description of changes
   - Type of change
   - Feature area
   - Testing performed
   - Screenshots (if UI changes)
   - Checklist completion

4. **Request review** from your partner

5. **Address review comments** promptly

### PR Requirements

- ✅ All CI checks pass (format, analyze, test, build)
- ✅ At least 1 approval from a team member
- ✅ No merge conflicts with `develop`
- ✅ Changelog updated
- ✅ Documentation updated (if needed)

### After PR is Merged

1. **Delete your feature branch:**
   ```bash
   git branch -d feature/your-feature-name
   git push origin --delete feature/your-feature-name
   ```

2. **Update your local `develop`:**
   ```bash
   git checkout develop
   git pull origin develop
   ```

---

## 🧪 Testing Requirements

### Test Coverage

- **Minimum:** 80% code coverage for core logic
- **Unit Tests:** Required for all utilities and business logic
- **Widget Tests:** Required for all custom widgets
- **Integration Tests:** Required for complete user flows

### Writing Tests

**Unit Test Example:**
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
    
    test('should deduct 0 points for safe pace', () {
      final penalty = PointsCalculator.calculatePenalty(
        0.20,
        0.22,
        const Duration(hours: 1),
      );
      expect(penalty, 0);
    });
  });
}
```

**Widget Test Example:**
```dart
// test/widgets/massive_button_test.dart
void main() {
  testWidgets('MassiveButton calls onPressed when tapped', (tester) async {
    var pressed = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MassiveButton(
            label: 'Test',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );
    
    await tester.tap(find.text('Test'));
    expect(pressed, isTrue);
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/core/utils/points_calculator_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📚 Documentation

### When to Update Documentation

- Adding a new feature → Update `AI_INSTRUCTIONS.md` and `README.md`
- Changing architecture → Update `AI_INSTRUCTIONS.md`
- Adding dependencies → Update `README.md` and `AI_INSTRUCTIONS.md`
- Completing a milestone → Update `ROADMAP.md`
- Making any change → Update `CHANGELOG.md`

### Documentation Files

- **`AI_INSTRUCTIONS.md`** - Project specification and architecture
- **`README.md`** - Quick start and overview
- **`ROADMAP.md`** - Development plan and progress
- **`CHANGELOG.md`** - Version history and changes
- **`CONTRIBUTING.md`** - This file
- **`DOCUMENTATION_STRUCTURE.md`** - How docs fit together

### Code Comments

- Add comments for complex logic
- Use `///` for public API documentation
- Use `//` for implementation notes
- Avoid obvious comments

**Example:**
```dart
/// Calculates BAC using the Widmark formula.
/// 
/// Formula: BAC = (Alcohol in grams / (Body weight × r)) × 100
/// where r = 0.68 for men, 0.55 for women
/// 
/// Returns BAC as a percentage (e.g., 0.08 for 0.08%)
static double calculateBAC({
  required double alcoholGrams,
  required Sex sex,
  required BodySize bodySize,
}) {
  // Get body weight based on size category
  final bodyWeight = _getBodyWeight(bodySize);
  
  // Distribution ratio varies by sex
  final r = sex == Sex.male ? 0.68 : 0.55;
  
  return (alcoholGrams / (bodyWeight * 1000 * r)) * 100;
}
```

---

## 🤝 Communication

### When to Sync with Your Partner

- Before starting a new feature
- After completing a major component
- When encountering architectural decisions
- Before merging to `develop`
- When blocked on an issue

### What to Communicate

- "I'm working on [feature]"
- "I've pushed [component], ready for review"
- "I need [data model/API] from you to proceed"
- "I'm blocked on [issue], can you help?"

### Code Review Guidelines

**As a Reviewer:**
- Be constructive and respectful
- Check against `AI_INSTRUCTIONS.md` standards
- Test the changes locally if possible
- Approve only if all requirements are met

**As an Author:**
- Respond to all comments
- Don't take feedback personally
- Ask for clarification if needed
- Thank reviewers for their time

---

## 🎭 Using AI Assistants

### AI Agent Personas

When working with AI assistants (Claude or Cursor), use these personas:

- **🎨 UI/UX Architect** - For drunk-proof UI design
- **🧠 State Manager** - For Riverpod providers
- **🔢 DGT Logic Engine** - For BAC calculations and game logic
- **📸 OCR Specialist** - For ML Kit integration
- **🎭 Animation Director** - For animations and effects

### AI Workflow

1. Tell the AI to read `AI_INSTRUCTIONS.md`
2. Reference `.claude/skills/` for patterns
3. Specify which persona to use
4. Review and test AI-generated code
5. Ensure it follows project standards

---

## ❓ Questions?

If you have questions:

1. Check `AI_INSTRUCTIONS.md` first
2. Review `.claude/skills/` for patterns
3. Ask your development partner
4. Create a GitHub issue with the `question` label

---

## 🎉 Thank You!

Thank you for contributing to Operación DGV! Your work helps create a fun, safe app that gamifies responsible drinking. 🚔🍻

---

**Remember:** The goal is to create a technically excellent app with drunk-proof UX. Every contribution should serve that mission.
