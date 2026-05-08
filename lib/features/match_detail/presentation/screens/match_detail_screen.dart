import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/name_utils.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../shared/widgets/editorial.dart';
import '../../../home/presentation/providers/match_providers.dart';
import '../../../../services/predictions_service.dart';
import '../../../../services/notes_service.dart';
import '../../../../services/favorites_service.dart';
import '../../../../services/notification_service.dart';
import '../../../home/data/models/match_model.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  final int matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final matchAsync = ref.watch(matchDetailProvider(widget.matchId));

    return matchAsync.when(
      loading: () => Scaffold(
        backgroundColor: p.background,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: p.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.tr('failed_load_match'), style: TextStyle(color: p.textPrimary)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(matchDetailProvider(widget.matchId)),
                child: Text(context.tr('retry')),
              ),
            ],
          ),
        ),
      ),
      data: (match) => Scaffold(
        backgroundColor: p.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopBar(match),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: p.accent,
                  backgroundColor: p.paper,
                  child: NestedScrollView(
                    headerSliverBuilder: (ctx, _) => [
                      SliverToBoxAdapter(child: _buildHero(match)),
                      SliverToBoxAdapter(child: _buildActions(match)),
                      SliverToBoxAdapter(child: _buildTabs()),
                    ],
                    body: TabBarView(
                      controller: _tabs,
                      children: [
                        _buildOverview(match),
                        _buildStatistics(match),
                        _buildLineups(match),
                        _buildEvents(match),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(MatchModel match) {
    final p = context.palette;
    final favs = ref.watch(favoritesProvider);
    final saved = favs.matches.contains(match.id);
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: p.textPrimary, size: 20),
          ),
          Expanded(
            child: Text(
              match.league != null
                  ? NameUtils.shortLeague(match.league!.name).toUpperCase()
                  : context.tr('match_label'),
              textAlign: TextAlign.center,
              style: AppType.eyebrow(
                size: 10,
                color: p.textSecondary,
                letterSpacing: 1.6,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
                HapticFeedback.selectionClick();
                ref.read(favoritesProvider.notifier).toggleMatch(match.id);
            },
            icon: Icon(
              saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: saved ? p.accent : p.textPrimary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(MatchModel match) {
    final p = context.palette;
    final isLive = match.status.isLive;
    final hasScore = match.status != MatchStatus.scheduled;
    final home = NameUtils.shortTeam(match.homeTeam.name);
    final away = NameUtils.shortTeam(match.awayTeam.name);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isLive) ...[
                LivePulse(color: p.live, size: 6),
                const SizedBox(width: 6),
                Text("${match.elapsed ?? '·'}'  ${context.tr('in_play')}",
                    style: AppType.eyebrow(
                        size: 10, color: p.live, letterSpacing: 1.6)),
              ] else if (match.status.isFinished)
                Text(context.tr('full_time_label'),
                    style: AppType.eyebrow(
                        size: 10,
                        color: p.textSecondary,
                        letterSpacing: 1.6))
              else
                Text(
                  match.time != null
                      ? '${context.tr('kick_off')} · ${match.time}'
                      : context.tr('scheduled'),
                  style: AppType.eyebrow(
                      size: 10, color: p.textSecondary, letterSpacing: 1.6),
                ),
              const Spacer(),
              if (match.date != null)
                Text(
                  match.date!.toUpperCase(),
                  style: AppType.eyebrow(
                      size: 10, color: p.textTertiary, letterSpacing: 1.4),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(home,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppType.display(
                          size: 32,
                          color: p.textPrimary,
                          style: FontStyle.italic,
                          letterSpacing: -1,
                          height: 1.0,
                        )),
                    const SizedBox(height: 4),
                    Text(context.tr('home'),
                        style: AppType.eyebrow(
                            size: 9,
                            color: p.textTertiary,
                            letterSpacing: 1.4)),
                  ],
                ),
              ),
              if (hasScore)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${match.homeGoals}–${match.awayGoals}',
                    style: AppType.mono(
                      size: 50,
                      color: p.textPrimary,
                      weight: FontWeight.w500,
                      letterSpacing: -1.5,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'vs',
                    style: AppType.display(
                      size: 28,
                      color: p.textTertiary,
                      style: FontStyle.italic,
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(away,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppType.display(
                          size: 32,
                          color: p.textPrimary,
                          style: FontStyle.italic,
                          letterSpacing: -1,
                          height: 1.0,
                        )),
                    const SizedBox(height: 4),
                    Text(context.tr('away'),
                        style: AppType.eyebrow(
                            size: 9,
                            color: p.textTertiary,
                            letterSpacing: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          if (match.venue != null) ...[
            const SizedBox(height: 18),
            Container(height: 0.5, color: p.line),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.stadium_outlined, color: p.textTertiary, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    match.venue!,
                    style: AppType.serif(
                      size: 13,
                      color: p.textSecondary,
                      style: FontStyle.italic,
                    ),
                  ),
                ),
                if (match.referee != null)
                  Text(
                    match.referee!.toUpperCase(),
                    style: AppType.eyebrow(
                      size: 9,
                      color: p.textTertiary,
                      letterSpacing: 1.4,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(MatchModel match) {
    final p = context.palette;
    final prediction =
        ref.watch(predictionsProvider.notifier).forMatch(match.id);
    final note = ref.watch(notesProvider)[match.id];
    final reminder =
        NotificationService.instance.isReminderScheduled(match.id);
    final canPredict = match.status.isUpcoming || match.status.isLive;

    final actions = [
      _Action(
        icon: Icons.gps_fixed_rounded,
        label: prediction != null
            ? '${prediction.predictedHome}–${prediction.predictedAway}'
            : context.tr('predict_label'),
        active: prediction != null,
        enabled: canPredict || prediction != null,
        onTap: () => _openPredictionSheet(match, prediction),
      ),
      _Action(
        icon: Icons.edit_note_rounded,
        label: note != null ? context.tr('note') : context.tr('note'),
        active: note != null,
        enabled: true,
        onTap: () => _openNoteSheet(match, note?.text),
      ),
      _Action(
        icon: reminder ? Icons.alarm_on_rounded : Icons.alarm_rounded,
        label: reminder ? context.tr('reminded') : context.tr('remind'),
        active: reminder,
        enabled: match.status.isUpcoming,
        onTap: () => _toggleReminder(match, reminder),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.line, width: 0.5)),
      ),
      child: Row(
        children: actions.map((a) {
          return Expanded(
            child: InkWell(
              onTap: a.enabled ? a.onTap : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: p.line, width: 0.5),
                    bottom: BorderSide(color: p.line, width: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      a.icon,
                      size: 18,
                      color: a.active
                          ? p.accent
                          : (a.enabled ? p.textPrimary : p.textTertiary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      a.label.toUpperCase(),
                      style: AppType.eyebrow(
                        size: 9,
                        color: a.active
                            ? p.accent
                            : (a.enabled ? p.textPrimary : p.textTertiary),
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabs() {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line, width: 0.5)),
      ),
      child: TabBar(
        controller: _tabs,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: p.ink, width: 2),
          ),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        dividerColor: Colors.transparent,
        labelColor: p.textPrimary,
        unselectedLabelColor: p.textTertiary,
        labelStyle: AppType.eyebrow(size: 11, letterSpacing: 1.6),
        unselectedLabelStyle: AppType.eyebrow(size: 11, letterSpacing: 1.6),
        tabs: [
          Tab(text: context.tr('overview').toUpperCase()),
          Tab(text: context.tr('stats').toUpperCase()),
          Tab(text: context.tr('lineups').toUpperCase()),
          Tab(text: context.tr('events').toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildOverview(MatchModel match) {
    final p = context.palette;
    final prediction =
        ref.watch(predictionsProvider.notifier).forMatch(match.id);
    final note = ref.watch(notesProvider)[match.id];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
      physics: const BouncingScrollPhysics(),
      children: [
        if (prediction != null) ...[
          _predictionBlock(prediction, match),
          const SizedBox(height: 24),
        ],
        if (note != null) ...[
          _noteBlock(note.text, () => _openNoteSheet(match, note.text)),
          const SizedBox(height: 24),
        ],
        Eyebrow(context.tr('match_facts'), color: p.textPrimary),
        const SizedBox(height: 12),
        if (match.venue != null)
          _factRow(context.tr('stadium'), match.venue!),
        if (match.referee != null) _factRow(context.tr('referee'), match.referee!),
        if (match.date != null) _factRow(context.tr('date_label'), match.date!),
        if (match.homeFormation != null && match.awayFormation != null) ...[
          const SizedBox(height: 24),
          Eyebrow(context.tr('formations'), color: p.textPrimary),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _formationCard(
                    NameUtils.shortTeam(match.homeTeam.name),
                    match.homeFormation!),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _formationCard(
                    NameUtils.shortTeam(match.awayTeam.name),
                    match.awayFormation!),
              ),
            ],
          ),
        ],

        // Head to head section header
        const SizedBox(height: 24),
        Eyebrow(context.tr('match_info'), color: p.textPrimary),
        const SizedBox(height: 12),

        // Show league info
        if (match.league != null) _factRow('Competition', match.league!.name),
        if (match.league?.country != null) _factRow('Country', match.league!.country!),
        if (match.league?.season != null) _factRow('Season', '${match.league!.season}'),

        // Show elapsed time for live matches
        if (match.status.isLive && match.elapsed != null)
          _factRow('Elapsed', "${match.elapsed}'"),

        // Quick stats summary if available
        if (match.statistics != null && match.statistics!.statistics.isNotEmpty) ...[
          const SizedBox(height: 24),
          Eyebrow(context.tr('key_numbers'), color: p.textPrimary),
          const SizedBox(height: 12),
          ...match.statistics!.statistics.take(4).map((s) => _statSummaryRow(s)),
        ],

        // Goal scorers from events
        if (match.events.any((e) => e.isGoal)) ...[
          const SizedBox(height: 24),
          Eyebrow(context.tr('goals'), color: p.textPrimary),
          const SizedBox(height: 12),
          ...match.events.where((e) => e.isGoal).map((e) => _goalRow(e, match)),
        ],
      ],
    );
  }

  Widget _statSummaryRow(StatisticItemModel stat) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line, width: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              stat.homeValue ?? '-',
              style: AppType.mono(size: 16, color: p.textPrimary, weight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              stat.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppType.eyebrow(size: 9, color: p.textTertiary, letterSpacing: 1.2),
            ),
          ),
          Expanded(
            child: Text(
              stat.awayValue ?? '-',
              textAlign: TextAlign.right,
              style: AppType.mono(size: 16, color: p.textPrimary, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalRow(MatchEventModel event, MatchModel match) {
    final p = context.palette;
    final isHome = event.teamId == match.homeTeam.id;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line, width: 0.4)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              "${event.minute ?? ''}'",
              style: AppType.mono(size: 13, color: p.accent, weight: FontWeight.w600),
            ),
          ),
          Icon(Icons.sports_soccer_rounded, color: p.accent, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.player ?? 'Unknown',
              style: AppType.serif(size: 15, color: p.textPrimary, style: FontStyle.italic),
            ),
          ),
          Text(
            isHome ? NameUtils.shortTeam(match.homeTeam.name) : NameUtils.shortTeam(match.awayTeam.name),
            style: AppType.eyebrow(size: 9, color: p.textTertiary, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    ref.invalidate(matchDetailProvider(widget.matchId));
    ref.invalidate(matchStatisticsProvider(widget.matchId));
    ref.invalidate(matchEventsProvider(widget.matchId));
    ref.invalidate(matchLineupsProvider(widget.matchId));
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Widget _predictionBlock(PredictionEntry prediction, MatchModel match) {
    final p = context.palette;
    String? badge;
    Color? badgeColor;
    if (prediction.isResolved) {
      if (prediction.isExactMatch) {
        badge = 'EXACT +3';
        badgeColor = p.accent;
      } else if (prediction.isOutcomeCorrect) {
        badge = '+1';
        badgeColor = p.warning;
      } else {
        badge = 'MISS';
        badgeColor = p.live;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: p.line, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Eyebrow(context.tr('your_pick'), color: p.textPrimary),
              const Spacer(),
              if (badge != null && badgeColor != null)
                InkChip(label: badge, color: badgeColor),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${prediction.predictedHome}–${prediction.predictedAway}',
                style: AppType.mono(
                  size: 32,
                  color: p.accent,
                  weight: FontWeight.w500,
                ),
              ),
              if (prediction.isResolved) ...[
                const SizedBox(width: 14),
                Container(width: 0.5, height: 22, color: p.line),
                const SizedBox(width: 14),
                Text(
                  'Actual',
                  style: AppType.eyebrow(size: 10, color: p.textTertiary),
                ),
                const SizedBox(width: 8),
                Text(
                  '${prediction.actualHome}–${prediction.actualAway}',
                  style: AppType.mono(
                    size: 24,
                    color: p.textPrimary,
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

  Widget _noteBlock(String text, VoidCallback onEdit) {
    final p = context.palette;
    return InkWell(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: p.line, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Eyebrow(context.tr('note'), color: p.textPrimary),
                const Spacer(),
                Icon(Icons.edit, color: p.textTertiary, size: 14),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: AppType.serif(
                size: 16,
                color: p.textPrimary,
                style: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _factRow(String label, String value) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line, width: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: AppType.eyebrow(
                size: 10,
                color: p.textTertiary,
                letterSpacing: 1.4,
              ),
            ),
          ),
          Text(
            value,
            style: AppType.serif(
              size: 16,
              color: p.textPrimary,
              style: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formationCard(String team, String formation) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: p.line, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            team.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppType.eyebrow(
                size: 10, color: p.textTertiary, letterSpacing: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            formation,
            style: AppType.mono(
              size: 28,
              color: p.textPrimary,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(MatchModel match) {
    final p = context.palette;
    // Try from match first, then from separate provider
    var stats = match.statistics?.statistics ?? [];
    if (stats.isEmpty) {
      final asyncStats = ref.watch(matchStatisticsProvider(widget.matchId));
      stats = asyncStats.valueOrNull?.statistics ?? [];
    }
    if (stats.isEmpty) {
      return _buildEmpty(context.tr('no_stats_yet'), context.tr('available_after_kickoff'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
      physics: const BouncingScrollPhysics(),
      itemCount: stats.length,
      itemBuilder: (ctx, i) {
        final s = stats[i];
        final h = double.tryParse(s.homeValue ?? '0') ?? 0;
        final a = double.tryParse(s.awayValue ?? '0') ?? 0;
        final total = h + a;
        final hShare = total == 0 ? 0.5 : (h / total).clamp(0.05, 0.95);
        final aShare = 1.0 - hShare;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      s.homeValue ?? '–',
                      style: AppType.mono(
                        size: 16,
                        color: p.textPrimary,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      s.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppType.eyebrow(
                        size: 10,
                        color: p.textTertiary,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      s.awayValue ?? '–',
                      textAlign: TextAlign.right,
                      style: AppType.mono(
                        size: 16,
                        color: p.textPrimary,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: (hShare * 100).toInt(),
                    child: Container(height: 2, color: p.accent),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: (aShare * 100).toInt(),
                    child: Container(height: 2, color: p.info),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLineups(MatchModel match) {
    var lineups = match.lineups ?? [];
    if (lineups.isEmpty) {
      final asyncLineups = ref.watch(matchLineupsProvider(widget.matchId));
      lineups = asyncLineups.valueOrNull ?? [];
    }
    if (lineups.isEmpty) {
      return _buildEmpty(context.tr('no_lineups_yet'), context.tr('lineups_before_kickoff'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
      physics: const BouncingScrollPhysics(),
      itemCount: lineups.length,
      itemBuilder: (ctx, i) => _lineupCard(lineups[i]),
    );
  }

  Widget _lineupCard(MatchLineupModel lineup) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: p.line, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              NameUtils.shortTeam(lineup.teamName),
              style: AppType.serif(
                size: 22,
                color: p.textPrimary,
                style: FontStyle.italic,
              ),
            ),
            if (lineup.formation != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${lineup.formation}'.toUpperCase(),
                  style: AppType.mono(
                    size: 11,
                    color: p.accent,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Eyebrow(context.tr('starting_xi'), color: p.textPrimary),
            const SizedBox(height: 8),
            ...lineup.startXI.map((p2) => _playerRow(p2, false)),
            if (lineup.substitutes.isNotEmpty) ...[
              const SizedBox(height: 14),
              Eyebrow(context.tr('substitutes'), color: p.textPrimary),
              const SizedBox(height: 8),
              ...lineup.substitutes.map((p2) => _playerRow(p2, true)),
            ],
            if (lineup.coachName != null) ...[
              const SizedBox(height: 12),
              Container(height: 0.5, color: p.line),
              const SizedBox(height: 10),
              Row(
                children: [
                  Eyebrow(context.tr('coach'), color: p.textTertiary),
                  const SizedBox(width: 10),
                  Text(
                    lineup.coachName!,
                    style: AppType.serif(
                      size: 14,
                      color: p.textPrimary,
                      style: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _playerRow(LineupPlayerModel player, bool sub) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: p.line.withValues(alpha: 0.5), width: 0.4),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '${player.number ?? '–'}',
              style: AppType.mono(
                size: 12,
                color: p.textTertiary,
                weight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.sans(
                size: 14,
                color: sub ? p.textSecondary : p.textPrimary,
                weight: FontWeight.w500,
              ),
            ),
          ),
          if (player.position != null)
            Text(
              player.position!.toUpperCase(),
              style: AppType.eyebrow(
                size: 9,
                color: p.textTertiary,
                letterSpacing: 1.2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEvents(MatchModel match) {
    var events = match.events;
    if (events.isEmpty) {
      final asyncEvents = ref.watch(matchEventsProvider(widget.matchId));
      events = asyncEvents.valueOrNull ?? [];
    }
    if (events.isEmpty) {
      return _buildEmpty(context.tr('no_events_yet'), context.tr('events_appear_here'));
    }
    final p = context.palette;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
      physics: const BouncingScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (ctx, i) {
        final e = events[i];
        IconData icon = Icons.circle;
        Color iconColor = p.textTertiary;
        if (e.isGoal) {
          icon = Icons.sports_soccer_rounded;
          iconColor = p.accent;
        } else if (e.isYellowCard) {
          icon = Icons.square;
          iconColor = p.warning;
        } else if (e.isRedCard) {
          icon = Icons.square;
          iconColor = p.live;
        } else if (e.isSubstitution) {
          icon = Icons.swap_horiz_rounded;
          iconColor = p.info;
        }
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: p.line, width: 0.4)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 38,
                child: Text(
                  "${e.minute ?? '–'}'",
                  style: AppType.mono(
                    size: 13,
                    color: p.textPrimary,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.player ?? 'Unknown',
                      style: AppType.serif(
                        size: 15,
                        color: p.textPrimary,
                        style: FontStyle.italic,
                      ),
                    ),
                    if (e.detail != null)
                      Text(
                        e.detail!,
                        style: AppType.sans(
                          size: 11,
                          color: p.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(String title, String sub) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DisplayText(
              title,
              size: 22,
              style: FontStyle.italic,
              color: p.textSecondary,
            ),
            const SizedBox(height: 4),
            DeckText(sub),
          ],
        ),
      ),
    );
  }

  // ----- Sheets -----

  Future<void> _openPredictionSheet(
      MatchModel match, PredictionEntry? existing) async {
    int home = existing?.predictedHome ?? 1;
    int away = existing?.predictedAway ?? 1;

    await showModalBottomSheet(
      context: context,
      backgroundColor: context.palette.paper,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          return _scoreSheet(
            ctx,
            title: existing != null ? 'Update prediction' : 'Predict score',
            home: home,
            away: away,
            homeName: NameUtils.shortTeam(match.homeTeam.name),
            awayName: NameUtils.shortTeam(match.awayTeam.name),
            onChange: (h, a) => setSheet(() {
              home = h;
              away = a;
            }),
            onSubmit: () async {
              HapticFeedback.mediumImpact();
              await ref.read(predictionsProvider.notifier).upsert(
                    matchId: match.id,
                    homeTeam: match.homeTeam.name,
                    awayTeam: match.awayTeam.name,
                    predictedHome: home,
                    predictedAway: away,
                  );
              if (mounted) {
                Navigator.pop(ctx);
              }
            },
          );
        });
      },
    );
  }

  Widget _scoreSheet(
    BuildContext ctx, {
    required String title,
    required int home,
    required int away,
    required String homeName,
    required String awayName,
    required void Function(int home, int away) onChange,
    required VoidCallback onSubmit,
  }) {
    final p = ctx.palette;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 3,
              color: p.line,
            ),
          ),
          const SizedBox(height: 22),
          Eyebrow(title, color: p.textPrimary),
          const SizedBox(height: 8),
          DisplayText(ctx.tr('pick_the_score'),
              size: 28, style: FontStyle.italic, color: p.textPrimary),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _scorePicker(
                  homeName,
                  home,
                  (v) => onChange(v, away),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _scorePicker(
                  awayName,
                  away,
                  (v) => onChange(home, v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: p.ink,
                foregroundColor: p.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(),
              ),
              child: Text(
                ctx.tr('save_pick'),
                style: AppType.eyebrow(
                  size: 11,
                  color: p.background,
                  letterSpacing: 1.6,
                  weight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scorePicker(
      String team, int value, ValueChanged<int> onChanged) {
    return Builder(builder: (context) {
      final p = context.palette;
      return Column(
        children: [
          Text(team.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.eyebrow(
                  size: 10,
                  color: p.textTertiary,
                  letterSpacing: 1.4)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: value <= 0 ? null : () => onChanged(value - 1),
                icon: Icon(Icons.remove, color: p.textPrimary, size: 22),
              ),
              Text(
                '$value',
                style: AppType.mono(
                  size: 44,
                  color: p.textPrimary,
                  weight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: value >= 12 ? null : () => onChanged(value + 1),
                icon: Icon(Icons.add, color: p.textPrimary, size: 22),
              ),
            ],
          ),
        ],
      );
    });
  }

  Future<void> _openNoteSheet(MatchModel match, String? existing) async {
    final controller = TextEditingController(text: existing ?? '');
    await showModalBottomSheet(
      context: context,
      backgroundColor: context.palette.paper,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      builder: (ctx) {
        final p = ctx.palette;
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                  child: Container(
                      width: 36, height: 3, color: p.line)),
              const SizedBox(height: 22),
              Eyebrow(ctx.tr('match_note'), color: p.textPrimary),
              const SizedBox(height: 8),
              DisplayText(ctx.tr('a_private_line'),
                  size: 26, style: FontStyle.italic, color: p.textPrimary),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 5,
                maxLength: 500,
                cursorColor: p.accent,
                style: AppType.serif(
                  size: 16,
                  color: p.textPrimary,
                  style: FontStyle.italic,
                  height: 1.45,
                ),
                decoration: InputDecoration(
                  hintText: ctx.tr('note_hint'),
                  hintStyle: AppType.serif(
                    size: 16,
                    color: p.textTertiary,
                    style: FontStyle.italic,
                  ),
                  filled: false,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: p.line, width: 0.6),
                    borderRadius: BorderRadius.zero,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: p.line, width: 0.6),
                    borderRadius: BorderRadius.zero,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: p.ink, width: 1),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (existing != null)
                    TextButton(
                      onPressed: () async {
                        await ref
                            .read(notesProvider.notifier)
                            .delete(match.id);
                        if (mounted) Navigator.pop(ctx);
                      },
                      child: Text(
                        ctx.tr('delete'),
                        style: AppType.eyebrow(
                          size: 10,
                          color: p.live,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await ref
                          .read(notesProvider.notifier)
                          .save(match.id, controller.text);
                      if (mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.ink,
                      foregroundColor: p.background,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: Text(
                      ctx.tr('save').toUpperCase(),
                      style: AppType.eyebrow(
                        size: 11,
                        color: p.background,
                        letterSpacing: 1.6,
                        weight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleReminder(MatchModel match, bool currentlyOn) async {
    HapticFeedback.mediumImpact();
    if (currentlyOn) {
      await NotificationService.instance.cancelMatchReminder(match.id);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('reminder_cancelled'))),
        );
      }
      return;
    }
    final granted = NotificationService.instance.permissionGranted ||
        await NotificationService.instance.requestPermissions();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  context.tr('enable_notifications_hint'))),
        );
      }
      return;
    }
    final kickoff = _kickoffDateTime(match);
    final ok = await NotificationService.instance.scheduleMatchReminder(
      matchId: match.id,
      homeTeam: match.homeTeam.name,
      awayTeam: match.awayTeam.name,
      kickoff: kickoff,
    );
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              ok ? context.tr('reminder_set') : context.tr('could_not_schedule')),
        ),
      );
    }
  }

  DateTime _kickoffDateTime(MatchModel match) {
    final fallback = DateTime.now().add(const Duration(hours: 1));
    final timeStr = match.time;
    if (timeStr == null || timeStr.isEmpty) return fallback;
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? fallback.hour;
        final min = int.tryParse(parts[1]) ?? fallback.minute;
        final now = DateTime.now();
        var dt = DateTime(now.year, now.month, now.day, hour, min);
        if (dt.isBefore(now)) dt = dt.add(const Duration(days: 1));
        return dt;
      }
    } catch (_) {}
    return fallback;
  }
}

class _Action {
  final IconData icon;
  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;
  const _Action({
    required this.icon,
    required this.label,
    required this.active,
    required this.enabled,
    required this.onTap,
  });
}
