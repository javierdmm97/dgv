import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_provider.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';
import 'package:dgv/widgets/custom_keypad.dart';

/// Full-screen BAC entry using [CustomKeypad] with maxDigits=3 (X.XX format).
///
/// Returns a [BACEntryResult] via [Navigator.pop] to the caller.
class ManualEntryScreen extends ConsumerStatefulWidget {
  const ManualEntryScreen({super.key, required this.player});

  final PlayerProfile player;

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  bool _isSubmitting = false;

  Future<void> _submit(double bac) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final result = await ref
          .read(bACEntryNotifierProvider.notifier)
          .submitBAC(widget.player.id, bac);
      if (mounted) Navigator.pop(context, result);
    } on Exception {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
              Center(
                child: Text(
                  'Óptimo: ${player.optimalBAC} mg/L',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: DGTColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (_isSubmitting)
                const Center(child: CircularProgressIndicator())
              else
                CustomKeypad(maxDigits: 3, onConfirm: _submit),
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
