import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n.dart';
import '../models.dart';
import '../store.dart';
import '../widgets/charts.dart';
import '../widgets/ui.dart';

/// ---------------------------------------------------------------------------
/// Weekly summary — closes the feedback loop by showing progress against the
/// goals and comparing this week with the previous one.
/// ---------------------------------------------------------------------------
class WeeklyScreen extends StatelessWidget {
  const WeeklyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = Theme.of(context);
    final scheme = t.colorScheme;

    final now = DateTime.now();
    final thisCut = now.subtract(const Duration(days: 7));
    final lastCut = now.subtract(const Duration(days: 14));

    final thisWeek = state.entries
        .where((e) => e.wake.isAfter(thisCut))
        .toList();
    final lastWeek = state.entries
        .where((e) => e.wake.isAfter(lastCut) && !e.wake.isAfter(thisCut))
        .toList();

    double avgOf(List<SleepEntry> l) => l.isEmpty
        ? 0
        : l.map((e) => e.durationHours).reduce((a, b) => a + b) / l.length;

    final goal = state.goals.targetHours;
    final met = thisWeek.where((e) => e.durationHours >= goal).toList();
    final delta = thisWeek.isEmpty || lastWeek.isEmpty
        ? null
        : avgOf(thisWeek) - avgOf(lastWeek);

    final best = thisWeek.isEmpty
        ? null
        : thisWeek.reduce((a, b) => a.durationHours >= b.durationHours ? a : b);
    final worst = thisWeek.isEmpty
        ? null
        : thisWeek.reduce((a, b) => a.durationHours <= b.durationHours ? a : b);

    return PageScaffold(
      title: L.t('weekly'),
      subtitle: L.t('week_summary_sub'),
      children: [
        HeroTitle(text: L.t('this_week'), emoji: '🗓️'),
        const SizedBox(height: 10),

        if (thisWeek.isEmpty)
          ExpressiveCard(child: EmptyState(message: L.t('no_week_data')))
        else ...[
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              StatTile(
                icon: Icons.nightlight_round,
                label: L.t('nights_logged'),
                value: '${thisWeek.length} / 7',
              ),
              StatTile(
                icon: Icons.emoji_events_rounded,
                label: L.t('goals_met'),
                value: '${met.length} / ${thisWeek.length}',
                tint: scheme.tertiary,
              ),
              StatTile(
                icon: Icons.trending_up_rounded,
                label: L.t('avg_sleep'),
                value: Util.hours(avgOf(thisWeek)),
                tint: scheme.secondary,
              ),
              StatTile(
                icon: Icons.battery_alert_rounded,
                label: L.t('sleep_debt'),
                value: Util.hours(state.sleepDebt),
                tint: scheme.error,
              ),
            ],
          ),
          const SizedBox(height: 18),

          SectionHeader(title: L.t('trend')),
          ExpressiveCard(
            child: SleepBarChart(
              entries: thisWeek,
              goalHours: goal,
              dayLabels: thisWeek
                  .map(
                    (e) => Util.dayLabel(e.nightDate, L.lang).split(' ').first,
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),

          SectionHeader(
            title: L.t('week_vs_last'),
            subtitle: L.t('week_compare_sub'),
          ),
          ExpressiveCard(
            child: delta == null
                ? Text(
                    L.t('insufficient_week'),
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (delta >= 0 ? scheme.primary : scheme.error)
                              .withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          delta >= 0
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color: delta >= 0 ? scheme.primary : scheme.error,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              delta == 0
                                  ? L.t('vs_last_same')
                                  : L.tr(
                                      delta > 0 ? 'vs_last_up' : 'vs_last_down',
                                      {'h': Util.hours(delta.abs())},
                                    ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${L.t('last_week')}: ${Util.hours(avgOf(lastWeek))}',
                              style: t.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 18),

          if (best != null && worst != null) ...[
            Row(
              children: [
                Expanded(
                  child: _HighlightCard(
                    icon: '🌟',
                    label: L.t('best_night'),
                    hours: Util.hours(best.durationHours),
                    date: Util.dayLabel(best.nightDate, L.lang),
                    tint: scheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HighlightCard(
                    icon: '🌧️',
                    label: L.t('worst_night'),
                    hours: Util.hours(worst.durationHours),
                    date: Util.dayLabel(worst.nightDate, L.lang),
                    tint: scheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],

          SectionHeader(title: L.t('table_of_sleep')),
          ExpressiveCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (final e in thisWeek.reversed)
                  _WeekRow(entry: e, goal: goal),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.icon,
    required this.label,
    required this.hours,
    required this.date,
    required this.tint,
  });

  final String icon;
  final String label;
  final String hours;
  final String date;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return ExpressiveCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            label,
            style: t.textTheme.labelMedium?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hours,
            style: t.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: tint,
            ),
          ),
          Text(
            date,
            style: t.textTheme.bodySmall?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({required this.entry, required this.goal});
  final SleepEntry entry;
  final double goal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final d = entry.durationHours;
    final state = d >= goal ? 'met' : (d >= goal - 0.75 ? 'close' : 'missed');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              Util.dayLabel(entry.nightDate, L.lang),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              '${Util.clock(entry.bedtime.hour * 60 + entry.bedtime.minute)} → ${Util.clock(entry.wake.hour * 60 + entry.wake.minute)}',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
          Text(
            Util.hours(d),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
          ),
          const SizedBox(width: 8),
          GoalBadge(
            state: state,
            text: switch (state) {
              'met' => L.t('goal_met'),
              'close' => L.t('goal_close'),
              _ => L.t('goal_missed'),
            },
          ),
        ],
      ),
    );
  }
}
