import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/graph_node.dart';
import 'graph_painter.dart';

/// Renders a composed knowledge graph: ambient dim nodes + a glowing,
/// animated causal path. Positions are normalized (0..1) so the same data
/// reads identically at any canvas size — matching the design composition
/// rather than relying on a force layout.
class KnowledgeGraphView extends StatefulWidget {
  final List<GraphNode> nodes; // all nodes (lit + dim)
  final List<GraphEdge> edges;
  final List<GraphNode> litPath; // ordered lit nodes
  final void Function(GraphNode)? onTapNode;
  final int revealCount; // how many lit nodes are revealed (for live build)

  const KnowledgeGraphView({
    super.key,
    required this.nodes,
    required this.edges,
    required this.litPath,
    this.onTapNode,
    this.revealCount = 999,
  });

  @override
  State<KnowledgeGraphView> createState() => _KnowledgeGraphViewState();
}

class _KnowledgeGraphViewState extends State<KnowledgeGraphView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dash = AnimationController(
      vsync: this, duration: const Duration(seconds: 4))
    ..repeat();

  @override
  void dispose() {
    _dash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final positions = {for (final n in widget.nodes) n.id: n.pos};
    final litVisible = widget.litPath.take(widget.revealCount).toList();

    return LayoutBuilder(builder: (context, c) {
      final size = Size(c.maxWidth, c.maxHeight);
      return Stack(
        children: [
          // edges + glow path
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _dash,
              builder: (_, _) => CustomPaint(
                painter: EdgePainter(
                  positions: positions,
                  edges: widget.edges,
                  litPath: litVisible,
                  dashPhase: _dash.value * 240,
                ),
              ),
            ),
          ),
          // nodes
          ...widget.nodes.where((n) {
            if (!n.lit) return true;
            return widget.litPath.indexOf(n) < widget.revealCount;
          }).map((n) {
            final left = n.pos.dx * size.width - n.size / 2;
            final top = n.pos.dy * size.height - n.size / 2;
            return Positioned(
              left: left,
              top: top,
              child: _Spawn(
                key: ValueKey(n.id),
                child: GestureDetector(
                  onTap: () => widget.onTapNode?.call(n),
                  child: GraphNodeChip(
                    type: n.type,
                    label: n.label,
                    sublabel: n.sublabel,
                    size: n.size,
                    lit: n.lit,
                    dim: !n.lit,
                    glowPulse: n.type == NodeType.causalChain,
                  ),
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}

/// Node spawn animation: scale 0.94→1 + fade (design: "Graph-build").
class _Spawn extends StatefulWidget {
  final Widget child;
  const _Spawn({super.key, required this.child});
  @override
  State<_Spawn> createState() => _SpawnState();
}

class _SpawnState extends State<_Spawn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500))
    ..forward();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curve,
      child: ScaleTransition(
        scale: Tween(begin: 0.94, end: 1.0).animate(curve),
        child: widget.child,
      ),
    );
  }
}
