import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
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
  final String sectionLabel;
  final String title;
  final String subtitle;
  final String helpText;
  final String stepId;
  final String infoBannerText;
  final String noTitle;
  final String noDescription;
  final String yesTitle;
  final String yesDescription;
  final String agentTitle;
  final String agentDescription;
  final String conditionalHint;

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
    sectionLabel: 'TREATMENT CONSENT',
    title: 'Electroconvulsive Therapy (ECT)',
    subtitle:
        'ECT is a psychiatric treatment in which seizures are electrically '
        'induced. State your preferences below.',
    helpText:
        'ECT can be an effective treatment for severe depression and other '
        'conditions. Under PA law, you can consent in advance, refuse in '
        'advance, or set conditions.',
    stepId: 'ect',
    infoBannerText: 'Under PA Act 194, your agent cannot consent to ECT unless '
        'you explicitly authorize it here.',
    noTitle: 'I do not consent to ECT',
    noDescription: 'ECT must not be performed on me.',
    yesTitle: 'I consent to ECT',
    yesDescription: 'My provider may perform ECT if indicated.',
    agentTitle: 'My agent will decide about ECT',
    agentDescription:
        'Authorize your agent to consent to or refuse ECT on your behalf.',
    conditionalHint:
        'e.g., only if other treatments have failed and my agent agrees',
    read: (pref) => pref.ectConsent,
    write: (id, value) => DirectivePrefsCompanion(
        directiveId: Value(id), ectConsent: Value(value)),
  );

  static final ConsentChoiceConfig experimental = ConsentChoiceConfig(
    sectionLabel: 'RESEARCH CONSENT',
    title: 'Experimental Studies',
    subtitle:
        'State your preferences regarding participation in experimental '
        'research during mental health treatment.',
    helpText:
        'You have the right to consent to or refuse participation in '
        'experimental research. Your preferences here will guide your care '
        'team and agent.',
    stepId: 'experimentalStudies',
    infoBannerText: 'Under PA Act 194, your agent cannot consent to '
        'experimental research unless you explicitly authorize it here.',
    noTitle: 'I do not consent',
    noDescription: 'I refuse participation in experimental studies.',
    yesTitle: 'I consent to experimental studies',
    yesDescription:
        'I am willing to participate in research studies during treatment.',
    agentTitle: 'My agent will decide',
    agentDescription:
        'Authorize your agent to consent or refuse on your behalf.',
    conditionalHint: 'e.g., only non-invasive studies approved by my agent',
    read: (pref) => pref.experimentalConsent,
    write: (id, value) => DirectivePrefsCompanion(
        directiveId: Value(id), experimentalConsent: Value(value)),
  );

  static final ConsentChoiceConfig drugTrials = ConsentChoiceConfig(
    sectionLabel: 'CLINICAL TRIALS',
    title: 'Drug Trials',
    subtitle:
        'State your preferences regarding participation in clinical drug '
        'trials during mental health treatment.',
    helpText:
        'Clinical drug trials test new medications. You can consent, refuse, '
        'or set conditions for your participation.',
    stepId: 'drugTrials',
    infoBannerText: 'Under PA Act 194, your agent cannot consent to drug '
        'trials unless you explicitly authorize it here.',
    noTitle: 'I do not consent',
    noDescription: 'I refuse participation in drug trials.',
    yesTitle: 'I consent to drug trials',
    yesDescription: 'I am willing to participate in clinical drug trials.',
    agentTitle: 'My agent will decide',
    agentDescription:
        'Authorize your agent to consent or refuse on your behalf.',
    conditionalHint: 'e.g., only trials with an independent safety monitor',
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
    with WizardStepMixin {
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
          SectionLabel(c.sectionLabel),
          const SizedBox(height: 6),
          Text(c.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            c.subtitle,
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
            text: c.infoBannerText,
          ),
          const SizedBox(height: 8),
          WizardHelpButton(helpText: c.helpText, stepId: c.stepId),
          const SizedBox(height: 16),
          ConsentOptionTile(
            icon: Icons.block,
            title: c.noTitle,
            description: c.noDescription,
            selected: _consent == ConsentOption.no,
            onTap: () => setState(() => _consent = ConsentOption.no),
          ),
          ConsentOptionTile(
            icon: Icons.check_circle_outline,
            title: c.yesTitle,
            description: c.yesDescription,
            selected: _consent == ConsentOption.yes,
            onTap: () => setState(() => _consent = ConsentOption.yes),
          ),
          ConsentOptionTile(
            icon: Icons.rule,
            title: 'I consent under specific conditions',
            description: 'Describe the conditions in the box below.',
            selected: _consent == ConsentOption.conditional,
            onTap: () =>
                setState(() => _consent = ConsentOption.conditional),
          ),
          if (_hasAgentSections)
            ConsentOptionTile(
              icon: Icons.person_outline,
              title: c.agentTitle,
              description: c.agentDescription,
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
                labelText: 'Conditions',
                hintText: c.conditionalHint,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
          ],
        ],
      ),
    );
  }
}
