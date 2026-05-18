import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/player_registration/providers/registration_provider.dart';
import 'package:dgv/widgets/massive_button.dart';

/// Multi-step player registration screen.
/// Steps: 0=Name, 1=Surname, 2=Sex, 3=BodySize, 4=Photo
class PlayerRegistrationScreen extends ConsumerStatefulWidget {
  const PlayerRegistrationScreen({super.key});

  @override
  ConsumerState<PlayerRegistrationScreen> createState() =>
      _PlayerRegistrationScreenState();
}

class _PlayerRegistrationScreenState
    extends ConsumerState<PlayerRegistrationScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _pageController = PageController();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );
    if (file != null) {
      ref.read(registrationNotifierProvider.notifier).setPhoto(file.path);
    }
  }

  Future<void> _submit() async {
    await ref.read(registrationNotifierProvider.notifier).submit();
    if (!mounted) return;
    final error = ref.read(registrationNotifierProvider).error;
    if (error == null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationNotifierProvider);

    // Keep page controller in sync when state.step changes externally
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != state.step) {
        _goToPage(state.step);
      }
    });

    return Scaffold(
      backgroundColor: DGTColors.background,
      appBar: AppBar(
        title: Text('Paso ${state.step + 1} de 5'),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
        leading: state.step > 0
            ? BackButton(
                onPressed: () {
                  ref
                      .read(registrationNotifierProvider.notifier)
                      .previousStep();
                },
              )
            : const CloseButton(),
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: state.step),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _NamePage(
                  controller: _nameController,
                  onNext: () {
                    ref
                        .read(registrationNotifierProvider.notifier)
                        .setName(_nameController.text);
                    ref.read(registrationNotifierProvider.notifier).nextStep();
                  },
                ),
                _SurnamePage(
                  controller: _surnameController,
                  onNext: () {
                    ref
                        .read(registrationNotifierProvider.notifier)
                        .setSurname(_surnameController.text);
                    ref.read(registrationNotifierProvider.notifier).nextStep();
                  },
                ),
                _SexPage(
                  onSelect: (sex) {
                    ref.read(registrationNotifierProvider.notifier).setSex(sex);
                    ref.read(registrationNotifierProvider.notifier).nextStep();
                  },
                ),
                _BodySizePage(
                  onSelect: (size) {
                    ref
                        .read(registrationNotifierProvider.notifier)
                        .setBodySize(size);
                    ref.read(registrationNotifierProvider.notifier).nextStep();
                  },
                ),
                _PhotoPage(
                  state: state,
                  onPickPhoto: _pickPhoto,
                  onSubmit: _submit,
                ),
              ],
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                state.error!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: DGTColors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step indicator
// ---------------------------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Row(
        children: List.generate(5, (i) {
          final active = i <= currentStep;
          return Expanded(
            child: Container(
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: active ? DGTColors.primary : DGTColors.textSecondary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 0 — Name
// ---------------------------------------------------------------------------

class _NamePage extends StatelessWidget {
  const _NamePage({required this.controller, required this.onNext});

  final TextEditingController controller;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _InputPage(
      label: 'Nombre',
      hint: 'Introduce tu nombre',
      controller: controller,
      onNext: onNext,
    );
  }
}

// ---------------------------------------------------------------------------
// Page 1 — Surname
// ---------------------------------------------------------------------------

class _SurnamePage extends StatelessWidget {
  const _SurnamePage({required this.controller, required this.onNext});

  final TextEditingController controller;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _InputPage(
      label: 'Apellido',
      hint: 'Introduce tu apellido',
      controller: controller,
      onNext: onNext,
    );
  }
}

class _InputPage extends StatelessWidget {
  const _InputPage({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onNext,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: DGTColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(hintText: hint),
            onSubmitted: (_) => onNext(),
          ),
          const Spacer(),
          MassiveButton(text: 'Siguiente', onPressed: onNext),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 2 — Sex
// ---------------------------------------------------------------------------

class _SexPage extends StatelessWidget {
  const _SexPage({required this.onSelect});

  final void Function(Sex) onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sexo',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: DGTColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: MassiveButton(
                  text: 'Hombre',
                  onPressed: () => onSelect(Sex.male),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MassiveButton(
                  text: 'Mujer',
                  onPressed: () => onSelect(Sex.female),
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 3 — Body Size
// ---------------------------------------------------------------------------

class _BodySizePage extends StatelessWidget {
  const _BodySizePage({required this.onSelect});

  final void Function(BodySize) onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Complexión',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: DGTColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          MassiveButton(
            text: 'Pequeña  < 60 kg',
            onPressed: () => onSelect(BodySize.small),
          ),
          const SizedBox(height: 16),
          MassiveButton(
            text: 'Media  65–75 kg',
            onPressed: () => onSelect(BodySize.medium),
          ),
          const SizedBox(height: 16),
          MassiveButton(
            text: 'Grande  > 80 kg',
            onPressed: () => onSelect(BodySize.large),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 4 — Photo
// ---------------------------------------------------------------------------

class _PhotoPage extends StatelessWidget {
  const _PhotoPage({
    required this.state,
    required this.onPickPhoto,
    required this.onSubmit,
  });

  final RegistrationFormState state;
  final VoidCallback onPickPhoto;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = state.photoPath.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Foto de carnet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: DGTColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (state.bodySize != null) ...[
            const SizedBox(height: 8),
            Text(
              'Tu zona óptima: '
              '${_optimalLabel(state.bodySize!)} mg/L',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: DGTColors.textSecondary),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: onPickPhoto,
            child: CircleAvatar(
              radius: 72,
              backgroundColor: DGTColors.primary.withValues(alpha: 0.1),
              backgroundImage: hasPhoto ? _photoImage(state.photoPath) : null,
              child: hasPhoto
                  ? null
                  : const Icon(
                      Icons.camera_alt,
                      size: 48,
                      color: DGTColors.primary,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onPickPhoto,
            child: Text(
              hasPhoto ? 'Repetir foto' : 'Hacer foto',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: DGTColors.primary),
            ),
          ),
          const Spacer(),
          MassiveButton(
            text: state.isLoading ? 'Guardando…' : 'Confirmar Registro',
            onPressed: state.isLoading ? null : onSubmit,
          ),
        ],
      ),
    );
  }

  ImageProvider _photoImage(String path) => FileImage(File(path));

  String _optimalLabel(BodySize size) {
    switch (size) {
      case BodySize.small:
        return '2.5';
      case BodySize.medium:
        return '2.0';
      case BodySize.large:
        return '1.8';
    }
  }
}
