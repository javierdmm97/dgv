import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:dgv/features/firebase/services/firebase_sync_service.dart';

/// Compresses a player photo and returns a base64 data URL suitable for
/// storing in Firestore and rendering directly in the web frontend.
///
/// Falls back to the original [localPath] string if compression fails or
/// Firebase is unavailable — the app continues with a local-only photo.
class FirebaseStorageService {
  FirebaseStorageService(this._storage);

  // ignore: unused_field
  final FirebaseStorage _storage;

  Future<String> uploadPlayerPhoto(
    String playerId,
    String localPath,
  ) async {
    if (!FirebaseSyncService.isAvailable) return localPath;
    try {
      final file = File(localPath);
      if (!file.existsSync()) return localPath;

      final compressed = await FlutterImageCompress.compressWithFile(
        localPath,
        minWidth: 200,
        minHeight: 200,
        quality: 60,
      );
      if (compressed == null) return localPath;

      return 'data:image/jpeg;base64,${base64Encode(compressed)}';
    } on Exception catch (e) {
      if (kDebugMode) debugPrint('[Storage] compress failed: $e');
      return localPath;
    }
  }
}
