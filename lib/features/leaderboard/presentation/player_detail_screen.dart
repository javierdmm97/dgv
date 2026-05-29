import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/constants/app_constants.dart';
import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/utils/bac_calculator.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/theme/dgt_colors.dart';

class PlayerDetailScreen extends ConsumerWidget {
  const PlayerDetailScreen({super.key, required this.playerId});

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPlayer = ref.watch(playerByIdProvider(playerId));

    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        title: const Text('Detalle del Conductor'),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
      ),
      body: asyncPlayer.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (player) {
          if (player == null) {
            return const Center(child: Text('Conductor no encontrado.'));
          }
          return _PlayerDetail(player: player);
        },
      ),
    );
  }
}

class _PlayerDetail extends StatelessWidget {
  const _PlayerDetail({required this.player});

  final PlayerProfile player;

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
        ],
      ),
    );
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
            if (player.readings.isEmpty)
              const _EmptyChartState()
            else
              SizedBox(height: 240, child: _LineChart(player: player)),
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

class _LineChart extends StatelessWidget {
  const _LineChart({required this.player});

  final PlayerProfile player;

  // ---------------------------------------------------------------------------
  // Zone band helpers
  // ---------------------------------------------------------------------------

  /// Builds zone band data for the BAC graph.
  ///
  /// Uses wider sweet-spot (0.20) for rounds 1–2, standard (0.10) for 3+.
  /// Falls back to standard thresholds if roundNumber is out of range.
  static List<HorizontalRangeAnnotation> _buildZoneBands(
    double optimal,
    int roundNumber,
  ) {
    if (optimal <= 0) return [];

    final sweetSpot = (roundNumber >= 1 && roundNumber <= 2)
        ? AppConstants
              .zoneClosePct // 0.20 — wider for early rounds
        : AppConstants.zoneSweetSpotPct; // 0.10 — standard
    final close = AppConstants.zoneClosePct;
    final neutral = AppConstants.zoneNeutralPct;
    final far = AppConstants.zoneFarPct;

    return [
      // +2 zone (green): ±sweetSpot of optimal
      HorizontalRangeAnnotation(
        y1: optimal * (1 - sweetSpot),
        y2: optimal * (1 + sweetSpot),
        color: DGTColors.green.withValues(alpha: 0.15),
      ),
      // +1 zone below (yellow): close..sweetSpot below optimal
      HorizontalRangeAnnotation(
        y1: optimal * (1 - close),
        y2: optimal * (1 - sweetSpot),
        color: DGTColors.yellow.withValues(alpha: 0.15),
      ),
      // +1 zone above (yellow): sweetSpot..close above optimal
      HorizontalRangeAnnotation(
        y1: optimal * (1 + sweetSpot),
        y2: optimal * (1 + close),
        color: DGTColors.yellow.withValues(alpha: 0.15),
      ),
      // 0 zone below (gray): neutral..close below optimal
      HorizontalRangeAnnotation(
        y1: optimal * (1 - neutral),
        y2: optimal * (1 - close),
        color: DGTColors.textSecondary.withValues(alpha: 0.10),
      ),
      // 0 zone above (gray): close..neutral above optimal
      HorizontalRangeAnnotation(
        y1: optimal * (1 + close),
        y2: optimal * (1 + neutral),
        color: DGTColors.textSecondary.withValues(alpha: 0.10),
      ),
      // -1 zone below (orange): far..neutral below optimal
      HorizontalRangeAnnotation(
        y1: optimal * (1 - far),
        y2: optimal * (1 - neutral),
        color: DGTColors.orange.withValues(alpha: 0.12),
      ),
      // -1 zone above (orange): neutral..far above optimal
      HorizontalRangeAnnotation(
        y1: optimal * (1 + neutral),
        y2: optimal * (1 + far),
        color: DGTColors.orange.withValues(alpha: 0.12),
      ),
      // -2 zone (blue): below far threshold
      HorizontalRangeAnnotation(
        y1: 0,
        y2: optimal * (1 - far),
        color: DGTColors.primary.withValues(alpha: 0.10),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final chartReadings = [...player.readings]
      ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));
    final spots = chartReadings
        .map((r) => FlSpot(r.roundNumber.toDouble(), r.bac))
        .toList();
    final optimalSpots = chartReadings.map((r) {
      final optimal = BACCalculator.calculateOptimalBrAC(
        r.roundNumber,
        player.sex,
        player.bodySize,
      );
      return FlSpot(r.roundNumber.toDouble(), optimal);
    }).toList();
    final optimalUpperSpots = optimalSpots
        .map((s) => FlSpot(s.x, s.y * (1 + AppConstants.zoneSweetSpotPct)))
        .toList();
    final optimalLowerSpots = optimalSpots.map((s) {
      final lower = s.y * (1 - AppConstants.zoneSweetSpotPct);
      return FlSpot(s.x, lower < 0 ? 0 : lower);
    }).toList();

    final maxY =
        ([
                  ...spots.map((s) => s.y),
                  ...optimalUpperSpots.map((s) => s.y),
                ].reduce((a, b) => a > b ? a : b) +
                0.5)
            .ceilToDouble();

    // Single-reading edge case: ensure non-degenerate x-range (Req 3.7).
    final rawMinX = spots.first.x;
    final rawMaxX = spots.last.x;
    final minX = rawMinX == rawMaxX ? 0.0 : rawMinX;
    final maxX = rawMinX == rawMaxX ? 2.0 : rawMaxX;

    // Build zone bands using the last round's optimal as reference.
    final lastRound = chartReadings.last.roundNumber;
    final lastOptimal = BACCalculator.calculateOptimalBrAC(
      lastRound,
      player.sex,
      player.bodySize,
    );
    final zoneBands = _buildZoneBands(lastOptimal, lastRound);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        minX: minX,
        maxX: maxX,
        // Zone bands rendered behind the lines (Req 3.1–3.5)
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: zoneBands,
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: DGTColors.textSecondary.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: DGTColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 0.5,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 10,
                  color: DGTColors.textSecondary,
                ),
              ),
              reservedSize: 36,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) => Text(
                'R${value.toInt()}',
                style: const TextStyle(
                  fontSize: 10,
                  color: DGTColors.textSecondary,
                ),
              ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        // Lines rendered on top of zone bands (Req 3.6)
        lineBarsData: [
          LineChartBarData(
            spots: optimalUpperSpots,
            isCurved: true,
            color: DGTColors.green.withValues(alpha: 0.25),
            barWidth: 1,
            dashArray: [4, 4],
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: optimalLowerSpots,
            isCurved: true,
            color: DGTColors.green.withValues(alpha: 0.25),
            barWidth: 1,
            dashArray: [4, 4],
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: optimalSpots,
            isCurved: true,
            color: DGTColors.green.withValues(alpha: 0.8),
            barWidth: 2,
            dashArray: [6, 4],
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: DGTColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, pct, bar, idx) {
                final roundOptimal = BACCalculator.calculateOptimalBrAC(
                  spot.x.toInt(),
                  player.sex,
                  player.bodySize,
                );
                return FlDotCirclePainter(
                  radius: 5,
                  color: _dotColor(spot.y, roundOptimal),
                  strokeWidth: 2,
                  strokeColor: DGTColors.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: DGTColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }

  Color _dotColor(double bac, double optimal) {
    if (optimal <= 0) return DGTColors.orange;
    final pct = (bac - optimal).abs() / optimal;
    if (pct <= AppConstants.zoneSweetSpotPct) return DGTColors.green;
    if (pct <= AppConstants.zoneClosePct) return DGTColors.yellow;
    if (pct <= AppConstants.zoneNeutralPct) return DGTColors.orange;
    return DGTColors.red;
  }
}
