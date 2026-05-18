import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/constants/app_constants.dart';
import 'package:dgv/core/constants/route_constants.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/checkpoint_providers.dart';
import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';
import 'package:dgv/widgets/license_card.dart';
import 'package:dgv/widgets/massive_button.dart';

/// Pre-game screen: select which players are playing and choose checkpoint
/// interval, then start Round 0.
class PlayerSelectionScreen extends ConsumerStatefulWidget {
  const PlayerSelectionScreen({super.key});

  @override
  ConsumerState<PlayerSelectionScreen> createState() =>
      _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends ConsumerState<PlayerSelectionScreen> {
  final Set<String> _selectedIds = {};
  int _intervalMinutes = AppConstants.defaultIntervalMinutes;

  Future<void> _startGame(List<PlayerProfile> allPlayers) async {
    final selected = allPlayers
        .where((p) => _selectedIds.contains(p.id))
        .toList();
    if (selected.isEmpty) return;

    final selectedIds = selected.map((p) => p.id).toList();

    await ref.read(gameStateNotifierProvider.notifier).startGame(selectedIds);
    await ref
        .read(checkpointNotifierProvider.notifier)
        .initialize(players: selected, intervalMinutes: _intervalMinutes);

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.roundRobin,
      arguments: RoundRobinArgs(players: selected, round: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncPlayers = ref.watch(playerListNotifierProvider);

    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        title: const Text('Iniciar Control'),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
      ),
      body: asyncPlayers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (players) => _Body(
          players: players,
          selectedIds: _selectedIds,
          intervalMinutes: _intervalMinutes,
          onTogglePlayer: (id) => setState(() {
            if (_selectedIds.contains(id)) {
              _selectedIds.remove(id);
            } else {
              _selectedIds.add(id);
            }
          }),
          onIntervalChanged: (v) => setState(() => _intervalMinutes = v),
          onStart: () => _startGame(players),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.players,
    required this.selectedIds,
    required this.intervalMinutes,
    required this.onTogglePlayer,
    required this.onIntervalChanged,
    required this.onStart,
  });

  final List<PlayerProfile> players;
  final Set<String> selectedIds;
  final int intervalMinutes;
  final void Function(String id) onTogglePlayer;
  final void Function(int minutes) onIntervalChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No hay conductores registrados.\nVuelve al menú y añade jugadores.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: players.length,
            separatorBuilder: (context, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final player = players[index];
              final selected = selectedIds.contains(player.id);
              return Row(
                children: [
                  Checkbox(
                    value: selected,
                    activeColor: DGTColors.primary,
                    onChanged: (_) => onTogglePlayer(player.id),
                  ),
                  Expanded(
                    child: LicenseCard(
                      player: player,
                      onTap: () => onTogglePlayer(player.id),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        _IntervalSelector(
          selected: intervalMinutes,
          onChanged: onIntervalChanged,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: MassiveButton(
            text: 'Iniciar Control (${selectedIds.length} conductores)',
            onPressed: selectedIds.isEmpty ? null : onStart,
          ),
        ),
      ],
    );
  }
}

class _IntervalSelector extends StatelessWidget {
  const _IntervalSelector({required this.selected, required this.onChanged});

  final int selected;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Intervalo entre controles',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: DGTColors.textSecondary),
          ),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: AppConstants.availableIntervalMinutes
                .map((m) => ButtonSegment<int>(value: m, label: Text('$m min')))
                .toList(),
            selected: {selected},
            onSelectionChanged: (s) => onChanged(s.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: DGTColors.primary,
              selectedForegroundColor: DGTColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
