# 🛠️ Development Guide

Complete guide for setup, daily workflow, coding standards, and collaboration.

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

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

Types: feat, fix, docs, style, refactor, test, chore, perf, ci
Scopes: player-registration, breathalyzer, checkpoint, scoring, etc.

Examples:
feat(breathalyzer): add OCR camera screen
fix(scoring): correct points deduction formula
docs(readme): update installation instructions
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

### After Merge

```bash
git branch -d feature/your-feature-name
git push origin --delete feature/your-feature-name
git checkout develop
git pull origin develop
```

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

## 🚀 Quick Commands

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
- [AUTOMATION.md](AUTOMATION.md) - CI/CD details
- [ARCHITECTURE.md](ARCHITECTURE.md) - Project structure
- [../AI_INSTRUCTIONS.md](../AI_INSTRUCTIONS.md) - Complete specification
