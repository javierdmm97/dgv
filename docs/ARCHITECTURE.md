# 📁 Project Structure Overview

Complete file structure for Operación DGV with automation setup.

---

## 🗂️ Root Directory

```
dgv/
├── 📚 Documentation (13 files)
│   ├── AI_INSTRUCTIONS.md              ⭐ Project specification (read first)
│   ├── README.md                       ⭐ Quick start guide
│   ├── ROADMAP.md                      📅 Development plan (4 phases)
│   ├── CHANGELOG.md                    📝 Version history
│   ├── CONTRIBUTING.md                 🤝 Contribution guidelines
│   ├── DOCUMENTATION_STRUCTURE.md      📖 How docs fit together
│   ├── AUTOMATION_GUIDE.md             🤖 CI/CD and automation
│   ├── SETUP_COMPLETE.md               🚀 GitHub push guide
│   ├── HUMAN_SUMMARY.md                ✨ Setup summary
│   ├── PRE_PUSH_CHECKLIST.md           ✅ Pre-push verification
│   ├── QUICK_REFERENCE.md              🎯 Command reference
│   ├── PROJECT_STRUCTURE.md            📁 This file
│   └── CLAUDE.md                       🤖 Claude AI config
│
├── 🤖 GitHub Automation (.github/)
│   ├── workflows/
│   │   ├── ci.yml                      ✅ CI pipeline
│   │   ├── release.yml                 🚀 Release automation
│   │   ├── pr-labeler.yml              🏷️ Auto-label PRs
│   │   └── changelog-check.yml         📝 Changelog validation
│   │
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md               🐛 Bug report template
│   │   └── feature_request.md          ✨ Feature request template
│   │
│   ├── pull_request_template.md        📋 PR template
│   ├── labeler.yml                     🏷️ File-based labels
│   └── pr-labeler.yml                  🏷️ Branch-based labels
│
├── 🪝 Git Hooks
│   └── lefthook.yml                    🔧 Pre-commit, commit-msg, pre-push
│
├── 🛠️ Setup Scripts
│   ├── setup.sh                        🐧 Linux/macOS setup
│   └── setup.ps1                       🪟 Windows setup
│
├── ⚙️ Configuration
│   ├── .cursorrules                    🤖 Cursor AI config
│   ├── .gitignore                      🚫 Git exclusions
│   ├── analysis_options.yaml           🔍 Dart analyzer config
│   └── pubspec.yaml                    📦 Flutter dependencies
│
├── 📖 AI Skills (.claude/)
│   └── skills/
│       ├── dart-flutter-patterns/      🎨 Flutter best practices
│       └── flutter-dart-code-review/   ✅ Code review checklist
│
├── 📱 Flutter App (lib/)
│   ├── main.dart                       🚀 App entry point
│   ├── core/                           🎨 Shared resources
│   ├── widgets/                        🧩 Reusable components
│   └── features/                       🎮 Feature modules
│
├── 🧪 Tests (test/)
│   └── (to be created)
│
├── 🤖 Android (android/)
│   └── (Flutter generated)
│
└── 🍎 iOS (ios/)
    └── (Flutter generated)
```

---

## 📚 Documentation Files Explained

### Essential Reading (Start Here)

| File | Purpose | Read When |
|------|---------|-----------|
| **`HUMAN_SUMMARY.md`** | Quick overview of setup | First (you are here) |
| **`AI_INSTRUCTIONS.md`** | Complete project spec | Before coding |
| **`README.md`** | Quick start guide | Getting started |
| **`QUICK_REFERENCE.md`** | Command cheat sheet | During development |

### Setup & Workflow

| File | Purpose | Read When |
|------|---------|-----------|
| **`SETUP_COMPLETE.md`** | GitHub push instructions | Before first push |
| **`PRE_PUSH_CHECKLIST.md`** | Verification checklist | Before first push |
| **`CONTRIBUTING.md`** | Contribution workflow | Before first PR |
| **`AUTOMATION_GUIDE.md`** | CI/CD deep dive | Understanding automation |

### Planning & Tracking

| File | Purpose | Read When |
|------|---------|-----------|
| **`ROADMAP.md`** | Development plan | Planning work |
| **`CHANGELOG.md`** | Version history | Before releases |
| **`PROJECT_STRUCTURE.md`** | This file | Understanding structure |

