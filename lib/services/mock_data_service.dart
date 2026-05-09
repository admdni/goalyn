import 'dart:math';
import '../features/home/data/models/league_model.dart';
import '../features/home/data/models/team_model.dart';
import '../features/home/data/models/match_model.dart';
import '../features/news/data/models/news_model.dart';
import '../features/league/data/models/standing_model.dart';

class MockDataService {
  static final _random = Random();

  // Demonstration data only — every team and competition below is fictional.
  // Names, cities, stadiums and founding years are entirely invented for the
  // sample experience. Remote logos are intentionally not used so screenshots
  // never display third-party imagery.

  static final List<Map<String, dynamic>> _leagues = [
    {'id': 39, 'name': 'Top Lg', 'country': 'Northland', 'logo': null, 'flag': null, 'season': 2025, 'type': 'League'},
    {'id': 140, 'name': 'Iberia Lg', 'country': 'Iberia', 'logo': null, 'flag': null, 'season': 2025, 'type': 'League'},
    {'id': 61, 'name': 'Coastal Lg', 'country': 'Lumière', 'logo': null, 'flag': null, 'season': 2025, 'type': 'League'},
    {'id': 78, 'name': 'Bundle Lg', 'country': 'Eisenland', 'logo': null, 'flag': null, 'season': 2025, 'type': 'League'},
    {'id': 135, 'name': 'Adriatic Lg', 'country': 'Solaria', 'logo': null, 'flag': null, 'season': 2025, 'type': 'League'},
    {'id': 203, 'name': 'Bosporus Lg', 'country': 'Anatoria', 'logo': null, 'flag': null, 'season': 2025, 'type': 'League'},
    {'id': 2, 'name': 'Cont. Trophy', 'country': 'Continental', 'logo': null, 'flag': null, 'season': 2025, 'type': 'Cup'},
    {'id': 3, 'name': 'Series Cup', 'country': 'Continental', 'logo': null, 'flag': null, 'season': 2025, 'type': 'Cup'},
  ];

  static final List<Map<String, dynamic>> _teams = [
    {'id': 33, 'name': 'Helix', 'logo': null, 'country': 'Northland', 'stadium': 'Northgate Park', 'founded': '1902', 'venue_capacity': 48500},
    {'id': 50, 'name': 'Atlas', 'logo': null, 'country': 'Northland', 'stadium': 'Riverside Arena', 'founded': '1899', 'venue_capacity': 52000},
    {'id': 40, 'name': 'Vega', 'logo': null, 'country': 'Northland', 'stadium': 'Harborlight Stadium', 'founded': '1894', 'venue_capacity': 47000},
    {'id': 49, 'name': 'Nova', 'logo': null, 'country': 'Northland', 'stadium': 'Crown Field', 'founded': '1905', 'venue_capacity': 39800},
    {'id': 66, 'name': 'Orion', 'logo': null, 'country': 'Northland', 'stadium': 'Highbridge Park', 'founded': '1888', 'venue_capacity': 35200},
    {'id': 47, 'name': 'Lyra', 'logo': null, 'country': 'Northland', 'stadium': 'Westgate Stadium', 'founded': '1882', 'venue_capacity': 56400},
    {'id': 157, 'name': 'Solis', 'logo': null, 'country': 'Iberia', 'stadium': 'Solar Plaza', 'founded': '1903', 'venue_capacity': 78000},
    {'id': 541, 'name': 'Mira', 'logo': null, 'country': 'Iberia', 'stadium': 'Coastal Field', 'founded': '1899', 'venue_capacity': 82000},
    {'id': 85, 'name': 'Nyx', 'logo': null, 'country': 'Lumière', 'stadium': 'Lumière Arena', 'founded': '1971', 'venue_capacity': 46000},
    {'id': 165, 'name': 'Polar', 'logo': null, 'country': 'Eisenland', 'stadium': 'Capital Stadium', 'founded': '1901', 'venue_capacity': 71000},
    {'id': 109, 'name': 'Cygnus', 'logo': null, 'country': 'Solaria', 'stadium': 'Old Boys Field', 'founded': '1898', 'venue_capacity': 41500},
    {'id': 80, 'name': 'Aris', 'logo': null, 'country': 'Solaria', 'stadium': 'Wolves Den', 'founded': '1908', 'venue_capacity': 73000},
    {'id': 645, 'name': 'Hawks', 'logo': null, 'country': 'Anatoria', 'stadium': 'Hawk Park', 'founded': '1907', 'venue_capacity': 47200},
    {'id': 611, 'name': 'Drake', 'logo': null, 'country': 'Anatoria', 'stadium': 'Lion Arena', 'founded': '1905', 'venue_capacity': 52800},
    {'id': 644, 'name': 'Raven', 'logo': null, 'country': 'Anatoria', 'stadium': 'Eagle Park', 'founded': '1903', 'venue_capacity': 43300},
  ];

  static List<LeagueModel> getLeagues() {
    return _leagues.map((l) => LeagueModel.fromJson(l)).toList();
  }

  static LeagueModel? getLeagueById(int id) {
    try {
      final league = _leagues.firstWhere((l) => l['id'] == id);
      return LeagueModel.fromJson(league);
    } catch (_) {
      return null;
    }
  }

  static List<TeamModel> getTeams() {
    return _teams.map((t) => TeamModel.fromJson(t)).toList();
  }

  static TeamModel? getTeamById(int id) {
    try {
      final team = _teams.firstWhere((t) => t['id'] == id);
      return TeamModel.fromJson(team);
    } catch (_) {
      return null;
    }
  }

