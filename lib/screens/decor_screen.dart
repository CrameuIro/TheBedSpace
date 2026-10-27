import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n.dart';
import '../models.dart';
import '../seed.dart';
import '../store.dart';
import '../widgets/charts.dart';
import '../widgets/room_scene.dart';
import '../widgets/ui.dart';

/// Default drop position for a freshly placed piece, by category.
Offset _defaultSpot(String category) => switch (category) {
  'bed' => const Offset(0.25, 0.74),
  'media' => const Offset(0.80, 0.28),
  'study' => const Offset(0.66, 0.78),
  'door' => const Offset(0.11, 0.44),
  'light' => const Offset(0.16, 0.42),
  'wall' => const Offset(0.62, 0.16),
  'rug' => const Offset(0.50, 0.80),
  'plant' => const Offset(0.14, 0.72),
  'chair' => const Offset(0.40, 0.62),
  _ => const Offset(0.5, 0.5),
};

/// Whether the Decoration screen shows the bedroom sleep score card.
const bool _showRoomScore = false;

const Map<String, String> _catEmoji = {
  'bed': '🛏️',
  'media': '📺',
  'study': '💻',
  'door': '🚪',
  'light': '💡',
  'rug': '🧶',
  'plant': '🪴',
  'wall': '🖼️',
  'chair': '🪑',
};

/// ---------------------------------------------------------------------------
/// Decoration: arrange the bedroom, shop for furniture, and see how the room
/// score relates to the sleep hours you logged (the project's key hypothesis).
/// ---------------------------------------------------------------------------
class DecorScreen extends StatefulWidget {
  const DecorScreen({super.key});

  @override
  State<DecorScreen> createState() => _DecorScreenState();
}

class _DecorScreenState extends State<DecorScreen> {
  bool _showShop = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final corr = state.roomSleepCorrelation;

