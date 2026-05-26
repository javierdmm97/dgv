import 'package:flutter/material.dart';

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
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: DGTColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🚔', style: TextStyle(fontSize: 80)),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Espabila y tómate una bien fría.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DGTColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Si bebes, conduce.',
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
