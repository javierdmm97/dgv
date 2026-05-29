import 'package:flutter/material.dart' show Color;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import 'package:dgv/core/models/bac_reading.dart';
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
/// Round 0: records baseline with no points change.
/// Round 1+: calculates points, checks fine condition, updates Hive.
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
        feedbackMessage: 'Lectura registrada',
        feedbackColor: DGTColors.background,
      );
    }

    // -----------------------------------------------------------------------
    // Round 1+ — full scoring
    // -----------------------------------------------------------------------
    final curveMultiplier = await ref.read(curveMultiplierProvider.future);
    final optimal = BACCalculator.calculateOptimalBrAC(
      currentRound,
      player.sex,
      player.bodySize,
      curveMultiplier: curveMultiplier,
    );

    final pointsChange = PointsCalculator.calculatePointsChange(
      currentBAC: bac,
      optimalBAC: optimal,
      roundNumber: currentRound,
    );

    bool crossedLine = player.crossedOptimalLine;
    if (BACCalculator.crossedOptimalLine(
      bac,
      optimal,
      roundNumber: currentRound,
    )) {
      crossedLine = true;
    }

    final issueFine = PointsCalculator.shouldIssueFine(pointsChange);
    final newFineCount = player.fineCount + (issueFine ? 1 : 0);
    final newMoneyLost = player.moneyLost + (issueFine ? 100 : 0);

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
      crossedOptimalLine: crossedLine,
      fineCount: newFineCount,
      moneyLost: newMoneyLost,
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
      feedbackMessage: feedbackMsg,
      feedbackColor: feedbackColor,
      fineCount: newFineCount,
      moneyLost: newMoneyLost,
    );
  }
}

Color _colorFromEnum(FeedbackColor c) {
  switch (c) {
    case FeedbackColor.green:
      return DGTColors.green;
    case FeedbackColor.yellow:
      return DGTColors.yellow;
    case FeedbackColor.orange:
      return DGTColors.orange;
    case FeedbackColor.red:
      return DGTColors.red;
    case FeedbackColor.blue:
      return DGTColors.primary;
    case FeedbackColor.neutral:
      return DGTColors.background;
  }
}