    final defs = [...kFurniture]
      ..sort((a, b) {
        final ao = state.unlocked.contains(a.id) ? 0 : 1;
        final bo = state.unlocked.contains(b.id) ? 0 : 1;
        if (ao != bo) return ao - bo;
        return a.unlockLevel.compareTo(b.unlockLevel);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text(L.t('decoration')),
        actions: [
          IconButton(
            tooltip: L.t('reset_room'),
            onPressed: () async {
              await state.resetRoom();
              if (!context.mounted) return;
              showToast(context, L.t('reset_room_done'));
            },
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          HeroTitle(text: L.t('decoration'), emoji: '🎨'),
          const SizedBox(height: 6),
          Text(
            L.t('decor_sub'),
            style: t.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),

          // ----------------------------------------------------------- room preview
          AspectRatio(
            aspectRatio: kRoomAspect,
            child: RoomScene(
              items: state.placed,
              defFor: state.defFor,
              onTapItem: (def) => _showExplanation(context, def),
              draggable: true,
              onMoveItem: (item, x, y) => state.movePlaced(item, x, y),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.open_with_rounded,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  L.t('drag_hint'),
                  style: t.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                '${state.placed.length} ${L.t('placed')}',
                style: t.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ------------------------------------------------------------ room score
          // Hidden while decorating: the bedroom is graded secretly, as in
          // Ethan's BedScreen prototype. Set [_showRoomScore] to show it again.
          if (_showRoomScore) ...[
            SectionHeader(
              title: L.t('room_score'),
              subtitle: L.t('room_score_sub'),
            ),
            ExpressiveCard(
              child: Row(
                children: [
                  ScoreRing(
                    value: state.bedroomSleepScore,
                    // 12 summed points, divided by four as in BedScreen.cpp.
                    max: 12 / AppState.kScoreDivisor,
                    valueText: Util.score(state.bedroomSleepScore),
                    size: 120,
                    label: L.t('score'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.bedroomSleepScore >= 1.5
                              ? L.t('room_verdict_good')
                              : state.bedroomSleepScore >= 0
                              ? L.t('room_verdict_ok')
                              : L.t('room_verdict_bad'),
                          style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${state.placed.length} / ${kFurniture.length} ${L.t('owned')}',
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
          ],

          // ------------------------------------------------------- correlation view
          SectionHeader(
            title: L.t('correlation'),
            subtitle: L.t('correlation_sub'),
          ),
          ExpressiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (corr.n < 3)
                  Text(
                    L.tr('insufficient', {'n': '${3 - corr.n}'}),
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                else ...[
                  CorrelationScatter(entries: state.entries),
                  const SizedBox(height: 12),
                  Text(
                    corr.r.abs() < 0.15
                        ? L.tr('corr_flat', {
                            'r': corr.r.toStringAsFixed(2),
                            'n': '3',
                          })
                        : corr.r > 0
                        ? L.tr('corr_positive', {
                            'r': corr.r.toStringAsFixed(2),
                          })
                        : L.tr('corr_negative', {
                            'r': corr.r.toStringAsFixed(2),
                          }),
                    style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ------------------------------------------------------------------ shop
          SectionHeader(
            title: L.t('shop'),
            subtitle: L.t('shop_sub'),
            trailing: IconButton(
              tooltip: L.t('shop'),
              onPressed: () => setState(() => _showShop = !_showShop),
              icon: Icon(
                _showShop
                    ? Icons.unfold_less_rounded
                    : Icons.unfold_more_rounded,
              ),
            ),
          ),
          if (_showShop)
            for (final def in defs)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ShopTile(
                  def: def,
                  state: state,
                  onTap: () => _showExplanation(context, def),
                ),
              ),
        ],
      ),
    );
  }

  /// Shared "furniture explanation" sheet — required by the brief so that the
  /// score is never unexplained.
  void _showExplanation(BuildContext context, FurnitureDef def) {
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
                Text(
                  _catEmoji[def.category] ?? '🪑',
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(width: 10),
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
            const SizedBox(height: 14),
            Text(
              def.effect(L.lang),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 14),
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
}

class _ShopTile extends StatelessWidget {
  const _ShopTile({
    required this.def,
    required this.state,
    required this.onTap,
  });

  final FurnitureDef def;
  final AppState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final level = state.profile?.level ?? 1;
    final owned = state.unlocked.contains(def.id);
    final placed = state.isPlaced(def.id);
    final locked = level < def.unlockLevel;

    return ExpressiveCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A thumbnail of the actual piece, drawn with the room's own art.
          Container(
            width: 64,
            height: 56,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              painter: FurniturePainter(
                defId: def.id,
                category: def.category,
                scheme: scheme,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        def.name(L.lang),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    GoalBadge(
                      state: def.sleepScore >= 0 ? 'met' : 'missed',
                      text:
                          '${def.sleepScore >= 0 ? '+' : ''}${def.sleepScore}',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  def.effect(L.lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                if (locked)
                  Text(
                    L.tr('unlock_at_level', {'n': '${def.unlockLevel}'}),
                    style: t.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else if (!owned)
                  Text(
                    L.tr('buy', {'n': '${def.price}'}),
                    style: t.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                else
                  Text(
                    placed ? L.t('placed') : L.t('owned'),
                    style: t.textTheme.bodySmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ActionButton(
            def: def,
            state: state,
            owned: owned,
            placed: placed,
            locked: locked,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.def,
    required this.state,
    required this.owned,
    required this.placed,
    required this.locked,
  });

  final FurnitureDef def;
  final AppState state;
  final bool owned;
  final bool placed;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    if (locked) {
      return const Icon(Icons.lock_outline_rounded, size: 20);
    }
    if (!owned) {
      return FilledButton.tonal(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        ),
        onPressed: () async {
          final ok = await state.buyFurniture(def);
          if (!context.mounted) return;
          showToast(
            context,
            ok ? L.tr('bought', {'name': def.name(L.lang)}) : L.t('not_enough'),
          );
        },
        child: Text('🪙 ${def.price}'),
      );
    }
    final spot = _defaultSpot(def.category);
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
      ),
      onPressed: () => state.togglePlaced(def, x: spot.dx, y: spot.dy),
      child: Text(placed ? L.t('remove') : L.t('place')),
    );
  }
}
