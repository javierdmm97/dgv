import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';
import 'package:dgv/features/breathalyzer/presentation/feedback_screen.dart';
import 'package:dgv/widgets/massive_button.dart';

Widget _wrap(Widget child) {
  return MaterialApp(theme: ThemeData.light(), home: child);
}

BACEntryResult _makeResult({
  int pointsChange = 2,
  bool isImpounded = false,
  double bac = 2.0,
  Color? color,
}) {
  return BACEntryResult(
    playerId: 'p1',
    playerName: 'Juan García',
    bac: bac,
    roundNumber: 1,
    pointsChange: pointsChange,
    isImpounded: isImpounded,
    feedbackMessage: '¡En la zona óptima!',
    feedbackColor: color ?? DGTColors.green,
  );
}

void main() {
  group('FeedbackScreen', () {
    testWidgets('displays player name', (tester) async {
      await tester.pumpWidget(_wrap(FeedbackScreen(result: _makeResult())));
      expect(find.text('Juan García'), findsOneWidget);
    });

    testWidgets('displays positive points delta with + sign', (tester) async {
      await tester.pumpWidget(
        _wrap(FeedbackScreen(result: _makeResult(pointsChange: 2))),
      );
      expect(find.text('+2 pts'), findsOneWidget);
    });

    testWidgets('displays negative points delta without extra sign', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(FeedbackScreen(result: _makeResult(pointsChange: -3))),
      );
      expect(find.text('-3 pts'), findsOneWidget);
    });

    testWidgets('displays feedback message', (tester) async {
      await tester.pumpWidget(_wrap(FeedbackScreen(result: _makeResult())));
      expect(find.text('¡En la zona óptima!'), findsOneWidget);
    });

    testWidgets('displays formatted BAC reading', (tester) async {
      await tester.pumpWidget(
        _wrap(FeedbackScreen(result: _makeResult(bac: 2.15))),
      );
      expect(find.text('Lectura: 2.15 mg/L'), findsOneWidget);
    });

    testWidgets('shows impounded banner when isImpounded is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FeedbackScreen(
            result: _makeResult(isImpounded: true, pointsChange: -5),
          ),
        ),
      );
      expect(find.textContaining('INMOVILIZADO'), findsOneWidget);
    });

    testWidgets('does not show impounded banner when isImpounded is false', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(FeedbackScreen(result: _makeResult())));
      expect(find.textContaining('INMOVILIZADO'), findsNothing);
    });

    testWidgets('shows Continuar button', (tester) async {
      await tester.pumpWidget(_wrap(FeedbackScreen(result: _makeResult())));
      expect(find.byType(MassiveButton), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
    });

    testWidgets('scaffold background matches result feedbackColor', (
      tester,
    ) async {
      const testColor = Color(0xFF00FF00);
      await tester.pumpWidget(
        _wrap(FeedbackScreen(result: _makeResult(color: testColor))),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(testColor));
    });

    testWidgets('does not show title award section when awardedTitle is null', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(FeedbackScreen(result: _makeResult())));
      // No title emoji text should appear in the TitleAward widget area
      // (emojis from _TitleAward start with title.emoji which are 🟢🔴🔰🔋🛠️)
      expect(find.textContaining('🟢'), findsNothing);
    });

    testWidgets('tapping Continuar closes screen', (tester) async {
      bool popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => FeedbackScreen(result: _makeResult()),
                    ),
                  );
                },
                child: const Text('Go'),
              ),
            ),
          ),
          navigatorObservers: [_PopObserver(onPop: () => popped = true)],
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.byType(FeedbackScreen), findsOneWidget);

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });
  });
}

class _PopObserver extends NavigatorObserver {
  _PopObserver({required this.onPop});
  final VoidCallback onPop;

  @override
  void didPop(Route route, Route? previousRoute) => onPop();
}
