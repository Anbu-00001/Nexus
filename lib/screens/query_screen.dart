import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/tokens.dart';
import '../widgets/badges.dart';
import '../widgets/causal_chain_stepper.dart';
import '../widgets/nexus_app_bar.dart';
import '../widgets/prediction_alert.dart';
import '../widgets/primitives.dart';
import '../widgets/query_bar.dart';

class QueryScreen extends StatelessWidget {
  const QueryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // App bar with inline query
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: NexusSpace.x24, vertical: NexusSpace.x12 + 2),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: NexusColors.borderSubtle)),
          ),
          child: Row(
            children: [
              const NexusLogo(),
              const SizedBox(width: NexusSpace.x16 + 2),
              Expanded(
                child: QueryBar(
                  presetText: 'Why did Pump P-101 fail in August 2023?',
                  glow: true,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(builder: (context, c) {
            final narrow = c.maxWidth < 820;
            final answer = _AnswerPanel();
            final rail = _RightRail();
            if (narrow) {
              return SingleChildScrollView(
                child: Column(children: [answer, rail]),
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: SingleChildScrollView(child: answer)),
                Container(width: 1, color: NexusColors.borderSubtle),
                SizedBox(width: 372, child: SingleChildScrollView(child: rail)),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _AnswerPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(NexusSpace.x32 - 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: NexusSpace.x12,
            runSpacing: NexusSpace.x12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 420,
                child: Text(Demo.rootCauseTitle, style: NexusType.h2),
              ),
              const FreshnessBadge(0.92),
            ],
          ),
          const SizedBox(height: NexusSpace.x12 + 2),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _RichAnswer(),
          ),
          const SizedBox(height: NexusSpace.x24 + 2),
          SectionLabel('Causal chain · ${Demo.causalChain.id}'),
          const SizedBox(height: NexusSpace.x16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: CausalChainStepper(Demo.causalChain),
          ),
          const SizedBox(height: NexusSpace.x32 - 2),
          const SectionLabel('Cited from 3 sources'),
          const SizedBox(height: NexusSpace.x12 + 2),
          Wrap(
            spacing: NexusSpace.x8,
            runSpacing: NexusSpace.x8,
            children: Demo.sources.map((s) => SourceChip(s)).toList(),
          ),
        ],
      ),
    );
  }
}

class _RichAnswer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextSpan hl(String t, Color c) => TextSpan(
        text: t, style: NexusType.body.copyWith(color: c, height: 24 / 15));
    return RichText(
      text: TextSpan(
        style: NexusType.body.copyWith(color: NexusColors.textSecondary, height: 24 / 15),
        children: [
          const TextSpan(text: 'Valve '),
          hl('V-22', NexusColors.textPrimary),
          const TextSpan(text: ' held a partial-closed position for 11 days, starving '
              'the pump suction and inducing '),
          hl('cavitation', NexusColors.aging),
          const TextSpan(text: '. The resulting vibration accelerated '),
          hl('P-101', NexusColors.textPrimary),
          const TextSpan(text: ' bearing wear until catastrophic failure on '),
          hl('14 Aug 2023', NexusColors.textPrimary),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}

class _RightRail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(NexusSpace.x32 - 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PredictionAlertCard(Demo.prediction),
          const SizedBox(height: NexusSpace.x16),
          NexusCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ANSWER FRESHNESS',
                    style: NexusType.monoSmall().copyWith(letterSpacing: 1.4)),
                const SizedBox(height: NexusSpace.x12),
                _freshRow('Causal model', '92%', NexusColors.fresh),
                const SizedBox(height: NexusSpace.x8 + 2),
                _freshRow('Underlying SOP', '41% stale', NexusColors.stale),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _freshRow(String label, String value, Color c) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NexusType.bodySm.copyWith(color: NexusColors.textSecondary)),
          ),
          const SizedBox(width: NexusSpace.x8),
          Text(value, style: NexusType.monoSmall(color: c, weight: FontWeight.w600).copyWith(fontSize: 12)),
        ],
      );
}
