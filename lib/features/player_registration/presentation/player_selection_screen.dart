import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/constants/app_constants.dart';
import 'package:dgv/core/constants/route_constants.dart';
import 'package:dgv/core/models/player_profile.dart';
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
  double _preGameBeers = 0.0;

  void _toggleSelectAll(List<PlayerProfile> allPlayers) {
    final allSelected = allPlayers.every((p) => _selectedIds.contains(p.id));
    setState(() {
      if (allSelected) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(allPlayers.map((p) => p.id));
      }
    });
  }

  Future<void> _startGame(List<PlayerProfile> allPlayers) async {
    final selected = allPlayers
        .where((p) => _selectedIds.contains(p.id))
        .toList();
    if (selected.isEmpty) return;

    final selectedIds = selected.map((p) => p.id).toList();

    await ref
        .read(gameStateNotifierProvider.notifier)
        .startGame(selectedIds, preGameBeers: _preGameBeers);

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.roundRobin,
      arguments: RoundRobinArgs(
        players: selected,
        round: 0,
        intervalMinutes: _intervalMinutes,
      ),
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
          preGameBeers: _preGameBeers,
          onTogglePlayer: (id) => setState(() {
            if (_selectedIds.contains(id)) {
              _selectedIds.remove(id);
            } else {
              _selectedIds.add(id);
            }
          }),
          onIntervalChanged: (v) => setState(() => _intervalMinutes = v),
          onPreGameBeersChanged: (v) => setState(() => _preGameBeers = v),
          onSelectAll: () => _toggleSelectAll(players),
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
    required this.preGameBeers,
    required this.onTogglePlayer,
    required this.onSelectAll,
    required this.onIntervalChanged,
    required this.onPreGameBeersChanged,
    required this.onStart,
  });

  final List<PlayerProfile> players;
  final Set<String> selectedIds;
  final int intervalMinutes;
  final double preGameBeers;
  final void Function(String id) onTogglePlayer;
  final VoidCallback onSelectAll;
  final void Function(int minutes) onIntervalChanged;
  final ValueChanged<double> onPreGameBeersChanged;
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

    final allSelected = players.every((p) => selectedIds.contains(p.id));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${selectedIds.length} / ${players.length} seleccionados',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: DGTColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: onSelectAll,
                icon: Icon(
                  allSelected
                      ? Icons.deselect_outlined
                      : Icons.select_all_outlined,
                  size: 18,
                ),
                label: Text(
                  allSelected ? 'Deseleccionar todos' : 'Seleccionar todos',
                ),
              ),
            ],
          ),
        ),
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
        _PreGameBeersInput(
          value: preGameBeers,
          onChanged: onPreGameBeersChanged,
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

class _PreGameBeersInput extends StatefulWidget {
  const _PreGameBeersInput({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_PreGameBeersInput> createState() => _PreGameBeersInputState();
}

class _PreGameBeersInputState extends State<_PreGameBeersInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == 0.0 ? '' : widget.value.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmit(String text) {
    final parsed = double.tryParse(text.replaceAll(',', '.')) ?? 0.0;
    final clamped = parsed.clamp(0.0, 10.0);
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          const Text('🍺', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cervezas previas al control',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: DGTColors.textSecondary),
            ),
          ),
          SizedBox(
            width: 72,
            child: TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '0.0',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
              ),
              onChanged: _onSubmit,
              onEditingComplete: () {
                _onSubmit(_controller.text);
                FocusScope.of(context).unfocus();
              },
            ),
          ),
        ],
      ),
    );
  }
}
