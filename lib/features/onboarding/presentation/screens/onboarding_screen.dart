import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/editorial.dart';
import '../../../../services/favorites_service.dart';
import '../../../home/presentation/providers/match_providers.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/onboarding_service.dart';
import '../../../home/data/models/team_model.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  int _page = 0;
  final Set<int> _selectedTeamIds = {};
  bool _enableNotifs = true;
  bool _busy = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgress(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _buildWelcomePage(),
                  _buildNamePage(),
                  _buildTeamPickerPage(),
                  _buildNotificationsPage(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: List.generate(4, (i) {
          final active = i <= _page;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              height: 4,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                context.tr('issue_01'),
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                    height: 1,
                    color: AppColors.cardBorder),
              ),
            ],
          ),
          const SizedBox(height: 16),
          EditorialHeadline(context.tr('welcome_to'), fontSize: 50),
          const SizedBox(height: 12),
          EditorialDeck(
            context.tr('welcome_desc'),
          ),
          const SizedBox(height: 28),
          Container(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 18),
          Text(
            context.tr('in_this_issue'),
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 14),
          _editorialBullet('01', context.tr('live_scores'),
              context.tr('live_scores_desc')),
          _editorialBullet('02', context.tr('score_predictions'),
              context.tr('score_predictions_desc')),
          _editorialBullet('03', context.tr('kickoff_reminders'),
              context.tr('kickoff_reminders_desc')),
          _editorialBullet('04', context.tr('match_notebook'),
              context.tr('match_notebook_desc')),
        ],
      ),
    );
  }

  Widget _editorialBullet(String num, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
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
        ],
      ),
    );
  }


  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('chapter_one'),
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          EditorialHeadline(context.tr('what_call_you'), fontSize: 38),
          const SizedBox(height: 12),
          EditorialDeck(
            context.tr('nickname_desc'),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _nameController,
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: context.tr('name_hint'),
              prefixIcon: const Icon(Icons.person_outline_rounded,
                  color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            textInputAction: TextInputAction.done,
            maxLength: 24,
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('optional_skip'),
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamPickerPage() {
    final teams = ref.watch(allTeamsProvider).valueOrNull ?? <TeamModel>[];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('chapter_two'),
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          EditorialHeadline(context.tr('pick_your_sides'), fontSize: 38),
          const SizedBox(height: 8),
          EditorialDeck(
            '${_selectedTeamIds.length} selected — start with the clubs you can\'t live without.',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                final selected = _selectedTeamIds.contains(team.id);
                return _buildTeamTile(team, selected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamTile(TeamModel team, bool selected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          if (selected) {
            _selectedTeamIds.remove(team.id);
          } else {
            _selectedTeamIds.add(team.id);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.cardBorder,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.cardBorder,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                team.name.isNotEmpty ? team.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              team.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall.copyWith(
                color: selected
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('chapter_three'),
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          EditorialHeadline(context.tr('stay_in_loop'), fontSize: 38),
          const SizedBox(height: 12),
          EditorialDeck(
            context.tr('quiet_alert_desc'),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.cardBorder, width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.alarm_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr('pre_match_reminders'),
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textPrimary),
                  ),
                ),
                Switch.adaptive(
                  value: _enableNotifs,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _enableNotifs = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final isLast = _page == 3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Row(
        children: [
          if (_page > 0)
            TextButton(
              onPressed: _busy
                  ? null
                  : () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    },
              child: Text(context.tr('back')),
            )
          else if (_page == 1 || _page == 2)
            TextButton(
              onPressed: _busy ? null : _next,
              child: Text(context.tr('skip')),
            )
          else
            const SizedBox.shrink(),
          const Spacer(),
          ElevatedButton(
            onPressed: _busy
                ? null
                : () {
                    if (isLast) {
                      _finish();
                    } else {
                      _next();
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black),
                  )
                : Text(
                    isLast ? context.tr('get_started') : context.tr('continue_btn'),
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textInverse,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    HapticFeedback.mediumImpact();
    setState(() => _busy = true);

    final favs = ref.read(favoritesProvider.notifier);
    await favs.setTeams(_selectedTeamIds);

    if (_enableNotifs) {
      await NotificationService.instance.requestPermissions();
    }

    await OnboardingService.instance.markCompleted(
      displayName: _nameController.text,
      notificationsEnabled: _enableNotifs,
    );

    if (!mounted) return;
    context.go('/home');
  }
}
