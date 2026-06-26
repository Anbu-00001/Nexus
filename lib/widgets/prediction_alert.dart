import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/tokens.dart';
import 'primitives.dart';

/// The demo's hero card: a forward-looking failure prediction with a big
/// probability, a fill bar, the driving signature, and a work-order CTA.
class PredictionAlertCard extends StatelessWidget {
  final Prediction prediction;
  final bool compact;
  final VoidCallback? onCreateWorkOrder;

  const PredictionAlertCard(
    this.prediction, {
    super.key,
    this.compact = false,
    this.onCreateWorkOrder,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (prediction.probability * 100).round();
    return Container(
      padding: EdgeInsets.all(compact ? NexusSpace.x16 + 2 : NexusSpace.x24 - 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF2A1216), Color(0xFF120C0F)],
        ),
        borderRadius: compact ? NexusRadius.rLg : NexusRadius.rXl,
        border: Border.all(color: NexusColors.stale.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: NexusColors.stale.withValues(alpha: 0.15), spreadRadius: 1),
          BoxShadow(color: NexusColors.stale.withValues(alpha: 0.20), blurRadius: 36),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StatusDot(NexusColors.stale, size: 9, pulse: true),
              const SizedBox(width: NexusSpace.x8),
              Text('PREDICTION ALERT',
                  style: NexusType.monoSmall(color: NexusColors.stale, weight: FontWeight.w600)
                      .copyWith(letterSpacing: 1.8)),
            ],
          ),
          const SizedBox(height: NexusSpace.x12),
          Text('${prediction.asset} will likely fail again',
              style: NexusType.h3.copyWith(height: 24 / 18)),
          const SizedBox(height: NexusSpace.x12 + 2),
          Text('$pct%',
              style: NexusType.display.copyWith(
                  color: NexusColors.stale, fontSize: compact ? 34 : 52, height: 1)),
          const SizedBox(height: NexusSpace.x4),
          RichText(
            text: TextSpan(style: NexusType.bodySm, children: [
              const TextSpan(text: 'probability of failure in the '),
              TextSpan(
                  text: prediction.window,
                  style: NexusType.bodySm.copyWith(color: NexusColors.textPrimary)),
            ]),
          ),
          const SizedBox(height: NexusSpace.x16),
          ClipRRect(
            borderRadius: NexusRadius.rPill,
            child: Stack(children: [
              Container(height: 6, color: const Color(0xFF1A1012)),
              FractionallySizedBox(
                widthFactor: prediction.probability,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [NexusColors.aging, NexusColors.stale]),
                    boxShadow: NexusShadows.halo(NexusColors.stale, blur: 10, opacity: 0.6),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: NexusSpace.x12 + 2),
          Text('Driver: ${prediction.driver}',
              style: NexusType.monoSmall(color: NexusColors.textSecondary)),
          if (!compact) ...[
            const SizedBox(height: NexusSpace.x16),
            NexusButton('Create work order →',
                kind: NexusButtonKind.danger, expand: true, onPressed: onCreateWorkOrder),
          ],
        ],
      ),
    );
  }
}
