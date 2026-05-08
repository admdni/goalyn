import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/i18n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/name_utils.dart';
import '../../../../shared/widgets/editorial.dart';
import '../../../../shared/widgets/match_line.dart';
import '../../../home/data/models/match_model.dart';
import '../../../home/presentation/providers/match_providers.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  Timer? _refresh;
  String _filter = 'live';

  @override
  void initState() {
    super.initState();
    _refresh = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refresh?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final live = ref.watch(liveMatchesProvider).valueOrNull ?? <MatchModel>[];
    final finished = ref.watch(finishedMatchesProvider).valueOrNull ?? <MatchModel>[];
    final upcoming = ref.watch(upcomingMatchesProvider).valueOrNull ?? <MatchModel>[];
    final matches = switch (_filter) {
      'finished' => finished,
      'upcoming' => upcoming,
      _ => live,
    };

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(live.length),
            _buildSegmented(
                liveCount: live.length,
                finishedCount: finished.length,
                upcomingCount: upcoming.length),
            Expanded(child: _buildList(matches)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int liveCount) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Eyebrow(context.tr('live_coverage'), color: p.textPrimary),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 0.5, color: p.line)),
              const SizedBox(width: 10),
              if (liveCount > 0) ...[
                LivePulse(color: p.live, size: 6),
                const SizedBox(width: 6),
                Text('$liveCount ${context.tr('in_play')}',
                    style: AppType.eyebrow(
                        size: 10, color: p.live, letterSpacing: 1.6)),
              ] else
                Text(context.tr('no_live'),
                    style: AppType.eyebrow(
                        size: 10, color: p.textTertiary, letterSpacing: 1.4)),
            ],
          ),
          const SizedBox(height: 12),
          DisplayText(
            context.tr('stadium_feed'),
            size: 38,
            style: FontStyle.italic,
            color: p.textPrimary,
          ),
          const SizedBox(height: 6),
          DeckText(
            liveCount > 0
                ? context.tr('live_description')
                : context.tr('no_live_description'),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmented({
    required int liveCount,
    required int finishedCount,
    required int upcomingCount,
  }) {
    final p = context.palette;
    final segments = [
      ('live', context.tr('live'), liveCount),
      ('upcoming', context.tr('upcoming_filter'), upcomingCount),
      ('finished', context.tr('finished'), finishedCount),
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: p.line, width: 0.5),
          bottom: BorderSide(color: p.line, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: segments.map((s) {
          final selected = _filter == s.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _filter = s.$1);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? p.ink : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.$2.toUpperCase(),
                      style: AppType.eyebrow(
                        size: 11,
                        color: selected ? p.textPrimary : p.textTertiary,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selected ? p.ink : p.line,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '${s.$3}',
                        style: AppType.mono(
                          size: 10,
                          color: selected ? p.textPrimary : p.textTertiary,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _onRefresh() async {
    ref.invalidate(liveMatchesProvider);
    ref.invalidate(finishedMatchesProvider);
    ref.invalidate(upcomingMatchesProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Widget _buildList(List<MatchModel> matches) {
    final p = context.palette;
    if (matches.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sports_soccer_outlined,
                        size: 36, color: p.textTertiary),
                    const SizedBox(height: 12),
                    DisplayText(
                      context.tr('quiet_on_wire'),
                      size: 24,
                      style: FontStyle.italic,
                      color: p.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    DeckText(context.tr('try_another_tab')),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final grouped = <String, List<MatchModel>>{};
    for (final m in matches) {
      final key = NameUtils.shortLeague(m.league?.name ?? 'Other');
      grouped.putIfAbsent(key, () => []).add(m);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        children: grouped.entries
            .map((e) => MatchGroup(
                  title: e.key,
                  subtitle: '${e.value.length} ${context.tr('games_count')}',
                  matches: e.value,
                  onMatchTap: (m) => context.push('/match/${m.id}'),
                ))
            .toList(),
      ),
    );
  }
}
