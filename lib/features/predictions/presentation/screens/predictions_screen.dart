import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/editorial.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../services/predictions_service.dart';
import '../../../home/data/models/match_model.dart';
import '../../../home/presentation/providers/match_providers.dart';

class PredictionsScreen extends ConsumerStatefulWidget {
  const PredictionsScreen({super.key});

  @override
  ConsumerState<PredictionsScreen> createState() =>
      _PredictionsScreenState();
}

class _PredictionsScreenState extends ConsumerState<PredictionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(predictionStatsProvider);
    final predictions = ref.watch(predictionsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildEditorialHeader(stats),
            _buildEditorialTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUpcomingTab(),
                  _buildPicksTab(predictions),
                  _buildHistoryTab(predictions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorialHeader(PredictionStats stats) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(width: 8),
              Text(
                'No. 02 — THE DESK',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              TagChip(
                label: stats.rank,
                color: AppColors.primary,
                icon: Icons.workspace_premium_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 2, color: AppColors.textPrimary),
          const SizedBox(height: 14),
          EditorialHeadline(context.tr('predictions'), fontSize: 44),
          const SizedBox(height: 6),
          EditorialDeck(
              context.tr('predictions_deck')),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              EditorialFigure(
                value: '${stats.points}',
                label: context.tr('points'),
                color: AppColors.primary,
                valueSize: 64,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _editorialMetric(context.tr('accuracy'),
                        '${stats.accuracy.toStringAsFixed(0)}%'),
                    _editorialMetric(
                        context.tr('exact'), '${stats.exactRate.toStringAsFixed(0)}%'),
                    _editorialMetric(
                        context.tr('best_run'), '${stats.bestStreak}'),
                    _editorialMetric(
                        context.tr('streak'), '${stats.currentStreak}'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _editorialMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 0.5,
              color: AppColors.cardBorder,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorialTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.primary, width: 2.5),
          ),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        dividerColor: Colors.transparent,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: const TextStyle(
          fontSize: 12,
          letterSpacing: 1.6,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          letterSpacing: 1.6,
          fontWeight: FontWeight.w700,
        ),
        tabs: [
          Tab(text: context.tr('upcoming').toUpperCase()),
          Tab(text: context.tr('my_picks').toUpperCase()),
          Tab(text: context.tr('history').toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab() {
    final upcoming = ref.watch(upcomingMatchesProvider).valueOrNull ?? <MatchModel>[];
    if (upcoming.isEmpty) {
      return EmptyStateView(
        icon: Icons.event_outlined,
        title: context.tr('no_matches_predict'),
        subtitle: context.tr('check_back_fixtures'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: upcoming.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final match = upcoming[index];
        final existing =
            ref.watch(predictionsProvider.notifier).forMatch(match.id);
        return _buildPredictableMatchCard(match, existing);
      },
    );
  }

  Widget _buildPicksTab(List<PredictionEntry> predictions) {
    final pending = predictions.where((p) => !p.isResolved).toList();
    if (pending.isEmpty) {
      return EmptyStateView(
        icon: Icons.psychology_outlined,
        title: context.tr('no_active_picks'),
        subtitle: context.tr('make_prediction_hint'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: pending.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) =>
          _buildPredictionCard(pending[index]),
    );
  }

  Widget _buildHistoryTab(List<PredictionEntry> predictions) {
    final history = predictions.where((p) => p.isResolved).toList();
    if (history.isEmpty) {
      return EmptyStateView(
        icon: Icons.history_rounded,
        title: context.tr('no_history_yet'),
        subtitle: context.tr('resolve_hint'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) =>
          _buildPredictionCard(history[index]),
    );
  }

  Widget _buildPredictableMatchCard(
      MatchModel match, PredictionEntry? existing) {
    return GestureDetector(
      onTap: () => _openPredictionSheet(match, existing),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: existing != null
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.cardBorder,
            width: 0.6,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (match.league != null)
                    Text(
                      match.league!.name,
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${match.homeTeam.name} vs ${match.awayTeam.name}',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    match.time ?? context.tr('scheduled'),
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: existing != null
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                existing != null
                    ? '${existing.predictedHome}-${existing.predictedAway}'
                    : context.tr('predict'),
                style: AppTypography.labelMedium.copyWith(
                  color: existing != null
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(PredictionEntry p) {
    Color borderColor = AppColors.cardBorder;
    Widget result;
    if (p.isResolved) {
      if (p.isExactMatch) {
        borderColor = AppColors.primary;
        result = const _ResultBadge(
            text: 'EXACT +3', color: AppColors.primary);
      } else if (p.isOutcomeCorrect) {
        borderColor = AppColors.warning;
        result = const _ResultBadge(
            text: 'OUTCOME +1', color: AppColors.warning);
      } else {
        borderColor = AppColors.error.withOpacity(0.4);
        result =
            const _ResultBadge(text: 'MISS 0', color: AppColors.error);
      }
    } else {
      result = const _ResultBadge(
          text: 'PENDING', color: AppColors.info);
    }

    return Dismissible(
      key: ValueKey('pred_${p.matchId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      onDismissed: (_) {
        HapticFeedback.lightImpact();
        ref.read(predictionsProvider.notifier).remove(p.matchId);
      },
      child: GestureDetector(
        onTap: () => _openPickActionSheet(p),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 0.6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${p.homeTeam} vs ${p.awayTeam}',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  result,
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildScoreBlock(context.tr('predicted'),
                      '${p.predictedHome}-${p.predictedAway}',
                      AppColors.info),
                  const SizedBox(width: 10),
                  if (p.isResolved)
                    _buildScoreBlock(
                        context.tr('actual'),
                        '${p.actualHome}-${p.actualAway}',
                        AppColors.primary)
                  else
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _openResolveSheet(p),
                        child: Text(context.tr('enter_actual_score')),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBlock(String label, String value, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPredictionSheet(
      MatchModel match, PredictionEntry? existing) async {
    int home = existing?.predictedHome ?? 1;
    int away = existing?.predictedAway ?? 1;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    ctx.tr('predict_the_score'),
                    style: AppTypography.headlineMedium
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${match.homeTeam.name} vs ${match.awayTeam.name}',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _buildScorePicker(
                          team: match.homeTeam.name,
                          value: home,
                          onChanged: (v) => setSheet(() => home = v),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildScorePicker(
                          team: match.awayTeam.name,
                          value: away,
                          onChanged: (v) => setSheet(() => away = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.info, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ctx.tr('prediction_scoring_hint'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        await ref
                            .read(predictionsProvider.notifier)
                            .upsert(
                              matchId: match.id,
                              homeTeam: match.homeTeam.name,
                              awayTeam: match.awayTeam.name,
                              predictedHome: home,
                              predictedAway: away,
                            );
                        if (mounted) Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        existing != null
                            ? ctx.tr('update_prediction')
                            : ctx.tr('save_prediction'),
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textInverse,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScorePicker({
    required String team,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            team,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall
                .copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: value <= 0 ? null : () => onChanged(value - 1),
                icon: const Icon(Icons.remove_rounded),
                color: AppColors.primary,
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: value >= 12 ? null : () => onChanged(value + 1),
                icon: const Icon(Icons.add_rounded),
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openPickActionSheet(PredictionEntry p) async {
    if (p.isResolved) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.flag_outlined,
                    color: AppColors.primary),
                title: Text(context.tr('resolve_actual')),
                onTap: () {
                  Navigator.pop(ctx);
                  _openResolveSheet(p);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: AppColors.error),
                title: Text(context.tr('remove_prediction')),
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(predictionsProvider.notifier)
                      .remove(p.matchId);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openResolveSheet(PredictionEntry p) async {
    int home = p.actualHome ?? p.predictedHome;
    int away = p.actualAway ?? p.predictedAway;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    ctx.tr('enter_actual_score'),
                    style: AppTypography.headlineMedium
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${p.homeTeam} vs ${p.awayTeam}',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildScorePicker(
                          team: p.homeTeam,
                          value: home,
                          onChanged: (v) => setSheet(() => home = v),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(':',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary)),
                      ),
                      Expanded(
                        child: _buildScorePicker(
                          team: p.awayTeam,
                          value: away,
                          onChanged: (v) => setSheet(() => away = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.heavyImpact();
                        await ref
                            .read(predictionsProvider.notifier)
                            .resolve(
                              matchId: p.matchId,
                              actualHome: home,
                              actualAway: away,
                            );
                        if (mounted) Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        ctx.tr('resolve'),
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textInverse,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _ResultBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
