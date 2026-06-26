import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// The NEXUS logo lockup: glowing cyan square + spaced wordmark.
class NexusLogo extends StatelessWidget {
  final double dot;
  final double fontSize;
  final double spacing;
  final Color color;
  const NexusLogo({
    super.key,
    this.dot = 10,
    this.fontSize = 14,
    this.spacing = 4.0,
    this.color = NexusColors.cyan,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dot,
          height: dot,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(3)),
            boxShadow: NexusShadows.halo(color, blur: 10, opacity: 1),
          ),
        ),
        const SizedBox(width: NexusSpace.x8 + 2),
        Text('NEXUS',
            style: NexusType.monoSmall(color: NexusColors.textPrimary, weight: FontWeight.w700)
                .copyWith(fontSize: fontSize, letterSpacing: spacing)),
      ],
    );
  }
}

/// Standard desktop top bar with logo, optional subtitle, and trailing widget.
class NexusAppBar extends StatelessWidget {
  final String? subtitle;
  final Widget? trailing;
  final Widget? center;
  const NexusAppBar({super.key, this.subtitle, this.trailing, this.center});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: NexusSpace.x24, vertical: NexusSpace.x16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: NexusColors.borderSubtle)),
      ),
      child: Row(
        children: [
          const NexusLogo(),
          if (subtitle != null) ...[
            const SizedBox(width: NexusSpace.x16 + 2),
            Text(subtitle!,
                style: NexusType.bodySm.copyWith(color: NexusColors.textTertiary)),
          ],
          if (center != null) ...[
            const SizedBox(width: NexusSpace.x16),
            Expanded(child: center!),
          ] else
            const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
