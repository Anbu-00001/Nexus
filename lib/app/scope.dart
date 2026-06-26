import 'package:flutter/material.dart';
import '../models/models.dart';

/// The set of screens reachable in the demo.
enum NexusScreen { ingest, graph, query, pid, decay, voice, dashboard }

extension NexusScreenX on NexusScreen {
  bool get isMobile => this == NexusScreen.decay || this == NexusScreen.voice;

  String get title => switch (this) {
        NexusScreen.ingest => 'Ingest',
        NexusScreen.graph => 'Graph',
        NexusScreen.query => 'Query',
        NexusScreen.pid => 'P&ID',
        NexusScreen.decay => 'Decay',
        NexusScreen.voice => 'Capture',
        NexusScreen.dashboard => 'Dashboard',
      };

  IconData get icon => switch (this) {
        NexusScreen.ingest => Icons.cloud_upload_outlined,
        NexusScreen.graph => Icons.hub_outlined,
        NexusScreen.query => Icons.forum_outlined,
        NexusScreen.pid => Icons.account_tree_outlined,
        NexusScreen.decay => Icons.timelapse_outlined,
        NexusScreen.voice => Icons.mic_none_outlined,
        NexusScreen.dashboard => Icons.insights_outlined,
      };
}

/// App-wide state + navigation, exposed to every screen.
class NexusScope extends InheritedWidget {
  final Persona persona;
  final NexusScreen screen;
  final ValueChanged<Persona> setPersona;
  final ValueChanged<NexusScreen> goTo;

  const NexusScope({
    super.key,
    required this.persona,
    required this.screen,
    required this.setPersona,
    required this.goTo,
    required super.child,
  });

  static NexusScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NexusScope>()!;

  @override
  bool updateShouldNotify(NexusScope old) =>
      old.persona != persona || old.screen != screen;
}
