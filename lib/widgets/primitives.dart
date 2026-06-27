import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Surface card matching the design's `surface/1` panel treatment.
class NexusCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? background;
  final Color? borderColor;
  final BorderRadius radius;
  final List<BoxShadow>? shadow;
  final Gradient? gradient;

  const NexusCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(NexusSpace.x16),
    this.background,
    this.borderColor,
    this.radius = NexusRadius.rLg,
    this.shadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (background ?? NexusColors.surface1) : null,
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? NexusColors.borderSubtle),
        boxShadow: shadow,
      ),
      child: child,
    );
  }
}

enum NexusButtonKind { primary, secondary, ghost, danger }

class NexusButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final NexusButtonKind kind;
  final IconData? icon;
  final bool expand;

  const NexusButton(
    this.label, {
    super.key,
    this.onPressed,
    this.kind = NexusButtonKind.primary,
    this.icon,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border, shadow) = switch (kind) {
      NexusButtonKind.primary => (
          NexusColors.cyan,
          NexusColors.bgSunken,
          null,
          NexusShadows.halo(NexusColors.cyan, blur: 20, opacity: 0.3),
        ),
      NexusButtonKind.secondary => (
          NexusColors.surface2,
          NexusColors.textPrimary,
          NexusColors.borderStrong,
          null,
        ),
      NexusButtonKind.ghost => (
          Colors.transparent,
          NexusColors.textSecondary,
          null,
          null,
        ),
      NexusButtonKind.danger => (
          NexusColors.stale.withValues(alpha: 0.10),
          NexusColors.stale,
          NexusColors.stale.withValues(alpha: 0.40),
          null,
        ),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: NexusRadius.rMd,
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: NexusRadius.rMd,
            border: border == null ? null : Border.all(color: border),
            boxShadow: shadow,
          ),
          child: Container(
            width: expand ? double.infinity : null,
            padding: const EdgeInsets.symmetric(
                horizontal: NexusSpace.x20, vertical: NexusSpace.x12 + 1),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: NexusSpace.x8),
                ],
                Flexible(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: NexusType.body.copyWith(
                          color: fg, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Uppercase mono section label ("01 · COLOR" style).
class SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const SectionLabel(this.text, {super.key, this.color = NexusColors.textTertiary});

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: NexusType.monoSmall(color: color).copyWith(letterSpacing: 1.6),
      );
}

/// A small status dot, optionally pulsing, with a colored glow.
class StatusDot extends StatefulWidget {
  final Color color;
  final double size;
  final bool pulse;
  const StatusDot(this.color, {super.key, this.size = 8, this.pulse = false});

  @override
  State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot>
    with SingleTickerProviderStateMixin {
  // Created in initState (never lazily during dispose), so tearing the widget
  // down before it ever builds can't trigger an unsafe TickerMode lookup.
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400));

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
  Widget build(BuildContext context) {
    final dot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
        boxShadow: NexusShadows.halo(widget.color, blur: 8, opacity: 0.9),
      ),
    );
    if (!widget.pulse) return dot;
    return FadeTransition(
      opacity: Tween(begin: 0.5, end: 1.0).animate(_c),
      child: dot,
    );
  }
}

/// Thin horizontal rule.
class NexusDivider extends StatelessWidget {
  final double vertical;
  const NexusDivider({super.key, this.vertical = NexusSpace.x20});
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: vertical),
        child: const ColoredBox(
            color: NexusColors.borderSubtle, child: SizedBox(height: 1, width: double.infinity)),
      );
}
