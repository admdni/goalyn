import 'package:flutter_test/flutter_test.dart';
import 'package:goalyn/services/predictions_service.dart';

void main() {
  group('PredictionEntry scoring', () {
    test('exact match scores 3 points', () {
      final entry = PredictionEntry(
        matchId: 1,
        homeTeam: 'A',
        awayTeam: 'B',
        predictedHome: 2,
        predictedAway: 1,
        actualHome: 2,
        actualAway: 1,
        createdAt: DateTime.now(),
      );
      expect(entry.isExactMatch, true);
      expect(entry.points, 3);
    });

    test('correct outcome scores 1 point', () {
      final entry = PredictionEntry(
        matchId: 2,
        homeTeam: 'A',
        awayTeam: 'B',
        predictedHome: 2,
        predictedAway: 1,
        actualHome: 3,
        actualAway: 0,
        createdAt: DateTime.now(),
      );
      expect(entry.isExactMatch, false);
      expect(entry.isOutcomeCorrect, true);
      expect(entry.points, 1);
    });

    test('wrong outcome scores 0 points', () {
      final entry = PredictionEntry(
        matchId: 3,
        homeTeam: 'A',
        awayTeam: 'B',
        predictedHome: 2,
        predictedAway: 0,
        actualHome: 0,
        actualAway: 1,
        createdAt: DateTime.now(),
      );
      expect(entry.isOutcomeCorrect, false);
      expect(entry.points, 0);
    });

    test('unresolved prediction has 0 points', () {
      final entry = PredictionEntry(
        matchId: 4,
        homeTeam: 'A',
        awayTeam: 'B',
        predictedHome: 1,
        predictedAway: 1,
        createdAt: DateTime.now(),
      );
      expect(entry.isResolved, false);
      expect(entry.points, 0);
    });
  });
}
