import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n.dart';
import '../models.dart';
import '../store.dart';
import '../widgets/character.dart';
import '../widgets/room_scene.dart';
import '../widgets/ui.dart';
import 'decor_screen.dart';
import 'desk_screen.dart';
import 'friends_screen.dart';
import 'recovery_screen.dart';
import 'profile_edit_screen.dart';
import 'settings_screen.dart';
import 'sleep_log_sheet.dart';
import 'stats_screen.dart';
import 'tv_screen.dart';
import 'weekly_screen.dart';

/// ---------------------------------------------------------------------------
/// The virtual bedroom: the app's home. Four pieces of furniture are tappable
/// entry points (bed / TV / desk / door) and the player figure can be dragged.
/// ---------------------------------------------------------------------------
class BedroomScreen extends StatefulWidget {
  const BedroomScreen({super.key});

  @override
  State<BedroomScreen> createState() => _BedroomScreenState();
}

class _BedroomScreenState extends State<BedroomScreen> {
  // Left of centre and above the desk, so the figure never covers a piece the
  // player needs to tap (the desk is the entry point to the sleep data screens).
  Offset _charPos = const Offset(0.40, 0.58);
  bool _showBubble = true;

  bool get _isNight {
    final h = DateTime.now().hour;
    return h >= 22 || h < 7;
  }

  void _onFurnitureTap(FurnitureDef def) {
    switch (def.category) {
      case 'bed':
        showSleepLogSheet(context);
        break;
      case 'media':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const TvScreen()));
        break;
      case 'study':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const DeskScreen()));
        break;
      case 'door':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const FriendsScreen()));
        break;
      default:
        _showItemInfo(def);
    }
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _showItemInfo(FurnitureDef def) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    def.name(L.lang),
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                GoalBadge(
                  state: def.sleepScore >= 0 ? 'met' : 'missed',
                  text:
                      '${L.t('item_score')} ${def.sleepScore >= 0 ? '+' : ''}${def.sleepScore}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              def.effect(L.lang),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${L.t('source')}: ${def.source}',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _character(double w, double h) {
    final state = context.read<AppState>();
    final last = state.entries.isEmpty ? null : state.entries.last;
    final lateNight = state.latestLateNight;
    final cs = w * 0.24;
    const emoji = ['😵', '😕', '😐', '🙂', '😴'];

    return [
      Positioned(
        left: _charPos.dx * w - cs / 2,
        top: _charPos.dy * h - cs / 2,
        width: cs,
        height: cs,
        child: GestureDetector(
          onTap: () => setState(() => _showBubble = !_showBubble),
          onPanUpdate: (d) => setState(() {
            _charPos = Offset(
              (_charPos.dx + d.delta.dx / w).clamp(0.10, 0.90),
              (_charPos.dy + d.delta.dy / h).clamp(0.30, 0.86),
            );
          }),
          child: CharacterFigure(
            size: cs,
            sleeping: _isNight,
            avatar: state.profile?.avatar,
          ),
        ),
      ),
      if (_showBubble)
        Positioned(
          left: (_charPos.dx * w - 78).clamp(4, w - 160),
          // Anchored from the *bottom* so the bubble always sits just above the
          // figure's head. The old top-based anchor made the bubble grow
          // downward over the head, hiding it.
          bottom: (h - (_charPos.dy * h - cs / 2) + 10).clamp(
            12.0,
            math.max(12.0, h - 104.0),
          ),
          width: 156,
          child: Material(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _isNight ? '🌙' : '☀️',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isNight ? L.t('sleeping') : L.t('awake'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (last != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${Util.hours(last.durationHours)}  ${emoji[last.quality - 1]}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        L.t('tap_bed'),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  if (lateNight != null) ...[
                    const SizedBox(height: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => showLateNightSheet(context, lateNight),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '🩹 ${L.t('late_bubble')}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context);
    final profile = state.profile!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.surfaceContainerLow,
              scheme.primaryContainer.withValues(alpha: 0.35),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ------------------------------------------------------------ HUD
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfileEditScreen(),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: scheme.primary,
                                  child: Text(
                                    profile.avatar,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.name,
                                        style: t.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      LevelBar(
                                        compact: true,
                                        level: profile.level,
                                        progress: profile.levelProgress,
                                        xpInLevel: profile.xpInLevel,
                                        xpNeeded: profile.xpForNextLevel,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _CoinChip(coins: profile.coins),
                        IconButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.settings_rounded),
                          tooltip: L.t('settings'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Two explicit doors into the sleep reports — players told us
                    // the data was not discoverable from the bedroom. Scrollable
                    // so it never overflows on a narrow phone.
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _NavPill(
                            icon: Icons.bedtime_rounded,
                            label: L.t('stats'),
                            onTap: () => _open(const StatsScreen()),
                          ),
                          const SizedBox(width: 8),
                          _NavPill(
                            icon: Icons.summarize_rounded,
                            label: L.t('weekly'),
                            onTap: () => _open(const WeeklyScreen()),
                          ),
                          const SizedBox(width: 8),
                          _InfoPill(
                            icon: Icons.nightlight_round,
                            label:
                                '${L.t('room_score')} ${Util.score(state.bedroomSleepScore)}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ----------------------------------------------------------- room
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: RoomScene(
                    items: state.placed,
                    defFor: state.defFor,
                    onTapItem: _onFurnitureTap,
                    draggable: true,
                    onMoveItem: (item, x, y) => state.movePlaced(item, x, y),
                    characterBuilder: _character,
                  ),
                ),
              ),

              // -------------------------------------------------------- actions
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Column(
                  children: [
                    Text(
                      L.t('tap_char'),
                      style: t.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => showSleepLogSheet(context),
                            icon: const Icon(Icons.add_rounded),
                            label: Text(L.t('quick_log')),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const DecorScreen(),
                              ),
                            ),
                            icon: const Icon(Icons.chair_alt_rounded),
                            label: Text(L.t('decorate')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinChip extends StatelessWidget {
  const _CoinChip({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Text('🪙', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text(
            '$coins',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: scheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Deliberately not wrapped in Flexible: this pill lives inside a
    // horizontally scrolling Row (unbounded width), where a flex child would
    // throw a layout error.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// A tappable HUD chip that opens one of the sleep report screens.
class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.secondaryContainer,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: scheme.onSecondaryContainer),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: scheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                size: 15,
                color: scheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
