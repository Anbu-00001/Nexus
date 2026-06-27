import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/nexus_app_bar.dart';
import '../widgets/primitives.dart';

class PidScreen extends StatelessWidget {
  const PidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const NexusAppBar(subtitle: 'P&ID-204 · Unit 3 · sheet 3'),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(width: 366, child: _QaPanel()),
              Container(width: 1, color: NexusColors.borderSubtle),
              const Expanded(child: _Drawing()),
            ],
          ),
        ),
      ],
    );
  }
}

class _QaPanel extends StatelessWidget {
  const _QaPanel();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(NexusSpace.x24 + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NexusCard(
            background: NexusColors.surface1,
            borderColor: NexusColors.borderStrong,
            child: Row(children: [
              Text('YOU', style: NexusType.monoSmall().copyWith(fontSize: 10)),
              const SizedBox(width: NexusSpace.x12 - 1),
              Expanded(
                child: Text('Where is the pressure relief on the suction header?',
                    style: NexusType.bodySm.copyWith(color: NexusColors.textPrimary)),
              ),
            ]),
          ),
          const SizedBox(height: NexusSpace.x16 + 2),
          NexusCard(
            background: const Color(0x330E2E2E),
            borderColor: NexusColors.cyan.withValues(alpha: 0.23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: NexusColors.cyan,
                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                      boxShadow: NexusShadows.halo(NexusColors.cyan, blur: 8, opacity: 1),
                    ),
                  ),
                  const SizedBox(width: NexusSpace.x8),
                  Flexible(
                    child: Text('NEXUS · LOCATED ON DRAWING',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NexusType.monoSmall(color: NexusColors.cyan).copyWith(fontSize: 10, letterSpacing: 1.2)),
                  ),
                ]),
                const SizedBox(height: NexusSpace.x8),
                RichText(
                  text: TextSpan(
                    style: NexusType.body.copyWith(height: 22 / 14, fontSize: 14),
                    children: [
                      const TextSpan(text: 'The relief is '),
                      TextSpan(
                          text: 'Relief Valve RV-103',
                          style: NexusType.body.copyWith(
                              color: NexusColors.cyan, fontWeight: FontWeight.w600, fontSize: 14)),
                      const TextSpan(
                          text: ', tied to the P-101 suction header upstream of valve '
                              'V-22. Set pressure 8.5 barg.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: NexusSpace.x16 + 2),
          const SectionLabel('Highlighted component'),
          const SizedBox(height: NexusSpace.x12),
          NexusCard(
            borderColor: NexusColors.cyan.withValues(alpha: 0.27),
            shadow: [BoxShadow(color: NexusColors.cyan.withValues(alpha: 0.1), blurRadius: 18)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RV-103 · Relief Valve',
                    style: NexusType.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: NexusSpace.x4 + 2),
                Text('Set 8.5 barg · spring · 2" inlet\nTag grid ref: C-4 · sheet 3',
                    style: NexusType.bodySm),
                const SizedBox(height: NexusSpace.x12),
                const FreshnessBadgeStub(),
              ],
            ),
          ),
          const SizedBox(height: NexusSpace.x24),
          Row(children: [
            const Expanded(child: NexusButton('Trace upstream', kind: NexusButtonKind.secondary)),
            const SizedBox(width: NexusSpace.x8),
            const Expanded(child: NexusButton('Open spec', kind: NexusButtonKind.secondary)),
          ]),
        ],
      ),
    );
  }
}

/// "last tested 9mo ago" aging pill used in the P&ID component card.
class FreshnessBadgeStub extends StatelessWidget {
  const FreshnessBadgeStub({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: NexusSpace.x12 - 1, vertical: 5),
      decoration: BoxDecoration(
        color: NexusColors.aging.withValues(alpha: 0.12),
        borderRadius: NexusRadius.rPill,
        border: Border.all(color: NexusColors.aging.withValues(alpha: 0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: NexusColors.aging, shape: BoxShape.circle)),
        const SizedBox(width: 7),
        Text('last tested 9mo ago',
            style: NexusType.monoSmall(color: NexusColors.aging, weight: FontWeight.w600)),
      ]),
    );
  }
}

class _Drawing extends StatefulWidget {
  const _Drawing();
  @override
  State<_Drawing> createState() => _DrawingState();
}

