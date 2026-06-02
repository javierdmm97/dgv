import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dgv/core/constants/asset_paths.dart';
import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/core/utils/points_calculator.dart';

/// Renders a player's DGT-style license card to a PNG file on disk.
///
/// Uses dart:ui Canvas + PictureRecorder to composite the license template
/// image with the player's photo and stats, then writes a PNG to app docs.
class LicenseGenerator {
  LicenseGenerator._();

  static const double _cardWidth = 600;
  static const double _cardHeight = 375;
  static const double _pixelRatio = 2.0;

  // ---------------------------------------------------------------------------
  // Front layout constants
  // ---------------------------------------------------------------------------

  // Photo: height locked, -42px total left
  static const Rect _photoRect = Rect.fromLTWH(60, 137, 98, 140);

  // Text column to the right of the photo, same vertical origin
  static const double _textX = 170;
  static const Offset _nameOffset = Offset(_textX, 139);
  static const Offset _pointsOffset = Offset(_textX, 169);
  static const Offset _roundsOffset = Offset(_textX, 201);
  static const Offset _totalsOffset = Offset(_textX, 221);
  static const Offset _finesOffset = Offset(_textX, 241);
  static const Offset _titlesOffset = Offset(_textX, 265);
  static const double _titleIconSize = 38;
  static const double _titleIconGap = 6;

  // Medal / special badges
  static const Offset _medalOffset = Offset(528, 147);
  static const double _medalRadius = 26;
  static const Offset _coleccionistaOffset = Offset(528, 207);
  static const double _coleccionistaSize = 44;

  // ---------------------------------------------------------------------------
  // Back layout constants
  // ---------------------------------------------------------------------------

  static const double _bkLeftX = 8;
  static const double _bkLeftW = 185;
  static const double _bkStartY = 8;
  static const double _bkRowH = 18;

