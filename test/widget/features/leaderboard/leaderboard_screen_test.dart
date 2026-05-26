import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:dgv/features/leaderboard/providers/leaderboard_provider.dart';
import 'package:dgv/widgets/license_card.dart';

PlayerProfile _makePlayer(String id, String name, {int points = 10}) {
  return PlayerProfile(
    id: id,
    name: name,
    surname: 'Test',
    photoPath: 'assets/dgv_logo.png',
    sex: Sex.male,
    bodySize: BodySize.medium,
    points: points,
    licenseImagePath: '',
  );
}

Widget _wrap(List<PlayerProfile> players) {
  return ProviderScope(
    overrides: [sortedLeaderboardProvider.overrideWith((ref) => players)],
    child: MaterialApp(
      theme: ThemeData.light(),
      home: const LeaderboardScreen(),
    ),
  );
}

void main() {
  group('LeaderboardScreen', () {
    testWidgets('shows AppBar with title', (tester) async {
      await tester.pumpWidget(_wrap([]));
      expect(find.text('Carnet por Puntos'), findsOneWidget);
    });

    testWidgets('shows empty state when no players', (tester) async {
      await tester.pumpWidget(_wrap([]));
      expect(find.text('Sin conductores registrados.'), findsOneWidget);
    });

    testWidgets('renders a LicenseCard for each player', (tester) async {
      final players = [
        _makePlayer('a', 'Alice', points: 15),
        _makePlayer('b', 'Bob', points: 10),
      ];
      await tester.pumpWidget(_wrap(players));

      expect(find.byType(LicenseCard), findsNWidgets(2));
    });

    testWidgets('shows gold medal emoji for first place', (tester) async {
      final players = [
        _makePlayer('a', 'Alice', points: 15),
        _makePlayer('b', 'Bob', points: 10),
        _makePlayer('c', 'Carlos', points: 8),
        _makePlayer('d', 'Diana', points: 5),
      ];
      await tester.pumpWidget(_wrap(players));

      expect(find.text('🥇'), findsOneWidget);
      expect(find.text('🥈'), findsOneWidget);
      expect(find.text('🥉'), findsOneWidget);
    });

    testWidgets('shows no medal for players outside top 3', (tester) async {
      final players = [
        _makePlayer('a', 'Alice', points: 15),
        _makePlayer('b', 'Bob', points: 12),
        _makePlayer('c', 'Carlos', points: 10),
        _makePlayer('d', 'Diana', points: 5),
      ];
      await tester.pumpWidget(_wrap(players));

      // Only 3 medals even with 4 players
      expect(find.text('🥇'), findsOneWidget);
      expect(find.text('🥈'), findsOneWidget);
      expect(find.text('🥉'), findsOneWidget);
    });

    testWidgets('single player shows only gold medal', (tester) async {
      final players = [_makePlayer('a', 'Alice', points: 15)];
      await tester.pumpWidget(_wrap(players));

      expect(find.text('🥇'), findsOneWidget);
      expect(find.text('🥈'), findsNothing);
      expect(find.text('🥉'), findsNothing);
    });
  });
}
