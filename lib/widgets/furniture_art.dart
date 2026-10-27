import 'dart:math' as math;

import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// Vector art for every catalogue piece.
///
/// Each piece is drawn by its id (never guessed from its on-screen aspect
/// ratio) on a fixed design canvas that is 100 units tall. The canvas is
/// scaled uniformly into the box the room gives it, so a piece keeps the same
/// shape in the bedroom, the decoration preview, a friend's room and the shop.
/// ---------------------------------------------------------------------------
class FurniturePainter extends CustomPainter {
  FurniturePainter({
    required this.defId,
    required this.category,
    required this.scheme,
  });

  final String defId;
  final String category;
  final ColorScheme scheme;

  static const _ink = Color(0x8C2E2420);
  static const _wood = Color(0xFFB07A52);
  static const _woodLight = Color(0xFFCB9A6E);
  static const _woodDark = Color(0xFF7A4E33);
  static const _sheet = Color(0xFFF8F5F0);
  static const _metal = Color(0xFF4A4F57);
  static const _plastic = Color(0xFFF2F0EC);
  static const _brass = Color(0xFFE0B04A);

  Color get _fabric => scheme.primaryContainer;
  Color get _fabricDeep => scheme.primary;
  Color get _accent => scheme.tertiary;

  /// Design-canvas width per piece (height is always 100). These match each
  /// piece's proportions inside the fixed-aspect room, so nothing is squashed.
  static const Map<String, double> _designWidth = {
    'bed_basic': 197,
    'bed_luxury': 192,
    'bed_canopy': 203,
    'tv_basic': 159,
    'tv_xl': 189,
    'noise_machine': 139,
    'air_purifier': 98,
    'desk_basic': 183,
    'desk_tidy_dual': 207,
    'door_basic': 58,
    'lamp_warm': 71,
    'lamp_amber_desk': 85,
    'plant_fern': 85,
    'rug_wool': 179,
    'curtain_blackout': 122,
    'bookshelf': 86,
    'poster_calm': 137,
    'reading_chair': 111,
    'beanbag': 134,
  };

  static const Map<String, double> _categoryWidth = {
    'bed': 197,
    'media': 159,
    'study': 183,
    'door': 58,
    'light': 71,
    'plant': 85,
    'rug': 179,
    'wall': 137,
    'chair': 111,
  };

  /// Pieces that hang on the wall are centred in their box; everything else
  /// stands on the floor, so it is anchored to the bottom edge.
  static const Set<String> _hanging = {
    'curtain_blackout',
    'poster_calm',
    'tv_xl',
    'rug_wool',
  };

  @override
  void paint(Canvas canvas, Size s) {
    if (s.isEmpty) return;
    final dw = _designWidth[defId] ?? _categoryWidth[category] ?? 120.0;
    const dh = 100.0;
    final k = math.min(s.width / dw, s.height / dh);
    final dx = (s.width - dw * k) / 2;
    final dy = _hanging.contains(defId)
        ? (s.height - dh * k) / 2
        : s.height - dh * k;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(k);
    switch (defId) {
      case 'bed_basic':
        _bedBasic(canvas);
      case 'bed_luxury':
        _bedLuxury(canvas);
      case 'bed_canopy':
        _bedCot(canvas);
      case 'tv_basic':
        _tvBasic(canvas);
      case 'tv_xl':
        _tvWall(canvas);
      case 'noise_machine':
        _noiseMachine(canvas);
      case 'air_purifier':
        _purifier(canvas);
      case 'desk_basic':
        _deskBasic(canvas);
      case 'desk_tidy_dual':
        _deskDual(canvas);
      case 'door_basic':
        _door(canvas);
      case 'lamp_warm':
        _floorLamp(canvas);
      case 'lamp_amber_desk':
        _amberLamp(canvas);
      case 'plant_fern':
        _fern(canvas);
      case 'rug_wool':
        _rug(canvas);
      case 'curtain_blackout':
        _curtains(canvas);
      case 'bookshelf':
        _bookshelf(canvas);
      case 'poster_calm':
        _poster(canvas);
      case 'reading_chair':
        _armchair(canvas);
      case 'beanbag':
        _beanbag(canvas);
      default:
        _byCategory(canvas, dw);
    }
    canvas.restore();
  }

  void _byCategory(Canvas c, double dw) {
    switch (category) {
      case 'bed':
        _bedBasic(c);
      case 'media':
        _tvBasic(c);
      case 'study':
        _deskBasic(c);
      case 'door':
        _door(c);
      case 'light':
        _floorLamp(c);
      case 'rug':
        _rug(c);
      case 'plant':
        _fern(c);
      case 'wall':
        _poster(c);
      case 'chair':
        _armchair(c);
      default:
        _rr(c, _r(4, 4, dw - 8, 92), 10, scheme.surfaceContainerHighest);
    }
  }

  // ----------------------------------------------------------------- helpers

  Rect _r(double l, double t, double w, double h) => Rect.fromLTWH(l, t, w, h);

