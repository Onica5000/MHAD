/// The voice questionnaire — a read-aloud script for recording what autofill
/// turns into the directive. ONE definition, shared by the in-app page
/// (`/audio-guide`) and its printable PDF.
///
/// It runs alongside the web app (user, 2026-11-22): one section per wizard
/// step, in the SAME order with the SAME titles ([WizardStepL10n.title]), and
/// every prompt quotes the step's own labels and hints, so a renamed field
/// renames its prompt too. Sections follow the person's form
/// ([FormType.steps]); without a form every section shows, tagged with the
/// forms it is on. It is recorded in three parts — one recording, one
/// autofill run each — instead of a clip per section.
///
/// Every prompt names the autofill keys it asks for ([AudioQPrompt.keys]);
/// `audio_questionnaire_test` checks that every key the autofill prompt can
/// fill is asked for somewhere.
library;

import 'package:mhad/data/app_data/app_data.dart' show appData;
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/l10n/model_labels.dart';

/// One recording = one part = one autofill run.
enum AudioQPart { you, care, more }

class AudioQPrompt {
  const AudioQPrompt(this.text, [this.keys = const []]);

  /// What to say, in the app's language.
  final String text;

  /// The autofill keys this prompt asks for (document_extractor's answer
  /// keys; personal details as `personal_info.<key>`).
  final List<String> keys;
}

class AudioQSection {
  const AudioQSection({
    required this.title,
    required this.part,
    required this.forms,
    required this.prompts,
    this.step,
    this.example,
    this.note,
  });

  /// The wizard step this section mirrors; null for the crisis plan, which
  /// is its own page.
  final WizardStep? step;
  final String title;
  final AudioQPart part;

  /// The forms this section is on (the step's own forms).
  final Set<FormType> forms;
  final List<AudioQPrompt> prompts;

  /// How it might sound — marked "don't read this aloud".
  final String? example;
  final String? note;
}

const _allForms = {FormType.combined, FormType.declaration, FormType.poa};
const _agentForms = {FormType.combined, FormType.poa};
const _preferenceForms = {FormType.combined, FormType.declaration};

/// The questionnaire in the language of [l], for [form] (null = every form).
class AudioQuestionnaire {
  const AudioQuestionnaire(this.l, {this.form});

  final AppLocalizations l;
  final FormType? form;

  String get title => l.audioQTitle;

  /// How to record, for the AI path in view, then the speaking tips.
  String get intro =>
      '${appData.ai.apiModeVisible ? l.audioQIntroApi : l.audioQIntroHandoff}'
      '\n\n${l.audioQIntroTips}';

  /// Says whether the list follows the person's form.
  String get formNote =>
      form == null ? l.audioQAllForms : l.audioQForForm(form!.label(l));

  /// Agent options show unless the form is known to have no agent.
  bool get _agent => form?.hasAgentSections ?? true;

  String _q(String label) => '“$label”';