class _DrawingState extends State<_Drawing> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800));

  @override
  void initState() {
    super.initState();
    _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0B0F14)),
      child: Stack(
        children: [
          // grid + schematic
          Positioned.fill(child: CustomPaint(painter: _PidPainter())),
          Positioned(
            top: 14,
            left: 16,
            child: Text('[ P&ID-204 · rendered schematic ]',
                style: NexusType.monoSmall(color: const Color(0xFF3C4A5A)).copyWith(fontSize: 10)),
          ),
          // highlight ring + label, positioned in the 760x560 space
          LayoutBuilder(builder: (context, c) {
            double sx(double x) => x / 760 * c.maxWidth;
            double sy(double y) => y / 560 * c.maxHeight;
            return Stack(children: [
              Positioned(
                left: sx(214) - 32,
                top: sy(150) - 32,
                child: FadeTransition(
                  opacity: Tween(begin: 0.5, end: 1.0).animate(_pulse),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: NexusRadius.rLg,
                      border: Border.all(color: NexusColors.cyan, width: 2),
                      boxShadow: [
                        BoxShadow(color: NexusColors.cyan.withValues(alpha: 0.18), spreadRadius: 6),
                        BoxShadow(color: NexusColors.cyan.withValues(alpha: 0.45), blurRadius: 30),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: sx(256),
                top: sy(108),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                  decoration: BoxDecoration(
                    color: NexusColors.bgBase,
                    borderRadius: NexusRadius.rMd,
                    border: Border.all(color: NexusColors.cyan),
                    boxShadow: NexusShadows.halo(NexusColors.cyan, blur: 20, opacity: 0.3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RV-103',
                          style: NexusType.monoSmall(color: NexusColors.cyan, weight: FontWeight.w600)
                              .copyWith(fontSize: 12)),
                      const SizedBox(height: 3),
                      Text('Relief Valve · 8.5 barg', style: NexusType.monoSmall().copyWith(fontSize: 11)),
                    ],
                  ),
                ),
              ),
              _tag(sx(632), sy(472), 'P-101', NexusColors.cyan),
              _tag(sx(288), sy(262), 'V-22', const Color(0xFF7D8B9B)),
              _tag(sx(524), sy(262), 'V-18', const Color(0xFF7D8B9B)),
              _tag(sx(30), sy(360), 'T-04', const Color(0xFF7D8B9B)),
            ]);
          }),
        ],
      ),
    );
  }

  Widget _tag(double left, double top, String t, Color c) => Positioned(
        left: left,
        top: top,
        child: Text(t, style: NexusType.monoSmall(color: c, weight: FontWeight.w500).copyWith(fontSize: 10)),
      );
}

/// Draws the 26px grid + a simple P&ID schematic in the 760×560 design space.
class _PidPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // grid
    final grid = Paint()..color = const Color(0xFF172230);
    const step = 26.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), grid);
    }

    double sx(double x) => x / 760 * size.width;
    double sy(double y) => y / 560 * size.height;
    Offset p(double x, double y) => Offset(sx(x), sy(y));

    // pipes
    final pipe = Paint()
      ..color = const Color(0xFF46586B)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    void poly(List<Offset> pts) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final pt in pts.skip(1)) {
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, pipe);
    }

    poly([p(70, 300), p(300, 300)]);
    poly([p(300, 300), p(300, 180), p(470, 180)]);
    poly([p(300, 300), p(540, 300)]);
    poly([p(540, 300), p(540, 430), p(650, 430)]);
    poly([p(470, 180), p(650, 180)]);
    poly([p(210, 300), p(210, 150)]);

    // tank
    final tankFill = Paint()..color = const Color(0xFF131A22);
    final tankStroke = Paint()
      ..color = const Color(0xFF5B6B7D)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final tank = RRect.fromRectAndRadius(
        Rect.fromLTWH(sx(40), sy(250), sx(34) - sx(0), sy(350) - sy(250)),
        const Radius.circular(3));
    canvas.drawRRect(tank, tankFill);
    canvas.drawRRect(tank, tankStroke);

    // pump (cyan circle)
    final pumpFill = Paint()..color = const Color(0xFF10212A);
    final pumpStroke = Paint()
      ..color = NexusColors.cyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(p(650, 430), sx(30), pumpFill);
    canvas.drawCircle(p(650, 430), sx(30), pumpStroke);

    // valves (bowties)
    final valveFill = Paint()..color = const Color(0xFF1B232D);
    final valveStroke = Paint()
      ..color = const Color(0xFF7D8B9B)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    void bowtie(double cx) {
      for (final dir in [1.0, -1.0]) {
        final path = Path()
          ..moveTo(sx(cx - 10 * dir), sy(290))
          ..lineTo(sx(cx + 10 * dir), sy(300))
          ..lineTo(sx(cx - 10 * dir), sy(310))
          ..close();
        canvas.drawPath(path, valveFill);
        canvas.drawPath(path, valveStroke);
      }
    }

    bowtie(300);
    bowtie(540);

    // instrument bubbles
    final bubFill = Paint()..color = const Color(0xFF131A22);
    final bubStroke = Paint()
      ..color = const Color(0xFF5B6B7D)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    for (final c in [p(470, 180), p(210, 150)]) {
      canvas.drawCircle(c, sx(16), bubFill);
      canvas.drawCircle(c, sx(16), bubStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _) => false;
}
