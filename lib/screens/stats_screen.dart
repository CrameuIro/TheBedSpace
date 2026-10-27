import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n.dart';
import '../models.dart';
import '../seed.dart';
import '../store.dart';
import '../widgets/charts.dart';
import '../widgets/ui.dart';

/// Sleep data screen: averages, charts, factor impact and the night-by-night
/// table ("sleep time table" is a Must-have in the brief).
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _range = 7;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final data = state.lastDays(_range);

    return Scaffold(
      // The range selector lives in the body rather than in AppBar actions: on a
      // 360dp phone it does not fit beside the title.
      appBar: AppBar(title: Text(L.t('stats'))),
      body: state.entries.isEmpty
          ? EmptyState(message: L.t('no_data'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: SegmentedButton<int>(
                    segments: [
                      ButtonSegment(value: 7, label: Text(L.t('last7'))),
                      ButtonSegment(value: 30, label: Text(L.t('last30'))),
                    ],
                    selected: {_range},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => setState(() => _range = s.first),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.2,
                  children: [
                    StatTile(
                      icon: Icons.bedtime_rounded,
                      label: L.t('avg_sleep'),
                      value: Util.hours(state.avgDuration),
                    ),
                    StatTile(
                      icon: Icons.schedule_rounded,
                      label: L.t('avg_bed'),
                      value: state.avgBedtime,
                      tint: scheme.tertiary,
                    ),
                    StatTile(
                      icon: Icons.wb_twilight_rounded,
                      label: L.t('avg_wake'),
                      value: state.avgWake,
                      tint: scheme.secondary,
                    ),
                    StatTile(
                      icon: Icons.favorite_rounded,
                      label: L.t('avg_quality'),
                      value: state.avgQuality.toStringAsFixed(1),
                      tint: scheme.error,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                SectionHeader(title: L.t('trend')),
                ExpressiveCard(
                  child: SleepBarChart(
                    entries: data,
                    goalHours: state.goals.targetHours,
                    dayLabels: data
                        .map(
                          (e) => Util.dayLabel(
                            e.nightDate,
                            L.lang,
                          ).split(' ').first,
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 18),

                SectionHeader(title: L.t('bedtime_chart')),
                ExpressiveCard(
                  child: BedtimeDriftChart(
                    entries: data,
                    goalSlot: state.goals.bedSlotMinutes,
                  ),
                ),
                const SizedBox(height: 18),

                if (state.factorImpact.isNotEmpty) ...[
                  SectionHeader(
                    title: L.t('factor_impact'),
                    subtitle: L.t('factor_sub'),
                  ),
                  ExpressiveCard(
                    child: Column(
                      children: [
                        for (final e in state.factorImpact)
                          if (kFactorTags.any((f) => f.id == e.key))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Text(
                                    kFactorTags
                                        .firstWhere((f) => f.id == e.key)
                                        .emoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          kFactorTags
                                              .firstWhere((f) => f.id == e.key)
                                              .label(L.lang),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          kFactorTags
                                              .firstWhere((f) => f.id == e.key)
                                              .tip(L.lang),
                                          style: t.textTheme.bodySmall
                                              ?.copyWith(
                                                color: scheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GoalBadge(
                                    state: 'missed',
                                    text: '×${e.value}',
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                SectionHeader(title: L.t('table_of_sleep')),
                ExpressiveCard(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      for (final e in data.reversed)
                        _NightRow(entry: e, goal: state.goals.targetHours),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _NightRow extends StatelessWidget {
  const _NightRow({required this.entry, required this.goal});
  final SleepEntry entry;
  final double goal;

  static const _emoji = ['😵', '😕', '😐', '🙂', '😴'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final met = entry.durationHours >= goal;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 78,
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
            Util.hours(entry.durationHours),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: met ? scheme.primary : scheme.error,
            ),
          ),
          const SizedBox(width: 8),
          Text(_emoji[entry.quality - 1], style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
