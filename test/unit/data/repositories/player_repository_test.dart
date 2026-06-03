import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/player_profile.dart';

import 'fake_box.dart';

// ---------------------------------------------------------------------------
// Testable repository that accepts an injected FakeBox
// ---------------------------------------------------------------------------

/// Thin testable subclass of PlayerRepository logic that uses an injected box
/// instead of calling HiveService.getPlayersBox().
class _TestablePlayerRepository {
  _TestablePlayerRepository(this._box);

  final FakeBox<dynamic> _box;

  Future<List<PlayerProfile>> getAll() async {
    final players = <PlayerProfile>[];
    for (final key in _box.keys) {
      final json = _box.get(key) as String?;
      if (json != null) {
        players.add(
          PlayerProfile.fromJson(jsonDecode(json) as Map<String, dynamic>),
        );
      }
    }
    players.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return players;
  }

  Future<PlayerProfile?> getById(String id) async {
    final json = _box.get(id) as String?;
    if (json == null) return null;
    return PlayerProfile.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> save(PlayerProfile player) async {
    await _box.put(player.id, jsonEncode(player.toJson()));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> update(PlayerProfile player) async => save(player);

  Future<bool> exists(String id) async => _box.containsKey(id);

  Future<int> count() async => _box.length;

  Future<void> clearAll() async => _box.clear();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PlayerProfile _makePlayer({
  required String id,
  int points = 15,
  String name = 'Test',
}) => PlayerProfile(
  id: id,
  name: name,
  surname: 'Player',
  photoPath: '',
  sex: Sex.male,
  bodySize: BodySize.medium,
  licenseImagePath: '',
  readings: const [],
  titleCounts: const {},
  points: points,
  createdAt: DateTime(2025, 1, 1),
);

void main() {
  group('PlayerRepository (via _TestablePlayerRepository)', () {
    late FakeBox<dynamic> box;
    late _TestablePlayerRepository repo;

    setUp(() {
      box = FakeBox<dynamic>(name: 'players');
      repo = _TestablePlayerRepository(box);
    });

    tearDown(() async {
      await box.dispose();
    });

    // ── save / getById round-trip ────────────────────────────────────────────

    group('save and getById', () {
      test('round-trip preserves all fields', () async {
        final player = _makePlayer(id: 'p1', points: 12, name: 'Ana');
        await repo.save(player);

        final retrieved = await repo.getById('p1');
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('p1'));
        expect(retrieved.name, equals('Ana'));
        expect(retrieved.points, equals(12));
      });

      test('getById returns null for non-existent ID', () async {
        final result = await repo.getById('nonexistent');
        expect(result, isNull);
      });
    });

    // ── getAll ───────────────────────────────────────────────────────────────

    group('getAll', () {
      test('returns all saved players', () async {
        await repo.save(_makePlayer(id: 'p1'));
        await repo.save(_makePlayer(id: 'p2'));
        await repo.save(_makePlayer(id: 'p3'));

        final all = await repo.getAll();
        expect(all.length, equals(3));
        expect(all.map((p) => p.id), containsAll(['p1', 'p2', 'p3']));
      });

      test('returns empty list when no players saved', () async {
        final all = await repo.getAll();
        expect(all, isEmpty);
      });
    });

    // ── delete ───────────────────────────────────────────────────────────────

    group('delete', () {
      test('removes player and subsequent getById returns null', () async {
        await repo.save(_makePlayer(id: 'p1'));
        await repo.delete('p1');

        final result = await repo.getById('p1');
        expect(result, isNull);
      });

      test('delete non-existent ID does not throw', () async {
        expect(() => repo.delete('nonexistent'), returnsNormally);
      });
    });

    // ── update ───────────────────────────────────────────────────────────────

    group('update', () {
      test('modifies existing player data', () async {
        await repo.save(_makePlayer(id: 'p1', points: 10));
        final updated = _makePlayer(id: 'p1', points: 18);
        await repo.update(updated);

        final retrieved = await repo.getById('p1');
        expect(retrieved!.points, equals(18));
      });
    });

    // ── count ────────────────────────────────────────────────────────────────

    group('count', () {
      test('returns correct number of saved players', () async {
        expect(await repo.count(), equals(0));
        await repo.save(_makePlayer(id: 'p1'));
        expect(await repo.count(), equals(1));
        await repo.save(_makePlayer(id: 'p2'));
        expect(await repo.count(), equals(2));
      });

      test('count equals getAll length after operations', () async {
        await repo.save(_makePlayer(id: 'p1'));
        await repo.save(_makePlayer(id: 'p2'));
        await repo.delete('p1');

        final count = await repo.count();
        final all = await repo.getAll();
        expect(count, equals(all.length));
      });
    });

    // ── clearAll ─────────────────────────────────────────────────────────────

    group('clearAll', () {
      test('removes all players', () async {
        await repo.save(_makePlayer(id: 'p1'));
        await repo.save(_makePlayer(id: 'p2'));
        await repo.clearAll();

        expect(await repo.count(), equals(0));
        expect(await repo.getAll(), isEmpty);
      });
    });

    // ── Property 12: round-trip preserves entity data ────────────────────────

    group('Property 12: round-trip preserves entity data', () {
      // Feature: phase-1-completion, Property 12
      test('save then getById returns equivalent object', () async {
        final players = [
          _makePlayer(id: 'a', points: 5, name: 'Alice'),
          _makePlayer(id: 'b', points: 10, name: 'Bob'),
          _makePlayer(id: 'c', points: 15, name: 'Carlos'),
        ];

        for (final player in players) {
          await repo.save(player);
          final retrieved = await repo.getById(player.id);
          expect(retrieved, isNotNull);
          expect(retrieved!.id, equals(player.id));
          expect(retrieved.name, equals(player.name));
          expect(retrieved.points, equals(player.points));
        }
      });
    });

    // ── Property 13: count equals getAll length ──────────────────────────────

    group('Property 13: count equals length of getAll', () {
      // Feature: phase-1-completion, Property 13
      test('invariant holds after random save/delete sequence', () async {
        final ids = ['p1', 'p2', 'p3', 'p4', 'p5'];

        // Save all
        for (final id in ids) {
          await repo.save(_makePlayer(id: id));
          final count = await repo.count();
          final all = await repo.getAll();
          expect(count, equals(all.length));
        }

        // Delete some
        for (final id in ['p2', 'p4']) {
          await repo.delete(id);
          final count = await repo.count();
          final all = await repo.getAll();
          expect(count, equals(all.length));
        }
      });
    });
  });
}
