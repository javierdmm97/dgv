import 'dart:async';

import 'package:flutter/material.dart';

import 'package:dgv/core/constants/app_constants.dart';
import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';

/// Full-screen colored notification shown after each BAC entry (Round 1+).
///
/// Tap anywhere (or wait for auto-close) to dismiss.
/// Receives [BACEntryResult] as route argument.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key, required this.result});

  final BACEntryResult result;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _autoCloseTimer = Timer(AppConstants.feedbackDuration, _close);
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  void _close() {
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return GestureDetector(
      onTap: _close,
      child: Scaffold(
        backgroundColor: result.feedbackColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                _PlayerName(name: result.playerName),
                const SizedBox(height: 16),
                _PointsDelta(pointsChange: result.pointsChange),
                const SizedBox(height: 12),
                _Message(message: result.feedbackMessage),
                const SizedBox(height: 12),
                _BACLabel(bac: result.bac),
                if (result.awardedTitle != null) ...[
                  const SizedBox(height: 16),
                  _TitleAward(title: result.awardedTitle!),
                ],
                const Spacer(),
                Text(
                  'Toca para continuar',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: DGTColors.textPrimary.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _PlayerName extends StatelessWidget {
  const _PlayerName({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: DGTColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _PointsDelta extends StatelessWidget {
  const _PointsDelta({required this.pointsChange});

  final int pointsChange;

  @override
  Widget build(BuildContext context) {
    final sign = pointsChange >= 0 ? '+' : '';
    return Text(
      '$sign$pointsChange pts',
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: DGTColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(color: DGTColors.textPrimary),
      textAlign: TextAlign.center,
    );
  }
}

class _BACLabel extends StatelessWidget {
  const _BACLabel({required this.bac});

  final double bac;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Lectura: ${bac.toStringAsFixed(2)} mg/L',
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: DGTColors.textSecondary),
      textAlign: TextAlign.center,
    );
  }
}

class _TitleAward extends StatelessWidget {
  const _TitleAward({required this.title});

  final DGTTitle title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: DGTColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title.displayName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
