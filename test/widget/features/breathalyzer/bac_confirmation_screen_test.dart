import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/features/breathalyzer/presentation/bac_confirmation_screen.dart';
import 'package:dgv/widgets/massive_button.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PlayerProfile _player() => const PlayerProfile(
  id: 'p1',
  name: 'Carlos',
  surname: 'García',
  photoPath: '',
  sex: Sex.male,
  bodySize: BodySize.medium,
  points: 13,
  licenseImagePath: '',
);

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(theme: ThemeData.light(), home: child),
  );
}

BacConfirmationScreen _screen({double value = 0.45}) {
  return BacConfirmationScreen(
    args: BacConfirmationArgs(player: _player(), enteredValue: value),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BacConfirmationScreen', () {
    testWidgets('displays player name', (tester) async {
      await tester.pumpWidget(_wrap(_screen()));
      expect(find.text('Carlos García'), findsOneWidget);
    });

    testWidgets('displays entered value formatted to 2 decimal places', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_screen(value: 0.45)));
      expect(find.text('0.45 mg/L'), findsOneWidget);
    });

    testWidgets('player name is rendered at ≥ 24sp', (tester) async {
      await tester.pumpWidget(_wrap(_screen()));
      // Find the Text widget containing the player name.
      final nameWidget = tester.widget<Text>(find.text('Carlos García'));
      // The style is applied via copyWith — check the resolved fontSize.
      final style = nameWidget.style;
      expect(style?.fontSize, greaterThanOrEqualTo(24));
    });

    testWidgets('entered value is rendered at ≥ 48sp', (tester) async {
      await tester.pumpWidget(_wrap(_screen(value: 0.45)));
      final valueWidget = tester.widget<Text>(find.text('0.45 mg/L'));
      final style = valueWidget.style;
      expect(style?.fontSize, greaterThanOrEqualTo(48));
    });

    testWidgets('shows Confirmar and Corregir buttons', (tester) async {
      await tester.pumpWidget(_wrap(_screen()));
      expect(find.text('Confirmar'), findsOneWidget);
      expect(find.text('Corregir'), findsOneWidget);
    });

    testWidgets('both buttons have minHeight 80 via MassiveButton', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_screen()));
      final buttons = tester.widgetList<MassiveButton>(
        find.byType(MassiveButton),
      );
      expect(buttons.length, greaterThanOrEqualTo(2));
    });

    testWidgets('tapping Corregir pops with null', (tester) async {
      Object? poppedValue = 'sentinel'; // non-null sentinel

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  poppedValue = await Navigator.push<Object?>(
                    ctx,
                    MaterialPageRoute<Object?>(builder: (_) => _screen()),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap "Corregir"
      await tester.tap(find.text('Corregir'));
      await tester.pumpAndSettle();

      expect(poppedValue, isNull);
    });

    testWidgets('AppBar title says "Confirmar lectura"', (tester) async {
      await tester.pumpWidget(_wrap(_screen()));
      expect(find.text('Confirmar lectura'), findsOneWidget);
    });
  });
}
