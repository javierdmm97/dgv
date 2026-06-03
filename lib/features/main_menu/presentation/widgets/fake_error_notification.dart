import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/main_menu/providers/main_menu_provider.dart';

/// A dismissible top bar that displays a satirical DGT error notification.
///
/// Watches [mainMenuNotifierProvider] and returns [SizedBox.shrink] when
/// [MainMenuState.isFakeErrorVisible] is false.
///
/// Requirements: 8.2, 8.3
class FakeErrorNotification extends ConsumerWidget {
  const FakeErrorNotification({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(mainMenuNotifierProvider);

    return asyncState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (state) {
        if (!state.isFakeErrorVisible) {
          return const SizedBox.shrink();
        }

        return _FakeErrorBar(
          onDismiss: () =>
              ref.read(mainMenuNotifierProvider.notifier).dismissFakeError(),
        );
      },
    );
  }
}

class _FakeErrorBar extends StatelessWidget {
  const _FakeErrorBar({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DGTColors.error,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: DGTColors.textOnPrimary,
                semanticLabel: 'Error',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Modo sin conexion',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: DGTColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'El estado Español te la ha vuelto a jugar',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: DGTColors.textOnPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: DGTColors.textOnPrimary,
                tooltip: 'Cerrar notificación',
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
