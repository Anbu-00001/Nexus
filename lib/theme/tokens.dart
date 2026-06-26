import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// NEXUS design tokens — translated 1:1 from the Claude Design system
/// (NEXUS.dc.html · "06 · Tokens — JSON"). Do not hand-tweak values here;
/// they are the single source of truth shared with the design canvas.

class NexusColors {
  NexusColors._();

  // Base & surface
  static const bgBase = Color(0xFF0A0C10);
  static const bgSunken = Color(0xFF07090B);
  static const surface1 = Color(0xFF12161C);
  static const surface2 = Color(0xFF181E26);
  static const surface3 = Color(0xFF212934);

  // Borders
  static const borderSubtle = Color(0xFF242D38);
  static const borderStrong = Color(0xFF323D4B);

  // Text
  static const textPrimary = Color(0xFFEAF0F6);
  static const textSecondary = Color(0xFF9DA9B7);
  static const textTertiary = Color(0xFF5E6B79);

  // Accent — intelligence
  static const cyan = Color(0xFF2BE8DE);
  static const cyanDim = Color(0xFF128A84);
  static const cyanWash = Color(0xFF0E2E2E);

  // Causal — glow
  static const causal = Color(0xFF8B6CFF);
  static const causalBright = Color(0xFFB49CFF);
  static const causalWash = Color(0xFF1C1740);

  // Freshness — semantic (temporal decay)
  static const fresh = Color(0xFF34D399);
  static const aging = Color(0xFFF5B544);
  static const stale = Color(0xFFFF5C63);
  static const info = Color(0xFF5B9CFF);

  /// Maps a 0..1 confidence to its semantic freshness color.
  static Color freshnessFor(double confidence) {
    if (confidence >= 0.80) return fresh;
    if (confidence >= 0.55) return aging;
    return stale;
  }
}

/// 4px-base spacing scale: [2,4,8,12,16,20,24,32,40,48,64,80].
class NexusSpace {
  NexusSpace._();
  static const double x2 = 2;
  static const double x4 = 4;
  static const double x8 = 8;
  static const double x12 = 12;
  static const double x16 = 16;
  static const double x20 = 20;
  static const double x24 = 24;
  static const double x32 = 32;
  static const double x40 = 40;
  static const double x48 = 48;
  static const double x64 = 64;
  static const double x80 = 80;
}

class NexusRadius {
  NexusRadius._();
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 20;
  static const double pill = 999;

  static const rSm = BorderRadius.all(Radius.circular(sm));
  static const rMd = BorderRadius.all(Radius.circular(md));
  static const rLg = BorderRadius.all(Radius.circular(lg));
  static const rXl = BorderRadius.all(Radius.circular(xl));
  static const rPill = BorderRadius.all(Radius.circular(pill));
}

class NexusShadows {
  NexusShadows._();

  static const e1 = [
    BoxShadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const e2 = [
    BoxShadow(color: Color(0x73000000), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const e3 = [
    BoxShadow(color: Color(0x8C000000), blurRadius: 48, offset: Offset(0, 16)),
  ];

  // "0 0 0 1px <c> , 0 0 24px <c>" → ring (spread) + outer glow.
  static const glowCyan = [
    BoxShadow(color: Color(0x662BE8DE), spreadRadius: 1),
    BoxShadow(color: Color(0x402BE8DE), blurRadius: 24),
  ];
  static const glowCausal = [
    BoxShadow(color: Color(0x808B6CFF), spreadRadius: 1),
    BoxShadow(color: Color(0x738B6CFF), blurRadius: 28),
  ];

  /// A soft colored halo of arbitrary strength — used for live/pulsing accents.
  static List<BoxShadow> halo(Color c, {double blur = 18, double opacity = 0.45}) =>
      [BoxShadow(color: c.withValues(alpha: opacity), blurRadius: blur)];
}

/// Type scale on IBM Plex Sans / IBM Plex Mono.
/// letter-spacing is converted from `em` to logical px at each size.
class NexusType {
  NexusType._();

  static TextStyle _sans(
          {required double size,
          required double height,
          required FontWeight weight,
          double letterSpacing = 0,
          Color color = NexusColors.textPrimary}) =>
      GoogleFonts.ibmPlexSans(
        fontSize: size,
        height: height / size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: color,
      );

  static TextStyle _mono(
          {required double size,
          required double height,
          required FontWeight weight,
          double letterSpacing = 0,
          Color color = NexusColors.textPrimary}) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        height: height / size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: color,
      );

  static TextStyle get display => _sans(
      size: 48, height: 52, weight: FontWeight.w700, letterSpacing: -0.96);
  static TextStyle get h1 =>
      _sans(size: 32, height: 38, weight: FontWeight.w600, letterSpacing: -0.32);
  static TextStyle get h2 =>
      _sans(size: 24, height: 30, weight: FontWeight.w600);
  static TextStyle get h3 =>
      _sans(size: 18, height: 24, weight: FontWeight.w600);
  static TextStyle get body =>
      _sans(size: 15, height: 22, weight: FontWeight.w400);
  static TextStyle get bodySm => _sans(
      size: 13,
      height: 18,
      weight: FontWeight.w400,
      color: NexusColors.textSecondary);
  static TextStyle get caption => _sans(
      size: 12,
      height: 16,
      weight: FontWeight.w500,
      color: NexusColors.textSecondary);

  /// Uppercase mono label — apply `.toUpperCase()` at the call site.
  static TextStyle get mono => _mono(
      size: 12,
      height: 16,
      weight: FontWeight.w500,
      letterSpacing: 1.44,
      color: NexusColors.cyan);

  /// Small mono used for tags / micro-labels.
  static TextStyle monoSmall(
          {Color color = NexusColors.textSecondary, FontWeight weight = FontWeight.w500}) =>
      _mono(size: 11, height: 14, weight: weight, color: color);
}
