import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/agent_ext.dart';
import 'package:mhad/utils/address_format.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';

class ReviewStep extends ConsumerStatefulWidget {
  final int directiveId;
  final FormType formType;
  final bool embedded;

  /// Optional jump-to-step callback. When wired, the per-row "Edit" affordance
  /// asks the host wizard to navigate back to the relevant [WizardStep]. The
  /// wizard currently embeds this step without a callback, in which case the
  /// Edit affordance is hidden (the review remains a read-only last check, the
  /// same behavior the screen has always had).
  final void Function(WizardStep step)? onEditStep;

  const ReviewStep({
    required this.directiveId,
    required this.formType,
    this.embedded = false,
    this.onEditStep,
    super.key,
  });

  @override
  ConsumerState<ReviewStep> createState() => _ReviewStepState();
}

class _ReviewData {
  final Directive directive;
  final List<Agent> agents;
  final DirectivePref? prefs;
  final AdditionalInstructionsTableData? additionalInstructions;
  final GuardianNomination? guardian;
  final List<MedicationEntry> medications;
  final List<DiagnosisEntry> diagnoses;
  final List<DirectiveAllergy> allergies;

  const _ReviewData({
    required this.directive,
    required this.agents,
    required this.prefs,
    required this.additionalInstructions,
    required this.guardian,
    required this.medications,
    required this.diagnoses,
    required this.allergies,
  });
}

/// One editorial review row: a serif numeral, the section label, a one-line
/// summary of its contents, a per-row ok/needs-attention indicator, and an
/// optional Edit affordance. Carries the raw key/value entries so they stay
/// available to screen readers (preserving the data exposed by the old
/// `_ReviewSection`).
class _ReviewRowData {
  final WizardStep step;
  final String label;
  final Map<String, String> entries;
  final bool ok;

  /// When false the summary line is shown muted/empty-toned rather than as
  /// real content (mirrors the old "Empty / No information entered" state).
  final bool hasContent;

  const _ReviewRowData({
    required this.step,
    required this.label,
    required this.entries,
    required this.ok,
    required this.hasContent,
  });

  /// Non-empty entries, used for both the summary string and a11y.
  List<MapEntry<String, String>> get nonEmpty =>
      entries.entries.where((e) => e.value.isNotEmpty).toList();

  /// Compact one-line summary: joins the non-empty values (or "key: value"
  /// where the key carries meaning, e.g. ICD codes) with middle dots.
  String get summary {
    final parts = nonEmpty.map((e) => e.value).toList();
    if (parts.isEmpty) return 'Not provided yet';
    return parts.join(' · ');
  }
}

class _ReviewStepState extends ConsumerState<ReviewStep> with WizardStepMixin {
  _ReviewData? _data;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final repo = ref.read(directiveRepositoryProvider);
    final bundle = await repo.loadBundle(widget.directiveId);
    if (bundle == null || !mounted) return;
    // Allergies aren't part of DirectiveBundle — fetch separately for the
    // Allergies review row.
    final allergies = await repo.getAllergies(widget.directiveId);
    if (!mounted) return;

