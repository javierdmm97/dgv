import 'package:flutter/material.dart';

import 'package:dgv/core/constants/asset_paths.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/widgets/massive_button.dart';

/// "Ayuda" joke screen — satirical help page for Operación DGV.
class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        title: const Text('¿Necesitas Ayuda?'),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Image.asset(AssetPaths.fine, height: 200, fit: BoxFit.contain),
              const SizedBox(height: 40),
              Text(
                'Espabila y tómate una bien fría.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DGTColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '— Estrella Ballester, Directora General de la DGV',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: DGTColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'El agua deshidrata, pero la cerveza no!.',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: DGTColors.primary,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              MassiveButton(
                text: 'Cerrar',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
