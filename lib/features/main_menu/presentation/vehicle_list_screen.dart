import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/constants/route_constants.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/theme/dgt_colors.dart';

/// Browse all registered players in a 2-per-row grid.
/// Tap a player to view their license. FAB adds a new player.
class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPlayers = ref.watch(playerListNotifierProvider);

    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        title: const Text('Mis Vehículos'),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.playerRegistration),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
      ),
      body: asyncPlayers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (players) => players.isEmpty
            ? const _EmptyState()
            : _PlayerGrid(players: players),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No hay conductores registrados.\nPulsa + para añadir uno.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: DGTColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _PlayerGrid extends StatelessWidget {
  const _PlayerGrid({required this.players});

  final List<PlayerProfile> players;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: players.length,
      itemBuilder: (context, index) => _PlayerCard(player: players[index]),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.licenseViewer,
        arguments: player,
      ),
      child: Card(
        elevation: 3,
        color: DGTColors.licenseId,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PlayerAvatar(player: player),
              const SizedBox(height: 10),
              Text(
                player.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DGTColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                player.surname,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: DGTColors.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              _PointsBadge(points: player.points),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        player.photoPath.isNotEmpty && File(player.photoPath).existsSync();

    return CircleAvatar(
      radius: 36,
      backgroundColor: DGTColors.primary,
      backgroundImage: hasPhoto ? FileImage(File(player.photoPath)) : null,
      child: hasPhoto
          ? null
          : Text(
              _initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
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

class _PointsBadge extends StatelessWidget {
  const _PointsBadge({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      color: DGTColors.primary,
      child: Text(
        '$points pts',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
