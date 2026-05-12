import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:dgv/core/models/player_profile.dart';
import 'package:dgv/core/utils/checkpoint_calculator.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PlayerProfile _makePlayer(String id) => PlayerProfile(
  id: id,
  name: 'Player',
  surname: id,
  photoPath: '',
  sex: Sex.male,
  bodySize: BodySize.medium,
  optimalBAC: 2.0,
  licenseImagePath: '',
  readings: const [],
  titleCounts: const {},
);

List<PlayerProfile> _makePlayers(int count) =>
    List.generate(count, (i) => _makePlayer('p$i'));

void main() {
  group('CheckpointCalculator', () {
    // ── calculateNextCheckpoint ──────────────────────────────────────────────

    group('calculateNextCheckpoint', () {
      test('adds interval duration to last measurement', () {
        final base = DateTime(2025, 1, 1, 14, 0);
        final next = CheckpointCalculator.calculateNextCheckpoint(base, 45);
        expect(next, equals(base.add(const Duration(minutes: 45))));
      });

      test('works with 30-minute interval', () {
        final base = DateTime(2025, 1, 1, 14, 0);
        final next = CheckpointCalculator.calculateNextCheckpoint(base, 30);
        expect(next, equals(DateTime(2025, 1, 1, 14, 30)));
      });

      test('works with 60-minute interval', () {
        final base = DateTime(2025, 1, 1, 14, 0);
        final next = CheckpointCalculator.calculateNextCheckpoint(base, 60);
        expect(next, equals(DateTime(2025, 1, 1, 15, 0)));
      });
    });

    // ── isCheckpointDue ──────────────────────────────────────────────────────

    group('isCheckpointDue', () {
      test('returns true when current time is after next checkpoint', () {
        // Last measurement was 2 hours ago with 45-min interval → overdue
        final past = DateTime.now().subtract(const Duration(hours: 2));
        expect(CheckpointCalculator.isCheckpointDue(past, 45), isTrue);
      });

      test('returns false when checkpoint is in the future', () {
        // Last measurement was 10 seconds ago with 45-min interval → not due
        final recent = DateTime.now().subtract(const Duration(seconds: 10));
        expect(CheckpointCalculator.isCheckpointDue(recent, 45), isFalse);
      });
    });

    // ── getTimeRemaining ─────────────────────────────────────────────────────

    group('getTimeRemaining', () {
      test('returns Duration.zero when checkpoint is overdue', () {
        final past = DateTime.now().subtract(const Duration(hours: 2));
        expect(
          CheckpointCalculator.getTimeRemaining(past, 45),
          equals(Duration.zero),
        );
      });

      test('returns positive duration when checkpoint is in the future', () {
        final recent = DateTime.now().subtract(const Duration(seconds: 10));
        final remaining = CheckpointCalculator.getTimeRemaining(recent, 45);
        expect(remaining.inSeconds, greaterThan(0));
      });

      test('never returns negative duration', () {
        final past = DateTime.now().subtract(const Duration(hours: 10));
        final remaining = CheckpointCalculator.getTimeRemaining(past, 45);
        expect(remaining.inSeconds, greaterThanOrEqualTo(0));
      });
    });

    // ── divideIntoGroups ─────────────────────────────────────────────────────

    group('divideIntoGroups', () {
      test('20 players into 3 groups → sizes [7, 7, 6]', () {
        final players = _makePlayers(20);
        final groups = CheckpointCalculator.divideIntoGroups(players, 3);
        expect(groups.length, equals(3));
        expect(groups[0].length, equals(7));
        expect(groups[1].length, equals(7));
        expect(groups[2].length, equals(6));
      });

      test('1 player into 1 group', () {
        final players = _makePlayers(1);
        final groups = CheckpointCalculator.divideIntoGroups(players, 1);
        expect(groups.length, equals(1));
        expect(groups[0].length, equals(1));
      });

      test('clamps numberOfGroups to player count', () {
        final players = _makePlayers(3);
        final groups = CheckpointCalculator.divideIntoGroups(players, 10);
        // 3 players, 10 groups → clamps to 3 groups of 1
        final totalPlayers = groups.fold<int>(0, (s, g) => s + g.length);
        expect(totalPlayers, equals(3));
      });

      test('handles numberOfGroups <= 0 by using 1 group', () {
        final players = _makePlayers(5);
        final groups = CheckpointCalculator.divideIntoGroups(players, 0);
        final totalPlayers = groups.fold<int>(0, (s, g) => s + g.length);
        expect(totalPlayers, equals(5));
      });

      test('preserves all players across groups', () {
        final players = _makePlayers(10);
        final groups = CheckpointCalculator.divideIntoGroups(players, 3);
        final totalPlayers = groups.fold<int>(0, (s, g) => s + g.length);
        expect(totalPlayers, equals(10));
      });
    });

    // ── suggestNumberOfGroups ────────────────────────────────────────────────

    group('suggestNumberOfGroups', () {
      test('returns 1 for 8 players', () {
        expect(CheckpointCalculator.suggestNumberOfGroups(8), equals(1));
      });

      test('returns 2 for 9 players', () {
        expect(CheckpointCalculator.suggestNumberOfGroups(9), equals(2));
      });

      test('returns 2 for 16 players', () {
        expect(CheckpointCalculator.suggestNumberOfGroups(16), equals(2));
      });

      test('returns 3 for 17 players', () {
        expect(CheckpointCalculator.suggestNumberOfGroups(17), equals(3));
      });

      test('returns 3 for 24 players', () {
        expect(CheckpointCalculator.suggestNumberOfGroups(24), equals(3));
      });

      test('returns 4 for 25 players', () {
        expect(CheckpointCalculator.suggestNumberOfGroups(25), equals(4));
      });

      test('returns 1 for 1 player', () {
        expect(CheckpointCalculator.suggestNumberOfGroups(1), equals(1));
      });
    });

    // ── formatTimeRemaining ──────────────────────────────────────────────────

    group('formatTimeRemaining', () {
      test('formats 5 minutes 3 seconds as 05:03', () {
        expect(
          CheckpointCalculator.formatTimeRemaining(
            const Duration(minutes: 5, seconds: 3),
          ),
          equals('05:03'),
        );
      });

      test('formats zero duration as 00:00', () {
        expect(
          CheckpointCalculator.formatTimeRemaining(Duration.zero),
          equals('00:00'),
        );
      });

      test('formats 45 minutes as 45:00', () {
        expect(
          CheckpointCalculator.formatTimeRemaining(const Duration(minutes: 45)),
          equals('45:00'),
        );
      });

      test('zero-pads single-digit minutes and seconds', () {
        expect(
          CheckpointCalculator.formatTimeRemaining(
            const Duration(minutes: 1, seconds: 9),
          ),
          equals('01:09'),
        );
      });
    });

    // ── Property 9: Group division preserves count and balances sizes ─────────

    group('Property 9: group division preserves count and balances sizes', () {
      // Feature: phase-1-completion, Property 9
      test('sum of group sizes equals total player count', () {
        final rng = Random(42);
        for (var i = 0; i < 100; i++) {
          final playerCount = rng.nextInt(50) + 1; // [1, 50]
          final groupCount = rng.nextInt(10) + 1; // [1, 10]
          final players = _makePlayers(playerCount);

          final groups = CheckpointCalculator.divideIntoGroups(
            players,
            groupCount,
          );

          final total = groups.fold<int>(0, (s, g) => s + g.length);
          expect(
            total,
            equals(playerCount),
            reason: 'playerCount=$playerCount, groupCount=$groupCount',
          );
        }
      });

      test('no group is empty and sizes are reasonable', () {
        final rng = Random(42);
        for (var i = 0; i < 100; i++) {
          final playerCount = rng.nextInt(50) + 1;
          final groupCount = rng.nextInt(10) + 1;
          final players = _makePlayers(playerCount);

          final groups = CheckpointCalculator.divideIntoGroups(
            players,
            groupCount,
          );

          // All groups must be non-empty
          for (final group in groups) {
            expect(
              group.length,
              greaterThan(0),
              reason:
                  'playerCount=$playerCount, groupCount=$groupCount: '
                  'found empty group',
            );
          }

          // The last group may be smaller; all others have the same size
          if (groups.length > 1) {
            final firstSize = groups.first.length;
            for (var j = 0; j < groups.length - 1; j++) {
              expect(
                groups[j].length,
                equals(firstSize),
                reason:
                    'playerCount=$playerCount, groupCount=$groupCount: '
                    'non-last group $j has unexpected size',
              );
            }
            // Last group is <= first group size
            expect(groups.last.length, lessThanOrEqualTo(firstSize));
          }
        }
      });
    });

    // ── Property 10: Time remaining is non-negative and monotonically decreasing

    group('Property 10: time remaining is non-negative and monotonically '
        'decreasing', () {
      // Feature: phase-1-completion, Property 10
      test('getTimeRemaining never increases as time advances', () {
        // Use a past lastMeasurement so remaining decreases as we call it
        // multiple times (real time advances between calls)
        final lastMeasurement = DateTime.now().subtract(
          const Duration(minutes: 10),
        );
        const intervalMinutes = 45;

        Duration? previous;
        for (var step = 0; step < 5; step++) {
          final remaining = CheckpointCalculator.getTimeRemaining(
            lastMeasurement,
            intervalMinutes,
          );

          expect(remaining.inSeconds, greaterThanOrEqualTo(0));

          if (previous != null) {
            // Remaining should be <= previous (time only moves forward)
            expect(
              remaining.inSeconds,
              lessThanOrEqualTo(previous.inSeconds),
              reason: 'step=$step: remaining should not increase',
            );
          }
          previous = remaining;
        }
      });

      test('returns Duration.zero when checkpoint is overdue', () {
        // lastMeasurement 2 hours ago, 45-min interval → overdue
        final past = DateTime.now().subtract(const Duration(hours: 2));
        final remaining = CheckpointCalculator.getTimeRemaining(past, 45);
        expect(remaining, equals(Duration.zero));
      });
    });

    // ── Property 11: formatTimeRemaining always produces MM:SS ───────────────

    group('Property 11: formatTimeRemaining always produces MM:SS format', () {
      // Feature: phase-1-completion, Property 11
      test('output always contains colon-separated minutes and seconds', () {
        final rng = Random(42);
        // Pattern: digits:two-digits (minutes can be any length, seconds always 2)
        final pattern = RegExp(r'^\d+:\d{2}$');

        for (var i = 0; i < 100; i++) {
          final totalSeconds = rng.nextInt(7200); // [0, 7200) seconds
          final duration = Duration(seconds: totalSeconds);
          final formatted = CheckpointCalculator.formatTimeRemaining(duration);

          expect(
            pattern.hasMatch(formatted),
            isTrue,
            reason: 'duration=$duration → "$formatted" does not match MM:SS',
          );

          // Seconds part must be 00-59
          final parts = formatted.split(':');
          final seconds = int.parse(parts[1]);
          expect(seconds, inInclusiveRange(0, 59));
        }
      });

      test('zero-pads seconds to 2 digits', () {
        expect(
          CheckpointCalculator.formatTimeRemaining(
            const Duration(minutes: 5, seconds: 3),
          ),
          equals('05:03'),
        );
      });
    });
  });
}
