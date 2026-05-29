import 'package:fl_chart/fl_chart.dart';
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

void main() {
  group('PlayerDetailScreen', () {
    testWidgets('draws optimal BrAC as a per-round player-specific curve', (
      tester,
    ) async {
      final now = DateTime(2026);
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
        ProviderScope(
          overrides: [
            playerRepositoryProvider.overrideWith(
              (ref) => _FakePlayerRepository([player]),
            ),
          ],
          child: const MaterialApp(
            home: PlayerDetailScreen(playerId: 'player-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final optimalCurve = chart.data.lineBarsData[2];

      expect(optimalCurve.spots, const [
        FlSpot(1, 0.111),
        FlSpot(2, 0.223),
        FlSpot(3, 0.335),
      ]);
    });

    // ── Zone band tests (Task 7.1) ──────────────────────────────────────────

    testWidgets('renders 8 horizontal zone band annotations', (tester) async {
      final now = DateTime(2026);
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
        ProviderScope(
          overrides: [
            playerRepositoryProvider.overrideWith(
              (ref) => _FakePlayerRepository([player]),
            ),
          ],
          child: const MaterialApp(
            home: PlayerDetailScreen(playerId: 'player-2'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final bands = chart.data.rangeAnnotations.horizontalRangeAnnotations;

      // 8 bands: +2, +1 below, +1 above, 0 below, 0 above, -1 below, -1 above, -2
      expect(bands.length, equals(8));
    });

    testWidgets('all zone band opacities are ≤ 0.15', (tester) async {
      final now = DateTime(2026);
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
        ProviderScope(
          overrides: [
            playerRepositoryProvider.overrideWith(
              (ref) => _FakePlayerRepository([player]),
            ),
          ],
          child: const MaterialApp(
            home: PlayerDetailScreen(playerId: 'player-3'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final bands = chart.data.rangeAnnotations.horizontalRangeAnnotations;

      for (final band in bands) {
        final alpha = band.color?.a ?? 0.0;
        expect(
          alpha,
          lessThanOrEqualTo(0.15),
          reason: 'Band color alpha $alpha exceeds 0.15',
        );
      }
    });

    testWidgets('single-reading chart renders without error (minX=0, maxX=2)', (
      tester,
    ) async {
      final now = DateTime(2026);
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
        ProviderScope(
          overrides: [
            playerRepositoryProvider.overrideWith(
              (ref) => _FakePlayerRepository([player]),
            ),
          ],
          child: const MaterialApp(
            home: PlayerDetailScreen(playerId: 'player-4'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      // Non-degenerate x-range: minX=0, maxX=2
      expect(chart.data.minX, equals(0.0));
      expect(chart.data.maxX, equals(2.0));
    });
  });
}
