import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/wizard/widgets/consent_option_tile.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';

/// Per-treatment configuration for [ConsentChoiceStep]. Collapses the formerly
/// near-identical EctStep / ExperimentalStudiesStep / DrugTrialsStep (~195 lines
/// each) into one widget + three configs. The [read]/[write] callbacks bind
/// each instance to its own preference column.
class ConsentChoiceConfig {
  final String Function(AppLocalizations l) sectionLabel;
  final String Function(AppLocalizations l) title;
  final String Function(AppLocalizations l) subtitle;
  final String Function(AppLocalizations l) helpText;
  final String stepId;
  final String Function(AppLocalizations l) infoBannerText;
  final String Function(AppLocalizations l) noTitle;
  final String Function(AppLocalizations l) noDescription;
  final String Function(AppLocalizations l) yesTitle;
  final String Function(AppLocalizations l) yesDescription;
  final String Function(AppLocalizations l) agentTitle;
  final String Function(AppLocalizations l) agentDescription;
  final String Function(AppLocalizations l) conditionalHint;

  /// Read this treatment's stored consent string from the prefs row.
  final String Function(DirectivePref pref) read;

  /// Build the prefs companion that writes [value] to this treatment's column.
  final DirectivePrefsCompanion Function(int directiveId, String value) write;

  const ConsentChoiceConfig({
    required this.sectionLabel,
    required this.title,
    required this.subtitle,
    required this.helpText,
    required this.stepId,
    required this.infoBannerText,
    required this.noTitle,
    required this.noDescription,
    required this.yesTitle,
    required this.yesDescription,
    required this.agentTitle,
    required this.agentDescription,
    required this.conditionalHint,
    required this.read,
    required this.write,
  });

  static final ConsentChoiceConfig ect = ConsentChoiceConfig(
    sectionLabel: (l) => l.consentChoiceEctSectionLabel,
    title: (l) => l.consentChoiceEctTitle,
    subtitle: (l) => l.consentChoiceEctSubtitle,
    helpText: (l) => l.consentChoiceEctHelpText,
    stepId: 'ect',
    infoBannerText: (l) => l.consentChoiceEctInfoBannerText,
    noTitle: (l) => l.consentChoiceEctNoTitle,
    noDescription: (l) => l.consentChoiceEctNoDescription,
    yesTitle: (l) => l.consentChoiceEctYesTitle,
    yesDescription: (l) => l.consentChoiceEctYesDescription,
    agentTitle: (l) => l.consentChoiceEctAgentTitle,
    agentDescription: (l) => l.consentChoiceEctAgentDescription,
    conditionalHint: (l) => l.consentChoiceEctConditionalHint,
    read: (pref) => pref.ectConsent,
    write: (id, value) => DirectivePrefsCompanion(
        directiveId: Value(id), ectConsent: Value(value)),
  );

  static final ConsentChoiceConfig experimental = ConsentChoiceConfig(
    sectionLabel: (l) => l.consentChoiceExperimentalSectionLabel,
    title: (l) => l.consentChoiceExperimentalTitle,
    subtitle: (l) => l.consentChoiceExperimentalSubtitle,
    helpText: (l) => l.consentChoiceExperimentalHelpText,
    stepId: 'experimentalStudies',
    infoBannerText: (l) => l.consentChoiceExperimentalInfoBannerText,
    noTitle: (l) => l.consentChoiceNoConsentTitle,
    noDescription: (l) => l.consentChoiceExperimentalNoDescription,
    yesTitle: (l) => l.consentChoiceExperimentalYesTitle,
    yesDescription: (l) => l.consentChoiceExperimentalYesDescription,
    agentTitle: (l) => l.consentChoiceAgentDecidesTitle,
    agentDescription: (l) => l.consentChoiceAgentDecidesDescription,
    conditionalHint: (l) => l.consentChoiceExperimentalConditionalHint,
    read: (pref) => pref.experimentalConsent,
    write: (id, value) => DirectivePrefsCompanion(
        directiveId: Value(id), experimentalConsent: Value(value)),
  );

  static final ConsentChoiceConfig drugTrials = ConsentChoiceConfig(
    sectionLabel: (l) => l.consentChoiceDrugTrialsSectionLabel,
    title: (l) => l.consentChoiceDrugTrialsTitle,
    subtitle: (l) => l.consentChoiceDrugTrialsSubtitle,
    helpText: (l) => l.consentChoiceDrugTrialsHelpText,
    stepId: 'drugTrials',
    infoBannerText: (l) => l.consentChoiceDrugTrialsInfoBannerText,
    noTitle: (l) => l.consentChoiceNoConsentTitle,
    noDescription: (l) => l.consentChoiceDrugTrialsNoDescription,
    yesTitle: (l) => l.consentChoiceDrugTrialsYesTitle,
    yesDescription: (l) => l.consentChoiceDrugTrialsYesDescription,
    agentTitle: (l) => l.consentChoiceAgentDecidesTitle,
    agentDescription: (l) => l.consentChoiceAgentDecidesDescription,
    conditionalHint: (l) => l.consentChoiceDrugTrialsConditionalHint,
    read: (pref) => pref.drugTrialConsent,
    write: (id, value) => DirectivePrefsCompanion(
        directiveId: Value(id), drugTrialConsent: Value(value)),
  );
}

