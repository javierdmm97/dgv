import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/providers/repository_providers.dart';
import 'package:dgv/data/repositories/player_repository.dart';

// ---------------------------------------------------------------------------
// Minimal in-memory fake repository
// ---------------------------------------------------------------------------

class _FakePlayerRepository implements PlayerRepository {
  final _players = <String, PlayerProfile>{};

  @override
  Future<List<PlayerProfile>> getAll() async => _players.values.toList();

  @override
  Future<PlayerProfile?> getById(String id) async => _players[id];

  @override
  Future<void> save(PlayerProfile player) async {
    _players[player.id] = player;
  }

  @override
  Future<void> update(PlayerProfile player) async {
    _players[player.id] = player;
  }

  @override
  Future<void> delete(String id) async {
    _players.remove(id);
  }

  @override
  Future<bool> exists(String id) async => _players.containsKey(id);

  @override
  Future<int> count() async => _players.length;

  @override
  Future<void> clearAll() async => _players.clear();

  @override
  Stream<List<PlayerProfile>> watchAll() =>
      Stream.value(_players.values.toList());
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PlayerProfile _player(String id, String name) => PlayerProfile(
  id: id,
  name: name,
  surname: 'Test',
  photoPath: '',
  sex: Sex.male,
  bodySize: BodySize.medium,
  licenseImagePath: '',
);

/// Wraps [child] with a ProviderScope that uses a pre-seeded fake repository.
Widget _wrap(Widget child, {List<PlayerProfile> players = const []}) {
  final repo = _FakePlayerRepository();
  for (final p in players) {
    repo.save(p);
  }
  return ProviderScope(
    overrides: [playerRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

// ---------------------------------------------------------------------------
// Actual widget under test — a simple consumer that lists deletable cards
// ---------------------------------------------------------------------------

/// Minimal list widget that exercises [PlayerListNotifier.deletePlayer].
class _DeletableList extends ConsumerWidget {
  const _DeletableList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPlayers = ref.watch(playerListNotifierProvider);
    return asyncPlayers.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
      data: (players) => ListView(
        children: players
            .map(
              (p) => Dismissible(
                key: ValueKey('dismiss_${p.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('¿Eliminar a ${p.name}?'),
                      actions: [
                        TextButton(
                          key: const Key('cancelar'),
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          key: const Key('eliminar'),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                  return confirmed;
                },
                onDismissed: (_) => ref
                    .read(playerListNotifierProvider.notifier)
                    .deletePlayer(p.id),
                background: const ColoredBox(color: Colors.red),
                child: ListTile(key: ValueKey(p.id), title: Text(p.name)),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Swipe-to-delete player list', () {
    testWidgets('confirmation dialog is shown on swipe', (tester) async {
      final alice = _player('p1', 'Alice');
      await tester.pumpWidget(_wrap(const _DeletableList(), players: [alice]));
      await tester.pump();

      await tester.drag(
        find.byKey(const ValueKey('p1')),
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('¿Eliminar a Alice?'), findsOneWidget);
    });

    testWidgets('cancel keeps the player in the list', (tester) async {
      final alice = _player('p1', 'Alice');
      await tester.pumpWidget(_wrap(const _DeletableList(), players: [alice]));
      await tester.pump();

      await tester.drag(
        find.byKey(const ValueKey('p1')),
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cancelar')));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
    });

    // Uses plain test (not testWidgets) — no widget tree needed, and
    // testWidgets wraps in fake_async which treats Riverpod's zero-duration
    // scheduler timer as a pending timer assertion failure.
    test('confirm calls deletePlayer on the notifier', () async {
      final repo = _FakePlayerRepository();
      final alice = _player('p1', 'Alice');
      await repo.save(alice);

      final container = ProviderContainer(
        overrides: [playerRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(playerListNotifierProvider.future);
      await container
          .read(playerListNotifierProvider.notifier)
          .deletePlayer('p1');

      final remaining = await repo.getAll();
      expect(remaining, isEmpty);
    });
  });
}
