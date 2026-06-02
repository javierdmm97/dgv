import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/models/game_state.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/features/firebase/models/notification_payload.dart';

/// Writes app state to Firestore so the web frontend can display live data.
///
/// All methods are fire-and-forget — call with [unawaited]. Firebase offline
/// persistence buffers writes locally and flushes them when connectivity
/// is restored, so there is no need for a custom offline queue.
///
/// Call [markInitialized] from main() after [Firebase.initializeApp] succeeds.
/// Until then every write is silently skipped.
class FirebaseSyncService {
  FirebaseSyncService(this._db);

  final FirebaseFirestore _db;

  static bool _initialized = false;

  static void markInitialized() => _initialized = true;

  static bool get isAvailable => _initialized;

  @visibleForTesting
  static Map<String, dynamic> buildPlayerProfileDocForTest(
    PlayerProfile player,
  ) => _buildPlayerProfileDoc(player);

  @visibleForTesting
  static Map<String, dynamic> buildSessionPlayerDocForTest(
    PlayerProfile player,
  ) => _buildSessionPlayerDoc(player);

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Write a new session document when a game starts.
  Future<void> syncSessionCreate(GameState gameState) async {
    await _safeWrite(
      () => _db.collection('sessions').doc(gameState.id).set({
        'startTime': Timestamp.fromDate(gameState.startTime),
        'currentRound': gameState.currentRound,
        'isFinished': gameState.isFinished,
        'isInProgress': gameState.isInProgress,
        'playerIds': gameState.playerIds,
        'preGameBeers': gameState.preGameBeers,
      }),
    );
  }

  /// Register a player — creates their top-level [players/{id}] doc.
  Future<void> syncPlayerRegistration(PlayerProfile player) async {
    await _safeWrite(
      () => _db
          .collection('players')
          .doc(player.id)
          .set(_buildPlayerProfileDoc(player), SetOptions(merge: true)),
    );
  }

  /// Batch-update all players + session [currentRound] after a round completes.
  Future<void> syncRoundComplete({
    required String sessionId,
    required List<PlayerProfile> players,
    required int round,
  }) async {
    await _safeWrite(() async {
      final batch = _db.batch();

      if (sessionId.isNotEmpty) {
        batch.update(_db.collection('sessions').doc(sessionId), {
          'currentRound': round,
        });
      }

      for (final player in players) {
        batch.set(
          _db.collection('players').doc(player.id),
          _buildPlayerProfileDoc(player),
          SetOptions(merge: true),
        );
        if (sessionId.isNotEmpty) {
          batch.set(
            _sessionPlayerRef(sessionId, player.id),
            _buildSessionPlayerDoc(player),
            SetOptions(merge: true),
          );
        }
      }

      await batch.commit();
    });
  }

