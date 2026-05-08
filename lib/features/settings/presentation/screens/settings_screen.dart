import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../shared/widgets/editorial.dart';
import '../../../../services/notification_service.dart';
import 'legal_screen.dart';
import '../../../../services/onboarding_service.dart';
import '../../../../services/theme_service.dart';
import '../../../../main.dart';
import '../../../home/presentation/providers/match_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _matchReminders = true;
  bool _goalAlerts = true;
  bool _transferNews = true;

  @override
  void initState() {
    super.initState();
    final box = Hive.box('settings');
    _matchReminders = box.get('match_reminders', defaultValue: true) == true;
    _goalAlerts = box.get('goal_alerts', defaultValue: true) == true;
    _transferNews = box.get('transfer_news', defaultValue: true) == true;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            _buildMasthead(),
            _buildProfile(),
            _section(context.tr('appearance')),
            _buildAppearance(),
            _section(context.tr('notifications')),
            _buildNotifications(),
            _section(context.tr('language')),
            _buildLanguage(),
            _section('Library'),
            _buildLibrary(),
            _section(context.tr('about')),
            _buildAbout(),
          ],
        ),
      ),
    );
  }

  Widget _buildMasthead() {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Eyebrow(context.tr('settings'), color: p.textPrimary),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 0.5, color: p.line)),
            ],
          ),
          const SizedBox(height: 14),
          DisplayText(
            context.tr('preferences'),
            size: 42,
            style: FontStyle.italic,
            color: p.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    final p = context.palette;
    final name = OnboardingService.instance.displayName ?? 'Football Fan';
    return InkWell(
      onTap: () => context.push('/profile'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: p.line, width: 0.5),
            bottom: BorderSide(color: p.line, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: p.ink,
              ),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'F',
                style: AppType.display(
                  size: 22,
                  color: p.background,
                  weight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppType.serif(
                      size: 22,
                      color: p.textPrimary,
                      style: FontStyle.italic,
                    ),
                  ),
                  Text(
                    context.tr('view_profile'),
                    style: AppType.eyebrow(
                      size: 10,
                      color: p.textTertiary,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: p.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _section(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Eyebrow(label, color: context.palette.textPrimary),
    );
  }

  Widget _buildAppearance() {
    final mode = ref.watch(themeProvider);
    return Column(
      children: [
        _modeRow(context.tr('system_theme'), ThemeMode.system, mode),
        _modeRow(context.tr('light_theme'), ThemeMode.light, mode),
        _modeRow(context.tr('dark_theme'), ThemeMode.dark, mode),
      ],
    );
  }

  Widget _modeRow(String label, ThemeMode m, ThemeMode current) {
    final p = context.palette;
    final selected = m == current;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(themeProvider.notifier).setMode(m);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.line, width: 0.4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppType.serif(
                  size: 18,
                  color: p.textPrimary,
                  style: FontStyle.italic,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check, color: p.accent, size: 16)
            else
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  border: Border.all(color: p.line, width: 1),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifications() {
    return Column(
      children: [
        _toggleRow(
          context.tr('match_reminders'),
          context.tr('reminders_15min'),
          _matchReminders,
          (v) async {
            HapticFeedback.selectionClick();
            setState(() => _matchReminders = v);
            await Hive.box('settings').put('match_reminders', v);
            if (v) await NotificationService.instance.requestPermissions();
          },
        ),
        _toggleRow(
          context.tr('goal_alerts'),
          context.tr('live_goal_notif'),
          _goalAlerts,
          (v) async {
            HapticFeedback.selectionClick();
            setState(() => _goalAlerts = v);
            await Hive.box('settings').put('goal_alerts', v);
          },
        ),
        _toggleRow(
          context.tr('transfer_news'),
          context.tr('breaking_transfers'),
          _transferNews,
          (v) async {
            HapticFeedback.selectionClick();
            setState(() => _transferNews = v);
            await Hive.box('settings').put('transfer_news', v);
          },
        ),
      ],
    );
  }

  Widget _buildLanguage() {
    final inherited = LocaleInheritedWidget.of(context);
    final currentLang = inherited.locale.languageCode;
    return Column(
      children: [
        _langRow('English', 'en', currentLang, inherited.setLocale),
        _langRow('中文', 'zh', currentLang, inherited.setLocale),
      ],
    );
  }

  Widget _langRow(String label, String code, String current, void Function(Locale) setLocale) {
    final p = context.palette;
    final selected = code == current;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setLocale(Locale(code));
        Hive.box('settings').put('language', code);
        ref.read(newsLangProvider.notifier).state = code;
        ref.invalidate(newsProvider);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.line, width: 0.4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppType.serif(
                  size: 18,
                  color: p.textPrimary,
                  style: FontStyle.italic,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check, color: p.accent, size: 16)
            else
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  border: Border.all(color: p.line, width: 1),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibrary() {
    return Column(
      children: [
        _actionRow(
          context.tr('clear_cache'),
          context.tr('free_up_storage'),
          Icons.delete_outline,
          () async {
            HapticFeedback.mediumImpact();
            await Hive.box('cache').clear();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('cache_cleared'))),
              );
            }
          },
        ),
        _actionRow(
          context.tr('reset_onboarding'),
          context.tr('pick_teams_again'),
          Icons.refresh_rounded,
          () async {
            await OnboardingService.instance.reset();
            if (mounted) context.go('/onboarding');
          },
        ),
      ],
    );
  }

  Widget _buildAbout() {
    return Column(
      children: [
        _infoRow(context.tr('version'), '1.0.0'),
        _actionRow(context.tr('privacy_policy'), context.tr('read_privacy'), Icons.arrow_forward,
            () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const LegalScreen(
                title: 'Privacy Policy',
                content: _privacyPolicy,
              ),
            ),
          );
        }),
        _actionRow(context.tr('terms'), context.tr('read_terms'), Icons.arrow_forward,
            () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const LegalScreen(
                title: 'Terms of Use',
                content: _termsOfUse,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _toggleRow(
      String title, String sub, bool value, ValueChanged<bool> onChanged) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line, width: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppType.serif(
                      size: 18,
                      color: p.textPrimary,
                      style: FontStyle.italic,
                    )),
                const SizedBox(height: 2),
                Text(sub,
                    style: AppType.sans(
                      size: 12,
                      color: p.textTertiary,
                    )),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: p.accent,
          ),
        ],
      ),
    );
  }

  Widget _actionRow(String title, String sub, IconData icon, VoidCallback tap) {
    final p = context.palette;
    return InkWell(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.line, width: 0.4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppType.serif(
                        size: 18,
                        color: p.textPrimary,
                        style: FontStyle.italic,
                      )),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: AppType.sans(
                        size: 12,
                        color: p.textTertiary,
                      )),
                ],
              ),
            ),
            Icon(icon, color: p.textTertiary, size: 16),
          ],
        ),
      ),
    );
  }

  static const _privacyPolicy = '''Privacy Policy

Last updated: May 2026

Goalyn ("we", "our", or "us") operates the Goalyn mobile application. This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our app.

Information Collection
We collect minimal data to provide our service:
• Display name (optional, stored locally on your device)
• Favorite teams and leagues (stored locally)
• Match predictions and notes (stored locally)
• Notification preferences (stored locally)

We do not collect, transmit, or store any personal data on external servers. All user data remains on your device.

Third-Party Services
Our app uses the following third-party services:
• API-Football for live match data
• Google News for football news articles
These services may collect usage data according to their own privacy policies.

Data Storage
All personal preferences and user-generated content are stored locally on your device using encrypted local storage. We do not have access to this data.

Data Deletion
You can delete all your data at any time by clearing the app cache in Settings or by uninstalling the application.

Children's Privacy
Our app does not knowingly collect personal information from children under 13.

Changes to This Policy
We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy in the app.

Contact Us
If you have any questions about this Privacy Policy, please contact us at support@goalyn.app.''';

  static const _termsOfUse = '''Terms of Use

Last updated: May 2026

By using the Goalyn application, you agree to these terms.

Use of the App
Goalyn provides football match scores, news, and statistics for informational and entertainment purposes. The app includes features for tracking predictions, saving favorites, and reading football news.

Accuracy of Information
While we strive to provide accurate and up-to-date information, we make no warranties about the completeness, reliability, or accuracy of match scores, statistics, or news content. Data is provided by third-party services and may be subject to delays.

User Content
Predictions, notes, and preferences you create within the app are stored locally on your device. You are responsible for your own content.

Intellectual Property
The Goalyn name, logo, and design are our intellectual property. Match data is provided by API-Football. News content is sourced from public RSS feeds.

Prohibited Uses
You agree not to:
• Use the app for any unlawful purpose
• Attempt to reverse-engineer or modify the app
• Use match data for commercial gambling purposes

Limitation of Liability
Goalyn is provided "as is" without warranty of any kind. We shall not be liable for any damages arising from the use of this application.

Termination
We reserve the right to terminate or suspend access to the app at any time without notice.

Changes to Terms
We may modify these terms at any time. Continued use of the app constitutes acceptance of updated terms.

Contact Us
For questions about these Terms, contact us at support@goalyn.app.''';

  Widget _infoRow(String label, String value) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.line, width: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: AppType.eyebrow(
                size: 10,
                color: p.textTertiary,
                letterSpacing: 1.4,
              ),
            ),
          ),
          Text(
            value,
            style: AppType.mono(
              size: 13,
              color: p.textPrimary,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