  List<AudioQSection> get allSections => [
        AudioQSection(
          step: WizardStep.aboutYou,
          title: WizardStep.aboutYou.title(l),
          part: AudioQPart.you,
          forms: _allForms,
          prompts: [
            AudioQPrompt(l.audioQAboutName, ['personal_info.full_name']),
            AudioQPrompt(l.audioQAboutDob, ['personal_info.date_of_birth']),
            AudioQPrompt(l.audioQAboutAddress, [
              'personal_info.address_line1',
              'personal_info.address_line2',
              'personal_info.city',
              'personal_info.county',
              'personal_info.state',
              'personal_info.zip',
            ]),
            AudioQPrompt(l.audioQAboutPhone, ['personal_info.phone']),
          ],
          example: l.audioQAboutExample,
        ),
        AudioQSection(
          step: WizardStep.whenItKicksIn,
          title: WizardStep.whenItKicksIn.title(l),
          part: AudioQPart.you,
          forms: _allForms,
          prompts: [
            AudioQPrompt(
                l.audioQWhenTriggers(l.effCondTriggerTwoTitle,
                    l.effCondTriggerCourtTitle, l.effCondTriggerCommitTitle),
                const [
                  'trigger_two_professionals',
                  'trigger_court_order',
                  'trigger_involuntary_commitment',
                ]),
            AudioQPrompt(l.audioQWhenOwnWords, const ['effective_condition']),
            AudioQPrompt(l.audioQWhenDoctor, const [
              'personal_info.preferred_evaluating_doctor_name',
              'personal_info.preferred_evaluating_doctor_contact',
            ]),
          ],
          note: form == FormType.poa ? null : l.audioQWhenNote,
        ),
        AudioQSection(
          step: WizardStep.peopleITrust,
          title: WizardStep.peopleITrust.title(l),
          part: AudioQPart.you,
          forms: _agentForms,
          prompts: [
            AudioQPrompt(l.audioQAgent, const ['personal_info.agent']),
            AudioQPrompt(l.audioQAlternate, const ['personal_info.alternate_agent']),
            AudioQPrompt(l.audioQAgentMeds(l.agentAuthMedication),
                const ['agent_can_consent_medication']),
            AudioQPrompt(l.audioQAgentLimits, const ['agent_authority_limitations']),
          ],
          example: l.audioQAgentExample,
          note: l.audioQAgentNote,
        ),
        AudioQSection(
          step: WizardStep.guardianNomination,
          title: WizardStep.guardianNomination.title(l),
          part: AudioQPart.you,
          forms: _allForms,
          prompts: [
            AudioQPrompt(
                _agent
                    ? l.audioQGuardianWho(l.guardianNomSameAsPrimary,
                        l.guardianNomSameAsAlternate, l.guardianNomNoPreference)
                    : l.audioQGuardianWhoNoAgent(l.guardianNomNoPreference),
                const ['personal_info.guardian']),
            AudioQPrompt(l.audioQGuardianOverride(l.guardianNomCanOverride),
                const ['guardian_can_revoke', 'guardian_can_revoke_note']),
          ],
        ),
        AudioQSection(
          step: WizardStep.whereIWantCare,
          title: WizardStep.whereIWantCare.title(l),
          part: AudioQPart.care,
          forms: _preferenceForms,
          prompts: [
            AudioQPrompt(l.audioQCarePrefer(l.facilityPreferredTitle),
                const ['preferred_facility']),
            AudioQPrompt(l.audioQCareAvoid(l.facilityAvoidTitle),
                const ['avoid_facility']),
            AudioQPrompt(
                l.audioQCareRoom([
                  l.facilityRoomSingle,
                  l.facilityRoomWindow,
                  l.facilityRoomQuietFloor,
                  l.facilityRoomLowStimulation,
                  l.facilityRoomNoRoommate,
                  l.facilityRoomTransAffirming,
                  l.facilityRoomSameGender,
                ].map(_q).join(', ')),
                const ['room_preference_chips', 'same_gender_roommate']),
            AudioQPrompt(
                l.audioQCareRoommateMatch(l.facilityRoommateWomen,
                    l.facilityRoommateMen, l.facilityRoommateSameAsIdentity),
                const ['roommate_gender_match']),
            AudioQPrompt(l.audioQCareRoomOther(l.facilityOtherRoomPrefsLabel),
                const ['room_preferences_note']),
          ],
        ),
        AudioQSection(
          step: WizardStep.diagnoses,
          title: WizardStep.diagnoses.title(l),
          part: AudioQPart.care,
          forms: _preferenceForms,
          prompts: [
            AudioQPrompt(l.audioQDiagList, const ['diagnoses']),
            AudioQPrompt(l.audioQDiagDoctor, const [
              'personal_info.primary_doctor_name',
              'personal_info.primary_doctor_specialty',
              'personal_info.primary_doctor_phone',
            ]),
          ],
          example: l.audioQDiagExample,
        ),
        AudioQSection(
          step: WizardStep.allergies,
          title: WizardStep.allergies.title(l),
          part: AudioQPart.care,
          forms: _preferenceForms,
          prompts: [
            AudioQPrompt(
                l.audioQAllergyEach(
                    l.allergiesKindDrug,
                    l.allergiesKindFood,
                    l.allergiesKindMaterial,
                    l.allergiesSeverityMild,
                    l.allergiesSeverityModerate,
                    l.allergiesSeveritySevere),
                const ['allergies']),
          ],
          example: l.audioQAllergyExample,
        ),
        AudioQSection(
          step: WizardStep.medications,
          title: WizardStep.medications.title(l),
          part: AudioQPart.care,
          forms: _preferenceForms,
          prompts: [
            AudioQPrompt(l.audioQMedsCurrent(l.medsStepCurrentTitle),
                const ['medications_current']),
            AudioQPrompt(l.audioQMedsPreferred(l.medsStepPreferredTitle),
                const ['medications_preferred']),
            AudioQPrompt(l.audioQMedsNever(l.medsStepNeverTitle),
                const ['medications_to_avoid']),
            AudioQPrompt(l.audioQMedsLimit(l.medsStepLimitTitle),
                const ['medications_limited']),
            AudioQPrompt(
                _agent
                    ? l.audioQMedsConsent(l.medsConsentYes, l.medsStepAgentDecides,
                        l.medsConsentNo)
                    : l.audioQMedsConsentNoAgent(l.medsConsentYes, l.medsConsentNo),
                const ['medication_consent']),
          ],
          example: l.audioQMedsExample,
          note: l.audioQMedsNote,
        ),
        AudioQSection(
          step: WizardStep.proceduresResearch,
          title: WizardStep.proceduresResearch.title(l),
          part: AudioQPart.care,
          forms: _allForms,
          prompts: [
            AudioQPrompt(
                form == FormType.poa
                    ? l.audioQProcEachPoa
                    : _agent
                    ? l.audioQProcEach(
                        l.consentChoiceConsentTitle,
                        l.consentChoiceNoConsentTitle,
                        l.consentChoiceAgentDecidesTitle,
                        l.consentChoiceConditionalTitle)
                    : l.audioQProcEachNoAgent(l.consentChoiceConsentTitle,
                        l.consentChoiceNoConsentTitle, l.consentChoiceConditionalTitle),
                const ['ect_consent', 'experimental_consent', 'drug_trial_consent']),
          ],
          example: form == FormType.poa
              ? l.audioQProcExamplePoa
              : _agent
                  ? l.audioQProcExample
                  : l.audioQProcExampleNoAgent,
          note: form == FormType.poa
              ? l.audioQProcNotePoa
              : _agent
                  ? l.audioQProcNote
                  : null,
        ),
        AudioQSection(
          step: WizardStep.anythingElse,
          title: WizardStep.anythingElse.title(l),
          part: AudioQPart.more,
          forms: _preferenceForms,
          prompts: [
            AudioQPrompt(l.audioQElseLead),
            AudioQPrompt(
                l.audioQLabeled(l.addlInstrActivitiesTitle, l.addlInstrActivitiesHint),
                const ['activities']),
            AudioQPrompt(l.audioQLabeled(l.reviewLabelCrisis, l.addlInstrCrisisHint),
                const ['crisis_intervention']),
            AudioQPrompt(l.audioQLabeled(l.addlInstrDeescTitle, l.addlInstrDeescHint),
                const ['crisis_intervention']),
            AudioQPrompt(
                l.audioQLabeled(l.addlInstrTriggersTitle, l.addlInstrTriggersHint),
                const ['crisis_plan']),
            AudioQPrompt(l.audioQLabeled(l.reviewLabelHh, l.addlInstrHealthHistoryHint),
                const ['health_history']),
            AudioQPrompt(l.audioQLabeled(l.addlInstrDietaryTitle, l.addlInstrDietaryHint),
                const ['dietary']),
            AudioQPrompt(
                l.audioQLabeled(l.addlInstrReligiousTitle, l.addlInstrReligiousHint),
                const ['religious']),
            AudioQPrompt(
                l.audioQLabeled(l.addlInstrChildrenTitle, l.addlInstrChildrenHint),
                const ['children_custody']),
            AudioQPrompt(
                l.audioQLabeled(l.addlInstrFamilyNotifyTitle, l.addlInstrFamilyNotifyHint),
                const ['family_notification']),
            AudioQPrompt(
                l.audioQRecords(
                    l.addlInstrRecordsTitle,
                    l.addlInstrRecordsReleaseLabel,
                    l.addlInstrRecordsWithholdLabel,
                    l.addlInstrRecordsOtherLabel),
                const ['records_authorized', 'records_not_authorized', 'records_disclosure']),
            AudioQPrompt(l.audioQLabeled(l.reviewStepPetCare, l.addlInstrPetCareHint),
                const ['pet_custody']),
            AudioQPrompt(l.audioQLabeled(l.addlInstrReproTitle, l.addlInstrReproHint),
                const ['reproductive_health']),
            AudioQPrompt(l.audioQLabeled(l.addlInstrOtherTitle, l.addlInstrOtherHint),
                const ['other']),
            AudioQPrompt(l.audioQUlysses(l.addlInstrUlyssesTitle),
                const ['self_binding_ulysses']),
          ],
        ),
        AudioQSection(
          title: l.tabPageCrisisPlan,
          part: AudioQPart.more,
          forms: _preferenceForms,
          prompts: [
            AudioQPrompt(
                l.audioQCrisisPlan(
                    l.crisisPlanEarlyWarningSigns,
                    l.crisisPlanTriggersToWatchFor,
                    l.crisisPlanThingsThatGenuinelyHelp,
                    l.crisisPlanThingsToSayToMe,
                    l.crisisPlanDonTDoThese),
                const ['crisis_plan']),
          ],
          note: l.audioQCrisisPlanNote,
        ),
      ];

