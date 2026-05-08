class TeamModel {
  final int id;
  final String name;
  final String? logo;
  final String? country;
  final String? stadium;
  final String? stadiumImage;
  final String? founded;
  final String? venueName;
  final String? venueCity;
  final int? venueCapacity;

  const TeamModel({
    required this.id,
    required this.name,
    this.logo,
    this.country,
    this.stadium,
    this.stadiumImage,
    this.founded,
    this.venueName,
    this.venueCity,
    this.venueCapacity,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      country: json['country'] as String?,
      stadium: json['stadium'] as String?,
      stadiumImage: json['stadium_image'] as String?,
      founded: json['founded'] as String?,
      venueName: json['venue_name'] as String?,
      venueCity: json['venue_city'] as String?,
      venueCapacity: json['venue_capacity'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'country': country,
      'stadium': stadium,
      'stadium_image': stadiumImage,
      'founded': founded,
      'venue_name': venueName,
      'venue_city': venueCity,
      'venue_capacity': venueCapacity,
    };
  }

  TeamModel copyWith({
    int? id,
    String? name,
    String? logo,
    String? country,
    String? stadium,
    String? stadiumImage,
    String? founded,
    String? venueName,
    String? venueCity,
    int? venueCapacity,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      country: country ?? this.country,
      stadium: stadium ?? this.stadium,
      stadiumImage: stadiumImage ?? this.stadiumImage,
      founded: founded ?? this.founded,
      venueName: venueName ?? this.venueName,
      venueCity: venueCity ?? this.venueCity,
      venueCapacity: venueCapacity ?? this.venueCapacity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}