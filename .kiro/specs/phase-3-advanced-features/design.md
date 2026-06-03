# Design Document: Phase 3 — Advanced Features

## Overview

Phase 3 completes the Operación DGV game loop. The work spans 12 requirements across five areas: (1) new input methods (OCR camera, keypad confirmation), (2) UI polish (graph zones, last measurement display, siren audio), (3) data model extensions (license back side, curve multiplier, `licenseBackImagePath`), (4) game lifecycle management (recovery, finish game, player edit/delete), and (5) title system finalization.

All code follows the project's architecture rules: Riverpod 2.0+ with `@riverpod` code generation, Hive persistence, Freezed models, feature-first folder structure, `package:` imports only, `const` constructors, no `!` bang operator, minHeight 80 for touch targets.

---

## Architecture Overview

### New files

| File | Purpose |
|------|---------|
| `lib/features/breathalyzer/data/ocr_service.dart` | `OcrService` abstract interface + `MlKitOcrService` impl |
| `lib/features/breathalyzer/presentation/camera_ocr_screen.dart` | Camera viewfinder + OCR UI |
| `lib/features/breathalyzer/presentation/bac_confirmation_screen.dart` | Confirmation step before saving |
| `lib/features/fake_id/presentation/license_viewer_screen.dart` | Full-screen two-sided license PageView |
| `lib/features/main_menu/presentation/settings_screen.dart` | Curve multiplier settings |
| `lib/features/main_menu/presentation/final_ceremony_screen.dart` | Finish game placeholder |
| `lib/data/repositories/curve_settings_repository.dart` | Hive-backed curve multiplier storage |
| `lib/core/providers/recovery_provider.dart` | App launch game state recovery |
| `lib/widgets/last_measurement_widget.dart` | "Último registro" display widget |

### Modified files

| File | Change |
|------|--------|
| `lib/core/models/player_profile.dart` | Add `licenseBackImagePath` field (`@HiveField(13)`) |
| `lib/core/utils/bac_calculator.dart` | Apply `Curve_Multiplier` in `calculateOptimalBrAC()` |
| `lib/core/utils/title_evaluator.dart` | Fix `velocidadDeCrucero` tie-breaking; `multaPorExceso` awards all tied players |
| `lib/features/fake_id/services/license_generator.dart` | Add `generateBack()` method |
| `lib/features/fake_id/services/license_update_service.dart` | Call both `generate()` and `generateBack()` |
| `lib/features/checkpoint/presentation/siren_alert_overlay.dart` | Uncomment `AudioPlayer` call |
| `lib/features/leaderboard/presentation/leaderboard_screen.dart` | Add `LastMeasurementWidget`, title badges, tap-to-license-viewer |
| `lib/features/leaderboard/presentation/player_detail_screen.dart` | Add zone bands to BAC graph |
| `lib/features/main_menu/presentation/main_menu_screen.dart` | Add Finish Game button, Settings icon, player edit/delete |
| `lib/features/player_registration/presentation/player_registration_screen.dart` | Add edit mode |
| `pubspec.yaml` | Register `assets/sound/` |

---

## Component Designs

### Requirement 1 — OCR Camera ("El Radar")

#### `OcrService` interface

```dart
// lib/features/breathalyzer/data/ocr_service.dart
abstract interface class OcrService {
  /// Recognise text in [imageBytes] and return all candidate BrAC values
  /// with their confidence scores. Returns empty list if none found.
  Future<List<OcrCandidate>> recognise(Uint8List imageBytes);
  Future<void> dispose();
}

class OcrCandidate {
  const OcrCandidate({required this.value, required this.confidence});
  final double value;       // parsed BrAC value, e.g. 0.45
  final double confidence;  // 0.0–1.0
}
```

`MlKitOcrService` implements `OcrService` using `google_mlkit_text_recognition`. It filters recognised text blocks with the regex `\d\.\d{2}`, parses each match to `double`, and derives confidence from the ML Kit block confidence score.

#### `CameraOcrScreen`

- Uses `camera` package `CameraController` for live preview.
- Captures a frame every 500 ms and passes it to `OcrService.recognise()`.
- A 10-second `Timer` starts on `initState`; if no valid candidate is found, navigates to `ManualEntryScreen`.
- On confidence > 0.90: auto-navigates to `BacConfirmationScreen`.
- On confidence ≤ 0.90: shows detected value + "Confirmar" / "Reintentar" buttons.
- On camera unavailable/permission denied: shows error dialog with "Entendido" button, then navigates to `ManualEntryScreen`.
- "Entrada manual" `MassiveButton` always visible at bottom.
- Bounding box overlay drawn with `CustomPaint` over the camera preview.

