import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n.dart';
import '../models.dart';
import '../services/notifications.dart';
import '../store.dart';
import '../widgets/ui.dart';

/// Sleep goals — a Must-have: the trigger for rewards in the game loop.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late double _hours;
  late int _bedSlot;
  late int _wake;
  late bool _reminders;
  late int _lead;

  @override
  void initState() {
    super.initState();
    final g = context.read<AppState>().goals;
    _hours = g.targetHours;
    _bedSlot = g.bedSlotMinutes;
    _wake = g.wakeMinutes;
    _reminders = g.remindersEnabled;
    _lead = g.bedReminderLeadMinutes;
  }

  Future<void> _save() async {
    final state = context.read<AppState>();
    await state.setGoals(
      SleepGoals(
        targetHours: _hours,
        bedSlotMinutes: _bedSlot,
        wakeMinutes: _wake,
        remindersEnabled: _reminders,
        bedReminderLeadMinutes: _lead,
      ),
    );

    if (_reminders) {
      await NotificationService.requestPermission();
      final bedAbs = (18 * 60 + _bedSlot - _lead) % (24 * 60);
      final wakeAbs = _wake % (24 * 60);
      await NotificationService.cancelAll();
      await NotificationService.scheduleDaily(
        id: 1,
        hour: bedAbs ~/ 60,
        minute: bedAbs % 60,
        title: L.t('app_name'),
        body: L.t('target_bedtime'),
      );
      await NotificationService.scheduleDaily(
        id: 2,
        hour: wakeAbs ~/ 60,
        minute: wakeAbs % 60,
        title: L.t('app_name'),
        body: L.t('target_waketime'),
      );
    } else {
      await NotificationService.cancelAll();
    }

    if (!mounted) return;
    showToast(context, L.t('goals_saved'));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(L.t('goals'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          HeroTitle(text: L.t('goals'), emoji: '🎯'),
          const SizedBox(height: 6),
          Text(
            L.t('goals_sub'),
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          ExpressiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        L.t('target_hours'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      Util.hours(_hours),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Slider(
                  value: _hours,
                  min: 5,
                  max: 11,
                  divisions: 12,
                  label: Util.hours(_hours),
                  onChanged: (v) => setState(() => _hours = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          ExpressiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        L.t('target_bedtime'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      Util.clockFrom18(_bedSlot),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Slider(
                  value: _bedSlot.toDouble(),
                  min: 0,
                  max: 480,
                  divisions: 32,
                  label: Util.clockFrom18(_bedSlot),
                  onChanged: (v) => setState(() => _bedSlot = v.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          ExpressiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        L.t('target_waketime'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      Util.clock(_wake),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Slider(
                  value: _wake.toDouble(),
                  min: 4 * 60,
                  max: 12 * 60,
                  divisions: 32,
                  label: Util.clock(_wake),
                  onChanged: (v) => setState(() => _wake = v.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          ExpressiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    L.t('reminders'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    NotificationService.available
                        ? L.t('reminder_lead')
                        : L.t('notif_unavailable'),
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  value: _reminders,
                  onChanged: NotificationService.available
                      ? (v) => setState(() => _reminders = v)
                      : null,
                ),
                const SizedBox(height: 6),
                Text(
                  L.t('reminder_lead'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final m in [15, 30, 45, 60])
                      PillChip(
                        label: L.tr('minutes_before', {'n': '$m'}),
                        selected: _lead == m,
                        onTap: () => setState(() => _lead = m),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_rounded),
            label: Text(L.t('save_goals')),
          ),
        ],
      ),
    );
  }
}
