import 'package:flutter/material.dart';
import '../app/shell.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/tokens.dart';
import '../widgets/primitives.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ScreenHeader(subtitle: 'Plant overview · Unit 3 · Q2 2026'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(NexusSpace.x24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _KpiRow(),
                const SizedBox(height: NexusSpace.x16),
                LayoutBuilder(builder: (context, c) {
                  final narrow = c.maxWidth < 760;
                  if (narrow) {
                    return Column(children: [
                      _DowntimeChart(),
                      const SizedBox(height: NexusSpace.x16),
                      _ComplianceCard(),
                    ]);
                  }
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 16, child: _DowntimeChart()),
                        const SizedBox(width: NexusSpace.x16),
                        Expanded(flex: 10, child: _ComplianceCard()),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: NexusSpace.x16),
                _Communities(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _KpiRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth < 720 ? 2 : 4;
      // Narrow cards are ~150px wide; 1.75 is too short for the value + delta
      // (clips by ~14px), so give phone-width cards more height.
      final ratio = cols == 2 ? 1.4 : 1.75;
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: NexusSpace.x16,
        mainAxisSpacing: NexusSpace.x16,
        childAspectRatio: ratio,
        children: Demo.kpis.map((k) => _KpiCard(k)).toList(),
      );
    });
  }
}

class _KpiCard extends StatelessWidget {
  final Kpi kpi;
  const _KpiCard(this.kpi);
  @override
  Widget build(BuildContext context) {
    return NexusCard(
      padding: const EdgeInsets.all(NexusSpace.x16 + 2),
      gradient: kpi.alert
          ? const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF2A1216), NexusColors.surface1])
          : null,
      borderColor: kpi.alert ? NexusColors.stale.withValues(alpha: 0.4) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(kpi.label.toUpperCase(),
              style: NexusType.monoSmall(color: kpi.alert ? NexusColors.stale : NexusColors.textTertiary)
                  .copyWith(fontSize: 11, letterSpacing: 1.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text(kpi.value,
                style: NexusType.display.copyWith(
                    fontSize: 30, color: kpi.alert ? NexusColors.stale : (kpi.label.contains('compliance') ? NexusColors.aging : NexusColors.textPrimary))),
            if (kpi.unit != null) ...[
              const SizedBox(width: NexusSpace.x8),
              Text(kpi.unit!, style: NexusType.monoSmall().copyWith(fontSize: 12)),
            ],
          ]),
          Text(kpi.delta,
              style: NexusType.monoSmall(color: kpi.deltaColor, weight: FontWeight.w500).copyWith(fontSize: 11),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _DowntimeChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NexusCard(
      padding: const EdgeInsets.all(NexusSpace.x20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('Downtime by cause · last 8 weeks',
                    style: NexusType.body.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Row(children: [
                Text('■ mechanical', style: NexusType.monoSmall(color: NexusColors.cyan).copyWith(fontSize: 11)),
                const SizedBox(width: NexusSpace.x12),
                Text('■ process', style: NexusType.monoSmall(color: NexusColors.aging).copyWith(fontSize: 11)),
              ]),
            ],
          ),
          const SizedBox(height: NexusSpace.x24),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (i, bar) in Demo.downtime.indexed) ...[
                  if (i != 0) const SizedBox(width: NexusSpace.x12 + 2),
                  Expanded(child: _StackedBar(process: bar.$1, mechanical: bar.$2)),
                ],
              ],
            ),
          ),
          const SizedBox(height: NexusSpace.x12 - 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(8, (i) => Text('W${i + 1}',
                style: NexusType.monoSmall(color: NexusColors.textTertiary).copyWith(fontSize: 10))),
          ),
        ],
      ),
    );
  }
}

class _StackedBar extends StatelessWidget {
  final double process;
  final double mechanical;
  const _StackedBar({required this.process, required this.mechanical});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FractionallySizedBox(
          widthFactor: 1,
          child: Container(
            height: 200 * process,
            decoration: const BoxDecoration(
              color: NexusColors.aging,
              borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          height: 200 * mechanical,
          decoration: const BoxDecoration(
            color: NexusColors.cyan,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(3)),
          ),
        ),
      ],
    );
  }
}

class _ComplianceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NexusCard(
      padding: const EdgeInsets.all(NexusSpace.x20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Compliance status', style: NexusType.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: NexusSpace.x16 + 2),
          Row(children: [
            SizedBox(width: 104, height: 104, child: CustomPaint(painter: _RingPainter(), child: const Center(child: _RingLabel()))),
            const SizedBox(width: NexusSpace.x20),
            Expanded(
              child: Column(children: [
                _legend(NexusColors.fresh, 'Fresh SOPs', '112'),
                const SizedBox(height: NexusSpace.x8 + 2),
                _legend(NexusColors.aging, 'Aging', '29'),
                const SizedBox(height: NexusSpace.x8 + 2),
                _legend(NexusColors.stale, 'Stale · verify', '14'),
              ]),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _legend(Color c, String label, String count) => Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: NexusSpace.x8 + 1),
        Expanded(child: Text(label, style: NexusType.bodySm)),
        Text(count, style: NexusType.monoSmall(color: c == NexusColors.stale ? NexusColors.stale : NexusColors.textPrimary, weight: FontWeight.w600).copyWith(fontSize: 12)),
      ]);
}

class _RingLabel extends StatelessWidget {
  const _RingLabel();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      decoration: const BoxDecoration(color: NexusColors.surface1, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('81%', style: NexusType.h3.copyWith(fontSize: 20, fontWeight: FontWeight.w700)),
        Text('current', style: NexusType.monoSmall(color: NexusColors.textSecondary).copyWith(fontSize: 9)),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const SweepGradient(
        startAngle: -1.5708,
        endAngle: 4.7124,
        colors: [NexusColors.fresh, NexusColors.fresh, NexusColors.aging, NexusColors.aging, NexusColors.stale, NexusColors.stale],
        stops: [0.0, 0.70, 0.70, 0.88, 0.88, 1.0],
      ).createShader(rect);
    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(covariant _) => false;
}

class _Communities extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NexusCard(
      padding: const EdgeInsets.all(NexusSpace.x20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text('Failure communities · clustered by shared causal roots',
                  style: NexusType.body.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text('3 clusters · 27 assets', style: NexusType.monoSmall().copyWith(fontSize: 11)),
            ],
          ),
          const SizedBox(height: NexusSpace.x16 + 2),
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth < 640 ? 1 : 3;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: NexusSpace.x16,
              mainAxisSpacing: NexusSpace.x16,
              childAspectRatio: 1.5,
              children: Demo.communities.map((m) => _CommunityCard(m)).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final FailureCommunity m;
  const _CommunityCard(this.m);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NexusSpace.x16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1116),
        borderRadius: NexusRadius.rMd,
        border: Border.all(color: m.color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            StatusDot(m.color, size: 8),
            const SizedBox(width: NexusSpace.x8),
            Flexible(child: Text(m.name, style: NexusType.bodySm.copyWith(color: m.color, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: NexusSpace.x4 + 2),
          Text(m.members, style: NexusType.monoSmall(color: NexusColors.textSecondary).copyWith(fontSize: 11)),
          const Spacer(),
          Text('risk index ${m.riskIndex}',
              style: NexusType.monoSmall(color: m.color, weight: FontWeight.w600).copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