  static List<TeamModel> searchTeams(String query) {
    final lowerQuery = query.toLowerCase();
    return _teams
        .where((t) => (t['name'] as String).toLowerCase().contains(lowerQuery))
        .map((t) => TeamModel.fromJson(t))
        .toList();
  }

  static List<MatchModel> getTodaysMatches() {
    return _generateMatches(10, MatchStatus.live);
  }

  static List<MatchModel> getLiveMatches() {
    return _generateMatches(8, MatchStatus.live);
  }

  static List<MatchModel> getUpcomingMatches() {
    return _generateMatches(12, MatchStatus.scheduled);
  }

  static List<MatchModel> getFinishedMatches() {
    return _generateMatches(6, MatchStatus.finished);
  }

  static List<MatchModel> _generateMatches(int count, MatchStatus status) {
    final matches = <MatchModel>[];
    final leagues = getLeagues();

    for (int i = 0; i < count; i++) {
      final homeIndex = _random.nextInt(_teams.length);
      var awayIndex = _random.nextInt(_teams.length);
      while (awayIndex == homeIndex) {
        awayIndex = _random.nextInt(_teams.length);
      }

      final homeTeam = TeamModel.fromJson(_teams[homeIndex]);
      final awayTeam = TeamModel.fromJson(_teams[awayIndex]);
      final league = leagues[_random.nextInt(leagues.length)];

      int homeGoals = 0;
      int awayGoals = 0;
      String? elapsed;

      if (status == MatchStatus.live) {
        homeGoals = _random.nextInt(4);
        awayGoals = _random.nextInt(4);
        elapsed = '${45 + _random.nextInt(46)}';
      } else if (status == MatchStatus.finished) {
        homeGoals = _random.nextInt(5);
        awayGoals = _random.nextInt(5);
      }

      matches.add(MatchModel(
        id: 1000 + i,
        league: league,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        status: status,
        elapsed: elapsed,
        date: DateTime.now().toIso8601String().split('T')[0],
        time: '${21 + _random.nextInt(3)}:00',
        venue: homeTeam.stadium,
        referee: _getRandomReferee(),
      ));
    }

    return matches;
  }

  static String _getRandomReferee() {
    final referees = [
      'Michael Oliver', 'Anthony Taylor', 'Simon Marciniak', 'Daniele Orsato',
      'Björn Kuipers', 'Antonio Mateu Lahoz', 'Daniele Orsato', 'Clément Turpin',
    ];
    return referees[_random.nextInt(referees.length)];
  }

  static MatchModel getMatchDetails(int matchId) {
    final leagues = getLeagues();
    final league = leagues[_random.nextInt(leagues.length)];
    final homeTeam = TeamModel.fromJson(_teams[0]);
    final awayTeam = TeamModel.fromJson(_teams[1]);

    return MatchModel(
      id: matchId,
      league: league,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeGoals: 2,
      awayGoals: 1,
      status: MatchStatus.live,
      elapsed: '67\'',
      date: DateTime.now().toIso8601String().split('T')[0],
      time: '21:00',
      venue: homeTeam.stadium,
      referee: 'Michael Oliver',
      homeFormation: '4-3-3',
      awayFormation: '4-2-3-1',
      events: _generateMatchEvents(),
      statistics: _generateMatchStatistics(),
      lineups: _generateLineups(homeTeam, awayTeam),
    );
  }

  static List<MatchEventModel> _generateMatchEvents() {
    return [
      MatchEventModel(id: 1, type: 'Goal', detail: 'Normal Goal', player: 'M. Holt', minute: 23, teamId: 50, teamName: 'Atlas'),
      MatchEventModel(id: 2, type: 'Goal', detail: 'Normal Goal', player: 'Lansing', minute: 34, teamId: 50, teamName: 'Atlas'),
      MatchEventModel(id: 3, type: 'Card', detail: 'Yellow Card', player: 'Kemper', minute: 40, teamId: 50, teamName: 'Atlas'),
      MatchEventModel(id: 4, type: 'Goal', detail: 'Normal Goal', player: 'Asher', minute: 56, teamId: 47, teamName: 'Lyra'),
      MatchEventModel(id: 5, type: 'subst', detail: 'Substitution', player: 'Vance', assist: 'Lansing', minute: 60, teamId: 50, teamName: 'Atlas'),
      MatchEventModel(id: 6, type: 'Card', detail: 'Red Card', player: 'Halberg', minute: 75, teamId: 47, teamName: 'Lyra'),
    ];
  }

  static MatchStatisticsModel _generateMatchStatistics() {
    return MatchStatisticsModel(statistics: [
      const StatisticItemModel(name: 'Possession', homeValue: '58', awayValue: '42'),
      const StatisticItemModel(name: 'Shots', homeValue: '14', awayValue: '8'),
      const StatisticItemModel(name: 'Shots on Target', homeValue: '6', awayValue: '3'),
      const StatisticItemModel(name: 'Corners', homeValue: '7', awayValue: '4'),
      const StatisticItemModel(name: 'Fouls', homeValue: '9', awayValue: '12'),
      const StatisticItemModel(name: 'Yellow Cards', homeValue: '1', awayValue: '0'),
      const StatisticItemModel(name: 'Red Cards', homeValue: '0', awayValue: '1'),
      const StatisticItemModel(name: 'Offsides', homeValue: '2', awayValue: '3'),
      const StatisticItemModel(name: 'Passes', homeValue: '542', awayValue: '389'),
      const StatisticItemModel(name: 'Pass Accuracy', homeValue: '89%', awayValue: '82%'),
    ]);
  }