**Testability:** `CameraOcrScreen` accepts an `OcrService` parameter (defaults to `MlKitOcrService`). Tests inject a `FakeOcrService`.

---

### Requirement 2 — Round-Robin Audit

The existing `RoundRobinScreen` already satisfies most requirements:
- ✅ Progress indicator with `LinearProgressIndicator`
- ✅ No auto-advance
- ✅ Skips measured players
- ✅ Round 0 → leaderboard, Round 1+ → pop
- ✅ Fine screen navigation gated on `result.isFined`

**Gap identified:** The `ManualEntryScreen` currently navigates directly to feedback without going through `BacConfirmationScreen`. After adding the confirmation step (Req 5), `RoundRobinScreen._measureCurrent()` will receive the result only after confirmation, so no changes to `RoundRobinScreen` itself are needed beyond ensuring `ManualEntryScreen` routes through `BacConfirmationScreen`.

**Integration test additions:**
- Verify progress reaches `N / N` after all players measured.
- Verify round 0 navigates to leaderboard; round 1 pops.
- Verify fine screen shown only when `isFined == true`.

---

### Requirement 3 — Graph Zone Visualization

The BAC graph lives in `PlayerDetailScreen`. Zone bands are rendered as `fl_chart` `RangeAnnotation` entries (horizontal bands).

#### `ZoneBandData` helper

```dart
class ZoneBandData {
  const ZoneBandData({
    required this.yMin,
    required this.yMax,
    required this.color,
  });
  final double yMin;
  final double yMax;
  final Color color;
}

List<ZoneBandData> buildZoneBands(double optimal, int roundNumber) {
  // Use wider sweet-spot for rounds 1-2 as fallback
  final sweetSpot = (roundNumber <= 2)
      ? AppConstants.zoneClosePct   // 0.20 — wider for early rounds
      : AppConstants.zoneSweetSpotPct; // 0.10 — standard
  final close   = AppConstants.zoneClosePct;
  final neutral = AppConstants.zoneNeutralPct;
  final far     = AppConstants.zoneFarPct;

  return [
    ZoneBandData(yMin: optimal * (1 - sweetSpot), yMax: optimal * (1 + sweetSpot),
        color: DGTColors.green.withValues(alpha: 0.15)),
    ZoneBandData(yMin: optimal * (1 - close), yMax: optimal * (1 - sweetSpot),
        color: DGTColors.yellow.withValues(alpha: 0.15)),
    ZoneBandData(yMin: optimal * (1 + sweetSpot), yMax: optimal * (1 + close),
        color: DGTColors.yellow.withValues(alpha: 0.15)),
    ZoneBandData(yMin: optimal * (1 - neutral), yMax: optimal * (1 - close),
        color: DGTColors.textSecondary.withValues(alpha: 0.10)),
    ZoneBandData(yMin: optimal * (1 + close), yMax: optimal * (1 + neutral),
        color: DGTColors.textSecondary.withValues(alpha: 0.10)),
    ZoneBandData(yMin: optimal * (1 - far), yMax: optimal * (1 - neutral),
        color: DGTColors.orange.withValues(alpha: 0.12)),
    ZoneBandData(yMin: optimal * (1 + neutral), yMax: optimal * (1 + far),
        color: DGTColors.orange.withValues(alpha: 0.12)),
    ZoneBandData(yMin: 0, yMax: optimal * (1 - far),
        color: DGTColors.primary.withValues(alpha: 0.10)),
  ];
}
```

These are converted to `HorizontalRangeAnnotation` entries in the `fl_chart` `LineChartData.rangeAnnotations`. The existing optimal line and BrAC line are drawn on top (higher z-order via `extraLinesData`).

**Single-reading edge case:** When `readings.length == 1`, set `minX = 0`, `maxX = 2` to avoid a degenerate x-range.

---

### Requirement 4 — Last Measurement Widget

```dart
// lib/widgets/last_measurement_widget.dart
class LastMeasurementWidget extends StatelessWidget {
  const LastMeasurementWidget({super.key, required this.player});
  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    final last = player.readings
        .where((r) => r.roundNumber > 0)
        .lastOrNull;
    if (last == null) return const SizedBox.shrink();

    return Text(
      'Último registro: ${last.bac.toStringAsFixed(2)} mg/L — Ronda ${last.roundNumber}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: 16,
        color: DGTColors.textSecondary,
      ),
    );
  }
}
```

