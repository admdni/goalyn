import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/name_utils.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../shared/widgets/editorial.dart';
import '../../../../features/home/data/models/team_model.dart';
import '../../../../features/home/data/models/league_model.dart';
import '../../../home/presentation/providers/match_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  List<TeamModel> _teamResults = [];
  List<LeagueModel> _leagueResults = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChange);
    _controller.dispose();
    super.dispose();
  }

  void _onChange() {
    final q = _controller.text.toLowerCase();
    setState(() {
      _query = q;
      if (q.length >= 1) {
        _teamResults = (ref.read(allTeamsProvider).valueOrNull ??
                <TeamModel>[])
            .where((t) => t.name.toLowerCase().contains(q))
            .toList();
        _leagueResults = (ref.read(leaguesProvider).valueOrNull ??
                <LeagueModel>[])
            .where((l) => l.name.toLowerCase().contains(q))
            .toList();
      } else {
        _teamResults = [];
        _leagueResults = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back, color: p.textPrimary, size: 20),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    cursorColor: p.accent,
                    style: AppType.serif(
                      size: 22,
                      color: p.textPrimary,
                      style: FontStyle.italic,
                    ),
                    decoration: InputDecoration(
                      hintText: context.tr('search_teams_leagues'),
                      hintStyle: AppType.serif(
                        size: 22,
                        color: p.textTertiary,
                        style: FontStyle.italic,
                      ),
                      isDense: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_query.isNotEmpty)
                  IconButton(
                    onPressed: () => _controller.clear(),
                    icon: Icon(Icons.close, color: p.textTertiary, size: 18),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_query.isEmpty) {
      return _buildEmpty();
    }

    final p = context.palette;
    final hasResults = _teamResults.isNotEmpty || _leagueResults.isNotEmpty;
    if (!hasResults) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DisplayText(
                context.tr('no_matches_found'),
                size: 28,
                style: FontStyle.italic,
                color: p.textSecondary,
              ),
              const SizedBox(height: 6),
              DeckText(context.tr('try_search_hint')),
            ],
          ),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 60),
      children: [
        if (_teamResults.isNotEmpty) ...[
          _sectionHeader(context.tr('teams'), '${_teamResults.length}'),
          ..._teamResults.map((t) => _teamRow(t)),
        ],
        if (_leagueResults.isNotEmpty) ...[
          const SizedBox(height: 8),
          _sectionHeader(context.tr('leagues'), '${_leagueResults.length}'),
          ..._leagueResults.map((l) => _leagueRow(l)),
        ],
      ],
    );
  }

  Widget _buildEmpty() {
    final p = context.palette;
    final popular = ref.watch(allTeamsProvider).valueOrNull?.take(8).toList() ?? [];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 60),
      children: [
        Eyebrow(context.tr('try_searching')),
        const SizedBox(height: 10),
        DisplayText(
          'Find a club\nor a competition.',
          size: 32,
          style: FontStyle.italic,
          color: p.textPrimary,
        ),
        const SizedBox(height: 24),
        Container(height: 0.5, color: p.line),
        const SizedBox(height: 14),
        Eyebrow(context.tr('popular_clubs'), color: p.textPrimary),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popular
              .map((t) => GestureDetector(
                    onTap: () => context.push(
                        '/team/${t.id}?name=${Uri.encodeComponent(t.name)}'),
                    child: InkChip(label: NameUtils.shortTeam(t.name)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _sectionHeader(String label, String count) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Eyebrow(label, color: p.textPrimary),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 0.5, color: p.line)),
          const SizedBox(width: 10),
          Text(count,
              style: AppType.mono(
                size: 11,
                color: p.textTertiary,
                weight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  Widget _teamRow(TeamModel team) {
    final p = context.palette;
    return InkWell(
      onTap: () => context
          .push('/team/${team.id}?name=${Uri.encodeComponent(team.name)}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    NameUtils.shortTeam(team.name),
                    style: AppType.serif(
                      size: 20,
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
            Icon(Icons.arrow_forward, color: p.textTertiary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _leagueRow(LeagueModel league) {
    final p = context.palette;
    return InkWell(
      onTap: () => context.push(
          '/league/${league.id}?name=${Uri.encodeComponent(league.name)}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    league.name,
                    style: AppType.serif(
                      size: 20,
                      color: p.textPrimary,
                      style: FontStyle.italic,
                    ),
                  ),
                  if (league.country != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      league.country!.toUpperCase(),
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
            Icon(Icons.arrow_forward, color: p.textTertiary, size: 16),
          ],
        ),
      ),
    );
  }
}
