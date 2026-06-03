import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/fake_id/services/license_generator.dart';

/// Full-screen two-sided license viewer locked to landscape orientation.
///
/// Page 1: License front (PNG from [PlayerProfile.licenseImagePath]).
/// Page 2: License back (PNG from [PlayerProfile.licenseBackImagePath]).
///
/// Both pages regenerate their PNG on-demand if the file is missing.
/// Each page is wrapped in [InteractiveViewer] for pinch-to-zoom (1×–4×).
class LicenseViewerScreen extends StatefulWidget {
  const LicenseViewerScreen({super.key, required this.player});

  final PlayerProfile player;

  @override
  State<LicenseViewerScreen> createState() => _LicenseViewerScreenState();
}

class _LicenseViewerScreenState extends State<LicenseViewerScreen>
    with WidgetsBindingObserver {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lockLandscape();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final backPath = widget.player.licenseBackImagePath;
    if (backPath != null &&
        backPath.isNotEmpty &&
        File(backPath).existsSync()) {
      precacheImage(FileImage(File(backPath)), context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _restorePortrait();
    _pageController.dispose();
    super.dispose();
  }

  // Restore portrait when the app is backgrounded so that if the user returns
  // to a different screen (e.g. via the recents list) it shows correctly.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _restorePortrait();
    } else if (state == AppLifecycleState.resumed && mounted) {
      _lockLandscape();
    }
  }

  void _lockLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _restorePortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
        toolbarHeight: 40,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                RepaintBoundary(
                  child: _ZoomablePage(
                    child: _LicenseFrontPage(player: player),
                  ),
                ),
                RepaintBoundary(
                  child: _ZoomablePage(child: _LicenseBackPage(player: player)),
                ),
              ],
            ),
          ),
          _PageIndicator(currentPage: _currentPage, pageCount: 2),
          const SizedBox(height: 8),
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

  static Future<String?> _resolvedPath(PlayerProfile player) async {
    final path = player.licenseImagePath;
    if (path.isNotEmpty && File(path).existsSync()) return path;
    try {
      return await LicenseGenerator.generate(player);
    } on Exception {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _resolvedPath(player),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        final path = snap.data;
        if (path == null || path.isEmpty) {
          return const Center(
            child: Text(
              'No se pudo generar el carnet',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return Image.file(
          File(path),
          fit: BoxFit.contain,
          errorBuilder: (_, e, st) => const Center(
            child: Text(
              'No se pudo cargar el carnet',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// License back page
// ---------------------------------------------------------------------------

class _LicenseBackPage extends StatelessWidget {
  const _LicenseBackPage({required this.player});

  final PlayerProfile player;

  static Future<String?> _resolvedPath(PlayerProfile player) async {
    final path = player.licenseBackImagePath;
    if (path != null && path.isNotEmpty && File(path).existsSync()) return path;
    try {
      return await LicenseGenerator.generateBack(player);
    } on Exception {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _resolvedPath(player),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        final path = snap.data;
        if (path == null || path.isEmpty) {
          return const Center(
            child: Text(
              'No se pudo cargar el reverso',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return Image.file(
          File(path),
          fit: BoxFit.contain,
          errorBuilder: (_, e, st) => const Center(
            child: Text(
              'No se pudo cargar el reverso',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        );
      },
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
