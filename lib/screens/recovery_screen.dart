import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n.dart';
import '../models.dart';
import '../seed.dart';
import '../store.dart';
import '../widgets/ui.dart';

/// ---------------------------------------------------------------------------
/// Recovery after a late night (Must-have): concrete, kind next steps instead
/// of a lecture, plus everyday sleep-hygiene reminders.
/// ---------------------------------------------------------------------------
/// Shows the recovery plan straight after a late night is logged, so the
/// advice arrives when it is needed instead of waiting to be found.
Future<void> showLateNightSheet(BuildContext context, LateNightReport report) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          LateNightPlan(report: report),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RecoveryScreen()),
                    );
                  },
                  child: Text(L.t('late_more')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(L.t('late_ok')),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// Summary of a late night followed by its personalised recovery tips.
class LateNightPlan extends StatelessWidget {
  const LateNightPlan({super.key, required this.report});

  final LateNightReport report;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final goals = context.read<AppState>().goals;
    final e = report.entry;
    final bed = Util.clock(e.bedtime.hour * 60 + e.bedtime.minute);
    var summary = report.minutesLate >= 60
        ? L.tr('late_summary', {
            'bed': bed,
            'late': Util.hours(report.minutesLate / 60),
            'goal': Util.clock(18 * 60 + goals.bedSlotMinutes),
            'h': Util.hours(e.durationHours),
          })
        : L.tr('late_summary_plain', {
            'bed': bed,
            'h': Util.hours(e.durationHours),
          });
    if (report.hoursShort > 0) {
      summary += L.tr('late_summary_short', {
        'short': Util.hours(report.hoursShort),
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🌙', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    L.t('late_title'),
                    style: t.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(L.t('late_sub'), style: t.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(summary, style: t.textTheme.bodyMedium?.copyWith(height: 1.4)),
        const SizedBox(height: 14),
        Text(
          L.t('late_plan_title'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        const SizedBox(height: 8),
        for (final tip in report.tips)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tip.text,
                    style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        Text(
          L.t('recovery_disclaimer'),
          style: t.textTheme.bodySmall?.copyWith(
            color: t.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class RecoveryScreen extends StatelessWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = Theme.of(context);
    final scheme = t.colorScheme;

    final last = state.entries.isEmpty ? null : state.entries.last;
    final lateNight = state.latestLateNight;
    final shortNight =
        last != null && last.durationHours < state.goals.targetHours;
    final zh = L.lang == 'zh';

    return PageScaffold(
      title: L.t('recovery'),
      subtitle: L.t('recovery_sub'),
      children: [
        HeroTitle(text: L.t('recovery'), emoji: '🧘'),
        const SizedBox(height: 12),

        // --------------------------- personalised plan after a late night
        if (lateNight != null) ...[
          ExpressiveCard(
            color: scheme.errorContainer,
            child: LateNightPlan(report: lateNight),
          ),
          const SizedBox(height: 18),
        ],

        // ------------------------------------------- tonight's personalised plan
        ExpressiveCard(
          onTap: null,
          color: shortNight
              ? scheme.errorContainer
              : scheme.primaryContainer.withValues(alpha: 0.55),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    shortNight ? '🌙' : '✅',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      shortNight
                          ? L.t('recovery_plan_short')
                          : L.t('recovery_plan_ok'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                shortNight
                    ? L.tr('recovery_last_night', {
                        'h': Util.hours(last.durationHours),
                      })
                    : L.tr('recovery_on_track', {
                        'h': Util.hours(state.avgDuration),
                      }),
                style: t.textTheme.bodyMedium,
              ),
              if (state.sleepDebt > 0) ...[
                const SizedBox(height: 6),
                Text(
                  '${L.t('sleep_debt')}: ${Util.hours(state.sleepDebt)}',
                  style: t.textTheme.bodySmall?.copyWith(
                    color: scheme.onErrorContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),

        SectionHeader(title: L.t('recovery_steps')),
        for (var i = 0; i < kRecoveryTips.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ExpressiveCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      zh ? kRecoveryTips[i][1] : kRecoveryTips[i][0],
                      style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),

        // ------------------------------------------------- everyday sleep hygiene
        SectionHeader(
          title: L.t('general_tips'),
          subtitle: L.t('general_tips_sub'),
        ),
        ExpressiveCard(
          child: Column(
            children: [
              for (final f in kFactorTags)
                if (f.harmful)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Text(f.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.label(L.lang),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                f.tip(L.lang),
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
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          L.t('recovery_disclaimer'),
          style: t.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
