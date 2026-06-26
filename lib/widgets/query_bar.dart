import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'primitives.dart';

/// The NEXUS query/input bar with a live dot, mic, and Ask button.
class QueryBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final String? presetText;
  final VoidCallback? onAsk;
  final VoidCallback? onMic;
  final bool glow;

  const QueryBar({
    super.key,
    this.controller,
    this.hint = 'Ask NEXUS about an asset, event, or procedure…',
    this.presetText,
    this.onAsk,
    this.onMic,
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(NexusSpace.x16, 5, 5, 5),
      decoration: BoxDecoration(
        color: NexusColors.surface1,
        borderRadius: NexusRadius.rMd + const BorderRadius.all(Radius.circular(1)),
        border: Border.all(color: NexusColors.borderStrong),
        boxShadow: glow
            ? [
                BoxShadow(color: NexusColors.cyan.withValues(alpha: 0.15), spreadRadius: 1),
                BoxShadow(color: NexusColors.cyan.withValues(alpha: 0.12), blurRadius: 18),
              ]
            : null,
      ),
      child: Row(
        children: [
          const StatusDot(NexusColors.cyan, size: 8),
          const SizedBox(width: NexusSpace.x12),
          Expanded(
            child: presetText != null
                ? Text(presetText!,
                    style: NexusType.body, maxLines: 1, overflow: TextOverflow.ellipsis)
                : TextField(
                    controller: controller,
                    style: NexusType.body,
                    onSubmitted: (_) => onAsk?.call(),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle:
                          NexusType.body.copyWith(color: NexusColors.textTertiary),
                    ),
                  ),
          ),
          const SizedBox(width: NexusSpace.x8),
          _IconSquare(icon: Icons.mic_none_rounded, onTap: onMic),
          const SizedBox(width: NexusSpace.x8),
          GestureDetector(
            onTap: onAsk,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: NexusSpace.x16, vertical: NexusSpace.x12 - 1),
              decoration: BoxDecoration(
                color: NexusColors.cyan,
                borderRadius: const BorderRadius.all(Radius.circular(9)),
              ),
              child: Text('Ask',
                  style: NexusType.bodySm.copyWith(
                      color: NexusColors.bgSunken, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconSquare extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _IconSquare({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: NexusColors.surface2,
          borderRadius: const BorderRadius.all(Radius.circular(9)),
          border: Border.all(color: NexusColors.borderStrong),
        ),
        child: Icon(icon, size: 18, color: NexusColors.textSecondary),
      ),
    );
  }
}
