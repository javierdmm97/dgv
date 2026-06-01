import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/constants/app_constants.dart';
import 'package:dgv/core/constants/route_constants.dart';
import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/core/utils/bac_calculator.dart';
import 'package:dgv/core/utils/points_calculator.dart';
import 'package:dgv/widgets/massive_button.dart';

class PlayerDetailScreen extends ConsumerWidget {
  const PlayerDetailScreen({super.key, required this.playerId});

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bug #1 fix: Watch the list notifier to trigger rebuilds when player data changes
    ref.watch(playerListNotifierProvider);
    final asyncPlayer = ref.watch(playerByIdProvider(playerId));

    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        title: const Text('Detalle del Conductor'),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
        actions: [
          if (asyncPlayer.value != null)
            IconButton(
              icon: const Icon(Icons.credit_card_outlined),
              tooltip: 'Ver carnet de conducir',
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.licenseViewer,
                arguments: asyncPlayer.value!,
              ),
            ),
        ],
      ),
      body: asyncPlayer.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (player) {
          if (player == null) {
            return const Center(child: Text('Conductor no encontrado.'));
          }
          return _PlayerDetail(player: player, ref: ref);
        },
      ),
    );
  }
}

class _PlayerDetail extends StatelessWidget {
  const _PlayerDetail({required this.player, required this.ref});

