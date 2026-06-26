import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/tokens.dart';

/// Per-file ingestion progress card (icon · name · status · progress bar).
class FileIngestCard extends StatelessWidget {
  final FileIngest file;
  const FileIngestCard(this.file, {super.key});

  @override
  Widget build(BuildContext context) {
    final complete = file.progress >= 1.0;
    final active = !complete && !file.spinning;
    final statusColor = complete
        ? NexusColors.fresh
        : file.spinning
            ? NexusColors.textSecondary
            : NexusColors.cyan;
    return Container(
      padding: const EdgeInsets.all(NexusSpace.x16),
      decoration: BoxDecoration(
        color: NexusColors.surface1,
        borderRadius: NexusRadius.rMd + const BorderRadius.all(Radius.circular(2)),
        border: Border.all(
            color: active
                ? NexusColors.cyan.withValues(alpha: 0.2)
                : NexusColors.borderSubtle),
        boxShadow: active
            ? [BoxShadow(color: NexusColors.cyan.withValues(alpha: 0.10), blurRadius: 18)]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: file.kindColor.withValues(alpha: 0.06),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  border: Border.all(color: file.kindColor.withValues(alpha: 0.2)),
                ),
                child: Text(file.kind,
                    style: NexusType.monoSmall(color: file.kindColor, weight: FontWeight.w600)
                        .copyWith(fontSize: 9)),
              ),
              const SizedBox(width: NexusSpace.x12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NexusType.bodySm.copyWith(
                            color: NexusColors.textPrimary, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(file.statusText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NexusType.monoSmall(color: statusColor).copyWith(fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: NexusSpace.x8),
              if (file.spinning)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: NexusColors.info),
                )
              else
                Text('${(file.progress * 100).round()}%',
                    style: NexusType.monoSmall(color: statusColor, weight: FontWeight.w600)
                        .copyWith(fontSize: 12)),
            ],
          ),
          const SizedBox(height: NexusSpace.x12),
          ClipRRect(
            borderRadius: NexusRadius.rPill,
            child: Stack(children: [
              Container(height: 5, color: NexusColors.surface2),
              FractionallySizedBox(
                widthFactor: file.progress.clamp(0.0, 1.0),
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: statusColor,
                    boxShadow:
                        active ? NexusShadows.halo(statusColor, blur: 10, opacity: 1) : null,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
