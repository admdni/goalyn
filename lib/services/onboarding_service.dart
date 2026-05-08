import 'package:hive_flutter/hive_flutter.dart';

class OnboardingService {
  OnboardingService._();
  static final OnboardingService instance = OnboardingService._();

  bool get isCompleted {
    final box = Hive.box('settings');
    return box.get('onboarding_completed', defaultValue: false) == true;
  }

  Future<void> markCompleted({
    String? displayName,
    bool notificationsEnabled = false,
  }) async {
    final box = Hive.box('settings');
    await box.put('onboarding_completed', true);
    if (displayName != null && displayName.trim().isNotEmpty) {
      await box.put('display_name', displayName.trim());
    }
    await box.put('notifications_enabled', notificationsEnabled);
    await box.put(
        'onboarding_completed_at', DateTime.now().toIso8601String());
  }

  Future<void> reset() async {
    final box = Hive.box('settings');
    await box.put('onboarding_completed', false);
  }

  String? get displayName {
    final box = Hive.box('settings');
    final v = box.get('display_name');
    return v is String && v.isNotEmpty ? v : null;
  }

  bool get notificationsEnabled {
    final box = Hive.box('settings');
    return box.get('notifications_enabled', defaultValue: false) == true;
  }
}
