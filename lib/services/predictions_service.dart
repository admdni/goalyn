import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PredictionEntry {
  final int matchId;
  final String homeTeam;
  final String awayTeam;
  final int predictedHome;
  final int predictedAway;
  final int? actualHome;
  final int? actualAway;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const PredictionEntry({
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.predictedHome,
    required this.predictedAway,
    this.actualHome,
    this.actualAway,
    required this.createdAt,
    this.resolvedAt,
  });

  bool get isResolved => actualHome != null && actualAway != null;

  bool get isExactMatch =>
      isResolved &&
      predictedHome == actualHome &&
      predictedAway == actualAway;

  bool get isOutcomeCorrect {
    if (!isResolved) return false;
    final pDiff = predictedHome - predictedAway;
    final aDiff = actualHome! - actualAway!;
    if (pDiff == 0 && aDiff == 0) return true;
    if (pDiff > 0 && aDiff > 0) return true;
    if (pDiff < 0 && aDiff < 0) return true;
    return false;
  }

  /// 3 points exact, 1 point outcome only, 0 wrong.
  int get points {
    if (!isResolved) return 0;
    if (isExactMatch) return 3;
    if (isOutcomeCorrect) return 1;
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'predictedHome': predictedHome,
        'predictedAway': predictedAway,
        'actualHome': actualHome,
        'actualAway': actualAway,
        'createdAt': createdAt.toIso8601String(),
        'resolvedAt': resolvedAt?.toIso8601String(),
      };

  factory PredictionEntry.fromJson(Map json) => PredictionEntry(
        matchId: json['matchId'] as int,
        homeTeam: json['homeTeam'] as String? ?? '',
        awayTeam: json['awayTeam'] as String? ?? '',
        predictedHome: json['predictedHome'] as int? ?? 0,
        predictedAway: json['predictedAway'] as int? ?? 0,
        actualHome: json['actualHome'] as int?,
        actualAway: json['actualAway'] as int?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        resolvedAt: json['resolvedAt'] != null
            ? DateTime.tryParse(json['resolvedAt'] as String)
            : null,
      );

  PredictionEntry copyWith({
    int? predictedHome,
    int? predictedAway,
    int? actualHome,
    int? actualAway,
    DateTime? resolvedAt,
  }) =>
      PredictionEntry(
        matchId: matchId,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        predictedHome: predictedHome ?? this.predictedHome,
        predictedAway: predictedAway ?? this.predictedAway,
        actualHome: actualHome ?? this.actualHome,
        actualAway: actualAway ?? this.actualAway,
        createdAt: createdAt,
        resolvedAt: resolvedAt ?? this.resolvedAt,
      );
}

class PredictionStats {
  final int total;
  final int resolved;
  final int exact;
  final int outcomeCorrect;
  final int points;
  final int currentStreak;
  final int bestStreak;

  const PredictionStats({
    required this.total,
    required this.resolved,
    required this.exact,
    required this.outcomeCorrect,
    required this.points,
    required this.currentStreak,
    required this.bestStreak,
  });

  double get accuracy =>
      resolved == 0 ? 0 : (outcomeCorrect / resolved) * 100;

  double get exactRate =>
      resolved == 0 ? 0 : (exact / resolved) * 100;

  String get rank {
    if (points >= 100) return 'Legend';
    if (points >= 50) return 'Pro';
    if (points >= 20) return 'Sharp';
    if (points >= 5) return 'Rookie';
    return 'Newcomer';
  }
}

class PredictionsNotifier extends StateNotifier<List<PredictionEntry>> {
  PredictionsNotifier() : super([]) {
    _load();
  }

  static const _boxName = 'predictions';

  void _load() {
    final box = Hive.box(_boxName);
    final list = box.values
        .map((e) => PredictionEntry.fromJson(Map.from(e as Map)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = list;
  }

  PredictionEntry? forMatch(int matchId) {
    try {
      return state.firstWhere((p) => p.matchId == matchId);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsert({
    required int matchId,
    required String homeTeam,
    required String awayTeam,
    required int predictedHome,
    required int predictedAway,
  }) async {
    final box = Hive.box(_boxName);
    final existing = forMatch(matchId);
    final entry = existing != null
        ? existing.copyWith(
            predictedHome: predictedHome,
            predictedAway: predictedAway,
          )
        : PredictionEntry(
            matchId: matchId,
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            predictedHome: predictedHome,
            predictedAway: predictedAway,
            createdAt: DateTime.now(),
          );

    await box.put(matchId.toString(), entry.toJson());
    _load();
  }

  Future<void> resolve({
    required int matchId,
    required int actualHome,
    required int actualAway,
  }) async {
    final entry = forMatch(matchId);
    if (entry == null) return;
    final box = Hive.box(_boxName);
    final resolved = entry.copyWith(
      actualHome: actualHome,
      actualAway: actualAway,
      resolvedAt: DateTime.now(),
    );
    await box.put(matchId.toString(), resolved.toJson());
    _load();
  }

  Future<void> remove(int matchId) async {
    final box = Hive.box(_boxName);
    await box.delete(matchId.toString());
    _load();
  }

  Future<void> clearAll() async {
    final box = Hive.box(_boxName);
    await box.clear();
    _load();
  }

  PredictionStats stats() {
    final resolved = state.where((p) => p.isResolved).toList()
      ..sort((a, b) => (a.resolvedAt ?? a.createdAt)
          .compareTo(b.resolvedAt ?? b.createdAt));
    final exact = resolved.where((p) => p.isExactMatch).length;
    final outcome = resolved.where((p) => p.isOutcomeCorrect).length;
    final points = resolved.fold<int>(0, (sum, p) => sum + p.points);

    int current = 0;
    int best = 0;
    int run = 0;
    for (final p in resolved) {
      if (p.isOutcomeCorrect) {
        run += 1;
        if (run > best) best = run;
      } else {
        run = 0;
      }
    }
    // Current streak from latest backwards
    for (final p in resolved.reversed) {
      if (p.isOutcomeCorrect) {
        current += 1;
      } else {
        break;
      }
    }

    return PredictionStats(
      total: state.length,
      resolved: resolved.length,
      exact: exact,
      outcomeCorrect: outcome,
      points: points,
      currentStreak: current,
      bestStreak: best,
    );
  }
}

final predictionsProvider =
    StateNotifierProvider<PredictionsNotifier, List<PredictionEntry>>(
  (ref) => PredictionsNotifier(),
);

final predictionStatsProvider = Provider<PredictionStats>((ref) {
  ref.watch(predictionsProvider);
  return ref.read(predictionsProvider.notifier).stats();
});
