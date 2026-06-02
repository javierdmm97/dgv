import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/constants/app_constants.dart';
import 'package:dgv/core/constants/route_constants.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/checkpoint_providers.dart';
import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/breathalyzer/presentation/manual_entry_screen.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_provider.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';

/// "El Retén" — staged BAC entry for a group of players.
///
/// All measurements are staged locally first. Fine/feedback screens show a
/// preview of what would happen. Once all players are staged, the officer taps
/// "Confirmar grupo medido" to batch-submit everything to Hive simultaneously.
/// This prevents the race condition on the last player and ensures DGT titles
/// are evaluated after all readings are written.
///
/// - Round 0: back button available to cancel game; after confirm → leaderboard
/// - Round 1+: after confirm → pops back to checkpoint screen
class RoundRobinScreen extends ConsumerStatefulWidget {
  const RoundRobinScreen({super.key, required this.args});

  final RoundRobinArgs args;

  @override
  ConsumerState<RoundRobinScreen> createState() => _RoundRobinScreenState();
}

class _RoundRobinScreenState extends ConsumerState<RoundRobinScreen> {
  // player id → confirmed (staged) BAC value; not written to Hive until confirm
  final Map<String, double> _stagedBac = {};
  String? _measuringId;
  bool _isSubmitting = false;
  bool _submittedSuccessfully = false;

  List<PlayerProfile> get _players => widget.args.players;
  int get _round => widget.args.round;

  List<PlayerProfile> get _activePlayers =>
      _players.where((p) => !p.isIncautado).toList();

  bool get _allStaged =>
      _activePlayers.every((p) => _stagedBac.containsKey(p.id));

  int get _stagedCount =>
      _activePlayers.where((p) => _stagedBac.containsKey(p.id)).length;

  Future<void> _measurePlayer(PlayerProfile player) async {
    if (_measuringId != null || _isSubmitting) return;
    setState(() => _measuringId = player.id);

    final result = await Navigator.push<BACEntryResult>(
      context,
      MaterialPageRoute(
        builder: (_) => ManualEntryScreen(player: player, previewMode: true),
      ),
    );

    if (!mounted) return;
    setState(() => _measuringId = null);

    if (result == null) return;

    setState(() => _stagedBac[result.playerId] = result.bac);

    // Show preview fine/feedback screens (no Hive writes yet).
    if (_round > 0) {
      if (result.isFined) {
        await Navigator.pushNamed(context, AppRoutes.fine, arguments: result);
        if (!mounted) return;
      }
      await Navigator.pushNamed(context, AppRoutes.feedback, arguments: result);
    }
  }

