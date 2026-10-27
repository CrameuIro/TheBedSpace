import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A vector "player" figure for the bedroom, drawn with human proportions:
/// hair, a face with eyes / brows / nose / mouth, a neck, arms with hands, and
/// legs with shoes. Awake, it wears a hoodie and jeans; asleep, it switches to
/// striped pyjamas and slippers, closes its eyes and hugs a pillow.
class CharacterFigure extends StatelessWidget {
  const CharacterFigure({
    super.key,
    required this.size,
    required this.sleeping,
    this.avatar,
    this.bubbleLabel,
  });

  /// Square box the figure is drawn inside.
  final double size;
  final bool sleeping;

  /// The player's chosen emoji, worn as a small badge on the chest.
  final String? avatar;
  final String? bubbleLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FigurePainter(
          sleeping: sleeping,
          cloth: scheme.primary,
          outline: scheme.onSurface.withValues(alpha: 0.55),
          fontFamily: DefaultTextStyle.of(context).style.fontFamily,
        ),
        child: avatar == null || sleeping
            ? null
            : Align(
                alignment: const Alignment(0.18, -0.05),
                child: Text(avatar!, style: TextStyle(fontSize: size * 0.07)),
              ),
      ),
    );
  }
}

class _FigurePainter extends CustomPainter {
  _FigurePainter({
    required this.sleeping,
    required this.cloth,
    required this.outline,
    this.fontFamily,
  });

  final bool sleeping;
  final Color cloth;
  final Color outline;

  /// Font for the "zzz", taken from the surrounding text style.
  final String? fontFamily;

  static const _skin = Color(0xFFF1C9A5);
  static const _skinShade = Color(0xFFD9A47E);
  static const _hair = Color(0xFF3B2A22);
  static const _hairLight = Color(0xFF5A4134);
  static const _iris = Color(0xFF4A3426);
  static const _lips = Color(0xFFB5574B);
  static const _denim = Color(0xFF3D4A63);
  static const _shoe = Color(0xFFF4F1EC);

  Paint _fill(Color c) => Paint()..color = c;

  Paint _line(double w, [Color? c]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = c ?? outline;

  void _shape(Canvas c, Path p, Color col) {
    c.drawPath(p, _fill(col));
    c.drawPath(p, _line(0.6));
  }

  @override
  void paint(Canvas canvas, Size s) {
    if (s.isEmpty) return;
    // Everything is drawn on a 100 × 100 design canvas.
    final k = math.min(s.width, s.height) / 100;
    canvas.save();
    canvas.translate((s.width - 100 * k) / 2, (s.height - 100 * k) / 2);
    canvas.scale(k);

    final top = sleeping ? Color.lerp(cloth, Colors.white, 0.55)! : cloth;
    final bottom = sleeping ? Color.lerp(cloth, Colors.white, 0.35)! : _denim;

    // ground shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 96.5), width: 36, height: 5),
      _fill(Colors.black.withValues(alpha: 0.14)),
    );

    _legs(canvas, bottom);
    _torso(canvas, top);
    _arms(canvas, top);
    _head(canvas);

    if (sleeping) _zzz(canvas);
    canvas.restore();
  }

  void _legs(Canvas c, Color col) {
    for (final x in [41.0, 51.0]) {
      final leg = Path()
        ..moveTo(x, 64)
        ..lineTo(x + 8.5, 64)
        ..lineTo(x + 8, 92)
        ..lineTo(x + 0.6, 92)
        ..close();
      _shape(c, leg, col);
    }
    // inner seam
    c.drawLine(const Offset(50, 66), const Offset(50, 91), _line(0.5));
    // shoes / slippers
    final shoe = sleeping ? Color.lerp(cloth, Colors.white, 0.2)! : _shoe;
    for (final r in [
      const Rect.fromLTWH(37.5, 90, 13, 6),
      const Rect.fromLTWH(49.5, 90, 13, 6),
    ]) {
      final rr = RRect.fromRectAndCorners(
        r,
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      );
      c.drawRRect(rr, _fill(shoe));
      c.drawRRect(rr, _line(0.6));
      if (!sleeping) {
        c.drawLine(
          Offset(r.left + 1, r.bottom - 1.2),
          Offset(r.right - 1, r.bottom - 1.2),
          _line(1, const Color(0xFFBDB6AC)),
        );
      }
    }
  }

