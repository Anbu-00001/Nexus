import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nexus/app/scope.dart';
import 'package:nexus/models/models.dart';
import 'package:nexus/theme/theme.dart';

import 'package:nexus/screens/ingestion_screen.dart';
import 'package:nexus/screens/graph_screen.dart';
import 'package:nexus/screens/query_screen.dart';
import 'package:nexus/screens/pid_screen.dart';
import 'package:nexus/screens/decay_screen.dart';
import 'package:nexus/screens/voice_screen.dart';
import 'package:nexus/screens/dashboard_screen.dart';

/// Wraps a screen exactly like the live shell does so it can call
/// `NexusScope.of(context)` and render its `ScreenHeader`.
Widget _host(NexusScreen screen, Widget child) {
  return MaterialApp(
    theme: buildNexusTheme(),
    debugShowCheckedModeBanner: false,
    home: NexusScope(
      persona: Persona.engineer,
      screen: screen,
      setPersona: (_) {},
      goTo: (_) {},
      // The two mobile screens use MainAxisSize.min columns and are scrolled
      // by the live shell; reproduce that here so they get a finite height
      // exactly like production rather than an unbounded test viewport.
      child: Scaffold(
        body: screen.isMobile ? SingleChildScrollView(child: child) : child,
      ),
    ),
  );
}

Widget _screenFor(NexusScreen s) => switch (s) {
      NexusScreen.ingest => const IngestionScreen(),
      NexusScreen.graph => const GraphScreen(),
      NexusScreen.query => const QueryScreen(),
      NexusScreen.pid => const PidScreen(),
      NexusScreen.decay => const DecayScreen(),
      NexusScreen.voice => const VoiceScreen(),
      NexusScreen.dashboard => const DashboardScreen(),
    };

Future<void> _pumpAt(
  WidgetTester tester,
  NexusScreen screen,
  Size size,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_host(screen, _screenFor(screen)));
  // Several screens run repeating AnimationControllers + Timers, so
  // pumpAndSettle would never return. Pump a fixed slice to let the
  // reveal Timer + animations advance and the layout settle.
  await tester.pump(const Duration(milliseconds: 700));

  expect(
    tester.takeException(),
    isNull,
    reason: 'overflow/exception on ${screen.title} at ${size.width}x${size.height}',
  );
}

void main() {
  setUpAll(() {
    // No network in tests: stop google_fonts from trying to fetch IBM Plex.
    // Flutter substitutes a wide 'notdef' fallback — our worst case for width.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // Desktop screens are exercised across a wide range of widths. The live shell
  // (NexusShell) switches to the full-bleed mobile layout below 860px, so the
  // desktop screens only ever render at >=600px here — well below their natural
  // size, which is what makes the worst-case-font hardening meaningful.
  const desktopSizes = <Size>[
    Size(1440, 900),
    Size(1024, 768),
    Size(760, 800),
    Size(600, 800),
  ];

  // Mobile screens render at a fixed phone viewport.
  const mobileSize = Size(390, 844);

  const desktopScreens = <NexusScreen>[
    NexusScreen.ingest,
    NexusScreen.graph,
    NexusScreen.query,
    NexusScreen.pid,
    NexusScreen.dashboard,
  ];

  const mobileScreens = <NexusScreen>[
    NexusScreen.decay,
    NexusScreen.voice,
  ];

  for (final screen in desktopScreens) {
    for (final size in desktopSizes) {
      testWidgets(
        '${screen.title} renders without overflow at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
          await _pumpAt(tester, screen, size);
        },
      );
    }
  }

  for (final screen in mobileScreens) {
    testWidgets(
      '${screen.title} (mobile) renders without overflow at '
      '${mobileSize.width.toInt()}x${mobileSize.height.toInt()}',
      (tester) async {
        await _pumpAt(tester, screen, mobileSize);
      },
    );
  }
}
