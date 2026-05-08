class NewsArticleModel {
  final String id;
  final String title;
  final String? description;
  final String? content;
  final String? imageUrl;
  final String? source;
  final String? author;
  final String? url;
  final DateTime? publishedAt;
  final String? category;
  final int? readingTime;
  final bool isSaved;

  const NewsArticleModel({
    required this.id,
    required this.title,
    this.description,
    this.content,
    this.imageUrl,
    this.source,
    this.author,
    this.url,
    this.publishedAt,
    this.category,
    this.readingTime,
    this.isSaved = false,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      content: json['content'] as String?,
      imageUrl: json['image'] as String? ?? json['image_url'] as String?,
      source: json['source']?['name'] as String? ?? json['source'] as String?,
      author: json['author'] as String?,
      url: json['url'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : json['published_at'] != null
              ? DateTime.tryParse(json['published_at'] as String)
              : null,
      category: json['category'] as String?,
      readingTime: json['reading_time'] as int?,
      isSaved: json['is_saved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'image': imageUrl,
      'source': source,
      'author': author,
      'url': url,
      'publishedAt': publishedAt?.toIso8601String(),
      'category': category,
      'reading_time': readingTime,
      'is_saved': isSaved,
    };
  }

  NewsArticleModel copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? imageUrl,
    String? source,
    String? author,
    String? url,
    DateTime? publishedAt,
    String? category,
    int? readingTime,
    bool? isSaved,
  }) {
    return NewsArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      author: author ?? this.author,
      url: url ?? this.url,
      publishedAt: publishedAt ?? this.publishedAt,
      category: category ?? this.category,
      readingTime: readingTime ?? this.readingTime,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsArticleModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