  void _torso(Canvas c, Color col) {
    // neck
    c.drawRect(const Rect.fromLTWH(46.5, 31, 7, 8), _fill(_skinShade));
    final body = Path()
      ..moveTo(38, 41)
      ..quadraticBezierTo(39, 37, 44, 36.5)
      ..lineTo(56, 36.5)
      ..quadraticBezierTo(61, 37, 62, 41)
      ..lineTo(63, 66)
      ..quadraticBezierTo(50, 68.5, 37, 66)
      ..close();
    _shape(c, body, col);
    if (sleeping) {
      // pyjama stripes, clipped to the shirt
      c.save();
      c.clipPath(body);
      final stripe = _line(1.6, Color.lerp(cloth, Colors.white, 0.15)!);
      for (var x = 40.0; x < 62; x += 4.5) {
        c.drawLine(Offset(x, 36), Offset(x, 68), stripe);
      }
      c.restore();
      c.drawPath(body, _line(0.6));
      // collar
      final collar = Path()
        ..moveTo(45, 36.8)
        ..lineTo(50, 42)
        ..lineTo(55, 36.8);
      c.drawPath(collar, _line(0.9));
    } else {
      // hood folds behind the neck and drawstrings
      final hood = Path()
        ..moveTo(43.5, 37)
        ..quadraticBezierTo(50, 43, 56.5, 37)
        ..quadraticBezierTo(50, 39.5, 43.5, 37)
        ..close();
      c.drawPath(hood, _fill(Color.lerp(col, Colors.black, 0.25)!));
      c.drawLine(
        const Offset(47.5, 40),
        const Offset(47, 47),
        _line(0.7, Colors.white),
      );
      c.drawLine(
        const Offset(52.5, 40),
        const Offset(53, 47),
        _line(0.7, Colors.white),
      );
      // front pocket and ribbed hem
      final pocket = Path()
        ..moveTo(43, 55)
        ..lineTo(57, 55)
        ..lineTo(59, 63)
        ..lineTo(41, 63)
        ..close();
      c.drawPath(pocket, _line(0.6));
      c.drawLine(
        const Offset(37.5, 64),
        const Offset(62.5, 64),
        _line(0.6, Color.lerp(col, Colors.black, 0.35)!),
      );
    }
  }

  void _arms(Canvas c, Color col) {
    final sleeve = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = col;
    final sleeveEdge = _line(8.2);
    if (sleeping) {
      // arms folded round a pillow
      final left = Path()
        ..moveTo(39.5, 41)
        ..quadraticBezierTo(35, 50, 41, 55);
      final right = Path()
        ..moveTo(60.5, 41)
        ..quadraticBezierTo(65, 50, 59, 55);
      for (final p in [left, right]) {
        c.drawPath(p, sleeveEdge);
        c.drawPath(p, sleeve);
      }
      final pillow = RRect.fromRectAndRadius(
        const Rect.fromLTWH(37, 46, 26, 15),
        const Radius.circular(6),
      );
      c.drawRRect(pillow, _fill(Colors.white));
      c.drawRRect(pillow, _line(0.6));
      c.drawLine(
        const Offset(41, 53.5),
        const Offset(59, 53.5),
        _line(0.5, const Color(0x33000000)),
      );
      for (final o in [const Offset(42, 56), const Offset(58, 56)]) {
        c.drawCircle(o, 3, _fill(_skin));
        c.drawCircle(o, 3, _line(0.5));
      }
    } else {
      // relaxed arms at the sides
      final left = Path()
        ..moveTo(39.5, 41)
        ..quadraticBezierTo(35.5, 50, 35, 60);
      final right = Path()
        ..moveTo(60.5, 41)
        ..quadraticBezierTo(64.5, 50, 65, 60);
      for (final p in [left, right]) {
        c.drawPath(p, sleeveEdge);
        c.drawPath(p, sleeve);
      }
      for (final o in [const Offset(35, 63.5), const Offset(65, 63.5)]) {
        c.drawOval(
          Rect.fromCenter(center: o, width: 5.6, height: 6.4),
          _fill(_skin),
        );
        c.drawOval(
          Rect.fromCenter(center: o, width: 5.6, height: 6.4),
          _line(0.5),
        );
      }
    }
  }

