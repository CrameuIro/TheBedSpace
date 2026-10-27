import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n.dart';
import '../models.dart';
import '../seed.dart';
import '../store.dart';
import '../widgets/ui.dart';
import 'chat_screen.dart';
import 'friend_room_screen.dart';

/// ---------------------------------------------------------------------------
/// Friends (Should-have): check whether a friend is asleep and peek at their
/// room. All data is local demo data — the real social backend is out of scope.
/// ---------------------------------------------------------------------------
class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final awake = kFriends.where((f) => !f.isSleeping(now)).length;
    final state = context.watch<AppState>();

    return PageScaffold(
      title: L.t('friends'),
      subtitle: L.t('friends_sub'),
      action: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded),
        tooltip: L.t('add_friend'),
      ),
      children: [
        HeroTitle(text: L.t('friends'), emoji: '🚪'),
        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PillChip(
              emoji: '🌙',
              label: '${kFriends.length - awake} ${L.t('sleeping')}',
            ),
            PillChip(emoji: '☀️', label: '$awake ${L.t('awake')}'),
          ],
        ),
        const SizedBox(height: 16),

        for (final f in kFriends)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FriendCard(friend: f, now: now),
          ),

        const SizedBox(height: 14),
        SectionHeader(
          title: L.t('permissions'),
          subtitle: L.t('permissions_sub'),
        ),
        ExpressiveCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              for (final f in kFriends)
                SwitchListTile.adaptive(
                  value: state.canFriendView(f.id),
                  onChanged: (allowed) =>
                      state.setFriendPermission(f.id, allowed),
                  secondary: CircleAvatar(
                    backgroundColor: scheme.surfaceContainerHighest,
                    child: Text(f.avatar),
                  ),
                  title: Text(
                    f.name,
                    style: t.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    state.canFriendView(f.id)
                        ? L.t('permission_enabled')
                        : L.t('permission_disabled'),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        ExpressiveCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L.t('wake_hint'),
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
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({required this.friend, required this.now});

  final Friend friend;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final sleeping = friend.isSleeping(now);

    return ExpressiveCard(
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => FriendRoomScreen(friend: friend)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: sleeping
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
                child: Text(
                  friend.avatar,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            friend.name,
                            style: t.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        GoalBadge(
                          state: sleeping ? 'met' : 'close',
                          text: sleeping ? L.t('sleeping') : L.t('awake'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FriendRoomScreen(friend: friend),
                    ),
                  ),
                  icon: const Icon(Icons.meeting_room_rounded, size: 18),
                  label: Text(L.t('visit')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(friend: friend),
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: Text(L.t('chat')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
