import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
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
  const ManualEntryScreen({super.key, required this.player});

  final PlayerProfile player;

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  bool _isNavigating = false;
  double? _lastEnteredValue;

  Future<void> _submit(double bac) async {
    if (_isNavigating) return;
    _isNavigating = true;
    _lastEnteredValue = bac;

    final result = await Navigator.push<BACEntryResult?>(
      context,
      MaterialPageRoute<BACEntryResult?>(
        builder: (_) => BacConfirmationScreen(
          args: BacConfirmationArgs(player: widget.player, enteredValue: bac),
        ),
      ),
    );

    if (!mounted) return;
    _isNavigating = false;

    if (result != null) {
      // Confirmed — pop back to caller with result.
      Navigator.pop(context, result);
    }
    // If result is null ("Corregir"), stay on keypad with previous value.
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final hasPhoto = player.photoPath.isNotEmpty;

    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        title: Text('Tasa de ${player.name}'),
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
                      ? (player.photoPath.startsWith('assets/')
                            ? AssetImage(player.photoPath) as ImageProvider
                            : FileImage(File(player.photoPath)))
                      : null,
                  child: hasPhoto
                      ? null
                      : Text(
                          _initials(player.name, player.surname),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: DGTColors.primary),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${player.name} ${player.surname}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 32),
              CustomKeypad(
                maxDigits: 3,
                onConfirm: _submit,
                initialValue: _lastEnteredValue,
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
