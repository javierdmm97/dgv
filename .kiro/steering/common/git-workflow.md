---
name: Git Workflow
inclusion: auto
description: Git commit and PR standards
---

# Git Workflow

## Commit Message Format

```
<type>: <description>

<optional body>
```

### Types
- **feat** - New feature
- **fix** - Bug fix
- **refactor** - Code refactoring (no feature change)
- **docs** - Documentation changes
- **test** - Adding or updating tests
- **chore** - Maintenance tasks (dependencies, build config)
- **perf** - Performance improvements
- **ci** - CI/CD changes
- **style** - Code style changes (formatting, no logic change)

### Examples

```bash
feat(breathalyzer): add OCR camera screen
fix(scoring): correct points deduction formula
docs(readme): update installation instructions
refactor(ui): extract massive button widget
test(calculator): add BAC calculation edge cases
chore(deps): update riverpod to 2.4.0
```

## Pull Request Workflow

When creating PRs:

1. Analyze full commit history (not just latest commit)
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Draft comprehensive PR summary
4. Include test plan with TODOs
5. Push with `-u` flag if new branch

### PR Requirements

- ✅ All CI checks pass (format, analyze, test, build)
- ✅ At least 1 approval from a team member
- ✅ No merge conflicts with `develop`
- ✅ Changelog updated
- ✅ Documentation updated (if needed)

---

**Reference:** `.claude/rules/common/git-workflow.md`
