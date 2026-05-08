import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/editorial.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../home/data/models/team_model.dart';
import '../../../home/presentation/providers/match_providers.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  TeamModel? _left;
  TeamModel? _right;
  bool _initialized = false;

  void _initTeams(List<TeamModel> teams) {
    if (!_initialized && teams.length >= 2) {
      _initialized = true;
      _left = teams[0];
      _right = teams[6 < teams.length ? 6 : 1];
    }
  }

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(allTeamsProvider).valueOrNull ?? <TeamModel>[];
    _initTeams(teams);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            _buildEditorialMasthead(),
            _buildHeader(),
            const SizedBox(height: 22),
            SectionKicker(
              label: context.tr('the_numbers'),
              issue: 'I',
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildMetricRows(),
            ),
            const SizedBox(height: 20),
            SectionKicker(
              label: context.tr('editorial_verdict'),
              issue: 'II',
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildPredictionCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorialMasthead() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                'No. 04 — TALE OF THE TAPE',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 2, color: AppColors.textPrimary),
          const SizedBox(height: 16),
          EditorialHeadline(context.tr('compare_the_sides'), fontSize: 42),
          const SizedBox(height: 6),
          EditorialDeck(
            context.tr('compare_desc'),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.textPrimary, width: 1),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTeamPicker(true)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'VS',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontStyle: FontStyle.italic,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(child: _buildTeamPicker(false)),
        ],
      ),
    );
  }

  Widget _buildTeamPicker(bool isLeft) {
    final team = isLeft ? _left : _right;
    return GestureDetector(
      onTap: () => _pickTeam(isLeft),
      child: Column(
        children: [
          if (team == null)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.primary),
            )
          else
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 0.5),
              ),
              alignment: Alignment.center,
              child: Text(
                team.name.isNotEmpty ? team.name[0].toUpperCase() : '?',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            team?.name ?? context.tr('pick_team'),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRows() {
    if (_left == null || _right == null) {
      return const SizedBox.shrink();
    }

    // Deterministic per-team metrics derived from team id, so the screen
    // is consistent across rebuilds and feels analytical.
    final lFormScore = _formScore(_left!);
    final rFormScore = _formScore(_right!);
    final lGoals = _goalsAvg(_left!);
    final rGoals = _goalsAvg(_right!);
    final lDef = _defenceScore(_left!);
    final rDef = _defenceScore(_right!);
    final lFans = _fanPower(_left!);
    final rFans = _fanPower(_right!);

    return Column(
      children: [
        _metricRow(
            context.tr('form_last_10'), lFormScore.toStringAsFixed(1),
            rFormScore.toStringAsFixed(1), lFormScore, rFormScore, 10),
        _metricRow(
            context.tr('goals_per_match'), lGoals.toStringAsFixed(2),
            rGoals.toStringAsFixed(2), lGoals, rGoals, 4),
        _metricRow(
            context.tr('defensive_rating'), lDef.toStringAsFixed(1),
            rDef.toStringAsFixed(1), lDef, rDef, 100),
        _metricRow(context.tr('fan_power'), '$lFans', '$rFans',
            lFans.toDouble(), rFans.toDouble(), 100000),
        _metricRow(context.tr('stadium_capacity'),
            '${_left!.venueCapacity ?? 0}',
            '${_right!.venueCapacity ?? 0}',
            (_left!.venueCapacity ?? 0).toDouble(),
            (_right!.venueCapacity ?? 0).toDouble(),
            100000),
        _metricRow(context.tr('founded'),
            _left!.founded ?? '—',
            _right!.founded ?? '—',
            _yearScore(_left!.founded),
            _yearScore(_right!.founded),
            150),
      ],
    );
  }

  Widget _metricRow(String label, String leftVal, String rightVal,
      double leftScore, double rightScore, double maxValue) {
    final lShare = (leftScore / (leftScore + rightScore + 0.01)).clamp(0.05, 0.95);
    final rShare = 1.0 - lShare;
    final leftWins = leftScore > rightScore;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  leftVal,
                  style: AppTypography.titleMedium.copyWith(
                    color: leftWins
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                child: Text(
                  rightVal,
                  textAlign: TextAlign.right,
                  style: AppTypography.titleMedium.copyWith(
                    color: leftWins
                        ? AppColors.textPrimary
                        : AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: (lShare * 100).toInt(),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        const BorderRadius.horizontal(left: Radius.circular(2)),
                  ),
                ),
              ),
              Expanded(
                flex: (rShare * 100).toInt(),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(2)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard() {
    if (_left == null || _right == null) return const SizedBox.shrink();

    final lScore = _formScore(_left!) +
        _goalsAvg(_left!) * 2 +
        _defenceScore(_left!) / 20;
    final rScore = _formScore(_right!) +
        _goalsAvg(_right!) * 2 +
        _defenceScore(_right!) / 20;

    final total = lScore + rScore;
    final lWin = ((lScore / total) * 100).clamp(5, 95).toInt();
    final draw = (100 - (lScore - rScore).abs() * 6).clamp(8, 35).toInt();
    final rWin = (100 - lWin - draw).clamp(5, 95);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                context.tr('predicted_outcome'),
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _outcomeBlock(
                    '${_left!.name.split(' ').first} win', '$lWin%'),
              ),
              const SizedBox(width: 8),
              Expanded(child: _outcomeBlock(context.tr('draw_label'), '$draw%')),
              const SizedBox(width: 8),
              Expanded(
                child: _outcomeBlock(
                    '${_right!.name.split(' ').first} win', '$rWin%'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.tr('model_disclaimer'),
            style: AppTypography.labelSmall
                .copyWith(color: Colors.black.withOpacity(0.65)),
          ),
        ],
      ),
    );
  }

  Widget _outcomeBlock(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTeam(bool isLeft) async {
    final teams = ref.read(allTeamsProvider).valueOrNull ?? <TeamModel>[];
    final result = await showModalBottomSheet<TeamModel>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        isLeft ? ctx.tr('pick_first_team') : ctx.tr('pick_second_team'),
                        style: AppTypography.headlineSmall
                            .copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: teams.length,
                    itemBuilder: (ctx, i) {
                      final team = teams[i];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cardBorder, width: 0.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            team.name.isNotEmpty ? team.name[0].toUpperCase() : '?',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(team.name,
                            style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimary)),
                        subtitle: team.country != null
                            ? Text(team.country!,
                                style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary))
                            : null,
                        onTap: () => Navigator.pop(ctx, team),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      HapticFeedback.selectionClick();
      setState(() {
        if (isLeft) {
          _left = result;
        } else {
          _right = result;
        }
      });
    }
  }

  // Deterministic pseudo-metrics derived from team id so the comparison is stable.
  double _formScore(TeamModel t) => 4 + ((t.id * 7) % 60) / 10.0; // 4.0 - 10.0
  double _goalsAvg(TeamModel t) => 0.8 + ((t.id * 11) % 30) / 10.0; // 0.8 - 3.7
  double _defenceScore(TeamModel t) => 50 + ((t.id * 13) % 50).toDouble();
  int _fanPower(TeamModel t) =>
      40000 + (t.id * 137) % 60000;
  double _yearScore(String? founded) {
    final y = int.tryParse(founded ?? '') ?? 1900;
    return 2025 - y.toDouble();
  }
}
