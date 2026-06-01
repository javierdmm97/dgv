# Recovered Code Review Tracker

Source of truth: `D:\Descargas\dgv_0.1.0\assets\flutter_assets\recovered_code_tree`

This APK was compiled, installed and manually tested on a real device — no bugs.
Goal: find every difference between current codebase and this recovered tree.

Legend:
- ✅ Reviewed — identical to current
- 🔧 Reviewed — DIFF FOUND & FIXED
- ⚠️ Reviewed — DIFF FOUND, not yet applied
- 🔲 Not yet reviewed
- ➖ Skip (Flutter framework / 3rd party / generated)
- ❓ No individual recovered file — not comparable

---

## Tier 1 — Game Logic & Navigation

| Recovered File | Current Path | Status |
|---|---|---|
| BACEntryNotifier.dart | lib/features/breathalyzer/providers/bac_entry_provider.dart | ✅ identical |
| BACEntryResult.dart | lib/features/breathalyzer/providers/bac_entry_result.dart | ✅ identical |
| BACReading.dart | lib/core/models/bac_reading.dart | ✅ identical |
| BacConfirmationArgs.dart | lib/features/breathalyzer/presentation/bac_confirmation_screen.dart | ✅ identical |
| CheckpointCalculator.dart | lib/core/utils/checkpoint_calculator.dart | ✅ identical |
| CheckpointNotifier.dart | lib/core/providers/checkpoint_providers.dart | ✅ identical |
| CheckpointRepositoryImpl.dart | lib/data/repositories/checkpoint_repository_impl.dart | ✅ identical |
| CheckpointScreen.dart | lib/features/checkpoint/presentation/checkpoint_screen.dart | ✅ identical |
| DGVApp.dart | lib/app.dart | ✅ identical |
| FeedbackScreen.dart | lib/features/breathalyzer/presentation/feedback_screen.dart | ✅ identical |
| FineScreen.dart | lib/features/scoring/presentation/fine_screen.dart | ✅ identical |
| GameState.dart | lib/core/models/game_state.dart | ✅ identical |
| GameStateNotifier.dart | lib/core/providers/game_state_providers.dart | ✅ identical |
| GameStateRepositoryImpl.dart | lib/data/repositories/game_state_repository_impl.dart | ✅ identical |
| GroupCheckpoint.dart | lib/core/models/checkpoint_state.dart | ✅ identical |
| GroupCountdownCard.dart | lib/features/checkpoint/presentation/group_countdown_card.dart | ✅ identical |
| ManualEntryScreen.dart | lib/features/breathalyzer/presentation/manual_entry_screen.dart | ✅ identical |
| PlayerListNotifier.dart | lib/core/providers/player_providers.dart | ✅ identical |
| PlayerProfile.dart | lib/core/models/player_profile.dart | ✅ identical |
| PlayerRepositoryImpl.dart | lib/data/repositories/player_repository_impl.dart | ✅ identical |
| PointsCalculator.dart | lib/core/utils/points_calculator.dart | ✅ identical |
| RecoveryNotifier.dart | lib/core/providers/recovery_provider.dart | ✅ identical |
| RegistrationFormState.dart | lib/features/player_registration/providers/registration_provider.dart | ✅ identical |
| RoundCompletionService.dart | lib/features/breathalyzer/providers/round_completion_service.dart | 🔧 missing LicenseUpdateService call |
| TitleEvaluator.dart | lib/core/utils/title_evaluator.dart | ✅ identical |

---

## Tier 2 — Providers & UI Screens

| Recovered File | Current Path | Status |
|---|---|---|
| AyudaScreen.dart | lib/features/main_menu/presentation/ayuda_screen.dart | ✅ identical |
| CustomKeypad.dart | lib/widgets/custom_keypad.dart | ✅ identical |
| FakeErrorNotification.dart | lib/features/main_menu/presentation/widgets/fake_error_notification.dart | ✅ identical |
| FakeNewsDetailScreen.dart | lib/features/main_menu/presentation/fake_news_detail_screen.dart | ✅ identical |
| FakeNewsScreen.dart | lib/features/main_menu/presentation/fake_news_screen.dart | ✅ identical |
| FakeNewsSection.dart | lib/features/main_menu/presentation/widgets/fake_news_section.dart | ✅ identical |
| HiveService.dart | lib/core/storage/hive_service.dart | ✅ identical |
| LastMeasurementWidget.dart | lib/widgets/last_measurement_widget.dart | ✅ identical |
| LeaderboardScreen.dart | lib/features/leaderboard/presentation/leaderboard_screen.dart | ✅ identical |
| LicenseCard.dart | lib/widgets/license_card.dart | ✅ identical |
| LicenseExportService.dart | lib/features/fake_id/services/license_export_service.dart | ✅ identical |
| LicenseUpdateService.dart | lib/features/fake_id/services/license_update_service.dart | ✅ identical |
| LicenseViewerScreen.dart | lib/features/fake_id/presentation/license_viewer_screen.dart | ✅ identical |
| MainMenuState.dart | lib/features/main_menu/providers/main_menu_provider.dart | 🔧 SharedPrefs persistence, reset fix |
| MassiveButton.dart | lib/widgets/massive_button.dart | ✅ identical |
| NotificationService.dart | lib/core/services/notification_service.dart | ✅ identical |
| PlayerRegistrationScreen.dart | lib/features/player_registration/presentation/player_registration_screen.dart | ✅ identical |
| PlayerSelectionScreen.dart | lib/features/player_registration/presentation/player_selection_screen.dart | ✅ identical |
| SettingsScreen.dart | lib/features/main_menu/presentation/settings_screen.dart | ✅ identical |
| SplashScreen.dart | lib/features/main_menu/presentation/splash_screen.dart | ✅ identical |
| TitleBadge.dart | lib/widgets/title_badge.dart | ✅ identical |
| VehicleListScreen.dart | lib/features/main_menu/presentation/vehicle_list_screen.dart | ✅ identical |