  static List<MatchLineupModel> _generateLineups(TeamModel homeTeam, TeamModel awayTeam) {
    return [
      MatchLineupModel(
        teamId: homeTeam.id,
        teamName: homeTeam.name,
        teamLogo: homeTeam.logo,
        formation: '4-3-3',
        coachName: 'Pep Guardiola',
        startXI: _generatePlayers(11, homeTeam.id),
        substitutes: _generatePlayers(7, homeTeam.id, isSub: true),
      ),
      MatchLineupModel(
        teamId: awayTeam.id,
        teamName: awayTeam.name,
        teamLogo: awayTeam.logo,
        formation: '4-2-3-1',
        coachName: 'Mikel Arteta',
        startXI: _generatePlayers(11, awayTeam.id),
        substitutes: _generatePlayers(7, awayTeam.id, isSub: true),
      ),
    ];
  }

  static List<LineupPlayerModel> _generatePlayers(int count, int teamId, {bool isSub = false}) {
    final names = isSub
        ? ['Lyle', 'Marsh', 'Doran', 'Doku', 'Phillips', 'Gomez', 'Carson']
        : ['Vyse', 'Lyle', 'Marsh', 'Wagner', 'Ostrov', 'Kemper', 'Vance', 'Rens', 'Lansing', 'Doran', 'M. Holt'];
    
    return List.generate(count, (i) => LineupPlayerModel(
      id: teamId * 100 + i,
      name: names[i % names.length],
      number: isSub ? 20 + i : i == 0 ? 31 : 2 + i,
      position: i == 0 ? 'G' : (i <= 4 ? 'D' : (i <= 7 ? 'M' : 'F')),
    ));
  }

  static List<NewsArticleModel> getNews() {
    return [
      NewsArticleModel(
        id: '1',
        title: 'Top Cup Final: Solis vs Atlas Preview',
        description: 'The most anticipated match of the season is here. Both teams are in top form heading into the final.',
        content: 'Solis and Atlas will face off in what promises to be an epic Continental Cup final...',
        imageUrl: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800',
        source: 'Goalyn Sports',
        author: 'John Smith',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        category: 'champions_league',
        readingTime: 5,
      ),
      NewsArticleModel(
        id: '2',
        title: 'Transfer News: Top 10 Deals Expected This Summer',
        description: 'The summer transfer window is approaching and several big moves are expected.',
        content: 'As the transfer window approaches, clubs across Europe are preparing for some major signings...',
        imageUrl: 'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800',
        source: 'Transfer Daily',
        author: 'Sarah Johnson',
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
        category: 'transfers',
        readingTime: 7,
      ),
      NewsArticleModel(
        id: '3',
        title: 'Top Flight Title Race Heats Up',
        description: 'With only a few games remaining, the Top Flight title race is reaching its climax.',
        content: 'The Top Flight title race has never been more intense as Nova and Atlas battle for glory...',
        imageUrl: 'https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?w=800',
        source: 'Top Flight News',
        author: 'Mike Wilson',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        category: 'premier_league',
        readingTime: 4,
      ),
      NewsArticleModel(
        id: '4',
        title: 'Anatorian Football: Hawks Signs New Star',
        description: 'Hawks have completed a major signing that could change the course of the season.',
        content: 'In a stunning transfer move, Hawks has secured the signing of one of anatorian football\'s brightest talents...',
        imageUrl: 'https://images.unsplash.com/photo-1551958219-acbc608c6377?w=800',
        source: 'Bosporus Lg Daily',
        author: 'Ahmet Yilmaz',
        publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
        category: 'turkish_football',
        readingTime: 3,
      ),
      NewsArticleModel(
        id: '5',
        title: 'World Cup 2026: Qualification Update',
        description: 'Teams around the world are fighting for their place in the upcoming World Cup.',
        content: 'As qualification matches continue across continents, several nations are securing their spots...',
        imageUrl: 'https://images.unsplash.com/photo-1553778263-73a83bab9b0c?w=800',
        source: 'World Football',
        author: 'Carlos Mendez',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        category: 'world_football',
        readingTime: 6,
      ),
      NewsArticleModel(
        id: '6',
        title: 'Iberia Lg: Mira\'s Road to Recovery',
        description: 'After a challenging season, Mira is showing signs of resurgence.',
        content: 'Mira\'s new young squad is finding their rhythm under the new manager...',
        imageUrl: 'https://images.unsplash.com/photo-1543326727-cf6c39e8f84c?w=800',
        source: 'Iberia Lg Weekly',
        author: 'Pedro Garcia',
        publishedAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        category: 'la_liga',
        readingTime: 5,
      ),
      NewsArticleModel(
        id: '7',
        title: 'Rising Stars: Best Young Players to Watch',
        description: 'A look at the most exciting young talents making waves in European football.',
        content: 'From Spain to Germany, these young players are taking the football world by storm...',
        imageUrl: 'https://images.unsplash.com/photo-1517466787929-bc90951d0974?w=800',
        source: 'Talent Scout',
        author: 'Emma Davis',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        category: 'world_football',
        readingTime: 8,
      ),
    ];
  }

