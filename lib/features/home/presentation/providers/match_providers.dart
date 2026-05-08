import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/models/match_model.dart';
import '../../data/models/league_model.dart';
import '../../data/models/team_model.dart';
import '../../../league/data/models/standing_model.dart';
import '../../../news/data/models/news_model.dart';
import '../../../../services/mock_data_service.dart';
import '../../../../services/news_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../services/cache_service.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Connectivity Provider
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((results) => results.first);
});

// Leagues Provider
final leaguesProvider = FutureProvider<List<LeagueModel>>((ref) async {
  const cacheKey = 'leagues';
  try {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
      '/leagues',
      queryParameters: {'current': 'true'},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    // Cache the raw response
    await CacheService.put(cacheKey, responseList, ttlMinutes: 60);
    return responseList
        .map((e) => LeagueModel.fromJson(e['league'] as Map<String, dynamic>))
        .toList();
  } catch (e) {
    // Try fresh cache first, then stale cache, then mock
    final cached = CacheService.get(cacheKey) ?? CacheService.getStale(cacheKey);
    if (cached != null) {
      return (cached as List<dynamic>)
          .map((e) => LeagueModel.fromJson((e as Map<String, dynamic>)['league'] as Map<String, dynamic>))
          .toList();
    }
    return MockDataService.getLeagues();
  }
});

// Live Matches Provider
final liveMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  const cacheKey = 'live_matches';
  try {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
      '/fixtures',
      queryParameters: {'live': 'all'},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    // Cache the raw response
    await CacheService.put(cacheKey, responseList, ttlMinutes: 1);
    return responseList
        .map((e) => MatchModel.fromApiFootball(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    // Try fresh cache first, then stale cache, then mock
    final cached = CacheService.get(cacheKey) ?? CacheService.getStale(cacheKey);
    if (cached != null) {
      return (cached as List<dynamic>)
          .map((e) => MatchModel.fromApiFootball(e as Map<String, dynamic>))
          .toList();
    }
    return MockDataService.getLiveMatches();
  }
});

