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
  });
}
