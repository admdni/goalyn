class LeagueModel {
  final int id;
  final String name;
  final String? country;
  final String? logo;
  final String? flag;
  final int? season;
  final String? type;

  const LeagueModel({
    required this.id,
    required this.name,
    this.country,
    this.logo,
    this.flag,
    this.season,
    this.type,
  });

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    return LeagueModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      country: json['country'] as String?,
      logo: json['logo'] as String?,
      flag: json['flag'] as String?,
      season: json['season'] as int?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'logo': logo,
      'flag': flag,
      'season': season,
      'type': type,
    };
  }

  LeagueModel copyWith({
    int? id,
    String? name,
    String? country,
    String? logo,
    String? flag,
    int? season,
    String? type,
  }) {
    return LeagueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      logo: logo ?? this.logo,
      flag: flag ?? this.flag,
      season: season ?? this.season,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeagueModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}