import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n.dart';
import '../services/notifications.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'profile_edit_screen.dart';

/// ---------------------------------------------------------------------------
/// Settings: profile summary, appearance (dark mode + theme colour + language),
/// data utilities and the about box.
/// ---------------------------------------------------------------------------
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final profile = state.profile;

    return PageScaffold(
      title: L.t('settings'),
      children: [
        // ---------------------------------------------------------------- profile
        ExpressiveCard(
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: scheme.primary,
                child: Text(
                  profile?.avatar ?? '🧑‍🎓',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.name ?? '',
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${L.t('my_level')} ${profile?.level ?? 1} · 🪙 ${profile?.coins ?? 0}',
                      style: t.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ------------------------------------------------------------- appearance
        SectionHeader(title: L.t('display')),
        ExpressiveCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                L.t('dark_mode'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(L.t('dark_auto')),
                    icon: const Icon(Icons.brightness_auto_rounded),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(L.t('theme_light')),
                    icon: const Icon(Icons.light_mode_rounded),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(L.t('theme_dark')),
                    icon: const Icon(Icons.dark_mode_rounded),
                  ),
                ],
                selected: {state.themeMode},
                onSelectionChanged: (s) => state.setThemeMode(s.first),
              ),
              const SizedBox(height: 20),

              Text(
                L.t('colour'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (var i = 0; i < kSeedPalettes.length; i++)
                    _SeedDot(
                      index: i,
                      selected: state.seedIndex == i,
                      onTap: () => state.setSeedIndex(i),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                state.seedIndex == 0
                    ? ''
                    : (L.lang == 'zh'
                          ? kSeedPalettes[state.seedIndex].zh
                          : kSeedPalettes[state.seedIndex].en),
                style: t.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                L.t('language'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'en', label: Text('English')),
                  ButtonSegment(value: 'zh', label: Text('中文')),
                ],
                selected: {state.lang},
                onSelectionChanged: (s) => state.setLang(s.first),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ------------------------------------------------------------------- data
        SectionHeader(title: L.t('data'), subtitle: L.t('data_sub')),
        ExpressiveCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    NotificationService.available
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      NotificationService.available
                          ? L.t('notif_sub')
                          : L.t('notif_unavailable'),
                      style: t.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Manual escape hatch: re-ask for the notification permission if
              // it was previously dismissed.
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: NotificationService.available
                      ? () async {
                          final granted =
                              await NotificationService.requestPermission();
                          if (!context.mounted) return;
                          showToast(
                            context,
                            granted
                                ? L.t('notif_granted')
                                : L.t('notif_denied'),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.notifications_none_rounded),
                  label: Text(L.t('notif_request')),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    await state.loadDemoData();
                    if (!context.mounted) return;
                    showToast(context, L.t('demo_done'));
                  },
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: Text(L.t('demo_data')),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.error,
                    side: BorderSide(
                      color: scheme.error.withValues(alpha: 0.5),
                    ),
                  ),
                  onPressed: () => _confirmErase(context),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(L.t('reset_all')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ------------------------------------------------------------------ about
        SectionHeader(title: L.t('about')),
        ExpressiveCard(
          child: Text(
            L.t('about_body'),
            style: t.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmErase(BuildContext context) async {
    final state = context.read<AppState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L.t('reset_all')),
        content: Text(L.t('reset_all_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(L.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(L.t('ok')),
          ),
        ],
      ),
    );
    if (ok != true) return;
    // The root widget is keyed on the login state, so clearing the profile
    // rebuilds the navigator and lands on the login screen by itself. Pushing
    // that screen manually here used to leave a route the bedroom swap could
    // never replace, which is why "Enter my bedroom" stopped responding.
    await state.eraseAll();
  }
}

class _SeedDot extends StatelessWidget {
  const _SeedDot({
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = kSeedPalettes[index];
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: palette.color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? scheme.onSurface : Colors.transparent,
            width: selected ? 3.5 : 0,
          ),
        ),
        child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white)
            : null,
      ),
    );
  }
}
