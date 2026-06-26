import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Animated voice waveform — bars scaleY on a staggered loop (design: nx-wave).
/// When [active] is false the bars rest low (paused state).
class Waveform extends StatefulWidget {
  final int bars;
  final Color color;
  final bool active;
  final double height;
  const Waveform({
    super.key,
    this.bars = 11,
    this.color = NexusColors.causal,
    this.active = true,
    this.height = 38,
  });

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Row(
            children: List.generate(widget.bars, (i) {
              final phase = i / widget.bars;
              final t = (_c.value + phase) % 1.0;
              // triangle wave 0.18 → 1 → 0.18
              final tri = 1 - (2 * t - 1).abs();
              final scale = widget.active ? (0.18 + 0.82 * tri) : 0.18;
              final accent = i.isOdd ? const Color(0xFF9D83FF) : widget.color;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Align(
                    alignment: Alignment.center,
                    child: FractionallySizedBox(
                      heightFactor: scale.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// A circular transport button (record / pause) with a causal glow.
class TransportButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final double size;
  const TransportButton({
    super.key,
    required this.icon,
    this.color = NexusColors.causal,
    this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: NexusShadows.halo(color, blur: 20, opacity: 0.55),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.4),
      ),
    );
  }
}

/// Static decorative waveform painter (for non-animated contexts).
class StaticWaveform extends StatelessWidget {
  final Color color;
  const StaticWaveform({super.key, this.color = NexusColors.causal});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _StaticWavePainter(color), size: const Size(double.infinity, 38));
}

class _StaticWavePainter extends CustomPainter {
  final Color color;
  _StaticWavePainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final rnd = math.Random(7);
    const n = 22;
    for (var i = 0; i < n; i++) {
      final x = size.width * i / (n - 1);
      final h = size.height * (0.2 + 0.8 * rnd.nextDouble());
      canvas.drawLine(
          Offset(x, (size.height - h) / 2), Offset(x, (size.height + h) / 2), p);
    }
  }

  @override
  bool shouldRepaint(covariant _) => false;
}
