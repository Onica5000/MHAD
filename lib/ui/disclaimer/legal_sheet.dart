import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// The full eight-section legal disclosure, rendered two ways:
///   * [ReadOnlyAccordion] — a scrollable Scaffold used from Settings → Legal.
///   * [FullLegalSheet] — the same accordion inside the modal sheet opened
///     from the first-launch gate's "Read full disclaimer" link.
/// Both share the section data ([_buildSections]) and the [_AccordionSection]
/// expander, so the disclosure text lives in exactly one place.

// ─── Read-only accordion (Settings → Legal) ─────────────────────────────

class ReadOnlyAccordion extends StatefulWidget {
  final MhadPalette palette;
  const ReadOnlyAccordion({required this.palette, super.key});

  @override
  State<ReadOnlyAccordion> createState() => _ReadOnlyAccordionState();
}

class _ReadOnlyAccordionState extends State<ReadOnlyAccordion> {
  int _open = 0;

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final sections = _buildSections(context, p);
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      appBar: AppBar(title: Text(context.l10n.settingsLegalDisclaimer)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text(
              context.l10n.legalSheetFullLegalDisclosure,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.legalSheetTheEightSectionsBelowWere,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 13,
                color: p.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            for (int i = 0; i < sections.length; i++) ...[
              _AccordionSection(
                number: sections[i].number,
                title: sections[i].title,
                body: sections[i].body,
                expanded: _open == i,
                onTap: () =>
                    setState(() => _open = _open == i ? -1 : i),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Full-legal modal sheet (opened from gate) ──────────────────────────

class FullLegalSheet extends StatefulWidget {
  final ScrollController scrollController;
  const FullLegalSheet({required this.scrollController, super.key});

  @override
  State<FullLegalSheet> createState() => _FullLegalSheetState();
}

class _FullLegalSheetState extends State<FullLegalSheet> {
  int _open = 0;

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final sections = _buildSections(context, p);
    return Column(
      children: [
        // Drag handle
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 8),
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: p.border,
            borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.legalSheetFullLegalSections,
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                tooltip: context.l10n.close,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              for (int i = 0; i < sections.length; i++) ...[
                _AccordionSection(
                  number: sections[i].number,
                  title: sections[i].title,
                  body: sections[i].body,
                  expanded: _open == i,
                  onTap: () =>
                      setState(() => _open = _open == i ? -1 : i),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Section data (unchanged from prior implementation) ─────────────────

class _SectionData {
  final String number;
  final String title;
  final List<Widget> body;
  const _SectionData({
    required this.number,
    required this.title,
    required this.body,
  });
}

List<_SectionData> _buildSections(BuildContext context, MhadPalette p) {
  return [
    _SectionData(
      number: '01',
      title: context.l10n.legalSheetNotLegalOrMedicalAdvice,
      body: [
        _Para(spans: [
          TextSpan(
              text:
                  context.l10n.legalSheetThisAppHelpsPennsylvaniaResidents),
          _bold(context.l10n.legalSheetPaAct194Of2004),
          TextSpan(
              text:
                  context.l10n.legalSheetTheInformationIsForInformational),
          _bold(context.l10n.legalSheetBoldNot),
          TextSpan(text: context.l10n.legalSheetConstituteLegalOrMedicalAdvice),
        ], palette: p),
        _Para(spans: [
          TextSpan(
              text:
                  context.l10n.legalSheetItIsNotAMedical),
        ], palette: p),
      ],
    ),
    _SectionData(
      number: '02',
      title: context.l10n.legalSheetNoProfessionalRelationship,
      body: [
        _Para(spans: [
          TextSpan(text: context.l10n.legalSheetUseOfThisAppDoes),
          _bold(context.l10n.legalSheetBoldNot),
          TextSpan(
              text:
                  context.l10n.legalSheetCreateAnAttorneyClientRelationship),
        ], palette: p),
        _Para(spans: [
          TextSpan(
              text:
                  context.l10n.legalSheetYouAreSolelyResponsibleFor),
        ], palette: p),
      ],
    ),
    _SectionData(
      number: '03',
      title: context.l10n.legalSheetUseAtYourOwnRisk,
      body: [
        _Para(spans: [
          TextSpan(
              text:
                  context.l10n.legalSheetInPlainTermsThisApp),
        ], palette: p),
        _Para(spans: [
          TextSpan(text: context.l10n.legalSheetThisAppIsProvided),
          TextSpan(
            text: context.l10n.legalSheetAsIs,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          TextSpan(
              text:
                  context.l10n.legalSheetWithoutWarrantiesOfAnyKind),
        ], palette: p),
      ],
    ),
    _SectionData(
      number: '04',
      title: context.l10n.legalSheetRequirementsForAValidDirective,
      body: [
        _Para(spans: [
          TextSpan(
              text:
                  context.l10n.legalSheetAPaMentalHealthAdvance),
          _bold(context.l10n.legalSheetBoldOnly),
          TextSpan(text: context.l10n.legalSheetWhen),
        ], palette: p),
        _Bullet(spans: [
          TextSpan(
              text:
                  context.l10n.legalSheetYouThePrincipalHaveLegal),
        ], palette: p),
        _Bullet(spans: [
          TextSpan(text: context.l10n.legalSheetItIsSignedInThe),
          _bold(context.l10n.legalSheetBoldTwoAdultWitnesses),
        ], palette: p),
        _Bullet(spans: [
          TextSpan(
              text:
                  context.l10n.legalSheetBothWitnessesMeetEligibilityRequirements),
        ], palette: p),
        _Para(spans: [
          _bold(context.l10n.legalSheetBoldWitnessesCannotBe),
          TextSpan(
              text:
                  context.l10n.legalSheetYourDesignatedAgentOrAlternate),
        ], palette: p),
        _Para(spans: [
          TextSpan(
              text:
                  context.l10n.legalSheetThisAppCapturesTouchDrawn),
          _bold(context.l10n.legalSheetBoldPrinted),
          TextSpan(
              text:
                  context.l10n.legalSheetDirectiveMustBeSignedIn),
        ], palette: p),
        _Para(spans: [
          TextSpan(text: context.l10n.legalSheetOnceSignedProvidersAndYour),
          _bold(context.l10n.legalSheetBoldMustComply),
          TextSpan(
              text:
                  context.l10n.legalSheetWithYourDirective20Pa),
        ], palette: p),
      ],
    ),
    _SectionData(
      number: '05',
      title: context.l10n.legalSheetTwoYearValidity,
      body: [
        _Para(spans: [
          TextSpan(text: context.l10n.legalSheetUnderPaAct194An),
          _bold(context.l10n.legalSheetBoldTwoYears),
          TextSpan(
              text:
                  context.l10n.legalSheetFromTheDateOfExecution),
          _bold(context.l10n.legalSheetBoldUnlessYouAreFoundIncapable),
          TextSpan(
              text:
                  context.l10n.legalSheetOfMakingMentalHealthDecisions),
        ], palette: p),
      ],
    ),
    _SectionData(
      number: '06',
      title: context.l10n.legalSheetRevocation,
      body: [
        _Para(spans: [
          TextSpan(
              text:
                  context.l10n.legalSheetYouMayRevokeThisDirective),
        ], palette: p),
        _Bullet(spans: [
          TextSpan(
              text: context.l10n.legalSheetNotifyingYourHealthcareProviderOr),
        ], palette: p),
        _Bullet(spans: [
          TextSpan(text: context.l10n.legalSheetDestroyingTheDirective),
        ], palette: p),
        _Bullet(spans: [
          TextSpan(text: context.l10n.legalSheetExecutingANewDirective),
        ], palette: p),
        _Para(spans: [
          TextSpan(text: context.l10n.legalSheetNotifyEveryoneWhoHasCopies),
        ], palette: p),
      ],
    ),
    _SectionData(
      number: '07',
      title: context.l10n.legalSheetPrivacyAiFeatures,
      body: [
        _Para(spans: [
          TextSpan(
              text:
                  context.l10n.legalSheetThisIsAWebApp),
          _bold(context.l10n.legalSheetBoldNotSavedPermanently),
          TextSpan(
              text:
                  context.l10n.legalSheetIfYouCloseTheTab),
          _bold(context.l10n.legalSheetBoldNot),
          TextSpan(text: context.l10n.legalSheetHipaaCompliant),
        ], palette: p),
        _Para(spans: [
          TextSpan(
              text:
                  context.l10n.legalSheetIfYouUseTheOptional),
        ], palette: p),
        _Para(spans: [
          TextSpan(text: context.l10n.legalSheetToProtectYouTheApp),
          _bold(context.l10n.legalSheetBoldAutomaticallyKeepsIdentifyingDetailsOut),
          TextSpan(
              text:
                  context.l10n.legalSheetYourNameDateOfBirth),
        ], palette: p),
        _Para(spans: [
          TextSpan(
              text:
                  context.l10n.legalSheetDocumentsYouUploadForAutofill),
          _bold(context.l10n.legalSheetBoldUploadingIsNeverRequired),
          TextSpan(
              text:
                  context.l10n.legalSheetBlackOutAnythingYouDon),
        ], palette: p),
        _Para(spans: [
          TextSpan(
              text:
                  context.l10n.legalSheetSeparatelyToHelpYouFill),
          _bold(context.l10n.legalSheetBoldTheseLookupsSendOnlyThe),
          TextSpan(
              text:
                  context.l10n.legalSheetNeverYourIdentityThePeople),
        ], palette: p),
        _Para(spans: [
          TextSpan(
              text:
                  context.l10n.legalSheetAiSuggestionsAreNotLegal),
        ], palette: p),
      ],
    ),
    _SectionData(
      number: '08',
      title: context.l10n.legalSheetResourcesAssistance,
      body: [
        _Resource(
            title: context.l10n.legalSheetPaProtectionAdvocacy,
            sub: context.l10n.legalSheetYourRightsUnderAct194,
            mono:
                '${appData.phoneOf('paProtectionAdvocacy')} · TDD/TTY ${appData.contact('paProtectionAdvocacy').tdd ?? ''}',
            palette: p),
        const SizedBox(height: 10),
        _Resource(
            title: context.l10n.legalSheetPaMentalHealthConsumersAssociation,
            sub: null,
            mono: appData.phoneOf('pmhca'),
            palette: p),
        const SizedBox(height: 10),
        _Resource(
            title: context.l10n.legalSheetMentalHealthAssociationInPennsylvania,
            sub: null,
            mono: appData.phoneOf('mhapa'),
            palette: p),
        const SizedBox(height: 10),
        _Resource(
            title: context.l10n.legalSheet988SuicideCrisisLifeline,
            sub: context.l10n.legalSheet247FreeConfidential,
            mono: context.l10n.legalSheetCallOrText988,
            palette: p),
      ],
    ),
  ];
}

// ─── Building blocks (used by accordion sheet) ──────────────────────────

InlineSpan _bold(String text) => TextSpan(
      text: text,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );

class _Para extends StatelessWidget {
  final List<InlineSpan> spans;
  final MhadPalette palette;
  const _Para({required this.spans, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: spans
              .map((s) => _coloredBoldInBody(s, palette))
              .toList(growable: false),
        ),
        style: TextStyle(
          fontFamily: kSansFamily,
          fontSize: 14,
          color: palette.textMuted,
          height: 1.55,
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final List<InlineSpan> spans;
  final MhadPalette palette;
  const _Bullet({required this.spans, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 8),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: palette.textMuted,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: spans
                    .map((s) => _coloredBoldInBody(s, palette))
                    .toList(growable: false),
              ),
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 14,
                color: palette.textMuted,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InlineSpan _coloredBoldInBody(InlineSpan span, MhadPalette palette) {
  if (span is! TextSpan) return span;
  final isBold = (span.style?.fontWeight == FontWeight.w600 ||
      span.style?.fontWeight == FontWeight.bold);
  if (!isBold) return span;
  return TextSpan(
    text: span.text,
    style: (span.style ?? const TextStyle()).copyWith(color: palette.text),
    children: span.children,
  );
}

class _Resource extends StatelessWidget {
  final String title;
  final String? sub;
  final String mono;
  final MhadPalette palette;
  const _Resource({
    required this.title,
    required this.sub,
    required this.mono,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: palette.text,
                ),
              ),
              if (sub != null)
                TextSpan(
                  text: ' — $sub',
                  style: TextStyle(color: palette.textMuted),
                ),
            ],
          ),
          style: const TextStyle(
            fontFamily: kSansFamily,
            fontSize: 14,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          mono,
          style: TextStyle(
            fontFamily: kMonoFamily,
            fontFamilyFallback: const [
              'Consolas',
              'Menlo',
              'Courier New',
              'monospace'
            ],
            fontSize: 12,
            color: palette.text,
          ),
        ),
      ],
    );
  }
}

class _AccordionSection extends StatelessWidget {
  final String number;
  final String title;
  final List<Widget> body;
  final bool expanded;
  final VoidCallback onTap;

  const _AccordionSection({
    required this.number,
    required this.title,
    required this.body,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(
          color: expanded
              ? p.primary.withValues(alpha: 0.25)
              : p.border,
        ),
        borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                height: 56,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          number,
                          style: TextStyle(
                            fontFamily: 'Instrument Serif',
                            fontFamilyFallback: const ['Georgia', 'serif'],
                            fontStyle: FontStyle.italic,
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            height: 1,
                            letterSpacing: -0.5,
                            color: p.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: kSansFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                            color: p.text,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: expanded ? 0.5 : 0,
                        child: Icon(Icons.keyboard_arrow_down,
                            size: 18, color: p.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 0, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: body,
              ),
            ),
        ],
      ),
    );
  }
}
