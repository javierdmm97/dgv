import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/widgets/title_badge.dart';

/// Helper that wraps a widget in a minimal MaterialApp with a theme that
/// provides a [ColorScheme] (needed for [Theme.of(context).colorScheme.outline]).
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData.light(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('TitleBadge', () {
    // ── Requirement 13.6: accepts title type and count as parameters ──────────

    testWidgets('can be constructed with const constructor', (tester) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.velocidadDeCrucero, count: 0)),
      );
      expect(find.byType(TitleBadge), findsOneWidget);
    });

    // ── Requirement 13.3: count == 0 → grayed-out icon, no counter ───────────

    testWidgets('shows no counter text when count is 0', (tester) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.velocidadDeCrucero, count: 0)),
      );

      expect(find.textContaining('×'), findsNothing);
    });

    testWidgets('applies opacity when count is 0', (tester) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.velocidadDeCrucero, count: 0)),
      );

      // Opacity is used to grey out the icon when inactive.
      expect(find.byType(Opacity), findsOneWidget);
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, equals(0.3));
    });

    // ── Requirement 13.4: count >= 1 → full-color icon + counter ─────────────

    testWidgets('shows counter text when count is 1', (tester) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.velocidadDeCrucero, count: 1)),
      );

      expect(find.text('×1'), findsOneWidget);
    });

    testWidgets('shows counter text when count is greater than 1', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.multaPorExceso, count: 3)),
      );

      expect(find.text('×3'), findsOneWidget);
    });

    testWidgets('does not apply opacity when count >= 1', (tester) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.lDePracticas, count: 2)),
      );

      // No Opacity wrapper when the badge is active.
      expect(find.byType(Opacity), findsNothing);
    });

    // ── Requirement 13.5: compact Row layout ─────────────────────────────────

    testWidgets('uses Row as root layout', (tester) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.vehiculoHibrido, count: 1)),
      );

      // The TitleBadge itself renders a Row at its root.
      final badge = tester.widget<TitleBadge>(find.byType(TitleBadge));
      expect(badge, isNotNull);

      // Verify Row is present in the subtree.
      expect(find.byType(Row), findsWidgets);
    });

    // ── Requirement 13.1: displays icon for each title type ──────────────────

    testWidgets('renders an image for velocidadDeCrucero', (tester) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.velocidadDeCrucero, count: 1)),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renders an image for multaPorExceso', (tester) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.multaPorExceso, count: 1)),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renders an image for lDePracticas', (tester) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.lDePracticas, count: 1)),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renders an image for vehiculoHibrido', (tester) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.vehiculoHibrido, count: 1)),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renders an image for itvPassed', (tester) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.itvPassed, count: 1)),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    // ── Requirement 13.2: counter format is ×N ───────────────────────────────

    testWidgets('counter text uses × prefix format', (tester) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.itvPassed, count: 5)),
      );

      expect(find.text('×5'), findsOneWidget);
    });

    // ── Edge case: very high count should display without overflow ────────────

    testWidgets('displays high count without overflow', (tester) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.velocidadDeCrucero, count: 99)),
      );

      expect(find.text('×99'), findsOneWidget);
      // No overflow errors should be thrown.
      expect(tester.takeException(), isNull);
    });

    // ── Transition: count 0 → 1 shows counter, removes opacity ──────────────

    testWidgets('updates correctly when count changes from 0 to 1', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.vehiculoHibrido, count: 0)),
      );

      expect(find.textContaining('×'), findsNothing);
      expect(find.byType(Opacity), findsOneWidget);

      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.vehiculoHibrido, count: 1)),
      );

      expect(find.text('×1'), findsOneWidget);
      expect(find.byType(Opacity), findsNothing);
    });

    // ── Requirement 13.7: uses opacity for inactive state ────────────────────

    testWidgets('grayed icon uses opacity 0.3', (tester) async {
      await tester.pumpWidget(
        _wrap(const TitleBadge(title: DGTTitle.velocidadDeCrucero, count: 0)),
      );

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, equals(0.3));
    });
  });
}
