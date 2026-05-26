import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/constants/route_constants.dart';
import 'package:dgv/core/models/checkpoint_state.dart';
import 'package:dgv/core/providers/checkpoint_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/services/notification_service.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';
import 'package:dgv/features/checkpoint/presentation/group_countdown_card.dart';
import 'package:dgv/features/checkpoint/presentation/siren_alert_overlay.dart';
import 'package:dgv/widgets/massive_button.dart';

/// Main game-in-progress screen showing per-group countdown timers.
///
/// Listens for [CheckpointNotifier.isCheckpointActive] transitions to
/// trigger the [SirenAlertOverlay].
class CheckpointScreen extends ConsumerStatefulWidget {
  const CheckpointScreen({super.key});

  @override
  ConsumerState<CheckpointScreen> createState() => _CheckpointScreenState();
}

class _CheckpointScreenState extends ConsumerState<CheckpointScreen> {
  @override
  Widget build(BuildContext context) {
    // Listen for checkpoint activation → show siren overlay
    ref.listen<AsyncValue<CheckpointState?>>(checkpointNotifierProvider, (
      prev,
      next,
    ) {
      final wasActive = prev?.value?.isCheckpointActive ?? false;
      final isNowActive = next.value?.isCheckpointActive ?? false;
      if (!wasActive && isNowActive) {
        Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => const SirenAlertOverlay(),
            fullscreenDialog: true,
          ),
        );
      }
    });

    final asyncState = ref.watch(checkpointNotifierProvider);
    final asyncPlayers = ref.watch(playerListProvider);

    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        title: asyncState.when(
          loading: () => const Text('Control Sorpresa'),
          error: (_, e) => const Text('Control Sorpresa'),
          data: (s) => s == null
              ? const Text('Control Sorpresa')
              : Text('Control Sorpresa — Ronda ${s.currentRound}'),
        ),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
      ),
      floatingActionButton: kDebugMode
          ? FloatingActionButton.small(
              onPressed: () {
                ref
                    .read(checkpointNotifierProvider.notifier)
                    .skipToNextCheckpoint();
                final state = ref.read(checkpointNotifierProvider).value;
                final groupIndex = state?.activeGroupIndex;
                final label = groupIndex != null
                    ? 'Grupo ${groupIndex + 1}'
                    : 'Grupo 1';
                NotificationService.showCheckpointAlert(label);
              },
              tooltip: 'DEBUG: Skip timer + test notification',
              child: const Icon(Icons.fast_forward),
            )
          : null,
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (checkpointState) {
          if (checkpointState == null) {
            return _NoGameBody(onGoLeaderboard: _goLeaderboard);
          }
          if (checkpointState.isCheckpointActive) {
            return _ActiveCheckpointBody(
              state: checkpointState,
              asyncPlayers: asyncPlayers,
              onGoReten: () => _goReten(checkpointState),
              onGoLeaderboard: _goLeaderboard,
            );
          }
          return _CountdownBody(
            state: checkpointState,
            onGoLeaderboard: _goLeaderboard,
          );
        },
      ),
    );
  }

  void _goLeaderboard() => Navigator.pushNamed(context, AppRoutes.leaderboard);

  void _goReten(CheckpointState state) {
    final activeGroup = state.activeGroup;
    if (activeGroup == null) return;

    final asyncPlayers = ref.read(playerListProvider).value ?? [];
    final groupPlayers = asyncPlayers
        .where((p) => activeGroup.playerIds.contains(p.id))
        .toList();

    Navigator.pushNamed(
      context,
      AppRoutes.roundRobin,
      arguments: RoundRobinArgs(
        players: groupPlayers,
        round: state.currentRound,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// No-game fallback
// ---------------------------------------------------------------------------

class _NoGameBody extends StatelessWidget {
  const _NoGameBody({required this.onGoLeaderboard});

  final VoidCallback onGoLeaderboard;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No hay partida en curso.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            MassiveButton(
              text: 'Ver Clasificación',
              onPressed: onGoLeaderboard,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active checkpoint (a group is being measured)
// ---------------------------------------------------------------------------

class _ActiveCheckpointBody extends StatelessWidget {
  const _ActiveCheckpointBody({
    required this.state,
    required this.asyncPlayers,
    required this.onGoReten,
    required this.onGoLeaderboard,
  });

  final CheckpointState state;
  final AsyncValue<dynamic> asyncPlayers;
  final VoidCallback onGoReten;
  final VoidCallback onGoLeaderboard;

  @override
  Widget build(BuildContext context) {
    final activeGroup = state.activeGroup;
    final groupIdx = (state.activeGroupIndex ?? 0) + 1;
    final total = state.totalGroups;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DGTColors.warning,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '🚨 ¡CONTROL ACTIVO!\nGrupo $groupIdx de $total',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: DGTColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (activeGroup != null) ...[
            const SizedBox(height: 12),
            Text(
              '${activeGroup.playerIds.length} conductores en este grupo',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
          const Spacer(),
          MassiveButton(
            text: 'Ir al Retén',
            icon: Icons.directions_car,
            onPressed: onGoReten,
          ),
          const SizedBox(height: 12),
          MassiveButton(text: 'Ver Clasificación', onPressed: onGoLeaderboard),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Countdown display (waiting for next checkpoint)
// ---------------------------------------------------------------------------

class _CountdownBody extends StatelessWidget {
  const _CountdownBody({required this.state, required this.onGoLeaderboard});

  final CheckpointState state;
  final VoidCallback onGoLeaderboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.groups.length,
            separatorBuilder: (context, i) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final group = state.groups[index];
              final isActive =
                  state.isCheckpointActive &&
                  state.activeGroupIndex == group.groupIndex;
              return GroupCountdownCard(
                group: group,
                groupNumber: group.groupIndex + 1,
                isActive: isActive,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: MassiveButton(
            text: 'Ver Clasificación',
            onPressed: onGoLeaderboard,
          ),
        ),
      ],
    );
  }
}
