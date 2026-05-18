import 'package:flutter/material.dart';

import 'package:dgv/core/models/checkpoint_state.dart';
import 'package:dgv/core/theme/dgt_colors.dart';

/// Displays a single group's countdown to next checkpoint.
class GroupCountdownCard extends StatelessWidget {
  const GroupCountdownCard({
    super.key,
    required this.group,
    required this.groupNumber,
    this.isActive = false,
  });

  final GroupCheckpoint group;
  final int groupNumber;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isDue = group.isDue;
    final bgColor = isActive
        ? DGTColors.warning
        : isDue
        ? DGTColors.red
        : DGTColors.surface;
    final label = isDue ? '¡MEDIR AHORA!' : group.formattedTimeRemaining;

    return Card(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              isDue ? Icons.warning_amber_rounded : Icons.timer_outlined,
              color: isDue ? DGTColors.textOnPrimary : DGTColors.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Grupo $groupNumber  (${group.playerIds.length} conductores)',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDue ? DGTColors.textOnPrimary : DGTColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
