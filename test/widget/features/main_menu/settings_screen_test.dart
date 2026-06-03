import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/game_state.dart';
import 'package:dgv/core/providers/repository_providers.dart';
import 'package:dgv/data/repositories/game_state_repository.dart';
import 'package:dgv/features/main_menu/presentation/settings_screen.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeGameStateRepository implements GameStateRepository {
  GameState? _state;

  _FakeGameStateRepository([this._state]);

  @override
  Future<GameState?> getCurrent() async => _state;

  @override
  Future<void> save(GameState state) async {
    _state = state;
  }

  @override
  Future<void> delete() async {
    _state = null;
  }

  @override
  Future<bool> isGameInProgress() async => _state?.isInProgress ?? false;

  @override
  Stream<GameState?> watch() => Stream.value(_state);
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _wrap({GameState? gameState}) {
  return ProviderScope(
    overrides: [
      gameStateRepositoryProvider.overrideWithValue(
        _FakeGameStateRepository(gameState),
      ),
    ],
    child: const MaterialApp(home: SettingsScreen()),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SettingsScreen', () {
    testWidgets('shows Curva DGV title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Curva DGV'), findsWidgets);
    });

    testWidgets('shows sex selector', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Hombre'), findsOneWidget);
      expect(find.text('Mujer'), findsOneWidget);
    });

    testWidgets('shows body size selector', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('S'), findsOneWidget);
      expect(find.text('M'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
    });

    testWidgets('shows pre-game beers slider', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.textContaining('Cervezas previas'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('shows curve chart', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('shows no offset legend by default', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();

      expect(find.text('Sin cervezas previas'), findsOneWidget);
      expect(find.textContaining('Con '), findsNothing);
    });
  });
}
