import 'package:flutter/material.dart';

import 'package:dgv/core/constants/asset_paths.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/widgets/massive_button.dart';

/// A full-screen modal that displays a satirical DGT error message.
///
/// Shows [AssetPaths.errorMessage] with a blue DGT header, satirical Spanish
/// error text, and a [MassiveButton] to dismiss the screen.
///
/// Requirements: 10.1, 10.2, 10.3, 10.4, 10.5
class FakeErrorScreen extends StatelessWidget {
  const FakeErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DGTColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ErrorHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _ErrorImage(),
                    const SizedBox(height: 24),
                    _ErrorBody(context: context),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: MassiveButton(
                text: 'Cerrar',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorHeader extends StatelessWidget {
  const _ErrorHeader();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DGTColors.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: DGTColors.textOnPrimary,
              size: 28,
              semanticLabel: 'Advertencia',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'DIRECCIÓN GENERAL DE TRÁFICO',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: DGTColors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorImage extends StatelessWidget {
  const _ErrorImage();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        AssetPaths.errorMessage,
        fit: BoxFit.contain,
        semanticLabel: 'Imagen de error del sistema DGT',
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: DGTColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DGTColors.error, width: 2),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 64,
                  color: DGTColors.error,
                  semanticLabel: 'Imagen no disponible',
                ),
                SizedBox(height: 8),
                Text(
                  'ERROR 404: Imagen no encontrada',
                  style: TextStyle(color: DGTColors.error),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ERROR CRÍTICO DEL SISTEMA — CÓDIGO: DGT-42069',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: DGTColors.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Se ha detectado una anomalía grave en el subsistema de '
          'control de diversión. El nivel de alcohol en sangre del '
          'conductor supera los límites establecidos por el Reglamento '
          'General de Circulación, artículo 20, párrafo 3, subsección B.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        Text(
          'La Dirección General de Tráfico ha sido notificada '
          'automáticamente. Un agente de la autoridad se personará en '
          'su domicilio en un plazo máximo de 3 a 5 días laborables '
          '(festivos no incluidos, sujeto a disponibilidad del agente '
          'y condiciones meteorológicas adversas).',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        Text(
          'Para evitar sanciones adicionales, se recomienda encarecidamente '
          'apagar el dispositivo, enterrarlo en el jardín y fingir que '
          'nunca ocurrió nada. La DGT no se hace responsable de los '
          'daños morales, físicos o espirituales derivados del uso de '
          'esta aplicación.',
          style: bodyStyle,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 16),
        Text(
          '— Atentamente, La DGT\n'
          'P.D.: Recuerde que el alcohol y la conducción no se mezclan. '
          'Pero usted no está conduciendo, así que... ¡salud! 🍺',
          style: bodyStyle?.copyWith(
            fontStyle: FontStyle.italic,
            color: DGTColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
