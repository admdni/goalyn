import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/name_utils.dart';
import '../../core/i18n/app_localizations.dart';
import '../../features/home/data/models/match_model.dart';
import 'editorial.dart';

/// A line-item match row — typographic, no card chrome. Used in lists.
class MatchLine extends StatelessWidget {
  final MatchModel match;
  final VoidCallback? onTap;
  final bool dense;

  const MatchLine({
    super.key,
    required this.match,
    this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isLive = match.status.isLive;
    final isFinal = match.status.isFinished;
    final hasScore = isLive || isFinal;
    final winner = hasScore
        ? (match.homeGoals > match.awayGoals
            ? 'home'
            : match.awayGoals > match.homeGoals
                ? 'away'
                : 'draw')
        : null;

    return InkWell(
      onTap: onTap,
      onLongPress: () => _showMatchActions(context, match),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: dense ? 10 : 14,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLive)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LivePulse(color: p.live, size: 5),
                        const SizedBox(width: 4),
                        Text(
                          "${match.elapsed ?? '·'}'",
                          style: AppType.mono(
                            size: 11,
                            color: p.live,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  else if (isFinal)
                    Text(
                      'FT',
                      style: AppType.eyebrow(
                        size: 10,
                        color: p.textTertiary,
                        letterSpacing: 1.6,
                      ),
                    )
                  else
                    Text(
                      match.time ?? '—',
                      style: AppType.mono(
                        size: 11,
                        color: p.textSecondary,
                        weight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _teamRow(
                    context,
                    NameUtils.shortTeam(match.homeTeam.name),
                    hasScore ? '${match.homeGoals}' : null,
                    winner == 'home' && isFinal,
                  ),
                  const SizedBox(height: 4),
                  _teamRow(
                    context,
                    NameUtils.shortTeam(match.awayTeam.name),
                    hasScore ? '${match.awayGoals}' : null,
                    winner == 'away' && isFinal,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamRow(
    BuildContext context,
    String name,
    String? goals,
    bool isWinner,
  ) {
    final p = context.palette;
    final dim = goals != null && !isWinner && match.status.isFinished;
    final textColor = dim ? p.textTertiary : p.textPrimary;
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppType.sans(
              size: 15,
              color: textColor,
              weight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
        ),
        if (goals != null) ...[
          const SizedBox(width: 8),
          Text(
            goals,
            style: AppType.mono(
              size: 18,
              color: textColor,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Long-press context menu
// ---------------------------------------------------------------------------

void _showMatchActions(BuildContext context, MatchModel match) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _MatchActionsSheet(match: match),
  );
}

class _MatchActionsSheet extends StatelessWidget {
  final MatchModel match;
  const _MatchActionsSheet({required this.match});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final home = match.homeTeam.name;
    final away = match.awayTeam.name;
    final hasScore = match.status.isLive || match.status.isFinished;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.paper,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            // Drag handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: p.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            // Match title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '$home vs $away',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.sans(
                  size: 15,
                  color: p.textPrimary,
                  weight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: p.line),
            _ActionTile(
              icon: Icons.info_outline_rounded,
              label: context.tr('view_details'),
              color: p.textPrimary,
              onTap: () {
                Navigator.pop(context);
                context.push('/match/${match.id}');
              },
            ),
            _ActionTile(
              icon: Icons.gps_fixed_rounded,
              label: context.tr('predict_score'),
              color: p.textPrimary,
              onTap: () {
                Navigator.pop(context);
                context.push('/predictions');
              },
            ),
            if (hasScore)
              _ActionTile(
                icon: Icons.share_rounded,
                label: context.tr('share_score'),
                color: p.textPrimary,
                onTap: () {
                  Navigator.pop(context);
                  Share.share(
                    '$home ${match.homeGoals} - ${match.awayGoals} $away',
                  );
                },
              ),
            const SizedBox(height: 4),
            Divider(height: 1, color: p.line),
            _ActionTile(
              icon: Icons.close_rounded,
              label: context.tr('cancel'),
              color: p.textTertiary,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppType.sans(
                  size: 15,
                  color: color,
                  weight: FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A grouped list of matches under a date or league header.
class MatchGroup extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<MatchModel> matches;
  final void Function(MatchModel match)? onMatchTap;

  const MatchGroup({
    super.key,
    required this.title,
    this.subtitle,
    required this.matches,
    this.onMatchTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title.toUpperCase(),
                style: AppType.eyebrow(
                  size: 10,
                  color: p.textPrimary,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 0.5, color: p.line)),
              if (subtitle != null) ...[
                const SizedBox(width: 10),
                Text(
                  subtitle!,
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
        ...matches.expand((m) => [
              MatchLine(
                match: m,
                onTap: onMatchTap == null ? null : () => onMatchTap!(m),
              ),
              HairLine(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: p.line.withValues(alpha: 0.5)),
            ]),
      ],
    );
  }
}
