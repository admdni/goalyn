import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/editorial.dart';
import '../../../../services/favorites_service.dart';
import '../../../../services/predictions_service.dart';
import '../../../../services/notes_service.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/onboarding_service.dart';
import '../../../home/presentation/providers/match_providers.dart';
import '../../../home/data/models/team_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(predictionStatsProvider);
    final favorites = ref.watch(favoritesProvider);
    final notes = ref.watch(notesProvider);
    final reminders = NotificationService.instance.getAllReminders();
    final name = OnboardingService.instance.displayName ?? context.tr('football_fan');
    final favTeams = (ref.watch(allTeamsProvider).valueOrNull ?? <TeamModel>[])
        .where((t) => favorites.teams.contains(t.id))
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            _buildEditorialMasthead(name, stats),
            _buildEditorialHero(name, stats),
            const EditorialDivider(),
            _buildStatColumns(stats, favorites, notes.length, reminders.length),
            const EditorialDivider(),
            _buildBadgeSection(stats),
            const EditorialDivider(),
            _buildFavoriteTeamsSection(favTeams),
            const EditorialDivider(),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorialMasthead(String name, PredictionStats stats) {
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
                'No. 03 — THE PROFILE',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _editName,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 2, color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildEditorialHero(String name, PredictionStats stats) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TagChip(
                  label: stats.rank,
                  color: AppColors.primary,
                  icon: Icons.workspace_premium_rounded),
              const SizedBox(width: 8),
              TagChip(
                  label: context.tr('member'),
                  color: AppColors.textSecondary,
                  icon: Icons.verified_user_outlined),
            ],
          ),
          const SizedBox(height: 14),
          EditorialHeadline(name, fontSize: 44),
          const SizedBox(height: 8),
          EditorialDeck(
            stats.total > 0
                ? 'A reader of the game with ${stats.total} predictions and ${stats.exact} exact calls.'
                : 'A reader of the game — no predictions on file. The pen is yours.',
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              EditorialFigure(
                value: '${stats.points}',
                label: context.tr('total_points'),
                color: AppColors.primary,
                valueSize: 72,
              ),
              const Spacer(),
              EditorialFigure(
                value: '${stats.currentStreak}',
                label: context.tr('streak'),
                valueSize: 36,
                color: AppColors.warning,
                alignment: CrossAxisAlignment.end,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumns(PredictionStats stats, FavoritesState fav,
      int notesCount, int remindersCount) {
    final entries = <_Stat>[
      _Stat(context.tr('predictions'), '${stats.total}'),
      _Stat(context.tr('accuracy'), '${stats.accuracy.toStringAsFixed(0)}%'),
      _Stat(context.tr('best_streak'), '${stats.bestStreak}'),
      _Stat(context.tr('exact_picks'), '${stats.exact}'),
      _Stat(context.tr('favorite_teams'), '${fav.teams.length}'),
      _Stat(context.tr('match_notes'), '$notesCount'),
      _Stat(context.tr('reminders'), '$remindersCount'),
      _Stat(context.tr('saved_leagues'), '${fav.leagues.length}'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionKicker(
            label: 'The numbers',
            issue: 'I',
            padding: EdgeInsets.only(bottom: 14),
          ),
          ...entries.map((e) => _editorialStatRow(e)),
        ],
      ),
    );
  }

  Widget _editorialStatRow(_Stat stat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              stat.label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 40,
              height: 0.5,
              color: AppColors.cardBorder,
            ),
          ),
          Text(
            stat.value,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeSection(PredictionStats stats) {
    final badges = <_Badge>[
      _Badge(context.tr('first_pick'), stats.total >= 1, Icons.flag_outlined),
      _Badge(context.tr('sharp_eye'), stats.outcomeCorrect >= 5, Icons.visibility_rounded),
      _Badge(context.tr('bullseye'), stats.exact >= 1, Icons.center_focus_strong_rounded),
      _Badge(context.tr('streak_3'), stats.bestStreak >= 3,
          Icons.local_fire_department_rounded),
      _Badge(context.tr('streak_5'), stats.bestStreak >= 5, Icons.whatshot_rounded),
      _Badge(context.tr('pundit'), stats.points >= 20, Icons.workspace_premium_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionKicker(
            label: 'Awards & honours',
            issue: 'II',
            padding: EdgeInsets.only(bottom: 14),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badges.map((b) => _buildBadgeChip(b)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeChip(_Badge b) {
    final color = b.unlocked ? AppColors.primary : AppColors.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: b.unlocked ? Colors.transparent : AppColors.surface,
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(b.icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            b.name.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteTeamsSection(List teams) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionKicker(
                  label: 'Followed sides',
                  issue: 'III',
                  padding: EdgeInsets.zero,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/favorites'),
                child: Text(
                  '${context.tr('manage')} →',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (teams.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                context.tr('no_favorites'),
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            )
          else
            SizedBox(
              height: 78,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: teams.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (ctx, i) {
                  final t = teams[i];
                  return GestureDetector(
                    onTap: () => context.push(
                        '/team/${t.id}?name=${Uri.encodeComponent(t.name)}'),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cardBorder, width: 0.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            t.name.isNotEmpty ? t.name[0].toUpperCase() : '?',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 60,
                          child: Text(
                            t.name.split(' ').first,
                            style: AppTypography.labelSmall
                                .copyWith(color: AppColors.textPrimary),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionKicker(
            label: 'In this issue',
            issue: 'IV',
            padding: EdgeInsets.only(bottom: 14),
          ),
          _editorialAction('01', context.tr('make_prediction'),
              context.tr('make_prediction_desc'), Icons.east_rounded,
              () => context.push('/predictions')),
          _editorialAction('02', context.tr('compare_teams'),
              context.tr('compare_teams_desc'), Icons.east_rounded,
              () => context.push('/compare')),
          _editorialAction('03', context.tr('reset_onboarding'),
              context.tr('reset_onboarding_desc'), Icons.refresh_rounded,
              () async {
            await OnboardingService.instance.reset();
            if (mounted) context.go('/onboarding');
          }),
        ],
      ),
    );
  }

  Widget _editorialAction(
      String num, String title, String sub, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  num,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(icon, size: 18, color: AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editName() async {
    final controller = TextEditingController(
        text: OnboardingService.instance.displayName ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(context.tr('display_name')),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 24,
          decoration: InputDecoration(
            hintText: context.tr('your_nickname'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await Hive.box('settings').put('display_name', result);
      if (mounted) setState(() {});
    }
  }
}

class _Badge {
  final String name;
  final bool unlocked;
  final IconData icon;
  const _Badge(this.name, this.unlocked, this.icon);
}

class _Stat {
  final String label;
  final String value;
  const _Stat(this.label, this.value);
}
