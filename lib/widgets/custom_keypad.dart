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
/// - Confirm button disabled when buffer is empty
/// - Colors from [DGTColors]; display text from [Theme.of(context).textTheme]
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

  /// Parses an optional initial value into a digit buffer.
  /// maxDigits=2: 0.45 → [4, 5]; maxDigits=3: 1.50 → [1, 5, 0]
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

  /// Formats the current buffer as the display string.
  /// maxDigits=2: `0.XX`; maxDigits=3: `X.XX`
  String get _displayValue {
    if (widget.maxDigits == 3) {
      if (_buffer.isEmpty) return '0.00';
      final digits = _buffer.map((d) => d.toString()).join().padRight(3, '0');
      return '${digits[0]}.${digits.substring(1)}';
    }
    final digits = _buffer.map((d) => d.toString()).join().padRight(2, '0');
    return '0.$digits';
  }

  void _onDigit(int digit) {
    if (_buffer.length >= widget.maxDigits) return;
    HapticFeedback.lightImpact();
    setState(() {
      _buffer = [..._buffer, digit];
    });
  }

  void _onBackspace() {
    if (_buffer.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _buffer = _buffer.sublist(0, _buffer.length - 1);
    });
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
        _DisplayValue(displayValue: _displayValue),
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

/// Displays the current formatted input value above the keypad.
class _DisplayValue extends StatelessWidget {
  const _DisplayValue({required this.displayValue});

  final String displayValue;

  @override
  Widget build(BuildContext context) {
    return Text(displayValue, style: Theme.of(context).textTheme.displaySmall);
  }
}

/// The 3×4 grid of keypad buttons.
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
        _DigitButton(digit: 1, onTap: onDigit),
        _DigitButton(digit: 2, onTap: onDigit),
        _DigitButton(digit: 3, onTap: onDigit),
        // Row 2
        _DigitButton(digit: 4, onTap: onDigit),
        _DigitButton(digit: 5, onTap: onDigit),
        _DigitButton(digit: 6, onTap: onDigit),
        // Row 3
        _DigitButton(digit: 7, onTap: onDigit),
        _DigitButton(digit: 8, onTap: onDigit),
        _DigitButton(digit: 9, onTap: onDigit),
        // Row 4
        _ActionButton(
          label: '⌫',
          onTap: onBackspace,
          backgroundColor: DGTColors.orange,
        ),
        _DigitButton(digit: 0, onTap: onDigit),
        _ActionButton(
          label: '✓',
          onTap: confirmEnabled ? onConfirm : null,
          backgroundColor: confirmEnabled
              ? DGTColors.primary
              : DGTColors.textSecondary,
        ),
      ],
    );
  }
}

/// A single digit button in the keypad grid.
class _DigitButton extends StatelessWidget {
  const _DigitButton({required this.digit, required this.onTap});

  final int digit;
  final void Function(int digit) onTap;

  @override
  Widget build(BuildContext context) {
    return _KeypadCell(
      child: ElevatedButton(
        onPressed: () => onTap(digit),
        style: _buttonStyle(DGTColors.surface),
        child: Text(
          digit.toString(),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

/// A non-digit action button (backspace or confirm).
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.backgroundColor,
  });

  final String label;
  final VoidCallback? onTap;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return _KeypadCell(
      child: ElevatedButton(
        onPressed: onTap,
        style: _buttonStyle(backgroundColor),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: DGTColors.textOnPrimary),
        ),
      ),
    );
  }
}

/// Constrains a keypad cell to exactly 80×80 px.
class _KeypadCell extends StatelessWidget {
  const _KeypadCell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox(width: 80, height: 80, child: child),
    );
  }
}

ButtonStyle _buttonStyle(Color backgroundColor) {
  return ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size(80, 80)),
    backgroundColor: WidgetStatePropertyAll(backgroundColor),
    shape: const WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    padding: const WidgetStatePropertyAll(EdgeInsets.zero),
  );
}
