# 🤖 Automation Guide - Operación DGV

This document explains all the automation set up for the Operación DGV project to facilitate collaboration between developers.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Git Hooks (Lefthook)](#git-hooks-lefthook)
3. [GitHub Actions](#github-actions)
4. [Changelog Automation](#changelog-automation)
5. [Release Automation](#release-automation)
6. [PR Automation](#pr-automation)
7. [Quick Reference](#quick-reference)

---

## 🎯 Overview

We've automated the following workflows:

✅ **Pre-commit checks** - Format, analyze code before committing  
✅ **Commit message validation** - Enforce conventional commit format  
✅ **CI/CD pipeline** - Test, analyze, build on every PR  
✅ **PR labeling** - Auto-label PRs based on files changed  
✅ **Changelog checks** - Ensure changelog is updated  
✅ **Release automation** - Auto-create releases from tags  
✅ **APK building** - Build and upload APKs automatically  

---

## 🪝 Git Hooks (Lefthook)

### What is Lefthook?

Lefthook is a fast Git hooks manager that runs checks before commits and pushes.

### Setup

1. **Add to `pubspec.yaml`:**
   ```yaml
   dev_dependencies:
     lefthook: ^1.5.0
   ```

2. **Install:**
   ```bash
   flutter pub get
   lefthook install
   ```

3. **Configuration:** See `lefthook.yml`

### Hooks Configured

#### Pre-commit (runs before `git commit`)
- ✅ **Format check** - Runs `dart format` on staged files
- ✅ **Analyze** - Runs `flutter analyze` to catch errors
- ⏸️ **Tests** - Commented out (uncomment when you have tests)

#### Commit-msg (validates commit message)
- ✅ **Conventional commit check** - Ensures format: `type(scope): description`

#### Pre-push (runs before `git push`)
- ✅ **Tests** - Runs `flutter test` before pushing

### Bypassing Hooks

If you need to bypass hooks (not recommended):

```bash
# Skip pre-commit hooks
git commit --no-verify -m "message"

# Skip pre-push hooks
git push --no-verify
```

### Example Workflow

```bash
# Make changes
vim lib/features/breathalyzer/manual_entry_screen.dart

# Stage changes
git add .

# Commit (hooks run automatically)
git commit -m "feat(breathalyzer): add manual entry screen"
# ✅ Formatting...
# ✅ Analyzing...
# ✅ Commit message valid

# Push (tests run automatically)
git push origin feature/breathalyzer
# ✅ Running tests...
# ✅ All tests passed
```

---

## 🔄 GitHub Actions

### Workflows Configured

#### 1. CI Pipeline (`.github/workflows/ci.yml`)

**Triggers:** PR to `develop` or `main`, push to `develop` or `main`

**Jobs:**
1. **Analyze & Format Check**
   - Checks code formatting
   - Runs static analysis
   - Checks for outdated dependencies

2. **Run Tests**
   - Runs all tests with coverage
   - Uploads coverage to Codecov (optional)

3. **Build Android APK** (Optional - PR only)
   - Only runs if you check `[x] **Build APK**` in the PR description
   - Builds debug APK
   - Uploads as artifact (available for 7 days)
   - Comments on PR when build is ready

**Status:** ✅ Must pass before merging PR

**💡 Tip:** To save CI time, only check the "Build APK" box when you need to test the actual APK (e.g., testing on physical device, checking app size, etc.)

#### 2. Release Pipeline (`.github/workflows/release.yml`)

**Triggers:** Push tag matching `v*.*.*` (e.g., `v1.0.0`)

**Jobs:**
1. **Create Release**
   - Builds release APK and App Bundle
   - Extracts changelog for the version
   - Creates GitHub release with:
     - Release notes from CHANGELOG.md
     - APK file for download
     - App Bundle for Play Store

**Example:**
```bash
# Create and push a tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# GitHub Actions automatically:
# 1. Builds release APK
# 2. Extracts changelog
# 3. Creates GitHub release
# 4. Uploads APK and AAB
```

#### 3. PR Labeler (`.github/workflows/pr-labeler.yml`)

**Triggers:** PR opened, synchronized, or reopened

**Jobs:**
1. **Auto-label PR**
   - Labels based on files changed (see `.github/labeler.yml`)
   - Labels based on branch name (see `.github/pr-labeler.yml`)

**Example Labels:**
- `feature: breathalyzer` - Changes in `lib/features/breathalyzer/`
- `area: ui` - Changes in `lib/widgets/` or `lib/core/theme/`
- `area: tests` - Changes in `test/`
- `feature` - Branch name starts with `feature/`
- `fix` - Branch name starts with `fix/`

#### 4. Changelog Check (`.github/workflows/changelog-check.yml`)

**Triggers:** PR to `develop` or `main`

**Jobs:**
1. **Check Changelog Updated**
   - Verifies CHANGELOG.md was modified
   - Skips check for docs-only PRs
   - Comments on PR if changelog not updated
   - Fails CI if changelog missing

**Bypass:** Only for documentation-only PRs

---

## 📝 Changelog Automation

### How It Works

1. **During Development:**
   - Add changes to `CHANGELOG.md` under `[Unreleased]` section
   - GitHub Actions checks if changelog was updated on PR

2. **When Releasing:**
   - Move `[Unreleased]` changes to a new version section
   - Add release date
   - Create git tag
   - GitHub Actions extracts changelog and creates release

### Changelog Format

```markdown
# Changelog

## [Unreleased]

### Added
- New feature description (#PR_NUMBER)

### Fixed
- Bug fix description (#PR_NUMBER)

### Changed
- Change description (#PR_NUMBER)

## [1.0.0] - 2026-05-15

### Added
- Initial release with all core features

[Unreleased]: https://github.com/user/repo/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/user/repo/releases/tag/v1.0.0
```

### Example Workflow

**1. Working on a feature:**
```markdown
## [Unreleased]

### Added
- Manual BAC entry screen with custom keypad (#23)
- OCR camera integration for breathalyzer readings (#25)
```

**2. Ready to release v1.0.0:**
```markdown
## [Unreleased]

<!-- Empty for now -->

## [1.0.0] - 2026-05-15

### Added
- Manual BAC entry screen with custom keypad (#23)
- OCR camera integration for breathalyzer readings (#25)
```

**3. Create release:**
```bash
git add CHANGELOG.md
git commit -m "chore: prepare v1.0.0 release"
git push origin develop

# Merge to main
git checkout main
git merge develop
git push origin main

# Create tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

**4. GitHub Actions automatically:**
- Extracts changelog between `## [1.0.0]` and next `##`
- Creates GitHub release with extracted notes
- Uploads APK and AAB files

---

## 🚀 Release Automation

### Release Process

#### Step 1: Prepare Release

1. **Update version in `pubspec.yaml`:**
   ```yaml
   version: 1.0.0+1
   ```

2. **Update CHANGELOG.md:**
   - Move `[Unreleased]` changes to new version section
   - Add release date
   - Update comparison links at bottom

3. **Commit changes:**
   ```bash
   git add pubspec.yaml CHANGELOG.md
   git commit -m "chore: prepare v1.0.0 release"
   git push origin develop
   ```

#### Step 2: Merge to Main

```bash
# Create PR from develop to main
# After approval and merge:
git checkout main
git pull origin main
```

#### Step 3: Create Tag

```bash
# Create annotated tag
git tag -a v1.0.0 -m "Release v1.0.0"

# Push tag to trigger release workflow
git push origin v1.0.0
```

#### Step 4: Automated Release

GitHub Actions automatically:
1. ✅ Checks out code
2. ✅ Sets up Flutter and Java
3. ✅ Runs code generation
4. ✅ Builds release APK
5. ✅ Builds release App Bundle
6. ✅ Extracts changelog for v1.0.0
7. ✅ Creates GitHub release with:
   - Title: "Release v1.0.0"
   - Body: Changelog + download instructions
   - Files: APK and AAB

#### Step 5: Verify Release

1. Go to GitHub Releases page
2. Verify release was created
3. Download and test APK
4. Share release link with team

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR.MINOR.PATCH+BUILD**
- Example: `1.2.3+45`
  - `1` - Major version (breaking changes)
  - `2` - Minor version (new features)
  - `3` - Patch version (bug fixes)
  - `45` - Build number (increments with each build)

**Examples:**
- `v1.0.0` - Initial release
- `v1.1.0` - Added new features
- `v1.1.1` - Bug fixes
- `v2.0.0` - Breaking changes

---

## 🏷️ PR Automation

### Auto-labeling

PRs are automatically labeled based on:

#### 1. Files Changed (`.github/labeler.yml`)

| Files Changed | Label Applied |
|---------------|---------------|
| `lib/features/player_registration/**` | `feature: player-registration` |
| `lib/features/breathalyzer/**` | `feature: breathalyzer` |
| `lib/widgets/**` | `area: ui` |
| `lib/core/**` | `area: core` |
| `test/**` | `area: tests` |
| `*.md` | `area: docs` |
| `pubspec.yaml` | `area: dependencies` |

#### 2. Branch Name (`.github/pr-labeler.yml`)

| Branch Pattern | Label Applied |
|----------------|---------------|
| `feature/*` | `feature` |
| `fix/*` | `fix` |
| `hotfix/*` | `hotfix` |
| `refactor/*` | `refactor` |
| `docs/*` | `docs` |

### PR Template

When creating a PR, a template is automatically loaded with:
- Description section
- Type of change checklist
- Feature area checklist
- Testing checklist
- Code quality checklist
- AI persona used
- Related issues

**Location:** `.github/pull_request_template.md`

### PR Workflow

1. **Create branch:**
   ```bash
   git checkout -b feature/breathalyzer-ocr
   ```

2. **Make changes and commit:**
   ```bash
   git add .
   git commit -m "feat(breathalyzer): add OCR camera integration"
   ```

3. **Update CHANGELOG.md:**
   ```markdown
   ## [Unreleased]
   
   ### Added
   - OCR camera integration for breathalyzer readings (#XX)
   ```

4. **Push and create PR:**
   ```bash
   git push origin feature/breathalyzer-ocr
   ```

5. **Fill out PR template:**
   - ✅ Describe your changes
   - ✅ Check relevant options
   - ✅ **Optional:** Check `[x] **Build APK**` if you need to test the APK
   - ✅ Update changelog confirmation

6. **GitHub automatically:**
   - ✅ Loads PR template
   - ✅ Adds labels (`feature`, `feature: breathalyzer`)
   - ✅ Runs CI checks (format, analyze, test)
   - ✅ Builds APK only if you checked the box
   - ✅ Checks if changelog was updated

7. **Fill out PR template and request review**

8. **After approval, merge to `develop`**

---

## 📋 Quick Reference

### Common Commands

```bash
# Setup hooks
lefthook install

# Run hooks manually
lefthook run pre-commit
lefthook run pre-push

# Format code
dart format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Create and push tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### Commit Message Format

```
<type>(<scope>): <description>

Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert
Scopes: player-registration, breathalyzer, checkpoint, scoring, leaderboard, etc.

Examples:
feat(breathalyzer): add OCR camera screen
fix(scoring): correct points deduction formula
docs(readme): update installation instructions
```

### Release Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Update `CHANGELOG.md` (move Unreleased to version section)
- [ ] Commit changes: `chore: prepare vX.Y.Z release`
- [ ] Merge to `main`
- [ ] Create tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
- [ ] Push tag: `git push origin vX.Y.Z`
- [ ] Verify GitHub release was created
- [ ] Test downloaded APK

### Troubleshooting

**Problem:** Lefthook not running
```bash
# Reinstall hooks
lefthook install

# Check if hooks are installed
ls -la .git/hooks/
```

**Problem:** CI failing on format check
```bash
# Format locally
dart format .

# Commit formatted code
git add .
git commit -m "style: format code"
```

**Problem:** Changelog check failing
```bash
# Update CHANGELOG.md under [Unreleased]
vim CHANGELOG.md

# Commit changelog
git add CHANGELOG.md
git commit -m "docs: update changelog"
```

**Problem:** Release not created
```bash
# Check tag format (must be vX.Y.Z)
git tag -l

# Check GitHub Actions logs
# Go to: https://github.com/user/repo/actions
```

---

## 🎉 Benefits

### For Developers

✅ **Consistent code quality** - Automatic formatting and linting  
✅ **Catch errors early** - Pre-commit checks prevent bad commits  
✅ **Clear commit history** - Conventional commits make history readable  
✅ **Easy releases** - One command to create a release  
✅ **Automatic documentation** - Changelog extracted to releases  
✅ **Fast feedback** - CI runs on every PR  

### For Collaboration

✅ **Reduced conflicts** - Consistent formatting prevents merge conflicts  
✅ **Clear communication** - PR templates ensure complete information  
✅ **Organized PRs** - Auto-labeling makes PRs easy to filter  
✅ **Quality assurance** - CI ensures all code meets standards  
✅ **Easy onboarding** - New developers follow automated workflows  

---

## 📚 Additional Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Lefthook Documentation](https://github.com/evilmartians/lefthook)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Last Updated:** May 4, 2026  
**Maintained by:** Operación DGV Team
