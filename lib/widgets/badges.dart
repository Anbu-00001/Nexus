import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/tokens.dart';
import 'primitives.dart';

/// FRESH / AGING / STALE pill with a glowing (optionally pulsing) dot.
class FreshnessBadge extends StatelessWidget {
  final double confidence; // 0..1
  final String? labelOverride;
  const FreshnessBadge(this.confidence, {super.key, this.labelOverride});

  @override
  Widget build(BuildContext context) {
    final c = NexusColors.freshnessFor(confidence);
    final word = confidence >= 0.80
        ? 'FRESH'
        : confidence >= 0.55
            ? 'AGING'
            : 'STALE';
    final text = labelOverride ?? '$word · ${(confidence * 100).round()}%';
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: NexusSpace.x12, vertical: NexusSpace.x4 + 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: NexusRadius.rPill,
        border: Border.all(color: c.withValues(alpha: 0.42)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusDot(c, size: 7, pulse: confidence < 0.55),
          const SizedBox(width: NexusSpace.x8 - 1),
          Text(text,
              style: NexusType.monoSmall(color: c, weight: FontWeight.w600)
                  .copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

/// Confidence bar with a green→amber→red gradient fill, sized to confidence.
class DecayingConfidenceBar extends StatelessWidget {
  final double confidence; // 0..1
  final String footnote;
  final double height;
  const DecayingConfidenceBar(
    this.confidence, {
    super.key,
    this.footnote = '',
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final c = NexusColors.freshnessFor(confidence);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('CONFIDENCE', style: NexusType.monoSmall()),
            Text('${(confidence * 100).round()}%',
                style: NexusType.monoSmall(color: c, weight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: NexusSpace.x8 - 1),
        ClipRRect(
          borderRadius: NexusRadius.rPill,
          child: Stack(
            children: [
              Container(height: height, color: NexusColors.surface2),
              FractionallySizedBox(
                widthFactor: confidence.clamp(0.04, 1.0),
                child: Container(
                  height: height,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                      NexusColors.fresh,
                      NexusColors.aging,
                      NexusColors.stale,
                    ], stops: [0.0, 0.55, 1.0]),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (footnote.isNotEmpty) ...[
          const SizedBox(height: NexusSpace.x8 - 1),
          Text(footnote, style: NexusType.monoSmall(color: NexusColors.textTertiary)),
        ],
      ],
    );
  }
}

/// PID / LOG / SME source-citation chip.
class SourceChip extends StatelessWidget {
  final SourceRef source;
  const SourceChip(this.source, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: NexusSpace.x12 - 1, vertical: NexusSpace.x8),
      decoration: BoxDecoration(
        color: NexusColors.surface1,
        borderRadius: NexusRadius.rSm,
        border: Border.all(color: NexusColors.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(source.kind,
              style: NexusType.monoSmall(color: source.color, weight: FontWeight.w600)
                  .copyWith(fontSize: 10)),
          const SizedBox(width: NexusSpace.x8),
          Text(source.label, style: NexusType.bodySm.copyWith(color: NexusColors.textPrimary)),
        ],
      ),
    );
  }
}
