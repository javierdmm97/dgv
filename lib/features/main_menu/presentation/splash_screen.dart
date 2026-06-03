import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/constants/route_constants.dart';
import 'package:dgv/core/providers/recovery_provider.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/main_menu/presentation/main_menu_screen.dart';
import 'package:dgv/widgets/massive_button.dart';

/// Full-screen DGT-blue splash screen shown on cold launch.
///
/// Displays the DGV logo centered with a white city-skyline silhouette.
/// Shows an "Acceder" button and auto-skips to main menu after 3 seconds.
///
/// Requirements: 5.3 (Splash / Landing Screen)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _autoSkipTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade-in animation for logo
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Auto-skip after 3 seconds
    _autoSkipTimer = Timer(const Duration(seconds: 3), _navigateToMainMenu);
  }

  @override
  void dispose() {
    _autoSkipTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _navigateToMainMenu() async {
    if (!mounted) return;

    // Read recovery state and navigate accordingly
    final recoveryAsync = ref.read(recoveryNotifierProvider);

    await recoveryAsync.when(
      loading: () async {
        // Wait a bit for loading to complete
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        // Default to main menu if still loading
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        );
      },
      error: (error, stack) {
        if (!mounted) return;
        // On error, go to main menu
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        );
      },
      data: (route) {
        if (!mounted) return;

        switch (route) {
          case RecoveryRoute.checkpoint:
            Navigator.of(context).pushReplacementNamed(AppRoutes.game);
          case RecoveryRoute.leaderboard:
            Navigator.of(context).pushReplacementNamed(AppRoutes.leaderboard);
          case RecoveryRoute.mainMenu:
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainMenuScreen()),
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DGTColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            // City skyline silhouette at bottom
            Positioned(left: 0, right: 0, bottom: 0, child: _CitySkyline()),

            // Centered logo
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Image.asset(
                    'assets/logo_app.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // "Acceder" button at bottom
            Positioned(
              left: 16,
              right: 16,
              bottom: 120,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: MassiveButton(
                  text: 'Acceder',
                  icon: Icons.arrow_forward,
                  backgroundColor: Colors.white,
                  foregroundColor: DGTColors.primary,
                  onPressed: _navigateToMainMenu,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// City skyline silhouette (decorative)
// ---------------------------------------------------------------------------

class _CitySkyline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.sizeOf(context).width, 120),
      painter: _SkylinePainter(),
    );
  }
}

class _SkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Simple city skyline silhouette
    path.moveTo(0, h);
    path.lineTo(0, h * 0.6);
    path.lineTo(w * 0.1, h * 0.6);
    path.lineTo(w * 0.1, h * 0.4);
    path.lineTo(w * 0.15, h * 0.4);
    path.lineTo(w * 0.15, h * 0.7);
    path.lineTo(w * 0.25, h * 0.7);
    path.lineTo(w * 0.25, h * 0.3);
    path.lineTo(w * 0.3, h * 0.3);
    path.lineTo(w * 0.3, h * 0.5);
    path.lineTo(w * 0.4, h * 0.5);
    path.lineTo(w * 0.4, h * 0.2);
    path.lineTo(w * 0.45, h * 0.2);
    path.lineTo(w * 0.45, h * 0.6);
    path.lineTo(w * 0.55, h * 0.6);
    path.lineTo(w * 0.55, h * 0.35);
    path.lineTo(w * 0.6, h * 0.35);
    path.lineTo(w * 0.6, h * 0.55);
    path.lineTo(w * 0.7, h * 0.55);
    path.lineTo(w * 0.7, h * 0.25);
    path.lineTo(w * 0.75, h * 0.25);
    path.lineTo(w * 0.75, h * 0.65);
    path.lineTo(w * 0.85, h * 0.65);
    path.lineTo(w * 0.85, h * 0.45);
    path.lineTo(w * 0.9, h * 0.45);
    path.lineTo(w * 0.9, h * 0.7);
    path.lineTo(w, h * 0.7);
    path.lineTo(w, h);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
