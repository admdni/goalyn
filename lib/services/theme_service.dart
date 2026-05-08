import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(_load());

  static ThemeMode _load() {
    final box = Hive.box('settings');
    final raw = box.get('theme_mode', defaultValue: 'dark');
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final raw = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await Hive.box('settings').put('theme_mode', raw);
  }

  Future<void> toggle() async {
    final next =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setMode(next);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);
