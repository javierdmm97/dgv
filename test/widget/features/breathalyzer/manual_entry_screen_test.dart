import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/breathalyzer/presentation/manual_entry_screen.dart';
import 'package:dgv/widgets/custom_keypad.dart';

PlayerProfile _player({String photoPath = ''}) {
  return PlayerProfile(
    id: 'p1',
    name: 'Ana',
    surname: 'López',
    photoPath: photoPath,
    sex: Sex.female,
    bodySize: BodySize.small,
    points: 12,
    licenseImagePath: '',
  );
}

Widget _wrap(Widget child) {
  final player = _player();
  return ProviderScope(
    overrides: [
      currentGameStateProvider.overrideWith((ref) async => null),
      playerByIdProvider(player.id).overrideWith((ref) async => player),
    ],
    child: MaterialApp(theme: ThemeData.light(), home: child),
  );
}

void main() {
  group('ManualEntryScreen', () {
    testWidgets('shows player name in AppBar title', (tester) async {
      await tester.pumpWidget(_wrap(ManualEntryScreen(player: _player())));
      expect(find.text('Tasa de Ana'), findsOneWidget);
    });

    testWidgets('shows player full name in body', (tester) async {
      await tester.pumpWidget(_wrap(ManualEntryScreen(player: _player())));
      expect(find.text('Ana López'), findsOneWidget);
    });

    testWidgets('shows initials avatar when no photo', (tester) async {
      await tester.pumpWidget(_wrap(ManualEntryScreen(player: _player())));
      expect(find.text('AL'), findsOneWidget);
    });

    testWidgets('shows CustomKeypad with maxDigits 3', (tester) async {
      await tester.pumpWidget(_wrap(ManualEntryScreen(player: _player())));
      final keypad = tester.widget<CustomKeypad>(find.byType(CustomKeypad));
      expect(keypad.maxDigits, equals(3));
    });

    testWidgets('has background color matching DGTColors.background', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(ManualEntryScreen(player: _player())));
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(DGTColors.background));
    });
  });
}
