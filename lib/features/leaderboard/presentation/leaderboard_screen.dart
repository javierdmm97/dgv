import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/constants/route_constants.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/leaderboard/providers/leaderboard_provider.dart';
import 'package:dgv/widgets/license_card.dart';

/// Leaderboard screen — shows all players sorted by points.
/// Tap a player card to view their full license and BAC graph.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(sortedLeaderboardProvider);

    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        title: const Text('Carnet por Puntos'),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
      ),
      body: players.isEmpty
          ? const _EmptyState()
          : _PlayerList(players: players),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(64),
          child: Center(
            child: Text(
              'Sin conductores registrados.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: DGTColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayerList extends StatelessWidget {
  const _PlayerList({required this.players});

  final List<PlayerProfile> players;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      separatorBuilder: (context, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final player = players[index];
        return Stack(
          alignment: Alignment.topLeft,
          children: [
            LicenseCard(
              player: player,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.license,
                arguments: player.id,
              ),
              onViewLicense: () => Navigator.pushNamed(
                context,
                AppRoutes.licenseViewer,
                arguments: player,
              ),
            ),
            if (index < 3)
              Positioned(top: 8, right: 8, child: _RankBadge(rank: index + 1)),
          ],
        );
      },
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final emoji = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '',
    };
    return Text(emoji, style: const TextStyle(fontSize: 24));
  }
}