### AI Configuration

| File | Purpose | Read When |
|------|---------|-----------|
| **`CLAUDE.md`** | Claude AI config | Using Claude Web |
| **`.cursorrules`** | Cursor AI config | Using Cursor IDE |
| **`DOCUMENTATION_STRUCTURE.md`** | How AIs use docs | Understanding AI workflow |

---

## 🤖 GitHub Automation Files

### Workflows (`.github/workflows/`)

| File | Trigger | Purpose |
|------|---------|---------|
| **`ci.yml`** | PR to develop/main | Format, analyze, test, build |
| **`release.yml`** | Tag push (v*.*.*) | Build release, create GitHub release |
| **`pr-labeler.yml`** | PR opened | Auto-label based on files/branch |
| **`changelog-check.yml`** | PR to develop/main | Ensure changelog updated |

### Templates (`.github/`)

| File | Purpose |
|------|---------|
| **`pull_request_template.md`** | PR template with checklist |
| **`ISSUE_TEMPLATE/bug_report.md`** | Bug report structure |
| **`ISSUE_TEMPLATE/feature_request.md`** | Feature request structure |

### Configuration (`.github/`)

| File | Purpose |
|------|---------|
| **`labeler.yml`** | File-based PR labeling rules |
| **`pr-labeler.yml`** | Branch-based PR labeling rules |

---

## 🪝 Git Hooks (lefthook.yml)

| Hook | When | Action |
|------|------|--------|
| **pre-commit** | Before commit | Format code, run analyze |
| **commit-msg** | After commit message | Validate conventional format |
| **pre-push** | Before push | Run all tests |

---

## 📱 Flutter App Structure (lib/)

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp configuration
│
├── core/                              # Shared resources
│   ├── theme/
│   │   ├── dgt_colors.dart           # DGT color palette
│   │   ├── dgt_typography.dart       # Typography system
│   │   └── dgt_theme.dart            # ThemeData config
│   │
│   ├── constants/
│   │   ├── app_constants.dart        # BAC limits, point values
│   │   ├── asset_paths.dart          # Asset paths
│   │   └── dgt_strings.dart          # Spanish strings
│   │
│   ├── utils/
│   │   ├── bac_calculator.dart       # Widmark formula
│   │   ├── points_calculator.dart    # Points deduction logic
│   │   └── title_evaluator.dart      # DGT title awards
│   │
│   └── models/
│       ├── player_profile.dart       # Player data model
│       ├── bac_reading.dart          # BAC reading model
│       └── achievement.dart          # Achievement model
│
├── widgets/                           # Reusable UI components
│   ├── massive_button.dart           # Oversized button
│   ├── custom_keypad.dart            # Drunk-proof keypad
│   ├── dgt_avatar.dart               # Player avatar
│   ├── license_card.dart             # License card
│   └── siren_animation.dart          # Siren effect
│
└── features/                          # Feature modules
    │
    ├── onboarding/                    # App intro
    │   ├── presentation/
    │   │   ├── onboarding_screen.dart
    │   │   └── widgets/
    │   └── providers/
    │       └── onboarding_provider.dart
    │
    ├── player_registration/           # Player setup
    │   ├── data/
    │   │   ├── player_repository.dart
    │   │   └── hive_player_datasource.dart
    │   ├── domain/
    │   │   └── models/
    │   │       └── player.dart
    │   ├── presentation/
    │   │   ├── registration_screen.dart
    │   │   ├── avatar_selection_screen.dart
    │   │   ├── photo_capture_screen.dart
    │   │   └── widgets/
    │   └── providers/
    │       ├── player_list_provider.dart
    │       └── registration_form_provider.dart
    │
    ├── breathalyzer/                  # BAC entry
    │   ├── data/
    │   │   ├── bac_repository.dart
    │   │   └── ocr_service.dart
    │   ├── presentation/
    │   │   ├── manual_entry_screen.dart
    │   │   ├── camera_ocr_screen.dart
    │   │   ├── round_robin_screen.dart
    │   │   └── widgets/
    │   └── providers/
    │       ├── bac_entry_provider.dart
    │       └── ocr_provider.dart
    │
    ├── checkpoint/                    # Round management
    │   ├── presentation/
    │   │   ├── checkpoint_screen.dart
    │   │   ├── shot_clock_widget.dart
    │   │   └── siren_alert_screen.dart
    │   └── providers/
    │       ├── checkpoint_timer_provider.dart
    │       └── round_manager_provider.dart
    │
    ├── scoring/                       # Points calculation
    │   ├── domain/
    │   │   ├── points_engine.dart
    │   │   └── penalty_rules.dart
    │   └── providers/
    │       └── scoring_provider.dart
    │
    ├── leaderboard/                   # Rankings
    │   ├── presentation/
    │   │   ├── leaderboard_screen.dart
    │   │   ├── player_detail_screen.dart
    │   │   └── widgets/
    │   │       ├── points_card.dart
    │   │       └── bac_graph.dart
    │   └── providers/
    │       └── leaderboard_provider.dart
    │
    ├── achievements/                  # DGT titles
    │   ├── domain/
    │   │   └── title_definitions.dart
    │   ├── presentation/
    │   │   ├── achievements_screen.dart
    │   │   └── title_award_animation.dart
    │   └── providers/
    │       └── achievements_provider.dart
    │
    └── fake_id/                       # License generation
        ├── presentation/
        │   ├── id_generator_screen.dart
        │   ├── final_ceremony_screen.dart
        │   └── widgets/
        │       ├── fake_license_card.dart
        │       └── envelope_animation.dart
        └── providers/
            └── id_generator_provider.dart
