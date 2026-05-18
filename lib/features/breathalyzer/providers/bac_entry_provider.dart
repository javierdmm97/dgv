import 'package:flutter/material.dart' show Color;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import 'package:dgv/core/constants/app_constants.dart';
import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/checkpoint_providers.dart';
import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/providers/repository_providers.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/core/utils/bac_calculator.dart';
import 'package:dgv/core/utils/points_calculator.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';

part 'bac_entry_provider.g.dart';

/// Processes a single BAC entry for a player.
///
/// For Round 0: records baseline with no points change.
/// For Round 1+: calculates points, checks impoundment, updates Hive.
@riverpod
class BACEntryNotifier extends _$BACEntryNotifier {
  @override
  void build() {}

  Future<BACEntryResult> submitBAC(String playerId, double bac) async {
    final repo = ref.read(playerRepositoryProvider);
    final player = await repo.getById(playerId);
    if (player == null) {
      throw StateError('Player $playerId not found');
    }

    final gameState = await ref.read(currentGameStateProvider.future);
    final currentRound = gameState?.currentRound ?? 0;
    final now = DateTime.now();

    // -----------------------------------------------------------------------
    // Round 0 — baseline, no feedback, no points
    // -----------------------------------------------------------------------
    if (currentRound == 0) {
      final reading = BACReading(
        id: const Uuid().v4(),
        playerId: playerId,
        bac: bac,
        timestamp: now,
        roundNumber: 0,
        entryMethod: BACEntryMethod.manual,
        pointsChange: 0,
      );
      final updated = player.copyWith(readings: [...player.readings, reading]);
      await repo.update(updated);
      ref.invalidate(playerListNotifierProvider);

      return BACEntryResult(
        playerId: playerId,
        playerName: '${player.name} ${player.surname}',
        bac: bac,
        roundNumber: 0,
        pointsChange: 0,
        isImpounded: false,
        feedbackMessage: 'Lectura registrada',
        feedbackColor: DGTColors.background,
      );
    }

    // -----------------------------------------------------------------------
    // Round 1+ — full scoring
    // -----------------------------------------------------------------------
    final previousReading = player.latestReadingForRound(currentRound - 1);
    final previousBAC = previousReading?.bac ?? 0.0;
    final timeDelta = previousReading != null
        ? now.difference(previousReading.timestamp)
        : const Duration(minutes: AppConstants.defaultIntervalMinutes);

    // Impoundment takes priority
    final impounded = PointsCalculator.isImpounded(bac);
    int pointsChange;
    bool crossedLine = player.crossedOptimalLine;

    if (impounded) {
      pointsChange = PointsCalculator.getImpoundmentPenalty();
    } else {
      pointsChange = PointsCalculator.calculatePointsChange(
        currentBAC: bac,
        optimalBAC: player.optimalBAC,
        previousBAC: previousBAC,
        timeDelta: timeDelta,
      );
      if (BACCalculator.crossedOptimalLine(bac, player.optimalBAC)) {
        crossedLine = true;
      }
    }

    final newPoints = PointsCalculator.calculateTotalPoints(
      player.points,
      pointsChange,
    );
    final feedbackMsg = PointsCalculator.getFeedbackMessage(pointsChange);
    final feedbackColorEnum = PointsCalculator.getFeedbackColor(pointsChange);
    final feedbackColor = _colorFromEnum(feedbackColorEnum);

    final reading = BACReading(
      id: const Uuid().v4(),
      playerId: playerId,
      bac: bac,
      timestamp: now,
      roundNumber: currentRound,
      entryMethod: BACEntryMethod.manual,
      pointsChange: pointsChange,
    );

    final updatedPlayer = player.copyWith(
      points: newPoints,
      readings: [...player.readings, reading],
      isImpounded: impounded,
      crossedOptimalLine: crossedLine,
    );

    await repo.update(updatedPlayer);
    ref.invalidate(playerListNotifierProvider);

    // Notify checkpoint that this player has been measured
    await ref
        .read(checkpointNotifierProvider.notifier)
        .recordPlayerMeasurement(playerId);

    return BACEntryResult(
      playerId: playerId,
      playerName: '${player.name} ${player.surname}',
      bac: bac,
      roundNumber: currentRound,
      pointsChange: pointsChange,
      isImpounded: impounded,
      feedbackMessage: feedbackMsg,
      feedbackColor: feedbackColor,
    );
  }
}

// Maps the FeedbackColor enum to an actual Flutter Color.
Color _colorFromEnum(FeedbackColor c) {
  switch (c) {
    case FeedbackColor.green:
      return DGTColors.green;
    case FeedbackColor.yellow:
      return DGTColors.yellow;
    case FeedbackColor.red:
      return DGTColors.red;
    case FeedbackColor.neutral:
      return DGTColors.background;
  }
}
