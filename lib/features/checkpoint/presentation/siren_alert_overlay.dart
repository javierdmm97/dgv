import 'dart:async';

import 'package:flutter/material.dart';

import 'package:dgv/core/constants/app_constants.dart';
import 'package:dgv/core/theme/dgt_colors.dart';

/// Full-screen red/blue flash animation shown when a checkpoint fires.
///
/// Shown via [Navigator.push] with a transparent background.
/// Auto-dismisses after [AppConstants.sirenDuration].
/// Bug #3 fix: Audio removed entirely — visual animation only.
class SirenAlertOverlay extends StatefulWidget {
  const SirenAlertOverlay({super.key});

  @override
  State<SirenAlertOverlay> createState() => _SirenAlertOverlayState();
}

class _SirenAlertOverlayState extends State<SirenAlertOverlay> {
  bool _isRed = true;
  Timer? _flashTimer;
  Timer? _closeTimer;

  @override
  void initState() {
    super.initState();
    // Flash every 250 ms
    _flashTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => setState(() => _isRed = !_isRed),
    );
    // Close after siren duration
    _closeTimer = Timer(AppConstants.sirenDuration, _dismiss);
    // Bug #3 fix: Removed audio playback
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    _closeTimer?.cancel();
    // Bug #3 fix: Removed audio player disposal
    super.dispose();
  }

  void _dismiss() {
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      child: Scaffold(
        backgroundColor: _isRed ? DGTColors.sirenRed : DGTColors.sirenBlue,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🚨', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 16),
                Text(
                  '¡CONTROL SORPRESA!',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Toca para continuar',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