Placed inside the existing `LicenseCard` widget, below the points row. Because `LicenseCard` already watches the player via the provider, reactivity is automatic.

---

### Requirement 5 — Keypad Confirmation Step

#### `BacConfirmationScreen`

```dart
// lib/features/breathalyzer/presentation/bac_confirmation_screen.dart
// Route args: BacConfirmationArgs(player, enteredValue)
```

Layout:
- Player name at 24sp bold
- Entered value at 48sp bold (prominent)
- "Confirmar" `MassiveButton` → triggers save, pops with `BACEntryResult`
- "Corregir" `MassiveButton` (secondary style) → pops with `null`, caller re-opens keypad with pre-populated value

`ManualEntryScreen` is updated: instead of saving directly on confirm, it pushes `BacConfirmationScreen`. If `BacConfirmationScreen` returns `null`, the keypad is shown again with the previous value. If it returns a `BACEntryResult`, the flow continues normally.

`CameraOcrScreen` also pushes `BacConfirmationScreen` when confidence ≤ 0.90 or when the operator taps "Confirmar" on the low-confidence overlay.

---

### Requirement 6 — Siren Audio Fix

**`pubspec.yaml`** — add under `flutter.assets`:
```yaml
    - assets/sound/
```

**`SirenAlertOverlay`** — replace the commented block with:
```dart
AudioPlayer? _audioPlayer;

@override
void initState() {
  super.initState();
  _flashTimer = ...;
  _closeTimer = ...;
  _playAudio();
}

Future<void> _playAudio() async {
  try {
    _audioPlayer = AudioPlayer();
    await _audioPlayer!.play(AssetSource('sound/policia_control.mp3'));
  } on Exception {
    // Degrade silently — visual animation continues
  }
}

@override
void dispose() {
  _flashTimer?.cancel();
  _closeTimer?.cancel();
  unawaited(_audioPlayer?.stop());
  _audioPlayer?.dispose();
  super.dispose();
}
```

---

### Requirement 7 — DGT Title System Finalization

#### `velocidadDeCrucero` tie-breaking

Update `_findClosestToOptimal` to sort tied players alphabetically by name:

```dart
// When distance == minDistance, keep the one whose name comes first alphabetically
if (distance < minDistance ||
    (distance == minDistance &&
     player.name.compareTo(closest!.name) < 0)) {
  minDistance = distance;
  closest = player;
}
```

#### `multaPorExceso` — award all tied players

Replace the single-winner logic with a multi-winner approach:

```dart
static void _awardMultaPorExceso(
  Map<String, DGTTitle> awards,
  List<PlayerProfile> players,
  int currentRound,
) {
  if (currentRound <= 1) return;
  double maxSpike = 0.0;
  for (final p in players) {
    final cur = p.latestReadingForRound(currentRound);
    final prev = p.latestReadingForRound(currentRound - 1);
    if (cur == null || prev == null) continue;
    final spike = cur.bac - prev.bac;
    if (spike > maxSpike) maxSpike = spike;
  }
  if (maxSpike <= 0) return;
  for (final p in players) {
    final cur = p.latestReadingForRound(currentRound);
    final prev = p.latestReadingForRound(currentRound - 1);
    if (cur == null || prev == null) continue;
    if ((cur.bac - prev.bac) == maxSpike) {
      awards[p.id] = DGTTitle.multaPorExceso;
    }
  }
}
```

`vehiculoHibrido` remains stubbed (returns empty list) until the team defines the replacement.

---

### Requirement 8 — Two-Sided License Viewing

#### `PlayerProfile` model change

Add to `PlayerProfile` Freezed factory:
```dart
@HiveField(13) @Default(null) String? licenseBackImagePath,
```

Run `dart run build_runner build -d` after this change.

#### `LicenseGenerator.generateBack()`

Same canvas pipeline as `generate()` but uses `AssetPaths.licenseBack` as template and renders:

| Zone | Content | Offset |
|------|---------|--------|
| Header | "HISTORIAL DE MEDICIONES" | (20, 20) |
| Round table | "R1: 0.XX mg/L (+2)" per row | (20, 60 + i*22) |
| Fine log | "Multa N — Ronda N — 100€" | below round table |
| Total money | "Total: X€" | below fine log |
| Perfection | "Precisión: 0.XX" | bottom-right |

File saved as `license_back_{playerId}.png`.

#### `LicenseUpdateService`

