---
name: Testing Requirements
inclusion: auto
description: Minimum test coverage and TDD workflow
---

# Testing Requirements

## Minimum Test Coverage: 80%

Test Types (ALL required):

1. **Unit Tests** - Individual functions, utilities, components
2. **Integration Tests** - API endpoints, database operations
3. **E2E Tests** - Critical user flows (framework chosen per language)

## Test-Driven Development

MANDATORY workflow:

1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## Edge Cases You MUST Test

1. **Null/Undefined** input
2. **Empty** arrays/strings
3. **Invalid types** passed
4. **Boundary values** (min/max)
5. **Error paths** (network failures, DB errors)
6. **Race conditions** (concurrent operations)
7. **Large data** (performance with 10k+ items)
8. **Special characters** (Unicode, emojis, SQL chars)

## Test Anti-Patterns to Avoid

- Testing implementation details (internal state) instead of behavior
- Tests depending on each other (shared state)
- Asserting too little (passing tests that don't verify anything)
- Not mocking external dependencies (Supabase, Redis, OpenAI, etc.)

## Quality Checklist

- [ ] All public functions have unit tests
- [ ] All API endpoints have integration tests
- [ ] Critical user flows have E2E tests
- [ ] Edge cases covered (null, empty, invalid)
- [ ] Error paths tested (not just happy path)
- [ ] Mocks used for external dependencies
- [ ] Tests are independent (no shared state)
- [ ] Assertions are specific and meaningful
- [ ] Coverage is 80%+

## Test Structure (AAA Pattern)

Prefer Arrange-Act-Assert structure for tests:

```dart
test('calculates similarity correctly', () {
  // Arrange
  final vector1 = [1, 0, 0]
  final vector2 = [0, 1, 0]

  // Act
  final similarity = calculateCosineSimilarity(vector1, vector2)

  // Assert
  expect(similarity).toBe(0)
})
```

## Test Naming

Use descriptive names that explain the behavior under test:

```dart
test('returns empty array when no markets match query', () {})
test('throws error when API key is missing', () {})
test('falls back to substring search when Redis is unavailable', () {})
```

---

**Reference:** `.claude/rules/common/testing.md`
