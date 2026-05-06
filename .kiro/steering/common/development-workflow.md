---
name: Development Workflow
inclusion: auto
description: Feature implementation workflow from research to commit
---

# Development Workflow

## Feature Implementation Workflow

### 0. Research & Reuse (MANDATORY FIRST)

Before writing ANY new code:

1. **GitHub code search first** - Find existing implementations, templates, patterns
2. **Library docs second** - Confirm API behavior, package usage, version details
3. **Package registries** - Search npm, PyPI, crates.io before writing utility code
4. **Exa only when necessary** - Use for broader web research after GitHub and docs
5. **Prefer adopting proven approaches** - Fork, port, or wrap existing solutions over net-new code

### 1. Plan First

- Use **planner** agent to create implementation plan
- Generate planning docs: PRD, architecture, system_design, tech_doc, task_list
- Identify dependencies and risks
- Break down into phases

**Plan Format:**
- Overview (2-3 sentences)
- Requirements (bulleted list)
- Architecture changes (file paths + descriptions)
- Implementation steps (phases with specific actions)
- Testing strategy (unit, integration, E2E)
- Risks & mitigations
- Success criteria

### 2. TDD Approach

- Use **tdd-guide** agent
- Write tests first (RED)
- Implement to pass tests (GREEN)
- Refactor (IMPROVE)
- Verify 80%+ coverage

### 3. Code Review

- Use **code-reviewer** agent immediately after writing code
- Address CRITICAL and HIGH issues
- Fix MEDIUM issues when possible

### 4. Commit & Push

- Detailed commit messages
- Follow conventional commits format
- See git-workflow.md for commit message format and PR process

### 5. Pre-Review Checks

- Verify all automated checks (CI/CD) are passing
- Resolve any merge conflicts
- Ensure branch is up to date with target branch
- Only request review after these checks pass

---

**Reference:** `.claude/rules/common/development-workflow.md`
