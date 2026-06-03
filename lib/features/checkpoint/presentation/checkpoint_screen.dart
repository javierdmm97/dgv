import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/constants/route_constants.dart';
import 'package:dgv/core/models/checkpoint_state.dart';
import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/navigation/app_route_observer.dart';
import 'package:dgv/core/providers/checkpoint_providers.dart';
import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/services/notification_service.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';
import 'package:dgv/features/checkpoint/presentation/group_countdown_card.dart';
import 'package:dgv/widgets/massive_button.dart';

/// Main game-in-progress screen showing per-group countdown timers.
///
/// Timers count down to each group's next checkpoint. When a group's timer
/// reaches zero the card turns red and shows an "Ir al Retén" button.
/// No siren overlay — just the timers.
class CheckpointScreen extends ConsumerStatefulWidget {
  const CheckpointScreen({super.key});

  @override
  ConsumerState<CheckpointScreen> createState() => _CheckpointScreenState();
}

class _CheckpointScreenState extends ConsumerState<CheckpointScreen>
    with RouteAware {
  bool _isShowingAwards = false;
  bool _isAwardsShowScheduled = false;

  @override
  void initState() {
    super.initState();
    // Show round-awards sheet whenever a new round completes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(lastRoundAwardsProvider, (_, awards) {
        if (awards != null && awards.isNotEmpty && mounted) {
          _showPendingAwardsIfVisible();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _showPendingAwardsIfVisible();
  }

  void _showPendingAwardsIfVisible() {
    if (!mounted || _isShowingAwards || _isAwardsShowScheduled) return;

    _isAwardsShowScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isAwardsShowScheduled = false;
      if (!mounted || _isShowingAwards) return;
      if (ModalRoute.of(context)?.isCurrent != true) return;

      final awards = ref.read(lastRoundAwardsProvider);
      if (awards == null || awards.isEmpty) return;
      _showAwardsSheet(awards);
    });
  }

  void _showAwardsSheet(Map<String, DGTTitle> awards) {
    _isShowingAwards = true;
    final players = ref.read(playerListProvider).value ?? [];
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => _RoundAwardsSheet(
        awards: awards,
        players: players,
        onClose: () {
          ref.read(lastRoundAwardsProvider.notifier).state = null;
          Navigator.pop(ctx);
        },
      ),
    ).whenComplete(() {
      // Safety net: clear provider even if sheet is dismissed by any other means.
      ref.read(lastRoundAwardsProvider.notifier).state = null;
      _isShowingAwards = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(checkpointNotifierProvider);
    final asyncPlayers = ref.watch(playerListProvider);
    final currentRound = ref.watch(
      gameStateNotifierProvider.select((v) => v.value?.currentRound),
    );

    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        title: asyncState.when(
          loading: () => const Text('Control Sorpresa'),
          error: (_, _) => const Text('Control Sorpresa'),
          data: (s) => s == null
              ? const Text('Control Sorpresa')
              : Text('Ronda ${currentRound ?? s.currentRound}'),
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
                final gameRound =
                    ref.read(gameStateNotifierProvider).value?.currentRound ??
                    1;
                NotificationService.showGroupTimer(
                  99,
                  label,
                  DateTime.now().add(const Duration(seconds: 10)),
                  gameRound,
                );
              },
              tooltip: 'Saltar timer + probar notificación',
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
          return _TimersBody(
            state: checkpointState,
            players: asyncPlayers.value ?? [],
            onGoReten: _goReten,
            onGoLeaderboard: _goLeaderboard,
          );
        },
      ),
    );
  }

  void _goLeaderboard() => Navigator.pushNamed(context, AppRoutes.leaderboard);

  void _goReten(GroupCheckpoint group, CheckpointState state) {
    final allPlayers = ref.read(playerListProvider).value ?? [];
    final groupPlayers = allPlayers
        .where((p) => group.playerIds.contains(p.id))
        .toList();

    final gameRound =
        ref.read(gameStateNotifierProvider).value?.currentRound ??
        state.currentRound;

    Navigator.pushNamed(
      context,
      AppRoutes.roundRobin,
      arguments: RoundRobinArgs(players: groupPlayers, round: gameRound),
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
// Round awards bottom sheet
// ---------------------------------------------------------------------------

class _RoundAwardsSheet extends StatelessWidget {
  const _RoundAwardsSheet({
    required this.awards,
    required this.players,
    required this.onClose,
  });

  final Map<String, DGTTitle> awards;
  final List<PlayerProfile> players;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final entries = awards.entries.toList();
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              '🏅 Títulos de la Ronda',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: DGTColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: entries.map((entry) {
                  final player = players
                      .where((p) => p.id == entry.key)
                      .firstOrNull;
                  final name = player != null
                      ? '${player.name} ${player.surname}'
                      : entry.key;
                  final title = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Text(title.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title.displayName,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                name,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: DGTColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: MassiveButton(text: 'Cerrar', onPressed: onClose),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timers list
// ---------------------------------------------------------------------------

class _TimersBody extends StatelessWidget {
  const _TimersBody({
    required this.state,
    required this.players,
    required this.onGoReten,
    required this.onGoLeaderboard,
  });

  final CheckpointState state;
  final List<PlayerProfile> players;
  final void Function(GroupCheckpoint group, CheckpointState state) onGoReten;
  final VoidCallback onGoLeaderboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.groups.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final group = state.groups[index];
              final groupPlayers = players
                  .where((p) => group.playerIds.contains(p.id))
                  .toList();
              return GroupCountdownCard(
                group: group,
                groupNumber: group.groupIndex + 1,
                players: groupPlayers,
                onMeasure: () => onGoReten(group, state),
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
