import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexus/main.dart';

void main() {
  testWidgets('NEXUS app boots and shows the wordmark', (tester) async {
    // No network in tests — fall back to a bundled metric-compatible font.
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const NexusApp());
    await tester.pump();

    expect(find.text('NEXUS'), findsWidgets);
  });
}
