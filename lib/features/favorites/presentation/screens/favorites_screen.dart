import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/name_utils.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../shared/widgets/editorial.dart';
import '../../../../shared/widgets/match_line.dart';
import '../../../home/presentation/providers/match_providers.dart';
import '../../../../services/favorites_service.dart';
import '../../../../features/home/data/models/match_model.dart';
import '../../../../features/home/data/models/team_model.dart';
import '../../../../features/home/data/models/league_model.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String _filter = 'teams';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final favs = ref.watch(favoritesProvider);

    final teams = (ref.watch(allTeamsProvider).valueOrNull ?? <TeamModel>[])
        .where((t) => favs.teams.contains(t.id))
        .toList();
    final leagues = (ref.watch(leaguesProvider).valueOrNull ?? <LeagueModel>[])
        .where((l) => favs.leagues.contains(l.id))
        .toList();
    final matches = <MatchModel>[
      ...(ref.watch(todayMatchesProvider).valueOrNull ?? <MatchModel>[]),
      ...(ref.watch(upcomingMatchesProvider).valueOrNull ?? <MatchModel>[]),
      ...(ref.watch(finishedMatchesProvider).valueOrNull ?? <MatchModel>[]),
    ].where((m) => favs.matches.contains(m.id)).toSet().toList();

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildMasthead(teams.length, matches.length, leagues.length),
            _buildSegmented(teams.length, matches.length, leagues.length),
            Expanded(
              child: switch (_filter) {
                'teams' => _buildTeams(teams),
                'matches' => _buildMatches(matches),
                _ => _buildLeagues(leagues),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasthead(int teams, int matches, int leagues) {
    final p = context.palette;
    final total = teams + matches + leagues;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Eyebrow(context.tr('my_library'), color: p.textPrimary),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 0.5, color: p.line)),
              const SizedBox(width: 10),
              Text(
                '$total SAVED',
                style: AppType.eyebrow(
                  size: 10,
                  color: p.textTertiary,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DisplayText(
            context.tr('saved_title'),
            size: 44,
            style: FontStyle.italic,
            color: p.textPrimary,
          ),
          const SizedBox(height: 6),
          DeckText(
            total > 0
                ? context.tr('favorites_desc')
                : context.tr('favorites_empty_hint'),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmented(int teams, int matches, int leagues) {
    final p = context.palette;
    final segs = [
      ('teams', context.tr('teams'), teams),
      ('matches', context.tr('matches'), matches),
      ('leagues', context.tr('leagues'), leagues),
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: p.line, width: 0.5),
          bottom: BorderSide(color: p.line, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: segs.map((s) {
          final selected = _filter == s.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _filter = s.$1),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? p.ink : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.$2.toUpperCase(),
                      style: AppType.eyebrow(
                        size: 11,
                        color: selected ? p.textPrimary : p.textTertiary,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${s.$3}',
                      style: AppType.mono(
                        size: 11,
                        color: selected ? p.textPrimary : p.textTertiary,
                        weight: FontWeight.w500,
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

  Widget _buildTeams(List<TeamModel> teams) {
    if (teams.isEmpty) return _empty(context.tr('no_teams_saved'));
    final p = context.palette;
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: teams.length,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(height: 0.5, color: p.line),
      ),
      itemBuilder: (ctx, i) {
        final team = teams[i];
        return InkWell(
          onTap: () => context.push(
              '/team/${team.id}?name=${Uri.encodeComponent(team.name)}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        NameUtils.shortTeam(team.name),
                        style: AppType.serif(
                          size: 22,
                          color: p.textPrimary,
                          style: FontStyle.italic,
                        ),
                      ),
                      if (team.country != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          team.country!.toUpperCase(),
                          style: AppType.eyebrow(
                            size: 10,
                            color: p.textTertiary,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                      HapticFeedback.selectionClick();
                      ref.read(favoritesProvider.notifier).toggleTeam(team.id);
                  },
                  icon: Icon(Icons.bookmark_rounded,
                      color: p.accent, size: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatches(List<MatchModel> matches) {
    if (matches.isEmpty) return _empty(context.tr('no_matches_saved'));
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        MatchGroup(
          title: 'My matches',
          subtitle: '${matches.length} games',
          matches: matches,
          onMatchTap: (m) => context.push('/match/${m.id}'),
        ),
      ],
    );
  }

  Widget _buildLeagues(List<LeagueModel> leagues) {
    if (leagues.isEmpty) return _empty(context.tr('no_leagues_saved'));
    final p = context.palette;
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: leagues.length,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(height: 0.5, color: p.line),
      ),
      itemBuilder: (ctx, i) {
        final l = leagues[i];
        return InkWell(
          onTap: () => context.push(
              '/league/${l.id}?name=${Uri.encodeComponent(l.name)}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.name,
                        style: AppType.serif(
                          size: 22,
                          color: p.textPrimary,
                          style: FontStyle.italic,
                        ),
                      ),
                      if (l.country != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          l.country!.toUpperCase(),
                          style: AppType.eyebrow(
                            size: 10,
                            color: p.textTertiary,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                      HapticFeedback.selectionClick();
                      ref.read(favoritesProvider.notifier).toggleLeague(l.id);
                  },
                  icon: Icon(Icons.bookmark_rounded,
                      color: p.accent, size: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _empty(String message) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border_rounded,
                size: 36, color: p.textTertiary),
            const SizedBox(height: 12),
            DisplayText(
              message,
              size: 24,
              style: FontStyle.italic,
              color: p.textSecondary,
              align: TextAlign.center,
            ),
            const SizedBox(height: 4),
            DeckText(context.tr('tap_bookmark_hint')),
          ],
        ),
      ),
    );
  }
}
