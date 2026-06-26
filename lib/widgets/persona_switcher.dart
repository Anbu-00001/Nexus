import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/tokens.dart';

/// Segmented Technician · Engineer · Manager control.
class PersonaSwitcher extends StatelessWidget {
  final Persona value;
  final ValueChanged<Persona> onChanged;
  final bool compact;
  const PersonaSwitcher({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NexusSpace.x4),
      decoration: BoxDecoration(
        color: NexusColors.surface1,
        borderRadius: NexusRadius.rMd,
        border: Border.all(color: NexusColors.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: Persona.values.map((p) {
          final selected = p == value;
          return GestureDetector(
            onTap: () => onChanged(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: EdgeInsets.symmetric(
                  horizontal: compact ? NexusSpace.x12 : NexusSpace.x12 + 2,
                  vertical: compact ? NexusSpace.x8 - 1 : NexusSpace.x8 + 1),
              decoration: BoxDecoration(
                color: selected ? NexusColors.cyan : Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(7)),
              ),
              child: Text(
                p.label,
                style: NexusType.caption.copyWith(
                  fontSize: compact ? 11 : 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? NexusColors.bgSunken : NexusColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
