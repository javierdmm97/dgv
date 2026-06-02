import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:dgv/features/firebase/providers/firebase_providers.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/providers/repository_providers.dart';
import 'package:dgv/features/fake_id/services/license_generator.dart';
import 'package:dgv/features/fake_id/services/license_update_service.dart';

part 'registration_provider.freezed.dart';
part 'registration_provider.g.dart';

/// Transient UI state for the multi-step registration flow.
/// Not persisted to Hive — only lives during the registration screen lifecycle.
@freezed
class RegistrationFormState with _$RegistrationFormState {
  const factory RegistrationFormState({
    @Default(0) int step,
    @Default('') String name,
    @Default('') String surname,
    Sex? sex,
    BodySize? bodySize,
    @Default('') String photoPath,
    @Default(false) bool isLoading,
    String? error,
  }) = _RegistrationFormState;
}

@riverpod
class RegistrationNotifier extends _$RegistrationNotifier {
  /// Tracks the ID of the player being edited, or null for create mode.
  String? _editingPlayerId;

  @override
  RegistrationFormState build() => const RegistrationFormState();

  /// Pre-populates all fields for editing an existing player.
  void initForEdit(PlayerProfile player) {
    _editingPlayerId = player.id;
    state = RegistrationFormState(
      name: player.name,
      surname: player.surname,
      sex: player.sex,
      bodySize: player.bodySize,
      photoPath: player.photoPath,
    );
  }

  /// Resets to blank create mode.
  void reset() {
    _editingPlayerId = null;
    state = const RegistrationFormState();
  }

  void setName(String value) =>
      state = state.copyWith(name: value.trim(), error: null);

  void setSurname(String value) =>
      state = state.copyWith(surname: value.trim(), error: null);

  void setSex(Sex value) => state = state.copyWith(sex: value, error: null);

  void setBodySize(BodySize value) =>
      state = state.copyWith(bodySize: value, error: null);

  void setPhoto(String path) =>
      state = state.copyWith(photoPath: path, error: null);

  void nextStep() {
    if (!_canAdvance()) return;
    state = state.copyWith(step: state.step + 1, error: null);
  }

  void previousStep() {
    if (state.step > 0) {
      state = state.copyWith(step: state.step - 1, error: null);
    }
  }

  bool _canAdvance() {
    switch (state.step) {
      case 0:
        return state.name.isNotEmpty;
      case 1:
        return state.surname.isNotEmpty;
      case 2:
        return state.sex != null;
      case 3:
        return state.bodySize != null;
      default:
        return false;
    }
  }

  Future<void> submit() async {
    final s = state;
    if (s.name.isEmpty ||
        s.surname.isEmpty ||
        s.sex == null ||
        s.bodySize == null) {
      state = s.copyWith(error: 'Completa todos los campos');
      return;
    }

    state = s.copyWith(isLoading: true, error: null);

    final editId = _editingPlayerId;
    if (editId != null) {
      await _submitEdit(s, editId);
    } else {
      await _submitCreate(s);
    }
  }

  Future<void> _submitCreate(RegistrationFormState s) async {
    try {
      final bare = PlayerProfile(
        id: const Uuid().v4(),
        name: s.name,
        surname: s.surname,
        photoPath: s.photoPath,
        sex: s.sex!,
        bodySize: s.bodySize!,
        licenseImagePath: '',
        createdAt: DateTime.now(),
      );

      // Generate both license sides immediately so the viewer always has images.
      final frontPath = await LicenseGenerator.generate(bare);
      final backPath = await LicenseGenerator.generateBack(bare);
      final profile = bare.copyWith(
        licenseImagePath: frontPath,
        licenseBackImagePath: backPath,
      );

      await ref.read(playerListNotifierProvider.notifier).addPlayer(profile);
      final syncService = ref.read(firebaseSyncServiceProvider);
      unawaited(
        _compressPhotoToBase64(profile.photoPath).then(
          (url) => syncService.syncPlayerRegistration(
            url != null ? profile.copyWith(photoPath: url) : profile,
          ),
        ),
      );
      state = const RegistrationFormState();
    } on Exception catch (e) {
      state = s.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _submitEdit(RegistrationFormState s, String playerId) async {
    try {
      final repo = ref.read(playerRepositoryProvider);
      final existing = await repo.getById(playerId);
      if (existing == null) {
        state = s.copyWith(isLoading: false, error: 'Conductor no encontrado');
        return;
      }
      final updated = existing.copyWith(
        name: s.name,
        surname: s.surname,
        sex: s.sex!,
        bodySize: s.bodySize!,
        photoPath: s.photoPath.isNotEmpty ? s.photoPath : existing.photoPath,
      );
      await LicenseUpdateService.updateForPlayer(player: updated, repo: repo);
      ref.invalidate(playerListNotifierProvider);
      _editingPlayerId = null;
      state = const RegistrationFormState();
    } on Exception catch (e) {
      state = s.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// Compresses [localPath] to a JPEG and returns a base64 data URL, or null on failure.
Future<String?> _compressPhotoToBase64(String localPath) async {
  if (localPath.isEmpty) return null;
  try {
    final file = File(localPath);
    if (!file.existsSync()) return null;
    final compressed = await FlutterImageCompress.compressWithFile(
      localPath,
      minWidth: 400,
      minHeight: 400,
      quality: 75,
      format: CompressFormat.webp,
    );
    if (compressed == null) return null;
    return 'data:image/webp;base64,${base64Encode(compressed)}';
  } on Exception catch (e) {
    if (kDebugMode) debugPrint('[Registration] photo compress failed: $e');
    return null;
  }
}