  static List<StandingModel> getStandings(int leagueId) {
    final teams = getTeams();
    final standings = <StandingModel>[];

    for (int i = 0; i < teams.length; i++) {
      final played = 20 + _random.nextInt(10);
      final won = 8 + _random.nextInt(12);
      final drawn = 2 + _random.nextInt(6);
      final lost = played - won - drawn;
      final goalsFor = 20 + _random.nextInt(40);
      final goalsAgainst = 15 + _random.nextInt(30);

      standings.add(StandingModel(
        rank: i + 1,
        teamId: teams[i].id,
        teamName: teams[i].name,
        teamLogo: teams[i].logo,
        points: won * 3 + drawn,
        played: played,
        won: won,
        drawn: drawn,
        lost: lost,
        goalsFor: goalsFor,
        goalsAgainst: goalsAgainst,
        goalDifference: goalsFor - goalsAgainst,
        form: _generateForm(),
        description: i < 4 ? 'Continental Cup' : (i < 6 ? 'Continental Series' : (i > teams.length - 3 ? 'Relegation' : null)),
      ));
    }

    standings.sort((a, b) {
      final pointsDiff = b.points.compareTo(a.points);
      if (pointsDiff != 0) return pointsDiff;
      final gdDiff = b.goalDifference.compareTo(a.goalDifference);
      if (gdDiff != 0) return gdDiff;
      return b.goalsFor.compareTo(a.goalsFor);
    });

    return standings.asMap().entries.map((e) {
      return StandingModel(
        rank: e.key + 1,
        teamId: e.value.teamId,
        teamName: e.value.teamName,
        teamLogo: e.value.teamLogo,
        points: e.value.points,
        played: e.value.played,
        won: e.value.won,
        drawn: e.value.drawn,
        lost: e.value.lost,
        goalsFor: e.value.goalsFor,
        goalsAgainst: e.value.goalsAgainst,
        goalDifference: e.value.goalDifference,
        form: e.value.form,
        description: e.key < 4 ? 'Continental Cup' : (e.key < 6 ? 'Continental Series' : (e.key > teams.length - 3 ? 'Relegation' : null)),
      );
    }).toList();
  }

