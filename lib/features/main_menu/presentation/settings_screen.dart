import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/core/utils/bac_calculator.dart';

/// Settings screen — Curva DGV calibration tool.
///
/// Lets the user visualise the optimal BAC curve for any sex/bodySize
/// combination and preview how a pre-game beers offset shifts it.
/// No data is persisted here; the actual pre-game beers value is entered
/// at "Iniciar Control" (PlayerSelectionScreen).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Sex _sex = Sex.male;
  BodySize _bodySize = BodySize.medium;
  double _preGameBeers = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        title: const Text('Curva DGV'),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Simulador de curva',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: DGTColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Selecciona perfil y cervezas previas para ver cómo se desplaza '
              'la curva óptima. Usa esto para calibrar antes del control.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: DGTColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Profile selectors
            _ProfileSelectors(
              sex: _sex,
              bodySize: _bodySize,
              onSexChanged: (v) => setState(() => _sex = v),
              onBodySizeChanged: (v) => setState(() => _bodySize = v),
            ),
            const SizedBox(height: 16),

            // Pre-game beers slider
            _BeersSlider(
              value: _preGameBeers,
              sex: _sex,
              bodySize: _bodySize,
              onChanged: (v) => setState(() => _preGameBeers = v),
            ),
            const SizedBox(height: 20),

            // Curve chart
            _CurveChart(
              sex: _sex,
              bodySize: _bodySize,
              preGameBeers: _preGameBeers,
            ),
            const SizedBox(height: 16),

            // Legend
            _Legend(preGameBeers: _preGameBeers),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile selectors
// ---------------------------------------------------------------------------

class _ProfileSelectors extends StatelessWidget {
  const _ProfileSelectors({
    required this.sex,
    required this.bodySize,
    required this.onSexChanged,
    required this.onBodySizeChanged,
  });

