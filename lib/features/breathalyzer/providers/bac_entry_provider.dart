import 'dart:async';

import 'package:flutter/material.dart' show Color;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:dgv/features/firebase/providers/firebase_providers.dart';

import 'package:dgv/core/constants/app_constants.dart';
import 'package:dgv/core/models/bac_reading.dart';
import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/providers/checkpoint_providers.dart';
import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/providers/repository_providers.dart'
    show playerRepositoryProvider;
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/core/utils/bac_calculator.dart';
import 'package:dgv/core/utils/points_calculator.dart';
import 'package:dgv/features/breathalyzer/providers/bac_entry_result.dart';
import 'package:dgv/features/fake_id/services/license_update_service.dart';

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
    final preGameBeers = gameState?.preGameBeers ?? 0.0;
    final optimal =
        BACCalculator.calculateOptimalBrAC(
          currentRound,
          player.sex,
          player.bodySize,
        ) +
        BACCalculator.preGameBacOffset(
          preGameBeers,
          player.sex,
          player.bodySize,
        );

    // Non-drinkers (BAC ≤ soberThreshold) keep their points — no deduction, no
    // fine. Their perfection score naturally suffers from being far below optimal.
    final isSober = bac <= AppConstants.soberThreshold;

    final rawPointsChange = PointsCalculator.calculatePointsChange(
      currentBAC: bac,
      optimalBAC: optimal,
      roundNumber: currentRound,
    );
    final pointsChange = isSober ? 0 : rawPointsChange;

    bool crossedLine = player.crossedOptimalLine;
    if (!isSober &&
        BACCalculator.crossedOptimalLine(
          bac,
          optimal,
          roundNumber: currentRound,
        )) {
      crossedLine = true;
    }

    final issueFine =
        !isSober && PointsCalculator.shouldIssueFine(rawPointsChange);
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
      optimalBAC: optimal,
    );

    final updatedPlayer = player.copyWith(
      points: newPoints,
      readings: [...player.readings, reading],
      crossedOptimalLine: crossedLine,
      fineCount: newFineCount,
      moneyLost: newMoneyLost,
    );

    await repo.update(updatedPlayer);
    unawaited(
      ref.read(firebaseSyncServiceProvider).syncPlayerUpdate(updatedPlayer),
    );
    await LicenseUpdateService.updateForPlayer(
      player: updatedPlayer,
      repo: repo,
    );
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

  /// Calculate what would happen if [bac] were submitted for [playerId] now,
  /// without writing anything to Hive or notifying the checkpoint.
  ///
  /// Used by the staged Retén flow so players can preview their +/- and fine
  /// before the whole group is confirmed.
  Future<BACEntryResult> calculatePreview(String playerId, double bac) async {
    final repo = ref.read(playerRepositoryProvider);
    final player = await repo.getById(playerId);
    if (player == null) throw StateError('Player $playerId not found');

    final gameState = await ref.read(currentGameStateProvider.future);
    final currentRound = gameState?.currentRound ?? 0;

    if (currentRound == 0) {
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

    final preGameBeers = gameState?.preGameBeers ?? 0.0;
    final optimal =
        BACCalculator.calculateOptimalBrAC(
          currentRound,
          player.sex,
          player.bodySize,
        ) +
        BACCalculator.preGameBacOffset(
          preGameBeers,
          player.sex,
          player.bodySize,
        );

    final isSober = bac <= AppConstants.soberThreshold;
    final rawPointsChange = PointsCalculator.calculatePointsChange(
      currentBAC: bac,
      optimalBAC: optimal,
      roundNumber: currentRound,
    );
    final pointsChange = isSober ? 0 : rawPointsChange;
    final issueFine =
        !isSober && PointsCalculator.shouldIssueFine(rawPointsChange);

    final feedbackMsg = PointsCalculator.getFeedbackMessage(pointsChange);
    final feedbackColorEnum = PointsCalculator.getFeedbackColor(pointsChange);
    final feedbackColor = _colorFromEnum(feedbackColorEnum);

    return BACEntryResult(
      playerId: playerId,
      playerName: '${player.name} ${player.surname}',
      bac: bac,
      roundNumber: currentRound,
      pointsChange: pointsChange,
      feedbackMessage: feedbackMsg,
      feedbackColor: feedbackColor,
      fineCount: player.fineCount + (issueFine ? 1 : 0),
      moneyLost: player.moneyLost + (issueFine ? 100 : 0),
    );
  }

  /// Replace an existing BAC reading for [playerId] in [roundNumber].
  ///
  /// Reverses the old reading's points impact, applies the new value, and
  /// updates fine counters if the fine status changed.
  /// Does NOT notify the checkpoint (player is already counted as measured).
  Future<BACEntryResult> editBAC(
    String playerId,
    int roundNumber,
    double newBAC,
  ) async {
    final repo = ref.read(playerRepositoryProvider);
    final player = await repo.getById(playerId);
    if (player == null) throw StateError('Player $playerId not found');

    final oldReading = player.latestReadingForRound(roundNumber);
    if (oldReading == null) {
      throw StateError('No reading for player $playerId in round $roundNumber');
    }

    final gameState = await ref.read(currentGameStateProvider.future);
    final preGameBeers = gameState?.preGameBeers ?? 0.0;
    final optimal =
        BACCalculator.calculateOptimalBrAC(
          roundNumber,
          player.sex,
          player.bodySize,
        ) +
        BACCalculator.preGameBacOffset(
          preGameBeers,
          player.sex,
          player.bodySize,
        );

    final isSober = newBAC <= AppConstants.soberThreshold;
    final rawPointsChange = PointsCalculator.calculatePointsChange(
      currentBAC: newBAC,
      optimalBAC: optimal,
      roundNumber: roundNumber,
    );
    final newPointsChange = isSober ? 0 : rawPointsChange;

    // Reverse the old reading's impact, then apply the new one.
    final basePoints = player.points - oldReading.pointsChange;
    final newPoints = PointsCalculator.calculateTotalPoints(
      basePoints,
      newPointsChange,
    );

    final oldWasFine = PointsCalculator.shouldIssueFine(
      oldReading.pointsChange,
    );
    final newIsFine =
        !isSober && PointsCalculator.shouldIssueFine(rawPointsChange);
    final newFineCount =
        player.fineCount - (oldWasFine ? 1 : 0) + (newIsFine ? 1 : 0);
    final newMoneyLost =
        player.moneyLost - (oldWasFine ? 100 : 0) + (newIsFine ? 100 : 0);

    final updatedReading = oldReading.copyWith(
      bac: newBAC,
      timestamp: DateTime.now(),
      pointsChange: newPointsChange,
      optimalBAC: optimal,
    );
    final updatedReadings = player.readings
        .map((r) => r.id == oldReading.id ? updatedReading : r)
        .toList();

    final updatedPlayer = player.copyWith(
      points: newPoints,
      readings: updatedReadings,
      fineCount: newFineCount.clamp(0, 999),
      moneyLost: newMoneyLost.clamp(0, 999999),
    );

    await repo.update(updatedPlayer);
    await LicenseUpdateService.updateForPlayer(
      player: updatedPlayer,
      repo: repo,
    );
    ref.invalidate(playerListNotifierProvider);

    final feedbackMsg = PointsCalculator.getFeedbackMessage(newPointsChange);
    final feedbackColorEnum = PointsCalculator.getFeedbackColor(
      newPointsChange,
    );
    final feedbackColor = _colorFromEnum(feedbackColorEnum);

    return BACEntryResult(
      playerId: playerId,
      playerName: '${player.name} ${player.surname}',
      bac: newBAC,
      roundNumber: roundNumber,
      pointsChange: newPointsChange,
      feedbackMessage: feedbackMsg,
      feedbackColor: feedbackColor,
      fineCount: newFineCount.clamp(0, 999),
      moneyLost: newMoneyLost.clamp(0, 999999),
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
