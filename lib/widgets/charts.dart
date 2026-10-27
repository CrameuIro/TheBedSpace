import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models.dart';

/// ---------------------------------------------------------------------------
/// Hand-drawn charts (no chart package, so the styling stays fully on-theme).
/// ---------------------------------------------------------------------------

void _label(
  Canvas canvas,
  String text,
  Offset at,
  TextStyle style, {
  TextAlign align = TextAlign.left,
}) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textAlign: align,
  )..layout();
  final dx = switch (align) {
    TextAlign.center => at.dx - tp.width / 2,
    TextAlign.right => at.dx - tp.width,
    _ => at.dx,
  };
  tp.paint(canvas, Offset(dx, at.dy));
}

/// Duration per night as bars, with the goal drawn as a dashed line.
class SleepBarChart extends StatelessWidget {
  const SleepBarChart({
    super.key,
    required this.entries,
    required this.goalHours,
    this.height = 190,
    this.dayLabels = const [],
  });

  final List<SleepEntry> entries;
  final double goalHours;
  final double height;
  final List<String> dayLabels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _BarPainter(
          entries: entries,
          goal: goalHours,
          bar: scheme.primary,
          barMissed: scheme.errorContainer,
          goalColor: scheme.tertiary,
          axis: scheme.onSurfaceVariant,
          labels: dayLabels,
          textStyle: Theme.of(context).textTheme.labelSmall!
              .copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.entries,
    required this.goal,
    required this.bar,
    required this.barMissed,
    required this.goalColor,
    required this.axis,
    required this.labels,
    required this.textStyle,
  });

  final List<SleepEntry> entries;
  final double goal;
  final Color bar;
  final Color barMissed;
  final Color goalColor;
  final Color axis;
  final List<String> labels;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size s) {
    if (entries.isEmpty) return;
    const padL = 30.0, padB = 22.0, padT = 12.0;
    final plotH = s.height - padB - padT;
    final plotW = s.width - padL;
    final maxH = math.max(
      10.0,
      math.max(goal, entries.map((e) => e.durationHours).reduce(math.max)) + 1,
    );

    // horizontal grid lines every 2 hours
    final grid = Paint()
      ..color = axis.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (var h = 0; h <= maxH.ceil(); h += 2) {
      final y = padT + plotH - (h / maxH) * plotH;
      canvas.drawLine(Offset(padL, y), Offset(s.width, y), grid);
      _label(canvas, '${h}h', Offset(0, y - 7), textStyle);
    }

    // goal line
    final gy = padT + plotH - (goal / maxH) * plotH;
    final dash = Paint()
      ..color = goalColor
      ..strokeWidth = 2;
    for (var x = padL; x < s.width; x += 10) {
      canvas.drawLine(
        Offset(x, gy),
        Offset(math.min(x + 6, s.width), gy),
        dash,
      );
    }

    final n = entries.length;
    final slot = plotW / n;
    final bw = math.min(slot * 0.62, 26.0);
    for (var i = 0; i < n; i++) {
      final e = entries[i];
      final cx = padL + slot * (i + 0.5);
      final bh = (e.durationHours / maxH) * plotH;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - bw / 2, padT + plotH - bh, bw, bh),
        const Radius.circular(8),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = e.durationHours >= goal ? bar : barMissed,
      );
      if (i < labels.length && slot > 16) {
        _label(
          canvas,
          labels[i],
          Offset(cx, padT + plotH + 6),
          textStyle,
          align: TextAlign.center,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.entries != entries || old.goal != goal;
}

/// Bedtime (minutes past 18:00) per night — shows the "drift" late in the week.
class BedtimeDriftChart extends StatelessWidget {
  const BedtimeDriftChart({
    super.key,
    required this.entries,
    required this.goalSlot,
    this.height = 180,
  });

  final List<SleepEntry> entries;
  final int goalSlot;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _LinePainter(
          entries: entries,
          goalSlot: goalSlot,
          line: scheme.primary,
          goal: scheme.tertiary,
          axis: scheme.onSurfaceVariant,
          textStyle: Theme.of(context).textTheme.labelSmall!
              .copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.entries,
    required this.goalSlot,
    required this.line,
    required this.goal,
    required this.axis,
    required this.textStyle,
  });

  final List<SleepEntry> entries;
  final int goalSlot;
  final Color line;
  final Color goal;
  final Color axis;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size s) {
    if (entries.length < 2) return;
    const padL = 44.0, padB = 18.0, padT = 12.0;
    final plotH = s.height - padB - padT;
    final plotW = s.width - padL;

    final slots = entries.map((e) => e.bedSlotMinutes.toDouble()).toList();
    final lo = math.min(slots.reduce(math.min), goalSlot.toDouble()) - 30;
    final hi = math.max(slots.reduce(math.max), goalSlot.toDouble()) + 30;
    final range = math.max(60.0, hi - lo);

    double yFor(double slot) => padT + plotH - ((slot - lo) / range) * plotH;
    double xFor(int i) => padL + plotW * (i / (entries.length - 1));

    // goal line
    final gy = yFor(goalSlot.toDouble());
    canvas.drawLine(
      Offset(padL, gy),
      Offset(s.width, gy),
      Paint()
        ..color = goal
        ..strokeWidth = 2,
    );
    _label(canvas, Util.clockFrom18(goalSlot), Offset(0, gy - 7), textStyle);

    // axis marks: later bedtimes are drawn higher, so the latest time labels
    // the top and the earliest the bottom. A mark that would sit on top of
    // the goal label is skipped.
    final topY = padT - 2;
    final bottomY = padT + plotH - 12;
    if ((topY - (gy - 7)).abs() > 14) {
      _label(
        canvas,
        Util.clockFrom18((lo + range).round()),
        Offset(0, topY),
        textStyle,
      );
    }
    if ((bottomY - (gy - 7)).abs() > 14) {
      _label(
        canvas,
        Util.clockFrom18(lo.round()),
        Offset(0, bottomY),
        textStyle,
      );
    }

    // line
    final path = Path()..moveTo(xFor(0), yFor(slots[0]));
    for (var i = 1; i < entries.length; i++) {
      path.lineTo(xFor(i), yFor(slots[i]));
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = line,
    );
    for (var i = 0; i < entries.length; i++) {
      canvas.drawCircle(
        Offset(xFor(i), yFor(slots[i])),
        4,
        Paint()..color = line,
      );
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.entries != entries;
}

/// Scatter of room score (x) against logged hours (y) — the correlation view.
class CorrelationScatter extends StatelessWidget {
  const CorrelationScatter({
    super.key,
    required this.entries,
    this.height = 190,
  });

  final List<SleepEntry> entries;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _ScatterPainter(
          entries: entries,
          dot: scheme.primary,
          axis: scheme.onSurfaceVariant,
          textStyle: Theme.of(context).textTheme.labelSmall!
              .copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _ScatterPainter extends CustomPainter {
  _ScatterPainter({
    required this.entries,
    required this.dot,
    required this.axis,
    required this.textStyle,
  });

  final List<SleepEntry> entries;
  final Color dot;
  final Color axis;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size s) {
    if (entries.isEmpty) return;
    const padL = 34.0, padB = 22.0, padT = 12.0;
    final plotH = s.height - padB - padT;
    final plotW = s.width - padL;

    final xs = entries.map((e) => e.roomScoreAtLog.toDouble()).toList();
    final ys = entries.map((e) => e.durationHours).toList();
    var minX = xs.reduce(math.min), maxX = xs.reduce(math.max);
    if (maxX - minX < 1) {
      minX -= 1;
      maxX += 1;
    }
    final minY = math.max(0.0, ys.reduce(math.min) - 1);
    final maxY = ys.reduce(math.max) + 1;

    final grid = Paint()
      ..color = axis.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = padT + plotH * i / 4;
      canvas.drawLine(Offset(padL, y), Offset(s.width, y), grid);
    }

    for (var i = 0; i < entries.length; i++) {
      final x = padL + ((xs[i] - minX) / (maxX - minX)) * plotW;
      final y = padT + plotH - ((ys[i] - minY) / (maxY - minY)) * plotH;
      canvas.drawCircle(
        Offset(x, y),
        6,
        Paint()..color = dot.withValues(alpha: 0.75),
      );
    }

    _label(canvas, 'room score', Offset(padL, padT + plotH + 4), textStyle);
    _label(canvas, '${maxY.round()}h', Offset(0, padT - 2), textStyle);
    _label(canvas, '${minY.round()}h', Offset(0, padT + plotH - 12), textStyle);
  }

  @override
  bool shouldRepaint(_ScatterPainter old) => old.entries != entries;
}
