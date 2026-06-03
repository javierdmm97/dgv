import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dgv/core/theme/dgt_colors.dart';

/// A drunk-proof custom numeric keypad for entering BAC readings.
///
/// Meets the Custom_Keypad spec:
/// - 3×4 grid of 80×80 px buttons (digits 1–9, backspace ⌫, 0, confirm ✓)
/// - [maxDigits] = 2 (default): buffer holds 2 digits, display as `0.XX`
/// - [maxDigits] = 3: buffer holds 3 digits, display as `X.XX` (for BAC entry)
/// - Haptic feedback on every tap
/// - Press animation: scale down + flash to blue, spring back on release
/// - Confirm button disabled when buffer is empty
class CustomKeypad extends StatefulWidget {
  const CustomKeypad({
    super.key,
    required this.onConfirm,
    this.initialValue,
    this.maxDigits = 2,
  });

  final void Function(double value) onConfirm;
  final double? initialValue;
  // 2 = "0.XX" format (default); 3 = "X.XX" format (BAC entry up to 9.99)
  final int maxDigits;

  @override
  State<CustomKeypad> createState() => _CustomKeypadState();
}

class _CustomKeypadState extends State<CustomKeypad> {
  late List<int> _buffer;

  @override
  void initState() {
    super.initState();
    _buffer = _parseInitialValue(widget.initialValue);
  }

  List<int> _parseInitialValue(double? value) {
    if (value == null) return [];
    if (widget.maxDigits == 3) {
      final intPart = value.floor().clamp(0, 9);
      final decPart = ((value - intPart) * 100).round().clamp(0, 99);
      if (value == 0.0) return [];
      return [intPart, decPart ~/ 10, decPart % 10];
    }
    final centis = (value * 100).round().clamp(0, 99);
    final tens = centis ~/ 10;
    final units = centis % 10;
    if (centis == 0) return [];
    return [tens, units];
  }

  String get _displayValue {
    if (widget.maxDigits == 3) {
      if (_buffer.isEmpty) return '—.——';
      final digits = _buffer.map((d) => d.toString()).join().padRight(3, '0');
      return '${digits[0]}.${digits.substring(1)}';
    }
    if (_buffer.isEmpty) return '0.——';
    final digits = _buffer.map((d) => d.toString()).join().padRight(2, '0');
    return '0.$digits';
  }

  void _onDigit(int digit) {
    if (_buffer.length >= widget.maxDigits) return;
    HapticFeedback.lightImpact();
    setState(() => _buffer = [..._buffer, digit]);
  }

  void _onBackspace() {
    if (_buffer.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _buffer = _buffer.sublist(0, _buffer.length - 1));
  }

