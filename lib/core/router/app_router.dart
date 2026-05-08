import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../i18n/app_localizations.dart';
import '../theme/app_palette.dart';
import '../theme/app_typography.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/live/presentation/screens/live_screen.dart';
import '../../features/news/presentation/screens/news_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/match_detail/presentation/screens/match_detail_screen.dart';
import '../../features/league/presentation/screens/league_screen.dart';
import '../../features/team/presentation/screens/team_screen.dart';
import '../../features/news/presentation/screens/news_detail_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/predictions/presentation/screens/predictions_screen.dart';
import '../../features/compare/presentation/screens/compare_screen.dart';
import '../../services/onboarding_service.dart';
import '../../shared/widgets/connectivity_banner.dart';
import '../theme/app_theme.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final completed = OnboardingService.instance.isCompleted;
      final goingToOnboarding = state.matchedLocation == '/onboarding';
      if (!completed && !goingToOnboarding) return '/onboarding';
      if (completed && goingToOnboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/live',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const LiveScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/news',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const NewsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/favorites',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const FavoritesScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/match/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final matchId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return CustomTransitionPage(
            key: state.pageKey,
            child: MatchDetailScreen(matchId: matchId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/league/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final leagueId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          final leagueName = state.uri.queryParameters['name'] ?? 'League';
          return CustomTransitionPage(
            key: state.pageKey,
            child: LeagueScreen(leagueId: leagueId, leagueName: leagueName),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/team/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final teamId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          final teamName = state.uri.queryParameters['name'] ?? 'Team';
          return CustomTransitionPage(
            key: state.pageKey,
            child: TeamScreen(teamId: teamId, teamName: teamName),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/news/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final articleId = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: NewsDetailScreen(articleId: articleId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SearchScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/predictions',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PredictionsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/compare',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CompareScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
    ],
  );
}

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _routes = ['/home', '/live', '/news', '/favorites', '/settings'];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    _currentIndex = _routes.indexOf(location);
    if (_currentIndex < 0) _currentIndex = 0;

    final p = context.palette;
    return Scaffold(
      body: ConnectivityBanner(
        onReconnect: () {
          // Could trigger refresh here if needed
        },
        child: widget.child,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: p.background,
          border: Border(
            top: BorderSide(color: p.line, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, context.tr('nav_home')),
                _buildNavItem(1, Icons.bolt_outlined, Icons.bolt_rounded, context.tr('nav_live')),
                _buildNavItem(2, Icons.article_outlined, Icons.article_rounded, context.tr('nav_news')),
                _buildNavItem(3, Icons.bookmark_outline_rounded, Icons.bookmark_rounded, context.tr('nav_saved')),
                _buildNavItem(4, Icons.menu_rounded, Icons.menu_rounded, context.tr('nav_more')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final p = context.palette;
    final isSelected = _currentIndex == index;
    final color = isSelected ? p.textPrimary : p.textTertiary;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        context.go(_routes[index]);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: AppType.eyebrow(
                size: 9,
                color: color,
                letterSpacing: 1.4,
                weight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
