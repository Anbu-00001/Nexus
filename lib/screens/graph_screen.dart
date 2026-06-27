import 'package:flutter/material.dart';
import '../app/scope.dart';
import '../app/shell.dart';
import '../data/mock_data.dart';
import '../graph/knowledge_graph_view.dart';
import '../models/models.dart';
import '../theme/tokens.dart';
import '../widgets/badges.dart';
import '../widgets/graph_node.dart';
import '../widgets/primitives.dart';

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ScreenHeader(subtitle: 'Graph · Unit 3'),
        Expanded(
          child: LayoutBuilder(builder: (context, c) {
            final narrow = c.maxWidth < 820;
            if (narrow) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 360, child: _Canvas()),
                    Container(height: 1, color: NexusColors.borderSubtle),
                    const _Inspector(),
                    Container(height: 1, color: NexusColors.borderSubtle),
                    const _LegendColumn(),
                  ],
                ),
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                    width: 236,
                    child: SingleChildScrollView(child: _LegendColumn())),
                Container(width: 1, color: NexusColors.borderSubtle),
                const Expanded(child: _Canvas()),
                Container(width: 1, color: NexusColors.borderSubtle),
                const SizedBox(
                    width: 304,
                    child: SingleChildScrollView(child: _Inspector())),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _LegendColumn extends StatelessWidget {
  const _LegendColumn();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(NexusSpace.x20 + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Node types'),
          const SizedBox(height: NexusSpace.x16),
          ...NodeType.values.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: NexusSpace.x12 + 1),
                child: NodeLegendRow(t),
              )),
          const NexusDivider(),
          const SectionLabel('Lit path'),
          const SizedBox(height: NexusSpace.x12 + 2),
          NexusCard(
            background: NexusColors.causalWash,
            borderColor: NexusColors.causal.withValues(alpha: 0.4),
            shadow: [BoxShadow(color: NexusColors.causal.withValues(alpha: 0.25), blurRadius: 22)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Causal chain · ${Demo.causalChain.id}',
                    style: NexusType.bodySm.copyWith(
                        color: NexusColors.causalBright, fontWeight: FontWeight.w600)),
                const SizedBox(height: NexusSpace.x4 + 2),
                Text('5 nodes · confidence ${Demo.causalChain.confidence}',
                    style: NexusType.monoSmall(color: NexusColors.textSecondary)),
                const SizedBox(height: NexusSpace.x8 + 2),
                Text(Demo.causalChain.summary,
                    style: NexusType.bodySm.copyWith(color: NexusColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Canvas extends StatelessWidget {
  const _Canvas();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.2,
          colors: [Color(0xFF0E1319), Color(0xFF08090C)],
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(NexusSpace.x24),
            child: KnowledgeGraphView(
              nodes: [...Demo.dimNodes, ...Demo.litPath],
              edges: [...Demo.dimEdges, ...Demo.litEdges],
              litPath: Demo.litPath,
              onTapNode: (n) {},
            ),
          ),
          Positioned(
            right: NexusSpace.x16,
            bottom: NexusSpace.x16,
            child: _ZoomControls(),
          ),
        ],
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NexusColors.surface1,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
        border: Border.all(color: NexusColors.borderStrong),
      ),
      child: Column(children: [
        _zoomBtn(Icons.add, true),
        _zoomBtn(Icons.remove, false),
      ]),
    );
  }

  Widget _zoomBtn(IconData i, bool top) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          border: top
              ? const Border(bottom: BorderSide(color: NexusColors.borderSubtle))
              : null,
        ),
        child: Icon(i, size: 16, color: NexusColors.textSecondary),
      );
}

class _Inspector extends StatelessWidget {
  const _Inspector();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(NexusSpace.x20 + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EQUIPMENT',
              style: NexusType.monoSmall(color: NexusColors.cyan).copyWith(letterSpacing: 1.4)),
          const SizedBox(height: NexusSpace.x4),
          Text('Pump P-101', style: NexusType.h2.copyWith(fontSize: 22)),
          const SizedBox(height: NexusSpace.x4),
          Text('Centrifugal feed pump · Unit 3 · install 2016', style: NexusType.bodySm),
          const SizedBox(height: NexusSpace.x12 + 2),
          const FreshnessBadge(0.68),
          const NexusDivider(),
          const SectionLabel('On causal path'),
          const SizedBox(height: NexusSpace.x12 + 2),
          _PathItem('Incoming: vibration spike', 'corr. 0.86 · Aug 2023'),
          const SizedBox(height: NexusSpace.x12 - 2),
          _PathItem('Outgoing: bearing failure', 'lead time 19 days'),
          const NexusDivider(),
          const SectionLabel('Sources'),
          const SizedBox(height: NexusSpace.x12),
          ...Demo.sources.take(2).map((s) => Padding(
                padding: const EdgeInsets.only(bottom: NexusSpace.x8),
                child: SourceChip(s),
              )),
          const SizedBox(height: NexusSpace.x20),
          NexusButton('Explain this chain',
              expand: true,
              onPressed: () => NexusScope.of(context).goTo(NexusScreen.query)),
        ],
      ),
    );
  }
}

class _PathItem extends StatelessWidget {
  final String title;
  final String sub;
  const _PathItem(this.title, this.sub);
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            color: NexusColors.causal,
            shape: BoxShape.circle,
            boxShadow: NexusShadows.halo(NexusColors.causal, blur: 6, opacity: 1),
          ),
        ),
        const SizedBox(width: NexusSpace.x12 - 1),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: NexusType.bodySm.copyWith(
                      color: NexusColors.textPrimary, fontWeight: FontWeight.w500)),
              Text(sub, style: NexusType.monoSmall(color: NexusColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
