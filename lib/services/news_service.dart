import 'package:dio/dio.dart';
import 'package:xml/xml.dart';
import '../features/news/data/models/news_model.dart';

class NewsService {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  static const _categoriesEn = {
    'all': 'football soccer',
    'transfers': 'football transfer news',
    'premier_league': 'Premier League',
    'champions_league': 'Champions League UEFA',
    'la_liga': 'La Liga Spain football',
    'turkish_football': 'Süper Lig Turkish football',
    'world_football': 'FIFA World Cup football',
  };

  static const _categoriesZh = {
    'all': '足球 比赛',
    'transfers': '足球 转会 新闻',
    'premier_league': '英超联赛',
    'champions_league': '欧冠联赛 UEFA',
    'la_liga': '西甲联赛',
    'turkish_football': '土耳其足球 超级联赛',
    'world_football': '世界杯 FIFA 足球',
  };

  static const _localeConfig = {
    'en': {'hl': 'en', 'gl': 'US', 'ceid': 'US:en'},
    'zh': {'hl': 'zh-CN', 'gl': 'CN', 'ceid': 'CN:zh-Hans'},
  };

  static Future<List<NewsArticleModel>> fetchNews({String category = 'all', String lang = 'en'}) async {
    try {
      final categories = lang == 'zh' ? _categoriesZh : _categoriesEn;
      final config = _localeConfig[lang] ?? _localeConfig['en']!;
      final query = categories[category] ?? categories['all']!;
      final encoded = Uri.encodeComponent(query);
      final url = 'https://news.google.com/rss/search?q=$encoded&hl=${config['hl']}&gl=${config['gl']}&ceid=${config['ceid']}';

      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.plain),
      );

      final document = XmlDocument.parse(response.data as String);
      final items = document.findAllElements('item');

      final articles = <NewsArticleModel>[];
      int index = 0;

      for (final item in items) {
        if (index >= 20) break;

        final title = item.getElement('title')?.innerText ?? '';
        final link = item.getElement('link')?.innerText;
        final pubDate = item.getElement('pubDate')?.innerText;
        final source = item.getElement('source')?.innerText;
        final description = item.getElement('description')?.innerText ?? '';

        // Extract image from description HTML if present
        String? imageUrl;
        final imgMatch = RegExp(r'src="([^"]+)"').firstMatch(description);
        if (imgMatch != null) {
          imageUrl = imgMatch.group(1);
        }

        // Clean HTML from description
        final cleanDescription = description
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&quot;', '"')
            .replaceAll('&#39;', "'")
            .trim();

        DateTime? publishedAt;
        if (pubDate != null) {
          try {
            publishedAt = _parseRssDate(pubDate);
          } catch (_) {}
        }

        // Estimate reading time
        final wordCount = cleanDescription.split(RegExp(r'\s+')).length;
        final readingTime = (wordCount / 200).ceil().clamp(2, 10);

        articles.add(NewsArticleModel(
          id: '${index}_${title.hashCode}',
          title: title,
          description: cleanDescription.isNotEmpty ? cleanDescription : null,
          content: cleanDescription,
          imageUrl: imageUrl,
          source: source,
          url: link,
          publishedAt: publishedAt,
          category: category == 'all' ? _guessCategory(title) : category,
          readingTime: readingTime,
        ));

        index++;
      }

      return articles;
    } catch (e) {
      return [];
    }
  }

  static String _guessCategory(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('transfer') || lower.contains('sign') || lower.contains('deal')) return 'transfers';
    if (lower.contains('premier league') || lower.contains('epl')) return 'premier_league';
    if (lower.contains('champions league') || lower.contains('ucl')) return 'champions_league';
    if (lower.contains('la liga') || lower.contains('barcelona') || lower.contains('real madrid')) return 'la_liga';
    if (lower.contains('süper lig') || lower.contains('galatasaray') || lower.contains('fenerbah')) return 'turkish_football';
    if (lower.contains('world cup') || lower.contains('fifa')) return 'world_football';
    return 'world_football';
  }

  static DateTime _parseRssDate(String dateStr) {
    // RSS date format: "Thu, 08 May 2026 14:30:00 GMT"
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };

    final parts = dateStr.split(' ');
    if (parts.length >= 5) {
      final day = int.tryParse(parts[1]) ?? 1;
      final month = months[parts[2]] ?? 1;
      final year = int.tryParse(parts[3]) ?? 2026;
      final timeParts = parts[4].split(':');
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;
      return DateTime.utc(year, month, day, hour, minute);
    }

    return DateTime.now();
  }
}