```dart
static Future<void> updateForPlayer({
  required PlayerProfile player,
  required PlayerRepository repo,
}) async {
  final frontPath = await LicenseGenerator.generate(player);
  final backPath  = await LicenseGenerator.generateBack(player);
  final updated = player.copyWith(
    licenseImagePath: frontPath,
    licenseBackImagePath: backPath,
  );
  await repo.update(updated);
}
```

#### `LicenseViewerScreen`

```dart
// lib/features/fake_id/presentation/license_viewer_screen.dart
class LicenseViewerScreen extends StatelessWidget {
  const LicenseViewerScreen({super.key, required this.player});
  final PlayerProfile player;
  // PageView with 2 pages, each wrapped in InteractiveViewer(minScale:1, maxScale:4)
  // Page 1: Image.file(player.licenseImagePath) or generated front
  // Page 2: Image.file(player.licenseBackImagePath) or dynamic fallback widget
  // PageController + smooth_page_indicator (or manual dot indicator)
}
```

When `licenseBackImagePath` is null, page 2 renders a `_DynamicBackWidget` that builds the table from `player.readings` directly — no crash.

---

### Requirement 9 — Game State Recovery

#### `RecoveryNotifier`

```dart
// lib/core/providers/recovery_provider.dart
@riverpod
class RecoveryNotifier extends _$RecoveryNotifier {
  @override
  Future<RecoveryRoute> build() async {
    final gameState = await ref.watch(gameStateRepositoryProvider).getCurrent();
    if (gameState == null || gameState.isFinished) {
      return RecoveryRoute.mainMenu;
    }
    // Restore checkpoint timer
    ref.read(checkpointNotifierProvider.notifier).restoreFromState(gameState);
    // Determine screen
    if (gameState.isCheckpointActive) return RecoveryRoute.checkpoint;
    return RecoveryRoute.leaderboard;
  }
}

enum RecoveryRoute { mainMenu, checkpoint, leaderboard }
```

`app.dart` watches `recoveryNotifierProvider` and routes accordingly on first build. Subsequent navigation is handled normally.

`GameStateRepository` already persists to Hive after every state change (existing behaviour). No changes needed there.

---

### Requirement 10 — Player Edit & Delete

#### Delete — `Dismissible` in main menu

Wrap each `LicenseCard` in the "Mis Vehículos" list with `Dismissible`:

```dart
Dismissible(
  key: ValueKey(player.id),
  direction: DismissDirection.endToStart,
  confirmDismiss: (_) => _confirmDelete(context, player),
  onDismissed: (_) => ref.read(playerNotifierProvider.notifier).delete(player.id),
  background: _DeleteBackground(),
  child: LicenseCard(player: player, onTap: ...),
)
```

`_confirmDelete` shows `AlertDialog` with "Eliminar" / "Cancelar". Returns `bool`.

Both swipe-to-delete and the edit button are hidden (or disabled) when `gameState?.isInProgress == true`.

#### Edit — `PlayerRegistrationScreen` in edit mode

Add optional `PlayerProfile? editingPlayer` parameter to `PlayerRegistrationScreen`. When non-null:
- Pre-populate all form fields
- Change title to "Editar Conductor"
- On save: call `playerRepository.update()` + `LicenseGenerator.generate()` + `LicenseUpdateService`

---

### Requirement 11 — Finish Game Button

#### `FinishGameButton` widget

Shown on `MainMenuScreen` when `gameState?.isInProgress == true`. Enabled only when `gameState.currentRound >= 5` and all players in the current round have been measured.

```dart
MassiveButton(
  text: 'Finalizar Partida',
  icon: Icons.flag,
  isEnabled: canFinish,
  onPressed: canFinish ? _confirmFinish : null,
)
```

`_confirmFinish` shows `AlertDialog` with "Finalizar" / "Cancelar". On confirm: `Navigator.pushNamed(context, AppRoutes.finalCeremony)`.

#### `FinalCeremonyScreen`

```dart
// lib/features/main_menu/presentation/final_ceremony_screen.dart
// Placeholder — Phase 5 will implement the full ceremony
Scaffold(
  body: Center(child: Text('Ceremonia Final — Próximamente')),
  bottomNavigationBar: MassiveButton(
    text: 'Volver al Menú',
    onPressed: _returnToMenu,
  ),
)

Future<void> _returnToMenu() async {
  await ref.read(gameStateRepositoryProvider).clear();
  if (mounted) Navigator.pushNamedAndRemoveUntil(
    context, AppRoutes.mainMenu, (_) => false,
  );
}
```

