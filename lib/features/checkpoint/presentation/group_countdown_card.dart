import 'dart:async';

import 'package:flutter/material.dart';

import 'package:dgv/core/models/checkpoint_state.dart';
import 'package:dgv/core/theme/dgt_colors.dart';

/// Displays a single group's countdown to next checkpoint.
///
/// Uses a local 1-second [Timer] so the MM:SS display updates without
/// requiring the parent to emit a new provider state every second.
class GroupCountdownCard extends StatefulWidget {
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
  State<GroupCountdownCard> createState() => _GroupCountdownCardState();
}

class _GroupCountdownCardState extends State<GroupCountdownCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDue = widget.group.isDue;
    final bgColor = widget.isActive
        ? DGTColors.warning
        : isDue
        ? DGTColors.red
        : DGTColors.surface;
    final label = isDue ? '¡MEDIR AHORA!' : widget.group.formattedTimeRemaining;

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
                'Grupo ${widget.groupNumber}  (${widget.group.playerIds.length} conductores)',
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