    setState(() {
      _data = _ReviewData(
        directive: bundle.directive,
        agents: bundle.agents,
        prefs: bundle.prefs,
        additionalInstructions: bundle.additional,
        guardian: bundle.guardian,
        medications: bundle.medications,
        diagnoses: bundle.diagnoses,
        allergies: allergies,
      );
    });
  }

  @override
  Future<bool> validateAndSave() async => true;

  /// Builds the ordered list of editorial rows from loaded data. Every section
  /// and field that the legacy `_ReviewSection` layout rendered is preserved
  /// here — only the presentation changed.
  List<_ReviewRowData> _buildRows(_ReviewData data) {
    final d = data.directive;
    final agents = data.agents;
    final prefs = data.prefs;
    final additional = data.additionalInstructions;
    final guardian = data.guardian;
    final meds = data.medications;

    final primaryAgent = agents.primaryAgent;
    final altAgent = agents.alternateAgent;

    final exceptions = meds
        .where((m) => m.entryType == MedicationEntryType.exception.name)
        .toList();
    final limitations = meds
        .where((m) => m.entryType == MedicationEntryType.limitation.name)
        .toList();
    final preferred = meds
        .where((m) => m.entryType == MedicationEntryType.preferred.name)
        .toList();

    String firstPhone(Agent? a) => a == null
        ? ''
        : [a.homePhone, a.workPhone, a.cellPhone]
            .firstWhere((p) => p.isNotEmpty, orElse: () => '');

    // Build a row; hasContent reflects whether ANY value was provided so empty
    // steps render the muted "Not provided yet" state. `ok` defaults to true
    // (optional) — pass false only for a genuine blocker (e.g. missing name).
    _ReviewRowData row(WizardStep step, String label,
        Map<String, String> entries, {bool? ok}) {
      final has = entries.values.any((v) => v.trim().isNotEmpty);
      return _ReviewRowData(
        step: step,
        label: label,
        entries: entries,
        hasContent: has,
        ok: ok ?? true,
      );
    }

    final rows = <_ReviewRowData>[];

    // Drive the rows off THIS form type's own step list, so EVERY step the user
    // could fill is shown for review (with its data, or "Not provided yet") and
    // the set respects the form type: POA shows the agent/guardian steps only,
    // Declaration omits the agent steps, Combined shows them all. The Review
    // step itself has no row.
    for (final step in widget.formType.steps) {
      switch (step) {
        case WizardStep.aboutYou:
          rows.add(row(step, 'Personal Information', {
            'Name': d.fullName,
            'Date of birth': d.dateOfBirth,
            'Address': composeAddressInline(
                line1: d.address,
                line2: d.address2,
                city: d.city,
                state: d.state,
                zip: d.zip),
            'Phone': d.phone,
          }, ok: d.fullName.trim().isNotEmpty));

        case WizardStep.whenItKicksIn:
          rows.add(row(step, 'Effective Condition',
              {'Condition': d.effectiveCondition}));

        case WizardStep.peopleITrust:
          rows.add(row(step, 'Primary Agent', {
            'Name': primaryAgent?.fullName ?? '',
            'Relationship': primaryAgent?.relationship ?? '',
            'Phone': firstPhone(primaryAgent),
          }));
          // Alternate agent is optional — only its own row when one is named.
          if (altAgent != null) {
            rows.add(row(step, 'Alternate Agent', {
              'Name': altAgent.fullName,
              'Relationship': altAgent.relationship,
              'Phone': firstPhone(altAgent),
            }));
          }

        case WizardStep.guardianNomination:
          rows.add(row(step, 'Guardian Nomination', {
            'Name': guardian?.nomineeFullName ?? '',
            'Relationship': guardian?.nomineeRelationship ?? '',
            'Phone': guardian?.nomineePhone ?? '',
          }));

        case WizardStep.whereIWantCare:
          rows.add(row(step, 'Where I want care', {
            'Treatment facility': prefs?.treatmentFacilityPref ?? '',
            'Medication consent': prefs?.medicationConsent ?? '',
          }));

        case WizardStep.diagnoses:
          rows.add(row(step, 'Medical Diagnoses', {
            for (final dx in data.diagnoses) dx.icdCode: dx.name,
          }));

        case WizardStep.allergies:
          rows.add(row(step, 'Allergies & reactions', {
            'Allergies': data.allergies
                .map((a) => a.severity.isNotEmpty
                    ? '${a.substance} (${a.severity})'
                    : a.substance)
                .where((s) => s.trim().isNotEmpty)
                .join(', '),
          }));

        case WizardStep.medications:
          rows.add(row(step, 'Medications', {
            'Never give': exceptions.map((m) => m.medicationName).join(', '),
            'With limits': limitations.map((m) => m.medicationName).join(', '),
            'Preferred': preferred.map((m) => m.medicationName).join(', '),
          }));

        case WizardStep.proceduresResearch:
          rows.add(row(step, 'Procedures & research', {
            'ECT consent': prefs?.ectConsent ?? '',
            'Experimental studies': prefs?.experimentalConsent ?? '',
            'Drug trials': prefs?.drugTrialConsent ?? '',
          }));

        case WizardStep.anythingElse:
          rows.add(row(step, 'Additional Instructions', {
            'Activities': additional?.activities ?? '',
            'Crisis intervention': additional?.crisisIntervention ?? '',
            'Health history': additional?.healthHistory ?? '',
            'Dietary': additional?.dietary ?? '',
            'Religious': additional?.religious ?? '',
            'Children': additional?.childrenCustody ?? '',
            'Family notification': additional?.familyNotification ?? '',
            'Records disclosure': additional?.recordsDisclosure ?? '',
            'Pet care': additional?.petCustody ?? '',
            'Other': additional?.other ?? '',
          }));

        case WizardStep.reviewAndSign:
          break; // the Review step itself — no row to review
      }
    }

    return rows;
  }

  /// Optional-but-recommended contact details that are missing for people the
  /// user named. These never block signing (everything's optional), but the
  /// review step nudges the user to acquire them so the care team can actually
  /// reach the agent / guardian.
  List<String> _missingRecommended(_ReviewData data) {
    final out = <String>[];
    void check(String who, bool hasPhone, bool hasAddress) {
      if (!hasPhone) out.add("$who's phone number");
      if (!hasAddress) out.add("$who's address");
    }

    final primary = data.agents.primaryAgent;
    if (primary != null && primary.fullName.isNotEmpty) {
      check('your primary agent', primary.bestPhone.isNotEmpty,
          primary.fullAddress.isNotEmpty);
    }
    final alt = data.agents.alternateAgent;
    if (alt != null && alt.fullName.isNotEmpty) {
      check('your alternate agent', alt.bestPhone.isNotEmpty,
          alt.fullAddress.isNotEmpty);
    }
    final g = data.guardian;
    if (g != null && g.nomineeFullName.isNotEmpty) {
      check('your guardian nominee', g.nomineePhone.isNotEmpty,
          g.fullNomineeAddress.isNotEmpty);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return Center(
        child: Semantics(
          label: 'Loading',
          child: const CircularProgressIndicator(),
        ),
      );
    }

    final p = Theme.of(context).mhadPalette;
    final rows = _buildRows(_data!);
    // Only genuine blockers (e.g. missing name) count as "needs attention".
    // Empty OPTIONAL steps still render (as "Not provided yet") but don't
    // inflate the warning banner now that every step is always shown.
    final warnCount = rows.where((r) => !r.ok).length;

    return ListView(
      shrinkWrap: widget.embedded,
      physics: widget.embedded ? const NeverScrollableScrollPhysics() : null,
      padding: widget.embedded
          ? const EdgeInsets.symmetric(horizontal: 4)
          : const EdgeInsets.fromLTRB(20, 4, 20, 16),
      children: [
        // The wizard scaffold's StepHead already renders the "Review" title +
        // subtitle above this step, so we avoid a duplicate H1 and instead
        // lead with a short editorial summary line (prototype ScrReview copy).
        Text(
          "One last look, then we'll make your signing packet.",
          style: TextStyle(
            fontFamily: kSansFamily,
            fontSize: 14,
            height: 1.5,
            color: p.textMuted,
          ),
        ),
        const SizedBox(height: 16),

        // ok / warning summary banner.
        if (warnCount > 0)
          InfoBanner(
            icon: Icons.warning_amber_rounded,
            variant: InfoBannerVariant.warning,
            text: warnCount == 1
                ? '1 section still needs your attention before signing.'
                : '$warnCount sections still need your attention before '
                    'signing.',
          )
        else
          const InfoBanner(
            icon: Icons.check_circle_outline,
            variant: InfoBannerVariant.success,
            text: 'Everything looks good. All sections reviewed.',
          ),

        // Optional-but-recommended contact details that are still blank. These
        // don't block signing — just a nudge to gather them if you can.
        if (_missingRecommended(_data!).isNotEmpty) ...[
          const SizedBox(height: 8),
          InfoBanner(
            icon: Icons.info_outline,
            variant: InfoBannerVariant.info,
            text: 'Optional, but worth gathering before you sign: '
                '${_missingRecommended(_data!).join('; ')}. '
                'They help your care team reach the people you named — you can '
                'still sign without them.',
          ),
        ],

        const SectionLabel('Your directive at a glance'),

        // Numbered editorial rows.
        ...List.generate(rows.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ReviewRow(
              number: i + 1,
              data: rows[i],
              onEdit: widget.onEditStep == null
                  ? null
                  : () => widget.onEditStep!(rows[i].step),
            ),
          );
        }),

        const SizedBox(height: 18),
        // Opt-in review (moved here from Settings). Built-in rules flag
        // cross-step contradictions; when the AI is set up it adds an optional
        // AI review (gaps + things to double-check) on the same screen.
        const SectionLabel('Optional check'),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                context.push(AppRoutes.aiCheckRoute(widget.directiveId)),
            icon: const Icon(Icons.fact_check_outlined, size: 18),
            label: const Text('Run a consistency check'),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Scans your answers for cross-step contradictions (e.g. an agent-'
          'consent that conflicts with an avoid list), and — if the AI is set '
          'up — adds an optional AI review of gaps to double-check. Optional; '
          'you can sign without it.',
          style: TextStyle(
            fontFamily: kSansFamily,
            fontSize: 12,
            height: 1.4,
            color: p.textMuted,
          ),
        ),

        const SizedBox(height: 16),

        // Ready-to-sign call-to-action card (preserved from legacy layout).
        _CalloutCard(
          variant: _CalloutVariant.primary,
          title: 'Ready to sign?',
          body: 'Review all sections above. When satisfied, tap '
              'Preview to continue to signing and dating the directive.',
        ),
        const SizedBox(height: 12),

        // FACTUAL_ANALYSIS C6 / F15+F18 — providers SHALL comply with the
        // directive (§ 5804 compliance; § 5842 duties toward agent decisions
        // — § 5837 is agent REMOVAL; corrected 2026-07-11 legal audit), but a
        // provider may decline to follow specific instructions that are
        // against accepted medical practice or when the provider is not
        // physically available. Surfacing this here sets accurate
        // expectations before signing.
        const _CalloutCard(
          variant: _CalloutVariant.surface,
          icon: Icons.info_outline,
          richBody: TextSpan(
            children: [
              TextSpan(
                text: 'Providers must comply ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text:
                    'with your directive under PA Act 194 (20 Pa.C.S. §§ 5804, '
                    '5842). A provider may decline specific instructions only '
                    'if they conflict with accepted medical practice, or when '
                    'the provider is not physically available.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

/// A single numbered editorial review row.
class _ReviewRow extends StatelessWidget {
  final int number;
  final _ReviewRowData data;
  final VoidCallback? onEdit;

  const _ReviewRow({
    required this.number,
    required this.data,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.mhadPalette;
    final dark = theme.brightness == Brightness.dark;

    final ok = data.ok && data.hasContent;
    final okColor = dark
        ? SemanticColors.successTextDark
        : SemanticColors.successTextLight;
    final warnColor = dark
        ? SemanticColors.warningTextDark
        : SemanticColors.warningTextLight;

    // Build a full a11y description from every field (no data hidden from
    // screen readers even though the visible summary is collapsed to one line).
    final a11yEntries = data.nonEmpty
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    final a11yLabel = a11yEntries.isEmpty
        ? '${data.label}. No information entered.'
        : '${data.label}. $a11yEntries.';

    final content = Semantics(
      label: a11yLabel,
      button: onEdit != null,
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.border),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Serif italic numeral chip.
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.primaryTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SerifNumeral(
                value: number,
                size: 18,
                color: p.primary,
              ),
            ),
            const SizedBox(width: 12),
            // Label + one-line summary.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.hasContent ? data.summary : 'No information entered',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 12,
                      height: 1.3,
                      fontStyle:
                          data.hasContent ? FontStyle.normal : FontStyle.italic,
                      color: p.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Per-row ok / needs-attention indicator.
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                ok ? Icons.check_rounded : Icons.warning_amber_rounded,
                size: 18,
                color: ok ? okColor : warnColor,
              ),
            ),
            // Edit affordance (only when a jump callback is wired).
            if (onEdit != null) ...[
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: p.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (onEdit == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }
}

enum _CalloutVariant { primary, surface }

/// A small callout card supporting either plain body text or a styled
/// [TextSpan], with an optional leading icon. Replaces the two bespoke
/// Material `Card`s the legacy layout used for "Ready to sign?" and the
/// provider-compliance note, themed via the editorial palette.
class _CalloutCard extends StatelessWidget {
  final _CalloutVariant variant;
  final String? title;
  final String? body;
  final TextSpan? richBody;
  final IconData? icon;

  const _CalloutCard({
    required this.variant,
    this.title,
    this.body,
    this.richBody,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;

    final (bg, border, fg) = switch (variant) {
      _CalloutVariant.primary => (p.primaryLight, p.primary, p.onPrimaryLight),
      _CalloutVariant.surface => (p.surface, p.border, p.textMuted),
    };

    final children = <Widget>[];
    if (title != null) {
      children.add(Text(
        title!,
        style: TextStyle(
          fontFamily: kSansFamily,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ));
      children.add(const SizedBox(height: 6));
    }
    if (body != null) {
      children.add(Text(
        body!,
        style: TextStyle(
          fontFamily: kSansFamily,
          fontSize: 13,
          height: 1.45,
          color: fg,
        ),
      ));
    }
    if (richBody != null) {
      children.add(Text.rich(
        richBody!,
        style: TextStyle(
          fontFamily: kSansFamily,
          fontSize: 12.5,
          height: 1.45,
          color: fg,
        ),
      ));
    }

    final body0 = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.all(14),
      child: icon == null
          ? body0
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
                Expanded(child: body0),
              ],
            ),
    );
  }
}
