/// Helpers to render short, editorial-friendly names for teams and leagues
/// without relying on remote logo imagery.
class NameUtils {
  NameUtils._();

  // Demonstration data: every team and league is fictional and already short.
  // No mapping needed — names are 4-6 characters by design.
  static const Map<String, String> _teamShortMap = {};
  static const Map<String, String> _leagueShortMap = {};

  static String shortTeam(String? name) {
    if (name == null || name.isEmpty) return '—';
    final mapped = _teamShortMap[name];
    if (mapped != null) return mapped;

    var n = name.trim();
    n = n.replaceAll(RegExp(r'^(FC|AC|AS|SC|SV|VfL|VfB|RB)\s+'), '');
    n = n.replaceAll(RegExp(r'\s+(FC|AC|CF|SC|FK|JK|BK)$'), '');
    if (n.length <= 12) return n;
    final words = n.split(' ');
    if (words.length >= 2) {
      return '${words.first[0]}. ${words.skip(1).join(' ')}';
    }
    return '${n.substring(0, 11)}…';
  }

  static String shortLeague(String? name) {
    if (name == null || name.isEmpty) return '—';
    return _leagueShortMap[name] ?? name;
  }

  /// 2-letter monogram for a team/league name, ideal for editorial badges.
  static String monogram(String? name) {
    if (name == null || name.isEmpty) return '—';
    final cleaned = name
        .replaceAll(RegExp(r'^(FC|AC|AS|SC|SV|VfL|VfB|RB|UEFA)\s+'), '')
        .replaceAll(RegExp(r'\s+(FC|AC|CF|SC|FK|JK|BK)$'), '')
        .trim();
    final words =
        cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '—';
    if (words.length == 1) {
      return words.first.length >= 2
          ? words.first.substring(0, 2).toUpperCase()
          : words.first.toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  /// 3-letter ticker-style code for a team/league.
  static String ticker(String? name) {
    if (name == null || name.isEmpty) return '—';
    final cleaned = name
        .replaceAll(RegExp(r'^(FC|AC|AS|SC|SV|VfL|VfB|RB|UEFA)\s+'), '')
        .replaceAll(RegExp(r'\s+(FC|AC|CF|SC|FK|JK|BK)$'), '')
        .trim();
    final words =
        cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '—';
    if (words.length == 1) {
      return words.first.length >= 3
          ? words.first.substring(0, 3).toUpperCase()
          : words.first.toUpperCase();
    }
    if (words.length == 2) {
      final a = words[0];
      final b = words[1];
      return (a[0] + b.substring(0, b.length >= 2 ? 2 : 1)).toUpperCase();
    }
    return (words[0][0] + words[1][0] + words[2][0]).toUpperCase();
  }
}
