import 'package:flutter/material.dart';

import '../models.dart';
import 'furniture_art.dart';

export 'furniture_art.dart' show FurniturePainter;

/// ---------------------------------------------------------------------------
/// The virtual bedroom. Furniture is drawn with lightweight vector painters so
/// the room needs no image assets and re-themes with the app colours.
/// ---------------------------------------------------------------------------

/// Width ÷ height of the room. Every screen that shows a room uses it.
const double kRoomAspect = 1.22;

class RoomScene extends StatefulWidget {
  const RoomScene({
    super.key,
    required this.items,
    required this.defFor,
    required this.onTapItem,
    this.draggable = false,
    this.onMoveItem,
    this.overlays = const {},
    this.characterBuilder,
  });

  final List<PlacedFurniture> items;
  final FurnitureDef? Function(String defId) defFor;
  final void Function(FurnitureDef def) onTapItem;
  final bool draggable;
  final void Function(PlacedFurniture item, double nx, double ny)? onMoveItem;

  /// Optional absolutely-positioned decorations keyed by furniture id.
  final Map<String, Widget> overlays;

  /// Builds the overlays that need the room's pixel size (the player figure and
  /// its status bubble).
  final List<Widget> Function(double w, double h)? characterBuilder;

  @override
  State<RoomScene> createState() => _RoomSceneState();
}