  static const double _bkEnvIconSize = 82;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates a license front PNG for [player] and returns the file path.
  ///
  /// [podiumPosition] 1/2/3 adds a gold/silver/bronze medal badge.
  /// [isColeccionista] adds a crown badge.
  static Future<String> generate(
    PlayerProfile player, {
    int? podiumPosition,
    bool isColeccionista = false,
  }) async {
    final templateImage = await _loadAssetImage(AssetPaths.licenseFront);

    ui.Image? playerPhoto;
    if (player.photoPath.isNotEmpty) {
      try {
        final bytes = await File(player.photoPath).readAsBytes();
        playerPhoto = await _decodeImageBytes(bytes);
      } on Exception {
        // Silently fall back to initials if photo is missing/corrupt.
      }
    }

    // Pre-load title icons for earned titles.
    final titleImages = <DGTTitle, ui.Image>{};
    for (final entry in player.titleCounts.entries) {
      if (entry.value > 0) {
        try {
          titleImages[entry.key] = await _loadAssetImage(entry.key.iconPath);
        } on Exception {
          // Skip missing title assets gracefully.
        }
      }
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      const Rect.fromLTWH(
        0,
        0,
        _cardWidth * _pixelRatio,
        _cardHeight * _pixelRatio,
      ),
    );
    canvas.scale(_pixelRatio, _pixelRatio);

    _drawTemplate(canvas, templateImage);
    _drawPhotoOrInitials(canvas, playerPhoto, player);
    _drawFrontTextOverlays(canvas, player);
    _drawFrontTitleIcons(canvas, titleImages, player.titleCounts);
    if (podiumPosition != null && podiumPosition >= 1 && podiumPosition <= 3) {
      _drawMedal(canvas, podiumPosition);
    }
    if (isColeccionista) {
      _drawColeccionistaBadge(canvas);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (_cardWidth * _pixelRatio).toInt(),
      (_cardHeight * _pixelRatio).toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw StateError('toByteData returned null for license front PNG');
    final pngBytes = byteData.buffer.asUint8List();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/license_${player.id}.png');
    await file.writeAsBytes(pngBytes, flush: true);
    return file.path;
  }

  /// Generates the back-side license PNG for [player] and returns the file path.
  ///
  /// [environmentalAssetPath] draws the awarded sticker when provided (final
  /// export only).
  static Future<String> generateBack(
    PlayerProfile player, {
    String? environmentalAssetPath,
  }) async {
    final templateImage = await _loadAssetImage(AssetPaths.licenseBack);

    // Pre-load right-panel assets.
    final titleImages = <DGTTitle, ui.Image>{};
    for (final entry in player.titleCounts.entries) {
      if (entry.value > 0) {
        try {
          titleImages[entry.key] = await _loadAssetImage(entry.key.iconPath);
        } on Exception {
          // Skip missing assets gracefully.
        }
      }
    }

    ui.Image? fineImage;
    if (player.fineCount > 0) {
      try {
        fineImage = await _loadAssetImage(AssetPaths.fineIcon);
      } on Exception {
        // Skip if asset missing.
      }
    }

    ui.Image? envImage;
    if (environmentalAssetPath != null) {
      try {
        envImage = await _loadAssetImage(environmentalAssetPath);
      } on Exception {
        // Skip if asset missing.
      }
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      const Rect.fromLTWH(
        0,
        0,
        _cardWidth * _pixelRatio,
        _cardHeight * _pixelRatio,
      ),
    );
    canvas.scale(_pixelRatio, _pixelRatio);

    _drawTemplate(canvas, templateImage);
    _drawBackLeftPanel(canvas, player, titleImages, fineImage, envImage);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (_cardWidth * _pixelRatio).toInt(),
      (_cardHeight * _pixelRatio).toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw StateError('toByteData returned null for license back PNG');
    final pngBytes = byteData.buffer.asUint8List();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/license_back_${player.id}.png');
    await file.writeAsBytes(pngBytes, flush: true);
    return file.path;
  }

  // ---------------------------------------------------------------------------
  // Front drawing helpers
  // ---------------------------------------------------------------------------

  static void _drawPhotoOrInitials(
    Canvas canvas,
    ui.Image? photo,
    PlayerProfile player,
  ) {
    final rrect = RRect.fromRectAndRadius(_photoRect, const Radius.circular(8));

    if (photo != null) {
      canvas.save();
      canvas.clipRRect(rrect);

      // Cover-fit: crop source to match destination aspect ratio, centred.
      final srcW = photo.width.toDouble();
      final srcH = photo.height.toDouble();
      final dstAspect = _photoRect.width / _photoRect.height;
      final Rect srcRect;
      if (srcW / srcH > dstAspect) {
        final cropW = srcH * dstAspect;
        srcRect = Rect.fromLTWH((srcW - cropW) / 2, 0, cropW, srcH);
      } else {
        final cropH = srcW / dstAspect;
        srcRect = Rect.fromLTWH(0, (srcH - cropH) / 2, srcW, cropH);
      }

      canvas.drawImageRect(
        photo,
        srcRect,
        _photoRect,
        Paint()..filterQuality = FilterQuality.high,
      );
      canvas.restore();
    } else {
      canvas.drawRRect(rrect, Paint()..color = DGTColors.primary);
      final initials = '${player.name[0]}${player.surname[0]}'.toUpperCase();
      _drawText(
        canvas,
        initials,
        Offset(
          _photoRect.left + _photoRect.width / 2 - 22,
          _photoRect.top + _photoRect.height / 2 - 24,
        ),
        fontSize: 44,
        bold: true,
        color: DGTColors.textOnPrimary,
      );
    }
  }

  static void _drawFrontTextOverlays(Canvas canvas, PlayerProfile player) {
    // 1. Name
    _drawText(
      canvas,
      '${player.name} ${player.surname}'.toUpperCase(),
      _nameOffset,
      fontSize: 22,
      bold: true,
      color: DGTColors.textPrimary,
      maxWidth: 340,
    );

    // 2. Points
    _drawText(
      canvas,
      '${player.points} puntos',
      _pointsOffset,
      fontSize: 20,
      bold: true,
      color: DGTColors.primary,
    );

    // 3. Rounds & readings count
    final activeReadings = player.readings
        .where((r) => r.isActiveRound)
        .toList();
    final roundNums = activeReadings.map((r) => r.roundNumber).toSet().length;
    _drawText(
      canvas,
      'Rondas: $roundNums  |  Lecturas: ${activeReadings.length}',
      _roundsOffset,
      fontSize: 14,
      color: DGTColors.textPrimary,
    );

    // 4. Total & precision
    final perfScore = PointsCalculator.calculatePerfectionScore(
      player.readings,
    );
    final perfLabel = perfScore.isFinite ? perfScore.toStringAsFixed(2) : '—';
    _drawText(
      canvas,
      'Total perdido: ${player.moneyLost}€  |  Precisión: $perfLabel',
      _totalsOffset,
      fontSize: 13,
      color: DGTColors.textPrimary,
    );

    // 5. Fine count
    if (player.fineCount > 0) {
      _drawText(
        canvas,
        '🚗 ${player.fineCount} multa${player.fineCount == 1 ? '' : 's'}',
        _finesOffset,
        fontSize: 14,
        bold: true,
        color: DGTColors.red,
      );
    }
  }

  static void _drawFrontTitleIcons(
    Canvas canvas,
    Map<DGTTitle, ui.Image> titleImages,
    Map<DGTTitle, int> titleCounts,
  ) {
    if (titleImages.isEmpty) return;

    double x = _titlesOffset.dx;
    final double y = _titlesOffset.dy;

    for (final entry in titleImages.entries) {
      final destRect = Rect.fromLTWH(x, y, _titleIconSize, _titleIconSize);
      canvas.drawImageRect(
        entry.value,
        Rect.fromLTWH(
          0,
          0,
          entry.value.width.toDouble(),
          entry.value.height.toDouble(),
        ),
        destRect,
        Paint()..filterQuality = FilterQuality.high,
      );

      final count = titleCounts[entry.key] ?? 0;
      if (count > 1) {
        _drawText(
          canvas,
          '×$count',
          Offset(x + _titleIconSize - 10, y + _titleIconSize - 2),
          fontSize: 10,
          bold: true,
          color: DGTColors.textPrimary,
        );
      }

      x += _titleIconSize + _titleIconGap;
      if (x + _titleIconSize > _cardWidth - 20) break;
    }
  }

  static void _drawMedal(Canvas canvas, int position) {
    final color = switch (position) {
      1 => const Color(0xFFFFD700), // gold
      2 => const Color(0xFFC0C0C0), // silver
      _ => const Color(0xFFCD7F32), // bronze
    };
    final borderColor = switch (position) {
      1 => const Color(0xFFB8860B),
      2 => const Color(0xFF808080),
      _ => const Color(0xFF8B4513),
    };

    canvas.drawCircle(_medalOffset, _medalRadius, Paint()..color = borderColor);
    canvas.drawCircle(_medalOffset, _medalRadius - 3, Paint()..color = color);

    final label = switch (position) {
      1 => '1°',
      2 => '2°',
      _ => '3°',
    };
    _drawText(
      canvas,
      label,
      Offset(_medalOffset.dx - 14, _medalOffset.dy - 14),
      fontSize: 18,
      bold: true,
      color: Colors.white,
    );
  }

  static void _drawColeccionistaBadge(Canvas canvas) {
    _drawText(
      canvas,
      '👑',
      Offset(
        _coleccionistaOffset.dx - _coleccionistaSize / 2 + 4,
        _coleccionistaOffset.dy - _coleccionistaSize / 2,
      ),
      fontSize: 36,
    );
  }

  // ---------------------------------------------------------------------------
  // Back drawing helpers
  // ---------------------------------------------------------------------------

  static void _drawBackLeftPanel(
    Canvas canvas,
    PlayerProfile player,
    Map<DGTTitle, ui.Image> titleImages,
    ui.Image? fineImage,
    ui.Image? envImage,
  ) {
    double y = _bkStartY;

    _drawText(
      canvas,
      'HISTORIAL DE RONDAS',
      Offset(_bkLeftX, y),
      fontSize: 14,
      bold: true,
      color: DGTColors.primary,
      maxWidth: _bkLeftW,
    );
    y += _bkRowH + 4;

    final activeReadings =
        player.readings.where((r) => r.isActiveRound).toList()
          ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    if (activeReadings.isEmpty) {
      _drawText(
        canvas,
        'Sin lecturas aún',
        Offset(_bkLeftX, y),
        fontSize: 13,
        color: DGTColors.textSecondary,
        maxWidth: _bkLeftW,
      );
      y += _bkRowH + 2;
    } else {
      for (final r in activeReadings) {
        final sign = r.pointsChange >= 0 ? '+' : '';
        _drawText(
          canvas,
          'R${r.roundNumber}: ${r.formattedBAC} mg/L',
          Offset(_bkLeftX, y),
          fontSize: 13,
          color: Colors.black,
          maxWidth: _bkLeftW,
        );
        y += _bkRowH;
        _drawText(
          canvas,
          '  $sign${r.pointsChange} pts',
          Offset(_bkLeftX, y),
          fontSize: 12,
          color: r.pointsChange >= 0 ? DGTColors.primary : DGTColors.red,
          maxWidth: _bkLeftW,
        );
        y += _bkRowH + 2;
        if (y > 260) break;
      }
    }

    y += 6;

    // Total perdido
    _drawText(
      canvas,
      'Total perdido: ${player.moneyLost}€',
      Offset(_bkLeftX, y),
      fontSize: 13,
      bold: true,
      color: Colors.black,
      maxWidth: _bkLeftW,
    );
    y += _bkRowH + 4;

    // Precision
    final perfScore = PointsCalculator.calculatePerfectionScore(
      player.readings,
    );
    final perfLabel = perfScore.isFinite
        ? perfScore.toStringAsFixed(2)
        : 'Sin datos';
    _drawText(
      canvas,
      'Precisión: $perfLabel',
      Offset(_bkLeftX, y),
      fontSize: 13,
      bold: true,
      color: Colors.black,
      maxWidth: _bkLeftW,
    );
    y += _bkRowH + 8;

    // Title icons — small row below precision
    if (titleImages.isNotEmpty) {
      _drawText(
        canvas,
        'Títulos:',
        Offset(_bkLeftX, y),
        fontSize: 12,
        bold: true,
        color: DGTColors.primary,
        maxWidth: _bkLeftW,
      );
      y += 16;

      double x = _bkLeftX;
      const double iconSize = 30;
      const double iconGap = 4;

      for (final entry in titleImages.entries) {
        canvas.drawImageRect(
          entry.value,
          Rect.fromLTWH(
            0,
            0,
            entry.value.width.toDouble(),
            entry.value.height.toDouble(),
          ),
          Rect.fromLTWH(x, y, iconSize, iconSize),
          Paint()..filterQuality = FilterQuality.high,
        );
        final count = player.titleCounts[entry.key] ?? 0;
        if (count > 1) {
          _drawText(
            canvas,
            '×$count',
            Offset(x + iconSize - 8, y + iconSize - 2),
            fontSize: 9,
            bold: true,
            color: DGTColors.textPrimary,
          );
        }
        x += iconSize + iconGap;
        if (x + iconSize > _bkLeftX + _bkLeftW) break;
      }
      y += iconSize + 8;
    }

    // Distintivo Ambiental — below títulos
    if (envImage != null) {
      canvas.drawImageRect(
        envImage,
        Rect.fromLTWH(
          0,
          0,
          envImage.width.toDouble(),
          envImage.height.toDouble(),
        ),
        Rect.fromLTWH(_bkLeftX, y, _bkEnvIconSize, _bkEnvIconSize),
        Paint()..filterQuality = FilterQuality.high,
      );
      _drawText(
        canvas,
        'Distintivo\nAmbiental',
        Offset(_bkLeftX + _bkEnvIconSize + 6, y + _bkEnvIconSize / 2 - 12),
        fontSize: 11,
        bold: true,
        color: DGTColors.primary,
      );
      y += _bkEnvIconSize + 8;
    }

    // Fine icon + count — inline, small
    if (fineImage != null) {
      const double fineSize = 28;
      canvas.drawImageRect(
        fineImage,
        Rect.fromLTWH(
          0,
          0,
          fineImage.width.toDouble(),
          fineImage.height.toDouble(),
        ),
        Rect.fromLTWH(_bkLeftX, y, fineSize, fineSize),
        Paint()..filterQuality = FilterQuality.high,
      );
      _drawText(
        canvas,
        ' ${player.fineCount} multa${player.fineCount == 1 ? '' : 's'}',
        Offset(_bkLeftX + fineSize + 4, y + 4),
        fontSize: 12,
        bold: true,
        color: DGTColors.red,
        maxWidth: _bkLeftW - fineSize - 4,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Shared drawing helpers
  // ---------------------------------------------------------------------------

  static void _drawTemplate(Canvas canvas, ui.Image template) {
    canvas.drawImageRect(
      template,
      Rect.fromLTWH(
        0,
        0,
        template.width.toDouble(),
        template.height.toDouble(),
      ),
      const Rect.fromLTWH(0, 0, _cardWidth, _cardHeight),
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  static void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    double fontSize = 14,
    bool bold = false,
    Color color = DGTColors.textPrimary,
    double maxWidth = 380,
  }) {
    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          )
          ..pushStyle(ui.TextStyle(color: color))
          ..addText(text);
    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: maxWidth));
    canvas.drawParagraph(paragraph, offset);
  }

  static Future<ui.Image> _loadAssetImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return _decodeImageBytes(data.buffer.asUint8List());
  }

  static Future<ui.Image> _decodeImageBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