// Today's Matches Provider
final todayMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  const cacheKey = 'today_matches';
  try {
    final apiClient = ref.read(apiClientProvider);
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final response = await apiClient.get(
      '/fixtures',
      queryParameters: {'date': dateStr},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    // Cache the raw response
    await CacheService.put(cacheKey, responseList);
    return responseList
        .map((e) => MatchModel.fromApiFootball(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    // Try fresh cache first, then stale cache, then mock
    final cached = CacheService.get(cacheKey) ?? CacheService.getStale(cacheKey);
    if (cached != null) {
      return (cached as List<dynamic>)
          .map((e) => MatchModel.fromApiFootball(e as Map<String, dynamic>))
          .toList();
    }
    return MockDataService.getTodaysMatches();
  }
});

// Upcoming Matches Provider
final upcomingMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  const cacheKey = 'upcoming_matches';
  try {
    final apiClient = ref.read(apiClientProvider);
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final nextWeek = now.add(const Duration(days: 7));
    final fromStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final toStr = '${nextWeek.year}-${nextWeek.month.toString().padLeft(2, '0')}-${nextWeek.day.toString().padLeft(2, '0')}';
    final response = await apiClient.get(
      '/fixtures',
      queryParameters: {'from': fromStr, 'to': toStr},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    // Cache the raw response
    await CacheService.put(cacheKey, responseList);
    return responseList
        .map((e) => MatchModel.fromApiFootball(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    // Try fresh cache first, then stale cache, then mock
    final cached = CacheService.get(cacheKey) ?? CacheService.getStale(cacheKey);
    if (cached != null) {
      return (cached as List<dynamic>)
          .map((e) => MatchModel.fromApiFootball(e as Map<String, dynamic>))
          .toList();
    }
    return MockDataService.getUpcomingMatches();
  }
});

// Match Detail Provider
final matchDetailProvider = FutureProvider.family<MatchModel, int>((ref, matchId) async {
  try {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
      '/fixtures',
      queryParameters: {'id': matchId.toString()},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    if (responseList.isEmpty) throw NotFoundException();
    final json = responseList.first as Map<String, dynamic>;

    // Parse basic match info
    var match = MatchModel.fromApiFootball(json);

    // Parse events
    final eventsJson = json['events'] as List<dynamic>? ?? [];
    final events = eventsJson.asMap().entries.map((e) {
      final ev = e.value as Map<String, dynamic>;
      return MatchEventModel(
        id: e.key,
        type: ev['type'] as String? ?? '',
        detail: ev['detail'] as String?,
        player: (ev['player'] as Map<String, dynamic>?)?['name'] as String?,
        assist: (ev['assist'] as Map<String, dynamic>?)?['name'] as String?,
        minute: (ev['time'] as Map<String, dynamic>?)?['elapsed'] as int?,
        teamId: (ev['team'] as Map<String, dynamic>?)?['id'] as int?,
        teamName: (ev['team'] as Map<String, dynamic>?)?['name'] as String?,
      );
    }).toList();

    // Parse statistics
    MatchStatisticsModel? statistics;
    final statsJson = json['statistics'] as List<dynamic>? ?? [];
    if (statsJson.length >= 2) {
      final homeStats = (statsJson[0] as Map<String, dynamic>)['statistics'] as List<dynamic>? ?? [];
      final awayStats = (statsJson[1] as Map<String, dynamic>)['statistics'] as List<dynamic>? ?? [];
      final statItems = <StatisticItemModel>[];
      for (int i = 0; i < homeStats.length; i++) {
        final h = homeStats[i] as Map<String, dynamic>;
        final a = i < awayStats.length ? awayStats[i] as Map<String, dynamic> : <String, dynamic>{};
        statItems.add(StatisticItemModel(
          name: h['type'] as String? ?? '',
          homeValue: h['value']?.toString() ?? '0',
          awayValue: a['value']?.toString() ?? '0',
        ));
      }
      statistics = MatchStatisticsModel(statistics: statItems);
    }

    // Parse lineups
    final lineupsJson = json['lineups'] as List<dynamic>? ?? [];
    final lineups = lineupsJson.map((l) {
      final lineup = l as Map<String, dynamic>;
      final team = lineup['team'] as Map<String, dynamic>? ?? {};
      final coach = lineup['coach'] as Map<String, dynamic>?;

      final startXI = (lineup['startXI'] as List<dynamic>? ?? []).map((p) {
        final player = (p as Map<String, dynamic>)['player'] as Map<String, dynamic>? ?? {};
        return LineupPlayerModel(
          id: player['id'] as int? ?? 0,
          name: player['name'] as String? ?? '',
          number: player['number'] as int?,
          position: player['pos'] as String?,
        );
      }).toList();

      final subs = (lineup['substitutes'] as List<dynamic>? ?? []).map((p) {
        final player = (p as Map<String, dynamic>)['player'] as Map<String, dynamic>? ?? {};
        return LineupPlayerModel(
          id: player['id'] as int? ?? 0,
          name: player['name'] as String? ?? '',
          number: player['number'] as int?,
          position: player['pos'] as String?,
        );
      }).toList();

      return MatchLineupModel(
        teamId: team['id'] as int? ?? 0,
        teamName: team['name'] as String? ?? '',
        teamLogo: team['logo'] as String?,
        formation: lineup['formation'] as String?,
        coachName: coach?['name'] as String?,
        startXI: startXI,
        substitutes: subs,
      );
    }).toList();

    // Parse formations
    String? homeFormation;
    String? awayFormation;
    if (lineups.isNotEmpty) {
      homeFormation = lineups.first.formation;
      if (lineups.length > 1) awayFormation = lineups[1].formation;
    }

    // Return enriched match
    return match.copyWith(
      events: events,
      statistics: statistics,
      lineups: lineups,
      homeFormation: homeFormation,
      awayFormation: awayFormation,
    );
  } catch (e) {
    return MockDataService.getMatchDetails(matchId);
  }
});

// Team Provider
final teamProvider = FutureProvider.family<TeamModel, int>((ref, teamId) async {
  try {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
      '/teams',
      queryParameters: {'id': teamId.toString()},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    if (responseList.isEmpty) throw NotFoundException();
    final teamData = responseList.first as Map<String, dynamic>;
    return TeamModel.fromJson(teamData['team'] as Map<String, dynamic>);
  } catch (e) {
    return MockDataService.getTeamById(teamId) ?? TeamModel(id: teamId, name: 'Unknown');
  }
});

// Search Provider
final searchTeamsProvider = FutureProvider.family<List<TeamModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  try {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
      '/teams',
      queryParameters: {'search': query},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    return responseList
        .map((e) => TeamModel.fromJson(e['team'] as Map<String, dynamic>))
        .toList();
  } catch (e) {
    return MockDataService.searchTeams(query);
  }
});

