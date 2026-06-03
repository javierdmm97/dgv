import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/core/utils/bac_calculator.dart';
import 'package:dgv/features/breathalyzer/presentation/bac_confirmation_screen.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';
import 'package:dgv/widgets/custom_keypad.dart';

/// Full-screen BAC entry using [CustomKeypad] with maxDigits=3 (X.XX format).
///
/// Pushes [BacConfirmationScreen] before saving — no Hive writes until the
/// operator taps "Confirmar" on the confirmation screen.
///
/// Returns a [BACEntryResult] via [Navigator.pop] to the caller.
class ManualEntryScreen extends ConsumerStatefulWidget {
  const ManualEntryScreen({
    super.key,
    required this.player,
    this.initialValue,
    this.previewMode = false,
  });

  final PlayerProfile player;

  /// Pre-fill the keypad with this value (used in edit mode).
  final double? initialValue;

  /// When true, confirmation does not write to Hive (staged Retén flow).
  final bool previewMode;

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  bool _isNavigating = false;
  late double? _lastEnteredValue = widget.initialValue;

  Future<void> _submit(double bac) async {
    if (_isNavigating) return;
    setState(() {
      _isNavigating = true;
      _lastEnteredValue = bac;
    });

    final result = await Navigator.push<BACEntryResult?>(
      context,
      MaterialPageRoute<BACEntryResult?>(
        builder: (_) => BacConfirmationScreen(
          args: BacConfirmationArgs(player: widget.player, enteredValue: bac),
          previewMode: widget.previewMode,
        ),
      ),
    );

    if (!mounted) return;
    setState(() => _isNavigating = false);

    if (result != null) {
      // Confirmed — pop back to caller with result.
      Navigator.pop(context, result);
    }
    // If result is null ("Corregir"), stay on keypad with previous value.
  }

  @override
  Widget build(BuildContext context) {
    // Watch the live player so "Último registro" reflects the freshest round.
    final livePlayer =
        ref
            .watch(playerByIdProvider(widget.player.id))
            .maybeWhen(data: (p) => p, orElse: () => null) ??
        widget.player;

    final currentRound = ref.watch(
      currentGameStateProvider.select((v) => v.value?.currentRound ?? 0),
    );
    final preGameBeers = ref.watch(
      currentGameStateProvider.select((v) => v.value?.preGameBeers ?? 0.0),
    );
    final optimal = currentRound > 0
        ? BACCalculator.calculateOptimalBrAC(
                currentRound,
                livePlayer.sex,
                livePlayer.bodySize,
              ) +
              BACCalculator.preGameBacOffset(
                preGameBeers,
                livePlayer.sex,
                livePlayer.bodySize,
              )
        : null;

    final lastReading = livePlayer.readings
        .where((r) => r.roundNumber > 0)
        .fold<BACReading?>(null, (prev, r) {
          if (prev == null) return r;
          return r.roundNumber > prev.roundNumber ? r : prev;
        });

    final hasPhoto = widget.player.photoPath.isNotEmpty;

    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        title: Text('Tasa de ${widget.player.name}'),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: DGTColors.primary.withValues(alpha: 0.1),
                  backgroundImage: hasPhoto
                      ? (widget.player.photoPath.startsWith('assets/')
                            ? AssetImage(widget.player.photoPath)
                                  as ImageProvider
                            : FileImage(File(widget.player.photoPath)))
                      : null,
                  child: hasPhoto
                      ? null
                      : Text(
                          _initials(widget.player.name, widget.player.surname),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: DGTColors.primary),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${widget.player.name} ${widget.player.surname}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (lastReading != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Último registro: ${lastReading.formattedBAC} mg/L — Ronda ${lastReading.roundNumber}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DGTColors.textSecondary,
                    ),
                  ),
                ),
              ],
              if (optimal != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: DGTColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: DGTColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Objetivo: ${optimal.toStringAsFixed(2)} mg/L',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: DGTColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              if (!_isNavigating)
                CustomKeypad(
                  maxDigits: 3,
                  onConfirm: _submit,
                  initialValue: _lastEnteredValue,
                )
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name, String surname) {
    final a = name.isNotEmpty ? name[0].toUpperCase() : '';
    final b = surname.isNotEmpty ? surname[0].toUpperCase() : '';
    return '$a$b';
  }
}
