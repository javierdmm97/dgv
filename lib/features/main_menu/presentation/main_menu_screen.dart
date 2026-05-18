import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/constants/dgt_strings.dart';
import 'package:dgv/core/constants/route_constants.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/main_menu/presentation/widgets/fake_error_notification.dart';
import 'package:dgv/features/main_menu/presentation/widgets/fake_news_section.dart';
import 'package:dgv/features/main_menu/providers/main_menu_provider.dart';
import 'package:dgv/widgets/license_card.dart';
import 'package:dgv/widgets/massive_button.dart';

// ---------------------------------------------------------------------------
// Drawer navigation
// ---------------------------------------------------------------------------

class _AppDrawer extends ConsumerWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(mainMenuNotifierProvider);
    final isGameInProgress = asyncState.value?.isGameInProgress ?? false;

    return Drawer(
      backgroundColor: DGTColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeader(),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: 'Inicio',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.popUntil(context, (r) => r.isFirst);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.directions_car_outlined,
                    label: 'Mis Vehículos',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        AppRoutes.playerRegistration,
                      );
                    },
                  ),
                  if (isGameInProgress) ...[
                    _DrawerItem(
                      icon: Icons.local_police_outlined,
                      label: 'Control Activo',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.game);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.emoji_events_outlined,
                      label: 'Clasificación',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.leaderboard);
                      },
                    ),
                  ],
                  _DrawerItem(
                    icon: Icons.newspaper_outlined,
                    label: 'Actualidad DGV',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.fakeNews);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.settings_outlined, size: 18),
                      label: const Text('Ajustes'),
                      style: TextButton.styleFrom(
                        foregroundColor: DGTColors.textSecondary,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ajustes — Próximamente')),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.help_outline, size: 18),
                      label: const Text('Ayuda'),
                      style: TextButton.styleFrom(
                        foregroundColor: DGTColors.textSecondary,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ayuda — Próximamente')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: DGTColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('DGV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Operación DGV',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Text(
            'Dirección General de Vitis',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: DGTColors.primary),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      horizontalTitleGap: 8,
    );
  }
}

/// The main hub screen of Operación DGV.
///
/// Watches [mainMenuNotifierProvider] and handles all three [AsyncValue]
/// states. The [build] method stays under 80 lines by delegating to private
/// widget classes.
///
/// Requirements: 8.1, 8.2, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9, 8.10, 8.11,
///               8.12, 8.13, 8.14
class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(mainMenuNotifierProvider);

    return Scaffold(
      backgroundColor: DGTColors.background,
      endDrawer: const _AppDrawer(),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorBody(error: error),
        data: (state) => _MainMenuBody(state: state),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error fallback
// ---------------------------------------------------------------------------

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          DGTStrings.errorGeneric,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main body — composes all sections
// ---------------------------------------------------------------------------

class _MainMenuBody extends StatelessWidget {
  const _MainMenuBody({required this.state});

  final MainMenuState state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            const FakeErrorNotification(),
            const _MainMenuHeader(),
            const SizedBox(height: 24),
            _GameActionSection(state: state),
            const SizedBox(height: 24),
            _MisVehiculosSection(state: state),
            const SizedBox(height: 24),
            FakeNewsSection(
              articles: kFakeNewsArticles,
              onViewAll: () => Navigator.pushNamed(context, AppRoutes.fakeNews),
            ),
            const SizedBox(height: 32),
          ]),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _MainMenuHeader — DGT logo + menu icon row
// ---------------------------------------------------------------------------

class _MainMenuHeader extends StatelessWidget {
  const _MainMenuHeader();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DGTStrings.mainMenuTitle,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: DGTColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.menu),
              color: DGTColors.primary,
              iconSize: 32,
              tooltip: 'Menú',
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _GameActionSection — Start / Resume button + reset
// ---------------------------------------------------------------------------

class _GameActionSection extends ConsumerWidget {
  const _GameActionSection({required this.state});

  final MainMenuState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = state.isGameInProgress
        ? DGTStrings.resumeGame
        : DGTStrings.startGame;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MassiveButton(
            text: label,
            icon: state.isGameInProgress ? Icons.play_arrow : Icons.flag,
            onPressed: () {
              final route = state.isGameInProgress
                  ? AppRoutes.game
                  : AppRoutes.playerSelection;
              Navigator.pushNamed(context, route);
            },
          ),
          if (state.isGameInProgress) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Nueva Partida'),
              style: OutlinedButton.styleFrom(
                foregroundColor: DGTColors.red,
                side: const BorderSide(color: DGTColors.red),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () => _confirmReset(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Nueva Partida?'),
        content: const Text(
          'Se reiniciará el juego. Los conductores registrados no se borrarán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: DGTColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(mainMenuNotifierProvider.notifier).resetGame();
    }
  }
}

// ---------------------------------------------------------------------------
// _MisVehiculosSection — heading + add player + player list
// ---------------------------------------------------------------------------

class _MisVehiculosSection extends StatelessWidget {
  const _MisVehiculosSection({required this.state});

  final MainMenuState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: DGTStrings.myVehicles,
          trailing: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text(DGTStrings.addPlayer),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.playerRegistration),
          ),
        ),
        const SizedBox(height: 8),
        _PlayerList(players: state.players),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: DGTColors.textPrimary,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _PlayerList extends StatelessWidget {
  const _PlayerList({required this.players});

  final List<PlayerProfile> players;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: Text(
            DGTStrings.errorNoPlayers,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: DGTColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: players.length,
      separatorBuilder: (_, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final player = players[index];
        return LicenseCard(
          key: ValueKey(player.id),
          player: player,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.license,
            arguments: player.id,
          ),
        );
      },
    );
  }
}
