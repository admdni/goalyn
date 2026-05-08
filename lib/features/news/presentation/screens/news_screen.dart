import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/editorial.dart';
import '../../../home/presentation/providers/match_providers.dart';
import '../../data/models/news_model.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  String _category = 'all';

  Future<void> _onRefresh() async {
    ref.invalidate(newsProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final all = ref.watch(newsProvider).valueOrNull ?? <NewsArticleModel>[];
    final filtered = _category == 'all'
        ? all
        : all
            .where((a) => (a.category ?? '').toLowerCase() == _category)
            .toList();

    final lead = filtered.isNotEmpty ? filtered.first : null;
    final rest =
        filtered.length > 1 ? filtered.skip(1).toList() : <NewsArticleModel>[];

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            _buildMasthead(filtered.length),
            _buildCategories(),
            if (lead != null) _buildLead(lead),
            const SizedBox(height: 12),
            for (int i = 0; i < rest.length; i++) ...[
              _buildArticleRow(rest[i]),
              if (i < rest.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(height: 0.5, color: p.line),
                ),
            ],
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildMasthead(int count) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Eyebrow(context.tr('front_page'), color: p.textPrimary),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 0.5, color: p.line)),
              const SizedBox(width: 10),
              Text(
                DateFormat('d MMM').format(DateTime.now()).toUpperCase(),
                style: AppType.eyebrow(
                    size: 10, color: p.textTertiary, letterSpacing: 1.4),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DisplayText(
            context.tr('the_wire'),
            size: 42,
            style: FontStyle.italic,
            color: p.textPrimary,
          ),
          const SizedBox(height: 6),
          DeckText(
            '$count ${context.tr('stories_curated')}',
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final p = context.palette;
    final cats = [
      ('all', context.tr('all')),
      ('transfers', context.tr('transfers')),
      ('premier_league', context.tr('epl')),
      ('champions_league', context.tr('ucl')),
      ('world_football', context.tr('world')),
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: p.line, width: 0.5),
          bottom: BorderSide(color: p.line, width: 0.5),
        ),
      ),
      child: SizedBox(
        height: 46,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: cats.length,
          itemBuilder: (ctx, i) {
            final c = cats[i];
            final selected = _category == c.$1;
            return GestureDetector(
              onTap: () => setState(() => _category = c.$1),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? p.ink : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  c.$2.toUpperCase(),
                  style: AppType.eyebrow(
                    size: 11,
                    color: selected ? p.textPrimary : p.textTertiary,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLead(NewsArticleModel article) {
    final p = context.palette;
    return GestureDetector(
      onTap: () => context.push('/news/${article.id}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkChip(label: context.tr('lead_story'), color: p.accent, filled: true),
                const SizedBox(width: 8),
                if (article.category != null)
                  Text(
                    article.category!.replaceAll('_', ' ').toUpperCase(),
                    style: AppType.eyebrow(
                      size: 10,
                      color: p.textTertiary,
                      letterSpacing: 1.4,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              article.title,
              style: AppType.display(
                size: 30,
                color: p.textPrimary,
                style: FontStyle.italic,
                letterSpacing: -0.5,
                height: 1.05,
              ),
            ),
            if (article.description != null) ...[
              const SizedBox(height: 10),
              Text(
                article.description!,
                style: AppType.serif(
                  size: 15,
                  color: p.textSecondary,
                  height: 1.45,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (article.author != null)
                  Text(
                    'By ${article.author}',
                    style: AppType.serif(
                      size: 12,
                      color: p.textTertiary,
                      style: FontStyle.italic,
                    ),
                  ),
                const Spacer(),
                if (article.readingTime != null)
                  Text(
                    '${article.readingTime} ${context.tr('min_read_label')}',
                    style: AppType.eyebrow(
                      size: 10,
                      color: p.textTertiary,
                      letterSpacing: 1.4,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleRow(NewsArticleModel article) {
    final p = context.palette;
    return InkWell(
      onTap: () => context.push('/news/${article.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.category != null)
              Text(
                article.category!.replaceAll('_', ' ').toUpperCase(),
                style: AppType.eyebrow(
                  size: 9,
                  color: p.accent,
                  letterSpacing: 1.4,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              article.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppType.serif(
                size: 18,
                color: p.textPrimary,
                weight: FontWeight.w400,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (article.source != null)
                  Text(
                    article.source!,
                    style: AppType.sans(
                      size: 11,
                      color: p.textTertiary,
                      weight: FontWeight.w500,
                    ),
                  ),
                const Spacer(),
                if (article.readingTime != null)
                  Text(
                    '${article.readingTime}min',
                    style: AppType.mono(
                      size: 11,
                      color: p.textTertiary,
                      weight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