---

### Requirement 12 — BAC Curve Calibration

#### `CurveSettingsRepository`

```dart
// lib/data/repositories/curve_settings_repository.dart
abstract interface class CurveSettingsRepository {
  Future<double> getMultiplier();
  Future<void> saveMultiplier(double value);
}

class HiveCurveSettingsRepository implements CurveSettingsRepository {
  static const _key = 'curve_multiplier';
  static const _default = 1.00;

  @override
  Future<double> getMultiplier() async {
    final box = HiveService.getSettingsBox();
    return (box.get(_key) as double?) ?? _default;
  }

  @override
  Future<void> saveMultiplier(double value) async {
    final box = HiveService.getSettingsBox();
    await box.put(_key, value);
  }
}
```

#### `BACCalculator` — apply multiplier

```dart
static double calculateOptimalBrAC(
  int roundNumber,
  Sex sex,
  BodySize bodySize, {
  double curveMultiplier = 1.0,
}) {
  if (roundNumber <= 0) return 0.0;
  final targets = _partyModeTargets[sex]![bodySize]!;
  final raw = roundNumber <= targets.length
      ? targets[roundNumber - 1]
      : targets[9];
  return raw * curveMultiplier;
}
```

A `@riverpod curveMultiplierProvider` reads from `HiveCurveSettingsRepository` and is watched by all callers of `calculateOptimalBrAC`.

#### `SettingsScreen`

```dart
// lib/features/main_menu/presentation/settings_screen.dart
// Slider: min=0.80, max=1.20, divisions=8, value=_multiplier
// Label: 'Curva: ${_multiplier.toStringAsFixed(2)}× — ${_label}'
// Warning text shown when multiplier != 1.00
// Disabled + message when currentRound >= 1
// Save button persists via CurveSettingsRepository
```

---

## Data Model Changes

### `PlayerProfile` — new field

```dart
@HiveField(13) @Default(null) String? licenseBackImagePath,
```

**Migration:** Existing Hive boxes will have no value for field 13; Freezed's `@Default(null)` handles this gracefully — no migration script needed.

After adding the field: `dart run build_runner build -d`

---

## Correctness Properties

| Property | Requirement | Description |
|----------|-------------|-------------|
| **P1** | Req 12 | `calculateOptimalBrAC(r, s, b, multiplier: m) == rawTarget(r,s,b) × m` for all m ∈ [0.80, 1.20] |
| **P2** | Req 12 | Round-trip: `saveMultiplier(v)` then `getMultiplier()` returns `v` for all v ∈ {0.80, 0.85, …, 1.20} |
| **P3** | Req 7 | `velocidadDeCrucero` winner always has `|bac - optimal| ≤ |bac - optimal|` for every other player |
| **P4** | Req 7 | `multaPorExceso` never awarded in round 1 |
| **P5** | Req 3 | Zone band boundaries are non-overlapping and cover [0, ∞) for any positive optimal value |
| **P6** | Req 9 | Recovery with pre-seeded Hive always routes to the same screen regardless of launch order |

---

## Testing Strategy

### Unit tests

| File | Tests |
|------|-------|
| `test/unit/core/utils/bac_calculator_test.dart` | P1: multiplier applied; edge cases (round 0, round 11+) |
| `test/unit/data/repositories/curve_settings_repository_test.dart` | P2: round-trip; default value when empty |
| `test/unit/core/utils/title_evaluator_test.dart` | P3, P4: all 5 evaluators; tie-breaking; multaPorExceso not in round 1 |
| `test/unit/features/breathalyzer/ocr_service_test.dart` | Pattern matching; confidence selection; multi-candidate |

### Widget tests

| File | Tests |
|------|-------|
| `test/widget/features/breathalyzer/bac_confirmation_screen_test.dart` | Confirmar saves; Corregir returns null; value displayed at 24sp+ |
| `test/widget/features/fake_id/license_viewer_screen_test.dart` | Two pages; page indicator; null back path fallback |
| `test/widget/features/main_menu/settings_screen_test.dart` | Slider range; label text; disabled during active game |
| `test/widget/widgets/last_measurement_widget_test.dart` | Correct text format; hidden when no readings |

### Integration tests

| File | Tests |
|------|-------|
| `test/integration/recovery_provider_test.dart` | Pre-seeded Hive → correct route; empty Hive → main menu |
| `test/integration/round_robin_screen_test.dart` | Progress reaches N/N; fine screen shown only when fined; round 0 → leaderboard |
