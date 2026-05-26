import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/features/leaderboard/providers/leaderboard_provider.dart';

PlayerProfile _makePlayer(String id, {required int points}) {
  return PlayerProfile(
    id: id,
    name: 'Player',
    surname: id,
    photoPath: '',
    sex: Sex.male,
    bodySize: BodySize.medium,
    points: points,
    licenseImagePath: '',
  );
}

ProviderContainer _makeContainer(List<PlayerProfile> players) {
  return ProviderContainer(
    overrides: [
      playerListNotifierProvider.overrideWith(
        () => _FakePlayerListNotifier(players),
      ),
    ],
  );
}

class _FakePlayerListNotifier extends PlayerListNotifier {
  _FakePlayerListNotifier(this._players);
  final List<PlayerProfile> _players;

  @override
  Future<List<PlayerProfile>> build() async => _players;
}

void main() {
  group('sortedLeaderboardProvider', () {
    test('returns players sorted by points descending', () async {
      final players = [
        _makePlayer('a', points: 5),
        _makePlayer('b', points: 15),
        _makePlayer('c', points: 10),
      ];
      final container = _makeContainer(players);
      addTearDown(container.dispose);

      // Wait for the async notifier to complete
      await container.read(playerListNotifierProvider.future);

      final result = container.read(sortedLeaderboardProvider);

      expect(result.map((p) => p.id).toList(), equals(['b', 'c', 'a']));
    });

    test('returns empty list when no players', () async {
      final container = _makeContainer([]);
      addTearDown(container.dispose);

      await container.read(playerListNotifierProvider.future);
      final result = container.read(sortedLeaderboardProvider);
      expect(result, isEmpty);
    });

    test('single player is returned as-is', () async {
      final players = [_makePlayer('only', points: 8)];
      final container = _makeContainer(players);
      addTearDown(container.dispose);

      await container.read(playerListNotifierProvider.future);
      final result = container.read(sortedLeaderboardProvider);
      expect(result.length, equals(1));
      expect(result.first.id, equals('only'));
    });

    test('players with equal points all have same points value', () async {
      final players = [
        _makePlayer('x', points: 10),
        _makePlayer('y', points: 10),
        _makePlayer('z', points: 10),
      ];
      final container = _makeContainer(players);
      addTearDown(container.dispose);

      await container.read(playerListNotifierProvider.future);
      final result = container.read(sortedLeaderboardProvider);
      expect(result.length, equals(3));
      expect(result.map((p) => p.points).toSet(), equals({10}));
    });

    test('result is unmodifiable — mutation throws UnsupportedError', () async {
      final players = [
        _makePlayer('a', points: 5),
        _makePlayer('b', points: 15),
      ];
      final container = _makeContainer(players);
      addTearDown(container.dispose);

      await container.read(playerListNotifierProvider.future);
      final result = container.read(sortedLeaderboardProvider);
      expect(() => result.clear(), throwsUnsupportedError);
      expect(result.length, equals(2));
    });
  });
}
