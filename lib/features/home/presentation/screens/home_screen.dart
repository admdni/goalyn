import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/name_utils.dart';
import '../../../../shared/widgets/editorial.dart';
import '../../../../shared/widgets/match_line.dart';
import '../../../../services/theme_service.dart';
import '../../data/models/match_model.dart';
import '../../data/models/league_model.dart';
import '../providers/match_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _filter = 'today'; // today | upcoming | finished
  DateTime _selectedDate = DateTime.now();

  Future<void> _onRefresh() async {
    ref.invalidate(liveMatchesProvider);
    ref.invalidate(todayMatchesProvider);
    ref.invalidate(upcomingMatchesProvider);
    ref.invalidate(finishedMatchesProvider);
    ref.invalidate(leaguesProvider);
    if (!_isToday(_selectedDate)) {
      final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      ref.invalidate(dateMatchesProvider(dateStr));
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildMasthead(),
            const SizedBox(height: 6),
            _buildHero(),
            const SizedBox(height: 4),
            _buildShortcuts(),
            const SizedBox(height: 4),
            _buildLiveStrip(),
            const SizedBox(height: 4),
            _buildLeaguesStrip(),
            const SizedBox(height: 6),
            _buildCalendarStrip(),
            _buildSegmented(),
            _buildMatchSection(),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildMasthead() {
    final p = context.palette;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final today = DateTime.now();
    final dayOfWeek = DateFormat('EEEE').format(today);
    final dayNum = DateFormat('d').format(today);
    final monthYear = DateFormat('MMMM y').format(today);
    final issue = 'Issue ${DateFormat('D').format(today)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Eyebrow(issue, color: p.textTertiary, size: 10),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 0.5, color: p.line)),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => ref.read(themeProvider.notifier).toggle(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    isLight
                        ? Icons.brightness_2_outlined
                        : Icons.wb_sunny_outlined,
                    size: 16,
                    color: p.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: p.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayNum,
                style: AppType.display(
                  size: 84,
                  color: p.textPrimary,
                  letterSpacing: -3,
                  height: 0.85,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dayOfWeek,
                      style: AppType.display(
                        size: 28,
                        color: p.textPrimary,
                        style: FontStyle.italic,
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      monthYear,
                      style: AppType.sans(
                        size: 12,
                        color: p.textSecondary,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: p.ink),
          const SizedBox(height: 10),
          Row(
            children: [
              Eyebrow(context.tr('goalyn_daily'), color: p.textPrimary, size: 11),
              const Spacer(),
              Eyebrow('No.${DateFormat('D').format(today)}',
                  color: p.textTertiary, size: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    final p = context.palette;
    final liveMatches = ref.watch(liveMatchesProvider).valueOrNull ?? <MatchModel>[];
    final todayMatches = ref.watch(todayMatchesProvider).valueOrNull ?? <MatchModel>[];
    final featured = liveMatches.isNotEmpty
        ? liveMatches.first
        : todayMatches.isNotEmpty
            ? todayMatches.first
            : null;

    if (featured == null) return const SizedBox.shrink();

    final isLive = featured.status.isLive;
    final hasScore = featured.status != MatchStatus.scheduled;
    final home = NameUtils.shortTeam(featured.homeTeam.name);
    final away = NameUtils.shortTeam(featured.awayTeam.name);

    return GestureDetector(
      onTap: () => context.push('/match/${featured.id}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isLive) ...[
                  LivePulse(color: p.live, size: 6),
                  const SizedBox(width: 6),
                  Text(context.tr('in_play'),
                      style: AppType.eyebrow(
                          size: 10,
                          color: p.live,
                          letterSpacing: 1.8)),
                ] else
                  Eyebrow(
                      featured.status.isFinished
                          ? context.tr('full_time')
                          : context.tr('featured_today'),
                      color: p.textTertiary),
                const Spacer(),
                if (featured.league != null)
                  Text(
                    NameUtils.shortLeague(featured.league!.name)
                        .toUpperCase(),
                    style: AppType.eyebrow(
                      size: 10,
                      color: p.textTertiary,
                      letterSpacing: 1.4,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
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
                            size: 38,
                            color: p.textPrimary,
                            style: FontStyle.italic,
                            letterSpacing: -1,
                            height: 1.0,
                          )),
                      const SizedBox(height: 4),
                      Text(home.toUpperCase(),
                          style: AppType.eyebrow(
                              size: 9,
                              color: p.textTertiary,
                              letterSpacing: 1.4)),
                    ],
                  ),
                ),
                if (hasScore)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${featured.homeGoals}–${featured.awayGoals}',
                      style: AppType.mono(
                        size: 44,
                        color: p.textPrimary,
                        weight: FontWeight.w500,
                        letterSpacing: -1,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      context.tr('vs'),
                      style: AppType.display(
                        size: 26,
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
                            size: 38,
                            color: p.textPrimary,
                            style: FontStyle.italic,
                            letterSpacing: -1,
                            height: 1.0,
                          )),
                      const SizedBox(height: 4),
                      Text(away.toUpperCase(),
                          style: AppType.eyebrow(
                              size: 9,
                              color: p.textTertiary,
                              letterSpacing: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 0.5, color: p.line),
            const SizedBox(height: 12),
            Row(
              children: [
                if (isLive)
                  Text(
                    "${featured.elapsed}'  ${context.tr('in_play')}",
                    style: AppType.eyebrow(
                        size: 10, color: p.live, letterSpacing: 1.6),
                  )
                else if (featured.time != null)
                  Text(
                    '${context.tr('kicks_off_at')} ${featured.time}',
                    style: AppType.serif(
                      size: 13,
                      color: p.textSecondary,
                      style: FontStyle.italic,
                    ),
                  )
                else
                  Text(
                    context.tr('final_label'),
                    style: AppType.serif(
                      size: 13,
                      color: p.textSecondary,
                      style: FontStyle.italic,
                    ),
                  ),
                const Spacer(),
                Text(
                  context.tr('read_story'),
                  style: AppType.serif(
                    size: 13,
                    color: p.accent,
                    style: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward, color: p.accent, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcuts() {
    final p = context.palette;
    final tiles = [
      _Shortcut(context.tr('predict'), context.tr('pick_scores'),
          Icons.gps_fixed_rounded, () => context.push('/predictions')),
      _Shortcut(context.tr('compare'), context.tr('two_teams'),
          Icons.compare_arrows_rounded, () => context.push('/compare')),
      _Shortcut(context.tr('nav_saved'), context.tr('teams_matches'),
          Icons.bookmark_outline_rounded, () => context.go('/favorites')),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 0.5, color: p.line),
          ...tiles.map((s) => _ShortcutTile(s: s)),
        ],
      ),
    );
  }

  Widget _buildLiveStrip() {
    final p = context.palette;
    final liveAsync = ref.watch(liveMatchesProvider);
    final live = liveAsync.valueOrNull ?? <MatchModel>[];
    if (live.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionRule(
          label: context.tr('live_now'),
          color: p.live,
          trailing: Eyebrow('${live.length} ${context.tr('games_count')}', color: p.textTertiary),
        ),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: live.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _LiveCard(match: live[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaguesStrip() {
    final p = context.palette;
    final leagues = ref.watch(leaguesProvider).valueOrNull ?? <LeagueModel>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionRule(label: context.tr('competitions')),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: leagues.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final l = leagues[i];
              return GestureDetector(
                onTap: () => context.push(
                    '/league/${l.id}?name=${Uri.encodeComponent(l.name)}'),
                child: Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: p.line, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        NameUtils.shortLeague(l.name).toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppType.eyebrow(
                          size: 10,
                          color: p.textPrimary,
                          letterSpacing: 1.4,
                        ),
                      ),
                      Text(
                        l.country ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppType.serif(
                          size: 12,
                          color: p.textSecondary,
                          style: FontStyle.italic,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarStrip() {
    final p = context.palette;
    final today = DateTime.now();
    final dates = List.generate(15, (i) => today.subtract(Duration(days: 7 - i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Eyebrow(context.tr('match_calendar'), color: p.textPrimary),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _selectedDate = today),
                child: Text(
                  context.tr('today'),
                  style: AppType.eyebrow(
                    size: 10,
                    color: _isToday(_selectedDate) ? p.accent : p.textTertiary,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: dates.length,
            itemBuilder: (context, i) {
              final date = dates[i];
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, today);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDate = date);
                },
                child: Container(
                  width: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? p.ink : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? p.ink : (isToday ? p.accent : p.line),
                      width: isToday && !isSelected ? 1.5 : 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date).substring(0, 3).toUpperCase(),
                        style: AppType.eyebrow(
                          size: 9,
                          color: isSelected ? p.background : p.textTertiary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: AppType.mono(
                          size: 18,
                          color: isSelected ? p.background : p.textPrimary,
                          weight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM').format(date).toUpperCase(),
                        style: AppType.eyebrow(
                          size: 8,
                          color: isSelected ? p.background : p.textTertiary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) => _isSameDay(d, DateTime.now());

  Widget _buildSegmented() {
    if (!_isToday(_selectedDate)) return const SizedBox.shrink();
    final p = context.palette;
    final segments = [
      ('today', context.tr('today')),
      ('upcoming', context.tr('upcoming_filter')),
      ('finished', context.tr('finished')),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DisplayText(
            context.tr('the_match_desk'),
            size: 32,
            style: FontStyle.italic,
            color: p.textPrimary,
          ),
          const SizedBox(height: 12),
          Container(height: 0.5, color: p.line),
          Row(
            children: segments.map((s) {
              final selected = _filter == s.$1;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _filter = s.$1);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selected ? p.ink : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    s.$2.toUpperCase(),
                    style: AppType.eyebrow(
                      size: 11,
                      color: selected ? p.textPrimary : p.textTertiary,
                      letterSpacing: 1.6,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Container(height: 0.5, color: p.line),
        ],
      ),
    );
  }

  Widget _buildMatchSection() {
    final isSelectedToday = _isToday(_selectedDate);

    final List<MatchModel> matches;
    if (isSelectedToday) {
      matches = switch (_filter) {
        'upcoming' => ref.watch(upcomingMatchesProvider).valueOrNull ?? <MatchModel>[],
        'finished' => ref.watch(finishedMatchesProvider).valueOrNull ?? <MatchModel>[],
        _ => ref.watch(todayMatchesProvider).valueOrNull ?? <MatchModel>[],
      };
    } else {
      final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      matches = ref.watch(dateMatchesProvider(dateStr)).valueOrNull ?? <MatchModel>[];
    }

    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Center(
          child: DeckText(
            context.tr('no_matches_section'),
            color: context.palette.textTertiary,
          ),
        ),
      );
    }

    // Group by league for visual variety
    final groups = <String, List<MatchModel>>{};
    for (final m in matches) {
      final key = NameUtils.shortLeague(m.league?.name ?? 'OTHER');
      groups.putIfAbsent(key, () => []).add(m);
    }

    return Column(
      children: groups.entries.map((entry) {
        return MatchGroup(
          title: entry.key,
          subtitle: '${entry.value.length} ${context.tr('games_count')}',
          matches: entry.value,
          onMatchTap: (m) => context.push('/match/${m.id}'),
        );
      }).toList(),
    );
  }
}

class _Shortcut {
  final String label;
  final String sub;
  final IconData icon;
  final VoidCallback onTap;
  const _Shortcut(this.label, this.sub, this.icon, this.onTap);
}

class _ShortcutTile extends StatelessWidget {
  final _Shortcut s;
  const _ShortcutTile({required this.s});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: s.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(s.icon, color: p.textPrimary, size: 18),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.label,
                    style: AppType.serif(
                      size: 22,
                      color: p.textPrimary,
                      style: FontStyle.italic,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.sub,
                    style: AppType.sans(
                      size: 12,
                      color: p.textTertiary,
                      weight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: p.textTertiary, size: 16),
          ],
        ),
      ),
    );
  }
}

class _LiveCard extends StatelessWidget {
  final MatchModel match;
  const _LiveCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final home = NameUtils.shortTeam(match.homeTeam.name);
    final away = NameUtils.shortTeam(match.awayTeam.name);
    return GestureDetector(
      onTap: () =>
          (context as Element).findAncestorStateOfType<NavigatorState>(),
      child: InkWell(
        onTap: () => GoRouter.of(context).push('/match/${match.id}'),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.paper,
            border: Border.all(color: p.line, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  LivePulse(color: p.live, size: 5),
                  const SizedBox(width: 6),
                  Text("${match.elapsed ?? '·'}'",
                      style: AppType.eyebrow(
                          size: 10,
                          color: p.live,
                          letterSpacing: 1.4)),
                  const Spacer(),
                  if (match.league != null)
                    Flexible(
                      child: Text(
                        NameUtils.shortLeague(match.league!.name)
                            .toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppType.eyebrow(
                          size: 9,
                          color: p.textTertiary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _liveTeam(p, home, '${match.homeGoals}'),
              const SizedBox(height: 6),
              _liveTeam(p, away, '${match.awayGoals}'),
              const Spacer(),
              Container(height: 0.5, color: p.line),
              const SizedBox(height: 8),
              Text(
                'In play · tap to follow',
                style: AppType.serif(
                  size: 12,
                  color: p.textSecondary,
                  style: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _liveTeam(AppPalette p, String name, String goals) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppType.sans(
              size: 14,
              color: p.textPrimary,
              weight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ),
        Text(
          goals,
          style: AppType.mono(
            size: 18,
            color: p.textPrimary,
            weight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