  /// The sections for [form] (every section when the form isn't known).
  List<AudioQSection> get sections => form == null
      ? allSections
      : allSections.where((s) => s.forms.contains(form)).toList();

  /// The recordings this form needs, in order.
  List<AudioQPart> get parts => [
        for (final p in AudioQPart.values)
          if (sections.any((s) => s.part == p)) p,
      ];

  List<AudioQSection> sectionsIn(AudioQPart p) =>
      sections.where((s) => s.part == p).toList();

  String partTitle(AudioQPart p) => switch (p) {
        AudioQPart.you => l.audioQPart1Title,
        AudioQPart.care => l.audioQPart2Title,
        AudioQPart.more => l.audioQPart3Title,
      };

  String partHow(AudioQPart p) => l.audioQPartHow(p.index + 1);

  /// "Step 3 of 11" — the wizard's own numbering for the person's form
  /// (Combined when unknown); null for the crisis plan.
  String? stepLabel(AudioQSection s) {
    final steps = (form ?? FormType.combined).steps;
    final i = s.step == null ? -1 : steps.indexOf(s.step!);
    return i < 0 ? null : l.stepDotsStepOf(i + 1, steps.length);
  }

  /// Which forms a section is on — only when the form isn't known.
  String? formsLabel(AudioQSection s) {
    if (form != null || s.forms.length == _allForms.length) return null;
    return s.forms.contains(FormType.poa)
        ? l.audioQFormsAgent
        : l.audioQFormsPreferences;
  }

  /// What the recording can't fill — the person does these in the app.
  List<String> get cantDo => [
        l.audioQCantDoSignatures,
        if (_agent) l.audioQCantDoInitials,
        if (form != FormType.poa) l.audioQCantDoSideEffects,
      ];

  String get closing => l.audioQClosing;

  /// Every autofill key the questionnaire asks for.
  Set<String> get coveredKeys => {
        for (final s in allSections)
          for (final p in s.prompts) ...p.keys,
      };
}
