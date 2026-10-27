import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n.dart';
import '../models.dart';
import '../seed.dart';
import '../store.dart';
import '../widgets/ui.dart';
import 'recovery_screen.dart';

/// Presents the "log a night" sheet. Returns true when a night was saved.
Future<bool> showSleepLogSheet(BuildContext context) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _SleepLogSheet(),
  );
  return saved ?? false;
}

class _SleepLogSheet extends StatefulWidget {
  const _SleepLogSheet();

  @override
  State<_SleepLogSheet> createState() => _SleepLogSheetState();
}

class _SleepLogSheetState extends State<_SleepLogSheet> {
  /// The evening the night being logged began on.
  late DateTime _night;

  /// Bedtime and wake-up as minutes past midnight. The real dates come from
  /// [Util.nightTimes], so a bedtime after midnight lands on the right day.
  int _bedMin = 23 * 60;
  int _wakeMin = 7 * 60;
  int _quality = 3;
  final Set<String> _factors = {};
  final _note = TextEditingController();

  static const _qualityEmoji = ['😵', '😕', '😐', '🙂', '😴'];

  /// Longer than this is almost certainly a mistyped time (e.g. 11:00 picked
  /// for 23:00), so the sheet asks the player to check before saving.
  static const double _maxPlausibleHours = 16;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Before 18:00 the player is almost always logging the night just gone.
    _night = now.hour < 18 ? today.subtract(const Duration(days: 1)) : today;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  DateTime get _bed => Util.nightTimes(_night, _bedMin, _wakeMin).$1;
  DateTime get _wake => Util.nightTimes(_night, _bedMin, _wakeMin).$2;

  double get _hours => _wake.difference(_bed).inMinutes / 60.0;

  bool get _implausible => _hours > _maxPlausibleHours;

  Future<void> _pick({required bool bed}) async {
    final current = bed ? _bedMin : _wakeMin;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked == null) return;
    setState(() {
      final minutes = picked.hour * 60 + picked.minute;
      if (bed) {
        _bedMin = minutes;
      } else {
        _wakeMin = minutes;
      }
    });
  }

  Future<void> _save() async {
    final state = context.read<AppState>();
    // Captured *before* the sheet is popped: once `pop()` runs this widget's
    // context is unmounted, so anything that still needs a live context (the
    // toast and the level-up dialog) has to use these instead. This is what
    // made the "OK" button on the level-up dialog look dead.
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final levels = await state.logSleep(
      bedtime: _bed,
      wake: _wake,
      quality: _quality,
      factors: _factors.toList(),
      note: _note.text.trim(),
    );
    if (!mounted) return;
    nav.pop(true);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          L.tr('logged_toast', {'score': Util.score(state.bedroomSleepScore)}),
        ),
      ),
    );

    // Staying up late: offer a recovery plan straight away. Built from the
    // night just entered (not entries.last, which may be a newer night when
    // an older one is back-filled).
    final lateNight = state.lateNightReport(
      SleepEntry(
        id: 'logged',
        bedtime: _bed,
        wake: _wake,
        quality: _quality,
        factors: _factors.toList(),
      ),
    );

    if (levels > 0) {
      await showDialog<void>(
        context: nav.context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.celebration_rounded, size: 40),
          title: Text(L.t('level_up')),
          content: Text(
            L.tr('level_up_body', {'n': '${state.profile!.level}'}),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(L.t('ok')),
            ),
          ],
        ),
      );
    }

    if (lateNight != null) {
      final hostContext = nav.context;
      if (hostContext.mounted) await showLateNightSheet(hostContext, lateNight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context);
    final goals = context.watch<AppState>().goals;
    final meetsGoal = !_implausible && _hours >= goals.targetHours;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Text(
            L.t('log_sleep'),
            style: t.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            L.t('tap_bed'),
            style: t.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),

          // ------------------------------------------------------- times
          Row(
            children: [
              Expanded(
                child: _TimeCard(
                  icon: Icons.bedtime_rounded,
                  label: L.t('bedtime'),
                  value: TimeOfDay.fromDateTime(_bed).format(context),
                  onTap: () => _pick(bed: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeCard(
                  icon: Icons.wb_sunny_rounded,
                  label: L.t('wakeup'),
                  value: TimeOfDay.fromDateTime(_wake).format(context),
                  onTap: () => _pick(bed: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ---------------------------------------------------- duration
          ExpressiveCard(
            color: _implausible
                ? scheme.errorContainer
                : meetsGoal
                ? scheme.primaryContainer
                : scheme.surfaceContainerHighest,
            child: Row(
              children: [
                Icon(
                  Icons.timelapse_rounded,
                  size: 30,
                  color: meetsGoal
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        L.t('duration'),
                        style: t.textTheme.labelLarge?.copyWith(
                          color: meetsGoal
                              ? scheme.onPrimaryContainer
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        Util.hours(_hours),
                        style: t.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_implausible)
                  GoalBadge(
                    state: meetsGoal
                        ? 'met'
                        : (_hours >= goals.targetHours - 1
                              ? 'close'
                              : 'missed'),
                    text: meetsGoal
                        ? L.t('goal_met')
                        : '${L.t('goal_line')} ${Util.hours(goals.targetHours)}',
                  ),
              ],
            ),
          ),
          if (_implausible) ...[
            const SizedBox(height: 8),
            Text(
              L.tr('log_too_long', {'h': Util.hours(_hours)}),
              style: t.textTheme.bodyMedium?.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 18),

          // ----------------------------------------------------- quality
          SectionHeader(title: L.t('quality')),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final q = i + 1;
              final sel = _quality == q;
              return GestureDetector(
                onTap: () => setState(() => _quality = q),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: sel
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? scheme.primary : scheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _qualityEmoji[i],
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$q',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: sel
                              ? scheme.onPrimary
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),

          // ----------------------------------------------------- factors
          SectionHeader(
            title: L.t('factors_title'),
            subtitle: L.t('factors_sub'),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kFactorTags.map((f) {
              final sel = _factors.contains(f.id);
              return PillChip(
                label: f.label(L.lang),
                emoji: f.emoji,
                selected: sel,
                color: f.harmful ? scheme.error : scheme.primary,
                onTap: () => setState(() {
                  sel ? _factors.remove(f.id) : _factors.add(f.id);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // -------------------------------------------------------- note
          TextField(
            controller: _note,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: L.t('note'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              filled: true,
            ),
          ),
          const SizedBox(height: 22),

          FilledButton.icon(
            onPressed: _implausible ? null : _save,
            icon: const Icon(Icons.nightlight_round),
            label: Text(L.t('save_night')),
          ),
        ],
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExpressiveCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
