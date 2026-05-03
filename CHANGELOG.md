# Changelog

All notable changes to the Operación DGV project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### 🎯 Planned Features
- Player registration flow with photo capture
- Manual BAC entry with custom keypad
- OCR camera integration for breathalyzer readings
- Checkpoint timer system with siren alerts
- Points calculation and penalty system
- Leaderboard with BAC progression graphs
- DGT title awards system
- Fake DGT license generation
- Final ceremony with envelope animations

---

## [0.1.0] - 2026-05-04

### 🎉 Initial Setup

#### Added
- Project initialization with Flutter 3.24.0
- Complete project documentation:
  - `AI_INSTRUCTIONS.md` - Comprehensive project specification
  - `README.md` - Quick start guide
  - `DOCUMENTATION_STRUCTURE.md` - Documentation hierarchy
  - `CLAUDE.md` and `.cursorrules` - AI assistant configuration
- Feature-first folder structure definition
- Core architecture rules (Riverpod, Hive, Freezed)
- DGT color palette and typography guidelines
- Game mechanics specifications (BAC calculations, points system)
- CI/CD automation:
  - GitHub Actions for testing and building
  - Automated PR labeling
  - Release automation with changelog extraction
  - Pre-commit hooks configuration
- Git workflow and commit conventions
- Code quality standards (linting, formatting, testing)

#### Documentation
- Defined 7 major features with detailed specifications
- Created AI agent personas for specialized tasks
- Established drunk-proof UI/UX principles
- Documented Widmark formula for BAC calculations
- Outlined 4-phase project milestones

---

## Version Format

### Types of Changes
- **Added** - New features
- **Changed** - Changes in existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Vulnerability fixes

### Version Numbers
- **MAJOR** - Incompatible API changes
- **MINOR** - New functionality (backwards-compatible)
- **PATCH** - Bug fixes (backwards-compatible)

---

## How to Update This Changelog

When working on a feature:

1. Add your changes under `[Unreleased]` section
2. Use the appropriate category (Added, Changed, Fixed, etc.)
3. Write clear, user-focused descriptions
4. Reference PR numbers: `(#123)`

Example:
```markdown
## [Unreleased]

### Added
- Player registration screen with avatar selection (#45)
- Custom keypad widget for BAC entry (#47)

### Fixed
- Points calculation for negative BAC deltas (#52)
```

When releasing a version:

1. Move `[Unreleased]` changes to a new version section
2. Add the release date
3. Create a git tag: `git tag -a v1.0.0 -m "Release v1.0.0"`
4. Push the tag: `git push origin v1.0.0`
5. GitHub Actions will automatically create a release

---

[Unreleased]: https://github.com/yourusername/dgv/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/yourusername/dgv/releases/tag/v0.1.0
