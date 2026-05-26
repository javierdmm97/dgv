import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/widgets/title_badge.dart';

/// A DGT-styled license card displaying a player's photo, name, points,
/// and title badges.
///
/// - Circular photo crop with initials fallback when [PlayerProfile.photoPath] is empty
/// - Name/surname using [TextTheme.titleMedium]
/// - Points using [TextTheme.displaySmall] in [DGTColors.primary]
/// - Row of [TitleBadge] for each [DGTTitle]
/// - Card with elevation 4, border radius 12, [DGTColors.licenseId] background
/// - Wrapped in [GestureDetector] for [onTap]
class LicenseCard extends StatelessWidget {
  const LicenseCard({super.key, required this.player, this.onTap});

  final PlayerProfile player;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: DGTColors.licenseId,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _LicenseHeader(player: player),
              const SizedBox(height: 8),
              _PointsDisplay(points: player.points),
              const SizedBox(height: 8),
              _BadgesRow(titleCounts: player.titleCounts),
              if (player.fineCount > 0) ...[
                const SizedBox(height: 8),
                _FineCount(fineCount: player.fineCount),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _LicenseHeader extends StatelessWidget {
  const _LicenseHeader({required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PlayerAvatar(player: player),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${player.name} ${player.surname}',
            style: Theme.of(context).textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = player.photoPath.isNotEmpty;

    if (hasPhoto) {
      final isAsset = player.photoPath.startsWith('assets/');
      final image = isAsset
          ? AssetImage(player.photoPath) as ImageProvider
          : FileImage(File(player.photoPath));
      return CircleAvatar(
        radius: 28,
        backgroundImage: image,
        onBackgroundImageError: (_, stackTrace) {},
        child: null,
      );
    }

    final initials = _buildInitials(player.name, player.surname);
    return CircleAvatar(
      radius: 28,
      backgroundColor: DGTColors.primary,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: DGTColors.textOnPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _buildInitials(String name, String surname) {
    final first = name.isNotEmpty ? name[0].toUpperCase() : '';
    final last = surname.isNotEmpty ? surname[0].toUpperCase() : '';
    return '$first$last';
  }
}

class _PointsDisplay extends StatelessWidget {
  const _PointsDisplay({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$points',
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
        color: DGTColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _BadgesRow extends StatelessWidget {
  const _BadgesRow({required this.titleCounts});

  final Map<DGTTitle, int> titleCounts;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: DGTTitle.values
          .map(
            (title) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: TitleBadge(title: title, count: titleCounts[title] ?? 0),
            ),
          )
          .toList(),
    );
  }
}

class _FineCount extends StatelessWidget {
  const _FineCount({required this.fineCount});

  final int fineCount;

  @override
  Widget build(BuildContext context) {
    return Text(
      '🚗 $fineCount multa${fineCount == 1 ? '' : 's'}',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: DGTColors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
