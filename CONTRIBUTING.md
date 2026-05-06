# Contributing to Operación DGV

> 🚔 **Parallel Development Guide** - How to split work with your partner for maximum efficiency

---

## 📋 Quick Overview

**Operación DGV** is a mid-to-large Flutter app with complex state management, multiple interconnected features, and specific game mechanics. We recommend **parallel work** with clear boundaries to ship faster.

---

## 🎯 Recommendation: PARALLEL Work (Not Series)

### Why Parallel?

- ✅ Features are mostly independent
- ✅ Clean architectural boundaries (domain, data, presentation)
- ✅ Minimal blocking between team members
- ✅ Faster time to market

### Why Not Series?

- ❌ Slow - waiting for one person to finish before starting
- ❌ Inefficient - doesn't leverage your team
- ❌ Risk - single point of failure

---

## 👥 Suggested Work Split

### Person A: Core Infrastructure & State Management

**Responsibility:** Build the foundation that everything else depends on

**Tasks:**
- Set up Riverpod providers architecture
- Create all data models (freezed + Hive types)
- Implement Hive storage layer
- Build BAC calculator & points calculator utilities
- Create game state provider (checkpoint, round management)
- Set up theme & constants

**Why this person starts first:** These are foundational. Other features depend on them.

**Estimated time:** 3-4 days

**Deliverables:**
- `core/` folder fully implemented
- `domain/` models ready
- `data/` repository layer ready
- All providers scaffolded

---

### Person B: UI Components & Screens (in parallel)

**Responsibility:** Build all user-facing screens and components

**Tasks:**
- Build custom widgets (massive button, custom keypad, license card, etc.)
- Implement Main Menu screen
- Build Player Registration flow (all 6 screens)
- Create Leaderboard & Player Detail screens
- Build Breathalyzer entry screens (manual + OCR)
- Implement Checkpoint timer UI

**Why this can start in parallel:** Person A provides the models/providers, Person B builds UI against those interfaces.

**Estimated time:** 4-5 days

**Deliverables:**
- `widgets/` folder complete
- `features/main_menu/` complete
- `features/player_registration/` complete
- `features/leaderboard/` complete
- `features/breathalyzer/` UI complete

---

## 🔗 Dependency Map

```
Person A (Infrastructure)
├── Models & Providers
│   └── Needed by: Person B (all screens)
│   └── Needed by: Person C (game logic)
└── Hive Storage
    └── Needed by: Person C (persistence)

Person B (UI)
├── Screens & Widgets
│   └── Depends on: Person A (models, providers)
│   └── Needs: Person C (game logic providers)
└── Can work independently on UI structure

Person C (Game Logic) - Optional 3rd person
├── Title evaluation
├── Scoring logic
├── Round management
└── Depends on: Person A (models, providers)
```

---

## 📅 Timeline

### Week 1

**Day 1-2:**
- Person A builds core infrastructure (models, providers, storage)
- Person B starts UI with mock data from Person A's interfaces

**Day 3-4:**
- Person B integrates real providers from Person A
- Person A refines based on feedback

**Day 5:**
- Both refine and test integration

### Week 2

**Day 1-2:**
- Person A builds game logic (title evaluation, scoring)
- Person B polishes UI, adds animations

**Day 3-5:**
- Integration testing, bug fixes, final polish

---

## 🛡️ How to Avoid Conflicts

### 1. Define Interfaces First

Before Person B starts UI, Person A should provide:
- Model signatures (what fields each model has)
- Provider signatures (what each provider returns)
- Expected behavior documentation

**Example:**
```dart
// Person A defines this interface
@riverpod
Future<List<PlayerProfile>> playerList(Ref ref) async {
  // Implementation TBD
}

// Person B uses it immediately
class LeaderboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playerListProvider);
    // Build UI
  }
}
```

### 2. Use Feature Branches

```bash
git checkout -b feat/core-infrastructure
git checkout -b feat/ui-components
git checkout -b feat/game-logic
```

### 3. Merge Frequently (Daily)

- Person A merges to `develop` first
- Person B pulls and integrates
- Resolve conflicts early, not at the end

### 4. Mock Data During Development

Person B can mock providers while Person A builds:

```dart
// Person B's mock during development
final mockPlayers = [
  PlayerProfile(id: '1', name: 'Alice', ...),
  PlayerProfile(id: '2', name: 'Bob', ...),
];

// Swap to real provider when Person A is done
```

---

## 🔀 Git Workflow for Parallel Work

### Person A's Workflow

```bash
git checkout -b feat/core-infrastructure
# ... work on models, providers, storage ...
git add .
git commit -m "feat(core): add player models and providers"
git push -u origin feat/core-infrastructure
# Create PR, merge to develop
```

### Person B's Workflow

```bash
git checkout develop
git pull
git checkout -b feat/ui-screens
# ... work on UI, pulling Person A's changes regularly ...
git pull origin develop  # Get Person A's merged changes
git add .
git commit -m "feat(ui): add leaderboard screen"
git push -u origin feat/ui-screens
# Create PR, merge to develop
```

### Daily Sync

```bash
# Both do this daily to stay in sync
git checkout develop
git pull origin develop
git checkout your-feature-branch
git merge develop  # Integrate latest changes
```

---

## ✅ Success Criteria for Parallel Work

- ✅ Clear interface contracts (models, providers)
- ✅ Daily syncs (15 min standup)
- ✅ Frequent merges (avoid long-lived branches)
- ✅ Mock data for testing
- ✅ Automated tests to catch integration issues
- ✅ Code reviews before merging

---

## 🤝 Communication Checklist

### Before Starting

- [ ] Agree on who does what
- [ ] Define model/provider interfaces
- [ ] Set up shared branch strategy
- [ ] Schedule daily syncs

### During Development

- [ ] "I'm working on [feature]"
- [ ] "I've pushed [component], ready for review"
- [ ] "I need [data model/API] from you to proceed"
- [ ] "I'm blocked on [issue], can you help?"

### Before Merging

- [ ] All tests pass
- [ ] Code reviewed by partner
- [ ] No merge conflicts
- [ ] Documentation updated

---

## 📚 Reference

For detailed information, see:

- **`AI_INSTRUCTIONS.md`** - Complete project specification
- **`.kiro/steering/`** - Development standards and patterns
- **`.kiro/skills/`** - Flutter/Riverpod best practices
- **`ROADMAP.md`** - Project roadmap and priorities

---

## 🎉 Let's Build!

You have a solid architecture and clear separation of concerns. Go parallel, communicate daily, and ship fast. 🚔🍻
