import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/notification_service.dart';
import 'core/storage/hive_service.dart';
import 'features/firebase/services/firebase_sync_service.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the whole app to portrait; the license viewer overrides this locally.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await HiveService.init();
  await NotificationService.init();
  await _initFirebase();

  runApp(const ProviderScope(child: DGVApp()));
}

/// Initialise Firebase with offline persistence enabled.
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    FirebaseSyncService.markInitialized();
  } on Exception catch (e) {
    if (kDebugMode) debugPrint('[Firebase] init failed — sync disabled: $e');
  }
}
