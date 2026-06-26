import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/tokens.dart';
import 'graph_node.dart';

/// Horizontal V-22 → cavitation → … → FAIL stepper with glowing causal links.
class CausalChainStepper extends StatelessWidget {
  final CausalChain chain;
  const CausalChainStepper(this.chain, {super.key});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < chain.steps.length; i++) {
      final step = chain.steps[i];
      final isLast = i == chain.steps.length - 1;
      children.add(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RingedNode(
            child: GraphNodeChip(
              type: step.type,
              label: step.label,
              size: 56,
              lit: isLast,
              glowPulse: isLast,
            ),
          ),
          const SizedBox(height: NexusSpace.x8),
          Text(step.role,
              style: NexusType.monoSmall(color: NexusColors.textSecondary)
                  .copyWith(fontSize: 10)),
        ],
      ));
      if (!isLast) {
        children.add(Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: NexusColors.causal,
              boxShadow: NexusShadows.halo(NexusColors.causal, blur: 8, opacity: 1),
            ),
          ),
        ));
      }
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: children);
  }
}

/// Adds the soft causal ring (box-shadow: 0 0 0 4px rgba(causal,.16)) seen on
/// every chain node in the design.
class _RingedNode extends StatelessWidget {
  final Widget child;
  const _RingedNode({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: NexusColors.causal.withValues(alpha: 0.16), spreadRadius: 4),
        ],
      ),
      child: child,
    );
  }
}
