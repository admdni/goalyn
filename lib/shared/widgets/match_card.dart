import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/home/data/models/match_model.dart';
import 'widgets.dart';

class MatchScoreCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback? onTap;
  final bool compact;

  const MatchScoreCard({
    super.key,
    required this.match,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 12 : 16),
      margin: EdgeInsets.symmetric(horizontal: compact ? 8 : 16, vertical: compact ? 4 : 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (match.league != null) ...[
            _buildLeagueInfo(),
            SizedBox(height: compact ? 8 : 12),
          ],
          _buildTeamsRow(),
          SizedBox(height: compact ? 8 : 12),
          _buildStatusRow(),
        ],
      ),
    );
  }

  Widget _buildLeagueInfo() {
    return Row(
      children: [
        Expanded(
          child: Text(
            match.league!.name,
            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        StatusBadge(
          status: match.status.displayName,
          isLive: match.status.isLive,
          elapsed: match.elapsed,
        ),
      ],
    );
  }

  Widget _buildTeamsRow() {
    final hasScore = match.status != MatchStatus.scheduled && match.status != MatchStatus.notStarted;

    return Row(
      children: [
        Expanded(child: _buildTeamInfo(match.homeTeam, isHome: true)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 20, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: hasScore
              ? Text(
                  '${match.homeGoals} - ${match.awayGoals}',
                  style: (compact ? AppTypography.scoreSmall : AppTypography.scoreMedium).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      match.time ?? 'VS',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
        Expanded(child: _buildTeamInfo(match.awayTeam, isHome: false)),
      ],
    );
  }

  Widget _buildTeamInfo(team, {required bool isHome}) {
    return Column(
      children: [
        TeamLogo(
          logoUrl: team.logo,
          name: team.name,
          size: compact ? 32 : 44,
        ),
        SizedBox(height: compact ? 4 : 6),
        Text(
          team.name,
          style: compact
              ? AppTypography.labelSmall.copyWith(color: AppColors.textPrimary)
              : AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusRow() {
    if (match.status.isLive && match.elapsed != null) {
      return Center(
        child: Text(
          "${match.elapsed}'",
          style: AppTypography.labelMedium.copyWith(color: AppColors.live),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class LiveMatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback? onTap;

  const LiveMatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.live.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.live.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildMatchInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const LiveBadge(),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            match.league?.name ?? 'Match',
            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (match.elapsed != null)
          Text(
            "${match.elapsed}'",
            style: AppTypography.labelMedium.copyWith(color: AppColors.live),
          ),
      ],
    );
  }

  Widget _buildMatchInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildTeamColumn(match.homeTeam, match.homeGoals, true),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${match.homeGoals} - ${match.awayGoals}',
            style: AppTypography.scoreMedium.copyWith(color: AppColors.textPrimary),
          ),
        ),
        Expanded(
          child: _buildTeamColumn(match.awayTeam, match.awayGoals, false),
        ),
      ],
    );
  }

  Widget _buildTeamColumn(team, int goals, bool isHome) {
    return Column(
      children: [
        TeamLogo(logoUrl: team.logo, name: team.name, size: 48),
        const SizedBox(height: 8),
        Text(
          team.name,
          style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (goals > 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              goals.clamp(0, 3),
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class CompactMatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback? onTap;

  const CompactMatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasScore = match.status != MatchStatus.scheduled;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                match.homeTeam.name,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: match.status.isLive ? AppColors.live.withOpacity(0.15) : AppColors.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: hasScore
                  ? Text(
                      '${match.homeGoals} - ${match.awayGoals}',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : Text(
                      match.time ?? 'TBD',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                    ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                match.awayTeam.name,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
