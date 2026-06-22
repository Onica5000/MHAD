enum FormType { combined, declaration, poa }

enum DirectiveStatus { draft, complete, expired, revoked }

enum ConsentOption { yes, no, agentDecides, conditional }

enum TreatmentFacilityPreference { noPreference, prefer, avoid }

enum AgentType { primary, alternate }

// `current` = informational "medications I'm currently taking" (not a legal
// preference). exception/limitation/preferred are the Act-194 med preferences.
enum MedicationEntryType { current, exception, limitation, preferred }

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

/// Parse a stored form-type name (e.g. 'combined') to a [FormType], or null
/// if unrecognized. Lets string-keyed call sites reuse the label getters.
FormType? formTypeFromName(String? name) {
  for (final t in FormType.values) {
    if (t.name == name) return t;
  }
  return null;
}

extension FormTypeExt on FormType {
  String get displayName => switch (this) {
        FormType.combined => 'Combined Declaration & Power of Attorney',
        FormType.declaration => 'Declaration Only',
        FormType.poa => 'Power of Attorney Only',
      };

  /// Short label for chips / context lines where [displayName] is too long.
  /// Previously forked into "Combined form" / "Combined" / etc.
  String get shortName => switch (this) {
        FormType.combined => 'Combined',
        FormType.declaration => 'Declaration',
        FormType.poa => 'Power of Attorney',
      };

  bool get hasAgentSections =>
      this == FormType.combined || this == FormType.poa;

  /// Returns the visible steps in display order for this form type.
  /// Combined 11 / Declaration 9 / POA 5.
  ///
  /// Declaration omits People I trust + Guardian (no agent flow).
  /// POA drops the clinically-specific preference steps (Where I want care,
  /// Diagnoses, Medications, Allergies, Procedures & research) AND "Anything
  /// else" — the POA is purely about appointing the agent, who then decides
  /// what isn't written.
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
      // Allergies BEFORE medications (artboard order). Allergies and the
      // medications "never want" list are independent sections — neither
      // cross-fills the other.
      if (!isPoa) WizardStep.allergies,
      if (!isPoa) WizardStep.medications,
      if (!isPoa) WizardStep.proceduresResearch,
      // "Anything else" free-form step: Declaration + Combined only. POA omits
      // it — that form is purely about appointing the agent.
      if (!isPoa) WizardStep.anythingElse,
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

  /// One-line subhead shown under the step title. Two-sentence copy matches
  /// the design artboard's `WebWiz*` / `WebHealthShell` subtitles verbatim
  /// (earlier builds shipped only the first clause of each).
  String get subtitle => switch (this) {
        WizardStep.aboutYou =>
          'Just the basics so this document is uniquely yours. Drop a photo '
              "of your ID and we'll read these for you.",
        WizardStep.whenItKicksIn =>
          'The conditions under which your directive becomes active. You can '
              'pick more than one.',
        WizardStep.peopleITrust =>
          "They speak for you if you can't. You can name a primary, an "
              'alternate, and set limits on what they decide.',
        WizardStep.guardianNomination =>
          'Rare, but worth planning for. A guardian is named by a court — '
              'not by you — and has broader authority than an agent.',
        WizardStep.whereIWantCare =>
          'Facilities you prefer — and any you specifically want to avoid — '
              'plus room and environment preferences.',
        WizardStep.diagnoses =>
          'Help your care team see the whole picture in a crisis. Search by '
              'name — we attach the ICD-10 code your doctors use.',
        WizardStep.medications =>
          'What you take now (for your care team) plus the medications you '
              'refuse, limit, or prefer. Your refusals and limits are binding '
              'under Act 194.',
        WizardStep.allergies =>
          'Drug allergies, sensitivities, past adverse reactions. This is the '
              'most-checked section by ER staff.',
        WizardStep.proceduresResearch =>
          'Three treatments under PA law need your explicit consent. Set each '
              'one — your agent fills any gaps.',
        WizardStep.anythingElse =>
          'Free-form preferences not covered above. This is your voice — '
              "write it how you'd say it.",
        WizardStep.reviewAndSign =>
          "One last look, then we'll make your signing packet. Tap any "
              'section to edit.',
      };
}
