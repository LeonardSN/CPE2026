import 'dart:math';

import 'package:flutter/material.dart';

import '../curriculum/cycle.dart';
import '../theme.dart';

/// Droite graduée : l'élève touche (ou glisse) pour placer son point.
class NumberLineInput extends StatelessWidget {
  final GraphSpec spec;
  final int? selected;
  final ValueChanged<int>? onSelect;

  /// Après la correction : on montre la bonne graduation en vert.
  final bool showCorrect;

  const NumberLineInput({
    super.key,
    required this.spec,
    required this.selected,
    required this.onSelect,
    this.showCorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    final line = context.isDark ? Colors.white70 : Brand.ink;
    final accent = context.colors.primary;
    return LayoutBuilder(builder: (context, c) {
      const pad = 22.0;
      final w = c.maxWidth;
      final step = (w - 2 * pad) / spec.divisions;
      double xOf(int tick) => pad + tick * step;
      int tickAt(double dx) => ((dx - pad) / step).round().clamp(0, spec.divisions);

      void handle(Offset p) {
        if (onSelect != null) onSelect!(tickAt(p.dx));
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => handle(d.localPosition),
        onHorizontalDragUpdate: (d) => handle(d.localPosition),
        child: SizedBox(
          height: 120,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _LinePainter(spec.divisions, pad, line),
                ),
              ),
              for (final e in spec.labels.entries)
                Positioned(
                  left: xOf(e.key) - 30,
                  width: 60,
                  top: 74,
                  child: Text(
                    e.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: line),
                  ),
                ),
              if (showCorrect) _pin(xOf(spec.targetTick), AppColors.green, '✓'),
              if (selected != null && !(showCorrect && selected == spec.targetTick))
                _pin(xOf(selected!), showCorrect ? AppColors.red : accent, ''),
            ],
          ),
        ),
      );
    });
  }

  Widget _pin(double x, Color color, String mark) {
    return Positioned(
      left: x - 16,
      top: 6,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Text(mark, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
          Container(width: 3, height: 14, color: color),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final int divisions;
  final double pad;
  final Color color;

  _LinePainter(this.divisions, this.pad, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final y = 60.0;
    final p = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(pad - 10, y), Offset(size.width - pad + 10, y), p);
    // flèche
    canvas.drawLine(Offset(size.width - pad + 10, y), Offset(size.width - pad + 2, y - 6), p);
    canvas.drawLine(Offset(size.width - pad + 10, y), Offset(size.width - pad + 2, y + 6), p);
    final step = (size.width - 2 * pad) / divisions;
    final thin = Paint()
      ..color = color
      ..strokeWidth = 2;
    for (var i = 0; i <= divisions; i++) {
      final big = i == 0 || i == divisions || (divisions % 2 == 0 && i == divisions ~/ 2);
      final h = big ? 12.0 : 7.0;
      canvas.drawLine(Offset(pad + i * step, y - h), Offset(pad + i * step, y + h), thin);
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.divisions != divisions || old.color != color;
}

/// Repère cartésien : l'élève touche une intersection pour placer son point.
class GridInput extends StatelessWidget {
  final GraphSpec spec;
  final Point<int>? selected;
  final ValueChanged<Point<int>>? onSelect;
  final bool showCorrect;

  const GridInput({
    super.key,
    required this.spec,
    required this.selected,
    required this.onSelect,
    this.showCorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    final ink = context.isDark ? Colors.white : Brand.ink;
    final accent = context.colors.primary;
    return LayoutBuilder(builder: (context, c) {
      final size = min(c.maxWidth, 340.0);
      final n = spec.range * 2;
      final cell = size / (n + 1);
      Offset pos(int x, int y) =>
          Offset(cell * (x + spec.range + 0.5), cell * (spec.range - y + 0.5));
      Point<int> pointAt(Offset p) => Point(
            ((p.dx / cell) - 0.5 - spec.range).round().clamp(-spec.range, spec.range),
            (spec.range - ((p.dy / cell) - 0.5)).round().clamp(-spec.range, spec.range),
          );

      return Center(
        child: GestureDetector(
          onTapDown: (d) {
            if (onSelect != null) onSelect!(pointAt(d.localPosition));
          },
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _GridPainter(spec.range, cell, ink)),
                ),
                if (showCorrect) _dot(pos(spec.x, spec.y), AppColors.green, cell),
                if (selected != null &&
                    !(showCorrect && selected!.x == spec.x && selected!.y == spec.y))
                  _dot(pos(selected!.x, selected!.y), showCorrect ? AppColors.red : accent, cell),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _dot(Offset o, Color color, double cell) {
    final r = max(9.0, cell * 0.32);
    return Positioned(
      left: o.dx - r,
      top: o.dy - r,
      child: Container(
        width: 2 * r,
        height: 2 * r,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final int range;
  final double cell;
  final Color ink;

  _GridPainter(this.range, this.cell, this.ink);

  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()
      ..color = ink.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    final axis = Paint()
      ..color = ink
      ..strokeWidth = 2.2;
    for (var i = -range; i <= range; i++) {
      final x = cell * (i + range + 0.5);
      final y = cell * (range - i + 0.5);
      canvas.drawLine(Offset(x, cell * 0.5), Offset(x, size.height - cell * 0.5), light);
      canvas.drawLine(Offset(cell * 0.5, y), Offset(size.width - cell * 0.5, y), light);
    }
    final o = cell * (range + 0.5);
    canvas.drawLine(Offset(cell * 0.2, o), Offset(size.width - cell * 0.2, o), axis);
    canvas.drawLine(Offset(o, cell * 0.2), Offset(o, size.height - cell * 0.2), axis);
    // graduations numérotées
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = -range; i <= range; i++) {
      if (i == 0) continue;
      final style = TextStyle(color: ink.withValues(alpha: 0.7), fontSize: max(9.0, cell * 0.32));
      tp.text = TextSpan(text: '$i', style: style);
      tp.layout();
      final x = cell * (i + range + 0.5);
      tp.paint(canvas, Offset(x - tp.width / 2, o + 3));
      final y = cell * (range - i + 0.5);
      tp.paint(canvas, Offset(o + 4, y - tp.height / 2));
    }
    tp.text = TextSpan(text: '0', style: TextStyle(color: ink, fontSize: max(9.0, cell * 0.32)));
    tp.layout();
    tp.paint(canvas, Offset(o + 3, o + 2));
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.range != range || old.cell != cell || old.ink != ink;
}