  final Sex sex;
  final BodySize bodySize;
  final ValueChanged<Sex> onSexChanged;
  final ValueChanged<BodySize> onBodySizeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sexo',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: DGTColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              SegmentedButton<Sex>(
                segments: const [
                  ButtonSegment(value: Sex.male, label: Text('Hombre')),
                  ButtonSegment(value: Sex.female, label: Text('Mujer')),
                ],
                selected: {sex},
                onSelectionChanged: (s) => onSexChanged(s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: DGTColors.primary,
                  selectedForegroundColor: DGTColors.textOnPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complexión',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: DGTColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              SegmentedButton<BodySize>(
                segments: const [
                  ButtonSegment(value: BodySize.small, label: Text('S')),
                  ButtonSegment(value: BodySize.medium, label: Text('M')),
                  ButtonSegment(value: BodySize.large, label: Text('L')),
                ],
                selected: {bodySize},
                onSelectionChanged: (s) => onBodySizeChanged(s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: DGTColors.primary,
                  selectedForegroundColor: DGTColors.textOnPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pre-game beers slider
// ---------------------------------------------------------------------------

class _BeersSlider extends StatelessWidget {
  const _BeersSlider({
    required this.value,
    required this.sex,
    required this.bodySize,
    required this.onChanged,
  });

  final double value;
  final Sex sex;
  final BodySize bodySize;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final offset = BACCalculator.preGameBacOffset(value, sex, bodySize);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '🍺 Cervezas previas',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: DGTColors.textSecondary),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value == 0.0
                    ? 'Sin compensación'
                    : '+${offset.toStringAsFixed(2)} mg/L',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: value == 0.0
                      ? DGTColors.textSecondary
                      : DGTColors.orange,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0.0,
          max: 5.0,
          divisions: 50,
          activeColor: DGTColors.orange,
          inactiveColor: DGTColors.textSecondary.withValues(alpha: 0.3),
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: DGTColors.textSecondary),
            ),
            Text(
              '5 cervezas',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: DGTColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Curve chart — two polylines across 10 rounds
// ---------------------------------------------------------------------------

class _CurveChart extends StatelessWidget {
  const _CurveChart({
    required this.sex,
    required this.bodySize,
    required this.preGameBeers,
  });

  final Sex sex;
  final BodySize bodySize;
  final double preGameBeers;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: DGTColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: DGTColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: CustomPaint(
          painter: _CurvePainter(
            sex: sex,
            bodySize: bodySize,
            preGameBeers: preGameBeers,
          ),
        ),
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  const _CurvePainter({
    required this.sex,
    required this.bodySize,
    required this.preGameBeers,
  });

  final Sex sex;
  final BodySize bodySize;
  final double preGameBeers;

  static const _rounds = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final offset = BACCalculator.preGameBacOffset(preGameBeers, sex, bodySize);

    // Build data points
    final baseline = List.generate(
      _rounds,
      (i) => BACCalculator.calculateOptimalBrAC(i + 1, sex, bodySize),
    );
    final shifted = baseline.map((v) => v + offset).toList();

    final maxY = (shifted.reduce(math.max) * 1.15).clamp(0.1, double.infinity);
    const minY = 0.0;

    // Drawing helpers
    double toX(int round) => 40 + (round / (_rounds - 1)) * (size.width - 48);
    double toY(double bac) =>
        size.height - 20 - ((bac - minY) / (maxY - minY)) * (size.height - 32);

    // Y-axis gridlines + labels
    final gridPaint = Paint()
      ..color = DGTColors.textSecondary.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    final labelStyle = const TextStyle(
      fontSize: 9,
      color: DGTColors.textSecondary,
    );
    final gridCount = 4;
    for (int i = 0; i <= gridCount; i++) {
      final y = minY + (maxY - minY) * i / gridCount;
      final dy = toY(y);
      canvas.drawLine(Offset(40, dy), Offset(size.width, dy), gridPaint);
      _drawText(canvas, y.toStringAsFixed(2), Offset(0, dy - 5), labelStyle);
    }

    // X-axis labels (R1–R10)
    final xLabelStyle = const TextStyle(
      fontSize: 9,
      color: DGTColors.textSecondary,
    );
    for (int i = 0; i < _rounds; i++) {
      final dx = toX(i);
      _drawText(
        canvas,
        'R${i + 1}',
        Offset(dx - 6, size.height - 16),
        xLabelStyle,
      );
    }

    // Draw baseline curve (DGT blue)
    _drawLine(
      canvas,
      List.generate(_rounds, (i) => Offset(toX(i), toY(baseline[i]))),
      DGTColors.primary,
      strokeWidth: 2,
      dashed: false,
    );

    // Draw shifted curve (orange), only when offset > 0
    if (offset > 0.001) {
      _drawLine(
        canvas,
        List.generate(_rounds, (i) => Offset(toX(i), toY(shifted[i]))),
        DGTColors.orange,
        strokeWidth: 2,
        dashed: true,
      );
    }

    // Dots on both curves
    for (int i = 0; i < _rounds; i++) {
      _drawDot(canvas, Offset(toX(i), toY(baseline[i])), DGTColors.primary);
      if (offset > 0.001) {
        _drawDot(canvas, Offset(toX(i), toY(shifted[i])), DGTColors.orange);
      }
    }
  }

  void _drawLine(
    Canvas canvas,
    List<Offset> points,
    Color color, {
    double strokeWidth = 2,
    bool dashed = false,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (!dashed) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    } else {
      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];
        // Dashed: draw first 60%, skip 40%
        final mid = Offset(
          p1.dx + (p2.dx - p1.dx) * 0.65,
          p1.dy + (p2.dy - p1.dy) * 0.65,
        );
        canvas.drawLine(p1, mid, paint);
      }
    }
  }

  void _drawDot(Canvas canvas, Offset center, Color color) {
    canvas.drawCircle(center, 3.5, Paint()..color = color);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_CurvePainter old) =>
      old.sex != sex ||
      old.bodySize != bodySize ||
      old.preGameBeers != preGameBeers;
}

// ---------------------------------------------------------------------------
// Legend
// ---------------------------------------------------------------------------

class _Legend extends StatelessWidget {
  const _Legend({required this.preGameBeers});

  final double preGameBeers;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(DGTColors.primary),
        const SizedBox(width: 6),
        Text(
          'Sin cervezas previas',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        if (preGameBeers > 0) ...[
          const SizedBox(width: 20),
          _dot(DGTColors.orange),
          const SizedBox(width: 6),
          Text(
            'Con ${preGameBeers.toStringAsFixed(1)} cervezas',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ],
    );
  }

  Widget _dot(Color color) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
