import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/widgets/last_measurement_widget.dart';
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
  const LicenseCard({
    super.key,
    required this.player,
    this.onTap,
    this.onEdit,
    this.onViewLicense,
  });

  final PlayerProfile player;
  final VoidCallback? onTap;

  /// Shows a pencil icon — used in main menu for editing a player.
  final VoidCallback? onEdit;

  /// Shows a credit-card icon — used to open the license viewer.
  final VoidCallback? onViewLicense;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Card(
            elevation: 4,
            shape: const RoundedRectangleBorder(),
            color: DGTColors.licenseId,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LicenseHeader(
                    player: player,
                    onEdit: onEdit,
                    onViewLicense: onViewLicense,
                  ),
                  const SizedBox(height: 8),
                  _PointsDisplay(points: player.points),
                  const SizedBox(height: 4),
                  LastMeasurementWidget(player: player),
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
          if (player.isIncautado)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                  ),
                  child: Transform.rotate(
                    angle: -0.4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: const Text(
                        'INCAUTADO',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _LicenseHeader extends StatelessWidget {
  const _LicenseHeader({required this.player, this.onEdit, this.onViewLicense});

  final PlayerProfile player;
  final VoidCallback? onEdit;
  final VoidCallback? onViewLicense;

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
        if (onViewLicense != null)
          IconButton(
            icon: const Icon(Icons.credit_card_outlined, size: 22),
            color: DGTColors.primary,
            tooltip: 'Ver carnet de conducir',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onViewLicense,
          ),
        if (onEdit != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: DGTColors.textSecondary,
            tooltip: 'Editar',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onEdit,
          ),
        ],
      ],
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({required this.player});

  final PlayerProfile player;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = player.photoPath.isNotEmpty;

    if (hasPhoto) {
      final isAsset = player.photoPath.startsWith('assets/');
      final imageProvider = isAsset
          ? AssetImage(player.photoPath) as ImageProvider
          : FileImage(File(player.photoPath));
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image(
          image: imageProvider,
          width: _size,
          height: _size,
          fit: BoxFit.cover,
          errorBuilder: (_, e, st) => _initialsBox(context),
        ),
      );
    }

    return _initialsBox(context);
  }

  Widget _initialsBox(BuildContext context) {
    final initials = _buildInitials(player.name, player.surname);
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: DGTColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
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
