import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/tokens.dart';
import '../widgets/badges.dart';
import '../widgets/nexus_app_bar.dart';
import '../widgets/primitives.dart';

class DecayScreen extends StatelessWidget {
  const DecayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sop = Demo.staleSop;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _StatusBar(),
        // app bar
        Padding(
          padding: const EdgeInsets.fromLTRB(NexusSpace.x20, NexusSpace.x8, NexusSpace.x20, NexusSpace.x16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const NexusLogo(dot: 8, fontSize: 12, spacing: 3.4),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: NexusColors.surface2,
                  shape: BoxShape.circle,
                  border: Border.all(color: NexusColors.borderStrong),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(NexusSpace.x20, NexusSpace.x4, NexusSpace.x20, NexusSpace.x24 + 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You asked', style: NexusType.bodySm),
              const SizedBox(height: NexusSpace.x4),
              Text('How do I restart Pump P-101?',
                  style: NexusType.h3.copyWith(fontSize: 18)),
              const SizedBox(height: NexusSpace.x20),
              // STALE banner
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: NexusSpace.x16 - 1, vertical: NexusSpace.x12 + 1),
                decoration: BoxDecoration(
                  color: NexusColors.stale.withValues(alpha: 0.14),
                  borderRadius: NexusRadius.rLg,
                  border: Border.all(color: NexusColors.stale.withValues(alpha: 0.5)),
                  boxShadow: [BoxShadow(color: NexusColors.stale.withValues(alpha: 0.16), blurRadius: 26)],
                ),
                child: Row(children: [
                  const StatusDot(NexusColors.stale, size: 9, pulse: true),
                  const SizedBox(width: NexusSpace.x8 + 1),
                  Text('STALE — verify before use',
                      style: NexusType.bodySm.copyWith(
                          color: NexusColors.stale, fontWeight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(height: NexusSpace.x12 + 2),
              // answer card
              NexusCard(
                radius: NexusRadius.rXl,
                padding: const EdgeInsets.all(NexusSpace.x16 + 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PROCEDURE',
                            style: NexusType.monoSmall().copyWith(letterSpacing: 1.0, fontSize: 11)),
                        Text(sop.id,
                            style: NexusType.monoSmall(color: NexusColors.stale).copyWith(fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: NexusSpace.x12 - 2),
                    Text(sop.title, style: NexusType.h3.copyWith(fontSize: 16)),
                    const SizedBox(height: NexusSpace.x4 + 2),
                    Text(sop.body, style: NexusType.bodySm.copyWith(height: 20 / 13)),
                    const SizedBox(height: NexusSpace.x16 + 2),
                    DecayingConfidenceBar(
                      sop.confidence,
                      height: 9,
                      footnote:
                          'decays ~${(sop.decayPerMonth * 100).toStringAsFixed(1)}%/month · '
                          'last confirmed ${sop.monthsSinceConfirmed}mo ago',
                    ),
                    if (sop.warning != null) ...[
                      const SizedBox(height: NexusSpace.x16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: NexusSpace.x12 + 1, vertical: NexusSpace.x12 - 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1116),
                          borderRadius: NexusRadius.rMd,
                          border: Border.all(color: NexusColors.borderSubtle),
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('⚠', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: NexusSpace.x8),
                          Expanded(
                            child: Text(sop.warning!,
                                style: NexusType.bodySm.copyWith(height: 1.4)),
                          ),
                        ]),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: NexusSpace.x16),
              NexusButton('Verify with supervisor',
                  kind: NexusButtonKind.danger, expand: true),
              const SizedBox(height: NexusSpace.x12 - 2),
              NexusButton('View revision history',
                  kind: NexusButtonKind.secondary, expand: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(NexusSpace.x20 + 2, NexusSpace.x12 + 2, NexusSpace.x20 + 2, NexusSpace.x8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('9:41', style: NexusType.monoSmall(color: NexusColors.textPrimary, weight: FontWeight.w600).copyWith(fontSize: 13)),
          Row(children: [
            Icon(Icons.signal_cellular_alt, size: 14, color: NexusColors.textSecondary),
            const SizedBox(width: 5),
            Icon(Icons.wifi, size: 14, color: NexusColors.textSecondary),
            const SizedBox(width: 5),
            Icon(Icons.battery_full, size: 14, color: NexusColors.textSecondary),
          ]),
        ],
      ),
    );
  }
}
