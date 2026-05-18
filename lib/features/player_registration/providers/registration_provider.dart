import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/utils/bac_calculator.dart';

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
  @override
  RegistrationFormState build() => const RegistrationFormState();

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

    try {
      final optimalBAC = BACCalculator.calculateOptimalBAC(s.bodySize!);
      final profile = PlayerProfile(
        id: const Uuid().v4(),
        name: s.name,
        surname: s.surname,
        photoPath: s.photoPath,
        sex: s.sex!,
        bodySize: s.bodySize!,
        optimalBAC: optimalBAC,
        licenseImagePath: '',
        createdAt: DateTime.now(),
      );

      await ref.read(playerListNotifierProvider.notifier).addPlayer(profile);
      // Reset form after success
      state = const RegistrationFormState();
    } on Exception catch (e) {
      state = s.copyWith(isLoading: false, error: e.toString());
    }
  }
}