class _RoomSceneState extends State<RoomScene> {
  String? _draggingId;
  Offset? _dragPos;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, c) {
        // Always lay the room out at the same aspect ratio, letterboxed into
        // whatever space the screen offers. Furniture sizes and positions are
        // fractions of the room, so a fixed ratio is what keeps the bedroom
        // looking exactly like the decoration preview.
        var w = c.maxWidth;
        var h = c.maxHeight;
        if (!w.isFinite) w = h * kRoomAspect;
        if (!h.isFinite) h = w / kRoomAspect;
        if (w / h > kRoomAspect) {
          w = h * kRoomAspect;
        } else {
          h = w / kRoomAspect;
        }

        return Center(
          child: SizedBox(
            width: w,
            height: h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  // ---------------------------------------------------------- room
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RoomPainter(
                        wall: scheme.surfaceContainerLow,
                        wallTop: scheme.primaryContainer.withValues(
                          alpha: 0.55,
                        ),
                        floor: scheme.surfaceContainerHighest,
                        accent: scheme.primary,
                        window: scheme.tertiaryContainer,
                      ),
                    ),
                  ),

                  // ------------------------------------------------------ furniture
                  for (final item in _depthSorted())
                    _buildItem(context, item, w, h),

                  // ------------------------------------------------------ character
                  if (widget.characterBuilder != null)
                    ...widget.characterBuilder!(w, h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Rugs lie on the floor under everything, wall pieces hang behind the
  /// furniture, and the rest is drawn back-to-front by its base line.
  List<PlacedFurniture> _depthSorted() {
    int layer(FurnitureDef d) => d.category == 'rug'
        ? 0
        : (d.category == 'wall' || d.id == 'tv_xl')
        ? 1
        : 2;
    final list = [
      for (final item in widget.items)
        if (widget.defFor(item.defId) != null) item,
    ];
    list.sort((a, b) {
      final da = widget.defFor(a.defId)!;
      final db = widget.defFor(b.defId)!;
      final byLayer = layer(da).compareTo(layer(db));
      if (byLayer != 0) return byLayer;
      return (a.y + da.height / 2).compareTo(b.y + db.height / 2);
    });
    return list;
  }

  Widget _buildItem(
    BuildContext context,
    PlacedFurniture item,
    double w,
    double h,
  ) {
    final def = widget.defFor(item.defId)!;
    final isDragging = _draggingId == def.id;
    final pos = isDragging && _dragPos != null
        ? _dragPos!
        : Offset(item.x, item.y);

    final iw = def.width * w;
    final ih = def.height * h;

    final child = AnimatedScale(
      scale: isDragging ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 160),
      child: CustomPaint(
        size: Size(iw, ih),
        painter: FurniturePainter(
          defId: def.id,
          category: def.category,
          scheme: Theme.of(context).colorScheme,
        ),
      ),
    );

    return Positioned(
      key: ValueKey('f_${def.id}'),
      left: pos.dx * w - iw / 2,
      top: pos.dy * h - ih / 2,
      width: iw,
      height: ih,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.onTapItem(def),
              onPanStart: widget.draggable
                  ? (_) => setState(() {
                      _draggingId = def.id;
                      _dragPos = Offset(item.x, item.y);
                    })
                  : null,
              onPanUpdate: widget.draggable
                  ? (d) {
                      final p = _dragPos ?? Offset(item.x, item.y);
                      setState(() {
                        _dragPos = Offset(
                          (p.dx + d.delta.dx / w).clamp(0.06, 0.94),
                          (p.dy + d.delta.dy / h).clamp(0.12, 0.86),
                        );
                      });
                    }
                  : null,
              onPanEnd: widget.draggable
                  ? (_) {
                      final p = _dragPos;
                      if (p != null) widget.onMoveItem?.call(item, p.dx, p.dy);
                      setState(() {
                        _draggingId = null;
                        _dragPos = null;
                      });
                    }
                  : null,
              child: child,
            ),
          ),
          if (widget.overlays.containsKey(def.id))
            Positioned(right: -6, top: -10, child: widget.overlays[def.id]!),
          if (widget.draggable && isDragging)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Draws the room shell: back wall, floor, window and a rug-like floor line.
class _RoomPainter extends CustomPainter {
  _RoomPainter({
    required this.wall,
    required this.wallTop,
    required this.floor,
    required this.accent,
    required this.window,
  });

  final Color wall;
  final Color wallTop;
  final Color floor;
  final Color accent;
  final Color window;

  @override
  void paint(Canvas canvas, Size size) {
    final horizon = size.height * 0.58;

    final wallPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [wallTop, wall],
      ).createShader(Rect.fromLTWH(0, 0, size.width, horizon));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, horizon), wallPaint);

    final floorPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [floor, floor.withValues(alpha: 0.75)],
          ).createShader(
            Rect.fromLTWH(0, horizon, size.width, size.height - horizon),
          );
    canvas.drawRect(
      Rect.fromLTWH(0, horizon, size.width, size.height - horizon),
      floorPaint,
    );

    // Skirting board
    canvas.drawRect(
      Rect.fromLTWH(0, horizon - 6, size.width, 6),
      Paint()..color = accent.withValues(alpha: 0.30),
    );

    // Window on the back wall, raised and narrowed so it reads as a window
    // rather than a backdrop the furniture is leaning against.
    final winRect = Rect.fromLTWH(
      size.width * 0.42,
      horizon * 0.10,
      size.width * 0.16,
      horizon * 0.30,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(winRect, const Radius.circular(10)),
      Paint()..color = window,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(winRect, const Radius.circular(10)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = accent.withValues(alpha: 0.45),
    );
    canvas.drawLine(
      Offset(winRect.center.dx, winRect.top),
      Offset(winRect.center.dx, winRect.bottom),
      Paint()
        ..color = accent.withValues(alpha: 0.45)
        ..strokeWidth = 3,
    );

    // Night sky detail: a small moon
    canvas.drawCircle(
      Offset(winRect.right - 12, winRect.top + 12),
      5,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    // Floorboards converging towards the back wall give the room depth.
    final board = Paint()
      ..color = accent.withValues(alpha: 0.10)
      ..strokeWidth = 1.5;
    final vanish = Offset(size.width / 2, horizon - size.height * 0.9);
    for (var i = -6; i <= 6; i++) {
      final bottom = Offset(
        size.width / 2 + i * size.width * 0.16,
        size.height,
      );
      final t = (horizon - bottom.dy) / (vanish.dy - bottom.dy);
      canvas.drawLine(Offset.lerp(bottom, vanish, t)!, bottom, board);
    }
    for (final f in [0.22, 0.50, 0.82]) {
      final y = horizon + (size.height - horizon) * f;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), board);
    }
  }

  @override
  bool shouldRepaint(_RoomPainter old) =>
      old.wall != wall || old.floor != floor;
}
