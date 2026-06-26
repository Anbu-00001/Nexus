import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// The three operating personas. Drives the UI mode + which screens surface.
enum Persona { technician, engineer, manager }

extension PersonaX on Persona {
  String get label => switch (this) {
        Persona.technician => 'Technician',
        Persona.engineer => 'Engineer',
        Persona.manager => 'Manager',
      };
}

/// Knowledge-graph node taxonomy. Each type carries its own visual language
/// (color + shape) exactly as defined in the design's "Graph Node Styles".
enum NodeType { equipment, document, event, causalChain, assertion, tacit }

enum NodeShape { roundedRect, square, circle, dashed }

extension NodeTypeX on NodeType {
  Color get color => switch (this) {
        NodeType.equipment => NexusColors.cyan,
        NodeType.document => NexusColors.info,
        NodeType.event => NexusColors.aging,
        NodeType.causalChain => NexusColors.causal,
        NodeType.assertion => NexusColors.fresh,
        NodeType.tacit => NexusColors.textSecondary,
      };

  Color get fill => switch (this) {
        NodeType.equipment => const Color(0xFF10212A),
        NodeType.document => NexusColors.surface2,
        NodeType.event => const Color(0xFF2A1B12),
        NodeType.causalChain => NexusColors.causalWash,
        NodeType.assertion => NexusColors.surface2,
        NodeType.tacit => NexusColors.surface2,
      };

  NodeShape get shape => switch (this) {
        NodeType.equipment => NodeShape.roundedRect,
        NodeType.document => NodeShape.square,
        NodeType.event => NodeShape.circle,
        NodeType.causalChain => NodeShape.circle,
        NodeType.assertion => NodeShape.roundedRect,
        NodeType.tacit => NodeShape.dashed,
      };

  String get tag => switch (this) {
        NodeType.equipment => 'EQ',
        NodeType.document => 'DOC',
        NodeType.event => 'EVT',
        NodeType.causalChain => 'CHN',
        NodeType.assertion => 'KA',
        NodeType.tacit => 'TK',
      };

  String get label => switch (this) {
        NodeType.equipment => 'Equipment',
        NodeType.document => 'Document',
        NodeType.event => 'Event',
        NodeType.causalChain => 'Causal Chain',
        NodeType.assertion => 'Assertion',
        NodeType.tacit => 'Tacit Knowledge',
      };
}

/// A graph node with a normalized position (0..1) within its canvas.
class GraphNode {
  final String id;
  final String label;
  final String? sublabel;
  final NodeType type;
  final Offset pos; // normalized 0..1
  final bool lit; // on the highlighted causal path
  final double size;

  const GraphNode({
    required this.id,
    required this.label,
    this.sublabel,
    required this.type,
    required this.pos,
    this.lit = false,
    this.size = 54,
  });
}

class GraphEdge {
  final String from;
  final String to;
  final Color color;
  final bool lit;
  final bool dashed;

  const GraphEdge(this.from, this.to,
      {this.color = NexusColors.borderStrong, this.lit = false, this.dashed = false});
}

/// A discovered cause→effect chain. The demo centerpiece.
class CausalChain {
  final String id;
  final String summary;
  final double confidence;
  final List<CausalStep> steps;

  const CausalChain({
    required this.id,
    required this.summary,
    required this.confidence,
    required this.steps,
  });
}

class CausalStep {
  final String label;
  final String role; // valve / process / signal / bearing / outcome
  final NodeType type;
  const CausalStep(this.label, this.role, this.type);
}

class SourceRef {
  final String kind; // PID / LOG / SME
  final String label;
  final Color color;
  const SourceRef(this.kind, this.label, this.color);
}

/// A forward-looking failure prediction derived from a recurring causal pattern.
class Prediction {
  final String asset;
  final double probability;
  final String window;
  final String driver;
  const Prediction({
    required this.asset,
    required this.probability,
    required this.window,
    required this.driver,
  });
}

/// A knowledge assertion with temporal-decay confidence.
class Assertion {
  final String id;
  final String title;
  final String body;
  final double confidence; // 0..1, decayed to "now"
  final double decayPerMonth;
  final int monthsSinceConfirmed;
  final String? warning;

  const Assertion({
    required this.id,
    required this.title,
    required this.body,
    required this.confidence,
    required this.decayPerMonth,
    required this.monthsSinceConfirmed,
    this.warning,
  });

  bool get isStale => confidence < 0.55;
}

class FileIngest {
  final String name;
  final String kind; // P&ID / PDF / OCR
  final Color kindColor;
  final String statusText;
  final double progress; // 0..1
  final bool spinning;

  const FileIngest({
    required this.name,
    required this.kind,
    required this.kindColor,
    required this.statusText,
    required this.progress,
    this.spinning = false,
  });
}

class FailureCommunity {
  final String name;
  final Color color;
  final String members;
  final double riskIndex;
  const FailureCommunity(this.name, this.color, this.members, this.riskIndex);
}

class Kpi {
  final String label;
  final String value;
  final String? unit;
  final String delta;
  final Color deltaColor;
  final bool alert;
  const Kpi(this.label, this.value, this.unit, this.delta, this.deltaColor,
      {this.alert = false});
}
