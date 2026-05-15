enum FormType { combined, declaration, poa }

enum DirectiveStatus { draft, complete, expired, revoked }

enum ConsentOption { yes, no, agentDecides, conditional }

enum TreatmentFacilityPreference { noPreference, prefer, avoid }

enum AgentType { primary, alternate }

enum MedicationEntryType { exception, limitation, preferred }

/// The new 9-step wizard flow. Each value below represents one screen the
/// user sees, with several of them composing what used to be multiple
/// separate screens (e.g. [peopleITrust] holds primary agent, alternate
/// agent, and authority limits — what used to be 3 screens).
enum WizardStep {
  aboutYou,
  whenItKicksIn,
  peopleITrust,
  guardianNomination,
  whereIWantCare,
  medications,
  proceduresResearch,
  anythingElse,
  reviewAndSign,
}

extension FormTypeExt on FormType {
  String get displayName => switch (this) {
        FormType.combined => 'Combined Declaration & Power of Attorney',
        FormType.declaration => 'Declaration Only',
        FormType.poa => 'Power of Attorney Only',
      };

  bool get hasAgentSections =>
      this == FormType.combined || this == FormType.poa;

  /// Returns the visible steps in display order for this form type.
  /// Declaration omits [WizardStep.peopleITrust] since there's no agent.
  List<WizardStep> get steps => [
        WizardStep.aboutYou,
        WizardStep.whenItKicksIn,
        if (hasAgentSections) WizardStep.peopleITrust,
        WizardStep.guardianNomination,
        WizardStep.whereIWantCare,
        WizardStep.medications,
        WizardStep.proceduresResearch,
        WizardStep.anythingElse,
        WizardStep.reviewAndSign,
      ];
}

extension WizardStepExt on WizardStep {
  /// Friendly, plain-language title shown in the wizard.
  String get displayName => switch (this) {
        WizardStep.aboutYou => 'About you',
        WizardStep.whenItKicksIn => 'When this kicks in',
        WizardStep.peopleITrust => 'People I trust',
        WizardStep.guardianNomination => 'If a court appoints a guardian',
        WizardStep.whereIWantCare => 'Where I want care',
        WizardStep.medications => 'Medications',
        WizardStep.proceduresResearch => 'Procedures & research',
        WizardStep.anythingElse => 'Anything else',
        WizardStep.reviewAndSign => 'Review & sign',
      };

  /// One-line subhead shown under the step title.
  String get subtitle => switch (this) {
        WizardStep.aboutYou =>
          'Just the basics so this document is uniquely yours.',
        WizardStep.whenItKicksIn =>
          "When you're considered unable to decide — including the conditions and any relevant diagnoses.",
        WizardStep.peopleITrust =>
          "They speak for you if you can't speak for yourself.",
        WizardStep.guardianNomination =>
          'Your preferred guardian, in case it ever comes to that.',
        WizardStep.whereIWantCare =>
          'Facilities I prefer, and ones I want to avoid.',
        WizardStep.medications =>
          "Meds I want, meds I don't, and known reactions.",
        WizardStep.proceduresResearch =>
          'Three treatments under PA law need your explicit consent.',
        WizardStep.anythingElse =>
          'Free-form preferences not covered above.',
        WizardStep.reviewAndSign =>
          'Final review and signatures — review the summary, then sign.',
      };
}
