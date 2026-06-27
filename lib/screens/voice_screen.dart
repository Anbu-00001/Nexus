import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/tokens.dart';
import '../widgets/graph_node.dart';
import '../widgets/primitives.dart';
import '../widgets/waveform.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});
  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  bool _recording = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // status bar
        Padding(
          padding: const EdgeInsets.fromLTRB(NexusSpace.x20 + 2, NexusSpace.x12 + 2, NexusSpace.x20 + 2, NexusSpace.x8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('9:41', style: NexusType.monoSmall(color: NexusColors.textPrimary, weight: FontWeight.w600).copyWith(fontSize: 13)),
            Icon(Icons.wifi, size: 14, color: NexusColors.textSecondary),
          ]),
        ),
        // app bar
        Padding(
          padding: const EdgeInsets.fromLTRB(NexusSpace.x20, NexusSpace.x8, NexusSpace.x20, NexusSpace.x12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: NexusColors.causal,
                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                      boxShadow: NexusShadows.halo(NexusColors.causal, blur: 8, opacity: 1),
                    ),
                  ),
                  const SizedBox(width: NexusSpace.x8 + 1),
                  Flexible(
                    child: Text('KNOWLEDGE CAPTURE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NexusType.monoSmall(color: NexusColors.textPrimary, weight: FontWeight.w700)
                            .copyWith(fontSize: 12, letterSpacing: 1.6)),
                  ),
                ]),
              ),
              const SizedBox(width: NexusSpace.x8),
              Text('● REC 12:04',
                  style: NexusType.monoSmall(color: NexusColors.stale).copyWith(fontSize: 11)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(NexusSpace.x20, NexusSpace.x4 + 2, NexusSpace.x20, NexusSpace.x24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI question
              NexusCard(
                radius: NexusRadius.rLg,
                background: const Color(0x330E2E2E),
                borderColor: NexusColors.cyan.withValues(alpha: 0.23),
                padding: const EdgeInsets.all(NexusSpace.x16 - 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const StatusDot(NexusColors.cyan, size: 7),
                      const SizedBox(width: NexusSpace.x8),
                      Flexible(
                        child: Text('NEXUS ASKS',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: NexusType.monoSmall(color: NexusColors.cyan).copyWith(fontSize: 10, letterSpacing: 1.0)),
                      ),
                      const SizedBox(width: NexusSpace.x8),
                      Flexible(
                        child: Text('▶ speaking',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: NexusType.monoSmall(color: NexusColors.textTertiary).copyWith(fontSize: 10)),
                      ),
                    ]),
                    const SizedBox(height: NexusSpace.x8 - 1),
                    Text('"When P-101 starts cavitating, what do you listen for before the gauges move?"',
                        style: NexusType.body.copyWith(fontWeight: FontWeight.w500, height: 22 / 15)),
                  ],
                ),
              ),
              const SizedBox(height: NexusSpace.x12 + 2),
              // waveform
              Container(
                padding: const EdgeInsets.all(NexusSpace.x16),
                decoration: BoxDecoration(
                  color: NexusColors.surface1,
                  borderRadius: NexusRadius.rXl,
                  border: Border.all(color: const Color(0xFF2C2550)),
                  boxShadow: [BoxShadow(color: NexusColors.causal.withValues(alpha: 0.14), blurRadius: 24)],
                ),
                child: Row(children: [
                  TransportButton(
                    icon: _recording ? Icons.pause : Icons.play_arrow,
                    onTap: () => setState(() => _recording = !_recording),
                  ),
                  const SizedBox(width: NexusSpace.x12 + 2),
                  Expanded(child: Waveform(active: _recording)),
                ]),
              ),
              const SizedBox(height: NexusSpace.x20),
              // transcript
              Text('LIVE TRANSCRIPT',
                  style: NexusType.monoSmall().copyWith(letterSpacing: 1.4, fontSize: 11)),
              const SizedBox(height: NexusSpace.x12 - 2),
              _Transcript(),
              const SizedBox(height: NexusSpace.x16 + 2),
              // becoming a node
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(
                  width: 26,
                  height: 40,
                  child: CustomPaint(painter: _ConnectorPainter()),
                ),
                const SizedBox(width: NexusSpace.x4),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(NexusSpace.x12 + 2),
                    decoration: BoxDecoration(
                      color: NexusColors.causalWash,
                      borderRadius: NexusRadius.rLg,
                      border: Border.all(color: NexusColors.causal, width: 1.5),
                      boxShadow: [BoxShadow(color: NexusColors.causal.withValues(alpha: 0.35), blurRadius: 22)],
                    ),
                    child: Row(children: [
                      GraphNodeChip(type: NodeType.tacit, label: 'TK', size: 42),
                      const SizedBox(width: NexusSpace.x12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('New TacitKnowledge node',
                                style: NexusType.bodySm.copyWith(
                                    color: NexusColors.causalBright, fontWeight: FontWeight.w600)),
                            Text('"early cavitation = casing rumble, −10s lead"',
                                style: NexusType.monoSmall(color: NexusColors.textSecondary).copyWith(fontSize: 11)),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: NexusSpace.x12 + 2),
              Center(
                child: Text('linked to · P-101 · cavitation event',
                    style: NexusType.monoSmall(color: NexusColors.textTertiary).copyWith(fontSize: 11)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Transcript extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: NexusType.body.copyWith(color: NexusColors.textSecondary, height: 22 / 14, fontSize: 14),
        children: [
          const TextSpan(text: '"Gauges lie when it\'s early. You hear a '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: NexusColors.causal.withValues(alpha: 0.18),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                border: Border.all(color: NexusColors.causal.withValues(alpha: 0.4)),
              ),
              child: Text('gravelly rumble at the casing about ten seconds before suction pressure drops',
                  style: NexusType.body.copyWith(color: NexusColors.causalBright, fontSize: 14, height: 1.3)),
            ),
          ),
          const TextSpan(text: ' '),
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _Cursor(),
          ),
        ],
      ),
    );
  }
}

class _Cursor extends StatefulWidget {
  const _Cursor();
  @override
  State<_Cursor> createState() => _CursorState();
}

class _CursorState extends State<_Cursor> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  @override
  void initState() {
    super.initState();
    _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _c,
        child: Container(width: 2, height: 14, color: NexusColors.cyan),
      );
}

class _ConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NexusColors.causal
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(2, 2)
      ..cubicTo(16, 2, 16, 30, 24, 30);
    // dashed
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, (d + 4).clamp(0, m.length)), paint);
        d += 8;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _) => false;
}