  /// Update a single player's session-scoped gameplay state after a BAC entry.
  Future<void> syncPlayerUpdate({
    required String sessionId,
    required PlayerProfile player,
  }) async {
    await _safeWrite(() async {
      final batch = _db.batch();
      batch.set(
        _db.collection('players').doc(player.id),
        _buildPlayerProfileDoc(player),
        SetOptions(merge: true),
      );
      if (sessionId.isNotEmpty) {
        batch.set(
          _sessionPlayerRef(sessionId, player.id),
          _buildSessionPlayerDoc(player),
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    });
  }

  /// Mark session as finished, write ceremony results, and do a final player sync.
  Future<void> syncGameFinish(
    GameState gameState,
    List<PlayerProfile> players,
    Map<String, dynamic> ceremony,
  ) async {
    await _safeWrite(() async {
      final batch = _db.batch();

      batch.update(_db.collection('sessions').doc(gameState.id), {
        'isFinished': true,
        'isInProgress': false,
        'finishTime': Timestamp.fromDate(
          gameState.finishTime ?? DateTime.now(),
        ),
        'ceremony': ceremony,
      });

      for (final player in players) {
        batch.set(
          _db.collection('players').doc(player.id),
          _buildPlayerProfileDoc(player),
          SetOptions(merge: true),
        );
        batch.set(
          _sessionPlayerRef(gameState.id, player.id),
          _buildSessionPlayerDoc(player),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    });
  }

  /// Write a notification to the [notifications] collection.
  ///
  /// The frontend displays it in a ticker and marks it read after 30–60 s.
  Future<void> sendNotification(NotificationPayload payload) async {
    await _safeWrite(
      () => _db.collection('notifications').doc(payload.id).set({
        'text': payload.text,
        'imageUrl': payload.imageUrl,
        'timestamp': Timestamp.fromDate(payload.timestamp),
        'status': payload.status,
        'type': payload.type,
        'targetPlayerId': payload.targetPlayerId,
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _safeWrite(Future<void> Function() write) async {
    if (!_initialized) return;
    try {
      await write().timeout(const Duration(seconds: 15));
    } on FirebaseException catch (e) {
      if (kDebugMode) debugPrint('[Firebase] ${e.code}: ${e.message}');
    } on Exception catch (e) {
      if (kDebugMode) debugPrint('[Firebase] write failed: $e');
    }
  }

  DocumentReference<Map<String, dynamic>> _sessionPlayerRef(
    String sessionId,
    String playerId,
  ) {
    return _db
        .collection('sessions')
        .doc(sessionId)
        .collection('players')
        .doc(playerId);
  }

  static Map<String, dynamic> _buildPlayerProfileDoc(PlayerProfile player) {
    final doc = <String, dynamic>{
      'name': player.name,
      'surname': player.surname,
      'sex': player.sex.name,
      'bodySize': player.bodySize.name,
      'createdAt': player.createdAt == null
          ? null
          : Timestamp.fromDate(player.createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (_isRemotePhoto(player.photoPath)) {
      doc['photoUrl'] = player.photoPath;
    }

    return doc;
  }

  static Map<String, dynamic> _buildSessionPlayerDoc(PlayerProfile player) {
    final doc = <String, dynamic>{
      'playerId': player.id,
      'points': player.points,
      'fineCount': player.fineCount,
      'moneyLost': player.moneyLost,
      'crossedOptimalLine': player.crossedOptimalLine,
      'isIncautado': player.isIncautado,
      'titleCounts': player.titleCounts.map((k, v) => MapEntry(k.name, v)),
      'titleDetails': player.titleCounts.entries
          .where((e) => e.value > 0)
          .map(
            (e) => {
              'key': e.key.name,
              'displayName': e.key.displayName,
              'emoji': e.key.emoji,
              'count': e.value,
            },
          )
          .toList(),
      'readings': _readingDocs(player.readings),
      'bacHistory': _bacHistory(player.readings),
      'optimalBACHistory': _optimalBACHistory(player.readings),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (_isRemotePhoto(player.photoPath)) {
      doc['photoUrl'] = player.photoPath;
    }

    return doc;
  }

  static bool _isRemotePhoto(String photoPath) {
    return photoPath.startsWith('data:image/') ||
        photoPath.startsWith('http://') ||
        photoPath.startsWith('https://');
  }

  static List<Map<String, dynamic>> _readingDocs(List<BACReading> readings) {
    return readings
        .map(
          (reading) => {
            'id': reading.id,
            'bac': reading.bac,
            'timestamp': Timestamp.fromDate(reading.timestamp),
            'roundNumber': reading.roundNumber,
            'entryMethod': reading.entryMethod.name,
            'pointsChange': reading.pointsChange,
            'optimalBAC': reading.optimalBAC,
            'notes': reading.notes,
          },
        )
        .toList();
  }

  static List<double> _bacHistory(List<BACReading> readings) {
    final byRound = <int, double>{};
    for (final r in readings.where((r) => r.isActiveRound)) {
      byRound[r.roundNumber] = r.bac;
    }
    final rounds = byRound.keys.toList()..sort();
    return rounds.map((k) => byRound[k]!).toList();
  }

  static List<double> _optimalBACHistory(List<BACReading> readings) {
    final byRound = <int, double>{};
    for (final r in readings.where((r) => r.isActiveRound)) {
      byRound[r.roundNumber] = r.optimalBAC;
    }
    final rounds = byRound.keys.toList()..sort();
    return rounds.map((k) => byRound[k]!).toList();
  }
}
