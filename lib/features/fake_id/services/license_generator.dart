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

  static const Offset _photoCenter = Offset(100, 200);
  static const double _photoRadius = 68;

  static const Offset _nameOffset = Offset(200, 90);
  static const Offset _pointsOffset = Offset(200, 125);
  static const Offset _titlesOffset = Offset(200, 155);

  /// Generates a license PNG for [player] and returns the absolute file path.
  static Future<String> generate(PlayerProfile player) async {
    final templateImage = await _loadAssetImage(AssetPaths.licenseFront);

    ui.Image? playerPhoto;
    if (player.photoPath.isNotEmpty) {
      try {
        final bytes = await File(player.photoPath).readAsBytes();
        playerPhoto = await _decodeImageBytes(bytes);
      } on Exception {
        // Silently fall back to initials avatar if photo is missing/corrupt.
      }
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      const Rect.fromLTWH(0, 0, _cardWidth, _cardHeight),
    );

    _drawTemplate(canvas, templateImage);
    _drawPhotoOrInitials(canvas, playerPhoto, player);
    _drawTextOverlays(canvas, player);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      _cardWidth.toInt(),
      _cardHeight.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/license_${player.id}.png');
    await file.writeAsBytes(pngBytes, flush: true);
    return file.path;
  }

  /// Generates the back-side license PNG for [player] and returns the file path.
  ///
  /// Draws a round-by-round BAC table, fine log, total money lost, and
  /// perfection score onto the back template (600×375 canvas).
  static Future<String> generateBack(PlayerProfile player) async {
    final templateImage = await _loadAssetImage(AssetPaths.licenseBack);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      const Rect.fromLTWH(0, 0, _cardWidth, _cardHeight),
    );

    _drawTemplate(canvas, templateImage);
    _drawBackContent(canvas, player);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      _cardWidth.toInt(),
      _cardHeight.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/license_back_${player.id}.png');
    await file.writeAsBytes(pngBytes, flush: true);
    return file.path;
  }

  // ---------------------------------------------------------------------------
  // Back-side drawing helpers
  // ---------------------------------------------------------------------------

  static void _drawBackContent(Canvas canvas, PlayerProfile player) {
    const double leftCol = 20;
    const double rightCol = 310;
    const double topY = 20;
    const double rowHeight = 22;

    // --- Section header: round-by-round table ---
    _drawText(
      canvas,
      'HISTORIAL DE RONDAS',
      const Offset(leftCol, topY),
      fontSize: 11,
      bold: true,
      color: DGTColors.primary,
    );

    final activeReadings =
        player.readings.where((r) => r.isActiveRound).toList()
          ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

    double y = topY + rowHeight;
    for (final reading in activeReadings) {
      final sign = reading.pointsChange >= 0 ? '+' : '';
      final line =
          'R${reading.roundNumber}: ${reading.formattedBAC} mg/L  '
          '($sign${reading.pointsChange} pts)';
      _drawText(
        canvas,
        line,
        Offset(leftCol, y),
        fontSize: 10,
        color: reading.pointsChange >= 0 ? DGTColors.green : DGTColors.red,
      );
      y += rowHeight - 2;
      if (y > _cardHeight - 60) break; // guard against overflow
    }

    // --- Section header: fine log ---
    _drawText(
      canvas,
      'MULTAS',
      const Offset(rightCol, topY),
      fontSize: 11,
      bold: true,
      color: DGTColors.red,
    );

    final fines = activeReadings
        .where((r) => PointsCalculator.shouldIssueFine(r.pointsChange))
        .toList();

    double fy = topY + rowHeight;
    if (fines.isEmpty) {
      _drawText(
        canvas,
        'Sin multas 🎉',
        Offset(rightCol, fy),
        fontSize: 10,
        color: DGTColors.green,
      );
    } else {
      for (int i = 0; i < fines.length; i++) {
        final fine = fines[i];
        _drawText(
          canvas,
          'Multa ${i + 1} — Ronda ${fine.roundNumber} — 100€',
          Offset(rightCol, fy),
          fontSize: 10,
          color: DGTColors.red,
        );
        fy += rowHeight - 2;
        if (fy > _cardHeight - 60) break;
      }
    }

    // --- Footer: total money lost + perfection score ---
    const double footerY = _cardHeight - 50;

    _drawText(
      canvas,
      'Total perdido: ${player.moneyLost}€',
      const Offset(leftCol, footerY),
      fontSize: 11,
      bold: true,
      color: DGTColors.textPrimary,
    );

    final perfScore = PointsCalculator.calculatePerfectionScore(
      player.readings,
      player.sex,
      player.bodySize,
    );
    final perfLabel = perfScore == double.infinity
        ? 'Sin datos'
        : perfScore.toStringAsFixed(3);

    _drawText(
      canvas,
      'Precisión: $perfLabel',
      const Offset(rightCol, footerY),
      fontSize: 11,
      bold: true,
      color: DGTColors.primary,
    );
  }

  // ---------------------------------------------------------------------------
  // Drawing helpers
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
      Paint(),
    );
  }

  static void _drawPhotoOrInitials(
    Canvas canvas,
    ui.Image? photo,
    PlayerProfile player,
  ) {
    if (photo != null) {
      _clipCircle(canvas, _photoCenter, _photoRadius, () {
        canvas.drawImageRect(
          photo,
          Rect.fromLTWH(0, 0, photo.width.toDouble(), photo.height.toDouble()),
          Rect.fromCircle(center: _photoCenter, radius: _photoRadius),
          Paint(),
        );
      });
    } else {
      canvas.drawCircle(
        _photoCenter,
        _photoRadius,
        Paint()..color = DGTColors.primary,
      );
      _drawText(
        canvas,
        '${player.name[0]}${player.surname[0]}',
        _photoCenter - const Offset(28, 22),
        fontSize: 44,
        bold: true,
        color: DGTColors.textOnPrimary,
      );
    }
  }

  static void _drawTextOverlays(Canvas canvas, PlayerProfile player) {
    _drawText(
      canvas,
      '${player.name} ${player.surname}'.toUpperCase(),
      _nameOffset,
      fontSize: 18,
      bold: true,
      color: DGTColors.textPrimary,
    );

    _drawText(
      canvas,
      '${player.points} puntos',
      _pointsOffset,
      fontSize: 16,
      color: DGTColors.primary,
    );

    final earned = player.titleCounts.entries
        .where((e) => e.value > 0)
        .map((e) => e.key.emoji)
        .join(' ');
    if (earned.isNotEmpty) {
      _drawText(canvas, earned, _titlesOffset, fontSize: 20);
    }

    if (player.fineCount > 0) {
      _drawText(
        canvas,
        '🚗 ${player.fineCount} multa${player.fineCount == 1 ? '' : 's'}',
        const Offset(200, 220),
        fontSize: 14,
        bold: true,
        color: DGTColors.red,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Low-level helpers
  // ---------------------------------------------------------------------------

  static void _clipCircle(
    Canvas canvas,
    Offset center,
    double radius,
    void Function() draw,
  ) {
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );
    draw();
    canvas.restore();
  }

  static void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    double fontSize = 14,
    bool bold = false,
    Color color = DGTColors.textPrimary,
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
      ..layout(const ui.ParagraphConstraints(width: 380));
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