  static List<LineupPlayerModel> getTeamSquad(int teamId) {
    final Map<int, List<Map<String, dynamic>>> squads = {
      33: [ // Helix
        {'name': 'André Onana', 'number': 24, 'position': 'G'},
        {'name': 'Tom Heaton', 'number': 22, 'position': 'G'},
        {'name': 'Diogo Dalot', 'number': 20, 'position': 'D'},
        {'name': 'Luke Shaw', 'number': 23, 'position': 'D'},
        {'name': 'Lisandro Martínez', 'number': 6, 'position': 'D'},
        {'name': 'Harry Maguire', 'number': 5, 'position': 'D'},
        {'name': 'Raphaël Varane', 'number': 19, 'position': 'D'},
        {'name': 'Aaron Wan-Bissaka', 'number': 29, 'position': 'D'},
        {'name': 'Bruno Fernandes', 'number': 8, 'position': 'M'},
        {'name': 'Mason Mount', 'number': 7, 'position': 'M'},
        {'name': 'Casemiro', 'number': 18, 'position': 'M'},
        {'name': 'Kobbie Mainoo', 'number': 37, 'position': 'M'},
        {'name': 'Christian Eriksen', 'number': 14, 'position': 'M'},
        {'name': 'Scott McTominay', 'number': 39, 'position': 'M'},
        {'name': 'Marcus Rashford', 'number': 10, 'position': 'F'},
        {'name': 'Rasmus Højlund', 'number': 11, 'position': 'F'},
        {'name': 'Alejandro Garnacho', 'number': 17, 'position': 'F'},
        {'name': 'Antony', 'number': 21, 'position': 'F'},
        {'name': 'Jadon Sancho', 'number': 25, 'position': 'F'},
        {'name': 'Anthony Martial', 'number': 9, 'position': 'F'},
      ],
      50: [ // Atlas
        {'name': 'Vyse', 'number': 31, 'position': 'G'},
        {'name': 'Stefan Ortega', 'number': 18, 'position': 'G'},
        {'name': 'Kyle Lyle', 'number': 2, 'position': 'D'},
        {'name': 'John Marsh', 'number': 5, 'position': 'D'},
        {'name': 'Rúben Wagner', 'number': 3, 'position': 'D'},
        {'name': 'Nathan Aké', 'number': 6, 'position': 'D'},
        {'name': 'Manuel Ostrov', 'number': 25, 'position': 'D'},
        {'name': 'Joško Gvardiol', 'number': 24, 'position': 'D'},
        {'name': 'Kemper', 'number': 16, 'position': 'M'},
        {'name': 'Kevin Vance', 'number': 17, 'position': 'M'},
        {'name': 'Bernardo Silva', 'number': 20, 'position': 'M'},
        {'name': 'İlkay Gündoğan', 'number': 8, 'position': 'M'},
        {'name': 'Mateo Kovačić', 'number': 10, 'position': 'M'},
        {'name': 'Phil Lansing', 'number': 47, 'position': 'F'},
        {'name': 'Marcus Holt', 'number': 9, 'position': 'F'},
        {'name': 'Jack Doran', 'number': 10, 'position': 'F'},
        {'name': 'Julián Álvarez', 'number': 19, 'position': 'F'},
        {'name': 'Jérémy Doku', 'number': 11, 'position': 'F'},
        {'name': 'Oscar Bobb', 'number': 52, 'position': 'F'},
        {'name': 'Rico Lewis', 'number': 82, 'position': 'D'},
      ],
      40: [ // Vega
        {'name': 'Alisson', 'number': 1, 'position': 'G'},
        {'name': 'Caoimhín Kelleher', 'number': 62, 'position': 'G'},
        {'name': 'Trent Alexander-Arnold', 'number': 66, 'position': 'D'},
        {'name': 'Andrew Robertson', 'number': 26, 'position': 'D'},
        {'name': 'Virgil van Dijk', 'number': 4, 'position': 'D'},
        {'name': 'Ibrahima Konaté', 'number': 5, 'position': 'D'},
        {'name': 'Joe Gomez', 'number': 2, 'position': 'D'},
        {'name': 'Jarell Quansah', 'number': 78, 'position': 'D'},
        {'name': 'Alexis Mac Allister', 'number': 10, 'position': 'M'},
        {'name': 'Dominik Szoboszlai', 'number': 8, 'position': 'M'},
        {'name': 'Ryan Gravenberch', 'number': 38, 'position': 'M'},
        {'name': 'Curtis Jones', 'number': 17, 'position': 'M'},
        {'name': 'Wataru Endo', 'number': 3, 'position': 'M'},
        {'name': 'Harvey Elliott', 'number': 19, 'position': 'M'},
        {'name': 'Marko Saber', 'number': 11, 'position': 'F'},
        {'name': 'Luis Díaz', 'number': 7, 'position': 'F'},
        {'name': 'Darwin Núñez', 'number': 9, 'position': 'F'},
        {'name': 'Diogo Jota', 'number': 20, 'position': 'F'},
        {'name': 'Cody Gakpo', 'number': 18, 'position': 'F'},
        {'name': 'Ben Doak', 'number': 50, 'position': 'F'},
      ],
      157: [ // Solis
        {'name': 'Thibaut Courtois', 'number': 1, 'position': 'G'},
        {'name': 'Andriy Lunin', 'number': 13, 'position': 'G'},
        {'name': 'Dani Carvajal', 'number': 2, 'position': 'D'},
        {'name': 'Ferland Mendy', 'number': 23, 'position': 'D'},
        {'name': 'Éder Militão', 'number': 3, 'position': 'D'},
        {'name': 'Antonio Rüdiger', 'number': 22, 'position': 'D'},
        {'name': 'David Alaba', 'number': 4, 'position': 'D'},
        {'name': 'Nacho', 'number': 6, 'position': 'D'},
        {'name': 'Jonas Brent', 'number': 5, 'position': 'M'},
        {'name': 'Luka Modrić', 'number': 10, 'position': 'M'},
        {'name': 'Toni Kroos', 'number': 8, 'position': 'M'},
        {'name': 'Eduardo Camavinga', 'number': 12, 'position': 'M'},
        {'name': 'Federico Valverde', 'number': 15, 'position': 'M'},
        {'name': 'Aurélien Tchouaméni', 'number': 18, 'position': 'M'},
        {'name': 'Vinícius Jr.', 'number': 7, 'position': 'F'},
        {'name': 'Rodrygo', 'number': 11, 'position': 'F'},
        {'name': 'Joselu', 'number': 14, 'position': 'F'},
        {'name': 'Brahim Díaz', 'number': 21, 'position': 'F'},
        {'name': 'Arda Güler', 'number': 24, 'position': 'F'},
        {'name': 'Lucas Vázquez', 'number': 17, 'position': 'D'},
      ],
      541: [ // Mira
        {'name': 'Marc-André ter Stegen', 'number': 1, 'position': 'G'},
        {'name': 'Iñaki Peña', 'number': 13, 'position': 'G'},
        {'name': 'Jules Koundé', 'number': 23, 'position': 'D'},
        {'name': 'Alejandro Balde', 'number': 3, 'position': 'D'},
        {'name': 'Ronald Araújo', 'number': 4, 'position': 'D'},
        {'name': 'Andreas Christensen', 'number': 15, 'position': 'D'},
        {'name': 'João Cancelo', 'number': 2, 'position': 'D'},
        {'name': 'Pau Cubarsí', 'number': 24, 'position': 'D'},
        {'name': 'Pedri', 'number': 8, 'position': 'M'},
        {'name': 'Gavi', 'number': 6, 'position': 'M'},
        {'name': 'Frenkie de Jong', 'number': 21, 'position': 'M'},
        {'name': 'Fermín López', 'number': 16, 'position': 'M'},
        {'name': 'Ilkay Gündoğan', 'number': 22, 'position': 'M'},
        {'name': 'Lamine Yamal', 'number': 19, 'position': 'F'},
        {'name': 'Roman Krieger', 'number': 9, 'position': 'F'},
        {'name': 'Raphinha', 'number': 11, 'position': 'F'},
        {'name': 'João Félix', 'number': 14, 'position': 'F'},
        {'name': 'Ferran Torres', 'number': 7, 'position': 'F'},
        {'name': 'Ansu Fati', 'number': 10, 'position': 'F'},
        {'name': 'Vitor Roque', 'number': 19, 'position': 'F'},
      ],
    };

    // Default squad for teams not in the map
    final defaultSquad = [
      {'name': 'Goalkeeper 1', 'number': 1, 'position': 'G'},
      {'name': 'Goalkeeper 2', 'number': 13, 'position': 'G'},
      {'name': 'Defender 1', 'number': 2, 'position': 'D'},
      {'name': 'Defender 2', 'number': 3, 'position': 'D'},
      {'name': 'Defender 3', 'number': 4, 'position': 'D'},
      {'name': 'Defender 4', 'number': 5, 'position': 'D'},
      {'name': 'Defender 5', 'number': 6, 'position': 'D'},
      {'name': 'Defender 6', 'number': 15, 'position': 'D'},
      {'name': 'Midfielder 1', 'number': 8, 'position': 'M'},
      {'name': 'Midfielder 2', 'number': 10, 'position': 'M'},
      {'name': 'Midfielder 3', 'number': 14, 'position': 'M'},
      {'name': 'Midfielder 4', 'number': 16, 'position': 'M'},
      {'name': 'Midfielder 5', 'number': 18, 'position': 'M'},
      {'name': 'Midfielder 6', 'number': 20, 'position': 'M'},
      {'name': 'Forward 1', 'number': 7, 'position': 'F'},
      {'name': 'Forward 2', 'number': 9, 'position': 'F'},
      {'name': 'Forward 3', 'number': 11, 'position': 'F'},
      {'name': 'Forward 4', 'number': 17, 'position': 'F'},
      {'name': 'Forward 5', 'number': 19, 'position': 'F'},
      {'name': 'Forward 6', 'number': 21, 'position': 'F'},
    ];

    final squad = squads[teamId] ?? defaultSquad;

    return squad.asMap().entries.map((entry) => LineupPlayerModel(
      id: teamId * 100 + entry.key,
      name: entry.value['name'] as String,
      number: entry.value['number'] as int,
      position: entry.value['position'] as String,
    )).toList();
  }

