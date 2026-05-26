import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgv/core/constants/dgt_strings.dart';
import 'package:dgv/core/constants/route_constants.dart';
import 'package:dgv/core/theme/dgt_theme.dart';
import 'package:dgv/features/main_menu/presentation/fake_news_screen.dart';
import 'package:dgv/features/main_menu/presentation/main_menu_screen.dart';
import 'package:dgv/features/player_registration/presentation/player_registration_screen.dart';
import 'package:dgv/features/player_registration/presentation/player_selection_screen.dart';
import 'package:dgv/features/breathalyzer/presentation/round_robin_screen.dart';
import 'package:dgv/features/breathalyzer/presentation/feedback_screen.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';
import 'package:dgv/features/checkpoint/presentation/checkpoint_screen.dart';
import 'package:dgv/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:dgv/features/leaderboard/presentation/player_detail_screen.dart';
import 'package:dgv/features/main_menu/presentation/ayuda_screen.dart';
import 'package:dgv/features/scoring/presentation/fine_screen.dart';

/// Main app widget
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
      home: const MainMenuScreen(),
      onGenerateRoute: _generateRoute,
    );
  }

  static Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.playerRegistration:
        return MaterialPageRoute<void>(
          builder: (_) => const PlayerRegistrationScreen(),
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

      default:
        return null;
    }
  }
}
