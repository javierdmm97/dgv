/// Centralized app route constants.
///
/// All features import from here — no per-file private route strings.
class AppRoutes {
  AppRoutes._();

  static const playerRegistration = '/player-registration';
  static const playerSelection = '/player-selection';
  static const game = '/game';
  static const fakeNews = '/fake-news';

  /// Requires `arguments: String playerId`
  static const license = '/license';

  /// Requires `arguments: RoundRobinArgs`
  static const roundRobin = '/round-robin';

  /// Requires `arguments: BACEntryResult` — pushed fullscreenDialog: true
  static const feedback = '/feedback';

  static const leaderboard = '/leaderboard';
}