  static Map<String, dynamic> getTeamStats(int teamId) {
    final played = 28 + _random.nextInt(10);
    final wins = (played * (0.4 + _random.nextDouble() * 0.3)).round();
    final draws = (played * (0.1 + _random.nextDouble() * 0.15)).round();
    final losses = played - wins - draws;
    final goalsFor = wins * 2 + draws + _random.nextInt(10);
    final goalsAgainst = losses * 2 + draws + _random.nextInt(8);
    final cleanSheets = (wins * 0.4 + _random.nextInt(3)).round();
    final avgPossession = 45.0 + _random.nextDouble() * 15.0;

    return {
      'matches_played': played,
      'wins': wins,
      'draws': draws,
      'losses': losses < 0 ? 0 : losses,
      'goals_for': goalsFor,
      'goals_against': goalsAgainst,
      'clean_sheets': cleanSheets,
      'avg_possession': double.parse(avgPossession.toStringAsFixed(1)),
    };
  }

  static String getTeamForm(int teamId) {
    const results = ['W', 'W', 'W', 'D', 'L'];
    final form = List<String>.from(results)..shuffle(_random);
    return form.join();
  }

  static List<MatchModel> getLeagueMatches(int leagueId) {
    final league = getLeagueById(leagueId);
    if (league == null) return [];

    final matches = <MatchModel>[];
    final leagueTeams = _teams.where((t) {
      final country = t['country'] as String;
      switch (leagueId) {
        case 39: return country == 'England';
        case 140: return country == 'Spain';
        case 61: return country == 'France';
        case 78: return country == 'Germany';
        case 135: return country == 'Italy';
        case 203: return country == 'Turkey';
        default: return true;
      }
    }).toList();

    // If fewer than 2 teams for the league, use all teams
    final teamsToUse = leagueTeams.length >= 2 ? leagueTeams : _teams;

    final statuses = [MatchStatus.finished, MatchStatus.live, MatchStatus.scheduled];

    for (int i = 0; i < 10; i++) {
      final homeIndex = _random.nextInt(teamsToUse.length);
      var awayIndex = _random.nextInt(teamsToUse.length);
      while (awayIndex == homeIndex) {
        awayIndex = _random.nextInt(teamsToUse.length);
      }

      final homeTeam = TeamModel.fromJson(teamsToUse[homeIndex]);
      final awayTeam = TeamModel.fromJson(teamsToUse[awayIndex]);
      final status = statuses[_random.nextInt(statuses.length)];

      int homeGoals = 0;
      int awayGoals = 0;
      String? elapsed;

      if (status == MatchStatus.live) {
        homeGoals = _random.nextInt(4);
        awayGoals = _random.nextInt(4);
        elapsed = '${_random.nextInt(90) + 1}';
      } else if (status == MatchStatus.finished) {
        homeGoals = _random.nextInt(5);
        awayGoals = _random.nextInt(5);
      }

      matches.add(MatchModel(
        id: 2000 + leagueId * 100 + i,
        league: league,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        status: status,
        elapsed: elapsed,
        date: DateTime.now().subtract(Duration(days: _random.nextInt(7))).toIso8601String().split('T')[0],
        time: '${15 + _random.nextInt(8)}:${_random.nextBool() ? '00' : '30'}',
        venue: homeTeam.stadium,
        referee: _getRandomReferee(),
      ));
    }

    return matches;
  }