// Search Leagues Provider
final searchLeaguesProvider = FutureProvider.family<List<LeagueModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  try {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
      '/leagues',
      queryParameters: {'search': query},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    return responseList
        .map((e) => LeagueModel.fromJson(e['league'] as Map<String, dynamic>))
        .toList();
  } catch (e) {
    final leagues = MockDataService.getLeagues();
    return leagues.where((l) => l.name.toLowerCase().contains(query.toLowerCase())).toList();
  }
});

// Finished Matches Provider
final finishedMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  const cacheKey = 'finished_matches';
  try {
    final apiClient = ref.read(apiClientProvider);
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final dateStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    final response = await apiClient.get(
      '/fixtures',
      queryParameters: {'date': dateStr, 'status': 'FT-AET-PEN'},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    // Cache the raw response
    await CacheService.put(cacheKey, responseList);
    return responseList
        .map((e) => MatchModel.fromApiFootball(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    // Try fresh cache first, then stale cache, then mock
    final cached = CacheService.get(cacheKey) ?? CacheService.getStale(cacheKey);
    if (cached != null) {
      return (cached as List<dynamic>)
          .map((e) => MatchModel.fromApiFootball(e as Map<String, dynamic>))
          .toList();
    }
    return MockDataService.getFinishedMatches();
  }
});

// Standings Provider
final standingsProvider = FutureProvider.family<List<StandingModel>, int>((ref, leagueId) async {
  final cacheKey = 'standings_$leagueId';
  try {
    final apiClient = ref.read(apiClientProvider);
    final season = DateTime.now().year;
    final response = await apiClient.get(
      '/standings',
      queryParameters: {'league': leagueId.toString(), 'season': season.toString()},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    if (responseList.isEmpty) return MockDataService.getStandings(leagueId);
    final leagueData = responseList.first as Map<String, dynamic>;
    final standings = (leagueData['league']?['standings'] as List<dynamic>?)?.first as List<dynamic>?;
    if (standings == null) return MockDataService.getStandings(leagueId);
    // Cache the raw standings list
    await CacheService.put(cacheKey, standings, ttlMinutes: 30);
    return standings
        .map((e) => StandingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    // Try fresh cache first, then stale cache, then mock
    final cached = CacheService.get(cacheKey) ?? CacheService.getStale(cacheKey);
    if (cached != null) {
      return (cached as List<dynamic>)
          .map((e) => StandingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return MockDataService.getStandings(leagueId);
  }
});

// League Matches Provider
final leagueMatchesProvider = FutureProvider.family<List<MatchModel>, int>((ref, leagueId) async {
  try {
    final apiClient = ref.read(apiClientProvider);
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final response = await apiClient.get(
      '/fixtures',
      queryParameters: {'league': leagueId.toString(), 'season': now.year.toString(), 'from': dateStr, 'to': dateStr},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    return responseList
        .map((e) => MatchModel.fromApiFootball(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    return MockDataService.getLeagueMatches(leagueId);
  }
});

// Team Info Provider (with venue details)
final teamInfoProvider = FutureProvider.family<TeamModel, int>((ref, teamId) async {
  try {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
      '/teams',
      queryParameters: {'id': teamId.toString()},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    if (responseList.isEmpty) throw NotFoundException();
    final teamData = responseList.first as Map<String, dynamic>;
    final team = teamData['team'] as Map<String, dynamic>;
    final venue = teamData['venue'] as Map<String, dynamic>?;
    return TeamModel(
      id: team['id'] as int? ?? teamId,
      name: team['name'] as String? ?? '',
      logo: team['logo'] as String?,
      country: team['country'] as String?,
      founded: team['founded']?.toString(),
      stadium: venue?['name'] as String?,
      venueCity: venue?['city'] as String?,
      venueCapacity: venue?['capacity'] as int?,
      stadiumImage: venue?['image'] as String?,
    );
  } catch (e) {
    return MockDataService.getTeamById(teamId) ?? TeamModel(id: teamId, name: 'Unknown');
  }
});

// Team Recent Matches Provider
final teamMatchesProvider = FutureProvider.family<List<MatchModel>, int>((ref, teamId) async {
  try {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
      '/fixtures',
      queryParameters: {'team': teamId.toString(), 'last': '5'},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    return responseList
        .map((e) => MatchModel.fromApiFootball(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    return MockDataService.getTodaysMatches().take(5).toList();
  }
});

// Team Squad Provider
final teamSquadProvider = FutureProvider.family<List<LineupPlayerModel>, int>((ref, teamId) async {
  try {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
      '/players/squads',
      queryParameters: {'team': teamId.toString()},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    if (responseList.isEmpty) return MockDataService.getTeamSquad(teamId);
    final players = (responseList.first as Map<String, dynamic>)['players'] as List<dynamic>?;
    if (players == null) return MockDataService.getTeamSquad(teamId);
    return players.map((p) {
      final player = p as Map<String, dynamic>;
      return LineupPlayerModel(
        id: player['id'] as int? ?? 0,
        name: player['name'] as String? ?? '',
        number: player['number'] as int?,
        position: player['position'] as String?,
        photo: player['photo'] as String?,
      );
    }).toList();
  } catch (e) {
    return MockDataService.getTeamSquad(teamId);
  }
});

// Match Events Provider
final matchEventsProvider = FutureProvider.family<List<MatchEventModel>, int>((ref, matchId) async {
  try {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
      '/fixtures/events',
      queryParameters: {'fixture': matchId.toString()},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    return responseList
        .asMap()
        .entries
        .map((e) => MatchEventModel.fromJson(e.value as Map<String, dynamic>))
        .toList();
  } catch (e) {
    return [];
  }
});

// Match Statistics Provider
final matchStatisticsProvider = FutureProvider.family<MatchStatisticsModel?, int>((ref, matchId) async {
  try {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
      '/fixtures/statistics',
      queryParameters: {'fixture': matchId.toString()},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    if (responseList.length < 2) return null;
    final homeStats = (responseList[0] as Map<String, dynamic>)['statistics'] as List<dynamic>;
    final awayStats = (responseList[1] as Map<String, dynamic>)['statistics'] as List<dynamic>;
    final stats = <StatisticItemModel>[];
    for (int i = 0; i < homeStats.length; i++) {
      final h = homeStats[i] as Map<String, dynamic>;
      final a = i < awayStats.length ? awayStats[i] as Map<String, dynamic> : <String, dynamic>{};
      stats.add(StatisticItemModel(
        name: h['type'] as String? ?? '',
        homeValue: h['value']?.toString(),
        awayValue: a['value']?.toString(),
      ));
    }
    return MatchStatisticsModel(statistics: stats);
  } catch (e) {
    return null;
  }
});

// Match Lineups Provider
final matchLineupsProvider = FutureProvider.family<List<MatchLineupModel>, int>((ref, matchId) async {
  try {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
      '/fixtures/lineups',
      queryParameters: {'fixture': matchId.toString()},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    return responseList
        .map((e) => MatchLineupModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    return [];
  }
});

// News Provider (Google News RSS - no API key needed, locale-aware)
final newsLangProvider = StateProvider<String>((ref) => 'en');

final newsProvider = FutureProvider<List<NewsArticleModel>>((ref) async {
  final lang = ref.watch(newsLangProvider);
  try {
    final articles = await NewsService.fetchNews(lang: lang);
    if (articles.isNotEmpty) return articles;
    return MockDataService.getNews();
  } catch (e) {
    return MockDataService.getNews();
  }
});

// Top Scorers Provider
final topScorersProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, leagueId) async {
  try {
    final apiClient = ref.read(apiClientProvider);
    final season = DateTime.now().year;
    final response = await apiClient.get(
      '/players/topscorers',
      queryParameters: {'league': leagueId.toString(), 'season': season.toString()},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    return responseList.map((e) {
      final item = e as Map<String, dynamic>;
      final player = item['player'] as Map<String, dynamic>;
      final stats = (item['statistics'] as List<dynamic>).first as Map<String, dynamic>;
      final team = stats['team'] as Map<String, dynamic>;
      final goals = stats['goals'] as Map<String, dynamic>;
      return {
        'player': player['name'] as String? ?? '',
        'team': team['name'] as String? ?? '',
        'team_logo': team['logo'] as String? ?? '',
        'goals': goals['total'] as int? ?? 0,
        'assists': (goals['assists'] as int?) ?? 0,
      };
    }).toList();
  } catch (e) {
    return MockDataService.getTopScorers(leagueId);
  }
});

// Date-specific Matches Provider
final dateMatchesProvider = FutureProvider.family<List<MatchModel>, String>((ref, dateStr) async {
  final cacheKey = 'matches_$dateStr';
  try {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
      '/fixtures',
      queryParameters: {'date': dateStr},
    );
    final data = response.data as Map<String, dynamic>;
    final responseList = data['response'] as List<dynamic>;
    await CacheService.put(cacheKey, responseList, ttlMinutes: 30);
    return responseList
        .map((e) => MatchModel.fromApiFootball(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    final cached = CacheService.get(cacheKey) ?? CacheService.getStale(cacheKey);
    if (cached != null) {
      return (cached as List<dynamic>)
          .map((e) => MatchModel.fromApiFootball(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
});

// All Teams Provider (for compare, onboarding, etc.)
final allTeamsProvider = FutureProvider<List<TeamModel>>((ref) async {
  // Use popular league teams
  try {
    final apiClient = ref.read(apiClientProvider);
    final teams = <TeamModel>[];
    // Fetch top teams from major leagues
    for (final leagueId in [39, 140, 61, 78, 135, 203]) {
      final response = await apiClient.get(
        '/standings',
        queryParameters: {'league': leagueId.toString(), 'season': DateTime.now().year.toString()},
      );
      final data = response.data as Map<String, dynamic>;
      final responseList = data['response'] as List<dynamic>;
      if (responseList.isNotEmpty) {
        final leagueData = responseList.first as Map<String, dynamic>;
        final standings = (leagueData['league']?['standings'] as List<dynamic>?)?.first as List<dynamic>?;
        if (standings != null) {
          for (final s in standings.take(5)) {
            final t = (s as Map<String, dynamic>)['team'] as Map<String, dynamic>;
            teams.add(TeamModel(
              id: t['id'] as int? ?? 0,
              name: t['name'] as String? ?? '',
              logo: t['logo'] as String?,
            ));
          }
        }
      }
    }
    if (teams.isEmpty) return MockDataService.getTeams();
    return teams;
  } catch (e) {
    return MockDataService.getTeams();
  }
});
