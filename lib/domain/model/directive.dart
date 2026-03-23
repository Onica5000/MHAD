enum FormType { combined, declaration, poa }

enum DirectiveStatus { draft, complete, expired, revoked }

enum ConsentOption { yes, no, agentDecides, conditional }

enum TreatmentFacilityPreference { noPreference, prefer, avoid }

enum AgentType { primary, alternate }

enum MedicationEntryType { exception, limitation, preferred }

enum WizardStep {
  personalInfo,
  effectiveCondition,
  treatmentFacility,
  medications,
  ect,
  experimentalStudies,
  drugTrials,
  additionalInstructions,
  agentDesignation,
  alternateAgent,
  agentAuthority,
  guardianNomination,
  review,
  execution,
}

extension FormTypeExt on FormType {
  String get displayName => switch (this) {
        FormType.combined => 'Combined Declaration & Power of Attorney',
        FormType.declaration => 'Declaration Only',
        FormType.poa => 'Power of Attorney Only',
      };

  bool get hasAgentSections =>
      this == FormType.combined || this == FormType.poa;

  List<WizardStep> get steps => [
        WizardStep.personalInfo,
        WizardStep.effectiveCondition,
        WizardStep.treatmentFacility,
        WizardStep.medications,
        WizardStep.ect,
        WizardStep.experimentalStudies,
        WizardStep.drugTrials,
        WizardStep.additionalInstructions,
        if (hasAgentSections) WizardStep.agentDesignation,
        if (hasAgentSections) WizardStep.alternateAgent,
        if (hasAgentSections) WizardStep.agentAuthority,
        WizardStep.guardianNomination,
        WizardStep.review,
        WizardStep.execution,
      ];
}

extension WizardStepExt on WizardStep {
  String get displayName => switch (this) {
        WizardStep.personalInfo => 'Personal Information',
        WizardStep.effectiveCondition => 'Effective Condition',
        WizardStep.treatmentFacility => 'Treatment Facility',
        WizardStep.medications => 'Medications',
        WizardStep.ect => 'ECT Preferences',
        WizardStep.experimentalStudies => 'Experimental Studies',
        WizardStep.drugTrials => 'Drug Trials',
        WizardStep.additionalInstructions => 'Additional Instructions',
        WizardStep.agentDesignation => 'Agent Designation',
        WizardStep.alternateAgent => 'Alternate Agent',
        WizardStep.agentAuthority => 'Agent Authority & Limits',
        WizardStep.guardianNomination => 'Guardian Nomination',
        WizardStep.review => 'Review',
        WizardStep.execution => 'Execution',
      };
}
