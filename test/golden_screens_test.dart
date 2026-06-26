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
import 'package:nexus/screens/dashboard_screen.dart';
import 'package:nexus/screens/decay_screen.dart';
import 'package:nexus/screens/voice_screen.dart';

/// Renders each screen to a PNG (run with `--update-goldens`) so the UI can be
/// reviewed headlessly against the design canvas.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget harness(Widget screen, NexusScreen which) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildNexusTheme(),
        home: NexusScope(
          persona: Persona.engineer,
          screen: which,
          setPersona: (_) {},
          goTo: (_) {},
          child: Scaffold(body: screen),
        ),
      );

  Future<void> shoot(WidgetTester tester, Widget screen, NexusScreen which,
      Size size, String name) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(harness(screen, which));
    await tester.pump(const Duration(milliseconds: 700));
    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
  }

  testWidgets('ingest', (t) => shoot(t, const IngestionScreen(), NexusScreen.ingest, const Size(1280, 820), 'ingest'));
  testWidgets('graph', (t) => shoot(t, const GraphScreen(), NexusScreen.graph, const Size(1280, 820), 'graph'));
  testWidgets('query', (t) => shoot(t, const QueryScreen(), NexusScreen.query, const Size(1280, 820), 'query'));
  testWidgets('pid', (t) => shoot(t, const PidScreen(), NexusScreen.pid, const Size(1280, 820), 'pid'));
  testWidgets('dashboard', (t) => shoot(t, const DashboardScreen(), NexusScreen.dashboard, const Size(1280, 900), 'dashboard'));
  testWidgets('decay', (t) => shoot(t, const DecayScreen(), NexusScreen.decay, const Size(390, 880), 'decay'));
  testWidgets('voice', (t) => shoot(t, const VoiceScreen(), NexusScreen.voice, const Size(390, 920), 'voice'));
}
