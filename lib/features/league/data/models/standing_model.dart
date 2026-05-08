class StandingModel {
  final int rank;
  final int teamId;
  final String teamName;
  final String? teamLogo;
  final int points;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final String? form;
  final String? description;

  const StandingModel({
    required this.rank,
    required this.teamId,
    required this.teamName,
    this.teamLogo,
    this.points = 0,
    this.played = 0,
    this.won = 0,
    this.drawn = 0,
    this.lost = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.goalDifference = 0,
    this.form,
    this.description,
  });

  factory StandingModel.fromJson(Map<String, dynamic> json) {
    return StandingModel(
      rank: json['rank'] as int? ?? 0,
      teamId: json['team']?['id'] as int? ?? 0,
      teamName: json['team']?['name'] as String? ?? '',
      teamLogo: json['team']?['logo'] as String?,
      points: json['points'] as int? ?? 0,
      played: json['all']?['played'] as int? ?? json['played'] as int? ?? 0,
      won: json['all']?['win'] as int? ?? json['won'] as int? ?? 0,
      drawn: json['all']?['draw'] as int? ?? json['drawn'] as int? ?? 0,
      lost: json['all']?['lose'] as int? ?? json['lost'] as int? ?? 0,
      goalsFor: json['all']?['goals']?['for'] as int? ?? json['goals_for'] as int? ?? 0,
      goalsAgainst: json['all']?['goals']?['against'] as int? ?? json['goals_against'] as int? ?? 0,
      goalDifference: json['goal_diff'] as int? ?? 0,
      form: json['form'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'team_id': teamId,
      'team_name': teamName,
      'team_logo': teamLogo,
      'points': points,
      'played': played,
      'won': won,
      'drawn': drawn,
      'lost': lost,
      'goals_for': goalsFor,
      'goals_against': goalsAgainst,
      'goal_diff': goalDifference,
      'form': form,
      'description': description,
    };
  }

  String get playedDisplay => '$played';
  String get recordDisplay => '$won-$drawn-$lost';
  String get goalsDisplay => '$goalsFor:$goalsAgainst';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StandingModel && runtimeType == other.runtimeType && teamId == other.teamId;

  @override
  int get hashCode => teamId.hashCode;
}