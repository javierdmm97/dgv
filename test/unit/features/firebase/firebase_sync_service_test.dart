import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/features/firebase/services/firebase_sync_service.dart';

PlayerProfile _makePlayer({String photoPath = 'C:\\local\\photo.jpg'}) {
  return PlayerProfile(
    id: 'p1',
    name: 'Test',
    surname: 'Player',
    photoPath: photoPath,
    sex: Sex.male,
    bodySize: BodySize.medium,
    points: 12,
    readings: [
      BACReading(
        id: 'r0',
        playerId: 'p1',
        bac: 0.05,
        timestamp: DateTime(2026, 6, 2, 10),
        roundNumber: 0,
        entryMethod: BACEntryMethod.manual,
      ),
      BACReading(
        id: 'r1',
        playerId: 'p1',
        bac: 0.35,
        timestamp: DateTime(2026, 6, 2, 11),
        roundNumber: 1,
        entryMethod: BACEntryMethod.manual,
        pointsChange: -4,
        optimalBAC: 0.2,
      ),
    ],
    titleCounts: const {DGTTitle.multaPorExceso: 1},
    crossedOptimalLine: true,
    fineCount: 1,
    moneyLost: 100,
    licenseImagePath: '',
    createdAt: DateTime(2026, 6, 2, 9),
  );
}

void main() {
  group('FirebaseSyncService document builders', () {
    test('global player profile excludes session gameplay fields', () {
      final doc = FirebaseSyncService.buildPlayerProfileDocForTest(
        _makePlayer(),
      );

      expect(doc.keys, containsAll(['name', 'surname', 'sex', 'bodySize']));
      expect(doc, isNot(contains('points')));
      expect(doc, isNot(contains('fineCount')));
      expect(doc, isNot(contains('moneyLost')));
      expect(doc, isNot(contains('titleCounts')));
      expect(doc, isNot(contains('readings')));
      expect(doc, isNot(contains('bacHistory')));
      expect(doc, isNot(contains('photoUrl')));
    });

    test('global player profile preserves remote/base64 photo urls', () {
      final doc = FirebaseSyncService.buildPlayerProfileDocForTest(
        _makePlayer(photoPath: 'data:image/webp;base64,abc123'),
      );

      expect(doc['photoUrl'], equals('data:image/webp;base64,abc123'));
    });

    test('session player doc contains gameplay fields', () {
      final doc = FirebaseSyncService.buildSessionPlayerDocForTest(
        _makePlayer(),
      );

      expect(doc['playerId'], equals('p1'));
      expect(doc['points'], equals(12));
      expect(doc['fineCount'], equals(1));
      expect(doc['moneyLost'], equals(100));
      expect(doc['crossedOptimalLine'], isTrue);
      expect(doc['titleCounts'], equals({'multaPorExceso': 1}));
      expect(doc['bacHistory'], equals([0.35]));
      expect(doc['optimalBACHistory'], equals([0.2]));
      expect(doc['readings'], hasLength(2));
      expect(doc, isNot(contains('name')));
      expect(doc, isNot(contains('surname')));
      expect(doc, isNot(contains('photoUrl')));
    });
  });
}
