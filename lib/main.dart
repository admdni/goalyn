import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/i18n/app_localizations.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'features/home/presentation/providers/match_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox('favorites'),
    Hive.openBox('settings'),
    Hive.openBox('cache'),
    Hive.openBox('predictions'),
    Hive.openBox('notes'),
  ]);

  // Initialize the notification service early so reminders survive app restarts.
  await NotificationService.instance.initialize();

  runApp(const ProviderScope(child: GoalynApp()));
}

class GoalynApp extends ConsumerStatefulWidget {
  const GoalynApp({super.key});

  @override
  ConsumerState<GoalynApp> createState() => _GoalynAppState();
}

class _GoalynAppState extends ConsumerState<GoalynApp> with WidgetsBindingObserver {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final savedLang = Hive.box('settings').get('language', defaultValue: 'en') as String;
    _locale = Locale(savedLang);
    // Sync news language with saved preference after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(newsLangProvider.notifier).state = savedLang;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh live data when app comes back to foreground
      ref.invalidate(liveMatchesProvider);
      ref.invalidate(todayMatchesProvider);
    }
  }

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final effectiveBrightness = switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => platformBrightness,
    };
    AppColors.applyMode(effectiveBrightness);

    return MaterialApp.router(
      title: 'Goalyn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: LocaleInheritedWidget(
            locale: _locale,
            setLocale: setLocale,
            child: child!,
          ),
        );
      },
    );
  }
}

class LocaleInheritedWidget extends InheritedWidget {
  final Locale locale;
  final void Function(Locale) setLocale;

  const LocaleInheritedWidget({
    required this.locale,
    required this.setLocale,
    required super.child,
  });

  static LocaleInheritedWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleInheritedWidget>()!;
  }

  @override
  bool updateShouldNotify(covariant LocaleInheritedWidget oldWidget) {
    return locale != oldWidget.locale;
  }
}
