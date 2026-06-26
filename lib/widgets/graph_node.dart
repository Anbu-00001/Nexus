import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/tokens.dart';

/// A single knowledge-graph node rendered per its type's shape/color.
/// [lit] gives it the causal-path ring + glow; [dim] fades background nodes.
class GraphNodeChip extends StatelessWidget {
  final NodeType type;
  final String label;
  final String? sublabel;
  final double size;
  final bool lit;
  final bool dim;
  final bool glowPulse;

  const GraphNodeChip({
    super.key,
    required this.type,
    required this.label,
    this.sublabel,
    this.size = 54,
    this.lit = false,
    this.dim = false,
    this.glowPulse = false,
  });

  BorderRadius get _radius => switch (type.shape) {
        NodeShape.circle => const BorderRadius.all(Radius.circular(999)),
        NodeShape.square => const BorderRadius.all(Radius.circular(6)),
        NodeShape.roundedRect => BorderRadius.circular(size * 0.22),
        NodeShape.dashed => const BorderRadius.all(Radius.circular(14)),
      };

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    final opacity = dim ? 0.4 : 1.0;
    final boxShadow = <BoxShadow>[
      if (lit) ...[
        BoxShadow(color: NexusColors.causal.withValues(alpha: 0.18), spreadRadius: 4),
        BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 22),
      ] else if (!dim && (type == NodeType.equipment || type == NodeType.causalChain))
        BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 16),
    ];

    Widget node = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: type.fill.withValues(alpha: dim ? 0.5 : 1),
        borderRadius: _radius,
        border: Border.all(
          color: color.withValues(alpha: opacity),
          width: lit ? 2 : 1.5,
        ),
        boxShadow: boxShadow,
      ),
      child: label.isEmpty
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: NexusType.monoSmall(
                          color: type == NodeType.causalChain ? NexusColors.causalBright : color,
                          weight: FontWeight.w600)
                      .copyWith(fontSize: label.contains('\n') ? 9 : 11, height: 1.1),
                ),
                if (sublabel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(sublabel!,
                        style: NexusType.monoSmall(color: NexusColors.textSecondary)
                            .copyWith(fontSize: 8)),
                  ),
              ],
            ),
    );

    return node;
  }
}

/// Legend row: small node glyph + type name.
class NodeLegendRow extends StatelessWidget {
  final NodeType type;
  const NodeLegendRow(this.type, {super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GraphNodeChip(type: type, label: '', size: 18),
        const SizedBox(width: NexusSpace.x12 - 1),
        Text(type.label, style: NexusType.bodySm.copyWith(color: NexusColors.textPrimary)),
      ],
    );
  }
}
