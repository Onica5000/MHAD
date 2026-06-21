import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/wizard/steps/agent_authority_step.dart';
import 'package:mhad/ui/wizard/steps/agent_designation_step.dart';
import 'package:mhad/ui/wizard/steps/alternate_agent_step.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';

/// Merged wizard step that combines [AgentDesignationStep],
/// [AlternateAgentStep], and [AgentAuthorityStep]. Matches the prototype's
/// step 03 "People I trust" — only shown for Combined / POA form types.
///
/// Visual presentation (2026-06-03): the two embedded data-entry forms
/// now live inside collapsible `_AgentCard` widgets matching the
/// prototype's `ScrWizardPeople::AgentCard` (mobile.jsx::ScrWizardPeople
/// L637-669). Collapsed state shows a compact summary (initials avatar +
/// role label + name + relation · phone). Expanded state shows the
/// existing form inline so the user can still edit every field exactly
/// as before — function preserved, presentation matched.
class PeopleITrustStep extends ConsumerStatefulWidget {
  final int directiveId;
  const PeopleITrustStep({required this.directiveId, super.key});

  @override
  ConsumerState<PeopleITrustStep> createState() => _PeopleITrustStepState();
}

class _PeopleITrustStepState extends ConsumerState<PeopleITrustStep>
    with WizardStepMixin {
  final _primaryKey = GlobalKey<State<AgentDesignationStep>>();
  final _alternateKey = GlobalKey<State<AlternateAgentStep>>();
  final _authorityKey = GlobalKey<State<AgentAuthorityStep>>();

  @override
  Future<bool> validateAndSave() async {
    bool ok = true;
    for (final k in [_primaryKey, _alternateKey, _authorityKey]) {
      final s = k.currentState;
      if (s is WizardStepMixin) {
        ok = await (s as WizardStepMixin).validateAndSave() && ok;
      }
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _AgentCard(
          directiveId: widget.directiveId,
          agentType: 'primary',
          roleLabel: 'PRIMARY AGENT',
          isPrimary: true,
          form: AgentDesignationStep(
            key: _primaryKey,
            directiveId: widget.directiveId,
            embedded: true,
          ),
        ),
        const SizedBox(height: 12),
        _AgentCard(
          directiveId: widget.directiveId,
          agentType: 'alternate',
          roleLabel: 'ALTERNATE AGENT',
          isPrimary: false,
          form: AlternateAgentStep(
            key: _alternateKey,
            directiveId: widget.directiveId,
            embedded: true,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(child: SectionLabel('What can they decide?')),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '20 Pa.C.S. § 5836',
                style: TextStyle(
                  fontFamily: kMonoFamily,
                  fontFamilyFallback: const [
                    'Consolas',
                    'Menlo',
                    'Courier New',
                    'monospace',
                  ],
                  fontSize: 9.5,
                  color: p.textMuted,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        Text(
          'Limit or expand your agent’s authority. Default is broad authority.',
          style: TextStyle(
            fontFamily: kSansFamily,
            fontSize: 13,
            color: p.textMuted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 8),
        AgentAuthorityStep(
          key: _authorityKey,
          directiveId: widget.directiveId,
          embedded: true,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: p.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 12,
                      color: p.textMuted,
                      height: 1.45,
                    ),
                    children: [
                      TextSpan(
                        text: '"Agent decides"',
                        style: TextStyle(
                            color: p.text, fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: ' grants the power; '),
                      TextSpan(
                        text: '"No"',
                        style: TextStyle(
                            color: p.text, fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: ' withholds it entirely; '),
                      TextSpan(
                        text: '"If…"',
                        style: TextStyle(
                            color: p.text, fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(
                          text:
                              ' lets you add a condition in your own words.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tap-to-expand agent card matching prototype `ScrWizardPeople::AgentCard`
/// (mobile.jsx L637-669).
///
/// Collapsed state shows: 38pt initials avatar (primary-filled if primary,
/// primaryLight if alternate; "+" icon when no agent is on file yet) +
/// monospace role label + "Primary" badge + name + relation · phone +
/// expand chevron. Auto-expanded by default when the agent has no name
/// on file (so first-time users land directly in the form).
///
/// Expanded state shows: 3 action chips (Contact picker · Phone verified
/// · Edit details) + the embedded data-entry form (existing
/// `AgentDesignationStep` / `AlternateAgentStep` with `embedded: true`).
class _AgentCard extends ConsumerStatefulWidget {
  final int directiveId;
  final String agentType; // 'primary' | 'alternate'
  final String roleLabel; // 'PRIMARY AGENT' | 'ALTERNATE AGENT'
  final bool isPrimary;
  final Widget form;

  const _AgentCard({
    required this.directiveId,
    required this.agentType,
    required this.roleLabel,
    required this.isPrimary,
    required this.form,
  });

  @override
  ConsumerState<_AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends ConsumerState<_AgentCard> {
  bool? _expanded; // null until first data load decides the default

  String _initials(String name) {
    final parts =
        name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String _phoneOf(Agent a) {
    for (final p in [a.cellPhone, a.homePhone, a.workPhone]) {
      if (p.isNotEmpty) return p;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;

    return FutureBuilder<List<Agent>>(
      future:
          ref.read(directiveRepositoryProvider).getAgents(widget.directiveId),
      builder: (context, snap) {
        final agents = snap.data ?? const <Agent>[];
        Agent? agent;
        for (final a in agents) {
          if (a.agentType == widget.agentType) {
            agent = a;
            break;
          }
        }
        final hasName = (agent?.fullName.trim().isNotEmpty ?? false);
        // Default-expanded when no name on file so first-time users land
        // straight in the form. Once a name exists, default collapsed
        // (the user already filled it and is reviewing).
        final isExpanded = _expanded ?? !hasName;
        final initials = hasName ? _initials(agent!.fullName) : '';

        return Container(
          decoration: BoxDecoration(
            color: p.card,
            border: Border.all(
              color: isExpanded ? p.primary : p.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () =>
                    setState(() => _expanded = !isExpanded),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: hasName
                            ? (widget.isPrimary
                                ? p.primary
                                : p.primaryLight)
                            : p.surface,
                        shape: BoxShape.circle,
                        border: hasName
                            ? null
                            : Border.all(color: p.border, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: hasName
                          ? Text(
                              initials,
                              style: TextStyle(
                                fontFamily: kSansFamily,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: widget.isPrimary
                                    ? p.onPrimary
                                    : p.onPrimaryLight,
                              ),
                            )
                          : Icon(Icons.add,
                              size: 18, color: p.textMuted),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.roleLabel,
                                style: TextStyle(
                                  fontFamily: kMonoFamily,
                                  fontFamilyFallback: const [
                                    'Consolas',
                                    'Menlo',
                                    'Courier New',
                                    'monospace',
                                  ],
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  color: p.textMuted,
                                ),
                              ),
                              if (widget.isPrimary) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: p.primaryLight,
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Primary',
                                    style: TextStyle(
                                      fontFamily: kSansFamily,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                      color: p.onPrimaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            hasName
                                ? agent!.fullName
                                : (widget.isPrimary
                                    ? 'Add someone'
                                    : 'Optional'),
                            style: TextStyle(
                              fontFamily: kSansFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: p.text,
                            ),
                          ),
                          if (hasName)
                            Builder(
                              builder: (_) {
                                final rel =
                                    agent!.relationship;
                                final phone = _phoneOf(agent);
                                final parts = <String>[
                                  if (rel.isNotEmpty) rel,
                                  if (phone.isNotEmpty) phone,
                                ];
                                if (parts.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  parts.join(' · '),
                                  style: TextStyle(
                                    fontFamily: kSansFamily,
                                    fontSize: 12,
                                    color: p.textMuted,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 18,
                      color: p.textMuted,
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                // Dashed-style top divider per prototype L661.
                CustomPaint(
                  size: const Size(double.infinity, 1),
                  painter: _DashedLinePainter(color: p.border),
                ),
                const SizedBox(height: 12),
                // Status chips when the agent has a name on file. These
                // mirror the prototype's "Contact picker ✓ / Phone
                // verified ✓ / Edit details" badges.
                if (hasName)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _StatusChip(
                        label: 'Contact picker',
                        ok: agent!.address.isNotEmpty,
                      ),
                      _StatusChip(
                        label: 'Phone on file',
                        ok: _phoneOf(agent).isNotEmpty,
                      ),
                    ],
                  ),
                if (hasName) const SizedBox(height: 12),
                // Embedded data-entry form. Function preserved — every
                // text field the user could touch before is here.
                widget.form,
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool ok;
  const _StatusChip({required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final okText = dark
        ? SemanticColors.successTextDark
        : SemanticColors.successTextLight;
    final bg = ok
        ? (dark
            ? SemanticColors.successBgDark
            : SemanticColors.successBgLight)
        : p.surface;
    final fg = ok ? okText : p.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: ok ? fg.withValues(alpha: 0.2) : p.border),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ok ? Icons.check : Icons.remove,
              size: 12, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double x = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