  final PlayerProfile player;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PlayerHeader(player: player),
          const SizedBox(height: 16),
          _TitleBadgesRow(player: player),
          const SizedBox(height: 16),
          _BACChart(player: player),
          if (!player.isIncautado) ...[
            const SizedBox(height: 24),
            MassiveButton(
              text: '🚗 Retirar vehículo',
              backgroundColor: Colors.red.shade700,
              onPressed: () => _confirmIncautado(context),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.withValues(alpha: 0.1),
              child: const Text(
                '🚗 Vehículo incautado — este conductor no participa en más rondas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _confirmIncautado(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Retirar vehículo?'),
        content: const Text(
          'Este conductor no participará en más rondas. Esta acción es permanente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Incautar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(playerListNotifierProvider.notifier)
          .markIncautado(player.id);
    }
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    final isAsset = player.photoPath.startsWith('assets/');
    final ImageProvider image = isAsset
        ? AssetImage(player.photoPath)
        : FileImage(File(player.photoPath));

    return Card(
      color: DGTColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundImage: player.photoPath.isNotEmpty ? image : null,
              backgroundColor: DGTColors.primary,
              child: player.photoPath.isEmpty
                  ? Text(
                      '${player.name[0]}${player.surname[0]}',
                      style: const TextStyle(
                        fontSize: 28,
                        color: DGTColors.textOnPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${player.name} ${player.surname}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${player.points} puntos',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _pointsColor(player.points),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (player.currentBAC != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Último registro: ${player.currentBAC!.toStringAsFixed(2)} mg/L',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: DGTColors.textSecondary,
                      ),
                    ),
                  ],
                  if (player.fineCount > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '🚗 ${player.fineCount} multa${player.fineCount == 1 ? '' : 's'} · ${player.moneyLost} €',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: DGTColors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _pointsColor(int points) {
    if (points >= 10) return DGTColors.green;
    if (points >= 5) return DGTColors.orange;
    return DGTColors.red;
  }
}

class _TitleBadgesRow extends StatelessWidget {
  const _TitleBadgesRow({required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    final earnedTitles = player.titleCounts.entries
        .where((e) => e.value > 0)
        .toList();

    if (earnedTitles.isEmpty) return const SizedBox.shrink();

    return Card(
      color: DGTColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Títulos conseguidos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: earnedTitles.map((entry) {
                final title = entry.key;
                final count = entry.value;
                return Chip(
                  avatar: Text(title.emoji),
                  label: Text('${title.displayName} ×$count'),
                  backgroundColor: DGTColors.background,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BACChart extends StatelessWidget {
  const _BACChart({required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: DGTColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresión de tasa',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (player.readings.where((r) => r.roundNumber > 0).isEmpty)
              const _EmptyChartState()
            else ...[
              SizedBox(height: 260, child: _LollipopChart(player: player)),
              const SizedBox(height: 8),
              _PerfectionScore(player: player),
              const SizedBox(height: 16),
              _MeasurementTable(player: player),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyChartState extends StatelessWidget {
  const _EmptyChartState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          'Sin lecturas aún',
          style: TextStyle(color: DGTColors.textSecondary, fontSize: 16),
        ),
      ),
    );
  }
}

/// Lollipop-style BAC chart.
///
/// For each round:
/// - A solid green line connects the per-round optimal values.
/// - A vertical stick runs from the optimal value to the actual measurement.
/// - A filled dot sits at the measurement value.
/// - Stick and dot are colored by zone proximity:
///   green (±10%), yellow (±20%), orange (±40%), red (beyond).
class _LollipopChart extends StatelessWidget {
  const _LollipopChart({required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    final readings = player.readings.where((r) => r.roundNumber > 0).toList()
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    return CustomPaint(
      painter: _LollipopPainter(
        readings: readings,
        sex: player.sex,
        bodySize: player.bodySize,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _LollipopPainter extends CustomPainter {
  _LollipopPainter({
    required this.readings,
    required this.sex,
    required this.bodySize,
  });

  final List<BACReading> readings;
  final Sex sex;
  final BodySize bodySize;

  static const _leftPad = 44.0;
  static const _rightPad = 16.0;
  static const _topPad = 12.0;
  static const _bottomPad = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.isEmpty) return;

    final chartW = size.width - _leftPad - _rightPad;
    final chartH = size.height - _topPad - _bottomPad;

    // Compute optimal values and overall Y range.
    final optimalValues = readings.map((r) {
      return BACCalculator.calculateOptimalBrAC(r.roundNumber, sex, bodySize);
    }).toList();

    final allY = [...readings.map((r) => r.bac), ...optimalValues];
    final maxY = (allY.reduce((a, b) => a > b ? a : b) + 0.15).clamp(
      0.5,
      double.infinity,
    );

    double yToPixel(double y) =>
        _topPad + chartH * (1 - (y / maxY).clamp(0.0, 1.0));

    // X positions: slot-based so no point lands on the chart border.
    // Each reading gets its own equal-width slot; the dot sits at slot centre.
    final n = readings.length;
    final slotW = chartW / n;
    double xForIndex(int i) => _leftPad + slotW * (i + 0.5);

    // ── Grid lines ────────────────────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = DGTColors.textSecondary.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    final step = maxY <= 0.5 ? 0.1 : (maxY <= 1.0 ? 0.2 : 0.5);
    for (double y = 0; y <= maxY; y += step) {
      final py = yToPixel(y);
      canvas.drawLine(
        Offset(_leftPad, py),
        Offset(size.width - _rightPad, py),
        gridPaint,
      );

      // Y-axis label.
      final tp = TextPainter(
        text: TextSpan(
          text: y.toStringAsFixed(1),
          style: const TextStyle(fontSize: 9, color: DGTColors.textSecondary),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(_leftPad - tp.width - 4, py - tp.height / 2));
    }

    // ── Optimal line ──────────────────────────────────────────────────────────
    final optimalPaint = Paint()
      ..color = DGTColors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final optimalPath = Path();
    for (int i = 0; i < readings.length; i++) {
      final x = xForIndex(i);
      final y = yToPixel(optimalValues[i]);
      if (i == 0) {
        optimalPath.moveTo(x, y);
      } else {
        optimalPath.lineTo(x, y);
      }
    }
    canvas.drawPath(optimalPath, optimalPaint);

    // ── Lollipops ─────────────────────────────────────────────────────────────
    for (int i = 0; i < readings.length; i++) {
      final reading = readings[i];
      final optimal = optimalValues[i];
      final x = xForIndex(i);
      final yMeasure = yToPixel(reading.bac);
      final yOptimal = yToPixel(optimal);

      final color = _zoneColor(reading.bac, optimal, reading.roundNumber);

      // Stick.
      final stickPaint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..strokeWidth = 2;
      canvas.drawLine(Offset(x, yOptimal), Offset(x, yMeasure), stickPaint);

      // Dot.
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, yMeasure), 7, dotPaint);
      canvas.drawCircle(
        Offset(x, yMeasure),
        7,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // X-axis label.
      final tp = TextPainter(
        text: TextSpan(
          text: 'R${reading.roundNumber}',
          style: const TextStyle(fontSize: 9, color: DGTColors.textSecondary),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - _bottomPad + 4));
    }
  }

  Color _zoneColor(double bac, double optimal, int round) {
    if (optimal <= 0) return DGTColors.orange;
    final pct = (bac - optimal).abs() / optimal;
    if (pct <= AppConstants.zoneSweetSpotPct) return DGTColors.green;
    if (pct <= AppConstants.zoneClosePct) return DGTColors.yellow;
    if (pct <= AppConstants.zoneNeutralPct) return DGTColors.orange;
    return DGTColors.red;
  }

  @override
  bool shouldRepaint(_LollipopPainter oldDelegate) =>
      readings != oldDelegate.readings;
}

// ---------------------------------------------------------------------------
// Perfection score
// ---------------------------------------------------------------------------

class _PerfectionScore extends StatelessWidget {
  const _PerfectionScore({required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    final score = PointsCalculator.calculatePerfectionScore(player.readings);
    final display = score.isFinite ? score.toStringAsFixed(3) : '—';

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Precisión: ',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: DGTColors.textSecondary),
        ),
        Text(
          display,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: DGTColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        const Tooltip(
          message: 'Desviación media del objetivo (menor = mejor)',
          child: Icon(
            Icons.info_outline,
            size: 14,
            color: DGTColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Measurement table (Bug #2 fix)
// ---------------------------------------------------------------------------

class _MeasurementTable extends StatelessWidget {
  const _MeasurementTable({required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    final activeReadings = player.readings.toList()
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    if (activeReadings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial de mediciones',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(
            color: DGTColors.textSecondary.withValues(alpha: 0.3),
          ),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: DGTColors.primary.withValues(alpha: 0.1),
              ),
              children: [
                _tableHeader('Ronda'),
                _tableHeader('Medición'),
                _tableHeader('Objetivo'),
                _tableHeader('Diff'),
              ],
            ),
            ...activeReadings.map((reading) {
              // R0 is the baseline — no optimal target exists yet.
              if (reading.roundNumber == 0) {
                return TableRow(
                  children: [
                    _tableCell('R0', color: DGTColors.textSecondary),
                    _tableCell(reading.formattedBAC),
                    _tableCell('—', color: DGTColors.textSecondary),
                    _tableCell('—', color: DGTColors.textSecondary),
                  ],
                );
              }

              final optimal = BACCalculator.calculateOptimalBrAC(
                reading.roundNumber,
                player.sex,
                player.bodySize,
              );
              final diff = reading.bac - optimal;
              final sign = diff >= 0 ? '+' : '';
              final diffColor = diff.abs() <= optimal * 0.1
                  ? DGTColors.green
                  : diff.abs() <= optimal * 0.2
                  ? DGTColors.yellow
                  : DGTColors.red;

              return TableRow(
                children: [
                  _tableCell('R${reading.roundNumber}'),
                  _tableCell(reading.formattedBAC),
                  _tableCell(optimal.toStringAsFixed(2)),
                  _tableCell(
                    '$sign${diff.toStringAsFixed(2)}',
                    color: diffColor,
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tableCell(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color ?? DGTColors.textPrimary),
        textAlign: TextAlign.center,
      ),
    );
  }
}
