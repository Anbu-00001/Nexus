import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/tokens.dart';

/// The planted demo narrative. Every figure here matches the design canvas so
/// the live app reads identically to the mockups. Later phases swap these
/// constants for live API responses behind the same shapes.
class Demo {
  Demo._();

  // ── The centerpiece causal chain ─────────────────────────────────────────
  static const causalChain = CausalChain(
    id: 'CC-07',
    summary:
        'V-22 partial close → cavitation → vibration spike → P-101 bearing wear → pump failure',
    confidence: 0.81,
    steps: [
      CausalStep('V-22', 'valve', NodeType.equipment),
      CausalStep('cavit.', 'process', NodeType.event),
      CausalStep('vibr.', 'signal', NodeType.event),
      CausalStep('P-101', 'bearing', NodeType.equipment),
      CausalStep('FAIL', 'outcome', NodeType.causalChain),
    ],
  );

  static const rootCauseTitle = 'Root cause: valve-induced cavitation';
  static const rootCauseBody =
      'Valve V-22 held a partial-closed position for 11 days, starving the pump '
      'suction and inducing cavitation. The resulting vibration accelerated '
      'P-101 bearing wear until catastrophic failure on 14 Aug 2023.';

  static const prediction = Prediction(
    asset: 'Pump P-101',
    probability: 0.74,
    window: 'next 3–5 weeks',
    driver: 'same V-22 → cavitation signature re-emerging since 02 Jun.',
  );

  static const sources = [
    SourceRef('PID', 'P&ID-204.pdf · sheet 3', NexusColors.cyan),
    SourceRef('LOG', 'maintenance-log-2023.pdf · row 142', NexusColors.aging),
    SourceRef('SME', 'R. Okafor · voice interview', NexusColors.causal),
  ];

  // ── Temporal-decay assertion (stale SOP) ─────────────────────────────────
  static const staleSop = Assertion(
    id: 'SOP-P-101-M',
    title: 'Controlled restart sequence',
    body:
        'Confirm suction valve V-22 fully open, prime casing, then energize at '
        'reduced speed…',
    confidence: 0.41,
    decayPerMonth: 0.042,
    monthsSinceConfirmed: 14,
    warning: 'Decayed past safe threshold. V-22 spec changed since last review.',
  );

  // ── Files being ingested (Screen 01) ─────────────────────────────────────
  static const ingestFiles = [
    FileIngest(
      name: 'P&ID-204_unit3.png',
      kind: 'P&ID',
      kindColor: NexusColors.cyan,
      statusText: '✓ 18 components · 9 connections mapped',
      progress: 1.0,
    ),
    FileIngest(
      name: 'maintenance-log-2023.pdf',
      kind: 'PDF',
      kindColor: NexusColors.aging,
      statusText: 'extracting events & timestamps · 142 rows',
      progress: 0.64,
    ),
    FileIngest(
      name: 'inspection-form-scan.tiff',
      kind: 'OCR',
      kindColor: NexusColors.info,
      statusText: 'handwriting OCR · reconciling fields',
      progress: 0.38,
      spinning: true,
    ),
  ];

  // ── Knowledge-graph explorer (Screen 02) ─────────────────────────────────
  // Positions are normalized to the design's 700×620 canvas.
  static const litPath = <GraphNode>[
    GraphNode(id: 'v22', label: 'V-22', sublabel: 'valve', type: NodeType.equipment, pos: Offset(0.214, 0.323), lit: true, size: 56),
    GraphNode(id: 'cav', label: 'cavit-\nation', type: NodeType.event, pos: Offset(0.429, 0.242), lit: true, size: 56),
    GraphNode(id: 'vib', label: 'vibr.\nspike', type: NodeType.event, pos: Offset(0.614, 0.435), lit: true, size: 56),
    GraphNode(id: 'p101', label: 'P-101', sublabel: 'bearing', type: NodeType.equipment, pos: Offset(0.674, 0.665), lit: true, size: 60),
    GraphNode(id: 'fail', label: 'FAIL\nCC-07', type: NodeType.causalChain, pos: Offset(0.471, 0.777), lit: true, size: 60),
  ];

  static const dimNodes = <GraphNode>[
    GraphNode(id: 'd1', label: '', type: NodeType.document, pos: Offset(0.173, 0.187), size: 34),
    GraphNode(id: 'e1', label: '', type: NodeType.event, pos: Offset(0.360, 0.135), size: 32),
    GraphNode(id: 'q1', label: '', type: NodeType.equipment, pos: Offset(0.534, 0.187), size: 36),
    GraphNode(id: 'd2', label: '', type: NodeType.document, pos: Offset(0.807, 0.200), size: 34),
    GraphNode(id: 't1', label: '', type: NodeType.tacit, pos: Offset(0.894, 0.394), size: 34),
    GraphNode(id: 'a1', label: '', type: NodeType.assertion, pos: Offset(0.774, 0.587), size: 34),
    GraphNode(id: 'e2', label: '', type: NodeType.event, pos: Offset(0.201, 0.694), size: 34),
    GraphNode(id: 'd3', label: '', type: NodeType.document, pos: Offset(0.800, 0.840), size: 32),
  ];

  static const litEdges = <GraphEdge>[
    GraphEdge('v22', 'cav', color: NexusColors.causal, lit: true),
    GraphEdge('cav', 'vib', color: NexusColors.causal, lit: true),
    GraphEdge('vib', 'p101', color: NexusColors.causal, lit: true),
    GraphEdge('p101', 'fail', color: NexusColors.causal, lit: true),
  ];

  static const dimEdges = <GraphEdge>[
    GraphEdge('d1', 'e1'),
    GraphEdge('e1', 'q1'),
    GraphEdge('q1', 'd2'),
    GraphEdge('d2', 't1'),
    GraphEdge('t1', 'a1'),
    GraphEdge('e2', 'fail'),
    GraphEdge('a1', 'd3'),
  ];

  // ── Manager dashboard (Screen 07) ────────────────────────────────────────
  static const kpis = [
    Kpi('Unplanned downtime', '38.2', 'hrs', '▼ 22% vs Q1', NexusColors.fresh),
    Kpi('MTBF', '412', 'days', '▲ 9% vs Q1', NexusColors.fresh),
    Kpi('Procedure compliance', '81%', null, '14 SOPs stale', NexusColors.aging),
    Kpi('Open predictions', '3', 'high-risk', '● P-101 in 3–5 wks',
        NexusColors.stale,
        alert: true),
  ];

  static const communities = [
    FailureCommunity('Suction / cavitation', NexusColors.stale, 'P-101 · V-22 · RV-103 · +4', 0.74),
    FailureCommunity('Seal / lubrication', NexusColors.aging, 'C-07 · K-12 · P-204 · +6', 0.52),
    FailureCommunity('Instrumentation', NexusColors.fresh, 'FT-09 · PT-14 · +8', 0.18),
  ];

  // Downtime stacked bars (process, mechanical) over 8 weeks — normalized 0..1.
  static const downtime = <(double, double)>[
    (0.18, 0.30), (0.12, 0.42), (0.24, 0.22), (0.30, 0.50),
    (0.16, 0.28), (0.20, 0.18), (0.10, 0.24), (0.14, 0.16),
  ];
}
