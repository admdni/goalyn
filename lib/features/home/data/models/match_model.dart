import 'league_model.dart';
import 'team_model.dart';

enum MatchStatus {
  notStarted('TBD'),
  scheduled('NS'),
  live('1H'),
  halfTime('HT'),
  secondHalf('2H'),
  extraTime('ET'),
  penaltyShootout('P'),
  finished('FT'),
  postponed('PST'),
  cancelled('CAN'),
  suspended('SUS'),
  interrupted('INT'),
  abandoned('ABD'),
  delayed('BD');

  final String code;
  const MatchStatus(this.code);

  static MatchStatus fromCode(String? code) {
    if (code == null) return MatchStatus.scheduled;
    return MatchStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => MatchStatus.scheduled,
    );
  }

  bool get isLive =>
      this == MatchStatus.live ||
      this == MatchStatus.halfTime ||
      this == MatchStatus.secondHalf ||
      this == MatchStatus.extraTime ||
      this == MatchStatus.penaltyShootout;

  bool get isFinished => this == MatchStatus.finished;

  bool get isUpcoming =>
      this == MatchStatus.scheduled || this == MatchStatus.notStarted;

  String get displayName {
    switch (this) {
      case MatchStatus.notStarted:
        return 'TBD';
      case MatchStatus.scheduled:
        return 'Scheduled';
      case MatchStatus.live:
      case MatchStatus.secondHalf:
        return 'LIVE';
      case MatchStatus.halfTime:
        return 'HT';
      case MatchStatus.extraTime:
        return 'ET';
      case MatchStatus.penaltyShootout:
        return 'PEN';
      case MatchStatus.finished:
        return 'FT';
      case MatchStatus.postponed:
        return 'Postponed';
      case MatchStatus.cancelled:
        return 'Cancelled';
      case MatchStatus.suspended:
        return 'Suspended';
      case MatchStatus.interrupted:
        return 'Interrupted';
      case MatchStatus.abandoned:
        return 'Abandoned';
      case MatchStatus.delayed:
        return 'Delayed';
    }
  }
}

class MatchModel {
  final int id;
  final LeagueModel? league;
  final TeamModel homeTeam;
  final TeamModel awayTeam;
  final int homeGoals;
  final int awayGoals;
  final MatchStatus status;
  final String? elapsed;
  final String? date;
  final String? time;
  final String? venue;
  final String? referee;
  final List<MatchEventModel> events;
  final MatchStatisticsModel? statistics;
  final List<MatchLineupModel>? lineups;
  final String? homeFormation;
  final String? awayFormation;

  const MatchModel({
    required this.id,
    this.league,
    required this.homeTeam,
    required this.awayTeam,
    this.homeGoals = 0,
    this.awayGoals = 0,
    this.status = MatchStatus.scheduled,
    this.elapsed,
    this.date,
    this.time,
    this.venue,
    this.referee,
    this.events = const [],
    this.statistics,
    this.lineups,
    this.homeFormation,
    this.awayFormation,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as int? ?? 0,
      league: json['league'] != null
          ? LeagueModel.fromJson(json['league'] as Map<String, dynamic>)
          : null,
      homeTeam: TeamModel.fromJson(json['home_team'] as Map<String, dynamic>? ?? {}),
      awayTeam: TeamModel.fromJson(json['away_team'] as Map<String, dynamic>? ?? {}),
      homeGoals: json['home_goals'] as int? ?? 0,
      awayGoals: json['away_goals'] as int? ?? 0,
      status: MatchStatus.fromCode(json['status'] as String?),
      elapsed: json['elapsed']?.toString(),
      date: json['date'] as String?,
      time: json['time'] as String?,
      venue: json['venue'] as String?,
      referee: json['referee'] as String?,
      homeFormation: json['home_formation'] as String?,
      awayFormation: json['away_formation'] as String?,
    );
  }

