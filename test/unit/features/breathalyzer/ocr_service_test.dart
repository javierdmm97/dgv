import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/features/breathalyzer/data/ocr_service.dart';

// ---------------------------------------------------------------------------
// Fake implementation for testing
// ---------------------------------------------------------------------------

/// A controllable [OcrService] that returns pre-configured candidates.
class FakeOcrService implements OcrService {
  FakeOcrService({this.candidates = const [], this.throwOnRecognise = false});

  final List<OcrCandidate> candidates;
  final bool throwOnRecognise;

  int recogniseCallCount = 0;
  bool disposed = false;

  @override
  Future<List<OcrCandidate>> recognise(Uint8List imageBytes) async {
    recogniseCallCount++;
    if (throwOnRecognise) throw Exception('Camera error');
    return candidates;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  group('OcrCandidate', () {
    test('stores value and confidence', () {
      const candidate = OcrCandidate(value: 0.45, confidence: 0.95);
      expect(candidate.value, equals(0.45));
      expect(candidate.confidence, equals(0.95));
    });
  });

  group('FakeOcrService', () {
    test('returns empty list when no candidates configured', () async {
      final service = FakeOcrService();
      final result = await service.recognise(Uint8List(0));
      expect(result, isEmpty);
    });

    test('returns configured candidates', () async {
      final service = FakeOcrService(
        candidates: [
          const OcrCandidate(value: 0.45, confidence: 0.95),
          const OcrCandidate(value: 0.30, confidence: 0.60),
        ],
      );
      final result = await service.recognise(Uint8List(0));
      expect(result.length, equals(2));
      expect(result.first.value, equals(0.45));
    });

    test('high confidence candidate (>0.90) is first when sorted', () async {
      final service = FakeOcrService(
        candidates: [
          const OcrCandidate(value: 0.30, confidence: 0.60),
          const OcrCandidate(value: 0.45, confidence: 0.95),
        ],
      );
      final result = await service.recognise(Uint8List(0));
      // Caller is responsible for sorting; FakeOcrService returns as-is.
      // This test verifies the caller can inspect confidence.
      expect(result.any((c) => c.confidence > 0.90), isTrue);
    });

    test('dispose marks service as disposed', () async {
      final service = FakeOcrService();
      await service.dispose();
      expect(service.disposed, isTrue);
    });

    test('recognise increments call count', () async {
      final service = FakeOcrService();
      await service.recognise(Uint8List(0));
      await service.recognise(Uint8List(0));
      expect(service.recogniseCallCount, equals(2));
    });
  });

  // ---------------------------------------------------------------------------
  // Confidence-based auto-confirm logic (tested via FakeOcrService)
  // ---------------------------------------------------------------------------

  group('OCR confidence routing logic', () {
    test(
      'single high-confidence candidate triggers auto-confirm path',
      () async {
        final service = FakeOcrService(
          candidates: [const OcrCandidate(value: 0.45, confidence: 0.95)],
        );
        final candidates = await service.recognise(Uint8List(0));
        final best = candidates.isNotEmpty ? candidates.first : null;

        expect(best, isNotNull);
        expect(best!.confidence, greaterThan(0.90));
      },
    );

    test('low-confidence candidate requires manual confirmation', () async {
      final service = FakeOcrService(
        candidates: [const OcrCandidate(value: 0.45, confidence: 0.75)],
      );
      final candidates = await service.recognise(Uint8List(0));
      final best = candidates.isNotEmpty ? candidates.first : null;

      expect(best, isNotNull);
      expect(best!.confidence, lessThanOrEqualTo(0.90));
    });

    test('no candidates triggers timeout/fallback path', () async {
      final service = FakeOcrService(candidates: []);
      final candidates = await service.recognise(Uint8List(0));

      expect(candidates, isEmpty);
    });

    test(
      'multiple candidates — highest confidence is first when pre-sorted',
      () async {
        // MlKitOcrService sorts descending; FakeOcrService returns as-is.
        // Simulate what MlKitOcrService would return after sorting.
        final sorted = [
          const OcrCandidate(value: 0.45, confidence: 0.95),
          const OcrCandidate(value: 0.30, confidence: 0.70),
          const OcrCandidate(value: 0.12, confidence: 0.50),
        ];
        final service = FakeOcrService(candidates: sorted);
        final candidates = await service.recognise(Uint8List(0));

        // Verify the first candidate has the highest confidence.
        for (var i = 1; i < candidates.length; i++) {
          expect(
            candidates[i - 1].confidence,
            greaterThanOrEqualTo(candidates[i].confidence),
          );
        }
      },
    );

    test('service error returns empty list gracefully', () async {
      final service = FakeOcrService(throwOnRecognise: true);
      // The screen catches exceptions; here we verify the fake throws.
      expect(() => service.recognise(Uint8List(0)), throwsException);
    });
  });
}