  Paint _stroke([double w = 1.4, Color col = _ink]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..color = col;

  Color _shade(Color col, double t) => Color.lerp(col, Colors.black, t)!;
  Color _tint(Color col, double t) => Color.lerp(col, Colors.white, t)!;

  void _rr(Canvas c, Rect r, double rad, Color col, {bool line = true}) {
    final rr = RRect.fromRectAndRadius(r, Radius.circular(rad));
    c.drawRRect(rr, Paint()..color = col);
    if (line) c.drawRRect(rr, _stroke());
  }

  /// Rounded only along the top edge (headboards, chair backs, lamp shades).
  void _top(Canvas c, Rect r, double rad, Color col, {bool line = true}) {
    final rr = RRect.fromRectAndCorners(
      r,
      topLeft: Radius.circular(rad),
      topRight: Radius.circular(rad),
    );
    c.drawRRect(rr, Paint()..color = col);
    if (line) c.drawRRect(rr, _stroke());
  }

  void _path(Canvas c, Path p, Color col, {bool line = true}) {
    c.drawPath(p, Paint()..color = col);
    if (line) c.drawPath(p, _stroke());
  }

  void _shadow(Canvas c, double cx, double y, double w) {
    c.drawOval(
      Rect.fromCenter(center: Offset(cx, y), width: w, height: 7),
      Paint()..color = const Color(0x26000000),
    );
  }

  void _glow(Canvas c, Offset o, double r, Color col, double alpha) {
    c.drawCircle(
      o,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            col.withValues(alpha: alpha),
            col.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: o, radius: r)),
    );
  }

  /// A dark glass panel showing a calm night sky, with a glass reflection.
  void _nightScreen(Canvas c, Rect r, double rad) {
    final rr = RRect.fromRectAndRadius(r, Radius.circular(rad));
    c.drawRRect(
      rr,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E4372), Color(0xFF121829)],
        ).createShader(r),
    );
    c.save();
    c.clipRRect(rr);
    // rolling hills
    final hills = Path()
      ..moveTo(r.left, r.bottom - r.height * 0.18)
      ..quadraticBezierTo(
        r.left + r.width * 0.30,
        r.bottom - r.height * 0.42,
        r.left + r.width * 0.60,
        r.bottom - r.height * 0.20,
      )
      ..quadraticBezierTo(
        r.left + r.width * 0.80,
        r.bottom - r.height * 0.08,
        r.right,
        r.bottom - r.height * 0.26,
      )
      ..lineTo(r.right, r.bottom)
      ..lineTo(r.left, r.bottom)
      ..close();
    c.drawPath(hills, Paint()..color = const Color(0xFF1B2A44));
    // moon
    final moon = Offset(r.left + r.width * 0.74, r.top + r.height * 0.30);
    final mr = r.height * 0.13;
    _glow(c, moon, mr * 3, const Color(0xFFFFF3C4), 0.35);
    c.drawCircle(moon, mr, Paint()..color = const Color(0xFFFFF3C4));
    c.drawCircle(
      moon.translate(mr * 0.5, -mr * 0.3),
      mr * 0.9,
      Paint()..color = const Color(0xFF2B3F6B),
    );
    // stars
    final star = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (final p in const [
      Offset(0.14, 0.22),
      Offset(0.30, 0.12),
      Offset(0.46, 0.30),
      Offset(0.58, 0.14),
      Offset(0.90, 0.18),
      Offset(0.22, 0.44),
    ]) {
      c.drawCircle(
        Offset(r.left + r.width * p.dx, r.top + r.height * p.dy),
        r.height * 0.025,
        star,
      );
    }
    // reflection
    final refl = Path()
      ..moveTo(r.left + r.width * 0.06, r.bottom)
      ..lineTo(r.left + r.width * 0.36, r.top)
      ..lineTo(r.left + r.width * 0.48, r.top)
      ..lineTo(r.left + r.width * 0.18, r.bottom)
      ..close();
    c.drawPath(refl, Paint()..color = Colors.white.withValues(alpha: 0.08));
    c.restore();
  }

  // -------------------------------------------------------------------- beds

  /// Side-on single bed: tall headboard on the left, low footboard on the
  /// right, white mattress, pillow and a folded-back blanket.
  void _bedBasic(Canvas c) {
    _shadow(c, 98, 96, 188);
    _rr(c, _r(14, 80, 8, 16), 2, _woodDark);
    _rr(c, _r(176, 80, 8, 16), 2, _woodDark);
    _rr(c, _r(10, 62, 178, 22), 5, _wood);
    c.drawLine(
      const Offset(16, 66),
      const Offset(182, 66),
      _stroke(1.2, _woodLight),
    );
    _rr(c, _r(16, 48, 168, 18), 8, _sheet);
    // pillow
    _rr(c, _r(26, 33, 42, 19), 9, Colors.white);
    c.drawLine(
      const Offset(34, 42),
      const Offset(60, 42),
      _stroke(1, const Color(0x33000000)),
    );
    // blanket draped over the side rail
    final blanket = RRect.fromRectAndRadius(
      _r(64, 44, 116, 36),
      const Radius.circular(8),
    );
    c.drawRRect(blanket, Paint()..color = _fabricDeep);
    c.save();
    c.clipRRect(blanket);
    for (var x = 84.0; x < 180; x += 16) {
      c.drawLine(
        Offset(x, 44),
        Offset(x, 80),
        _stroke(3, _tint(_fabricDeep, 0.25).withValues(alpha: 0.6)),
      );
    }
    c.drawRect(_r(64, 44, 18, 36), Paint()..color = _tint(_fabricDeep, 0.45));
    c.restore();
    c.drawRRect(blanket, _stroke());
    // headboard + footboard
    _top(c, _r(4, 10, 20, 82), 10, _woodDark);
    _rr(c, _r(9, 18, 10, 36), 4, _wood, line: false);
    _top(c, _r(180, 40, 14, 52), 7, _woodDark);
  }

  /// Upholstered adjustable bed: tufted headboard, raised backrest with two
  /// pillows and a quilted duvet.
  void _bedLuxury(Canvas c) {
    _shadow(c, 96, 96, 184);
    for (final x in [24.0, 166.0]) {
      _rr(c, _r(x, 84, 6, 12), 2, _brass);
    }
    _rr(c, _r(14, 64, 166, 22), 8, _shade(_fabricDeep, 0.25));
    // tufted headboard
    _top(c, _r(2, 0, 30, 90), 14, _fabric);
    final button = Paint()..color = _shade(_fabric, 0.3);
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 2; col++) {
        c.drawCircle(
          Offset(11.0 + col * 12 + (row.isOdd ? 6 : 0), 14.0 + row * 14),
          1.6,
          button,
        );
      }
    }
    // mattress with raised backrest
    _rr(c, _r(28, 52, 150, 16), 7, _sheet);
    final back = Path()
      ..moveTo(32, 58)
      ..lineTo(80, 58)
      ..lineTo(58, 26)
      ..quadraticBezierTo(50, 20, 42, 24)
      ..close();
    _path(c, back, _sheet);
    // pillows
    _rr(c, _r(36, 30, 28, 15), 7, Colors.white);
    _rr(c, _r(60, 38, 26, 13), 6, _tint(_accent, 0.55));
    // quilted duvet
    final duvet = RRect.fromRectAndRadius(
      _r(76, 46, 104, 36),
      const Radius.circular(9),
    );
    c.drawRRect(duvet, Paint()..color = _tint(_fabricDeep, 0.15));
    c.save();
    c.clipRRect(duvet);
    final quilt = _stroke(1, Colors.white.withValues(alpha: 0.35));
    for (var x = 60.0; x < 200; x += 12) {
      c.drawLine(Offset(x, 46), Offset(x + 36, 82), quilt);
      c.drawLine(Offset(x + 36, 46), Offset(x, 82), quilt);
    }
    c.restore();
    c.drawRRect(duvet, _stroke());
    _top(c, _r(176, 46, 14, 44), 7, _fabric);
  }

  /// Cot-style bed with a detachable guard rail of white slats.
  void _bedCot(Canvas c) {
    const rail = Color(0xFFF1E6D8);
    _shadow(c, 101, 96, 196);
    _rr(c, _r(14, 82, 8, 14), 2, _woodDark);
    _rr(c, _r(182, 82, 8, 14), 2, _woodDark);
    _rr(c, _r(8, 64, 188, 20), 5, rail);
    _rr(c, _r(14, 50, 176, 17), 8, _sheet);
    _rr(c, _r(22, 37, 38, 17), 8, Colors.white);
    _rr(c, _r(62, 46, 120, 26), 8, _tint(_accent, 0.35));
    for (var x = 74.0; x < 180; x += 14) {
      c.drawCircle(Offset(x, 58), 2.2, Paint()..color = _tint(_accent, 0.8));
    }
    // posts
    _top(c, _r(4, 8, 12, 84), 6, rail);
    _top(c, _r(188, 20, 12, 72), 6, rail);
    // removable guard rail on the front half
    _rr(c, _r(16, 22, 110, 6), 3, rail);
    for (var x = 24.0; x < 124; x += 11) {
      _rr(c, _r(x, 28, 4, 38), 2, rail);
    }
    c.drawCircle(const Offset(10, 8), 5, Paint()..color = _accent);
    c.drawCircle(const Offset(194, 20), 5, Paint()..color = _accent);
  }

  // -------------------------------------------------------------- media etc.

  /// Flat TV on a wooden media console.
  void _tvBasic(Canvas c) {
    _shadow(c, 80, 97, 150);
    _rr(c, _r(14, 92, 6, 6), 1, _woodDark);
    _rr(c, _r(139, 92, 6, 6), 1, _woodDark);
    _rr(c, _r(8, 66, 143, 28), 4, _wood);
    _rr(c, _r(8, 66, 143, 5), 2, _woodLight, line: false);
    for (final x in [55.0, 104.0]) {
      c.drawLine(Offset(x, 72), Offset(x, 92), _stroke(1.2));
    }
    for (final x in [31.5, 79.5, 127.5]) {
      _rr(c, _r(x - 6, 79, 12, 3), 1.5, _woodDark, line: false);
    }
    // stand
    _rr(c, _r(73, 56, 13, 10), 1, const Color(0xFF2A2D33), line: false);
    _rr(c, _r(56, 62, 47, 5), 2.5, const Color(0xFF2A2D33), line: false);
    // bezel + screen
    _rr(c, _r(16, 2, 127, 58), 5, const Color(0xFF202328));
    _nightScreen(c, _r(20, 6, 119, 48), 3);
    c.drawCircle(
      const Offset(133, 57),
      1.3,
      Paint()..color = const Color(0xFF63E6BE),
    );
  }

  /// Wall-mounted 65" TV with a soundbar on a floating shelf.
  void _tvWall(Canvas c) {
    _rr(c, _r(8, 6, 177, 70), 4, const Color(0x22000000), line: false);
    _rr(c, _r(5, 2, 177, 70), 4, const Color(0xFF17191D));
    _nightScreen(c, _r(8, 5, 171, 63), 2);
    c.drawCircle(
      const Offset(93.5, 70),
      1.2,
      Paint()..color = const Color(0xFF63E6BE),
    );
    _rr(c, _r(28, 90, 133, 6), 2, _woodLight);
    _rr(c, _r(52, 81, 85, 9), 4.5, const Color(0xFF2A2D33));
    final dot = Paint()..color = const Color(0xFF555A63);
    for (var x = 58.0; x < 134; x += 4) {
      c.drawCircle(Offset(x, 85.5), 0.9, dot);
    }
  }

  /// Rounded speaker with a fabric grille and sound waves.
  void _noiseMachine(Canvas c) {
    _shadow(c, 69.5, 96, 84);
    final waves = _stroke(2.2, _fabricDeep.withValues(alpha: 0.55));
    const centre = Offset(69.5, 58);
    for (final r in [44.0, 54.0]) {
      final rect = Rect.fromCircle(center: centre, radius: r);
      c.drawArc(rect, -0.45, 0.9, false, waves);
      c.drawArc(rect, math.pi - 0.45, 0.9, false, waves);
    }
    _rr(c, _r(30, 22, 79, 72), 30, _plastic);
    c.drawCircle(centre, 24, Paint()..color = const Color(0xFFD8D2CA));
    c.drawCircle(centre, 24, _stroke(1.2));
    final hole = Paint()..color = const Color(0xFF9E978E);
    for (var y = -18.0; y <= 18; y += 6) {
      for (var x = -18.0; x <= 18; x += 6) {
        if (x * x + y * y < 400) {
          c.drawCircle(centre.translate(x, y), 1.3, hole);
        }
      }
    }
    _rr(c, _r(57, 14, 25, 9), 4, _fabricDeep);
    c.drawCircle(const Offset(69.5, 88), 2, Paint()..color = _accent);
  }

  /// Tall air-purifier tower with vents and rising clean-air lines.
  void _purifier(Canvas c) {
    _shadow(c, 49, 96, 60);
    final air = _stroke(1.8, const Color(0xFF7CC6E8));
    for (final x in [38.0, 49.0, 60.0]) {
      final p = Path()
        ..moveTo(x, 15)
        ..quadraticBezierTo(x - 4, 10, x, 6)
        ..quadraticBezierTo(x + 4, 2, x, -2);
      c.drawPath(p, air);
    }
    _rr(c, _r(24, 18, 50, 78), 16, _plastic);
    _rr(c, _r(30, 22, 38, 9), 4, const Color(0xFFD9DCDF));
    for (var x = 34.0; x < 66; x += 4) {
      c.drawLine(
        Offset(x, 24),
        Offset(x, 29),
        _stroke(1, const Color(0xFF9AA0A6)),
      );
    }
    c.drawCircle(
      const Offset(49, 40),
      4.5,
      _stroke(1.8, const Color(0xFF2BB3A3)),
    );
    for (var x = 34.0; x <= 64; x += 7.5) {
      _rr(c, _r(x - 1.5, 52, 3, 34), 1.5, const Color(0xFFCDD1D5), line: false);
    }
  }

  // -------------------------------------------------------------------- desks

  /// Wooden study desk with a drawer unit, an open laptop, books and a mug.
  void _deskBasic(Canvas c) {
    _shadow(c, 92, 97, 176);
    _rr(c, _r(12, 52, 7, 45), 2, _woodDark);
    _rr(c, _r(118, 52, 58, 45), 3, _wood);
    _rr(c, _r(122, 56, 50, 18), 2, _woodLight);
    _rr(c, _r(122, 76, 50, 18), 2, _woodLight);
    _rr(c, _r(140, 63, 14, 3), 1.5, _woodDark, line: false);
    _rr(c, _r(140, 83, 14, 3), 1.5, _woodDark, line: false);
    _rr(c, _r(4, 44, 175, 9), 3, _wood);
    _rr(c, _r(4, 44, 175, 3), 1.5, _woodLight, line: false);
    // laptop
    _rr(c, _r(54, 10, 54, 32), 3, const Color(0xFF3A3F47));
    c.drawRect(
      _r(57, 13, 48, 26),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF9FD3F5), Color(0xFF5E8FD6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(_r(57, 13, 48, 26)),
    );
    for (var i = 0; i < 3; i++) {
      c.drawLine(
        Offset(62, 19.0 + i * 6),
        Offset(62.0 + 30 - i * 8, 19.0 + i * 6),
        _stroke(1.6, Colors.white.withValues(alpha: 0.7)),
      );
    }
    _rr(c, _r(48, 41, 66, 4), 2, const Color(0xFFB8BEC6));
    // books
    _rr(c, _r(14, 38, 30, 6), 1.5, _fabricDeep);
    _rr(c, _r(17, 32, 26, 6), 1.5, _accent);
    _rr(c, _r(15, 26, 28, 6), 1.5, scheme.secondary);
    // mug + pencil cup
    _rr(c, _r(124, 31, 12, 13), 2.5, _tint(_accent, 0.2));
    c.drawArc(_r(132, 34, 8, 7), -math.pi / 2, math.pi, false, _stroke(1.8));
    for (final dx in [-3.0, 0.0, 3.5]) {
      c.drawLine(
        Offset(158 + dx, 32),
        Offset(158 + dx * 1.6, 22),
        _stroke(1.6, dx == 0 ? const Color(0xFFE8A33D) : _fabricDeep),
      );
    }
    _rr(c, _r(151, 30, 14, 14), 2.5, const Color(0xFF8B9199));
  }

  /// Light-wood workstation with two monitors, keyboard and a succulent.
  void _deskDual(Canvas c) {
    const top = Color(0xFFE6D5BC);
    _shadow(c, 103, 97, 198);
    final leg = _stroke(4, _metal);
    c.drawLine(const Offset(18, 56), const Offset(12, 96), leg);
    c.drawLine(const Offset(18, 56), const Offset(26, 96), leg);
    c.drawLine(const Offset(189, 56), const Offset(183, 96), leg);
    c.drawLine(const Offset(189, 56), const Offset(197, 96), leg);
    _rr(c, _r(4, 50, 199, 7), 3, top);
    for (final x in [30.0, 110.0]) {
      _rr(c, _r(x + 27, 40, 8, 10), 1, _metal, line: false);
      _rr(c, _r(x + 17, 47, 28, 4), 2, _metal, line: false);
      _rr(c, _r(x, 4, 62, 38), 3, const Color(0xFF202328));
      c.drawRect(
        _r(x + 3, 7, 56, 32),
        Paint()..color = const Color(0xFF1E2B44),
      );
    }
    // left screen: code
    final code = [_accent, _fabric, const Color(0xFF8FD3B6), _fabric];
    for (var i = 0; i < 4; i++) {
      c.drawLine(
        Offset(37, 13.0 + i * 6),
        Offset(37.0 + 18 + (i * 13) % 26, 13.0 + i * 6),
        _stroke(2, code[i]),
      );
    }
    // right screen: sleep chart
    final bar = Paint()..color = _tint(_fabricDeep, 0.35);
    final hs = [10.0, 16.0, 13.0, 20.0, 17.0, 22.0];
    for (var i = 0; i < hs.length; i++) {
      c.drawRect(_r(118.0 + i * 8, 36 - hs[i], 5, hs[i]), bar);
    }
    _rr(c, _r(76, 44, 50, 5), 2, const Color(0xFFDADDE1));
    c.drawOval(_r(134, 44, 7, 5), Paint()..color = const Color(0xFFDADDE1));
    // succulent
    _rr(c, _r(180, 38, 14, 12), 2, const Color(0xFFC9774A));
    for (final a in [-0.7, 0.0, 0.7]) {
      c.save();
      c.translate(187, 38);
      c.rotate(a);
      c.drawOval(
        _r(-2.5, -11, 5, 11),
        Paint()..color = const Color(0xFF6BAA5E),
      );
      c.restore();
    }
  }

  // --------------------------------------------------------------------- door

  void _door(Canvas c) {
    const trim = Color(0xFFEADBC6);
    _top(c, _r(0, 0, 58, 100), 4, trim);
    _rr(c, _r(5, 5, 48, 95), 2, _wood);
    final panel = Paint()..color = _shade(_wood, 0.18);
    for (final r in [
      _r(10, 10, 17, 36),
      _r(31, 10, 17, 36),
      _r(10, 52, 17, 40),
      _r(31, 52, 17, 40),
    ]) {
      c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(2)), panel);
      c.drawLine(
        r.topLeft.translate(1, 1),
        r.topRight.translate(-1, 1),
        _stroke(1, _woodLight),
      );
    }
    _rr(c, _r(5, 16, 3, 7), 1, _brass, line: false);
    _rr(c, _r(5, 80, 3, 7), 1, _brass, line: false);
    _rr(c, _r(41, 46, 5, 13), 2, _brass);
    c.drawCircle(const Offset(43.5, 50), 3.2, Paint()..color = _brass);
    c.drawCircle(const Offset(43.5, 50), 3.2, _stroke(1));
    // little welcome light above the door
    _glow(c, const Offset(29, 3), 10, const Color(0xFFFFD27A), 0.6);
  }

  // ------------------------------------------------------------------- lights

  /// Floor lamp with a fabric drum shade and a warm glow.
  void _floorLamp(Canvas c) {
    _glow(c, const Offset(35.5, 24), 36, const Color(0xFFFFC56B), 0.55);
    _shadow(c, 35.5, 97, 36);
    c.drawOval(_r(21, 91, 29, 7), Paint()..color = _metal);
    _rr(c, _r(34, 30, 3.5, 63), 1.5, _metal, line: false);
    final shade = Path()
      ..moveTo(14, 36)
      ..lineTo(57, 36)
      ..lineTo(49, 8)
      ..lineTo(22, 8)
      ..close();
    _path(c, shade, const Color(0xFFF6E1B0));
    c.drawLine(
      const Offset(15, 33),
      const Offset(56, 33),
      _stroke(2.5, _accent),
    );
    final cone = Path()
      ..moveTo(16, 36)
      ..lineTo(55, 36)
      ..lineTo(64, 58)
      ..lineTo(7, 58)
      ..close();
    c.drawPath(cone, Paint()..color = const Color(0x33FFD27A));
  }

  /// Bedside table carrying an amber mushroom lamp.
  void _amberLamp(Canvas c) {
    _shadow(c, 43, 97, 70);
    _rr(c, _r(16, 90, 5, 8), 1, _woodDark);
    _rr(c, _r(64, 90, 5, 8), 1, _woodDark);
    _rr(c, _r(12, 58, 61, 34), 3, _wood);
    _rr(c, _r(17, 64, 51, 16), 2, _woodLight);
    c.drawCircle(const Offset(42.5, 72), 2.2, Paint()..color = _brass);
    _rr(c, _r(9, 54, 67, 6), 2, _woodDark);
    // book on the table
    _rr(c, _r(54, 48, 18, 6), 1.5, _fabricDeep);
    // lamp
    _glow(c, const Offset(32, 30), 34, const Color(0xFFFFB347), 0.6);
    _rr(c, _r(22, 47, 20, 7), 3, _woodDark);
    _rr(c, _r(30, 30, 4, 18), 1, const Color(0xFFE9D8BF));
    final dome = Path()
      ..moveTo(12, 32)
      ..arcTo(
        Rect.fromCircle(center: const Offset(32, 32), radius: 20),
        math.pi,
        math.pi,
        false,
      )
      ..close();
    c.drawPath(
      dome,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFCC80), Color(0xFFE0861A)],
        ).createShader(_r(12, 12, 40, 20)),
    );
    c.drawPath(dome, _stroke());
  }

  // ---------------------------------------------------------- plants & soft

  /// Boston fern: arching fronds with leaflets over a terracotta pot.
  void _fern(Canvas c) {
    _shadow(c, 42.5, 97, 42);
    const base = Offset(42.5, 62);
    const fronds = [
      (Offset(4, 56), Offset(14, 30)),
      (Offset(10, 22), Offset(26, 26)),
      (Offset(30, 2), Offset(38, 26)),
      (Offset(56, 4), Offset(48, 26)),
      (Offset(76, 22), Offset(60, 26)),
      (Offset(82, 56), Offset(72, 30)),
      (Offset(22, 44), Offset(30, 40)),
      (Offset(64, 44), Offset(56, 40)),
    ];
    for (var i = 0; i < fronds.length; i++) {
      final (tip, ctrl) = fronds[i];
      final stem = i.isEven ? const Color(0xFF3E7340) : const Color(0xFF4E8A4A);
      final leaf = _stroke(
        3.2,
        i.isEven ? const Color(0xFF5E9E52) : const Color(0xFF73B565),
      );
      Offset at(double t) => Offset(
        (1 - t) * (1 - t) * base.dx +
            2 * (1 - t) * t * ctrl.dx +
            t * t * tip.dx,
        (1 - t) * (1 - t) * base.dy +
            2 * (1 - t) * t * ctrl.dy +
            t * t * tip.dy,
      );
      for (var t = 0.25; t < 0.98; t += 0.09) {
        final p = at(t);
        final d = at(math.min(1, t + 0.02)) - p;
        final n = Offset(-d.dy, d.dx) / (d.distance == 0 ? 1 : d.distance);
        final len = 7 * (1.1 - t);
        c.drawLine(p - n * len, p + n * len, leaf);
      }
      final path = Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy);
      c.drawPath(path, _stroke(1.6, stem));
    }
    final pot = Path()
      ..moveTo(24, 64)
      ..lineTo(61, 64)
      ..lineTo(56, 96)
      ..lineTo(29, 96)
      ..close();
    _path(c, pot, const Color(0xFFC9774A));
    _rr(c, _r(20, 58, 45, 9), 3, const Color(0xFFB0623A));
  }

  /// Wool rug seen in perspective, with a border, medallion and fringe.
  void _rug(Canvas c) {
    const shape = [
      Offset(28, 12),
      Offset(151, 12),
      Offset(170, 88),
      Offset(9, 88),
    ];
    final fringe = _stroke(1.4, _tint(_fabric, 0.4));
    for (var t = 0.06; t < 0.96; t += 0.08) {
      final l = Offset.lerp(shape[0], shape[3], t)!;
      final r = Offset.lerp(shape[1], shape[2], t)!;
      c.drawLine(l, l.translate(-6, 0), fringe);
      c.drawLine(r, r.translate(6, 0), fringe);
    }
    _path(c, Path()..addPolygon(shape, true), _fabric);
    final inner = [
      const Offset(36, 20),
      const Offset(143, 20),
      const Offset(158, 80),
      const Offset(21, 80),
    ];
    c.drawPath(
      Path()..addPolygon(inner, true),
      _stroke(3, _fabricDeep.withValues(alpha: 0.55)),
    );
    final medallion = Path()
      ..moveTo(89.5, 30)
      ..lineTo(122, 50)
      ..lineTo(89.5, 70)
      ..lineTo(57, 50)
      ..close();
    c.drawPath(medallion, Paint()..color = _accent.withValues(alpha: 0.45));
    c.drawCircle(
      const Offset(89.5, 50),
      7,
      Paint()..color = _tint(_accent, 0.5),
    );
  }

  // -------------------------------------------------------------- wall items

  /// Night window framed by heavy blackout curtains on a rod.
  void _curtains(Canvas c) {
    _rr(c, _r(16, 12, 90, 80), 4, const Color(0xFFF4EEE6));
    _nightScreen(c, _r(21, 17, 80, 70), 2);
    c.drawLine(
      const Offset(61, 17),
      const Offset(61, 87),
      _stroke(3, const Color(0xFFF4EEE6)),
    );
    c.drawLine(
      const Offset(21, 52),
      const Offset(101, 52),
      _stroke(3, const Color(0xFFF4EEE6)),
    );
    final cloth = _shade(_fabricDeep, 0.25);
    final fold = _stroke(1.4, _shade(cloth, 0.3));
    for (final mirror in [false, true]) {
      c.save();
      if (mirror) {
        c.translate(122, 0);
        c.scale(-1, 1);
      }
      final panel = Path()
        ..moveTo(6, 8)
        ..lineTo(46, 8)
        ..quadraticBezierTo(34, 40, 30, 60)
        ..quadraticBezierTo(36, 80, 42, 98)
        ..lineTo(6, 98)
        ..close();
      _path(c, panel, cloth);
      for (final x in [14.0, 22.0]) {
        c.drawLine(Offset(x, 12), Offset(x, 96), fold);
      }
      _rr(c, _r(20, 57, 16, 6), 3, _brass);
      c.restore();
    }
    _rr(c, _r(2, 4, 118, 5), 2.5, _woodDark);
    c.drawCircle(const Offset(3, 6.5), 4, Paint()..color = _woodDark);
    c.drawCircle(const Offset(119, 6.5), 4, Paint()..color = _woodDark);
  }

  /// Low bookcase with three shelves of books and a little plant.
  void _bookshelf(Canvas c) {
    _shadow(c, 43, 97, 82);
    _rr(c, _r(4, 4, 78, 93), 3, _woodDark);
    c.drawRect(_r(9, 9, 68, 82), Paint()..color = const Color(0xFF8C5F42));
    final palette = [
      _fabricDeep,
      _accent,
      scheme.secondary,
      const Color(0xFFE3B04B),
      const Color(0xFF7FA37A),
      const Color(0xFFD9806B),
      const Color(0xFF6C8EBF),
    ];
    const shelves = [9.0, 37.0, 65.0];
    const layouts = [
      [7.0, 6.0, 8.0, 5.0, 7.0],
      [6.0, 8.0, 5.0, 7.0, 6.0, 8.0],
      [8.0, 6.0, 7.0, 6.0],
    ];
    for (var s = 0; s < shelves.length; s++) {
      final floor = shelves[s] + 26;
      var x = 11.0;
      for (var b = 0; b < layouts[s].length; b++) {
        final w = layouts[s][b];
        final h = 17.0 + ((s * 3 + b * 5) % 7);
        final col = palette[(s * 2 + b) % palette.length];
        _rr(c, _r(x, floor - h, w, h), 1, col);
        c.drawLine(
          Offset(x + 1.5, floor - h + 4),
          Offset(x + w - 1.5, floor - h + 4),
          _stroke(1, Colors.white.withValues(alpha: 0.6)),
        );
        x += w + 0.8;
      }
      if (s == 0) {
        _rr(c, _r(62, floor - 9, 11, 9), 2, const Color(0xFFC9774A));
        for (final a in [-0.6, 0.0, 0.6]) {
          c.save();
          c.translate(67.5, floor - 9);
          c.rotate(a);
          c.drawOval(
            _r(-2.5, -10, 5, 10),
            Paint()..color = const Color(0xFF5E9E52),
          );
          c.restore();
        }
      } else if (s == 1) {
        c.save();
        c.translate(64, floor);
        c.rotate(0.3);
        _rr(c, _r(0, -20, 7, 20), 1, palette[5]);
        c.restore();
      } else {
        _rr(c, _r(52, floor - 12, 22, 12), 2, _tint(_accent, 0.5));
      }
      _rr(c, _r(6, floor, 74, 3.5), 1, _wood);
    }
  }

  /// Framed print: moonlit mountains over still water.
  void _poster(Canvas c) {
    c.drawPath(
      Path()
        ..moveTo(38, 8)
        ..lineTo(68.5, 0)
        ..lineTo(99, 8),
      _stroke(1.2),
    );
    _rr(c, _r(6, 6, 125, 88), 3, _woodDark);
    c.drawRect(_r(12, 12, 113, 76), Paint()..color = const Color(0xFFFAF6EF));
    final art = _r(21, 20, 95, 60);
    c.save();
    c.clipRect(art);
    c.drawRect(
      art,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scheme.tertiaryContainer, scheme.primaryContainer],
        ).createShader(art),
    );
    c.drawCircle(
      const Offset(88, 36),
      8,
      Paint()..color = const Color(0xFFFFF3C4),
    );
    final far = Path()
      ..moveTo(21, 64)
      ..lineTo(44, 38)
      ..lineTo(60, 54)
      ..lineTo(76, 34)
      ..lineTo(116, 64)
      ..close();
    c.drawPath(far, Paint()..color = _tint(_fabricDeep, 0.35));
    final near = Path()
      ..moveTo(21, 66)
      ..lineTo(36, 52)
      ..lineTo(52, 66)
      ..close();
    c.drawPath(near, Paint()..color = _fabricDeep);
    c.drawRect(_r(21, 66, 95, 14), Paint()..color = _tint(_fabricDeep, 0.6));
    for (final y in [70.0, 75.0]) {
      c.drawLine(
        Offset(50, y),
        Offset(90, y),
        _stroke(1, Colors.white.withValues(alpha: 0.7)),
      );
    }
    c.restore();
    c.drawRect(art, _stroke(1));
  }

  // ------------------------------------------------------------------- seats

  /// Upholstered armchair seen from the front, with a throw cushion.
  void _armchair(Canvas c) {
    _shadow(c, 55.5, 97, 100);
    _rr(c, _r(18, 86, 6, 11), 2, _woodDark);
    _rr(c, _r(87, 86, 6, 11), 2, _woodDark);
    _top(c, _r(18, 6, 75, 60), 24, _fabricDeep);
    _top(c, _r(25, 13, 61, 48), 18, _tint(_fabricDeep, 0.18), line: false);
    _rr(c, _r(18, 70, 75, 18), 4, _shade(_fabricDeep, 0.15));
    _rr(c, _r(20, 56, 71, 18), 8, _tint(_fabricDeep, 0.3));
    _rr(c, _r(37, 36, 37, 22), 9, _tint(_accent, 0.25));
    c.drawLine(
      const Offset(55.5, 39),
      const Offset(55.5, 55),
      _stroke(1, Colors.white.withValues(alpha: 0.45)),
    );
    _rr(c, _r(4, 38, 22, 52), 10, _fabricDeep);
    _rr(c, _r(85, 38, 22, 52), 10, _fabricDeep);
    _rr(c, _r(6, 40, 18, 8), 4, _tint(_fabricDeep, 0.25), line: false);
    _rr(c, _r(87, 40, 18, 8), 4, _tint(_fabricDeep, 0.25), line: false);
  }

  /// Squashy beanbag with a sat-in dent and seams.
  void _beanbag(Canvas c) {
    _shadow(c, 67, 95, 120);
    final body = Path()
      ..moveTo(12, 84)
      ..cubicTo(4, 62, 22, 42, 40, 36)
      ..cubicTo(54, 10, 96, 8, 108, 30)
      ..cubicTo(126, 42, 132, 70, 124, 86)
      ..cubicTo(108, 98, 30, 100, 12, 84)
      ..close();
    final bounds = body.getBounds();
    c.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_tint(_accent, 0.35), _shade(_accent, 0.15)],
        ).createShader(bounds),
    );
    c.drawPath(body, _stroke());
    c.drawOval(
      _r(42, 52, 58, 22),
      Paint()..color = _shade(_accent, 0.25).withValues(alpha: 0.45),
    );
    final seam = _stroke(1.2, _shade(_accent, 0.35).withValues(alpha: 0.6));
    c.drawPath(
      Path()
        ..moveTo(40, 36)
        ..quadraticBezierTo(46, 64, 30, 92),
      seam,
    );
    c.drawPath(
      Path()
        ..moveTo(106, 30)
        ..quadraticBezierTo(100, 62, 110, 92),
      seam,
    );
    c.drawOval(
      _r(56, 18, 26, 10),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
  }

  @override
  bool shouldRepaint(FurniturePainter old) =>
      old.defId != defId || old.category != category || old.scheme != scheme;
}
