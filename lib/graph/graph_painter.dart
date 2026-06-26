import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/tokens.dart';

/// Paints graph edges: faint straight connectors for the ambient graph, plus
/// the highlighted causal path as a glowing polyline with a marching dash
/// overlay (design: "Causal-path glow").
class EdgePainter extends CustomPainter {
  final Map<String, Offset> positions; // normalized 0..1
  final List<GraphEdge> edges;
  final List<GraphNode> litPath; // ordered nodes forming the lit polyline
  final double dashPhase;

  EdgePainter({
    required this.positions,
    required this.edges,
    required this.litPath,
    required this.dashPhase,
  });

  Offset _p(String id, Size size) {
    final n = positions[id] ?? const Offset(0.5, 0.5);
    return Offset(n.dx * size.width, n.dy * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1) ambient / dim edges
    final dim = Paint()
      ..color = NexusColors.borderStrong.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (final e in edges.where((e) => !e.lit)) {
      if (!positions.containsKey(e.from) || !positions.containsKey(e.to)) continue;
      canvas.drawLine(_p(e.from, size), _p(e.to, size), dim);
    }

    if (litPath.length < 2) return;

    // 2) build the connected causal polyline
    final path = Path()..moveTo(_p(litPath.first.id, size).dx, _p(litPath.first.id, size).dy);
    for (var i = 1; i < litPath.length; i++) {
      final pt = _p(litPath[i].id, size);
      path.lineTo(pt.dx, pt.dy);
    }

    // glow underlay
    final glow = Paint()
      ..color = NexusColors.causal.withValues(alpha: 0.9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glow);

    final solid = Paint()
      ..color = NexusColors.causal.withValues(alpha: 0.9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, solid);

    // 3) marching bright dashes on top
    final dashPaint = Paint()
      ..color = NexusColors.causalBright
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _drawDashed(canvas, path, dashPaint, dash: 6, gap: 10, phase: dashPhase);
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint,
      {required double dash, required double gap, required double phase}) {
    for (final metric in path.computeMetrics()) {
      double dist = -(phase % (dash + gap));
      while (dist < metric.length) {
        final start = dist.clamp(0.0, metric.length);
        final end = (dist + dash).clamp(0.0, metric.length);
        if (end > 0) {
          canvas.drawPath(metric.extractPath(start, end), paint);
        }
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant EdgePainter old) => old.dashPhase != dashPhase;
}
