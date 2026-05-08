import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/name_utils.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../shared/widgets/editorial.dart';
import '../../../../services/favorites_service.dart';
import '../../../home/data/models/team_model.dart';
import '../../../home/presentation/providers/match_providers.dart';

class TeamScreen extends ConsumerStatefulWidget {
  final int teamId;
  final String teamName;

  const TeamScreen({super.key, required this.teamId, required this.teamName});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final team = ref.watch(teamInfoProvider(widget.teamId)).valueOrNull ??
        TeamModel(id: widget.teamId, name: widget.teamName);
    final favs = ref.watch(favoritesProvider);
    final saved = favs.teams.contains(team.id);

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(saved, () =>
                ref.read(favoritesProvider.notifier).toggleTeam(team.id)),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 60),
                children: [
                  _buildHero(team),
                  _buildFactSheet(team),
                  _buildForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool saved, VoidCallback onSave) {
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
          Expanded(
            child: Text(
              NameUtils.shortTeam(widget.teamName).toUpperCase(),
              style: AppType.eyebrow(
                size: 10,
                color: p.textSecondary,
                letterSpacing: 1.6,
              ),
            ),
          ),
          IconButton(
            onPressed: onSave,
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

  Widget _buildHero(team) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (team.country != null)
            Eyebrow(team.country!, color: p.accent),
          const SizedBox(height: 12),
          DisplayText(
            NameUtils.shortTeam(team.name),
            size: 48,
            style: FontStyle.italic,
            color: p.textPrimary,
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          DeckText(team.stadium ?? team.venueName ?? context.tr('storied_club')),
        ],
      ),
    );
  }

  Widget _buildFactSheet(team) {
    final p = context.palette;
    final rows = <(String, String)>[
      if (team.founded != null) (context.tr('founded'), team.founded!),
      if (team.stadium != null) (context.tr('stadium'), team.stadium!),
      if (team.venueCapacity != null)
        (context.tr('capacity'), _formatNumber(team.venueCapacity!)),
      if (team.country != null) (context.tr('country'), team.country!),
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: p.line, width: 0.5)),
          ),
          child: Row(
            children: [
              Eyebrow(context.tr('fact_sheet'), color: p.textPrimary),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 0.5, color: p.line)),
            ],
          ),
        ),
        ...rows.map((r) => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: p.line, width: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      r.$1.toUpperCase(),
                      style: AppType.eyebrow(
                        size: 10,
                        color: p.textTertiary,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  Text(
                    r.$2,
                    style: AppType.serif(
                      size: 17,
                      color: p.textPrimary,
                      style: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildForm() {
    final p = context.palette;
    // Mock recent form: WWDLW
    final form = ['W', 'W', 'D', 'L', 'W'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(context.tr('last_five'), color: p.textPrimary),
          const SizedBox(height: 14),
          Row(
            children: form.map((r) {
              final c = r == 'W'
                  ? p.accent
                  : r == 'D'
                      ? p.warning
                      : p.live;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: c, width: 1.2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    r,
                    style: AppType.mono(
                      size: 14,
                      color: c,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
