import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/checkpoint_state.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/checkpoint_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/features/checkpoint/presentation/checkpoint_screen.dart';
import 'package:dgv/widgets/massive_button.dart';

// ignore: unused_element
const _kEmptyPlayerList = <PlayerProfile>[];

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeCheckpointNotifier extends CheckpointNotifier {
  _FakeCheckpointNotifier(this._initialState);
  final CheckpointState? _initialState;

  @override
  Future<CheckpointState?> build() async => _initialState;

  @override
  Future<void> initialize({
    required List<PlayerProfile> players,
    required int intervalMinutes,
  }) async {}

  @override
  Future<void> completeGroupMeasurement(int groupIndex) async {}

  @override
  Future<void> recordPlayerMeasurement(String playerId) async {}

  @override
  Future<void> reset() async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

GroupCheckpoint _makeGroup({int index = 0, bool isDue = false}) {
  final now = DateTime.now();
  return GroupCheckpoint(
    groupIndex: index,
    playerIds: ['p${index}a', 'p${index}b'],
    lastMeasurement: now,
    intervalMinutes: 45,
    nextCheckpoint: isDue
        ? now.subtract(const Duration(seconds: 1))
        : now.add(const Duration(minutes: 44)),
  );
}

CheckpointState _makeState({
  bool isActive = false,
  int? activeGroupIndex,
  List<GroupCheckpoint>? groups,
}) {
  final grps = groups ?? [_makeGroup(index: 0), _makeGroup(index: 1)];
  return CheckpointState(
    currentRound: 1,
    intervalMinutes: 45,
    groups: grps,
    isCheckpointActive: isActive,
    activeGroupIndex: activeGroupIndex,
  );
}

Widget _wrap(CheckpointState? state) {
  return ProviderScope(
    overrides: [
      checkpointNotifierProvider.overrideWith(
        () => _FakeCheckpointNotifier(state),
      ),
      playerListProvider.overrideWith((ref) async => []),
    ],
    child: MaterialApp(
      theme: ThemeData.light(),
      home: const CheckpointScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CheckpointScreen', () {
    testWidgets('shows AppBar with title', (tester) async {
      await tester.pumpWidget(_wrap(null));
      await tester.pump();
      expect(find.text('Control Sorpresa'), findsOneWidget);
    });

    testWidgets('shows no-game body when checkpoint state is null', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(null));
      await tester.pump();
      expect(find.text('No hay partida en curso.'), findsOneWidget);
    });

    testWidgets('no-game body shows leaderboard button', (tester) async {
      await tester.pumpWidget(_wrap(null));
      await tester.pump();
      expect(find.text('Ver Clasificación'), findsOneWidget);
    });

    testWidgets('shows countdown body when game is active but not due', (
      tester,
    ) async {
      final state = _makeState();
      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      // CountdownBody shows GroupCountdownCards
      expect(find.byType(MassiveButton), findsOneWidget);
      expect(find.text('Ver Clasificación'), findsOneWidget);
    });

    testWidgets('shows active checkpoint banner when isCheckpointActive', (
      tester,
    ) async {
      final state = _makeState(isActive: true, activeGroupIndex: 0);
      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.textContaining('CONTROL ACTIVO'), findsOneWidget);
    });

    testWidgets('active checkpoint body shows "Ir al Retén" button', (
      tester,
    ) async {
      final state = _makeState(isActive: true, activeGroupIndex: 0);
      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.text('Ir al Retén'), findsOneWidget);
    });

    testWidgets('shows round number in appbar when game active', (
      tester,
    ) async {
      final state = _makeState();
      await tester.pumpWidget(_wrap(state));
      await tester.pump();

      expect(find.text('Control Sorpresa — Ronda 1'), findsOneWidget);
    });

    testWidgets('loading indicator shown before async resolves', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(null));
      // Before pump — in loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