---

## Tier 3 — Models, Theme, Constants

| Recovered File | Current Path | Status |
|---|---|---|
| AppConstants.dart | lib/core/constants/app_constants.dart | ✅ identical |
| AppRoutes.dart | lib/core/constants/route_constants.dart | ✅ identical |
| AssetPaths.dart | lib/core/constants/asset_paths.dart | ✅ identical |
| BACCalculator.dart | lib/core/utils/bac_calculator.dart | ✅ identical |
| CheckpointRepository.dart | lib/data/repositories/checkpoint_repository.dart | ✅ identical |
| DGTColors.dart | lib/core/theme/dgt_colors.dart | ✅ identical |
| DGTTheme.dart | lib/core/theme/dgt_theme.dart | ✅ identical |
| DGTTypography.dart | lib/core/theme/dgt_typography.dart | ✅ identical |
| FakeNewsArticle.dart | lib/core/constants/dgt_strings.dart | ✅ identical |
| GameStateRepository.dart | lib/data/repositories/game_state_repository.dart | ✅ identical |
| HiveVisualStyleRepository.dart | lib/data/repositories/hive_visual_style_repository.dart | ✅ identical |
| PlayerRepository.dart | lib/data/repositories/player_repository.dart | ✅ identical |
| VisualStyleRepository.dart | lib/data/repositories/visual_style_repository.dart | ✅ identical |
| VisualStyleSettings.dart | lib/core/models/visual_style_settings.dart | ✅ identical |

---

## Tier 4 — Logic Blobs & Generated

| Recovered File | Maps To | Status |
|---|---|---|
| recovered_logic_block_1753.dart | lib/core/models/dgt_title.dart | ✅ identical |
| recovered_logic_block_1765.dart | lib/core/providers/repository_providers.dart | ✅ identical |
| recovered_logic_block_1798.dart | lib/features/leaderboard/providers/leaderboard_provider.dart | 🔧 DIFF FOUND & FIXED |
| recovered_logic_block_1817.dart | lib/main.dart | ✅ identical |
| using.dart | All project files referenced — no extra source found | ✅ scanned |
| _SystemHash.dart | Generated Riverpod hashes | ➖ skip |

---

## Files With NO Recovered Counterpart (not comparable)

These exist in the current project but were NOT individually extracted to the recovered tree.
Their source was compiled into the APK but can only be verified by reading current code manually.

| Current Path | Notes |
|---|---|
| lib/features/main_menu/providers/ceremony_provider.dart | Referenced in using.dart — looks correct |
| lib/core/providers/visual_style_provider.dart | Referenced in using.dart — looks correct |
| lib/features/main_menu/presentation/final_ceremony_screen.dart | Referenced in using.dart — unverified |
| lib/features/leaderboard/presentation/player_detail_screen.dart | Referenced in using.dart — unverified |
| lib/features/fake_id/services/license_generator.dart | Referenced in using.dart — unverified |

---

## Confirmed Fixes Applied

1. **leaderboard_provider.dart** — filter by `gameState.playerIds` when game in progress (Bug 1)
2. **round_completion_service.dart** — add `LicenseUpdateService.updateForPlayer` after title awards
3. **main_menu_provider.dart** — SharedPreferences persistence for fake error, `licenseBackImagePath` in reset, `ref.invalidate(playerListNotifierProvider)` in resetGame

---

## Result for "Confirmar grupo medido" Bug

**Every file in the navigation chain is identical to the working APK.**
The bug is NOT caused by missing/changed source code in any recoverable file.

The 5 unverified files above (no recovered counterpart) are the only remaining candidates.
Most likely suspect: `final_ceremony_screen.dart` or `player_detail_screen.dart` are unrelated.
`license_generator.dart` also unrelated to navigation.

The bug may be a **runtime/state interaction** not visible in source comparison alone.