  Future<void> _editPlayer(PlayerProfile player) async {
    if (_measuringId != null || _isSubmitting) return;
    final existingBac = _stagedBac[player.id];
    if (existingBac == null) return;

    setState(() => _measuringId = player.id);

    final result = await Navigator.push<BACEntryResult>(
      context,
      MaterialPageRoute(
        builder: (_) => ManualEntryScreen(
          player: player,
          initialValue: existingBac,
          previewMode: true,
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _measuringId = null);

    if (result == null) return;

    setState(() => _stagedBac[player.id] = result.bac);

    // Show updated preview after edit.
    if (_round > 0) {
      if (result.isFined) {
        await Navigator.pushNamed(context, AppRoutes.fine, arguments: result);
        if (!mounted) return;
      }
      await Navigator.pushNamed(context, AppRoutes.feedback, arguments: result);
    }
  }

  Future<void> _submitAll() async {
    if (!_allStaged || _isSubmitting || _submittedSuccessfully) return;
    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(bACEntryNotifierProvider.notifier);
      final checkpointNotifier = ref.read(checkpointNotifierProvider.notifier);

      // Submit all active players in order — last submitBAC triggers
      // completeGroupMeasurement only AFTER all readings are in Hive.
      for (final player in _activePlayers) {
        final bac = _stagedBac[player.id];
        if (bac == null) continue;
        await notifier.submitBAC(player.id, bac, roundNumber: _round);
      }

      // Incautado players are auto-skipped in the checkpoint.
      for (final player in _players) {
        if (player.isIncautado) {
          await checkpointNotifier.skipPlayerMeasurement(player.id);
        }
      }

      _submittedSuccessfully = true;
      await _finishGroup();
    } finally {
      if (mounted && !_submittedSuccessfully) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _finishGroup() async {
    if (_round == 0) {
      final intervalMinutes =
          widget.args.intervalMinutes ?? AppConstants.defaultIntervalMinutes;
      await ref
          .read(checkpointNotifierProvider.notifier)
          .initialize(players: _players, intervalMinutes: intervalMinutes);
      await ref.read(gameStateNotifierProvider.notifier).advanceRound();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.leaderboard);
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _cancelGame() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cancelar el control?'),
        content: const Text(
          'Se descartará la selección de jugadores y volverás al menú.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(checkpointNotifierProvider.notifier).reset();
      await ref.read(gameStateNotifierProvider.notifier).deleteGame();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roundLabel = _round == 0 ? 'Base' : 'Ronda $_round';
    final canEdit = _round > 0 && !_isSubmitting;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: DGTColors.background,
        appBar: AppBar(
          title: Text('El Retén — $roundLabel'),
          backgroundColor: DGTColors.primary,
          foregroundColor: DGTColors.textOnPrimary,
          automaticallyImplyLeading: false,
          leading: _round == 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _cancelGame,
                  tooltip: 'Cancelar control',
                )
              : null,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProgressIndicator(
                measured: _stagedCount,
                total: _activePlayers.length,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _players.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final player = _players[index];
                    final isStaged = _stagedBac.containsKey(player.id);
                    final isMeasuring = _measuringId == player.id;
                    final stagedBac = _stagedBac[player.id];
                    return _PlayerMeasureCard(
                      player: player,
                      isStaged: isStaged,
                      isMeasuring: isMeasuring,
                      stagedBac: stagedBac,
                      canEdit: canEdit && isStaged && !player.isIncautado,
                      onMeasure:
                          (isStaged || player.isIncautado || _isSubmitting)
                          ? null
                          : () => _measurePlayer(player),
                      onEdit: () => _editPlayer(player),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _ConfirmButton(
                allStaged: _allStaged,
                isSubmitting: _isSubmitting,
                onConfirm: _submitAll,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confirm button
// ---------------------------------------------------------------------------

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.allStaged,
    required this.isSubmitting,
    required this.onConfirm,
  });

  final bool allStaged;
  final bool isSubmitting;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    if (isSubmitting) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: allStaged ? onConfirm : null,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Confirmar grupo medido'),
        style: ElevatedButton.styleFrom(
          backgroundColor: DGTColors.success,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DGTColors.textSecondary.withValues(
            alpha: 0.3,
          ),
          minimumSize: const Size(double.infinity, 64),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Per-player card
// ---------------------------------------------------------------------------

class _PlayerMeasureCard extends StatelessWidget {
  const _PlayerMeasureCard({
    required this.player,
    required this.isStaged,
    required this.isMeasuring,
    required this.stagedBac,
    required this.canEdit,
    required this.onMeasure,
    required this.onEdit,
  });

  final PlayerProfile player;
  final bool isStaged;
  final bool isMeasuring;
  final double? stagedBac;
  final bool canEdit;
  final VoidCallback? onMeasure;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final isIncautado = player.isIncautado;
    Color? cardColor;
    if (isIncautado) {
      cardColor = DGTColors.red.withValues(alpha: 0.08);
    } else if (isStaged) {
      cardColor = DGTColors.success.withValues(alpha: 0.12);
    }

    return Card(
      elevation: isStaged ? 1 : 3,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _PlayerAvatar(player: player, isStaged: isStaged),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${player.name} ${player.surname}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isStaged
                          ? DGTColors.textSecondary
                          : DGTColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isIncautado)
                    Text(
                      '🚗 VEHÍCULO INCAUTADO',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: DGTColors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else if (stagedBac != null)
                    Text(
                      '${stagedBac!.toStringAsFixed(2)} mg/L',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: DGTColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Text(
                      '${player.points} pts',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: DGTColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isIncautado)
              const Icon(Icons.car_crash, color: DGTColors.red, size: 32)
            else if (isStaged) ...[
              if (canEdit)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: DGTColors.primary,
                  tooltip: 'Corregir lectura',
                  onPressed: onEdit,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(right: 8),
                ),
              const Icon(
                Icons.check_circle,
                color: DGTColors.success,
                size: 32,
              ),
            ] else if (isMeasuring)
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else
              ElevatedButton.icon(
                onPressed: onMeasure,
                icon: const Icon(Icons.speed, size: 18),
                label: const Text('Medir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DGTColors.primary,
                  foregroundColor: DGTColors.textOnPrimary,
                  minimumSize: const Size(80, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({required this.player, required this.isStaged});

  final PlayerProfile player;
  final bool isStaged;

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        player.photoPath.isNotEmpty && File(player.photoPath).existsSync();

    return CircleAvatar(
      radius: 24,
      backgroundColor: isStaged ? DGTColors.success : DGTColors.primary,
      backgroundImage: hasPhoto ? FileImage(File(player.photoPath)) : null,
      child: hasPhoto
          ? null
          : Text(
              _initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
    );
  }

  String get _initials {
    final n = player.name.isNotEmpty ? player.name[0] : '';
    final s = player.surname.isNotEmpty ? player.surname[0] : '';
    return '$n$s'.toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// Progress bar
// ---------------------------------------------------------------------------

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.measured, required this.total});

  final int measured;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$measured / $total conductores listos',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: DGTColors.textSecondary),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: total > 0 ? measured / total : 0,
          backgroundColor: DGTColors.textSecondary.withValues(alpha: 0.2),
          color: DGTColors.success,
          minHeight: 8,
        ),
      ],
    );
  }
}
