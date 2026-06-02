import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:dgv/core/constants/dgt_strings.dart';
import 'package:dgv/core/constants/route_constants.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/providers/repository_providers.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/fake_id/services/license_export_service.dart';
import 'package:dgv/features/main_menu/providers/ceremony_provider.dart';
import 'package:dgv/widgets/massive_button.dart';

/// End-of-game ceremony: top 3 podium, Coleccionista prize,
/// Environmental Distinctives with sticker assets, and action buttons.
class FinalCeremonyScreen extends ConsumerWidget {
  const FinalCeremonyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(ceremonyDataProvider);

    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        title: const Text('Ceremonia Final'),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
        automaticallyImplyLeading: false,
      ),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            _FallbackBody(onReturn: () => _returnToMenu(context, ref)),
        data: (data) => _CeremonyBody(
          data: data,
          onReturn: () => _returnToMenu(context, ref),
          onViewLicenses: () =>
              Navigator.pushNamed(context, AppRoutes.vehicleList),
          onExportLicenses: () => _exportLicenses(context, ref),
        ),
      ),
    );
  }

  Future<void> _exportLicenses(BuildContext context, WidgetRef ref) async {
    final players =
        ref.read(playerListNotifierProvider).value ?? <PlayerProfile>[];
    final gameState = ref.read(gameStateNotifierProvider).value;
    final gamePlayers = gameState != null && gameState.playerIds.isNotEmpty
        ? players.where((p) => gameState.playerIds.contains(p.id)).toList()
        : players;

    final paths = await LicenseExportService.exportAll(gamePlayers);
    if (paths.isEmpty) return;

    final xFiles = paths.map((p) => XFile(p)).toList();
    await SharePlus.instance.share(
      ShareParams(files: xFiles, subject: 'Carnets DGV'),
    );
  }

  Future<void> _returnToMenu(BuildContext context, WidgetRef ref) async {
    await ref.read(gameStateNotifierProvider.notifier).finishGame();

    final repo = ref.read(playerRepositoryProvider);
    final players = await repo.getAll();
    for (final player in players) {
      await repo.update(
        player.copyWith(
          points: 15,
          readings: const [],
          titleCounts: const {},
          crossedOptimalLine: false,
          fineCount: 0,
          moneyLost: 0,
          licenseImagePath: '',
          licenseBackImagePath: '',
          isIncautado: false,
        ),
      );
    }

    if (!context.mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}

// ---------------------------------------------------------------------------
// Main ceremony body
// ---------------------------------------------------------------------------

class _CeremonyBody extends StatelessWidget {
  const _CeremonyBody({
    required this.data,
    required this.onReturn,
    required this.onViewLicenses,
    required this.onExportLicenses,
  });

  final CeremonyData data;
  final VoidCallback onReturn;
  final VoidCallback onViewLicenses;
  final Future<void> Function() onExportLicenses;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Podium(players: data.top3),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'Premio Especial'),
              const SizedBox(height: 12),
              _ColeccionistaRow(winner: data.coleccionista),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'Los más contaminantes 🏭'),
              const SizedBox(height: 12),
              _EnvironmentalList(players: data.environmentals),
              const SizedBox(height: 32),
              MassiveButton(
                text: DGTStrings.viewAllLicenses,
                icon: Icons.badge_outlined,
                onPressed: onViewLicenses,
              ),
              const SizedBox(height: 12),
              _ExportButton(onExport: onExportLicenses),
              const SizedBox(height: 12),
              MassiveButton(
                text: DGTStrings.returnToMenu,
                icon: Icons.home_outlined,
                onPressed: onReturn,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        const _ConfettiOverlay(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Export button with loading state
// ---------------------------------------------------------------------------

class _ExportButton extends StatefulWidget {
  const _ExportButton({required this.onExport});

  final Future<void> Function() onExport;

  @override
  State<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<_ExportButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: DGTColors.success,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.download_outlined),
        label: Text(
          _loading ? 'Generando carnets…' : 'Exportar Carnets',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: _loading
            ? null
            : () async {
                setState(() => _loading = true);
                try {
                  await widget.onExport();
                } finally {
                  if (mounted) setState(() => _loading = false);
                }
              },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confetti overlay (auto-stops after 3 s)
// ---------------------------------------------------------------------------

class _ConfettiOverlay extends StatefulWidget {
  const _ConfettiOverlay();

  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(60, (_) => _Particle(rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        if (_ctrl.isCompleted) return const SizedBox.shrink();
        return IgnorePointer(
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ConfettiPainter(_particles, _ctrl.value),
          ),
        );
      },
    );
  }
}

class _Particle {
  _Particle(Random rng)
    : x = rng.nextDouble(),
      delay = rng.nextDouble() * 0.4,
      size = 6 + rng.nextDouble() * 8,
      color = _kColors[rng.nextInt(_kColors.length)],
      spin = rng.nextDouble() * 2 * pi;

  final double x;
  final double delay;
  final double size;
  final Color color;
  final double spin;

  static const _kColors = [
    Color(0xFFFFD700),
    Color(0xFF003DA5),
    Color(0xFFD32F2F),
    Color(0xFF388E3C),
    Color(0xFFFF6F00),
    Color(0xFFAB47BC),
  ];
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter(this.particles, this.t);

  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final progress = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (progress <= 0) continue;
      final y = size.height * progress;
      final x = size.width * p.x;
      paint.color = p.color.withValues(alpha: 1 - progress * 0.6);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * progress * 4);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.5,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Podium
// ---------------------------------------------------------------------------

class _Podium extends StatelessWidget {
  const _Podium({required this.players});

  final List<PlayerProfile> players;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const _SectionTitle(title: 'Podio Final'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (players.length >= 2)
              _PodiumSlot(player: players[1], rank: 2, height: 80),
            if (players.isNotEmpty)
              _PodiumSlot(player: players[0], rank: 1, height: 110),
            if (players.length >= 3)
              _PodiumSlot(player: players[2], rank: 3, height: 60),
          ],
        ),
      ],
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.player,
    required this.rank,
    required this.height,
  });

  final PlayerProfile player;
  final int rank;
  final double height;

  @override
  Widget build(BuildContext context) {
    final medal = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      _ => '🥉',
    };
    final avatarSize = rank == 1 ? 64.0 : 52.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(medal, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          _PlayerAvatar(player: player, size: avatarSize),
          const SizedBox(height: 6),
          Text(
            player.name,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${player.points} pts',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: DGTColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Container(
            width: 72,
            height: height,
            decoration: BoxDecoration(
              color: switch (rank) {
                1 => const Color(0xFFFFD700),
                2 => const Color(0xFFB0BEC5),
                _ => const Color(0xFFBE8A3D),
              },
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({required this.player, required this.size});

  final PlayerProfile player;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: DGTColors.primary.withValues(alpha: 0.15),
      backgroundImage: player.photoPath.isNotEmpty
          ? AssetImage(player.photoPath)
          : null,
      child: player.photoPath.isEmpty
          ? Text(
              player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
                color: DGTColors.primary,
              ),
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Coleccionista de Títulos row
// ---------------------------------------------------------------------------

class _ColeccionistaRow extends StatelessWidget {
  const _ColeccionistaRow({required this.winner});

  final PlayerProfile? winner;

  @override
  Widget build(BuildContext context) {
    final winnerName = winner != null
        ? '${winner!.name} ${winner!.surname}'
        : 'Sin datos';
    final totalTitles =
        winner?.titleCounts.values.fold(0, (s, c) => s + c) ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DGTColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DGTColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Text('👑', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DGTStrings.coleccionistaTitulos,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DGTColors.primary,
                  ),
                ),
                Text(
                  DGTStrings.descColeccionistaTitulos,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: DGTColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  winnerName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (totalTitles > 0)
                Text(
                  '$totalTitles títulos',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: DGTColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Environmental Distinctives list with stagger animation
// ---------------------------------------------------------------------------

/// Asset path for each rank (1-based index).
String _stickerAsset(int rank) => switch (rank) {
  1 => 'assets/environmentalDistinctives/sin_pegatina.png',
  2 => 'assets/environmentalDistinctives/pegatina_b.png',
  3 => 'assets/environmentalDistinctives/pegatina_c.png',
  4 => 'assets/environmentalDistinctives/pegatina_eco.png',
  _ => 'assets/environmentalDistinctives/pegatina_0_emisiones.png',
};

class _EnvironmentalList extends StatefulWidget {
  const _EnvironmentalList({required this.players});

  final List<PlayerProfile> players;

  @override
  State<_EnvironmentalList> createState() => _EnvironmentalListState();
}

class _EnvironmentalListState extends State<_EnvironmentalList>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
      widget.players.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      ),
    );
    _fades = _ctrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slides = _fades
        .map(
          (f) => Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(f),
        )
        .toList();

    for (var i = 0; i < _ctrls.length; i++) {
      Future.delayed(Duration(milliseconds: i * 250), () {
        if (mounted) _ctrls[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.players.isEmpty) {
      return Center(
        child: Text(
          'Sin datos suficientes',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: DGTColors.textSecondary),
        ),
      );
    }

    return Column(
      children: List.generate(widget.players.length, (i) {
        final player = widget.players[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FadeTransition(
            opacity: _fades[i],
            child: SlideTransition(
              position: _slides[i],
              child: _EnvironmentalCard(rank: i + 1, player: player),
            ),
          ),
        );
      }),
    );
  }
}

class _EnvironmentalCard extends StatelessWidget {
  const _EnvironmentalCard({required this.rank, required this.player});

  final int rank;
  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: DGTColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Image.asset(
            _stickerAsset(rank),
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${player.name} ${player.surname}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${player.maxBAC.toStringAsFixed(2)} mg/L',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section title
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: DGTColors.primary,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fallback if ceremony data fails to load
// ---------------------------------------------------------------------------

class _FallbackBody extends StatelessWidget {
  const _FallbackBody({required this.onReturn});

  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '🏆',
            style: TextStyle(fontSize: 72),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Ceremonia Final',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: DGTColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          MassiveButton(
            text: DGTStrings.returnToMenu,
            icon: Icons.home_outlined,
            onPressed: onReturn,
          ),
        ],
      ),
    );
  }
}