  static List<Map<String, dynamic>> getTopScorers(int leagueId) {
    final Map<int, List<Map<String, dynamic>>> scorersByLeague = {
      39: [ // Top Flight
        {'player': 'Marcus Holt', 'team': 'Atlas', 'team_logo': 'https://media.api-sports.io/football/teams/50.png', 'goals': 27, 'assists': 5},
        {'player': 'Marko Saber', 'team': 'Vega', 'team_logo': 'https://media.api-sports.io/football/teams/40.png', 'goals': 19, 'assists': 12},
        {'player': 'Phil Lansing', 'team': 'Atlas', 'team_logo': 'https://media.api-sports.io/football/teams/50.png', 'goals': 17, 'assists': 8},
        {'player': 'Son Heung-min', 'team': 'Lyra', 'team_logo': 'https://media.api-sports.io/football/teams/47.png', 'goals': 16, 'assists': 7},
        {'player': 'Cole Palmer', 'team': 'Nova', 'team_logo': 'https://media.api-sports.io/football/teams/49.png', 'goals': 15, 'assists': 10},
        {'player': 'Alexander Isak', 'team': 'Newcastle', 'team_logo': 'https://media.api-sports.io/football/teams/34.png', 'goals': 14, 'assists': 4},
        {'player': 'Ollie Watkins', 'team': 'Aston Villa', 'team_logo': 'https://media.api-sports.io/football/teams/66.png', 'goals': 13, 'assists': 9},
        {'player': 'Bruno Fernandes', 'team': 'Helix', 'team_logo': 'https://media.api-sports.io/football/teams/33.png', 'goals': 12, 'assists': 8},
        {'player': 'Bukayo Saka', 'team': 'Nova', 'team_logo': 'https://media.api-sports.io/football/teams/42.png', 'goals': 12, 'assists': 11},
        {'player': 'Dominic Solanke', 'team': 'Lyra', 'team_logo': 'https://media.api-sports.io/football/teams/47.png', 'goals': 11, 'assists': 3},
      ],
      140: [ // Iberia Lg
        {'player': 'Roman Krieger', 'team': 'Mira', 'team_logo': 'https://media.api-sports.io/football/teams/541.png', 'goals': 23, 'assists': 6},
        {'player': 'Jonas Brent', 'team': 'Solis', 'team_logo': 'https://media.api-sports.io/football/teams/157.png', 'goals': 19, 'assists': 7},
        {'player': 'Vinícius Jr.', 'team': 'Solis', 'team_logo': 'https://media.api-sports.io/football/teams/157.png', 'goals': 16, 'assists': 9},
        {'player': 'Lamine Yamal', 'team': 'Mira', 'team_logo': 'https://media.api-sports.io/football/teams/541.png', 'goals': 14, 'assists': 11},
        {'player': 'Antoine Griezmann', 'team': 'Atlético Madrid', 'team_logo': 'https://media.api-sports.io/football/teams/530.png', 'goals': 13, 'assists': 6},
        {'player': 'Artem Dovbyk', 'team': 'Girona', 'team_logo': 'https://media.api-sports.io/football/teams/547.png', 'goals': 12, 'assists': 4},
        {'player': 'Alexander Sørloth', 'team': 'Villarreal', 'team_logo': 'https://media.api-sports.io/football/teams/533.png', 'goals': 11, 'assists': 3},
        {'player': 'Raphinha', 'team': 'Mira', 'team_logo': 'https://media.api-sports.io/football/teams/541.png', 'goals': 10, 'assists': 8},
        {'player': 'Álvaro Morata', 'team': 'Atlético Madrid', 'team_logo': 'https://media.api-sports.io/football/teams/530.png', 'goals': 10, 'assists': 5},
        {'player': 'Rodrygo', 'team': 'Solis', 'team_logo': 'https://media.api-sports.io/football/teams/157.png', 'goals': 9, 'assists': 7},
      ],
      135: [ // Adriatic Lg
        {'player': 'Lautaro Martínez', 'team': 'Aris', 'team_logo': 'https://media.api-sports.io/football/teams/80.png', 'goals': 24, 'assists': 5},
        {'player': 'Dušan Vlahović', 'team': 'Cygnus', 'team_logo': 'https://media.api-sports.io/football/teams/109.png', 'goals': 16, 'assists': 4},
        {'player': 'Victor Osimhen', 'team': 'Napoli', 'team_logo': 'https://media.api-sports.io/football/teams/492.png', 'goals': 15, 'assists': 3},
        {'player': 'Olivier Giroud', 'team': 'AC Milan', 'team_logo': 'https://media.api-sports.io/football/teams/489.png', 'goals': 14, 'assists': 5},
        {'player': 'Marcus Thuram', 'team': 'Aris', 'team_logo': 'https://media.api-sports.io/football/teams/80.png', 'goals': 13, 'assists': 7},
        {'player': 'Paulo Dybala', 'team': 'Roma', 'team_logo': 'https://media.api-sports.io/football/teams/497.png', 'goals': 11, 'assists': 6},
        {'player': 'Ademola Lookman', 'team': 'Atalanta', 'team_logo': 'https://media.api-sports.io/football/teams/499.png', 'goals': 11, 'assists': 5},
        {'player': 'Rafael Leão', 'team': 'AC Milan', 'team_logo': 'https://media.api-sports.io/football/teams/489.png', 'goals': 10, 'assists': 9},
        {'player': 'Khvicha Kvaratskhelia', 'team': 'Napoli', 'team_logo': 'https://media.api-sports.io/football/teams/492.png', 'goals': 10, 'assists': 8},
        {'player': 'Ciro Immobile', 'team': 'Lazio', 'team_logo': 'https://media.api-sports.io/football/teams/487.png', 'goals': 9, 'assists': 4},
      ],
      78: [ // Bundle Lg
        {'player': 'Harry Kane', 'team': 'Polar', 'team_logo': 'https://media.api-sports.io/football/teams/165.png', 'goals': 30, 'assists': 9},
        {'player': 'Serhou Guirassy', 'team': 'Stuttgart', 'team_logo': 'https://media.api-sports.io/football/teams/172.png', 'goals': 22, 'assists': 4},
        {'player': 'Loïs Openda', 'team': 'RB Leipzig', 'team_logo': 'https://media.api-sports.io/football/teams/173.png', 'goals': 18, 'assists': 6},
        {'player': 'Leroy Sané', 'team': 'Polar', 'team_logo': 'https://media.api-sports.io/football/teams/165.png', 'goals': 14, 'assists': 10},
        {'player': 'Florian Wirtz', 'team': 'Bayer Leverkusen', 'team_logo': 'https://media.api-sports.io/football/teams/168.png', 'goals': 13, 'assists': 11},
        {'player': 'Niclas Füllkrug', 'team': 'Borussia Dortmund', 'team_logo': 'https://media.api-sports.io/football/teams/165.png', 'goals': 12, 'assists': 5},
        {'player': 'Thomas Müller', 'team': 'Polar', 'team_logo': 'https://media.api-sports.io/football/teams/165.png', 'goals': 11, 'assists': 8},
        {'player': 'Jamal Musiala', 'team': 'Polar', 'team_logo': 'https://media.api-sports.io/football/teams/165.png', 'goals': 10, 'assists': 7},
        {'player': 'Victor Boniface', 'team': 'Bayer Leverkusen', 'team_logo': 'https://media.api-sports.io/football/teams/168.png', 'goals': 10, 'assists': 5},
        {'player': 'Deniz Undav', 'team': 'Stuttgart', 'team_logo': 'https://media.api-sports.io/football/teams/172.png', 'goals': 9, 'assists': 6},
      ],
      61: [ // Ligue 1
        {'player': 'Kylian Mbappé', 'team': 'Nyx', 'team_logo': 'https://media.api-sports.io/football/teams/85.png', 'goals': 25, 'assists': 8},
        {'player': 'Jonathan David', 'team': 'Lille', 'team_logo': 'https://media.api-sports.io/football/teams/79.png', 'goals': 17, 'assists': 4},
        {'player': 'Alexandre Lacazette', 'team': 'Lyon', 'team_logo': 'https://media.api-sports.io/football/teams/80.png', 'goals': 15, 'assists': 5},
        {'player': 'Pierre-Emerick Aubameyang', 'team': 'Marseille', 'team_logo': 'https://media.api-sports.io/football/teams/81.png', 'goals': 14, 'assists': 3},
        {'player': 'Ousmane Dembélé', 'team': 'Nyx', 'team_logo': 'https://media.api-sports.io/football/teams/85.png', 'goals': 12, 'assists': 10},
        {'player': 'Wissam Ben Yedder', 'team': 'Monaco', 'team_logo': 'https://media.api-sports.io/football/teams/91.png', 'goals': 11, 'assists': 4},
        {'player': 'Elye Wahi', 'team': 'Lens', 'team_logo': 'https://media.api-sports.io/football/teams/116.png', 'goals': 10, 'assists': 3},
        {'player': 'Randal Kolo Muani', 'team': 'Nyx', 'team_logo': 'https://media.api-sports.io/football/teams/85.png', 'goals': 10, 'assists': 6},
        {'player': 'Terem Moffi', 'team': 'Nice', 'team_logo': 'https://media.api-sports.io/football/teams/84.png', 'goals': 9, 'assists': 2},
        {'player': 'Folarin Balogun', 'team': 'Monaco', 'team_logo': 'https://media.api-sports.io/football/teams/91.png', 'goals': 8, 'assists': 5},
      ],
      203: [ // Bosporus Lg
        {'player': 'Mauro Icardi', 'team': 'Drake', 'team_logo': 'https://media.api-sports.io/football/teams/611.png', 'goals': 22, 'assists': 5},
        {'player': 'Edin Džeko', 'team': 'Hawks', 'team_logo': 'https://media.api-sports.io/football/teams/645.png', 'goals': 18, 'assists': 7},
        {'player': 'Cenk Tosun', 'team': 'Raven', 'team_logo': 'https://media.api-sports.io/football/teams/644.png', 'goals': 14, 'assists': 3},
        {'player': 'Michy Batshuayi', 'team': 'Hawks', 'team_logo': 'https://media.api-sports.io/football/teams/645.png', 'goals': 12, 'assists': 4},
        {'player': 'Dries Mertens', 'team': 'Drake', 'team_logo': 'https://media.api-sports.io/football/teams/611.png', 'goals': 11, 'assists': 9},
        {'player': 'Fred', 'team': 'Hawks', 'team_logo': 'https://media.api-sports.io/football/teams/645.png', 'goals': 10, 'assists': 6},
        {'player': 'Wilfried Zaha', 'team': 'Drake', 'team_logo': 'https://media.api-sports.io/football/teams/611.png', 'goals': 9, 'assists': 5},
        {'player': 'Rachid Ghezzal', 'team': 'Raven', 'team_logo': 'https://media.api-sports.io/football/teams/644.png', 'goals': 8, 'assists': 7},
        {'player': 'Ciro Immobile', 'team': 'Raven', 'team_logo': 'https://media.api-sports.io/football/teams/644.png', 'goals': 8, 'assists': 3},
        {'player': 'Kerem Aktürkoğlu', 'team': 'Drake', 'team_logo': 'https://media.api-sports.io/football/teams/611.png', 'goals': 7, 'assists': 8},
      ],
    };

    // Default scorers for leagues not in the map (e.g., UCL, UEL)
    final defaultScorers = [
      {'player': 'Top Scorer 1', 'team': 'Team A', 'team_logo': '', 'goals': 10, 'assists': 4},
      {'player': 'Top Scorer 2', 'team': 'Team B', 'team_logo': '', 'goals': 8, 'assists': 6},
      {'player': 'Top Scorer 3', 'team': 'Team C', 'team_logo': '', 'goals': 7, 'assists': 3},
      {'player': 'Top Scorer 4', 'team': 'Team D', 'team_logo': '', 'goals': 6, 'assists': 5},
      {'player': 'Top Scorer 5', 'team': 'Team E', 'team_logo': '', 'goals': 5, 'assists': 2},
      {'player': 'Top Scorer 6', 'team': 'Team F', 'team_logo': '', 'goals': 5, 'assists': 4},
      {'player': 'Top Scorer 7', 'team': 'Team G', 'team_logo': '', 'goals': 4, 'assists': 3},
      {'player': 'Top Scorer 8', 'team': 'Team H', 'team_logo': '', 'goals': 4, 'assists': 1},
      {'player': 'Top Scorer 9', 'team': 'Team I', 'team_logo': '', 'goals': 3, 'assists': 5},
      {'player': 'Top Scorer 10', 'team': 'Team J', 'team_logo': '', 'goals': 3, 'assists': 2},
    ];

    return scorersByLeague[leagueId] ?? defaultScorers;
  }

  static String _generateForm() {
    const results = ['W', 'D', 'L'];
    return List.generate(5, (_) => results[_random.nextInt(3)]).join();
  }
}