  void _onConfirm() {
    if (_buffer.isEmpty) return;
    HapticFeedback.mediumImpact();
    final double value;
    if (widget.maxDigits == 3) {
      final digits = _buffer.map((d) => d.toString()).join().padRight(3, '0');
      value = double.parse('${digits[0]}.${digits.substring(1)}');
    } else {
      value = double.parse('0.${_buffer.join()}');
    }
    widget.onConfirm(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DisplayValue(displayValue: _displayValue, isEmpty: _buffer.isEmpty),
        const SizedBox(height: 16),
        _KeypadGrid(
          onDigit: _onDigit,
          onBackspace: _onBackspace,
          onConfirm: _onConfirm,
          confirmEnabled: _buffer.isNotEmpty,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Display
// ---------------------------------------------------------------------------

class _DisplayValue extends StatelessWidget {
  const _DisplayValue({required this.displayValue, required this.isEmpty});

  final String displayValue;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.displaySmall?.copyWith(
      color: isEmpty ? DGTColors.textSecondary : null,
    );
    return Text(displayValue, style: style);
  }
}

// ---------------------------------------------------------------------------
// Grid
// ---------------------------------------------------------------------------

class _KeypadGrid extends StatelessWidget {
  const _KeypadGrid({
    required this.onDigit,
    required this.onBackspace,
    required this.onConfirm,
    required this.confirmEnabled,
  });

  final void Function(int digit) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onConfirm;
  final bool confirmEnabled;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Row 1
        _DigitKey(digit: 1, onTap: onDigit),
        _DigitKey(digit: 2, onTap: onDigit),
        _DigitKey(digit: 3, onTap: onDigit),
        // Row 2
        _DigitKey(digit: 4, onTap: onDigit),
        _DigitKey(digit: 5, onTap: onDigit),
        _DigitKey(digit: 6, onTap: onDigit),
        // Row 3
        _DigitKey(digit: 7, onTap: onDigit),
        _DigitKey(digit: 8, onTap: onDigit),
        _DigitKey(digit: 9, onTap: onDigit),
        // Row 4
        _ActionKey(
          label: '⌫',
          onTap: onBackspace,
          normalColor: DGTColors.orange,
        ),
        _DigitKey(digit: 0, onTap: onDigit),
        _ActionKey(
          label: '✓',
          onTap: confirmEnabled ? onConfirm : null,
          normalColor: confirmEnabled
              ? DGTColors.primary
              : DGTColors.textSecondary,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual keys
// ---------------------------------------------------------------------------

class _DigitKey extends StatelessWidget {
  const _DigitKey({required this.digit, required this.onTap});

  final int digit;
  final void Function(int digit) onTap;

  @override
  Widget build(BuildContext context) {
    return _KeypadKey(
      label: digit.toString(),
      normalColor: DGTColors.surface,
      pressedColor: DGTColors.primary,
      textStyle: Theme.of(context).textTheme.headlineMedium,
      pressedTextStyle: Theme.of(
        context,
      ).textTheme.headlineMedium?.copyWith(color: Colors.white),
      onTap: () => onTap(digit),
    );
  }
}

class _ActionKey extends StatelessWidget {
  const _ActionKey({
    required this.label,
    required this.onTap,
    required this.normalColor,
  });

  final String label;
  final VoidCallback? onTap;
  final Color normalColor;

  @override
  Widget build(BuildContext context) {
    return _KeypadKey(
      label: label,
      normalColor: normalColor,
      // Action keys flash white on press instead of changing to blue.
      pressedColor: normalColor == DGTColors.primary
          ? DGTColors.primary.withValues(alpha: 0.7)
          : Colors.white.withValues(alpha: 0.85),
      textStyle: Theme.of(
        context,
      ).textTheme.headlineMedium?.copyWith(color: DGTColors.textOnPrimary),
      pressedTextStyle: Theme.of(
        context,
      ).textTheme.headlineMedium?.copyWith(color: DGTColors.textOnPrimary),
      onTap: onTap,
    );
  }
}

// ---------------------------------------------------------------------------
// Animated key — scale + color flash on press
// ---------------------------------------------------------------------------

class _KeypadKey extends StatefulWidget {
  const _KeypadKey({
    required this.label,
    required this.onTap,
    required this.normalColor,
    required this.pressedColor,
    required this.textStyle,
    required this.pressedTextStyle,
  });

  final String label;
  final VoidCallback? onTap;
  final Color normalColor;
  final Color pressedColor;
  final TextStyle? textStyle;
  final TextStyle? pressedTextStyle;

  @override
  State<_KeypadKey> createState() => _KeypadKeyState();
}

class _KeypadKeyState extends State<_KeypadKey> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_pressed) return;
    setState(() => _pressed = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (!_pressed) return;
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final bgColor = _pressed ? widget.pressedColor : widget.normalColor;
    final style = _pressed ? widget.pressedTextStyle : widget.textStyle;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTapDown: enabled ? _handleTapDown : null,
        onTapUp: enabled ? _handleTapUp : null,
        onTapCancel: enabled ? _handleTapCancel : null,
        child: AnimatedScale(
          scale: _pressed ? 0.88 : 1.0,
          duration: _pressed
              ? const Duration(milliseconds: 60)
              : const Duration(milliseconds: 120),
          curve: _pressed ? Curves.easeIn : Curves.elasticOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: _pressed
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Center(child: Text(widget.label, style: style)),
          ),
        ),
      ),
    );
  }
}