```

---

## 🧪 Test Structure (test/)

```
test/
├── core/
│   ├── utils/
│   │   ├── bac_calculator_test.dart
│   │   ├── points_calculator_test.dart
│   │   └── title_evaluator_test.dart
│   └── models/
│       ├── player_profile_test.dart
│       ├── bac_reading_test.dart
│       └── achievement_test.dart
│
├── widgets/
│   ├── massive_button_test.dart
│   ├── custom_keypad_test.dart
│   └── dgt_avatar_test.dart
│
└── features/
    ├── player_registration/
    │   ├── player_repository_test.dart
    │   └── registration_flow_test.dart
    │
    ├── breathalyzer/
    │   ├── bac_entry_test.dart
    │   └── ocr_service_test.dart
    │
    └── (other features)
```

---

## 📊 File Count Summary

| Category | Count | Purpose |
|----------|-------|---------|
| **Documentation** | 13 | Project specs, guides, references |
| **GitHub Workflows** | 4 | CI/CD automation |
| **GitHub Templates** | 3 | PR and issue templates |
| **GitHub Config** | 2 | Labeling rules |
| **Git Hooks** | 1 | Pre-commit, commit-msg, pre-push |
| **Setup Scripts** | 2 | Automated setup (Linux/macOS/Windows) |
| **AI Config** | 2 | Claude and Cursor configuration |
| **AI Skills** | 2 | Flutter patterns and code review |
| **Flutter Config** | 3 | pubspec, analysis_options, .gitignore |

**Total:** 32 configuration and documentation files

---

## 🎯 Quick Navigation

### I want to...

**Understand the project:**
→ Read `AI_INSTRUCTIONS.md`

**Get started quickly:**
→ Read `README.md` and run `setup.sh`/`setup.ps1`

**Push to GitHub:**
→ Follow `SETUP_COMPLETE.md` and `PRE_PUSH_CHECKLIST.md`

**Learn the workflow:**
→ Read `CONTRIBUTING.md`

**See what to build:**
→ Check `ROADMAP.md`

**Find a command:**
→ Check `QUICK_REFERENCE.md`

**Understand automation:**
→ Read `AUTOMATION_GUIDE.md`

**Configure my AI:**
→ See `CLAUDE.md` or `.cursorrules`

**Track changes:**
→ Update `CHANGELOG.md`

---

## 🚀 Next Steps

1. ✅ Review this structure
2. ✅ Read `HUMAN_SUMMARY.md`
3. ✅ Read `AI_INSTRUCTIONS.md`
4. ✅ Follow `SETUP_COMPLETE.md` to push to GitHub
5. ✅ Start Phase 1 from `ROADMAP.md`

---

**Last Updated:** May 4, 2026  
**Total Files Created:** 32 configuration and documentation files  
**Status:** ✅ Ready to push to GitHub
