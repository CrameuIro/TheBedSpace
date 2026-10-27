import 'package:flutter/material.dart';

import '../l10n.dart';
import '../models.dart';
import '../seed.dart';
import '../widgets/character.dart';
import '../widgets/room_scene.dart';
import '../widgets/ui.dart';

Offset _spotFor(String category) => switch (category) {
  'bed' => const Offset(0.26, 0.34),
  'media' => const Offset(0.72, 0.32),
  'study' => const Offset(0.50, 0.72),
  'door' => const Offset(0.88, 0.46),
  'light' => const Offset(0.14, 0.44),
  'wall' => const Offset(0.50, 0.18),
  'rug' => const Offset(0.50, 0.78),
  'plant' => const Offset(0.14, 0.74),
  'chair' => const Offset(0.24, 0.68),
  _ => const Offset(0.5, 0.5),
};

/// ---------------------------------------------------------------------------
/// A friend's room — a read-only view of their decorated bedroom and whether
/// they are asleep right now. (Simulated locally; no server call.)
/// ---------------------------------------------------------------------------
class FriendRoomScreen extends StatelessWidget {
  const FriendRoomScreen({super.key, required this.friend});

  final Friend friend;

  FurnitureDef? _defFor(String id) {
    for (final f in kFurniture) {
      if (f.id == id) return f;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final now = DateTime.now();
    final sleeping = friend.isSleeping(now);

    final items = [
      for (var i = 0; i < friend.furnitureIds.length; i++)
        if (_defFor(friend.furnitureIds[i]) != null)
          PlacedFurniture(
            defId: friend.furnitureIds[i],
            x: _spotFor(_defFor(friend.furnitureIds[i])!.category).dx,
            // nudge repeats apart so identical categories do not stack
            y:
                (_spotFor(_defFor(friend.furnitureIds[i])!.category).dy +
                        (i % 2 == 0 ? 0.0 : 0.08))
                    .clamp(0.12, 0.86),
          ),
    ];

    final score = items.fold<int>(
      0,
      (sum, p) => sum + (_defFor(p.defId)?.sleepScore ?? 0),
    );

    return Scaffold(
      appBar: AppBar(title: Text(L.tr('friend_room', {'name': friend.name}))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: sleeping
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
                child: Text(
                  friend.avatar,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      style: t.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${L.tr('last_sleep', {'h': Util.hours(friend.lastSleepHours)})} · '
                      '${L.tr('streak', {'n': '${friend.streakDays}'})}',
                      style: t.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              GoalBadge(
                state: sleeping ? 'met' : 'close',
                text: sleeping ? L.t('sleeping') : L.t('awake'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          AspectRatio(
            aspectRatio: kRoomAspect,
            child: RoomScene(
              items: items,
              defFor: _defFor,
              onTapItem: (def) => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (_) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        def.name(L.lang),
                        style: t.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        def.effect(L.lang),
                        style: t.textTheme.bodyMedium?.copyWith(height: 1.45),
                      ),
                    ],
                  ),
                ),
              ),
              characterBuilder: (w, h) => [
                Positioned(
                  left: w * 0.52 - w * 0.12,
                  top: h * 0.80 - w * 0.12,
                  width: w * 0.24,
                  height: w * 0.24,
                  child: CharacterFigure(
                    size: w * 0.24,
                    sleeping: sleeping,
                    avatar: friend.avatar,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ExpressiveCard(
            child: Row(
              children: [
                Icon(
                  Icons.nightlight_round,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${L.t('room_score')}: ${score >= 0 ? '+' : ''}$score',
                    style: t.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          FilledButton.icon(
            onPressed: () =>
                showToast(context, L.tr('nudge_sent', {'name': friend.name})),
            icon: const Icon(Icons.notifications_active_rounded),
            label: Text(L.t('nudge')),
          ),
          const SizedBox(height: 10),
          Text(
            L.t('wake_hint'),
            style: t.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