  void _head(Canvas c) {
    // back hair (behind the face)
    final back = Path()
      ..moveTo(37.5, 28)
      ..quadraticBezierTo(35, 9, 50, 7)
      ..quadraticBezierTo(65, 9, 62.5, 28)
      ..quadraticBezierTo(58, 27, 57, 22)
      ..lineTo(43, 22)
      ..quadraticBezierTo(42, 27, 37.5, 28)
      ..close();
    c.drawPath(back, _fill(_hair));

    // ears
    for (final x in [39.0, 61.0]) {
      final ear = Rect.fromCenter(center: Offset(x, 23), width: 4, height: 6);
      c.drawOval(ear, _fill(_skinShade));
      c.drawOval(ear, _line(0.5));
    }

    // face
    final face = Path()
      ..moveTo(39.5, 20)
      ..quadraticBezierTo(39, 31, 50, 34)
      ..quadraticBezierTo(61, 31, 60.5, 20)
      ..quadraticBezierTo(60, 10, 50, 10)
      ..quadraticBezierTo(40, 10, 39.5, 20)
      ..close();
    _shape(c, face, _skin);

    // fringe
    final fringe = Path()
      ..moveTo(38.5, 22)
      ..quadraticBezierTo(37.5, 8, 50, 7.5)
      ..quadraticBezierTo(62.5, 8, 61.5, 22)
      ..quadraticBezierTo(60.5, 16.5, 57.5, 15.5)
      ..quadraticBezierTo(54.5, 18, 51.5, 15)
      ..quadraticBezierTo(47.5, 18.5, 43.5, 15.5)
      ..quadraticBezierTo(40, 16, 38.5, 22)
      ..close();
    c.drawPath(fringe, _fill(_hair));
    c.drawPath(
      Path()
        ..moveTo(44, 10.5)
        ..quadraticBezierTo(50, 8.6, 56, 10.5),
      _line(0.8, _hairLight),
    );

    // brows
    final brow = _line(0.9, _hair);
    if (sleeping) {
      c.drawLine(const Offset(43.8, 19), const Offset(47.4, 19.3), brow);
      c.drawLine(const Offset(52.6, 19.3), const Offset(56.2, 19), brow);
    } else {
      c.drawLine(const Offset(43.6, 18.7), const Offset(47.4, 18.2), brow);
      c.drawLine(const Offset(52.6, 18.2), const Offset(56.4, 18.7), brow);
    }

    // eyes
    for (final x in [45.6, 54.4]) {
      if (sleeping) {
        c.drawArc(
          Rect.fromCenter(center: Offset(x, 22.4), width: 4.4, height: 2.6),
          0.15,
          math.pi - 0.3,
          false,
          _line(0.8, _iris),
        );
      } else {
        final eye = Rect.fromCenter(
          center: Offset(x, 22.6),
          width: 4.4,
          height: 3.2,
        );
        c.drawOval(eye, _fill(Colors.white));
        c.drawCircle(Offset(x + 0.1, 22.7), 1.35, _fill(_iris));
        c.drawCircle(Offset(x + 0.6, 22.1), 0.45, _fill(Colors.white));
        c.drawArc(eye, math.pi + 0.1, math.pi - 0.2, false, _line(0.7, _iris));
      }
    }

    // nose
    c.drawPath(
      Path()
        ..moveTo(50.2, 24.2)
        ..quadraticBezierTo(51.2, 26.4, 49.6, 26.8),
      _line(0.6, _skinShade),
    );

    // cheeks
    for (final x in [42.6, 57.4]) {
      c.drawCircle(
        Offset(x, 26.6),
        1.9,
        _fill(const Color(0xFFF08A8A).withValues(alpha: 0.32)),
      );
    }

    // mouth
    if (sleeping) {
      c.drawOval(
        Rect.fromCenter(center: const Offset(50, 29.4), width: 2, height: 1.5),
        _fill(_lips.withValues(alpha: 0.8)),
      );
    } else {
      c.drawArc(
        Rect.fromCenter(center: const Offset(50, 28.4), width: 5, height: 2.6),
        0.2,
        math.pi - 0.4,
        false,
        _line(0.8, _lips),
      );
    }
  }

  void _zzz(Canvas c) {
    final style = TextStyle(
      fontFamily: fontFamily,
      color: outline,
      fontWeight: FontWeight.w800,
      fontSize: 9,
    );
    var x = 63.0;
    var y = 14.0;
    for (final size in [7.0, 9.0, 11.0]) {
      final tp = TextPainter(
        text: TextSpan(
          text: 'z',
          style: style.copyWith(fontSize: size),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(c, Offset(x, y));
      x += 5;
      y -= 6;
    }
  }

  @override
  bool shouldRepaint(_FigurePainter old) =>
      old.sleeping != sleeping || old.cloth != cloth || old.outline != outline;
}
