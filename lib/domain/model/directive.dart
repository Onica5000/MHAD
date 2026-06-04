enum FormType { combined, declaration, poa }

enum DirectiveStatus { draft, complete, expired, revoked }

enum ConsentOption { yes, no, agentDecides, conditional }

enum TreatmentFacilityPreference { noPreference, prefer, avoid }

enum AgentType { primary, alternate }

enum MedicationEntryType { exception, limitation, preferred }

/// Severity of an allergy entry. Mirrors the v2 prototype's Severity selector
/// on `ScrAllergies` (Mild / Moderate / Severe).
enum AllergySeverity { mild, moderate, severe }

/// The 11-step wizard flow per PROTOTYPE_DIFF_DECISIONS Decision 5.
/// User-overridden order: Diagnoses (6) → Medications (7) → Allergies (8)
/// so the Allergies-Severe → Medications-Avoid link runs backwards as a
/// nudge rather than a pre-fill.
enum WizardStep {
  aboutYou,
  whenItKicksIn,
  peopleITrust,
  guardianNomination,
  whereIWantCare,
  diagnoses,
  medications,
  allergies,
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
  /// Per PROTOTYPE_DIFF_DECISIONS § D.5 — Combined 11 / Declaration 9 / POA 6.
  ///
  /// Declaration omits People I trust + Guardian (no agent flow).
  /// POA drops the clinically-specific preference steps (Where I want care,
  /// Diagnoses, Medications, Allergies, Procedures & research) but KEEPS
  /// "Anything else" so the user can still write free-form context for the
  /// agent.
  List<WizardStep> get steps {
    final isPoa = this == FormType.poa;
    final isDeclaration = this == FormType.declaration;
    return [
      WizardStep.aboutYou,
      WizardStep.whenItKicksIn,
      if (hasAgentSections) WizardStep.peopleITrust,
      // Guardian: Combined + POA. Declaration omits — the document is about
      // preferences, not about who acts when a guardian is appointed.
      if (!isDeclaration) WizardStep.guardianNomination,
      // Preference-only clinical steps: Combined + Declaration. POA skips
      // these five so the agent decides what's not written.
      if (!isPoa) WizardStep.whereIWantCare,
      if (!isPoa) WizardStep.diagnoses,
      if (!isPoa) WizardStep.medications,
      if (!isPoa) WizardStep.allergies,
      if (!isPoa) WizardStep.proceduresResearch,
      // "Anything else" is included for ALL three form types — POA keeps it
      // so the user can write free-form context for the agent.
      WizardStep.anythingElse,
      WizardStep.reviewAndSign,
    ];
  }
}

extension WizardStepExt on WizardStep {
  /// Friendly, plain-language title shown in the wizard.
  String get displayName => switch (this) {
        WizardStep.aboutYou => 'About you',
        WizardStep.whenItKicksIn => 'When this kicks in',
        WizardStep.peopleITrust => 'People I trust',
        WizardStep.guardianNomination => 'If a court appoints a guardian',
        WizardStep.whereIWantCare => 'Where I want care',
        WizardStep.diagnoses => 'Diagnoses',
        WizardStep.medications => 'Medications',
        WizardStep.allergies => 'Allergies & reactions',
        WizardStep.proceduresResearch => 'Procedures & research',
        WizardStep.anythingElse => 'Anything else',
        // "Review" only — the sign step lives on its own post-wizard
        // route (SignScreen) per user direction 2026-06-04 mirroring the
        // prototype's ScrReview → ScrSign → ScrDone split.
        WizardStep.reviewAndSign => 'Review',
      };

  /// One-line subhead shown under the step title.
  String get subtitle => switch (this) {
        WizardStep.aboutYou =>
          'Just the basics so this document is uniquely yours.',
        WizardStep.whenItKicksIn =>
          "When you're considered unable to decide.",
        WizardStep.peopleITrust =>
          "They speak for you if you can't speak for yourself.",
        WizardStep.guardianNomination =>
          'Your preferred guardian, in case it ever comes to that.',
        WizardStep.whereIWantCare =>
          'Facilities I prefer, and ones I want to avoid.',
        WizardStep.diagnoses =>
          'Your conditions — helps care teams see the whole picture.',
        WizardStep.medications =>
          'What you currently take, and what you refuse during a crisis.',
        WizardStep.allergies =>
          "Drug allergies, sensitivities, past adverse reactions.",
        WizardStep.proceduresResearch =>
          'Three treatments under PA law need your explicit consent.',
        WizardStep.anythingElse =>
          'Free-form preferences not covered above.',
        WizardStep.reviewAndSign =>
          "One last look, then we'll make your signing packet.",
      };
}
