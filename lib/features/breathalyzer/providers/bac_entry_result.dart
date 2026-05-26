import 'package:flutter/material.dart';

import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/models/player_profile.dart';

/// Result returned by [BACEntryNotifier.submitBAC].
/// Passed as route argument to [FeedbackScreen] (and [FineScreen] when fined).
class BACEntryResult {
  const BACEntryResult({
    required this.playerId,
    required this.playerName,
    required this.bac,
    required this.roundNumber,
    required this.pointsChange,
    required this.feedbackMessage,
    required this.feedbackColor,
    this.awardedTitle,
    this.fineCount = 0,
    this.moneyLost = 0,
  });

  final String playerId;
  final String playerName;
  final double bac;
  final int roundNumber;
  final int pointsChange;
  final String feedbackMessage;
  final Color feedbackColor;
  final DGTTitle? awardedTitle;

  /// Number of fines the player has accumulated (shown on fine screen).
  final int fineCount;

  /// Total money lost to fines (100 per fine).
  final int moneyLost;

  bool get isBaselineRound => roundNumber == 0;

  /// True when this measurement triggered a fine (-4 points).
  bool get isFined => pointsChange <= -4;
}

/// Arguments passed when pushing the round-robin route.
class RoundRobinArgs {
  const RoundRobinArgs({required this.players, required this.round});

  final List<PlayerProfile> players;
  final int round;
}
