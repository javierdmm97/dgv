# 🛠️ Development Guide

> 📚 **Documentation:** [README](../README.md) | [Contributing](../CONTRIBUTING.md) | [Automation](AUTOMATION.md)

This guide is the authoritative source for development practices, setup, workflow, coding standards, and testing.

---

## 🚀 Quick Setup

### Prerequisites
- Flutter 3.10+
- Dart 3.0+
- Git
- Android Studio or VS Code with Flutter extensions

### Initial Setup

**Run the setup script:**

**Linux/macOS:**
```bash
chmod +x setup.sh
./setup.sh
```

**Windows (PowerShell):**
```powershell
.\setup.ps1
```

**Or manually:**
```bash
flutter pub get
flutter pub add --dev lefthook
lefthook install
dart run build_runner build -d
```

**Note:** Git hooks are managed by Lefthook. For hook configuration details, see [Git Hooks](AUTOMATION.md#git-hooks-lefthook).

### Verify Installation

```bash
flutter doctor
flutter analyze
flutter test
```

---

## 📋 Daily Workflow

### Morning Routine

```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

### Development Cycle

1. **Make changes**
2. **Run code generation** (if using Freezed/Riverpod):
   ```bash
   dart run build_runner watch -d
   ```
3. **Test locally**:
   ```bash
   flutter analyze
   flutter test
   ```
4. **Commit**:
   ```bash
   git add .
   git commit -m "feat(scope): description"
   ```
5. **Update CHANGELOG.md** under `[Unreleased]`
6. **Push**:
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create Pull Request** on GitHub

---

## 🌿 Git Workflow

### Branch Strategy

- **`main`** - Production (protected)
- **`develop`** - Integration (protected)
- **`feature/*`** - New features
- **`fix/*`** - Bug fixes
- **`refactor/*`** - Refactoring
- **`docs/*`** - Documentation

### Branch Naming

```bash
feature/player-registration
fix/points-calculation
refactor/ui-components
docs/update-readme
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

## 📝 Coding Standards

### Architecture Rules

- **State Management:** Riverpod ONLY
- **Models:** Freezed for immutable data
- **Storage:** Hive for local storage
- **Structure:** Feature-first architecture

### Code Style

- Run `dart format .` before committing
- Line length: 120 characters max
- Use trailing commas
- Use `const` constructors
- Avoid `!` operator, use `?.` and `??`

### UI/UX Guidelines

- Touch targets: `minHeight: 80`
- No native keyboards for numbers
- High contrast colors
- Minimal navigation
- Audio + visual feedback

### Examples

```dart
// ✅ GOOD - Riverpod with code generation
@riverpod
class PlayerList extends _$PlayerList {
  @override
  Future<List<PlayerProfile>> build() async {
    return await ref.read(playerRepositoryProvider).getAll();
  }
}

// ✅ GOOD - Const constructor
const MassiveButton(
  label: 'Continue',
  onPressed: _handleContinue,
)

// ✅ GOOD - Null safety
final name = player?.name ?? 'Unknown';

// ❌ BAD - Force unwrap
final name = player!.name;
```

---

## 🔀 Pull Request Process

### Before Creating PR

```bash
flutter test                # All tests pass
flutter analyze             # No errors
dart format .               # Code formatted
```

Update `CHANGELOG.md` under `[Unreleased]`

### PR Requirements

- ✅ All CI checks pass
- ✅ At least 1 approval
- ✅ No merge conflicts
- ✅ Changelog updated

**Note:** For CI/CD pipeline details, see [GitHub Actions](AUTOMATION.md#github-actions).

### After Merge

```bash
git branch -d feature/your-feature-name
git push origin --delete feature/your-feature-name
git checkout develop
git pull origin develop
```

**Note:** For release process, see [Release Automation](AUTOMATION.md#release-automation).

---

## 🧪 Testing

### Requirements

- 80%+ code coverage for core logic
- Unit tests for utilities and business logic
- Widget tests for custom widgets
- Integration tests for user flows

### Examples

**Unit Test:**
```dart
void main() {
  test('should deduct 3 points for fast BAC increase', () {
    final penalty = PointsCalculator.calculatePenalty(
      0.20, 0.60, const Duration(minutes: 30),
    );
    expect(penalty, 3);
  });
}
```

**Widget Test:**
```dart
testWidgets('MassiveButton calls onPressed when tapped', (tester) async {
  var pressed = false;
  await tester.pumpWidget(
    MaterialApp(
      home: MassiveButton(
        label: 'Test',
        onPressed: () => pressed = true,
      ),
    ),
  );
  await tester.tap(find.text('Test'));
  expect(pressed, isTrue);
});
```

### Running Tests

```bash
flutter test                              # All tests
flutter test test/core/utils/file.dart    # Specific file
flutter test --coverage                   # With coverage
```

---

## ✅ Pre-Push Checklist

Before pushing:

- [ ] Code formatted: `dart format .`
- [ ] No analysis errors: `flutter analyze`
- [ ] All tests pass: `flutter test`
- [ ] CHANGELOG.md updated
- [ ] Commit messages follow convention
- [ ] Branch up to date with `develop`

---

## 🎯 Checkpoint System (Group-Based)

### Overview

The checkpoint system uses group-based measurement to handle large player counts efficiently. Instead of measuring all players simultaneously, players are divided into groups and measured sequentially.

### Group Calculation

**Group sizes are calculated based on player count:**

| Players | Groups | Group Size | Total Time |
|---------|--------|-----------|-----------|
| 1-4 | 1 | 4 | ~2 min |
| 5-8 | 2 | 2-4 | ~5 min |
| 9-16 | 3 | 3-5 | ~8 min |
| 17-24 | 4 | 4-6 | ~12 min |
| 25+ | 5-6 | 5-6 | ~15 min |

**Formula:**
```
Time per group = (group_size × 30 seconds) + buffer
Total checkpoint time = (number_of_groups × time_per_group) + 5 min buffer
Main interval = 45 minutes (default, configurable)
```

### Implementation

**Key files:**
- `core/utils/checkpoint_calculator.dart` - Group calculation logic
- `features/checkpoint/providers/checkpoint_timer_provider.dart` - Timer state management
- `features/checkpoint/presentation/checkpoint_screen.dart` - UI for group measurement

**Core logic:**
```dart
// Calculate groups
final groups = CheckpointCalculator.divideIntoGroups(players);

// Calculate time per group
final timePerGroup = CheckpointCalculator.calculateTimePerGroup(groupSize);

// Calculate total interval
final interval = CheckpointCalculator.calculateCheckpointInterval(playerCount);
```

### Checkpoint Flow

1. **Main Timer Running** (45 min default)
   - Countdown visible in app bar
   - Players can measure BAC manually anytime

2. **Checkpoint Triggered**
   - Divide players into groups
   - Play siren alert (3 seconds)
   - Flash screen red/blue

3. **Group Measurement** (repeat for each group)
   - Show round-robin for current group only
   - Display: "Group X of Y"
   - Display: "Z/N players measured"
   - Lock UI until group complete

4. **All Groups Complete**
   - Evaluate titles
   - Award points
   - Update licenses
   - Reset main timer

### Testing

**Unit tests for checkpoint calculator:**
```dart
test('should calculate correct group size for 20 players', () {
  final groupSize = CheckpointCalculator.calculateGroupSize(20);
  expect(groupSize, 5);
});

test('should divide 20 players into 4 groups of 5', () {
  final players = List.generate(20, (i) => createPlayer(id: '$i'));
  final groups = CheckpointCalculator.divideIntoGroups(players);
  expect(groups.length, 4);
  expect(groups[0].length, 5);
});

test('should calculate correct interval for 20 players', () {
  final interval = CheckpointCalculator.calculateCheckpointInterval(20);
  expect(interval.inSeconds, greaterThan(900)); // At least 15 min
});
```

---

**💡 Tip:** For a quick reference cheat sheet, see [Quick Reference](../README.md#quick-reference)

### Setup
```bash
flutter pub get
lefthook install
dart run build_runner build -d
```

### Development
```bash
dart run build_runner watch -d    # Watch mode
dart format .                     # Format
flutter analyze                   # Analyze
flutter test                      # Test
flutter test --coverage           # Coverage
```

### Running
```bash
flutter run                       # Debug
flutter run --release             # Release
flutter run -d chrome             # Web
```

### Building
```bash
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

---

## 🆘 Troubleshooting

### Lefthook not running
```bash
lefthook install
```

### CI failing on format
```bash
dart format .
git add .
git commit --amend --no-edit
git push --force
```

### Build runner errors
```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build -d
```

### Merge conflicts
```bash
git checkout develop
git pull origin develop
git checkout your-branch
git merge develop
# Resolve conflicts
git add .
git commit -m "chore: resolve merge conflicts"
```

---

## 🤝 Communication

### When to Sync

- Before starting new features
- After completing major components
- When encountering architectural decisions
- Before merging to `develop`
- When blocked

### Code Review

**As Reviewer:**
- Be constructive and respectful
- Check against project standards
- Test locally if possible

**As Author:**
- Respond to all comments
- Ask for clarification if needed
- Thank reviewers

---

**See also:**
- [AUTOMATION.md](AUTOMATION.md) - Git hooks, CI/CD, and release automation
- [CONTRIBUTING.md](../CONTRIBUTING.md) - How to contribute
- [README.md](../README.md) - Project overview and quick reference
- [AI_INSTRUCTIONS.md](../AI_INSTRUCTIONS.md) - Complete specification