  factory MatchModel.fromApiFootball(Map<String, dynamic> json) {
    return MatchModel(
      id: json['fixture']['id'] as int? ?? 0,
      league: json['league'] != null
          ? LeagueModel(
              id: json['league']['id'] as int? ?? 0,
              name: json['league']['name'] as String? ?? '',
              logo: json['league']['logo'] as String?,
              country: json['league']['country'] as String?,
              flag: json['league']['flag'] as String?,
              season: json['league']['season'] as int?,
            )
          : null,
      homeTeam: TeamModel(
        id: json['teams']['home']['id'] as int? ?? 0,
        name: json['teams']['home']['name'] as String? ?? '',
        logo: json['teams']['home']['logo'] as String?,
      ),
      awayTeam: TeamModel(
        id: json['teams']['away']['id'] as int? ?? 0,
        name: json['teams']['away']['name'] as String? ?? '',
        logo: json['teams']['away']['logo'] as String?,
      ),
      homeGoals: json['goals']['home'] as int? ?? 0,
      awayGoals: json['goals']['away'] as int? ?? 0,
      status: MatchStatus.fromCode(json['fixture']['status']['short'] as String?),
      elapsed: json['fixture']['status']['elapsed']?.toString(),
      date: json['fixture']['date'] as String?,
      venue: json['fixture']['venue']?['name'] as String?,
      referee: json['fixture']['referee'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'league': league?.toJson(),
      'home_team': homeTeam.toJson(),
      'away_team': awayTeam.toJson(),
      'home_goals': homeGoals,
      'away_goals': awayGoals,
      'status': status.code,
      'elapsed': elapsed,
      'date': date,
      'time': time,
      'venue': venue,
      'referee': referee,
      'home_formation': homeFormation,
      'away_formation': awayFormation,
    };
  }

  MatchModel copyWith({
    int? id,
    LeagueModel? league,
    TeamModel? homeTeam,
    TeamModel? awayTeam,
    int? homeGoals,
    int? awayGoals,
    MatchStatus? status,
    String? elapsed,
    String? date,
    String? time,
    String? venue,
    String? referee,
    List<MatchEventModel>? events,
    MatchStatisticsModel? statistics,
    List<MatchLineupModel>? lineups,
    String? homeFormation,
    String? awayFormation,
  }) {
    return MatchModel(
      id: id ?? this.id,
      league: league ?? this.league,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeGoals: homeGoals ?? this.homeGoals,
      awayGoals: awayGoals ?? this.awayGoals,
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      date: date ?? this.date,
      time: time ?? this.time,
      venue: venue ?? this.venue,
      referee: referee ?? this.referee,
      events: events ?? this.events,
      statistics: statistics ?? this.statistics,
      lineups: lineups ?? this.lineups,
      homeFormation: homeFormation ?? this.homeFormation,
      awayFormation: awayFormation ?? this.awayFormation,
    );
  }

  String get scoreDisplay => '$homeGoals - $awayGoals';

  String get statusDisplay => status.displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MatchEventModel {
  final int id;
  final String type;
  final String? detail;
  final String? player;
  final String? assist;
  final int? minute;
  final int? teamId;
  final String? teamName;

  const MatchEventModel({
    required this.id,
    required this.type,
    this.detail,
    this.player,
    this.assist,
    this.minute,
    this.teamId,
    this.teamName,
  });

  factory MatchEventModel.fromJson(Map<String, dynamic> json) {
    return MatchEventModel(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      detail: json['detail'] as String?,
      player: json['player']?['name'] as String?,
      assist: json['assist']?['name'] as String?,
      minute: json['time']?['elapsed'] as int?,
      teamId: json['team']?['id'] as int?,
      teamName: json['team']?['name'] as String?,
    );
  }

  bool get isGoal => type == 'Goal';
  bool get isYellowCard => type == 'Card' && detail == 'Yellow Card';
  bool get isRedCard => type == 'Card' && detail == 'Red Card';
  bool get isSubstitution => type == 'subst';
  bool get isOwnGoal => detail == 'Own Goal';
  bool get isPenalty => detail == 'Penalty';
  bool get isMissedPenalty => detail == 'Missed Penalty';
  bool get isVar => type == 'Var';
}

class MatchStatisticsModel {
  final List<StatisticItemModel> statistics;

  const MatchStatisticsModel({this.statistics = const []});

  factory MatchStatisticsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MatchStatisticsModel();
    final stats = (json['statistics'] as List<dynamic>?)
            ?.map((e) => StatisticItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return MatchStatisticsModel(statistics: stats);
  }

  factory MatchStatisticsModel.fromApiFootball(List<dynamic> jsonList) {
    final stats = jsonList
        .map((e) => StatisticItemModel.fromApiFootball(e as Map<String, dynamic>))
        .toList();
    return MatchStatisticsModel(statistics: stats);
  }

  StatisticItemModel? getStatistic(String name) {
    try {
      return statistics.firstWhere((s) => s.name == name);
    } catch (_) {
      return null;
    }
  }
}

class StatisticItemModel {
  final String name;
  final String? homeValue;
  final String? awayValue;

  const StatisticItemModel({
    required this.name,
    this.homeValue,
    this.awayValue,
  });

  factory StatisticItemModel.fromJson(Map<String, dynamic> json) {
    return StatisticItemModel(
      name: json['name'] as String? ?? '',
      homeValue: json['home']?.toString(),
      awayValue: json['away']?.toString(),
    );
  }

  factory StatisticItemModel.fromApiFootball(Map<String, dynamic> json) {
    return StatisticItemModel(
      name: json['type'] as String? ?? '',
      homeValue: json['home']?.toString(),
      awayValue: json['away']?.toString(),
    );
  }
}

class MatchLineupModel {
  final int teamId;
  final String teamName;
  final String? teamLogo;
  final String? formation;
  final String? coachName;
  final List<LineupPlayerModel> startXI;
  final List<LineupPlayerModel> substitutes;

  const MatchLineupModel({
    required this.teamId,
    required this.teamName,
    this.teamLogo,
    this.formation,
    this.coachName,
    this.startXI = const [],
    this.substitutes = const [],
  });

  factory MatchLineupModel.fromJson(Map<String, dynamic> json) {
    return MatchLineupModel(
      teamId: json['team']?['id'] as int? ?? 0,
      teamName: json['team']?['name'] as String? ?? '',
      teamLogo: json['team']?['logo'] as String?,
      formation: json['formation'] as String?,
      coachName: json['coach']?['name'] as String?,
      startXI: (json['startXI'] as List<dynamic>?)
              ?.map((e) => LineupPlayerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      substitutes: (json['substitutes'] as List<dynamic>?)
              ?.map((e) => LineupPlayerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LineupPlayerModel {
  final int id;
  final String name;
  final int? number;
  final String? position;
  final String? photo;

  const LineupPlayerModel({
    required this.id,
    required this.name,
    this.number,
    this.position,
    this.photo,
  });

  factory LineupPlayerModel.fromJson(Map<String, dynamic> json) {
    return LineupPlayerModel(
      id: json['player']?['id'] as int? ?? 0,
      name: json['player']?['name'] as String? ?? '',
      number: json['player']?['number'] as int?,
      position: json['player']?['pos'] as String?,
      photo: json['player']?['photo'] as String?,
    );
  }
}