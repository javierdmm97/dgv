import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/breathalyzer/data/ocr_service.dart';
import 'package:dgv/features/breathalyzer/presentation/bac_confirmation_screen.dart';
import 'package:dgv/features/breathalyzer/presentation/manual_entry_screen.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';
import 'package:dgv/widgets/massive_button.dart';

/// Full-screen camera viewfinder that reads BrAC values via OCR.
///
/// - Captures a frame every 500 ms and passes it to [OcrService.recognise].
/// - Confidence > 0.90 → auto-navigates to [BacConfirmationScreen].
/// - Confidence ≤ 0.90 → shows detected value with "Confirmar"/"Reintentar".
/// - No valid value within 10 s → navigates to [ManualEntryScreen].
/// - Camera unavailable/permission denied → error dialog → [ManualEntryScreen].
/// - "Entrada manual" button always visible at bottom.
class CameraOcrScreen extends StatefulWidget {
  const CameraOcrScreen({
    super.key,
    required this.player,
    OcrService? ocrService,
  }) : _ocrService = ocrService;

  final PlayerProfile player;

  /// Injectable OCR service — defaults to [MlKitOcrService] in production.
  final OcrService? _ocrService;

  @override
  State<CameraOcrScreen> createState() => _CameraOcrScreenState();
}

class _CameraOcrScreenState extends State<CameraOcrScreen> {
  CameraController? _cameraController;
  late final OcrService _ocrService;

  Timer? _captureTimer;
  Timer? _timeoutTimer;

  bool _isProcessing = false;
  bool _navigating = false;

  /// Low-confidence candidate waiting for manual confirmation.
  OcrCandidate? _pendingCandidate;

  static const _captureInterval = Duration(milliseconds: 500);
  static const _timeoutDuration = Duration(seconds: 10);
  static const _highConfidenceThreshold = 0.90;

  @override
  void initState() {
    super.initState();
    _ocrService = widget._ocrService ?? MlKitOcrService();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showCameraError('No se encontró ninguna cámara en este dispositivo.');
        return;
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) return;

      setState(() => _cameraController = controller);
      _startCapturing();
    } on CameraException catch (e) {
      final msg = e.code == 'CameraAccessDenied'
          ? 'Permiso de cámara denegado. Actívalo en Ajustes.'
          : 'No se pudo inicializar la cámara: ${e.description}';
      _showCameraError(msg);
    } on Exception catch (_) {
      _showCameraError('No se pudo inicializar la cámara.');
    }
  }

  void _startCapturing() {
    _timeoutTimer = Timer(_timeoutDuration, _onTimeout);
    _captureTimer = Timer.periodic(_captureInterval, (_) => _captureFrame());
  }

  Future<void> _captureFrame() async {
    if (_isProcessing || _navigating) return;
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    _isProcessing = true;
    try {
      final xFile = await controller.takePicture();
      final bytes = await xFile.readAsBytes();
      await _processFrame(bytes);
    } on Exception {
      // Silently ignore capture errors — keep trying.
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _processFrame(Uint8List bytes) async {
    final candidates = await _ocrService.recognise(bytes);
    if (candidates.isEmpty || _navigating) return;

    final best = candidates.first;

    if (best.confidence > _highConfidenceThreshold) {
      _stopCapturing();
      await _pushConfirmation(best.value);
    } else {
      // Show low-confidence overlay — operator must confirm manually.
      if (mounted && _pendingCandidate?.value != best.value) {
        setState(() => _pendingCandidate = best);
      }
    }
  }

  void _onTimeout() {
    if (_navigating) return;
    _stopCapturing();
    _goToManualEntry();
  }

  void _stopCapturing() {
    _captureTimer?.cancel();
    _timeoutTimer?.cancel();
  }

  Future<void> _pushConfirmation(double value) async {
    if (_navigating || !mounted) return;
    _navigating = true;

    final result = await Navigator.push<BACEntryResult?>(
      context,
      MaterialPageRoute<BACEntryResult?>(
        builder: (_) => BacConfirmationScreen(
          args: BacConfirmationArgs(player: widget.player, enteredValue: value),
        ),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      // Confirmed — pop back to caller with result.
      Navigator.pop(context, result);
    } else {
      // Corregir — restart capturing.
      _navigating = false;
      setState(() => _pendingCandidate = null);
      _startCapturing();
    }
  }

  void _goToManualEntry() {
    if (!mounted) return;
    Navigator.pushReplacement<BACEntryResult?, void>(
      context,
      MaterialPageRoute<BACEntryResult?>(
        builder: (_) => ManualEntryScreen(player: widget.player),
      ),
    );
  }

  void _showCameraError(String message) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Error de cámara'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _goToManualEntry();
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopCapturing();
    _cameraController?.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('El Radar — ${widget.player.name}'),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _CameraPreview(controller: _cameraController),
          if (_pendingCandidate != null)
            _LowConfidenceOverlay(
              candidate: _pendingCandidate!,
              onConfirm: () => _pushConfirmation(_pendingCandidate!.value),
              onRetry: () => setState(() => _pendingCandidate = null),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: MassiveButton(
              text: 'Entrada manual',
              onPressed: () {
                _stopCapturing();
                _goToManualEntry();
              },
              backgroundColor: DGTColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _CameraPreview extends StatelessWidget {
  const _CameraPreview({required this.controller});

  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return CameraPreview(ctrl);
  }
}

/// Overlay shown when a low-confidence candidate is detected.
class _LowConfidenceOverlay extends StatelessWidget {
  const _LowConfidenceOverlay({
    required this.candidate,
    required this.onConfirm,
    required this.onRetry,
  });

  final OcrCandidate candidate;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Valor detectado',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${candidate.value.toStringAsFixed(2)} mg/L',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          MassiveButton(text: 'Confirmar', onPressed: onConfirm),
          const SizedBox(height: 16),
          MassiveButton(
            text: 'Reintentar',
            onPressed: onRetry,
            backgroundColor: DGTColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
