import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoritesState {
  final Set<int> teams;
  final Set<int> leagues;
  final Set<int> matches;

  const FavoritesState({
    this.teams = const {},
    this.leagues = const {},
    this.matches = const {},
  });

  FavoritesState copyWith({
    Set<int>? teams,
    Set<int>? leagues,
    Set<int>? matches,
  }) =>
      FavoritesState(
        teams: teams ?? this.teams,
        leagues: leagues ?? this.leagues,
        matches: matches ?? this.matches,
      );
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  FavoritesNotifier() : super(const FavoritesState()) {
    _load();
  }

  static const _boxName = 'favorites';

  void _load() {
    final box = Hive.box(_boxName);
    state = FavoritesState(
      teams: _toIntSet(box.get('teams', defaultValue: <int>[])),
      leagues: _toIntSet(box.get('leagues', defaultValue: <int>[])),
      matches: _toIntSet(box.get('matches', defaultValue: <int>[])),
    );
  }

  Set<int> _toIntSet(dynamic raw) {
    if (raw is List) {
      return raw.whereType<num>().map((e) => e.toInt()).toSet();
    }
    return <int>{};
  }

  bool isTeamFavorite(int id) => state.teams.contains(id);
  bool isLeagueFavorite(int id) => state.leagues.contains(id);
  bool isMatchFavorite(int id) => state.matches.contains(id);

  Future<void> toggleTeam(int id) async {
    final next = Set<int>.from(state.teams);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(teams: next);
    await Hive.box(_boxName).put('teams', next.toList());
  }

  Future<void> toggleLeague(int id) async {
    final next = Set<int>.from(state.leagues);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(leagues: next);
    await Hive.box(_boxName).put('leagues', next.toList());
  }

  Future<void> toggleMatch(int id) async {
    final next = Set<int>.from(state.matches);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(matches: next);
    await Hive.box(_boxName).put('matches', next.toList());
  }

  Future<void> setTeams(Set<int> ids) async {
    state = state.copyWith(teams: ids);
    await Hive.box(_boxName).put('teams', ids.toList());
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>(
  (ref) => FavoritesNotifier(),
);
