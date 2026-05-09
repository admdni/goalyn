import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('zh'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App
      'app_name': 'Goalyn',
      'tagline': 'Your Football Companion',

      // Navigation
      'nav_home': 'Home',
      'nav_live': 'Live',
      'nav_news': 'News',
      'nav_favorites': 'Favorites',
      'nav_settings': 'Settings',

      // Home
      'featured_matches': 'Featured Matches',
      'todays_matches': "Today's Matches",
      'top_leagues': 'Top Leagues',
      'trending_news': 'Trending News',
      'upcoming': 'Upcoming Fixtures',
      'no_matches': 'No matches today',
      'check_back_matches': 'Check back later for matches',
      'see_all': 'See All',
      'live_now': 'Live Now',

      // Live
      'live': 'Live',
      'finished': 'Finished',
      'upcoming_filter': 'Upcoming',
      'no_live_matches': 'No live matches right now',
      'no_finished': 'No finished matches',
      'no_upcoming': 'No upcoming matches',
      'matches_label': 'Matches',
      'active_count': 'active',
      'check_back_live': 'Check back later for live matches',
      'no_finished_today': 'No finished matches today',
      'no_upcoming_matches': 'No upcoming matches',

      // Match Detail
      'overview': 'Overview',
      'stats': 'Statistics',
      'lineups': 'Lineups',
      'events': 'Events',
      'h2h': 'Head to Head',
      'formation': 'Formation',
      'stadium': 'Stadium',
      'referee': 'Referee',
      'possession': 'Possession',
      'shots': 'Shots',
      'shots_on_target': 'Shots on Target',
      'corners': 'Corners',
      'fouls': 'Fouls',
      'offsides': 'Offsides',
      'yellow_cards': 'Yellow Cards',
      'red_cards': 'Red Cards',
      'passes': 'Passes',
      'starting_xi': 'Starting XI',
      'substitutes': 'Substitutes',
      'coach': 'Coach',
      'head_to_head': 'Head to Head',
      'recent_results': 'Recent Results',
      'all_time': 'All Time',
      'no_events': 'No events yet',
      'no_statistics': 'No statistics',
      'stats_available_after': 'Statistics will be available after the match',
      'date_label': 'Date',
      'match_statistics': 'Match Statistics',
      'lineups_available_later': 'Lineups will be available once confirmed',
      'events_will_appear': 'Match events will appear here',
      'unknown_player': 'Unknown',

      // Events
      'goal': 'Goal',
      'own_goal': 'Own Goal',
      'penalty': 'Penalty',
      'missed_penalty': 'Missed Penalty',
      'substitution': 'Substitution',
      'yellow_card': 'Yellow Card',
      'red_card': 'Red Card',
      'var_decision': 'VAR',

      // News (sample categories — fictional)
      'all_news': 'All',
      'transfers': 'Transfers',
      'premier_league': 'Top Flight',
      'champions_league': 'Continental Cup',
      'turkish_football': 'Anatoria',
      'world_football': 'World Football',
      'no_news': 'No news available',
      'latest_updates': 'Latest updates from around the world',
      'check_back_news': 'Check back later for news',
      'read_more': 'Read More',
      'share': 'Share',
      'save': 'Save',
      'saved': 'Saved',
      'min_read': 'min read',
      'featured': 'Featured',

      // Search
      'search': 'Search',
      'search_hint': 'Search teams, leagues, matches...',
      'no_results': 'No results found',
      'teams': 'Teams',
      'leagues': 'Leagues',
      'matches': 'Matches',
      'recent_searches': 'Recent Searches',

      // Favorites
      'no_favorites': 'No favorites yet',
      'add_favorites_hint': 'Tap the heart icon on any match,\nteam, or league to add it here',
      'favorite_teams': 'Favorite Teams',
      'favorite_matches': 'Favorite Matches',
      'favorite_leagues': 'Favorite Leagues',

      // Settings
      'appearance': 'Appearance',
      'dark_mode': 'Dark Mode',
      'notifications': 'Notifications',
      'match_reminders': 'Match Reminders',
      'goal_alerts': 'Goal Alerts',
      'transfer_news': 'Transfer News',
      'language': 'Language',
      'english': 'English',
      'chinese': 'Chinese',
      'dark_mode_desc': 'Use dark theme throughout the app',
      'match_reminders_desc': 'Get notified before your favorite matches',
      'goal_alerts_desc': 'Instant notifications for goals',
      'transfer_news_desc': 'Breaking transfer news alerts',
      'free_storage': 'Free up storage space',
      'read_privacy': 'Read our privacy policy',
      'read_terms': 'Read our terms',
      'clear_cache': 'Clear Cache',
      'about': 'About',
      'privacy_policy': 'Privacy Policy',
      'terms': 'Terms of Service',
      'app_version': 'App Version',
      'cache_cleared': 'Cache cleared successfully',
      'data': 'Data',

      // League
      'standings': 'Standings',
      'league_matches': 'Matches',
      'position': '#',
      'played': 'P',
      'won': 'W',
      'drawn': 'D',
      'lost': 'L',
      'gd': 'GD',
      'pts': 'Pts',
      'champions_league_zone': 'Top Cup',
      'europa_zone': 'Series Cup',
      'relegation_zone': 'Relegation',

      // Team
      'team_info': 'Team Info',
      'founded': 'Founded',
      'capacity': 'Capacity',
      'recent_matches': 'Recent Matches',
      'win': 'W',
      'loss': 'L',
      'draw': 'D',

      // General
      'error': 'Error',
      'retry': 'Retry',
      'loading': 'Loading...',
      'no_internet': 'No internet connection',
      'something_went_wrong': 'Something went wrong',
      'try_again': 'Try Again',
      'ht': 'HT',
      'ft': 'FT',
      'et': 'ET',
      'pen': 'PEN',
      'vs': 'VS',
      'home': 'Home',
      'away': 'Away',
      'tbd': 'TBD',
      'postponed': 'Postponed',
      'cancelled': 'Cancelled',

      // Profile
      'total_points': 'Total points',
      'best_streak': 'Best streak',
      'exact_picks': 'Exact picks',
      'match_notes': 'Match notes',
      'reminders': 'Reminders',
      'member': 'Member',
      'football_fan': 'Football Fan',
      'first_pick': 'First pick',
      'sharp_eye': 'Sharp eye',
      'bullseye': 'Bullseye',
      'pundit': 'Pundit',
      'make_prediction': 'Make a prediction',
      'make_prediction_desc': 'Pick a score for the next match',
      'compare_teams_desc': 'See how two clubs stack up',
      'reset_onboarding_desc': 'Pick favourite teams again',
      'manage': 'Manage',

      // Home Screen
      'goalyn_daily': 'Goalyn Daily',
      'in_play': 'IN PLAY',
      'full_time': 'Full time',
      'featured_today': 'Featured · today',
      'kicks_off_at': 'Kicks off at',
      'final_label': 'Final',
      'read_story': 'Read story',
      'predict': 'Predict',
      'pick_scores': 'Pick scores · earn pts',
      'compare': 'Compare',
      'two_teams': 'Two teams · numbers',
      'teams_matches': 'Teams · matches',
      'games_count': 'games',
      'competitions': 'Competitions',
      'match_calendar': 'MATCH CALENDAR',
      'today': 'TODAY',
      'the_match_desk': 'The match desk',
      'no_matches_section': 'No matches in this section.',
      'scheduled': 'Scheduled',

      // Live Screen
      'live_coverage': 'Live coverage',
      'no_live': 'NO LIVE',
      'stadium_feed': 'Stadium feed.',
      'live_description': 'Goals, cards and substitutions as they happen across leagues.',
      'no_live_description': 'Nothing kicking off right now. Check upcoming and finished tabs.',
      'quiet_on_wire': 'Quiet on the wire.',
      'try_another_tab': 'Try another tab — fresh matches coming.',

      // News Screen
      'front_page': 'Front page',
      'the_wire': 'The wire.',
      'stories_curated': 'stories from across the football world, curated by hand.',
      'all': 'All',
      'epl': 'EPL',
      'ucl': 'UCL',
      'world': 'World',
      'lead_story': 'Lead story',
      'min_read_label': 'MIN READ',

      // Search Screen
      'search_teams_leagues': 'Search teams, leagues…',
      'no_matches_found': 'No matches.',
      'try_search_hint': 'Try a club, country or league.',
      'try_searching': 'Try searching',
      'popular_clubs': 'Popular clubs',

      // Match Detail
      'failed_load_match': 'Failed to load match',
      'match_label': 'MATCH',
      'full_time_label': 'FULL TIME',
      'kick_off': 'KICK-OFF',
      'match_facts': 'Match facts',
      'formations': 'Formations',
      'match_info': 'Match info',
      'competition': 'Competition',
      'country': 'Country',
      'season': 'Season',
      'elapsed': 'Elapsed',
      'key_numbers': 'Key numbers',
      'goals': 'Goals',
      'your_pick': 'Your pick',
      'note': 'Note',
      'predict_label': 'Predict',
      'reminded': 'Reminded',
      'remind': 'Remind',
      'pick_the_score': 'Pick the score.',
      'save_pick': 'SAVE PICK',
      'match_note': 'Match note',
      'a_private_line': 'A private line.',
      'note_hint': 'Tactics, key players, takeaways…',
      'delete': 'DELETE',
      'no_stats_yet': 'No statistics yet.',
      'available_after_kickoff': 'Available after kickoff.',
      'no_lineups_yet': 'No lineups yet.',
      'lineups_before_kickoff': 'Confirmed an hour before kick-off.',
      'no_events_yet': 'No events yet.',
      'events_appear_here': 'Goals, cards, subs appear here.',
      'reminder_cancelled': 'Reminder cancelled',
      'enable_notifications_hint': 'Enable notifications in system settings to get reminders.',
      'reminder_set': 'Reminder set 15 min before kickoff',
      'could_not_schedule': 'Could not schedule',
      'update_prediction': 'Update prediction',
      'predict_score': 'Predict score',

      // Settings
      'settings': 'Settings',
      'preferences': 'Preferences.',
      'view_profile': 'VIEW PROFILE & PREDICTIONS',
      'system_theme': 'System',
      'light_theme': 'Light',
      'dark_theme': 'Dark',
      'reminders_15min': 'Notifications 15 min before kickoff',
      'live_goal_notif': 'Live notifications when goals happen',
      'breaking_transfers': 'Breaking transfer headlines',
      'send_test_notif': 'Send test notification',
      'verify_works': 'Verify it works on this device',
      'test_sent': 'Test notification sent',
      'notif_works': 'Notifications work.',
      'free_up_storage': 'Free up storage',
      'reset_onboarding': 'Reset onboarding',
      'pick_teams_again': 'Pick favourite teams again',
      'version': 'Version',

      // Favorites
      'my_library': 'My library',
      'tap_bookmark_hint': 'Tap the bookmark icon to add items.',

      // Team
      'fact_sheet': 'Fact sheet',
      'last_five': 'Last five',

      // League
      'standings_desc': 'Standings updated daily — top of the table to relegation.',

      // Onboarding
      'issue_01': 'ISSUE 01',
      'welcome_to': 'Welcome to\nGoalyn.',
      'welcome_desc': 'A pocket-sized sports magazine — built for the fan who reads, predicts, and remembers every result.',
      'in_this_issue': 'IN THIS ISSUE',
      'live_scores': 'Live scores',
      'live_scores_desc': 'Goals and key events as they happen.',
      'score_predictions': 'Score predictions',
      'score_predictions_desc': 'Pick the result before kickoff. Earn points.',
      'kickoff_reminders': 'Kickoff reminders',
      'kickoff_reminders_desc': 'Smart alerts before the matches you care about.',
      'match_notebook': 'Match notebook',
      'match_notebook_desc': 'A private place for tactics, takeaways, and reactions.',
      'chapter_one': 'CHAPTER ONE',
      'what_call_you': 'What should\nwe call you?',
      'nickname_desc': 'Your nickname appears on your profile and on your prediction record.',
      'name_hint': 'e.g. Footy Master',
      'optional_skip': 'Optional — you can skip this step.',
      'chapter_two': 'CHAPTER TWO',
      'pick_your_sides': 'Pick your\nsides.',
      'selected_count': 'selected — start with the clubs you can\'t live without.',
      'chapter_three': 'CHAPTER THREE',
      'stay_in_loop': 'Stay in\nthe loop.',
      'quiet_alert_desc': 'A quiet alert 15 minutes before every kickoff that matters to you. Toggle it any time in Settings.',
      'pre_match_reminders': 'Pre-match reminders',
      'back': 'Back',
      'skip': 'Skip',
      'continue_btn': 'Continue',
      'get_started': 'Get Started',

      // Connectivity
      'no_connection': 'NO CONNECTION · SHOWING CACHED DATA',
      'back_online': 'BACK ONLINE · REFRESHING',

      // Bottom Nav
      'nav_saved': 'Saved',
      'nav_more': 'More',

      // Compare
      'compare_teams': 'Compare teams',

      // Profile
      'profile': 'Profile',

      // Predictions
      'predictions': 'Predictions',
      'my_picks': 'My Picks',
      'history': 'History',

      // League (additional)
      'club': 'CLUB',
      'pl': 'PL',
      'no_standings': 'No standings available.',
      'champions': 'Champions',
      'europa': 'Europa',
      'relegation': 'Relegation',

      // Profile (additional)
      'saved_leagues': 'Saved leagues',
      'display_name': 'Display name',
      'your_nickname': 'Your nickname',
      'cancel': 'Cancel',

      // Predictions (additional)
      'no_matches_predict': 'No matches to predict',
      'check_back_fixtures': 'Check back when fixtures are scheduled',
      'no_active_picks': 'No active picks',
      'make_prediction_hint': 'Make a prediction from upcoming matches',
      'no_history_yet': 'No history yet',
      'resolve_hint': 'Resolve predictions with actual scores to build your record',
      'enter_actual_score': 'Enter actual score',
      'save_prediction': 'Save prediction',
      'resolve_actual': 'Resolve with actual score',
      'remove_prediction': 'Remove prediction',
      'resolve': 'Resolve',

      // Compare (additional)
      'compare_the_sides': 'Compare\nthe sides.',
      'compare_desc': 'A side-by-side editorial breakdown — pick two clubs and read the tale of the tape.',
      'form_last_10': 'Form (last 10)',
      'goals_per_match': 'Goals per match',
      'defensive_rating': 'Defensive rating',
      'fan_power': 'Fan power',
      'stadium_capacity': 'Stadium capacity',
      'draw_label': 'Draw',
      'model_disclaimer': 'Indicative model based on form, goals, and defensive ratings — not betting advice.',

      // Team (additional)
      'storied_club': 'A storied football club.',

      // Favorites (additional)
      'saved_title': 'Saved.',
      'favorites_desc': 'Teams, matches and leagues you follow.',
      'favorites_empty_hint': 'Tap the bookmark icon anywhere to start your library.',
      'no_teams_saved': 'No teams saved yet.',
      'no_matches_saved': 'No matches saved yet.',
      'no_leagues_saved': 'No leagues saved yet.',

      // Shared
      'view_details': 'View details',
      'share_score': 'Share score',

      // News Detail
      'full_article_hint': 'Full article available on the source.',

      // Match Line
      'in_play_tap': 'In play · tap to follow',

      // Predictions (screen)
      'predict_the_score': 'Predict the score',
      'prediction_scoring_hint': 'Earn 3 pts for an exact score, 1 pt for the right outcome.',
      'predictions_deck': 'Score the matches before they happen — an evolving record of your sharpness.',
      'points': 'Points',
      'accuracy': 'Accuracy',
      'exact': 'Exact',
      'best_run': 'Best run',
      'streak': 'Streak',
      'predicted': 'Predicted',
      'actual': 'Actual',

      // Compare (screen)
      'the_numbers': 'The numbers',
      'editorial_verdict': 'Editorial verdict',
      'predicted_outcome': 'Predicted outcome',
      'pick_team': 'Pick team',
      'pick_first_team': 'Pick first team',
      'pick_second_team': 'Pick second team',
    },
    'zh': {
      // App
      'app_name': 'Goalyn',
      'tagline': '您的足球伴侣',

      // Navigation
      'nav_home': '首页',
      'nav_live': '直播',
      'nav_news': '新闻',
      'nav_favorites': '收藏',
      'nav_settings': '设置',

      // Home
      'featured_matches': '精选比赛',
      'todays_matches': '今日比赛',
      'top_leagues': '热门联赛',
      'trending_news': '热门新闻',
      'upcoming': '即将开始',
      'no_matches': '今日无比赛',
      'check_back_matches': '稍后再来查看比赛',
      'see_all': '查看全部',
      'live_now': '直播中',

      // Live
      'live': '直播',
      'finished': '已结束',
      'upcoming_filter': '即将开始',
      'no_live_matches': '暂无直播比赛',
      'no_finished': '暂无已结束比赛',
      'no_upcoming': '暂无即将开始的比赛',
      'matches_label': '比赛',
      'active_count': '进行中',
      'check_back_live': '稍后再来查看直播比赛',
      'no_finished_today': '今日暂无已结束比赛',
      'no_upcoming_matches': '暂无即将开始的比赛',

      // Match Detail
      'overview': '概览',
      'stats': '数据统计',
      'lineups': '阵容',
      'events': '事件',
      'h2h': '交锋记录',
      'formation': '阵型',
      'stadium': '球场',
      'referee': '裁判',
      'possession': '控球率',
      'shots': '射门',
      'shots_on_target': '射正',
      'corners': '角球',
      'fouls': '犯规',
      'offsides': '越位',
      'yellow_cards': '黄牌',
      'red_cards': '红牌',
      'passes': '传球',
      'starting_xi': '首发阵容',
      'substitutes': '替补',
      'coach': '教练',
      'head_to_head': '交锋记录',
      'recent_results': '近期战绩',
      'all_time': '历史交锋',
      'no_events': '暂无事件',
      'no_statistics': '暂无统计数据',
      'stats_available_after': '比赛结束后将提供统计数据',
      'date_label': '日期',
      'match_statistics': '比赛统计',
      'lineups_available_later': '阵容确认后将显示',
      'events_will_appear': '比赛事件将在此显示',
      'unknown_player': '未知',

      // Events
      'goal': '进球',
      'own_goal': '乌龙球',
      'penalty': '点球',
      'missed_penalty': '点球失球',
      'substitution': '换人',
      'yellow_card': '黄牌',
      'red_card': '红牌',
      'var_decision': 'VAR',

      // News
      'all_news': '全部',
      'transfers': '转会',
      'premier_league': '顶级联赛',
      'champions_league': '洲际杯赛',
      'turkish_football': '安纳托利亚',
      'world_football': '世界足球',
      'no_news': '暂无新闻',
      'latest_updates': '来自世界各地的最新动态',
      'check_back_news': '稍后再来查看新闻',
      'read_more': '阅读更多',
      'share': '分享',
      'save': '收藏',
      'saved': '已收藏',
      'min_read': '分钟阅读',
      'featured': '精选',

      // Search
      'search': '搜索',
      'search_hint': '搜索球队、联赛、比赛...',
      'no_results': '未找到结果',
      'teams': '球队',
      'leagues': '联赛',
      'matches': '比赛',
      'recent_searches': '最近搜索',

      // Favorites
      'no_favorites': '暂无收藏',
      'add_favorites_hint': '点击任意比赛、球队或联赛的\n心形图标即可添加收藏',
      'favorite_teams': '收藏的球队',
      'favorite_matches': '收藏的比赛',
      'favorite_leagues': '收藏的联赛',

      // Settings
      'appearance': '外观',
      'dark_mode': '深色模式',
      'notifications': '通知',
      'match_reminders': '比赛提醒',
      'goal_alerts': '进球通知',
      'transfer_news': '转会新闻',
      'language': '语言',
      'english': '英语',
      'chinese': '中文',
      'dark_mode_desc': '在整个应用中使用深色主题',
      'match_reminders_desc': '在您喜欢的比赛开始前收到通知',
      'goal_alerts_desc': '即时进球通知',
      'transfer_news_desc': '最新转会新闻提醒',
      'free_storage': '释放存储空间',
      'read_privacy': '阅读我们的隐私政策',
      'read_terms': '阅读我们的服务条款',
      'clear_cache': '清除缓存',
      'about': '关于',
      'privacy_policy': '隐私政策',
      'terms': '服务条款',
      'app_version': '应用版本',
      'cache_cleared': '缓存已清除',
      'data': '数据',

      // League
      'standings': '积分榜',
      'league_matches': '比赛',
      'position': '#',
      'played': '场',
      'won': '胜',
      'drawn': '平',
      'lost': '负',
      'gd': '净胜',
      'pts': '积分',
      'champions_league_zone': '顶级杯赛区',
      'europa_zone': '次级杯赛区',
      'relegation_zone': '降级区',

      // Team
      'team_info': '球队信息',
      'founded': '成立时间',
      'capacity': '容纳人数',
      'recent_matches': '近期比赛',
      'win': '胜',
      'loss': '负',
      'draw': '平',

      // General
      'error': '错误',
      'retry': '重试',
      'loading': '加载中...',
      'no_internet': '无网络连接',
      'something_went_wrong': '出错了',
      'try_again': '重试',
      'ht': '半场',
      'ft': '全场',
      'et': '加时',
      'pen': '点球',
      'vs': 'VS',
      'home': '主场',
      'away': '客场',
      'tbd': '待定',
      'postponed': '延期',
      'cancelled': '取消',

      // Profile
      'total_points': '总积分',
      'best_streak': '最佳连胜',
      'exact_picks': '精准预测',
      'match_notes': '比赛笔记',
      'reminders': '提醒',
      'member': '会员',
      'football_fan': '球迷',
      'first_pick': '首次预测',
      'sharp_eye': '火眼金睛',
      'bullseye': '百发百中',
      'pundit': '专家',
      'make_prediction': '进行预测',
      'make_prediction_desc': '为下一场比赛预测比分',
      'compare_teams_desc': '看两支球队的数据对比',
      'reset_onboarding_desc': '重新选择喜爱的球队',
      'manage': '管理',

      // Home Screen
      'goalyn_daily': '飞饼体育日报',
      'in_play': '进行中',
      'full_time': '全场结束',
      'featured_today': '精选 · 今日',
      'kicks_off_at': '开球时间',
      'final_label': '终场',
      'read_story': '阅读详情',
      'predict': '预测',
      'pick_scores': '预测比分 · 赚积分',
      'compare': '对比',
      'two_teams': '两队 · 数据',
      'teams_matches': '球队 · 比赛',
      'games_count': '场比赛',
      'competitions': '赛事',
      'match_calendar': '比赛日历',
      'today': '今天',
      'the_match_desk': '比赛中心',
      'no_matches_section': '本栏目暂无比赛。',
      'scheduled': '已安排',

      // Live Screen
      'live_coverage': '实况报道',
      'no_live': '无直播',
      'stadium_feed': '球场直播。',
      'live_description': '各联赛进球、红黄牌和换人实时更新。',
      'no_live_description': '当前没有比赛进行中。请查看即将开始和已结束标签。',
      'quiet_on_wire': '暂时没有动态。',
      'try_another_tab': '换个标签看看 — 新比赛即将到来。',

      // News Screen
      'front_page': '头版',
      'the_wire': '新闻速递。',
      'stories_curated': '篇来自全球足球世界的精选报道。',
      'all': '全部',
      'epl': '英超',
      'ucl': '欧冠',
      'world': '世界',
      'lead_story': '头条新闻',
      'min_read_label': '分钟阅读',

      // Search Screen
      'search_teams_leagues': '搜索球队、联赛…',
      'no_matches_found': '无匹配结果。',
      'try_search_hint': '试试搜索俱乐部、国家或联赛。',
      'try_searching': '试试搜索',
      'popular_clubs': '热门俱乐部',

      // Match Detail
      'failed_load_match': '加载比赛失败',
      'match_label': '比赛',
      'full_time_label': '全场结束',
      'kick_off': '开球',
      'match_facts': '比赛信息',
      'formations': '阵型',
      'match_info': '比赛详情',
      'competition': '赛事',
      'country': '国家',
      'season': '赛季',
      'elapsed': '已进行',
      'key_numbers': '关键数据',
      'goals': '进球',
      'your_pick': '你的预测',
      'note': '笔记',
      'predict_label': '预测',
      'reminded': '已提醒',
      'remind': '提醒',
      'pick_the_score': '选择比分。',
      'save_pick': '保存预测',
      'match_note': '比赛笔记',
      'a_private_line': '私人记录。',
      'note_hint': '战术、关键球员、心得…',
      'delete': '删除',
      'no_stats_yet': '暂无统计数据。',
      'available_after_kickoff': '开球后可查看。',
      'no_lineups_yet': '暂无阵容信息。',
      'lineups_before_kickoff': '开球前一小时确认。',
      'no_events_yet': '暂无事件。',
      'events_appear_here': '进球、红黄牌、换人将在此显示。',
      'reminder_cancelled': '提醒已取消',
      'enable_notifications_hint': '请在系统设置中启用通知以接收提醒。',
      'reminder_set': '已设置开球前15分钟提醒',
      'could_not_schedule': '无法设置提醒',
      'update_prediction': '更新预测',
      'predict_score': '预测比分',

      // Settings
      'settings': '设置',
      'preferences': '偏好设置。',
      'view_profile': '查看个人资料和预测',
      'system_theme': '跟随系统',
      'light_theme': '浅色',
      'dark_theme': '深色',
      'reminders_15min': '开球前15分钟通知',
      'live_goal_notif': '进球实时通知',
      'breaking_transfers': '突发转会新闻',
      'send_test_notif': '发送测试通知',
      'verify_works': '验证此设备上是否正常',
      'test_sent': '测试通知已发送',
      'notif_works': '通知功能正常。',
      'free_up_storage': '释放存储空间',
      'reset_onboarding': '重置引导',
      'pick_teams_again': '重新选择喜爱的球队',
      'version': '版本',

      // Favorites
      'my_library': '我的收藏',
      'tap_bookmark_hint': '点击书签图标添加项目。',

      // Team
      'fact_sheet': '资料卡',
      'last_five': '近五场',

      // League
      'standings_desc': '积分榜每日更新 — 从榜首到降级区。',

      // Onboarding
      'issue_01': '第01期',
      'welcome_to': '欢迎来到\n飞饼体育。',
      'welcome_desc': '一本口袋大小的体育杂志 — 为每一位阅读、预测和记住每个比分的球迷而打造。',
      'in_this_issue': '本期内容',
      'live_scores': '实时比分',
      'live_scores_desc': '进球和关键事件实时更新。',
      'score_predictions': '比分预测',
      'score_predictions_desc': '在开球前预测结果。赢取积分。',
      'kickoff_reminders': '开球提醒',
      'kickoff_reminders_desc': '在你关注的比赛前收到智能提醒。',
      'match_notebook': '比赛笔记本',
      'match_notebook_desc': '记录战术、要点和反应的私人空间。',
      'chapter_one': '第一章',
      'what_call_you': '我们该怎么\n称呼你？',
      'nickname_desc': '你的昵称将显示在个人资料和预测记录中。',
      'name_hint': '例如 足球大师',
      'optional_skip': '可选 — 你可以跳过此步骤。',
      'chapter_two': '第二章',
      'pick_your_sides': '选择你的\n球队。',
      'selected_count': '已选择 — 从你最爱的俱乐部开始。',
      'chapter_three': '第三章',
      'stay_in_loop': '保持\n关注。',
      'quiet_alert_desc': '在每场你关注的比赛开球前15分钟收到一条安静的提醒。随时可在设置中调整。',
      'pre_match_reminders': '赛前提醒',
      'back': '返回',
      'skip': '跳过',
      'continue_btn': '继续',
      'get_started': '开始使用',

      // Connectivity
      'no_connection': '无网络连接 · 显示缓存数据',
      'back_online': '已恢复连接 · 正在刷新',

      // Bottom Nav
      'nav_saved': '收藏',
      'nav_more': '更多',

      // Compare
      'compare_teams': '球队对比',

      // Profile
      'profile': '个人资料',

      // Predictions
      'predictions': '预测',
      'my_picks': '我的预测',
      'history': '历史',

      // League (additional)
      'club': '俱乐部',
      'pl': '场',
      'no_standings': '暂无积分榜数据。',
      'champions': '冠军',
      'europa': '欧联',
      'relegation': '降级',

      // Profile (additional)
      'saved_leagues': '收藏的联赛',
      'display_name': '显示名称',
      'your_nickname': '你的昵称',
      'cancel': '取消',

      // Predictions (additional)
      'no_matches_predict': '没有可预测的比赛',
      'check_back_fixtures': '赛程安排后再来查看',
      'no_active_picks': '没有进行中的预测',
      'make_prediction_hint': '从即将开始的比赛中进行预测',
      'no_history_yet': '暂无历史记录',
      'resolve_hint': '用实际比分验证预测来建立你的记录',
      'enter_actual_score': '输入实际比分',
      'save_prediction': '保存预测',
      'resolve_actual': '用实际比分验证',
      'remove_prediction': '删除预测',
      'resolve': '验证',

      // Compare (additional)
      'compare_the_sides': '对比\n两队。',
      'compare_desc': '一个并排的编辑式对比 — 选择两支球队，阅读详细数据。',
      'form_last_10': '近10场表现',
      'goals_per_match': '场均进球',
      'defensive_rating': '防守评分',
      'fan_power': '球迷力量',
      'stadium_capacity': '球场容量',
      'draw_label': '平局',
      'model_disclaimer': '基于近期表现、进球和防守数据的预测模型 — 非博彩建议。',

      // Team (additional)
      'storied_club': '一支历史悠久的足球俱乐部。',

      // Favorites (additional)
      'saved_title': '收藏。',
      'favorites_desc': '你关注的球队、比赛和联赛。',
      'favorites_empty_hint': '点击任意地方的书签图标开始你的收藏。',
      'no_teams_saved': '暂无收藏的球队。',
      'no_matches_saved': '暂无收藏的比赛。',
      'no_leagues_saved': '暂无收藏的联赛。',

      // Shared
      'view_details': '查看详情',
      'share_score': '分享比分',

      // News Detail
      'full_article_hint': '完整文章请查看原始来源。',

      // Match Line
      'in_play_tap': '进行中 · 点击关注',

      // Predictions (screen)
      'predict_the_score': '预测比分',
      'prediction_scoring_hint': '精确比分得3分，正确结果得1分。',
      'predictions_deck': '在比赛开始前预测比分 — 记录你的敏锐度。',
      'points': '积分',
      'accuracy': '准确率',
      'exact': '精确',
      'best_run': '最佳连胜',
      'streak': '连胜',
      'predicted': '预测',
      'actual': '实际',

      // Compare (screen)
      'the_numbers': '数据对比',
      'editorial_verdict': '编辑预测',
      'predicted_outcome': '预测结果',
      'pick_team': '选择球队',
      'pick_first_team': '选择第一支球队',
      'pick_second_team': '选择第二支球队',
    },
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['en']?[key] ?? 
           key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n {
    final locale = Localizations.maybeLocaleOf(this) ?? const Locale('en');
    return AppLocalizations(locale);
  }
  String tr(String key) => l10n.t(key);
}
