import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n.dart';
import '../models.dart';
import '../store.dart';
import '../widgets/ui.dart';
import 'goals_screen.dart';
import 'recovery_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'weekly_screen.dart';

/// ---------------------------------------------------------------------------
/// The desk: settings and sleep data (plus goals, tips and the weekly recap).
/// ---------------------------------------------------------------------------
class DeskScreen extends StatelessWidget {
  const DeskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = Theme.of(context);

    final entries = [
      _DeskEntry(
        icon: Icons.insights_rounded,
        title: L.t('stats'),
        subtitle: entries0(state),
        page: const StatsScreen(),
      ),
      _DeskEntry(
        icon: Icons.flag_rounded,
        title: L.t('goals'),
        subtitle:
            '${Util.hours(state.goals.targetHours)} · ${Util.clockFrom18(state.goals.bedSlotMinutes)} → ${Util.clock(state.goals.wakeMinutes)}',
        page: const GoalsScreen(),
      ),
      _DeskEntry(
        icon: Icons.calendar_view_week_rounded,
        title: L.t('weekly'),
        subtitle:
            '${state.lastDays(7).length} ${L.t('nights_logged')} · ${state.goalsMetThisWeek} ${L.t('goal_met')}',
        page: const WeeklyScreen(),
      ),
      _DeskEntry(
        icon: Icons.self_improvement_rounded,
        title: L.t('recovery'),
        subtitle: state.sleepDebt > 0
            ? '${L.t('sleep_debt')}: ${Util.hours(state.sleepDebt)}'
            : L.t('recovery_sub'),
        page: const RecoveryScreen(),
      ),
      _DeskEntry(
        icon: Icons.settings_rounded,
        title: L.t('settings'),
        subtitle:
            '${L.t('dark_mode')} · ${L.t('language')} · ${L.t('demo_data')}',
        page: const SettingsScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(L.t('tap_desk'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          HeroTitle(text: L.t('my_profile'), emoji: '🖥️'),
          const SizedBox(height: 6),
          Text(
            '${state.profile?.name ?? ''} · ${L.t('my_level')} ${state.profile?.level ?? 1} · 🪙 ${state.profile?.coins ?? 0}',
            style: t.textTheme.bodyMedium?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ExpressiveCard(
                onTap: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => e.page)),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: t.colorScheme.primary.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(e.icon, color: t.colorScheme.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            e.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: t.textTheme.bodySmall?.copyWith(
                              color: t.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String entries0(AppState s) => s.entries.isEmpty
      ? L.t('no_data')
      : '${Util.hours(s.avgDuration)} · ${s.avgBedtime} → ${s.avgWake}';
}

class _DeskEntry {
  const _DeskEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.page,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget page;
}
