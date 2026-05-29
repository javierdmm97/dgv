import 'dart:typed_data';
import 'dart:ui' show Size;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// A single OCR candidate value extracted from a camera frame.
class OcrCandidate {
  const OcrCandidate({required this.value, required this.confidence});

  /// Parsed BrAC value, e.g. 0.45.
  final double value;

  /// Confidence score in [0.0, 1.0].
  final double confidence;
}

/// Abstract interface for OCR text recognition.
///
/// Inject a [FakeOcrService] in tests; use [MlKitOcrService] in production.
abstract interface class OcrService {
  /// Recognise text in [imageBytes] and return all candidate BrAC values
  /// sorted by confidence descending. Returns an empty list if none found.
  Future<List<OcrCandidate>> recognise(Uint8List imageBytes);

  /// Release any underlying resources.
  Future<void> dispose();
}

/// Production implementation backed by Google ML Kit Text Recognition.
///
/// Filters recognised text lines with the regex `\d\.\d{2}`, parses each
/// match to [double], and derives confidence from the ML Kit line score.
class MlKitOcrService implements OcrService {
  MlKitOcrService() : _recognizer = TextRecognizer();

  final TextRecognizer _recognizer;

  // Matches values like "0.45", "1.23", "0.00"
  static final _bracPattern = RegExp(r'\d\.\d{2}');

  @override
  Future<List<OcrCandidate>> recognise(Uint8List imageBytes) async {
    final inputImage = InputImage.fromBytes(
      bytes: imageBytes,
      metadata: InputImageMetadata(
        size: const Size(640, 480),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: 640,
      ),
    );

    final RecognizedText recognized;
    try {
      recognized = await _recognizer.processImage(inputImage);
    } on Exception {
      return [];
    }

    final candidates = <OcrCandidate>[];

    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        final lineConfidence = line.confidence ?? 0.0;
        final matches = _bracPattern.allMatches(line.text);
        for (final match in matches) {
          final parsed = double.tryParse(match.group(0)!);
          if (parsed == null) continue;
          candidates.add(
            OcrCandidate(value: parsed, confidence: lineConfidence),
          );
        }
      }
    }

    // Sort by confidence descending so the best candidate is first.
    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
    return candidates;
  }

  @override
  Future<void> dispose() async {
    _recognizer.close();
  }
}
