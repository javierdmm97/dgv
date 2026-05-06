# Contributing to Operación DGV

> 📚 **Documentation Navigation:** [README](README.md) | [Development Guide](docs/DEVELOPMENT.md) | [Automation Guide](docs/AUTOMATION.md)
>
> This is the entry point for contributors. For detailed setup, workflow, coding standards, and testing information, see the [Development Guide](docs/DEVELOPMENT.md). For CI/CD, git hooks, and release processes, see the [Automation Guide](docs/AUTOMATION.md).

Thank you for your interest in contributing to Operación DGV! This document provides guidelines and instructions for contributing to the project.

---

## 📋 Table of Contents

1. [Getting Started](#getting-started)
2. [Development Workflow](#development-workflow)
3. [Coding Standards](#coding-standards)
4. [Commit Convention](#commit-convention)
5. [Pull Request Process](#pull-request-process)
6. [Testing Requirements](#testing-requirements)
7. [Automation](#automation)
8. [Documentation](#documentation)

---

## 🚀 Getting Started

### Prerequisites

You'll need Flutter 3.10+, Dart 3.0+, Git, and an IDE with Flutter extensions.

**For complete setup instructions, see: [Setup Guide](docs/DEVELOPMENT.md#quick-setup)**

### Quick Start

```bash
# Clone and setup
git clone https://github.com/yourusername/dgv.git
cd dgv
flutter pub get
lefthook install
dart run build_runner build -d
```

**For detailed setup and verification, see: [Setup Guide](docs/DEVELOPMENT.md#quick-setup)**

### Read the Documentation

Before contributing, please read:

1. **[`AI_INSTRUCTIONS.md`](./AI_INSTRUCTIONS.md)** - Complete project specification
2. **[`.claude/skills/`](./.claude/skills/)** - Flutter/Riverpod best practices
3. **[`ROADMAP.md`](./ROADMAP.md)** - Project roadmap and current priorities

---

## 🔄 Development Workflow

### Branch Strategy

We use Git Flow with `main` (production), `develop` (integration), and feature branches (`feature/*`, `fix/*`, `refactor/*`, `docs/*`).

**For complete branch strategy and workflow, see: [Git Workflow](docs/DEVELOPMENT.md#git-workflow)**

### Daily Workflow

1. Branch from `develop`
2. Make your changes
3. Test and format your code
4. Commit using conventional commits
5. Push and create a PR

**For detailed daily workflow, see: [Daily Workflow](docs/DEVELOPMENT.md#daily-workflow)**

---

## 📝 Coding Standards

We follow strict coding standards to maintain consistency and quality across the codebase.

### Key Standards

- **State Management:** Riverpod only
- **Models:** Freezed for immutable data classes
- **Storage:** Hive for local storage
- **Code Style:** Run `dart format .` before committing
- **UI/UX:** Touch targets minimum 80px, no native keyboards for numbers

**For complete coding standards and examples, see: [Coding Standards](docs/DEVELOPMENT.md#coding-standards)**

---

## 💬 Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/).

### Commit Format

```text
<type>(<scope>): <description>
```

**Common types:** feat, fix, docs, style, refactor, test, chore

**Examples:**
```bash
feat(breathalyzer): add OCR camera screen
fix(scoring): correct points deduction formula
docs(readme): update installation instructions
```

**For complete commit convention guide, see: [Commit Convention](docs/DEVELOPMENT.md#commit-convention)**

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

### Testing Overview

- **Minimum:** 80% code coverage for core logic
- **Required:** Unit tests for utilities, widget tests for components, integration tests for flows

**For complete testing guide and examples, see: [Testing](docs/DEVELOPMENT.md#testing)**

---

## ⚙️ Automation

Our project uses automated workflows for quality assurance:

- **Git Hooks:** Pre-commit checks for formatting and analysis - [Details](docs/AUTOMATION.md#git-hooks-lefthook)
- **CI/CD:** Automated testing and building on PRs - [Details](docs/AUTOMATION.md#github-actions)
- **Releases:** Automated release creation from tags - [Details](docs/AUTOMATION.md#release-automation)

---

## 📚 Documentation

### When to Update Documentation

- Adding a new feature → Update `AI_INSTRUCTIONS.md` and `README.md`
- Changing architecture → Update `AI_INSTRUCTIONS.md` and `docs/DEVELOPMENT.md`
- Changing checkpoint system → Update `AI_INSTRUCTIONS.md`, `docs/DEVELOPMENT.md`, and `CLAUDE.md`
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
