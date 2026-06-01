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

  /// Requires `arguments: BACEntryResult` — shown before feedback when fined
  static const fine = '/fine';

  static const leaderboard = '/leaderboard';

  static const ayuda = '/ayuda';

  /// Requires `arguments: PlayerProfile` — full-screen two-sided license viewer
  static const licenseViewer = '/license-viewer';

  /// Optional `arguments: PlayerProfile` — edit an existing player
  static const playerEdit = '/player-edit';

  /// Final ceremony screen — end of game
  static const finalCeremony = '/final-ceremony';

  /// Settings screen — BAC curve calibration
  static const settings = '/settings';

  /// Vehicle list screen — browse all registered players (2 per row)
  static const vehicleList = '/vehicle-list';
}
