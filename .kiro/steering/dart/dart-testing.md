---
name: Dart/Flutter Testing
inclusion: fileMatch
fileMatchPattern: "**/*.dart"
description: Dart and Flutter testing standards
---

# Dart/Flutter Testing

## Test Framework

- **flutter_test** / **dart:test** — built-in test runner
- **mockito** (with `@GenerateMocks`) or **mocktail** (no codegen) for mocking
- **bloc_test** for BLoC/Cubit unit tests
- **fake_async** for controlling time in unit tests
- **integration_test** for end-to-end device tests

## Test Types

| Type | Tool | Location | When to Write |
|------|------|----------|---------------|
| Unit | `dart:test` | `test/unit/` | All domain logic, state managers, repositories |
| Widget | `flutter_test` | `test/widget/` | All widgets with meaningful behavior |
| Golden | `flutter_test` | `test/golden/` | Design-critical UI components |
| Integration | `integration_test` | `integration_test/` | Critical user flows on real device/emulator |

## Unit Tests: State Managers

### BLoC with `bloc_test`

```dart
group('CartBloc', () {
  late CartBloc bloc;
  late MockCartRepository repository;

  setUp(() {
    repository = MockCartRepository();
    bloc = CartBloc(repository);
  });

  tearDown(() => bloc.close());

  blocTest<CartBloc, CartState>(
    'emits updated items when CartItemAdded',
    build: () => bloc,
    act: (b) => b.add(CartItemAdded(testItem)),
    expect: () => [CartState(items: [testItem])],
  );
});
```

### Riverpod with `ProviderContainer`

```dart
test('usersProvider loads users from repository', () async {
  final container = ProviderContainer(
    overrides: [userRepositoryProvider.overrideWithValue(FakeUserRepository())],
  );
  addTearDown(container.dispose);

  final result = await container.read(usersProvider.future);
  expect(result, isNotEmpty);
});
```

## Widget Tests

```dart
testWidgets('CartPage shows item count badge', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cartNotifierProvider.overrideWith(() => FakeCartNotifier([testItem])),
      ],
      child: const MaterialApp(home: CartPage()),
    ),
  );

  await tester.pump();
  expect(find.text('1'), findsOneWidget);
  expect(find.byType(CartItemTile), findsOneWidget);
});
```

## Fakes Over Mocks

Prefer hand-written fakes for complex dependencies:

```dart
class FakeUserRepository implements UserRepository {
  final _users = <String, User>{};
  Object? fetchError;

  @override
  Future<User?> getById(String id) async {
    if (fetchError != null) throw fetchError!;
    return _users[id];
  }

  @override
  Future<void> save(User user) async {
    _users[user.id] = user;
  }

  void addUser(User user) => _users[user.id] = user;
}
```

## Async Testing

```dart
// Use fake_async for controlling timers and Futures
test('debounce triggers after 300ms', () {
  fakeAsync((async) {
    final debouncer = Debouncer(delay: const Duration(milliseconds: 300));
    var callCount = 0;
    debouncer.run(() => callCount++);
    expect(callCount, 0);
    async.elapse(const Duration(milliseconds: 200));
    expect(callCount, 0);
    async.elapse(const Duration(milliseconds: 200));
    expect(callCount, 1);
  });
});
```

## Test Organization

```
test/
├── unit/
│   ├── domain/
│   │   └── usecases/
│   └── data/
│       └── repositories/
├── widget/
│   └── presentation/
│       └── pages/
└── golden/
    └── widgets/

integration_test/
└── flows/
    ├── login_flow_test.dart
    └── checkout_flow_test.dart
```

## Coverage

- Target 80%+ line coverage for business logic (domain + state managers)
- All state transitions must have tests: loading → success, loading → error, retry
- Run `flutter test --coverage` and inspect `lcov.info` with a coverage reporter
- Coverage failures should block CI when below threshold

---

**Reference:** `.claude/rules/dart/testing.md`
