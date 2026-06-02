import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/features/firebase/services/firebase_storage_service.dart';
import 'package:dgv/features/firebase/services/firebase_sync_service.dart';

final firebaseSyncServiceProvider = Provider<FirebaseSyncService>((ref) {
  return FirebaseSyncService(FirebaseFirestore.instance);
});

final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService(FirebaseStorage.instance);
});
