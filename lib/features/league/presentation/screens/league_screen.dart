import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/name_utils.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../shared/widgets/editorial.dart';
import '../../../home/presentation/providers/match_providers.dart';
import '../../data/models/standing_model.dart';

class LeagueScreen extends ConsumerWidget {
  final int leagueId;
  final String leagueName;

  const LeagueScreen({
    super.key,
    required this.leagueId,
    required this.leagueName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final standings =
        ref.watch(standingsProvider(leagueId)).valueOrNull ?? <StandingModel>[];
    final league = ref
        .watch(leaguesProvider)
        .valueOrNull
        ?.where((l) => l.id == leagueId)
        .firstOrNull;

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 60),
                children: [
                  _buildHero(context, leagueName, league?.country),
                  _buildStandingsHeader(context),
                  ..._buildStandings(context, standings),
                  _buildLegend(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final p = context.palette;
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
          const Spacer(),
          Text(
            NameUtils.shortLeague(leagueName).toUpperCase(),
            style: AppType.eyebrow(
              size: 10,
              color: p.textSecondary,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, String name, String? country) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (country != null) Eyebrow(country, color: p.accent),
          const SizedBox(height: 10),
          DisplayText(
            name,
            size: 38,
            style: FontStyle.italic,
            color: p.textPrimary,
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          DeckText(context.tr('standings_desc')),
        ],
      ),
    );
  }

  Widget _buildStandingsHeader(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: p.line, width: 0.5),
          bottom: BorderSide(color: p.line, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 11),
          SizedBox(
            width: 22,
            child: Text(context.tr('position'),
                style: AppType.eyebrow(size: 10, color: p.textTertiary)),
          ),
          Expanded(
            child: Text(context.tr('club'),
                style: AppType.eyebrow(size: 10, color: p.textTertiary)),
          ),
          _statHeader(context.tr('pl'), p.textTertiary),
          _statHeader(context.tr('won'), p.textTertiary),
          _statHeader(context.tr('drawn'), p.textTertiary),
          _statHeader(context.tr('lost'), p.textTertiary),
          _statHeader(context.tr('gd'), p.textTertiary),
          _statHeader(context.tr('pts'), p.textPrimary, wide: true),
        ],
      ),
    );
  }

  Widget _statHeader(String label, Color color, {bool wide = false}) {
    return SizedBox(
      width: wide ? 38 : 26,
      child: Text(
        label,
        textAlign: TextAlign.right,
        style: AppType.eyebrow(size: 10, color: color, letterSpacing: 1.2),
      ),
    );
  }

  List<Widget> _buildStandings(BuildContext context, List<StandingModel> standings) {
    if (standings.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(40),
          child: Center(child: DeckText(context.tr('no_standings'))),
        ),
      ];
    }
    final p = context.palette;
    return List.generate(standings.length, (i) {
      final s = standings[i];
      final isUCL = s.rank <= 4;
      final isUEL = s.rank == 5 || s.rank == 6;
      final isRel = s.rank >= standings.length - 2;
      final indicator = isUCL
          ? p.accent
          : isUEL
              ? p.info
              : isRel
                  ? p.live
                  : Colors.transparent;

      return Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.line, width: 0.4)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 22,
              color: indicator,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 22,
              child: Text(
                '${s.rank}',
                style: AppType.mono(
                  size: 13,
                  color: p.textPrimary,
                  weight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                NameUtils.shortTeam(s.teamName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.sans(
                  size: 14,
                  color: p.textPrimary,
                  weight: FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            _stat('${s.played}', p.textSecondary),
            _stat('${s.won}', p.textSecondary),
            _stat('${s.drawn}', p.textSecondary),
            _stat('${s.lost}', p.textSecondary),
            _stat(
              s.goalDifference > 0 ? '+${s.goalDifference}' : '${s.goalDifference}',
              p.textSecondary,
            ),
            SizedBox(
              width: 38,
              child: Text(
                '${s.points}',
                textAlign: TextAlign.right,
                style: AppType.mono(
                  size: 14,
                  color: p.textPrimary,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _stat(String value, Color color) {
    return SizedBox(
      width: 26,
      child: Text(
        value,
        textAlign: TextAlign.right,
        style: AppType.mono(size: 12, color: color, weight: FontWeight.w500),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        children: [
          _legendDot(p.accent, context.tr('champions')),
          _legendDot(p.info, context.tr('europa')),
          _legendDot(p.live, context.tr('relegation')),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Builder(builder: (context) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 2, color: color),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: AppType.eyebrow(
              size: 9,
              color: context.palette.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      );
    });
  }
}
