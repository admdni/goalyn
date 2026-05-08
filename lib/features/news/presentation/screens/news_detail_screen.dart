import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/editorial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/providers/match_providers.dart';
import '../../data/models/news_model.dart';

class NewsDetailScreen extends ConsumerStatefulWidget {
  final String articleId;

  const NewsDetailScreen({super.key, required this.articleId});

  @override
  ConsumerState<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends ConsumerState<NewsDetailScreen> {
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final articles = ref.watch(newsProvider).valueOrNull ?? <NewsArticleModel>[];
    final NewsArticleModel? article = articles.isEmpty
        ? null
        : articles.cast<NewsArticleModel>().firstWhere(
              (a) => a.id == widget.articleId,
              orElse: () => articles.first,
            );

    if (article == null) {
      return Scaffold(
        backgroundColor: p.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(article.source ?? 'Goalyn'),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 60),
                children: [
                  _buildHeader(article),
                  _buildBody(article),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(String source) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: p.line, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: p.textPrimary, size: 20),
          ),
          Expanded(
            child: Text(
              source.toUpperCase(),
              style: AppType.eyebrow(
                size: 10,
                color: p.textSecondary,
                letterSpacing: 1.6,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _isSaved = !_isSaved),
            icon: Icon(
              _isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: _isSaved ? p.accent : p.textPrimary,
              size: 20,
            ),
          ),
          IconButton(
            onPressed: () => Share.share('Read on Goalyn'),
            icon: Icon(Icons.ios_share_rounded,
                color: p.textPrimary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(NewsArticleModel article) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.category != null)
            InkChip(
              label: article.category!.replaceAll('_', ' '),
              color: p.accent,
            ),
          const SizedBox(height: 16),
          Text(
            article.title,
            style: AppType.display(
              size: 32,
              color: p.textPrimary,
              style: FontStyle.italic,
              letterSpacing: -0.5,
              height: 1.05,
            ),
          ),
          if (article.description != null) ...[
            const SizedBox(height: 12),
            Text(
              article.description!,
              style: AppType.serif(
                size: 17,
                color: p.textSecondary,
                style: FontStyle.italic,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Container(height: 0.5, color: p.line),
          const SizedBox(height: 14),
          Row(
            children: [
              if (article.author != null)
                Expanded(
                  child: Text(
                    'By ${article.author}'.toUpperCase(),
                    style: AppType.eyebrow(
                      size: 10,
                      color: p.textPrimary,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              if (article.publishedAt != null)
                Text(
                  DateFormat('d MMM y').format(article.publishedAt!).toUpperCase(),
                  style: AppType.eyebrow(
                    size: 10,
                    color: p.textTertiary,
                    letterSpacing: 1.4,
                  ),
                ),
              if (article.readingTime != null) ...[
                const SizedBox(width: 8),
                Text(
                  '${article.readingTime} MIN',
                  style: AppType.mono(
                    size: 11,
                    color: p.textTertiary,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(NewsArticleModel article) {
    final p = context.palette;
    final String body = article.content ??
        article.description ??
        'Full article available on the source.';
    final paragraphs =
        body.split('\n').where((s) => s.trim().isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < paragraphs.length; i++) ...[
            if (i == 0)
              _buildDropCap(paragraphs[i])
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  paragraphs[i],
                  style: AppType.serif(
                    size: 16,
                    color: p.textPrimary,
                    height: 1.55,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 28),
          Container(height: 0.5, color: p.line),
          const SizedBox(height: 14),
          Text(
            '— END',
            style: AppType.eyebrow(
              size: 10,
              color: p.textTertiary,
              letterSpacing: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropCap(String first) {
    final p = context.palette;
    if (first.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: first.characters.first,
              style: AppType.display(
                size: 56,
                color: p.accent,
                weight: FontWeight.w400,
                height: 0.9,
              ),
            ),
            TextSpan(
              text: first.substring(first.characters.first.length),
              style: AppType.serif(
                size: 16,
                color: p.textPrimary,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
