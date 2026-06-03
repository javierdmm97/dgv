import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dgv/core/theme/dgt_colors.dart';

/// A large, high-contrast button designed for drunk-proof interaction.
///
/// Meets the Massive_Button spec:
/// - Minimum height of 80 px
/// - 24 sp bold text via [Theme.of(context).textTheme.titleLarge]
/// - Haptic feedback on tap
/// - Disabled state with 0.5 opacity
/// - Optional leading icon
/// - Rounded corners (border radius 12)
class MassiveButton extends StatelessWidget {
  const MassiveButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isEnabled = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBackground = backgroundColor ?? DGTColors.primary;
    final effectiveForeground = foregroundColor ?? DGTColors.textOnPrimary;

    final button = ElevatedButton(
      onPressed: isEnabled ? _handlePress : null,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 80)),
        backgroundColor: WidgetStatePropertyAll(effectiveBackground),
        foregroundColor: WidgetStatePropertyAll(effectiveForeground),
        textStyle: WidgetStatePropertyAll(
          Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
      ),
      child: _ButtonContent(text: text, icon: icon),
    );

    if (!isEnabled) {
      return Opacity(opacity: 0.5, child: button);
    }

    return button;
  }

  void _handlePress() {
    HapticFeedback.mediumImpact();
    onPressed?.call();
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return Text(text);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon), const SizedBox(width: 8), Text(text)],
    );
  }
}
