import 'dart:async';
import 'package:flutter/material.dart';
import '../app/scope.dart';
import '../app/shell.dart';
import '../data/mock_data.dart';
import '../graph/knowledge_graph_view.dart';
import '../theme/tokens.dart';
import '../widgets/file_ingest_card.dart';
import '../widgets/primitives.dart';

class IngestionScreen extends StatefulWidget {
  const IngestionScreen({super.key});
  @override
  State<IngestionScreen> createState() => _IngestionScreenState();
}

class _IngestionScreenState extends State<IngestionScreen> {
  int _reveal = 1;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 700), (t) {
      if (_reveal >= Demo.litPath.length) {
        t.cancel();
        return;
      }
      setState(() => _reveal++);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = (_reveal * 6 + 2).clamp(0, 32);
    final edges = (_reveal * 9).clamp(0, 47);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ScreenHeader(subtitle: 'Ingest engineering knowledge'),
        Expanded(
          child: LayoutBuilder(builder: (context, c) {
            final narrow = c.maxWidth < 820;
            if (narrow) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LeftPanel(),
                    Container(height: 1, color: NexusColors.borderSubtle),
                    SizedBox(
                      height: 440,
                      child: _GraphPanel(reveal: _reveal, nodes: nodes, edges: edges),
                    ),
                  ],
                ),
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: SingleChildScrollView(child: _LeftPanel())),
                Container(width: 1, color: NexusColors.borderSubtle),
                Expanded(child: _GraphPanel(reveal: _reveal, nodes: nodes, edges: edges)),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _LeftPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(NexusSpace.x24 + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ingest engineering knowledge', style: NexusType.h3.copyWith(fontSize: 20)),
          const SizedBox(height: NexusSpace.x4 + 2),
          Text('P&IDs, maintenance logs, SOPs & scanned forms',
              style: NexusType.bodySm),
          const SizedBox(height: NexusSpace.x20 + 2),
          _DropZone(),
          const SizedBox(height: NexusSpace.x20 + 2),
          ...Demo.ingestFiles.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: NexusSpace.x12),
                child: FileIngestCard(f),
              )),
        ],
      ),
    );
  }
}

class _DropZone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DottedBorderBox(
      child: Padding(
        padding: const EdgeInsets.all(NexusSpace.x32 + 2),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF10212A),
                borderRadius: NexusRadius.rLg,
                border: Border.all(color: NexusColors.cyan.withValues(alpha: 0.27)),
              ),
              child: const Icon(Icons.south_rounded, color: NexusColors.cyan, size: 22),
            ),
            const SizedBox(height: NexusSpace.x12 + 2),
            Text('Drop files to build the brain',
                style: NexusType.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: NexusSpace.x4 + 2),
            Text('.png · .pdf · .tiff · .csv — or browse',
                style: NexusType.monoSmall(color: NexusColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _GraphPanel extends StatelessWidget {
  final int reveal;
  final int nodes;
  final int edges;
  const _GraphPanel({required this.reveal, required this.nodes, required this.edges});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.2, -0.4),
          radius: 1.1,
          colors: [Color(0xFF0D1218), NexusColors.bgBase],
        ),
      ),
      padding: const EdgeInsets.all(NexusSpace.x24 + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('Knowledge graph · building live',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NexusType.body.copyWith(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: NexusSpace.x8),
              Flexible(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(
                    child: Text('$nodes nodes',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NexusType.monoSmall(color: NexusColors.cyan)),
                  ),
                  Text('  ·  ', style: NexusType.monoSmall()),
                  Flexible(
                    child: Text('$edges edges',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NexusType.monoSmall(color: NexusColors.causal)),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: NexusSpace.x16),
          Expanded(
            child: KnowledgeGraphView(
              nodes: [...Demo.dimNodes, ...Demo.litPath],
              edges: [...Demo.dimEdges, ...Demo.litEdges],
              litPath: Demo.litPath,
              revealCount: reveal,
              onTapNode: (_) => NexusScope.of(context).goTo(NexusScreen.graph),
            ),
          ),
          const SizedBox(height: NexusSpace.x12),
          NexusCard(
            padding: const EdgeInsets.symmetric(
                horizontal: NexusSpace.x16, vertical: NexusSpace.x12),
            child: Row(children: [
              const StatusDot(NexusColors.causal, size: 7, pulse: true),
              const SizedBox(width: NexusSpace.x8),
              Expanded(
                child: Text('New causal chain forming: V-22 → cavitation → P-101',
                    style: NexusType.monoSmall(color: NexusColors.textSecondary)),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

/// A dashed rounded border container (Flutter has no native dashed border).
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  const DottedBorderBox({
    super.key,
    required this.child,
    this.color = const Color(0x662BE8DE),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(color),
      child: ClipRRect(
        borderRadius: NexusRadius.rLg,
        child: ColoredBox(
          color: const Color(0x330E2E2E),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(NexusRadius.lg));
    final path = Path()..addRRect(rrect);
    const dash = 6.0, gap = 5.0;
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, (d + dash).clamp(0, m.length)), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _) => false;
}
