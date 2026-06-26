import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/tokens.dart';
import '../widgets/nexus_app_bar.dart';
import '../widgets/persona_switcher.dart';
import '../screens/ingestion_screen.dart';
import '../screens/graph_screen.dart';
import '../screens/query_screen.dart';
import '../screens/pid_screen.dart';
import '../screens/decay_screen.dart';
import '../screens/voice_screen.dart';
import '../screens/dashboard_screen.dart';
import 'scope.dart';

class NexusShell extends StatefulWidget {
  const NexusShell({super.key});
  @override
  State<NexusShell> createState() => _NexusShellState();
}

class _NexusShellState extends State<NexusShell> {
  Persona _persona = Persona.engineer;
  NexusScreen _screen = NexusScreen.ingest;

  // Each persona has a "home" screen it jumps to when selected.
  void _setPersona(Persona p) {
    setState(() {
      _persona = p;
      _screen = switch (p) {
        Persona.technician => NexusScreen.decay,
        Persona.engineer => NexusScreen.query,
        Persona.manager => NexusScreen.dashboard,
      };
    });
  }

  Widget _build(NexusScreen s) => switch (s) {
        NexusScreen.ingest => const IngestionScreen(),
        NexusScreen.graph => const GraphScreen(),
        NexusScreen.query => const QueryScreen(),
        NexusScreen.pid => const PidScreen(),
        NexusScreen.decay => const DecayScreen(),
        NexusScreen.voice => const VoiceScreen(),
        NexusScreen.dashboard => const DashboardScreen(),
      };

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 860;

    // Mobile screens scroll within a device frame on desktop, full-bleed on
    // a phone. Desktop screens always get bounded height (no outer scroll).
    final Widget screenBody;
    if (_screen.isMobile) {
      final content = SingleChildScrollView(child: _build(_screen));
      screenBody = wide ? _PhoneFrame(child: content) : content;
    } else {
      screenBody = _build(_screen);
    }

    return NexusScope(
      persona: _persona,
      screen: _screen,
      setPersona: _setPersona,
      goTo: (s) => setState(() => _screen = s),
      child: Scaffold(
        body: wide
            ? Row(children: [
                _Rail(
                  screen: _screen,
                  persona: _persona,
                  onSelect: (s) => setState(() => _screen = s),
                ),
                Expanded(child: Container(color: NexusColors.bgBase, child: screenBody)),
              ])
            : Column(children: [
                Expanded(child: screenBody),
                _BottomNav(
                  screen: _screen,
                  onSelect: (s) => setState(() => _screen = s),
                ),
              ]),
      ),
    );
  }
}

/// Slim left navigation rail for wide/desktop layouts.
class _Rail extends StatelessWidget {
  final NexusScreen screen;
  final Persona persona;
  final ValueChanged<NexusScreen> onSelect;
  const _Rail({required this.screen, required this.persona, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      decoration: const BoxDecoration(
        color: NexusColors.bgSunken,
        border: Border(right: BorderSide(color: NexusColors.borderSubtle)),
      ),
      child: Column(
        children: [
          const SizedBox(height: NexusSpace.x20),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: NexusColors.cyan,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              boxShadow: NexusShadows.halo(NexusColors.cyan, blur: 12, opacity: 1),
            ),
          ),
          const SizedBox(height: NexusSpace.x32),
          ...NexusScreen.values.map((s) => _RailButton(
                screen: s,
                selected: s == screen,
                onTap: () => onSelect(s),
              )),
          const Spacer(),
          _PersonaDot(persona),
          const SizedBox(height: NexusSpace.x20),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  final NexusScreen screen;
  final bool selected;
  final VoidCallback onTap;
  const _RailButton({required this.screen, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: NexusSpace.x12),
      child: Tooltip(
        message: screen.title,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: selected ? NexusColors.cyan.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: NexusRadius.rMd,
              border: Border.all(
                  color: selected
                      ? NexusColors.cyan.withValues(alpha: 0.4)
                      : Colors.transparent),
            ),
            child: Icon(screen.icon,
                size: 20,
                color: selected ? NexusColors.cyan : NexusColors.textTertiary),
          ),
        ),
      ),
    );
  }
}

class _PersonaDot extends StatelessWidget {
  final Persona persona;
  const _PersonaDot(this.persona);
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: persona.label,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: NexusColors.surface2,
          shape: BoxShape.circle,
          border: Border.all(color: NexusColors.borderStrong),
        ),
        child: Text(persona.label[0],
            style: NexusType.monoSmall(color: NexusColors.cyan, weight: FontWeight.w700)),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final NexusScreen screen;
  final ValueChanged<NexusScreen> onSelect;
  const _BottomNav({required this.screen, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: NexusColors.bgSunken,
        border: Border(top: BorderSide(color: NexusColors.borderSubtle)),
      ),
      padding: const EdgeInsets.symmetric(vertical: NexusSpace.x8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: NexusScreen.values.map((s) {
          final sel = s == screen;
          return GestureDetector(
            onTap: () => onSelect(s),
            child: Icon(s.icon,
                size: 22, color: sel ? NexusColors.cyan : NexusColors.textTertiary),
          );
        }).toList(),
      ),
    );
  }
}

/// Centers a mobile screen inside a device-sized frame (for desktop demoing).
class _PhoneFrame extends StatelessWidget {
  final Widget child;
  const _PhoneFrame({required this.child});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final h = c.maxHeight.isFinite ? c.maxHeight - NexusSpace.x48 : 800.0;
      return Center(
        child: Container(
          width: 390,
          height: h,
          decoration: BoxDecoration(
            color: NexusColors.bgSunken,
            borderRadius: const BorderRadius.all(Radius.circular(34)),
            border: Border.all(color: NexusColors.borderSubtle),
            boxShadow: NexusShadows.e3,
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      );
    });
  }
}

/// Shared desktop header used by the desktop screens, with persona switch.
class ScreenHeader extends StatelessWidget {
  final String? subtitle;
  final Widget? center;
  const ScreenHeader({super.key, this.subtitle, this.center});
  @override
  Widget build(BuildContext context) {
    final scope = NexusScope.of(context);
    return NexusAppBar(
      subtitle: subtitle,
      center: center,
      trailing: PersonaSwitcher(
        value: scope.persona,
        onChanged: scope.setPersona,
        compact: true,
      ),
    );
  }
}
