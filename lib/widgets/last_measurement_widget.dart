import 'package:flutter/material.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';

/// Displays the player's most recent active BrAC reading.
///
/// Shows "Último registro: 0.XX mg/L — Ronda N" for the last round-1+
/// reading. Returns [SizedBox.shrink] when the player has no active readings.
///
/// Reactivity: place inside a widget that already watches the player via
/// a Riverpod provider — the parent rebuild propagates here automatically.
class LastMeasurementWidget extends StatelessWidget {
  const LastMeasurementWidget({super.key, required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    // Only consider active-round readings (round > 0).
    final last = player.readings.where((r) => r.roundNumber > 0).lastOrNull;

    if (last == null) return const SizedBox.shrink();

    return Text(
      'Último registro: ${last.bac.toStringAsFixed(2)} mg/L — Ronda ${last.roundNumber}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: 16,
        color: DGTColors.textSecondary,
      ),
    );
  }
}
