import 'package:flutter/material.dart';

import 'package:dgv/core/models/dgt_title.dart';

/// A compact badge displaying a [DGTTitle] icon and accumulation counter.
///
/// Meets the Title_Badge spec:
/// - When [count] == 0: grayed-out icon (outline color), no counter text
/// - When [count] >= 1: full-color icon image + `×N` counter text
/// - Layout: Row([icon, if count > 0 Text('×$count')])
class TitleBadge extends StatelessWidget {
  const TitleBadge({super.key, required this.title, required this.count});

  final DGTTitle title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final isActive = count >= 1;
    final outlineColor = Theme.of(context).colorScheme.outline;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TitleIcon(
          iconPath: title.iconPath,
          isActive: isActive,
          greyColor: outlineColor,
        ),
        if (isActive) ...[const SizedBox(width: 2), _CounterText(count: count)],
      ],
    );
  }
}

class _TitleIcon extends StatelessWidget {
  const _TitleIcon({
    required this.iconPath,
    required this.isActive,
    required this.greyColor,
  });

  final String iconPath;
  final bool isActive;
  final Color greyColor;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      iconPath,
      width: 24,
      height: 24,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.emoji_events,
        size: 24,
        color: isActive ? null : greyColor,
      ),
    );

    if (isActive) {
      return image;
    }

    return Opacity(opacity: 0.3, child: image);
  }
}

class _CounterText extends StatelessWidget {
  const _CounterText({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Text('×$count', style: Theme.of(context).textTheme.labelSmall);
  }
}
