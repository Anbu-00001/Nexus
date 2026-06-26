import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

/// The global dark theme. NEXUS is dark-only by design.
ThemeData buildNexusTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: NexusColors.bgBase,
    canvasColor: NexusColors.bgBase,
    colorScheme: const ColorScheme.dark(
      surface: NexusColors.bgBase,
      primary: NexusColors.cyan,
      secondary: NexusColors.causal,
      error: NexusColors.stale,
      onPrimary: NexusColors.bgSunken,
      onSurface: NexusColors.textPrimary,
    ),
    textTheme: GoogleFonts.ibmPlexSansTextTheme(base.textTheme).apply(
      bodyColor: NexusColors.textPrimary,
      displayColor: NexusColors.textPrimary,
    ),
    dividerColor: NexusColors.borderSubtle,
    splashColor: NexusColors.cyan.withValues(alpha: 0.08),
    highlightColor: NexusColors.cyan.withValues(alpha: 0.05),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: NexusColors.surface2,
        borderRadius: NexusRadius.rSm,
        border: Border.all(color: NexusColors.borderStrong),
      ),
      textStyle: NexusType.caption,
    ),
  );
}
