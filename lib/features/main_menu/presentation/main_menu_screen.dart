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
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _GameActionSection — Start / Resume button
// ---------------------------------------------------------------------------

class _GameActionSection extends StatelessWidget {
  const _GameActionSection({required this.state});

  final MainMenuState state;

  @override
  Widget build(BuildContext context) {
    final label = state.isGameInProgress
        ? DGTStrings.resumeGame
        : DGTStrings.startGame;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MassiveButton(
        text: label,
        icon: state.isGameInProgress ? Icons.play_arrow : Icons.flag,
        onPressed: () {
          final route = state.isGameInProgress
              ? AppRoutes.game
              : AppRoutes.playerSelection;
          Navigator.pushNamed(context, route);
        },
      ),
    );
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
