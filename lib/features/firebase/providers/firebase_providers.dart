import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/features/firebase/services/firebase_sync_service.dart';

final firebaseSyncServiceProvider = Provider<FirebaseSyncService>((ref) {
  try {
    return FirebaseSyncService(FirebaseFirestore.instance);
  } on Exception {
    // Firebase not initialized (e.g. test environments).
    // _safeWrite already no-ops when !_initialized, so this is always safe.
    return FirebaseSyncService(_DisabledFirestore());
  }
});

/// Stand-in used only when Firebase.initializeApp() has not been called.
/// Never actually invoked — FirebaseSyncService._safeWrite returns early
/// because _initialized is false.
class _DisabledFirestore implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
