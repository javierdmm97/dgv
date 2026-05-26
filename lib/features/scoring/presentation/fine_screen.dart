import 'package:flutter/material.dart';

import 'package:dgv/core/constants/asset_paths.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';
import 'package:dgv/widgets/massive_button.dart';

/// Full-screen fine notification shown when a player receives -4 points.
///
/// Shows [AssetPaths.fine] image with player name, fine count, and money lost.
/// Receives [BACEntryResult] as route argument.
class FineScreen extends StatelessWidget {
  const FineScreen({super.key, required this.result});

  final BACEntryResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DGTColors.red,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              _FineImage(),
              const SizedBox(height: 24),
              Text(
                result.playerName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: DGTColors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '🚗 MULTA N.º ${result.fineCount}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: DGTColors.textOnPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Total perdido: ${result.moneyLost} €',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: DGTColors.textOnPrimary.withValues(alpha: 0.85),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '(se cobra mañana 😈)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: DGTColors.textOnPrimary.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              MassiveButton(
                text: 'Continuar',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FineImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AssetPaths.fine,
      height: 220,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 220,
          decoration: BoxDecoration(
            color: DGTColors.textOnPrimary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: DGTColors.textOnPrimary.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '🚨\nMULTA\nDGV',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: DGTColors.textOnPrimary,
                fontWeight: FontWeight.w900,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
