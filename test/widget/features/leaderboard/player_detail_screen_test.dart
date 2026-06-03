import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/repository_providers.dart';
import 'package:dgv/data/repositories/player_repository.dart';
import 'package:dgv/features/leaderboard/presentation/player_detail_screen.dart';

class _FakePlayerRepository implements PlayerRepository {
  _FakePlayerRepository(this.players);

  final List<PlayerProfile> players;

  @override
  Future<List<PlayerProfile>> getAll() async => players;

  @override
  Future<PlayerProfile?> getById(String id) async =>
      players.where((p) => p.id == id).firstOrNull;

  @override
  Future<void> save(PlayerProfile player) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> update(PlayerProfile player) async {}

  @override
  Future<bool> exists(String id) async => players.any((p) => p.id == id);

  @override
  Future<int> count() async => players.length;

  @override
  Future<void> clearAll() async {}

  @override
  Stream<List<PlayerProfile>> watchAll() => Stream.value(players);
}

Widget _wrap(Widget child, List<PlayerProfile> players) => ProviderScope(
  overrides: [
    playerRepositoryProvider.overrideWith(
      (ref) => _FakePlayerRepository(players),
    ),
  ],
  child: MaterialApp(home: child),
);

void main() {
  final now = DateTime(2026);

  group('PlayerDetailScreen', () {
    testWidgets(
      'renders lollipop chart (CustomPaint) when player has readings',
      (tester) async {
        final player = PlayerProfile(
          id: 'player-1',
          name: 'Test',
          surname: 'Driver',
          photoPath: '',
          sex: Sex.male,
          bodySize: BodySize.medium,
          licenseImagePath: '',
          readings: [
            BACReading(
              id: 'r1',
              playerId: 'player-1',
              bac: 0.12,
              timestamp: now,
              roundNumber: 1,
              entryMethod: BACEntryMethod.manual,
            ),
            BACReading(
              id: 'r2',
              playerId: 'player-1',
              bac: 0.24,
              timestamp: now,
              roundNumber: 2,
              entryMethod: BACEntryMethod.manual,
            ),
            BACReading(
              id: 'r3',
              playerId: 'player-1',
              bac: 0.39,
              timestamp: now,
              roundNumber: 3,
              entryMethod: BACEntryMethod.manual,
            ),
          ],
        );

        await tester.pumpWidget(
          _wrap(const PlayerDetailScreen(playerId: 'player-1'), [player]),
        );
        await tester.pumpAndSettle();

        // Chart is rendered as a CustomPaint.
        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets('measurement table shows round numbers for active readings', (
      tester,
    ) async {
      final player = PlayerProfile(
        id: 'player-2',
        name: 'Zone',
        surname: 'Test',
        photoPath: '',
        sex: Sex.male,
        bodySize: BodySize.medium,
        licenseImagePath: '',
        readings: [
          BACReading(
            id: 'r0',
            playerId: 'player-2',
            bac: 0.05,
            timestamp: now,
            roundNumber: 0,
            entryMethod: BACEntryMethod.manual,
          ),
          BACReading(
            id: 'r1',
            playerId: 'player-2',
            bac: 0.33,
            timestamp: now,
            roundNumber: 3,
            entryMethod: BACEntryMethod.manual,
          ),
        ],
      );

      await tester.pumpWidget(
        _wrap(const PlayerDetailScreen(playerId: 'player-2'), [player]),
      );
      await tester.pumpAndSettle();

      // Round 1+ readings appear in the table.
      expect(find.text('R3'), findsOneWidget);
      // Round 0 baseline is also shown (with — for objective and diff).
      expect(find.text('R0'), findsOneWidget);
    });

    testWidgets(
      'perfection score row is visible when player has active readings',
      (tester) async {
        final player = PlayerProfile(
          id: 'player-3',
          name: 'Opacity',
          surname: 'Test',
          photoPath: '',
          sex: Sex.male,
          bodySize: BodySize.medium,
          licenseImagePath: '',
          readings: [
            BACReading(
              id: 'r1',
              playerId: 'player-3',
              bac: 0.33,
              timestamp: now,
              roundNumber: 3,
              entryMethod: BACEntryMethod.manual,
            ),
          ],
        );

        await tester.pumpWidget(
          _wrap(const PlayerDetailScreen(playerId: 'player-3'), [player]),
        );
        await tester.pumpAndSettle();

        expect(find.text('Precisión: '), findsOneWidget);
      },
    );

    testWidgets('single-reading chart renders without error', (tester) async {
      final player = PlayerProfile(
        id: 'player-4',
        name: 'Single',
        surname: 'Reading',
        photoPath: '',
        sex: Sex.male,
        bodySize: BodySize.medium,
        licenseImagePath: '',
        readings: [
          BACReading(
            id: 'r1',
            playerId: 'player-4',
            bac: 0.11,
            timestamp: now,
            roundNumber: 1,
            entryMethod: BACEntryMethod.manual,
          ),
        ],
      );

      await tester.pumpWidget(
        _wrap(const PlayerDetailScreen(playerId: 'player-4'), [player]),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
