import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/constants/dgt_strings.dart';
import 'package:dgv/core/constants/route_constants.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/recovery_provider.dart';
import 'package:dgv/core/theme/dgt_theme.dart';
import 'package:dgv/features/breathalyzer/presentation/feedback_screen.dart';
import 'package:dgv/features/breathalyzer/presentation/round_robin_screen.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';
import 'package:dgv/features/checkpoint/presentation/checkpoint_screen.dart';
import 'package:dgv/features/fake_id/presentation/license_viewer_screen.dart';
import 'package:dgv/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:dgv/features/leaderboard/presentation/player_detail_screen.dart';
import 'package:dgv/features/main_menu/presentation/ayuda_screen.dart';
import 'package:dgv/features/main_menu/presentation/fake_news_screen.dart';
import 'package:dgv/features/main_menu/presentation/final_ceremony_screen.dart';
import 'package:dgv/features/main_menu/presentation/main_menu_screen.dart';
import 'package:dgv/features/main_menu/presentation/settings_screen.dart';
import 'package:dgv/features/main_menu/presentation/splash_screen.dart';
import 'package:dgv/features/main_menu/presentation/vehicle_list_screen.dart';
import 'package:dgv/features/player_registration/presentation/player_registration_screen.dart';
import 'package:dgv/features/player_registration/presentation/player_selection_screen.dart';
import 'package:dgv/features/scoring/presentation/fine_screen.dart';

/// Main app widget.
class DGVApp extends ConsumerWidget {
  const DGVApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: DGTStrings.appName,
      theme: DGTTheme.lightTheme,
      darkTheme: DGTTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      onGenerateRoute: _generateRoute,
    );
  }

  static Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute<void>(
          builder: (_) => const _RecoveryGate(),
          settings: settings,
        );

      case AppRoutes.playerRegistration:
        return MaterialPageRoute<void>(
          builder: (_) => const PlayerRegistrationScreen(),
          settings: settings,
        );

      case AppRoutes.playerEdit:
        final editingPlayer = settings.arguments as PlayerProfile;
        return MaterialPageRoute<void>(
          builder: (_) =>
              PlayerRegistrationScreen(editingPlayer: editingPlayer),
          settings: settings,
        );

      case AppRoutes.playerSelection:
        return MaterialPageRoute<void>(
          builder: (_) => const PlayerSelectionScreen(),
          settings: settings,
        );

      case AppRoutes.game:
        return MaterialPageRoute<void>(
          builder: (_) => const CheckpointScreen(),
          settings: settings,
        );

      case AppRoutes.fakeNews:
        return MaterialPageRoute<void>(
          builder: (_) => const FakeNewsScreen(),
          settings: settings,
        );

      case AppRoutes.license:
        final playerId = settings.arguments as String;
        return MaterialPageRoute<void>(
          builder: (_) => PlayerDetailScreen(playerId: playerId),
          settings: settings,
        );

      case AppRoutes.roundRobin:
        final args = settings.arguments as RoundRobinArgs;
        return MaterialPageRoute<void>(
          builder: (_) => RoundRobinScreen(args: args),
          settings: settings,
        );

      case AppRoutes.feedback:
        final result = settings.arguments as BACEntryResult;
        return MaterialPageRoute<void>(
          builder: (_) => FeedbackScreen(result: result),
          fullscreenDialog: true,
          settings: settings,
        );

      case AppRoutes.leaderboard:
        return MaterialPageRoute<void>(
          builder: (_) => const LeaderboardScreen(),
          settings: settings,
        );

      case AppRoutes.fine:
        final result = settings.arguments as BACEntryResult;
        return MaterialPageRoute<void>(
          builder: (_) => FineScreen(result: result),
          fullscreenDialog: true,
          settings: settings,
        );

      case AppRoutes.ayuda:
        return MaterialPageRoute<void>(
          builder: (_) => const AyudaScreen(),
          settings: settings,
        );

      case AppRoutes.finalCeremony:
        return MaterialPageRoute<void>(
          builder: (_) => const FinalCeremonyScreen(),
          settings: settings,
        );

      case AppRoutes.settings:
        return MaterialPageRoute<void>(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      case AppRoutes.vehicleList:
        return MaterialPageRoute<void>(
          builder: (_) => const VehicleListScreen(),
          settings: settings,
        );

      case AppRoutes.licenseViewer:
        final player = settings.arguments as PlayerProfile;
        return MaterialPageRoute<void>(
          builder: (_) => LicenseViewerScreen(player: player),
          settings: settings,
        );

      default:
        return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Recovery gate — routes to the correct screen on first launch
// ---------------------------------------------------------------------------

/// Reads [recoveryNotifierProvider] on first build and navigates to the
/// appropriate screen. Shows a loading indicator while the provider resolves.
class _RecoveryGate extends ConsumerWidget {
  const _RecoveryGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recovery = ref.watch(recoveryNotifierProvider);

    return recovery.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => const MainMenuScreen(),
      data: (route) {
        // Navigate once on first data emission.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          switch (route) {
            case RecoveryRoute.checkpoint:
              Navigator.pushReplacementNamed(context, AppRoutes.game);
            case RecoveryRoute.leaderboard:
              Navigator.pushReplacementNamed(context, AppRoutes.leaderboard);
            case RecoveryRoute.mainMenu:
              break; // Already on main menu — no navigation needed.
          }
        });
        return const MainMenuScreen();
      },
    );
  }
}
