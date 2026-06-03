import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_provider.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';
import 'package:dgv/widgets/massive_button.dart';

/// Route arguments for [BacConfirmationScreen].
class BacConfirmationArgs {
  const BacConfirmationArgs({required this.player, required this.enteredValue});

  final PlayerProfile player;
  final double enteredValue;
}

/// Confirmation step shown after a BrAC value is entered but before saving.
///
/// Returns a [BACEntryResult] via [Navigator.pop] when "Confirmar" is tapped.
/// Returns `null` via [Navigator.pop] when "Corregir" is tapped so the caller
/// can re-show the keypad with the previously entered value.
///
/// No Hive writes occur until "Confirmar" is tapped.
class BacConfirmationScreen extends ConsumerStatefulWidget {
  const BacConfirmationScreen({
    super.key,
    required this.args,
    this.previewMode = false,
  });

  final BacConfirmationArgs args;

  /// When true, calls calculatePreview() instead of submitBAC() — no Hive writes.
  /// Used by the staged Retén flow.
  final bool previewMode;

  @override
  ConsumerState<BacConfirmationScreen> createState() =>
      _BacConfirmationScreenState();
}

class _BacConfirmationScreenState extends ConsumerState<BacConfirmationScreen> {
  bool _isSubmitting = false;

  Future<void> _confirm() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(bACEntryNotifierProvider.notifier);
      final result = widget.previewMode
          ? await notifier.calculatePreview(
              widget.args.player.id,
              widget.args.enteredValue,
            )
          : await notifier.submitBAC(
              widget.args.player.id,
              widget.args.enteredValue,
            );
      if (mounted) Navigator.pop(context, result);
    } on Exception {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _correct() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.args.player;
    final value = widget.args.enteredValue;

    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        title: const Text('Confirmar lectura'),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Player name — 24sp bold (Req 5.4)
              Text(
                '${player.name} ${player.surname}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: DGTColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Entered value — 48sp bold (Req 5.4)
              Text(
                '${value.toStringAsFixed(2)} mg/L',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: DGTColors.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              if (_isSubmitting)
                const Center(child: CircularProgressIndicator())
              else ...[
                // Confirmar — saves and proceeds (Req 5.2)
                MassiveButton(text: 'Confirmar', onPressed: _confirm),

                const SizedBox(height: 16),

                // Corregir — returns null so caller re-shows keypad (Req 5.3)
                MassiveButton(
                  text: 'Corregir',
                  onPressed: _correct,
                  backgroundColor: DGTColors.textSecondary,
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
