/// The "Getting ready" checklist — ONE definition, shared by the page
/// (`/getting-ready`) and its printable PDF (user, 2026-11-22).
///
/// In priority order: what makes the directive VALID (facts only from the
/// legal canon and the booklet text in Learn: faq_valid, combined_execution,
/// faq_finding_witnesses), then what to GATHER in the wizard's own step order
/// (each item names its step), then what to do AFTER signing.
library;

import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/l10n/model_labels.dart';

enum GettingReadyTier { valid, gather, after }

class GettingReadyItem {
  const GettingReadyItem(this.id, this.text, {this.forms = _allForms, this.step});

  /// Stable id (tick state, tests).
  final String id;
  final String text;

  /// The forms this item applies to.
  final Set<FormType> forms;

  /// The wizard step where it is entered, for "In the app: …".
  final WizardStep? step;
}

const _allForms = {FormType.combined, FormType.declaration, FormType.poa};
const _agentForms = {FormType.combined, FormType.poa};
const _preferenceForms = {FormType.combined, FormType.declaration};

/// The checklist in the language of [l], for [form] (null = every form).
class GettingReadyChecklist {
  const GettingReadyChecklist(this.l, {this.form});

  final AppLocalizations l;
  final FormType? form;

  String get formNote =>
      form == null ? l.gettingReadyAllForms : l.gettingReadyForForm(form!.label(l));

  String tierTitle(GettingReadyTier t) => switch (t) {
        GettingReadyTier.valid => l.gettingReadyTierValid,
        GettingReadyTier.gather => l.gettingReadyTierGather,
        GettingReadyTier.after => l.gettingReadyTierAfter,
      };

  String tierLead(GettingReadyTier t) => switch (t) {
        GettingReadyTier.valid => l.gettingReadyTierValidLead,
        GettingReadyTier.gather => l.gettingReadyTierGatherLead,
        GettingReadyTier.after => l.gettingReadyTierAfterLead,
      };

  List<GettingReadyItem> allItems(GettingReadyTier t) => switch (t) {
        GettingReadyTier.valid => [
            GettingReadyItem('valid-age', l.grValidAge),
            GettingReadyItem('valid-status', l.grValidStatus),
            GettingReadyItem('valid-choices', l.grValidChoices),
            GettingReadyItem('valid-sign', l.grValidSign),
            GettingReadyItem('valid-witnesses', l.grValidWitnesses),
            GettingReadyItem('valid-witness-who', l.grValidWitnessWho),
            GettingReadyItem('valid-agent', l.grValidAgent, forms: _agentForms),
          ],
        GettingReadyTier.gather => [
            GettingReadyItem('about-you', l.grGatherAboutYou, step: WizardStep.aboutYou),
            GettingReadyItem('when', l.grGatherWhen, step: WizardStep.whenItKicksIn),
            GettingReadyItem('agent', l.grGatherAgent,
                forms: _agentForms, step: WizardStep.peopleITrust),
            GettingReadyItem('authority', l.grGatherAuthority,
                forms: _agentForms, step: WizardStep.peopleITrust),
            GettingReadyItem('guardian', l.grGatherGuardian,
                step: WizardStep.guardianNomination),
            GettingReadyItem('care', l.grGatherCare,
                forms: _preferenceForms, step: WizardStep.whereIWantCare),
            GettingReadyItem('diagnoses', l.grGatherDiagnoses,
                forms: _preferenceForms, step: WizardStep.diagnoses),
            GettingReadyItem('allergies', l.grGatherAllergies,
                forms: _preferenceForms, step: WizardStep.allergies),
            GettingReadyItem('meds', l.grGatherMeds,
                forms: _preferenceForms, step: WizardStep.medications),
            GettingReadyItem('procedures', l.grGatherProcedures,
                forms: _preferenceForms, step: WizardStep.proceduresResearch),
            GettingReadyItem('procedures-poa', l.grGatherProceduresPoa,
                forms: const {FormType.poa}, step: WizardStep.proceduresResearch),
            GettingReadyItem('else', l.grGatherElse,
                forms: _preferenceForms, step: WizardStep.anythingElse),
            GettingReadyItem('capacity-letter', l.grGatherCapacityLetter),
          ],
        GettingReadyTier.after => [
            GettingReadyItem('copies', l.grAfterCopies),
            GettingReadyItem('keep', l.grAfterKeep),
            GettingReadyItem('expiry', l.grAfterExpiry),
            GettingReadyItem('revoke', l.grAfterRevoke),
          ],
      };

  /// The items for [form] (every item when the form isn't known).
  List<GettingReadyItem> items(GettingReadyTier t) => [
        for (final i in allItems(t))
          if (form == null || i.forms.contains(form)) i,
      ];

  /// "In the app: Step 3 of 11 · People I trust" for a gather item.
  String? stepTag(GettingReadyItem i) {
    if (i.step == null) return null;
    final steps = (form ?? FormType.combined).steps;
    final n = steps.indexOf(i.step!);
    final where = n < 0
        ? i.step!.title(l)
        : '${l.stepDotsStepOf(n + 1, steps.length)} · ${i.step!.title(l)}';
    return l.gettingReadyStepTag(where);
  }

  /// Which forms an item is for — only when the form isn't known.
  String? formsTag(GettingReadyItem i) {
    if (form != null || i.forms.length == _allForms.length) return null;
    if (i.forms.length == 1) return i.forms.single.label(l);
    return i.forms.contains(FormType.poa)
        ? l.gettingReadyFormsAgent
        : l.gettingReadyFormsPreferences;
  }
}
