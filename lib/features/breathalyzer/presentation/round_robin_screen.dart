import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/constants/route_constants.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/breathalyzer/presentation/manual_entry_screen.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';
import 'package:dgv/widgets/license_card.dart';
import 'package:dgv/widgets/massive_button.dart';

/// "El Retén" — sequential round-robin BAC entry for a group of players.
///
/// Receives [RoundRobinArgs] as route argument.
/// - Round 0: advances silently after all measured → replaces with leaderboard
/// - Round 1+: shows [FeedbackScreen] after each entry, pops to checkpoint
class RoundRobinScreen extends ConsumerStatefulWidget {
  const RoundRobinScreen({super.key, required this.args});

  final RoundRobinArgs args;

  @override
  ConsumerState<RoundRobinScreen> createState() => _RoundRobinScreenState();
}

class _RoundRobinScreenState extends ConsumerState<RoundRobinScreen> {
  int _currentIndex = 0;
  final Set<String> _measuredIds = {};

  List<PlayerProfile> get _players => widget.args.players;
  int get _round => widget.args.round;

  PlayerProfile get _currentPlayer => _players[_currentIndex];

  bool get _allMeasured => _measuredIds.length >= _players.length;

  Future<void> _measureCurrent() async {
    final result = await Navigator.push<BACEntryResult>(
      context,
      MaterialPageRoute(
        builder: (_) => ManualEntryScreen(player: _currentPlayer),
      ),
    );

    if (result == null || !mounted) return;

    setState(() => _measuredIds.add(result.playerId));

    // Show feedback for rounds 1+
    if (_round > 0) {
      if (result.isFined) {
        await Navigator.pushNamed(context, AppRoutes.fine, arguments: result);
        if (!mounted) return;
      }
      await Navigator.pushNamed(context, AppRoutes.feedback, arguments: result);
      if (!mounted) return;
    }

    if (_allMeasured) {
      await _finishGroup();
      return;
    }

    // Advance to next unmeasured player
    _advanceToNext();
  }

  void _advanceToNext() {
    for (var i = 1; i <= _players.length; i++) {
      final idx = (_currentIndex + i) % _players.length;
      if (!_measuredIds.contains(_players[idx].id)) {
        setState(() => _currentIndex = idx);
        return;
      }
    }
  }

  Future<void> _finishGroup() async {
    if (_round == 0) {
      // Baseline complete — advance game to round 1 and show leaderboard
      await ref.read(gameStateNotifierProvider.notifier).advanceRound();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.leaderboard);
    } else {
      // Active round group complete — pop back to checkpoint screen
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roundLabel = _round == 0 ? 'Base' : 'Ronda $_round';

    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        title: Text('El Retén — $roundLabel'),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProgressIndicator(
              measured: _measuredIds.length,
              total: _players.length,
            ),
            const SizedBox(height: 24),
            Expanded(child: LicenseCard(player: _currentPlayer)),
            const SizedBox(height: 24),
            MassiveButton(
              text: 'Medir a ${_currentPlayer.name}',
              icon: Icons.speed,
              onPressed: _allMeasured ? null : _measureCurrent,
            ),
          ],
        ),
      ),
    );
  }
}

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
          '$measured / $total conductores medidos',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: DGTColors.textSecondary),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: total > 0 ? measured / total : 0,
          backgroundColor: DGTColors.textSecondary.withValues(alpha: 0.2),
          color: DGTColors.primary,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
