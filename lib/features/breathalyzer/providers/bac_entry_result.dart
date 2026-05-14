import 'package:flutter/material.dart';

import 'package:dgv/core/models/dgt_title.dart';
import 'package:dgv/core/models/player_profile.dart';

/// Result returned by [BACEntryNotifier.submitBAC].
/// Passed as route argument to [FeedbackScreen].
class BACEntryResult {
  const BACEntryResult({
    required this.playerId,
    required this.playerName,
    required this.bac,
    required this.roundNumber,
    required this.pointsChange,
    required this.isImpounded,
    required this.feedbackMessage,
    required this.feedbackColor,
    this.awardedTitle,
  });

  final String playerId;
  final String playerName;
  final double bac;
  final int roundNumber;
  final int pointsChange;
  final bool isImpounded;
  final String feedbackMessage;
  final Color feedbackColor;
  final DGTTitle? awardedTitle;

  bool get isBaselineRound => roundNumber == 0;
}

/// Arguments passed when pushing the round-robin route.
class RoundRobinArgs {
  const RoundRobinArgs({required this.players, required this.round});

  final List<PlayerProfile> players;
  final int round;
}
