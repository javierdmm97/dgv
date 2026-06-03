import 'dart:async';

import 'package:flutter/material.dart';

import 'package:dgv/core/models/checkpoint_state.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/widgets/massive_button.dart';

/// Displays a single group's countdown with an inline "Ir al Retén" button
/// when the timer is up.
class GroupCountdownCard extends StatefulWidget {
  const GroupCountdownCard({
    super.key,
    required this.group,
    required this.groupNumber,
    required this.players,
    this.onMeasure,
  });

  final GroupCheckpoint group;
  final int groupNumber;
  final List<PlayerProfile> players;
  final VoidCallback? onMeasure;

  @override
  State<GroupCountdownCard> createState() => _GroupCountdownCardState();
}

class _GroupCountdownCardState extends State<GroupCountdownCard> {
  Timer? _ticker;
  bool _expanded = false;

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
    final bgColor = isDue ? DGTColors.red : DGTColors.surface;
    final onDark = isDue;

    return Card(
      color: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row — tap to expand player list
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    isDue ? Icons.warning_amber_rounded : Icons.timer_outlined,
                    color: onDark ? Colors.white : DGTColors.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Grupo ${widget.groupNumber}  '
                      '(${widget.group.playerIds.length} conductores)',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: onDark ? Colors.white : null,
                      ),
                    ),
                  ),
                  Text(
                    isDue ? '¡MEDIR!' : widget.group.formattedTimeRemaining,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onDark ? Colors.white : DGTColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: onDark ? Colors.white : DGTColors.primary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded player list
          if (_expanded && widget.players.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: widget.players.map((p) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: onDark
                              ? Colors.white70
                              : DGTColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${p.name} ${p.surname}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: onDark ? Colors.white : null),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // "Ir al Retén" button — only shown when due
          if (isDue && widget.onMeasure != null) ...[
            const Divider(height: 1, color: DGTColors.dividerOnDark),
            Padding(
              padding: const EdgeInsets.all(12),
              child: MassiveButton(
                text: 'Ir al Retén',
                icon: Icons.directions_car,
                onPressed: widget.onMeasure,
                backgroundColor: Colors.white,
                foregroundColor: DGTColors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
