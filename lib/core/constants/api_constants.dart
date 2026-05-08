class ApiConstants {
  ApiConstants._();

  // API-Football Configuration
  static const String apiFootballBaseUrl = 'https://v3.football.api-sports.io';
  static const String apiFootballApiKey = '03215f5976d625a722fc58304b2b824e';

  // GNews Configuration (Free tier)
  static const String gnewsBaseUrl = 'https://gnews.io/api/v4';
  static const String gnewsApiKey = 'demo'; // User should add their key

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 20;

  // Cache Duration
  static const int cacheDurationMinutes = 5;
}
