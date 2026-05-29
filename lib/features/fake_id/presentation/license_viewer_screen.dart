import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/core/utils/points_calculator.dart';

/// Full-screen two-sided license viewer.
///
/// Page 1: License front (PNG from [PlayerProfile.licenseImagePath]).
/// Page 2: License back — PNG from [PlayerProfile.licenseBackImagePath] if
///         available, otherwise a dynamic widget built from readings.
///
/// Each page is wrapped in [InteractiveViewer] for pinch-to-zoom (1×–4×).
/// A two-dot page indicator shows the current page.
class LicenseViewerScreen extends StatefulWidget {
  const LicenseViewerScreen({super.key, required this.player});

  final PlayerProfile player;

  @override
  State<LicenseViewerScreen> createState() => _LicenseViewerScreenState();
}

class _LicenseViewerScreenState extends State<LicenseViewerScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('${player.name} ${player.surname}'),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                // Page 1 — License front
                _ZoomablePage(child: _LicenseFrontPage(player: player)),
                // Page 2 — License back (PNG or dynamic fallback)
                _ZoomablePage(
                  child: player.licenseBackImagePath != null
                      ? _LicenseBackImagePage(
                          path: player.licenseBackImagePath!,
                        )
                      : _DynamicBackWidget(player: player),
                ),
              ],
            ),
          ),
          _PageIndicator(currentPage: _currentPage, pageCount: 2),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page wrapper
// ---------------------------------------------------------------------------

class _ZoomablePage extends StatelessWidget {
  const _ZoomablePage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: Center(child: child),
    );
  }
}

// ---------------------------------------------------------------------------
// License front page
// ---------------------------------------------------------------------------

class _LicenseFrontPage extends StatelessWidget {
  const _LicenseFrontPage({required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    final path = player.licenseImagePath;
    if (path.isEmpty) {
      return const Center(
        child: Text(
          'Carnet no generado',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Text(
          'No se pudo cargar el carnet',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// License back — PNG version
// ---------------------------------------------------------------------------

class _LicenseBackImagePage extends StatelessWidget {
  const _LicenseBackImagePage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Text(
          'No se pudo cargar el reverso',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// License back — dynamic fallback (no PNG yet)
// ---------------------------------------------------------------------------

/// Renders the license back content dynamically from [PlayerProfile] data.
/// Used when [PlayerProfile.licenseBackImagePath] is null (pre-Phase 3 player).
class _DynamicBackWidget extends StatelessWidget {
  const _DynamicBackWidget({required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    final activeReadings =
        player.readings.where((r) => r.roundNumber > 0).toList()
          ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    final perfection = PointsCalculator.calculatePerfectionScore(
      player.readings,
      player.sex,
      player.bodySize,
    );
    final perfectionStr = perfection.isFinite
        ? perfection.toStringAsFixed(2)
        : '—';

    return Container(
      color: DGTColors.licenseId,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HISTORIAL DE MEDICIONES',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: DGTColors.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Round-by-round table
            if (activeReadings.isEmpty)
              const Text(
                'Sin lecturas activas',
                style: TextStyle(color: DGTColors.textSecondary),
              )
            else
              ...activeReadings.map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    'R${r.roundNumber}: ${r.bac.toStringAsFixed(2)} mg/L '
                    '(${r.formattedPointsChange})',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Fine log
            if (player.fineCount > 0) ...[
              Text(
                'MULTAS',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DGTColors.red,
                ),
              ),
              const SizedBox(height: 4),
              ...List.generate(
                player.fineCount,
                (i) => Text(
                  'Multa ${i + 1} — 100€',
                  style: const TextStyle(fontSize: 13, color: DGTColors.red),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Total money lost
            Text(
              'Total: ${player.moneyLost}€',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Perfection score
            Text(
              'Precisión: $perfectionStr',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: DGTColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page indicator
// ---------------------------------------------------------------------------

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.currentPage, required this.pageCount});

  final int currentPage;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? DGTColors.primary : Colors.white38,
          ),
        );
      }),
    );
  }
}