/// One advance-consent decision (no / yes / conditional / agent-decides) for a
/// statutorily-gated treatment. Behaviour is identical to the former three
/// per-treatment steps; copy + the bound preference column come from [config].
class ConsentChoiceStep extends ConsumerStatefulWidget {
  const ConsentChoiceStep({
    required this.directiveId,
    required this.config,
    this.embedded = false,
    super.key,
  });

  final int directiveId;
  final ConsentChoiceConfig config;
  final bool embedded;

  @override
  ConsumerState<ConsentChoiceStep> createState() => _ConsentChoiceStepState();
}

class _ConsentChoiceStepState extends ConsumerState<ConsentChoiceStep>
    with WizardStepMixin, WizardStepLoadGuard {
  final _formKey = GlobalKey<FormState>();
  ConsentOption _consent = ConsentOption.no;
  final _conditionsCtrl = TextEditingController();
  bool _hasAgentSections = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _conditionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(directiveRepositoryProvider);
    final directive = await repo.getDirectiveById(widget.directiveId);
    final pref = await repo.getPreferences(widget.directiveId);
    markLoaded();

    if (!mounted) return;
    setState(() {
      if (directive != null) {
        final formType = FormType.values.firstWhere(
          (e) => e.name == directive.formType,
          orElse: () => FormType.declaration,
        );
        _hasAgentSections = formType.hasAgentSections;
      }

      if (pref != null) {
        final raw = widget.config.read(pref);
        if (raw.startsWith(consentConditionalPrefix)) {
          _consent = ConsentOption.conditional;
          _conditionsCtrl.text =
              raw.substring(consentConditionalPrefix.length);
        } else {
          _consent = ConsentOption.values.firstWhere(
            (e) => e.name == raw,
            orElse: () => ConsentOption.no,
          );
        }
      }
    });
  }

  @override
  Future<bool> validateAndSave() async {
    if (!isLoaded) return true; // don't reset the consent choice before load
    _formKey.currentState?.validate();

    final String consentValue;
    if (_consent == ConsentOption.conditional) {
      consentValue = 'conditional:${_conditionsCtrl.text.trim()}';
    } else {
      consentValue = _consent.name;
    }

    await ref
        .read(directiveRepositoryProvider)
        .upsertPreferences(widget.config.write(widget.directiveId, consentValue));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final c = widget.config;
    final l = context.l10n;

    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: widget.embedded,
        physics:
            widget.embedded ? const NeverScrollableScrollPhysics() : null,
        padding: widget.embedded
            ? const EdgeInsets.symmetric(horizontal: 4)
            : const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          SectionLabel(c.sectionLabel(l)),
          const SizedBox(height: 6),
          Text(c.title(l), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            c.subtitle(l),
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 13,
              color: p.textMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          InfoBanner(
            icon: Icons.gavel_outlined,
            variant: InfoBannerVariant.warning,
            text: c.infoBannerText(l),
          ),
          const SizedBox(height: 8),
          WizardHelpButton(helpText: c.helpText(l), stepId: c.stepId),
          const SizedBox(height: 16),
          ConsentOptionTile(
            icon: Icons.block,
            title: c.noTitle(l),
            description: c.noDescription(l),
            selected: _consent == ConsentOption.no,
            onTap: () => setState(() => _consent = ConsentOption.no),
          ),
          ConsentOptionTile(
            icon: Icons.check_circle_outline,
            title: c.yesTitle(l),
            description: c.yesDescription(l),
            selected: _consent == ConsentOption.yes,
            onTap: () => setState(() => _consent = ConsentOption.yes),
          ),
          ConsentOptionTile(
            icon: Icons.rule,
            title: l.consentChoiceConditionalTitle,
            description: l.consentChoiceConditionalDescription,
            selected: _consent == ConsentOption.conditional,
            onTap: () =>
                setState(() => _consent = ConsentOption.conditional),
          ),
          if (_hasAgentSections)
            ConsentOptionTile(
              icon: Icons.person_outline,
              title: c.agentTitle(l),
              description: c.agentDescription(l),
              selected: _consent == ConsentOption.agentDecides,
              onTap: () =>
                  setState(() => _consent = ConsentOption.agentDecides),
            ),
          if (_consent == ConsentOption.conditional) ...[
            const SizedBox(height: 6),
            TextFormField(
              controller: _conditionsCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l.consentChoiceConditionsLabel,
                hintText: c.conditionalHint(l),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.required : null,
            ),
          ],
        ],
      ),
    );
  }
}
