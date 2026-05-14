import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/constants/app_constants.dart';
import 'package:dgv/core/models/dgt_title.dart';
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
                  if (player.isImpounded) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: DGTColors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'INMOVILIZADO',
                        style: TextStyle(
                          color: DGTColors.textOnPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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

  @override
  Widget build(BuildContext context) {
    final spots = player.readings
        .map((r) => FlSpot(r.roundNumber.toDouble(), r.bac))
        .toList();

    final optimal = player.optimalBAC;
    final bandTop = optimal + AppConstants.optimalToleranceClose;
    final bandBottom = optimal - AppConstants.optimalToleranceClose;

    final maxY =
        ([
                  ...spots.map((s) => s.y),
                  bandTop,
                  AppConstants.impoundmentThreshold,
                ].reduce((a, b) => a > b ? a : b) +
                0.5)
            .ceilToDouble();

    final minX = spots.first.x;
    final maxX = spots.last.x;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        minX: minX,
        maxX: maxX,
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
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: optimal,
              color: DGTColors.green.withValues(alpha: 0.8),
              strokeWidth: 2,
              dashArray: [6, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                labelResolver: (_) => 'Óptimo',
                style: const TextStyle(
                  color: DGTColors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: bandBottom.clamp(0, maxY),
              y2: bandTop.clamp(0, maxY),
              color: DGTColors.green.withValues(alpha: 0.15),
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: DGTColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                radius: 5,
                color: _dotColor(spot.y, optimal),
                strokeWidth: 2,
                strokeColor: DGTColors.surface,
              ),
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
    final diff = (bac - optimal).abs();
    if (diff <= AppConstants.optimalToleranceClose) return DGTColors.green;
    if (diff <= AppConstants.optimalToleranceFar) return DGTColors.orange;
    return DGTColors.red;
  }
}
