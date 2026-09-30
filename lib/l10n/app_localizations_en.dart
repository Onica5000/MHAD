// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PA Mental Health\nAdvance Directive';

  @override
  String get navHome => 'Home';

  @override
  String get navLearn => 'Learn';

  @override
  String get navAsk => 'Ask';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMore => 'More';

  @override
  String get navStart => 'Start';

  @override
  String get navAutofill => 'Autofill';

  @override
  String get navAiAssistant => 'AI assistant';

  @override
  String get navDownloadPrint => 'Download & print';

  @override
  String get navResetForm => 'Reset Form';

  @override
  String get badgeAiReady => 'READY';

  @override
  String get badgeAiSetUp => 'SET UP';

  @override
  String get newDirective => 'New Directive';

  @override
  String get home => 'Home';

  @override
  String get education => 'Education';

  @override
  String get assistant => 'Assistant';

  @override
  String get exportDirective => 'Export Directive';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get done => 'Done';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Retry';

  @override
  String get required => 'Required';

  @override
  String get combinedForm => 'Combined Declaration & Power of Attorney';

  @override
  String get declarationOnly => 'Declaration Only';

  @override
  String get poaOnly => 'Power of Attorney Only';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get fullName => 'Full name';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get state => 'State';

  @override
  String get zipCode => 'ZIP code';

  @override
  String get phone => 'Phone number';

  @override
  String get effectiveCondition => 'Effective Condition';

  @override
  String get treatmentFacility => 'Treatment Facility';

  @override
  String get medications => 'Medications';

  @override
  String get ectPreferences => 'ECT Preferences';

  @override
  String get experimentalStudies => 'Experimental Studies';

  @override
  String get drugTrials => 'Drug Trials';

  @override
  String get additionalInstructions => 'Additional Instructions';

  @override
  String get agentDesignation => 'Agent Designation';

  @override
  String get alternateAgent => 'Alternate Agent';

  @override
  String get agentAuthority => 'Agent Authority & Limits';

  @override
  String get guardianNomination => 'Guardian Nomination';

  @override
  String get review => 'Review';

  @override
  String get execution => 'Execution';

  @override
  String get draft => 'Draft';

  @override
  String get complete => 'Complete';

  @override
  String get expired => 'Expired';

  @override
  String get revoked => 'Revoked';

  @override
  String get saveAndExit => 'Save & Exit';

  @override
  String get saveAndExitMessage =>
      'Your work isn\'t saved permanently — it stays in this browser only and is wiped when you close the tab (kept about 10 minutes for crash recovery). Export or print to keep a copy.';

  @override
  String get previewPdf => 'Preview PDF';

  @override
  String get sharePrint => 'Share / Print';

  @override
  String get generateWalletCard => 'Generate Wallet Card';

  @override
  String get importFromDocument => 'Import from Document';

  @override
  String get importFromContacts => 'Import from Contacts';

  @override
  String get seeExamples => 'See examples';

  @override
  String get aiSuggest => 'AI Suggest';

  @override
  String stepNOfTotal(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String percentComplete(int percent) {
    return '$percent% complete';
  }

  @override
  String lastEdited(String date) {
    return 'Last edited $date';
  }

  @override
  String nSections(int filled, int total) {
    return '$filled of $total sections';
  }

  @override
  String get procResearchEctLabel => 'Electroconvulsive therapy (ECT)';

  @override
  String get procResearchExperimentalLabel => 'Experimental studies';

  @override
  String get procResearchDrugTrialsLabel => 'Drug trials';

  @override
  String get procResearchWhyTheseThree =>
      'Why these three? PA Act 194 specifically calls out ECT, experimental studies, and drug trials as requiring documented consent. Other treatments fall under your general preferences.';

  @override
  String get procResearchAgentAuthority =>
      'Agent authority for these three: your agent cannot consent to ECT, experimental studies, or drug trials on your behalf unless you expressly grant that power below. Without an express grant, only you can consent — or these will not be available during incapacity.';

  @override
  String get procResearchNeverAuthorizedTitle =>
      'Never authorized under PA Act 194';

  @override
  String get procResearchNeverAuthorizedBody =>
      'By statute (20 Pa.C.S. § 5836(b)), this directive can never convey the power to consent to the following — no clause in this document and no decision by your agent can authorize them:';

  @override
  String get procResearchPsychosurgery =>
      'Psychosurgery (brain surgery meant to change mood or behavior)';

  @override
  String get procResearchParentalRights => 'Termination of parental rights';

  @override
  String get signScreenPreparing => 'Preparing signing packet';

  @override
  String get signScreenBackToReview => 'Back to review';

  @override
  String get executionHelpText =>
      'Per 20 Pa.C.S. § 5822 / § 5832, a Mental Health Advance Directive must be signed on paper by you and two adult witnesses, all present at the same time. The app cannot witness it for you — this step walks you through what to do.';

  @override
  String get executionFinalStepLabel => 'Final step · on paper';

  @override
  String get executionHeading => 'Make it legal — with a pen.';

  @override
  String get executionIntro =>
      'Pennsylvania law requires a real signature on paper. We can\'t witness it for you — but here\'s exactly what to do.';

  @override
  String get executionWhyNotAppLead => 'Why not sign in the app? ';

  @override
  String get executionWhyNotAppBody =>
      'Under Act 194 the directive is only valid when you and two adult witnesses sign the ';

  @override
  String get executionSamePaperDocument => 'same paper document';

  @override
  String get executionWhyNotAppTail =>
      ', together. A tap-to-sign wouldn\'t hold up.';

  @override
  String get executionAnyFormValid =>
      'You don’t have to use a specific form. Pennsylvania’s official forms are recommended, not required — what makes your directive valid is its content and being signed and witnessed correctly. If a facility hands you a different form, this one still counts.';

  @override
  String get executionStep1Title => 'Print the packet';

  @override
  String get executionStep1Body =>
      'Print the PDF we just made. It already has signature lines for you and two witnesses.';

  @override
  String get executionStep2Title => 'Gather two adult witnesses';

  @override
  String get executionStep2Body =>
      'Both must be 18 or older and in the room with you when you sign. (Who can’t witness is below.)';

  @override
  String get executionStep3Title => 'Everyone signs, same place, same time';

  @override
  String get executionStep3Body =>
      'Sign and date the witness page in front of both witnesses. They sign right after you, while you watch.';

  @override
  String get executionWitnessLead => 'A witness ';

  @override
  String get executionWitnessCannot => 'cannot';

  @override
  String get executionWitnessRest =>
      ' be your agent or alternate agent, your mental health care provider, or an employee of the facility where you receive treatment — unless they are related to you by blood, marriage, or adoption.';

  @override
  String get executionInYourPacket => 'In your packet';

  @override
  String get executionPacketMhadTitle => 'Your completed MHAD';

  @override
  String get executionPacketMhadSub => 'PDF · PA Act 194 format';

  @override
  String get executionPacketSignatureTitle => 'Signature & witness page';

  @override
  String get executionPacketSignatureSub =>
      'Pre-filled with your name and the date lines';

  @override
  String get executionPacketWitnessTitle => 'Witness eligibility guide';

  @override
  String get executionPacketWitnessSub => 'One page — who can and can\'t sign';

  @override
  String get executionPacketAfterTitle => 'What to do after signing';

  @override
  String get executionPacketAfterSub =>
      'Who to give copies to, how to distribute';

  @override
  String get executionPreviewPacket => 'Preview & open packet';

  @override
  String get executionNotYetValid =>
      'NOT YET VALID · BECOMES LEGAL ONCE SIGNED ON PAPER BY YOU + 2 WITNESSES';

  @override
  String get reviewStepNotProvidedYet => 'Not provided yet';

  @override
  String get reviewStepNoInfoEntered => 'No information entered';

  @override
  String reviewStepA11yNoInfo(String label) {
    return '$label. No information entered.';
  }

  @override
  String get reviewStepPrimaryAgent => 'Primary Agent';

  @override
  String get reviewStepWhereIWantCare => 'Where I want care';

  @override
  String get reviewStepMedicalDiagnoses => 'Medical Diagnoses';

  @override
  String get reviewStepAllergiesReactions => 'Allergies & reactions';

  @override
  String get reviewStepProceduresResearch => 'Procedures & research';

  @override
  String get reviewStepName => 'Name';

  @override
  String get reviewStepPhone => 'Phone';

  @override
  String get reviewStepCondition => 'Condition';

  @override
  String get reviewStepRelationship => 'Relationship';

  @override
  String get reviewStepTreatmentFacility => 'Treatment facility';

  @override
  String get reviewStepMedicationConsent => 'Medication consent';

  @override
  String get reviewStepAllergies => 'Allergies';

  @override
  String get reviewStepNeverGive => 'Never give';

  @override
  String get reviewStepWithLimits => 'With limits';

  @override
  String get reviewStepPreferred => 'Preferred';

  @override
  String get reviewStepEctConsent => 'ECT consent';

  @override
  String get reviewStepDrugTrials => 'Drug trials';

  @override
  String get reviewStepActivities => 'Activities';

  @override
  String get reviewStepCrisisIntervention => 'Crisis intervention';

  @override
  String get reviewStepHealthHistory => 'Health history';

  @override
  String get reviewStepDietary => 'Dietary';

  @override
  String get reviewStepReligious => 'Religious';

  @override
  String get reviewStepChildren => 'Children';

  @override
  String get reviewStepFamilyNotification => 'Family notification';

  @override
  String get reviewStepRecordsDisclosure => 'Records disclosure';

  @override
  String get reviewStepPetCare => 'Pet care';

  @override
  String get reviewStepOther => 'Other';

  @override
  String reviewStepWhoPhone(String who) {
    return '$who\'s phone number';
  }

  @override
  String reviewStepWhoAddress(String who) {
    return '$who\'s address';
  }

  @override
  String get reviewStepYourPrimaryAgent => 'your primary agent';

  @override
  String get reviewStepYourAlternateAgent => 'your alternate agent';

  @override
  String get reviewStepYourGuardianNominee => 'your guardian nominee';

  @override
  String get reviewStepLoading => 'Loading';

  @override
  String get reviewStepOneLastLook =>
      'One last look, then we\'ll make your signing packet.';

  @override
  String get reviewStepOneSectionNeedsAttention =>
      '1 section still needs your attention before signing.';

  @override
  String reviewStepSectionsNeedAttention(int count) {
    return '$count sections still need your attention before signing.';
  }

  @override
  String get reviewStepAllGood =>
      'Everything looks good. All sections reviewed.';

  @override
  String reviewStepOptionalGather(String items) {
    return 'Optional, but worth gathering before you sign: $items. They help your care team reach the people you named — you can still sign without them.';
  }

  @override
  String get reviewStepAtAGlance => 'Your directive at a glance';

  @override
  String get reviewStepOptionalCheck => 'Optional check';

  @override
  String get reviewStepRunConsistencyCheck => 'Run a consistency check';

  @override
  String get reviewStepConsistencyCheckHelp =>
      'Scans your answers for cross-step contradictions (e.g. an agent-consent that conflicts with an avoid list), and — if the AI is set up — adds an optional AI review of gaps to double-check. Optional; you can sign without it.';

  @override
  String get reviewStepReadyToSign => 'Ready to sign?';

  @override
  String get reviewStepReadyToSignBody =>
      'Review all sections above. When satisfied, tap Preview to continue to signing and dating the directive.';

  @override
  String get reviewStepProvidersMustComply => 'Providers must comply ';

  @override
  String get reviewStepProvidersMustComplyBody =>
      'with your directive under PA Act 194 (20 Pa.C.S. §§ 5804, 5842). A provider may decline specific instructions only if they conflict with accepted medical practice, or when the provider is not physically available.';

  @override
  String get reviewStepExperimentalStudies => 'Experimental studies';

  @override
  String get wizardProgressSaved => 'Progress saved';

  @override
  String get wizardLoading => 'Loading';

  @override
  String get wizardError => 'Error';

  @override
  String get wizardUnableToLoad => 'Unable to load this directive.';

  @override
  String get wizardBackToHome => 'Back to home';

  @override
  String get wizardNotFound => 'Not found';

  @override
  String get wizardDirectiveNotFound => 'Directive not found.';

  @override
  String get wizardPreview => 'Preview';

  @override
  String get wizardContinue => 'Continue';

  @override
  String get wizardSaved => 'Saved';

  @override
  String get wizardIncompletePrivate =>
      'Some fields are incomplete — you can come back to finish later.';

  @override
  String get wizardIncompletePublic =>
      'Some fields are incomplete — you can fill them in before you finish.';

  @override
  String get wizardExitWithoutSaving => 'Exit Without Saving?';

  @override
  String get wizardExitWebBody =>
      'The web app does not save your progress permanently.\n\nIf you leave, close the tab, or the app crashes, your work is kept on this device for 10 minutes so you can reopen and recover it — then it’s erased. Export or print your document to keep a copy.';

  @override
  String get wizardExitPublicBody =>
      'You are in Public Mode — your data is stored in memory only and will be lost when the app closes.\n\nExport or print your document before leaving. To save across sessions, use Private Mode instead.';

  @override
  String get wizardStay => 'Stay';

  @override
  String get wizardExit => 'Exit';

  @override
  String get wizardSaveExitBody =>
      'Your progress on this step will be saved. You can return to continue later.';

  @override
  String get wizardYourDirective => 'YOUR DIRECTIVE';

  @override
  String personalInfoStepReuseDetails(String name) {
    return 'Reuse your details from $name?';
  }

  @override
  String get personalInfoStepCopy => 'Copy';

  @override
  String get personalInfoStepZipFirst => 'Enter a 5-digit ZIP first.';

  @override
  String get personalInfoStepZipLookupFailed =>
      'Couldn\'t look up that ZIP — you can type it in.';

  @override
  String personalInfoStepCountyName(String county) {
    return '$county County';
  }

  @override
  String personalInfoStepFilled(String filled) {
    return 'Filled: $filled';
  }

  @override
  String get personalInfoStepDateFormat => 'Use MM/DD/YYYY format';

  @override
  String get personalInfoStepInvalidDate => 'Invalid date';

  @override
  String get personalInfoStepDobFuture =>
      'Date of birth can\'t be in the future';

  @override
  String get personalInfoStepMustBeAdult =>
      'Must be 18 or older (or an emancipated minor) to create a directive';

  @override
  String get personalInfoStepSelectDob => 'Select your date of birth';

  @override
  String get personalInfoStepHelp =>
      'Provide your legal name as it appears on official documents. You must be 18 years of age or older, or an emancipated minor, to create a Mental Health Advance Directive under PA Act 194 of 2004.';

  @override
  String get personalInfoStepFullLegalName => 'Full legal name *';

  @override
  String get personalInfoStepFullLegalNameHelper =>
      'Use your full legal name as it appears on official ID';

  @override
  String get personalInfoStepDobLabel => 'Date of birth (MM/DD/YYYY) *';

  @override
  String get personalInfoStepDobHelper =>
      'Used to verify your identity on the directive';

  @override
  String get personalInfoStepPickDate => 'Pick date';

  @override
  String get personalInfoStepStreetAddress => 'Street address';

  @override
  String get personalInfoStepStreetAddressHelper =>
      'Your current residential address';

  @override
  String get personalInfoStepAddress2 => 'Apt, suite, unit, etc.';

  @override
  String get personalInfoStepCounty => 'County';

  @override
  String get personalInfoStepZip => 'ZIP';

  @override
  String get personalInfoStepZipHint => '12345 or 12345-6789';

  @override
  String get personalInfoStepZipHelper =>
      'Tap the icon to fill city, county & state';

  @override
  String get personalInfoStepZipTooltip => 'Fill city, county & state from ZIP';

  @override
  String get personalInfoStepZipInvalid => 'Enter 5-digit or 5+4-digit ZIP';

  @override
  String get personalInfoStepPhoneInvalid =>
      'Enter a valid 10-digit phone number';

  @override
  String get peopleTrustPrimaryAgent => 'PRIMARY AGENT';

  @override
  String get peopleTrustAlternateAgent => 'ALTERNATE AGENT';

  @override
  String get peopleTrustWhatCanTheyDecide => 'What can they decide?';

  @override
  String get peopleTrustAuthorityIntro =>
      'Limit or expand your agent’s authority. Default is broad authority.';

  @override
  String get peopleTrustLegendAgentDecides => '\"Agent decides\"';

  @override
  String get peopleTrustLegendGrants => ' grants the power; ';

  @override
  String get peopleTrustLegendNo => '\"No\"';

  @override
  String get peopleTrustLegendWithholds => ' withholds it entirely; ';

  @override
  String get peopleTrustLegendIf => '\"If…\"';

  @override
  String get peopleTrustLegendCondition =>
      ' lets you add a condition in your own words.';

  @override
  String get peopleTrustPrimaryBadge => 'Primary';

  @override
  String get peopleTrustAddSomeone => 'Add someone';

  @override
  String get peopleTrustOptional => 'Optional';

  @override
  String get peopleTrustContactPicker => 'Contact picker';

  @override
  String get peopleTrustPhoneOnFile => 'Phone on file';

  @override
  String get agentDesigHelp =>
      'Your agent must be 18 or older. Under PA Act 194, they cannot be your mental health care provider or an employee of a mental health care facility or residential facility where you receive care — unless they are related to you. Choose someone you trust to honor your wishes.';

  @override
  String get agentDesigTitle => 'Primary Agent Designation';

  @override
  String get agentDesigAgentDefinition =>
      'An agent (healthcare proxy) is someone you choose to make mental health care decisions on your behalf when you cannot.';

  @override
  String get agentDesigRelationship => 'Relationship';

  @override
  String get agentDesigSpouseNote =>
      'Note: Under PA Act 194 §5838, if you designate your spouse as your agent, that designation is automatically revoked if either spouse files for divorce, unless you state otherwise in this directive.';

  @override
  String get altAgentHelp =>
      'Your agent must be 18 or older. They cannot be your treating physician, an employee of your treatment facility (unless a relative), or someone with financial interest in your estate. Choose someone you trust to honor your wishes.';

  @override
  String get altAgentTitle => 'Alternate Agent Designation';

  @override
  String get altAgentActsIf =>
      'Your alternate agent acts if your primary agent is unable or unwilling to serve.';

  @override
  String get altAgentSameAuthority =>
      'The alternate agent has the same authority as the primary agent but only steps in when the primary agent cannot act.';

  @override
  String get altAgentNotRequired =>
      'You are not required to designate an alternate agent.';

  @override
  String get altAgentRelationship => 'Relationship';

  @override
  String get agentAuthHelp =>
      'Consider carefully before restricting your agent\'s authority. Broad authority gives your agent flexibility to respond to situations you may not anticipate.';

  @override
  String get agentAuthIntro =>
      'By default your agent has broad authority to make mental health treatment decisions. You may restrict this authority here.';

  @override
  String get agentAuthScopeTitle =>
      'Important: Scope of Authority (20 Pa.C.S. § 5836)';

  @override
  String get agentAuthScopeBody =>
      'The checkboxes below apply ONLY to:\n  • Voluntary hospitalization (admission to a treatment facility)\n  • General psychiatric medications\n\nThey do NOT cover:\n  • Electroconvulsive therapy (ECT)\n  • Experimental studies or procedures\n  • Clinical drug trials\n\nYour consent choices for ECT, experimental studies, and drug trials are set on their dedicated pages earlier in this form. Under PA Act 194, your agent CANNOT override those decisions — they are binding regardless of agent authority.';

  @override
  String get agentAuthStandardLead => 'The standard your agent must follow: ';

  @override
  String get agentAuthStandardBody =>
      'under § 5836(d), your agent is legally bound to make the decision you would make if you were competent, guided by what you write in this directive and any clear prior instructions, after consulting with providers. The more you fill in, the closer their decisions can match yours.';

  @override
  String get agentAuthHospitalization =>
      'Agent may consent to voluntary hospitalization';

  @override
  String get agentAuthHospitalizationSub =>
      'Admission to a psychiatric treatment facility only';

  @override
  String get agentAuthMedication => 'Agent may consent to medication';

  @override
  String get agentAuthMedicationSub =>
      'General psychiatric medications only — does not include ECT';

  @override
  String get agentAuthExamplesField => 'Agent Limitations';

  @override
  String get agentAuthExample1 =>
      'My agent may not consent to electroconvulsive therapy (ECT) under any circumstances.';

  @override
  String get agentAuthExample2 =>
      'My agent should consult with my therapist, Dr. Smith, before agreeing to any changes in my medication regimen.';

  @override
  String get agentAuthExample3 =>
      'My agent may consent to voluntary inpatient admission for up to 72 hours, but may not consent to longer stays without consulting my family.';

  @override
  String get agentAuthLimitationsLabel =>
      'Additional limitations or instructions (optional)';

  @override
  String get guardianNomNoPreference => 'No preference';

  @override
  String get guardianNomNoPreferenceHint =>
      'Let the court decide. They will usually appoint a family member or county guardianship office.';

  @override
  String get guardianNomSameAsPrimary => 'Same as my primary agent';

  @override
  String get guardianNomSameAsPrimaryHint =>
      'The simplest path. The court is not required to follow this, but it is strong guidance.';

  @override
  String get guardianNomSameAsAlternate => 'Same as my alternate agent';

  @override
  String get guardianNomSameAsAlternateHint =>
      'Use this if your alternate would be a better fit for a longer-term guardianship role.';

  @override
  String get guardianNomDifferent => 'Someone different';

  @override
  String get guardianNomDifferentHint =>
      'Choose another person — e.g. an attorney, sibling, or close friend not already named.';

  @override
  String get guardianNomHelp =>
      'Your nomination is not binding — the court will consider it but makes the final decision on who to appoint.';

  @override
  String get guardianNomOptionalIntro =>
      'This section is optional. You may nominate a guardian in case a court ever needs to appoint one for you.';

  @override
  String get guardianNomGuardianVsAgent =>
      'A guardian is different from your agent. A guardian is appointed by a court during formal incapacity proceedings. This nomination tells the court who you prefer.';

  @override
  String get guardianNomPreferredGuardian => 'Preferred guardian';

  @override
  String get guardianNomPickWhatFits =>
      'Pick what fits — your nomination is guidance for the court, not a binding instruction.';

  @override
  String get guardianNomNomineeFullName => 'Nominee full name';

  @override
  String get guardianNomRelationshipToYou => 'Relationship to you';

  @override
  String get guardianNomConditionsTitle => 'Conditions on the guardianship';

  @override
  String get guardianNomConditionsIntro =>
      'If a court appoints a guardian, set the limits you want it to honor. These are guidance for the court, not binding.';

  @override
  String get guardianNomCanChangeAgent => 'Can change my agent';

  @override
  String get guardianNomCanChangeAgentHint =>
      'When or how may the guardian change my agent? (optional)';

  @override
  String get guardianNomCanOverride => 'Can override this directive';

  @override
  String get guardianNomCanOverrideSub => 'Revoke, suspend, or terminate it.';

  @override
  String get guardianNomCanOverrideHint =>
      'Any limits on overriding this directive? (optional)';

  @override
  String get guardianNomMustConsult => 'Must consult my agent first';

  @override
  String get guardianNomMustConsultHint =>
      'What should the guardian consult my agent about? (optional)';

  @override
  String diagnosesAlreadyAdded(String name) {
    return '$name is already added';
  }

  @override
  String get diagnosesSearchHint =>
      'Search a condition (e.g. depression, ADHD)…';

  @override
  String get diagnosesClearSearch => 'Clear search';

  @override
  String get diagnosesHelpText =>
      'Search for your psychiatric and medical diagnoses using ICD-10 codes. These are the official medical classification codes used by healthcare providers. Adding your diagnoses helps your care team and agent understand your conditions.\n\nPsychiatric diagnoses (F-codes) and medical diagnoses are shown in separate sections.\n\nThis lookup is free and uses the NIH Clinical Tables Service — no AI tokens are used.';

  @override
  String get diagnosesPsychiatric => 'Psychiatric';

  @override
  String get diagnosesMedical => 'Medical';

  @override
  String get diagnosesNoResults => 'No results found.';

  @override
  String get diagnosesEmptyTitle => 'No diagnoses added yet';

  @override
  String get diagnosesEmptyBody =>
      'Use the search above to find and add your diagnoses.';

  @override
  String diagnosesAddedOne(int count) {
    return 'Added · $count condition';
  }

  @override
  String diagnosesAddedMany(int count) {
    return 'Added · $count conditions';
  }

  @override
  String diagnosesPsychiatricCount(int count) {
    return 'Psychiatric ($count)';
  }

  @override
  String diagnosesMedicalCount(int count) {
    return 'Medical ($count)';
  }

  @override
  String get diagnosesDoctorSection => 'Primary care doctor · optional';

  @override
  String get diagnosesDoctorName => 'Doctor name';

  @override
  String get diagnosesDoctorNameHint =>
      'Type a name to search the provider registry';

  @override
  String get diagnosesNpiNote =>
      'Provider names from the NPI registry (NIH Clinical Tables). Verify details before relying on them.';

  @override
  String get diagnosesSpecialty => 'Specialty';

  @override
  String get diagnosesPhone => 'Phone';

  @override
  String get diagnosesDescribeSemantics =>
      'Describe a condition to find its official name';

  @override
  String get diagnosesDescribeLead => 'Don\'t know the official name? ';

  @override
  String get diagnosesDescribeBold => 'Describe how it shows up for you';

  @override
  String get diagnosesDescribeTail =>
      ' and I\'ll suggest the closest ICD-10 code for you to confirm.';

  @override
  String get diagnosesTry => 'Try →';

  @override
  String get diagnosesFooter =>
      'You\'re not required to list anything. Anything you do list is shared only with the people your directive names.';

  @override
  String diagnosesAddedName(String name) {
    return 'Added “$name”';
  }

  @override
  String diagnosesAlreadyAddedQuoted(String name) {
    return '“$name” is already added';
  }

  @override
  String get diagnosesDescribeTitle => 'Describe what you experience';

  @override
  String get diagnosesDescribeIntro =>
      'In your own words — symptoms, how it affects you, when it happens. We\'ll suggest possible conditions and confirm each against the ICD-10 registry. These are suggestions to review, not a diagnosis.';

  @override
  String get diagnosesDescribeHint =>
      'e.g. long stretches where I feel hopeless and can\'t get out of bed';

  @override
  String get diagnosesFinding => 'Finding…';

  @override
  String get diagnosesFindMatches => 'Find matches';

  @override
  String get diagnosesNoMatches =>
      'No close matches. Try adding more detail, or use the search box on the page if you know part of the name.';

  @override
  String get diagnosesSuggestionsNote =>
      'Suggestions only — confirm with your records or your doctor. Codes from NIH Clinical Tables (ICD-10-CM).';

  @override
  String get diagnosesDone => 'Done';

  @override
  String get allergiesKindDrug => 'Drug';

  @override
  String get allergiesKindFood => 'Food';

  @override
  String get allergiesKindMaterial => 'Material';

  @override
  String get allergiesKindOther => 'Other';

  @override
  String get allergiesSearchDrugHint => 'Search a drug or class…';

  @override
  String get allergiesSearchFoodHint => 'Search food allergens…';

  @override
  String get allergiesSearchMaterialHint => 'Search material allergens…';

  @override
  String get allergiesSearchOtherHint => 'Search other allergens…';

  @override
  String allergiesAddedToNeverWant(String name) {
    return 'Added $name to “Medications I never want”.';
  }

  @override
  String get allergiesCodeSevere => 'SEVERE';

  @override
  String get allergiesCodeModerate => 'MOD';

  @override
  String get allergiesCodeMild => 'MILD';

  @override
  String get allergiesHelpText =>
      'List drug allergies, sensitivities, and past adverse reactions. ER staff check this section first. Severity = Mild / Moderate / Severe. Allergies and the \"Medications I never want\" list are separate sections — add a medication you refuse there yourself.';

  @override
  String get allergiesAddSection => 'Add an allergy';

  @override
  String get allergiesSourceRxTerms => 'RxTerms · NLM clinical tables';

  @override
  String get allergiesSourceIcd => 'ICD-10-CM · NLM clinical tables';

  @override
  String get allergiesNoResults => 'No results found.';

  @override
  String get allergiesSourceNote =>
      'Drug allergies search RxTerms. Food, material & other allergies search ICD-10 (e.g. Z91.01 food allergy, T78.4 unspecified allergy).';

  @override
  String get allergiesSeveritySection => 'Severity & reaction';

  @override
  String get allergiesHowSerious => 'How serious is it?';

  @override
  String get allergiesWhatHappens => 'What happens';

  @override
  String get allergiesReactionsHint => 'e.g. Hives, Swelling, Throat closing';

  @override
  String get allergiesAddButton => 'Add allergy';

  @override
  String allergiesAddedOne(int count) {
    return 'Added · $count allergy';
  }

  @override
  String allergiesAddedMany(int count) {
    return 'Added · $count allergies';
  }

  @override
  String get allergiesFooter =>
      'You\'re not required to list anything. Anything you do list is shared only with the people your directive names.';

  @override
  String get allergiesClearSearch => 'Clear search';

  @override
  String allergiesMatches(int count) {
    return '$count matches';
  }

  @override
  String get allergiesSeverityMild => 'Mild';

  @override
  String get allergiesSeverityMildDesc => 'rash, mild GI';

  @override
  String get allergiesSeverityModerate => 'Moderate';

  @override
  String get allergiesSeverityModerateDesc => 'hives, swelling';

  @override
  String get allergiesSeveritySevere => 'Severe';

  @override
  String get allergiesSeveritySevereDesc => 'anaphylaxis · ER';

  @override
  String allergiesSeveritySemantics(String label) {
    return '$label severity';
  }

  @override
  String medsStepMaxPerCategory(int max) {
    return 'Maximum $max medications per category';
  }

  @override
  String get medsStepHelpText =>
      'List medications by name. Your preferences apply to generic, brand name, and trade name equivalents unless you specify otherwise in the notes — to request brand-name only, note it in the reason field.\n\nNarrow Therapeutic Index (NTI) drugs — ones with only a small safety margin between a helpful dose and a harmful one, like lithium, carbamazepine, and valproic acid — cannot have generics substituted under PA law (35 P.S. §960.3). These are marked with an \"NTI\" badge when you search.';

  @override
  String get medsStepHeadsUpLead => 'Heads up — ';

  @override
  String get medsStepHeadsUpBody =>
      'your refusal of a medication and any limits you set on its use are binding under PA Act 194, but ';

  @override
  String get medsStepHeadsUpBold =>
      'specific dosage instructions are not binding';

  @override
  String get medsStepHeadsUpTail => ' on the physician — they choose the dose.';

  @override
  String get medsStepAgentDecides =>
      'I have designated an agent to make decisions about my medications';

  @override
  String get medsStepCurrentTitle => 'Medications I am currently taking';

  @override
  String get medsStepCurrentSubtitle =>
      'For your care team’s reference — not a preference';

  @override
  String get medsStepNeverTitle => 'Medications I NEVER want';

  @override
  String get medsStepNeverSubtitle =>
      'These medications should not be administered';

  @override
  String get medsStepLimitTitle => 'Medications with limitations';

  @override
  String get medsStepLimitSubtitle => 'May be given but with restrictions';

  @override
  String get medsStepPreferredTitle => 'Preferred medications';

  @override
  String get medsStepPreferredSubtitle =>
      'Medications that have worked well for you';

  @override
  String get medsStepSideEffectsTitle => 'Side effects you may be experiencing';

  @override
  String get medsStepSideEffectsBody =>
      'For the medications you take now, check common side effects — especially any that affect your daily activities — so your care team knows. Needs AI set up. Not medical advice.';

  @override
  String medsStepNtiNote(String note) {
    return 'Narrow therapeutic index drug — $note. Pennsylvania law bars generic substitution for these; note any monitoring needs below. (Informational, not medical advice.)';
  }

  @override
  String get medsStepDosageLabel => 'Dosage (e.g. 20 mg twice daily)';

  @override
  String get medsStepReasonLabel => 'Reason / notes (optional)';

  @override
  String medsStepLearnAbout(String name) {
    return 'Learn about $name';
  }

  @override
  String get medsStepMedlineInfo => 'Plain-language info (MedlinePlus)';

  @override
  String get medsStepFdaInfo =>
      'Official FDA label (side effects & interactions)';

  @override
  String get medsStepRemoveDefault => 'Remove medication';

  @override
  String medsStepRemoveNamed(String name) {
    return 'Remove $name';
  }

  @override
  String medsStepAddToList(String title) {
    return 'Add medication to $title list';
  }

  @override
  String get medsStepAddButton => 'Add medication';

  @override
  String get facilityRoommateWomen => 'Women';

  @override
  String get facilityRoommateMen => 'Men';

  @override
  String get facilityRoommateSameAsIdentity => 'Same as my gender identity';

  @override
  String get facilityRoommateSpecify => 'Let me specify';

  @override
  String get facilityHelpText =>
      'You may specify treatment facilities you prefer or want to avoid. These preferences guide your agent and treatment providers but may not always be possible to honor. Both sections are optional.';

  @override
  String get facilityNoPreferenceBanner =>
      'Leave both sections empty if you have no preference. Your directive will indicate \"No Preference\" for treatment facilities.';

  @override
  String get facilityPreferredTitle => 'Preferred Facilities';

  @override
  String get facilityPreferredSubtitle =>
      'Facilities where you would prefer to be treated';

  @override
  String get facilityAvoidTitle => 'Facilities to Avoid';

  @override
  String get facilityAvoidSubtitle =>
      'Facilities where you do not want to be treated';

  @override
  String get facilityOtherRoomPrefsLabel => 'Other room preferences';

  @override
  String get facilityOtherRoomPrefsHint =>
      'Anything else about your room or surroundings — e.g. low lighting, near a window, away from loud areas…';

  @override
  String get facilityRoomSingle => 'Single room';

  @override
  String get facilityRoomWindow => 'Window if possible';

  @override
  String get facilityRoomQuietFloor => 'Quiet floor';

  @override
  String get facilityRoomSameGender => 'Same-gender roommate';

  @override
  String get facilityRoomNoRoommate => 'No roommate';

  @override
  String get facilityRoomTransAffirming => 'Trans-affirming staff';

  @override
  String get facilityRoomLowStimulation => 'Low-stimulation unit';

  @override
  String get facilityRoomPrefsTitle => 'Room preferences';

  @override
  String get facilityRoomPrefsSubtitle =>
      'Optional — guides staff if a choice is available.';

  @override
  String get facilityRoommateMatchPrompt =>
      'For \"same-gender roommate\", match me with:';

  @override
  String get facilityMatchMeWithLabel => 'Match me with';

  @override
  String get facilityMatchMeWithHint =>
      'Describe your roommate-matching preference';

  @override
  String get facilityNameLabel => 'Facility name';

  @override
  String get facilityNameHint => 'Type to search facilities';

  @override
  String get facilityLocationLabel => 'Location (optional)';

  @override
  String get facilityLocationHint => 'e.g., 123 Main St, Philadelphia, PA';

  @override
  String get facilityRemoveTooltip => 'Remove facility';

  @override
  String facilityAddToSemantics(String title) {
    return 'Add facility to $title';
  }

  @override
  String get facilityAddButton => 'Add facility';

  @override
  String get facilityNpiAttribution =>
      'Facility names from the NPI registry (NIH Clinical Tables). Verify details before relying on them.';

  @override
  String get addlInstrHelpText =>
      'These sections are all optional. Use them to give guidance to your agent and treatment team beyond the basic preferences above.';

  @override
  String get addlInstrExampleFieldName => 'Additional Instructions';

  @override
  String get addlInstrExample1 =>
      'I find listening to calming music and going for walks helpful during periods of distress. Please allow me access to my personal music player.';

  @override
  String get addlInstrExample2 =>
      'I am vegetarian for religious reasons. Please ensure my dietary needs are respected during any inpatient stay. I would also like access to a chaplain or spiritual advisor.';

  @override
  String get addlInstrExample3 =>
      'Please notify my sister, Jane Doe, if I am admitted. Do not contact my ex-spouse under any circumstances. My therapist, Dr. Smith, should be informed of any treatment changes.';

  @override
  String get addlInstrActivitiesTitle => 'Activities & Environment';

  @override
  String get addlInstrActivitiesHint =>
      'Preferences about daily activities, environment, restraints, seclusion';

  @override
  String get addlInstrActivitiesDescription =>
      'Describe activities that help you feel better (e.g., walking, reading, music) and your preferences about your physical environment during treatment. You can also state whether you consent to or refuse the use of restraints (being physically held or strapped down, or given medication to restrict your movement or behavior — a \"chemical restraint\") or seclusion (being confined alone in a room).';

  @override
  String get addlInstrCrisisTitle => 'Crisis Intervention';

  @override
  String get addlInstrCrisisHint =>
      'What helps or doesn\'t help during a crisis';

  @override
  String get addlInstrCrisisDescription =>
      'Based on your past experience, describe what helps you during a mental health crisis and what makes things worse. This helps your treatment team respond in the way that works best for you.';

  @override
  String get addlInstrDeescTitle => 'De-escalation Techniques';

  @override
  String get addlInstrDeescHint =>
      'e.g., music, deep breathing, quiet room, weighted blanket';

  @override
  String get addlInstrDeescDescription =>
      'List specific techniques or strategies that help calm you when you are distressed. Examples include listening to music, deep breathing, being in a quiet room, using a weighted blanket, speaking with a specific person, or going for a walk.';

  @override
  String get addlInstrTriggersTitle => 'Potential Crisis Triggers';

  @override
  String get addlInstrTriggersHint =>
      'e.g., loud environments, specific topics, being alone';

  @override
  String get addlInstrTriggersDescription =>
      'Identify situations, environments, or topics that may trigger or worsen a crisis for you. This helps your treatment team avoid these triggers. Examples: loud environments, being touched without permission, certain conversation topics, being left alone, or specific people.';

  @override
  String get addlInstrHealthHistoryTitle => 'Health History';

  @override
  String get addlInstrHealthHistoryHint =>
      'Relevant mental health history, diagnoses, hospitalizations';

  @override
  String get addlInstrHealthHistoryDescription =>
      'Summarize your relevant mental health history, including past diagnoses, hospitalizations, and treatments that worked well or did not work. This gives your treatment team context about your care history.';

  @override
  String get addlInstrDietaryTitle => 'Dietary Preferences';

  @override
  String get addlInstrDietaryHint =>
      'Food restrictions, preferences, religious dietary laws';

  @override
  String get addlInstrDietaryDescription =>
      'List any food allergies, dietary restrictions, or preferences your treatment team should know about. This includes religious dietary laws (e.g., kosher, halal, vegetarian), food intolerances, and any foods to avoid due to medication interactions.';

  @override
  String get addlInstrReligiousTitle => 'Religious & Spiritual';

  @override
  String get addlInstrReligiousHint =>
      'Religious practices, spiritual needs, clergy contact';

  @override
  String get addlInstrReligiousDescription =>
      'Describe any religious or spiritual practices that are important to you during treatment. This may include prayer times, clergy or chaplain visits, religious texts or items you would like to have access to, fasting observances, or faith-based coping practices.';

  @override
  String get addlInstrChildrenTitle => 'Children & Custody';

  @override
  String get addlInstrChildrenHint =>
      'Instructions regarding care of your minor children';

  @override
  String get addlInstrChildrenDescription =>
      'If you have minor children or dependents, describe who should care for them if you are hospitalized. Include contact information for caregivers, school details, and any custody arrangements your treatment team should be aware of.';

  @override
  String get addlInstrFamilyNotifyTitle => 'Family Notification';

  @override
  String get addlInstrFamilyNotifyHint => 'Who should be notified and how';

  @override
  String get addlInstrFamilyNotifyDescription =>
      'Specify who should be notified if you are hospitalized or if your treatment changes. Include how to reach them and what information may be shared. You can also specify people who should NOT be contacted.';

  @override
  String get addlInstrPetCareTitle => 'Pet Care';

  @override
  String get addlInstrPetCareHint => 'Instructions for care of your pets';

  @override
  String get addlInstrPetCareDescription =>
      'If you have pets, describe who should care for them if you are hospitalized. Include the caregiver\'s contact information, feeding and medication schedules, veterinary contacts, and any special care instructions.';

  @override
  String get addlInstrReproTitle => 'Reproductive Health Care';

  @override
  String get addlInstrReproHint => 'Pregnancy testing, contraception, etc.';

  @override
  String get addlInstrReproDescription =>
      'Describe any reproductive health care preferences your treatment team should know about. This may include whether you want pregnancy testing before medication changes, contraception preferences, or reproductive health conditions that could affect your treatment.';

  @override
  String get addlInstrOtherTitle => 'Other Instructions';

  @override
  String get addlInstrOtherHint => 'Any other instructions not covered above';

  @override
  String get addlInstrOtherDescription =>
      'Use this section for any instructions to your treatment team or agent that are not covered by the sections above. This is a catch-all for anything else you want to communicate about your care preferences.';

  @override
  String get addlInstrRecordsTitle => 'Records Disclosure & Limitations';

  @override
  String get addlInstrRecordsDescription =>
      'Choose who may — and may not — receive copies of your mental health records. Under 20 Pa.C.S. § 5836(e), the disclosure authority you grant here can override certain confidentiality protections (including drug & alcohol, mental-health-procedures, and HIV confidentiality laws), so be specific.';

  @override
  String get addlInstrRecordsReleaseLabel => 'Who may receive my records';

  @override
  String get addlInstrRecordsReleaseHint =>
      'e.g. my agent Jane Doe; my treatment team; Dr. Smith';

  @override
  String get addlInstrRecordsWithholdLabel => 'Who must NOT receive my records';

  @override
  String get addlInstrRecordsWithholdHint =>
      'e.g. my ex-spouse; specific family members';

  @override
  String get addlInstrRecordsOtherLabel => 'Other limitations on disclosure';

  @override
  String get addlInstrRecordsOtherHint =>
      'e.g. release only records from the last 12 months';

  @override
  String get addlInstrOptionalAddOns => 'Optional add-ons';

  @override
  String get addlInstrCrisisPlanTitle => 'Crisis plan';

  @override
  String get addlInstrCrisisPlanSubtitle =>
      'Your early-warning signs, triggers, what genuinely helps, and what not to do. Not required by Act 194 — but it\'s the part agents and ER staff read first.';

  @override
  String get addlInstrUlyssesTitle => 'Self-binding (Ulysses) clause';

  @override
  String get addlInstrUlyssesSubtitle =>
      'Acknowledge that, once two professionals find you incapable, what you wrote stands even over your in-the-moment protest, until capacity returns (20 Pa.C.S. §§ 5824, 5834).';

  @override
  String get effCondHelpText =>
      'Describe the circumstances under which you want this directive to take effect — for example, \"when two qualified professionals certify that I lack capacity to make treatment decisions.\" Under PA Act 194, the declaration becomes operative when a psychiatrist and one of the following certify you lack capacity: another psychiatrist, a licensed psychologist, your family physician, your attending physician, or another mental health treatment professional.';

  @override
  String get effCondTakeEffectWhen => 'This directive should take effect when…';

  @override
  String get effCondTriggerTwoTitle =>
      'A psychiatrist + one other professional find I lack capacity';

  @override
  String get effCondTriggerTwoSubtitle =>
      'The standard PA Act 194 trigger — two qualified professionals certify you can\'t make mental-health treatment decisions.';

  @override
  String get effCondTriggerCourtTitle => 'A court determines I lack capacity';

  @override
  String get effCondTriggerCommitTitle => 'I am involuntarily committed';

  @override
  String get effCondAnythingElseTitle =>
      'Anything else about timing (optional)';

  @override
  String get effCondAnythingElseSubtitle =>
      'Add your own words, or pick an example to start from.';

  @override
  String get effCondExampleFieldName => 'Effective Condition';

  @override
  String get effCondExample1 =>
      'This directive takes effect when I am unable to make mental health treatment decisions for myself, as determined by two qualified professionals.';

  @override
  String get effCondExample2 =>
      'This directive becomes effective any time I am admitted to a psychiatric facility or crisis unit, whether voluntary or involuntary, and I am unable to clearly communicate my wishes.';

  @override
  String get effCondExample3 =>
      'This directive takes effect when I am experiencing a severe episode of psychosis, mania, or dissociation that prevents me from understanding my treatment options or communicating my preferences.';

  @override
  String get effCondExample4 =>
      'This directive becomes effective when I tell my agent or treatment provider that I want it activated, or when I am unable to make consistent and informed decisions about my mental health care.';

  @override
  String get effCondExample5 =>
      'This directive is effective when my designated agent, in consultation with any treating professional, determines that I would benefit from having my pre-stated treatment preferences followed.';

  @override
  String get effCondOwnWordsLabel => 'In your own words (optional)';

  @override
  String get effCondDoctorTitle => 'Preferred evaluating doctor (optional)';

  @override
  String get effCondDoctorSubtitle =>
      'If you have a preferred doctor to evaluate your capacity, enter their information below.';

  @override
  String get effCondDoctorNameLabel => 'Name of Doctor';

  @override
  String get effCondDoctorContactLabel => 'Address / Phone Number';

  @override
  String get consentChoiceEctSectionLabel => 'TREATMENT CONSENT';

  @override
  String get consentChoiceEctTitle => 'Electroconvulsive Therapy (ECT)';

  @override
  String get consentChoiceEctSubtitle =>
      'ECT is a psychiatric treatment in which seizures are electrically induced. State your preferences below.';

  @override
  String get consentChoiceEctHelpText =>
      'ECT can be an effective treatment for severe depression and other conditions. Under PA law, you can consent in advance, refuse in advance, or set conditions.';

  @override
  String get consentChoiceEctInfoBannerText =>
      'Under PA Act 194, your agent cannot consent to ECT unless you explicitly authorize it here.';

  @override
  String get consentChoiceEctNoTitle => 'I do not consent to ECT';

  @override
  String get consentChoiceEctNoDescription =>
      'ECT must not be performed on me.';

  @override
  String get consentChoiceEctYesTitle => 'I consent to ECT';

  @override
  String get consentChoiceEctYesDescription =>
      'My provider may perform ECT if indicated.';

  @override
  String get consentChoiceEctAgentTitle => 'My agent will decide about ECT';

  @override
  String get consentChoiceEctAgentDescription =>
      'Authorize your agent to consent to or refuse ECT on your behalf.';

  @override
  String get consentChoiceEctConditionalHint =>
      'e.g., only if other treatments have failed and my agent agrees';

  @override
  String get consentChoiceExperimentalSectionLabel => 'RESEARCH CONSENT';

  @override
  String get consentChoiceExperimentalTitle => 'Experimental Studies';

  @override
  String get consentChoiceExperimentalSubtitle =>
      'State your preferences regarding participation in experimental research during mental health treatment.';

  @override
  String get consentChoiceExperimentalHelpText =>
      'You have the right to consent to or refuse participation in experimental research. Your preferences here will guide your care team and agent.';

  @override
  String get consentChoiceExperimentalInfoBannerText =>
      'Under PA Act 194, your agent cannot consent to experimental research unless you explicitly authorize it here.';

  @override
  String get consentChoiceExperimentalNoDescription =>
      'I refuse participation in experimental studies.';

  @override
  String get consentChoiceExperimentalYesTitle =>
      'I consent to experimental studies';

  @override
  String get consentChoiceExperimentalYesDescription =>
      'I am willing to participate in research studies during treatment.';

  @override
  String get consentChoiceExperimentalConditionalHint =>
      'e.g., only non-invasive studies approved by my agent';

  @override
  String get consentChoiceDrugTrialsSectionLabel => 'CLINICAL TRIALS';

  @override
  String get consentChoiceDrugTrialsTitle => 'Drug Trials';

  @override
  String get consentChoiceDrugTrialsSubtitle =>
      'State your preferences regarding participation in clinical drug trials during mental health treatment.';

  @override
  String get consentChoiceDrugTrialsHelpText =>
      'Clinical drug trials test new medications. You can consent, refuse, or set conditions for your participation.';

  @override
  String get consentChoiceDrugTrialsInfoBannerText =>
      'Under PA Act 194, your agent cannot consent to drug trials unless you explicitly authorize it here.';

  @override
  String get consentChoiceDrugTrialsNoDescription =>
      'I refuse participation in drug trials.';

  @override
  String get consentChoiceDrugTrialsYesTitle => 'I consent to drug trials';

  @override
  String get consentChoiceDrugTrialsYesDescription =>
      'I am willing to participate in clinical drug trials.';

  @override
  String get consentChoiceDrugTrialsConditionalHint =>
      'e.g., only trials with an independent safety monitor';

  @override
  String get consentChoiceConditionalTitle =>
      'I consent under specific conditions';

  @override
  String get consentChoiceConditionalDescription =>
      'Describe the conditions in the box below.';

  @override
  String get consentChoiceConditionsLabel => 'Conditions';

  @override
  String get consentChoiceNoConsentTitle => 'I do not consent';

  @override
  String get consentChoiceAgentDecidesTitle => 'My agent will decide';

  @override
  String get consentChoiceAgentDecidesDescription =>
      'Authorize your agent to consent or refuse on your behalf.';

  @override
  String get voiceInputOpenDictation => 'Open voice dictation';

  @override
  String get voiceInputDictateText => 'Dictate text';

  @override
  String get savedImportCouldNotRead => 'Could not read that file.';

  @override
  String get savedImportImportedAsDraft =>
      'Imported as an editable draft. After reviewing, re-sign and re-witness it to make it valid again — the previous signature does not carry over.';

  @override
  String get contactPickerBtnMissingName => 'name';

  @override
  String get contactPickerBtnMissingAddress => 'address';

  @override
  String get contactPickerBtnMissingPhone => 'phone number';

  @override
  String contactPickerBtnMissingFields(String fields) {
    return 'Contact is missing: $fields. Please fill in the missing fields manually.';
  }

  @override
  String get contactPickerBtnImportA11y => 'Import from contacts';

  @override
  String get contactPickerBtnImport => 'Import from Contacts';

  @override
  String medAutoSelectA11y(String name) {
    return 'Select medication $name';
  }

  @override
  String medAutoSelectNtiA11y(String name) {
    return 'Select medication $name, narrow therapeutic index drug';
  }

  @override
  String get medAutoNtiTooltip =>
      'Narrow Therapeutic Index (NTI) drug — no generic substitution in PA';

  @override
  String get medAutoNtiBadge => 'NTI';

  @override
  String medAutoSelectStrengthA11y(String medication) {
    return 'Select $medication';
  }

  @override
  String get medAutoFieldLabel => 'Medication name';

  @override
  String get medAutoSearchingA11y => 'Searching medications';

  @override
  String get wizardHelpA11y => 'Help for this step. Opens help sheet.';

  @override
  String get wizardHelpButton => 'Help';

  @override
  String get wizardHelpLearnMore => 'Learn More';

  @override
  String wizardHelpQuestionsContact(String phone) {
    return 'Questions? Contact PA Protection & Advocacy: $phone';
  }

  @override
  String get neverWantCrossAddTitle => 'Add to “Medications I never want”?';

  @override
  String get neverWantCrossAddBodySingle =>
      'You listed a drug allergy. Do you also want to refuse it as a medication, adding it to your “Medications I never want” list?';

  @override
  String get neverWantCrossAddBodyMulti =>
      'You listed these drug allergies. Choose any you also want to refuse as medications — they’ll be added to your “Medications I never want” list.';

  @override
  String get neverWantCrossAddNotNow => 'Not now';

  @override
  String get neverWantCrossAddConfirmSingle => 'Add to never-want';

  @override
  String get neverWantCrossAddConfirmMulti => 'Add selected';

  @override
  String get exampleTextSeeExamples => 'See examples';

  @override
  String exampleTextTitle(String fieldName) {
    return 'Example: $fieldName';
  }

  @override
  String get exampleTextIntro =>
      'Here are some examples of what others have written. Use your own words to describe your specific preferences.';

  @override
  String exampleTextNumbered(int number) {
    return 'Example $number';
  }

  @override
  String get exampleTextDisclaimer =>
      'These are samples only. Your directive should reflect your own wishes and circumstances.';

  @override
  String get exampleTextGotIt => 'Got it';

  @override
  String get quizQ1Headline =>
      'Do you have someone in mind to **speak for you**?';

  @override
  String get quizQ1Sub =>
      'A family member, partner, or close friend who could make treatment decisions if you can\'t.';

  @override
  String get quizQ1O1Label => 'Yes — and I trust them completely';

  @override
  String get quizQ1O1Hint => 'You probably want a Combined or POA-only form.';

  @override
  String get quizQ1O2Label => 'Yes, but I want to set firm limits';

  @override
  String get quizQ1O2Hint =>
      'Combined gives you both an agent and a binding declaration.';

  @override
  String get quizQ1O3Label =>
      'No — I want providers to follow my written wishes';

  @override
  String get quizQ1O3Hint => 'Declaration-only is for you.';

  @override
  String get quizQ1O4Label => 'I\'m not sure yet';

  @override
  String get quizQ1O4Hint => 'No problem — we can come back to this.';

  @override
  String get quizQ2Headline =>
      'Do you want to **write down** specific treatment preferences?';

  @override
  String get quizQ2Sub =>
      'Medications, facilities, ECT, experimental studies, drug trials.';

  @override
  String get quizQ2O1Label => 'Yes — I have specific things I want or refuse';

  @override
  String get quizQ2O1Hint =>
      'You probably want a Combined or Declaration form.';

  @override
  String get quizQ2O2Label =>
      'Some preferences, but I\'d rather my agent decide';

  @override
  String get quizQ2O2Hint =>
      'Combined still works — agent decides where you didn\'t write.';

  @override
  String get quizQ2O3Label => 'No — let my agent or doctors decide everything';

  @override
  String get quizQ2O3Hint => 'Power of Attorney only is the lightest path.';

  @override
  String get quizQ2O4Label => 'I\'m not sure yet';

  @override
  String get quizQ2O4Hint => 'No problem — Combined leaves both doors open.';

  @override
  String get quizQ3Headline =>
      'If you can\'t decide, **whose voice** should reach the doctors first?';

  @override
  String get quizQ3Sub =>
      'The directive you write today, or the person you trust?';

  @override
  String get quizQ3O1Label =>
      'What I wrote — even over what someone says in the moment';

  @override
  String get quizQ3O1Hint =>
      'Declaration-only or Combined with strong written preferences.';

  @override
  String get quizQ3O2Label =>
      'My agent — they can read the situation in real time';

  @override
  String get quizQ3O2Hint =>
      'POA-only or Combined where the agent has broad authority.';

  @override
  String get quizQ3O3Label => 'Both — what I wrote, with my agent filling gaps';

  @override
  String get quizQ3O3Hint => 'Combined is the strongest fit.';

  @override
  String get quizQ3O4Label => 'I\'m not sure yet';

  @override
  String get quizQ3O4Hint => 'No problem — Combined supports both pathways.';

  @override
  String get quizQ4Headline =>
      'What\'s the **most important** thing this document does for you?';

  @override
  String get quizQ4Sub =>
      'There\'s no wrong answer — this just confirms what we\'re seeing.';

  @override
  String get quizQ4O1Label => 'Names who I trust to speak for me';

  @override
  String get quizQ4O1Hint => 'Combined or POA-only.';

  @override
  String get quizQ4O2Label => 'Locks in specific treatments I want — or refuse';

  @override
  String get quizQ4O2Hint => 'Combined or Declaration-only.';

  @override
  String get quizQ4O3Label => 'Both — equally';

  @override
  String get quizQ4O3Hint => 'Combined.';

  @override
  String get quizQ4O4Label => 'Just having something on file';

  @override
  String get quizQ4O4Hint =>
      'Any form works. Combined gives the broadest coverage.';

  @override
  String quizQuestionEyebrow(int current, int total) {
    return 'Help me choose · question $current of $total';
  }

  @override
  String get quizInYourWords => 'In your words';

  @override
  String get quizResultEyebrow => 'Help me choose · result';

  @override
  String get quizRecommendedForYou => 'Recommended for you';

  @override
  String get quizYouProbablyWant => 'You probably want\n';

  @override
  String get quizLegendCombined => 'Combined';

  @override
  String get quizLegendDeclaration => 'Declaration only';

  @override
  String get quizLegendPoa => 'Power of Attorney only';

  @override
  String get quizRetake => 'Retake';

  @override
  String quizUseForm(String formName) {
    return 'Use $formName';
  }

  @override
  String get quizFormNameCombined => 'Combined';

  @override
  String get quizFormNameDeclaration => 'Declaration';

  @override
  String get quizFormNamePoa => 'POA';

  @override
  String get quizExplainCombined =>
      'Includes both your treatment preferences AND an agent designation. The most comprehensive option — and what most people choose.';

  @override
  String get quizExplainPoa =>
      'Designates an agent to make decisions for you, without locking in specific treatment preferences. Best when you trust someone completely and want them to decide in the moment.';

  @override
  String get quizExplainDeclaration =>
      'Documents your treatment preferences without naming an agent. Your treatment team will follow your written wishes directly.';

  @override
  String get aiSuggestDraftTitle => 'AI Draft';

  @override
  String get aiSuggestSuggestionTitle => 'AI Suggestion';

  @override
  String get aiSuggestYourText => 'Your text:';

  @override
  String get aiSuggestDraftLabel => 'AI draft:';

  @override
  String get aiSuggestSuggestionLabel => 'AI suggestion:';

  @override
  String aiSuggestReviewCarefully(String notAdvice) {
    return '$notAdvice Review carefully.';
  }

  @override
  String get aiSuggestDismiss => 'Dismiss';

  @override
  String get aiSuggestAddToMine => 'Add to mine';

  @override
  String get aiSuggestUseDraft => 'Use this draft';

  @override
  String get aiSuggestUseInstead => 'Use instead';

  @override
  String get aiSuggestAppliedA11y => 'AI suggestion applied. Undo available.';

  @override
  String get aiSuggestApplied => 'AI suggestion applied.';

  @override
  String get aiSuggestUndo => 'Undo';

  @override
  String aiSuggestLoadingA11y(String fieldName) {
    return 'AI Suggest, loading suggestion for $fieldName';
  }

  @override
  String aiSuggestForFieldA11y(String fieldName) {
    return 'AI Suggest for $fieldName';
  }

  @override
  String get aiSuggestSetupA11y => 'Set up AI Assistant to use suggestions';

  @override
  String get aiSuggestTooltip => 'Get an AI suggestion for this field';

  @override
  String get aiSuggestSetupTooltip => 'Set up AI Assistant to use this feature';

  @override
  String get aiSuggestIconTooltip => 'AI suggestion';

  @override
  String get contactSheetPermissionRequired =>
      'Contact permission is required to import.';

  @override
  String get contactSheetRolePrimaryAgent => 'primary agent';

  @override
  String get contactSheetPickYour => 'Pick your ';

  @override
  String get contactSheetLocalOnly =>
      'From your phone\'s contacts. We never upload them — search runs locally.';

  @override
  String get contactSheetSearchHint => 'Search by name or number';

  @override
  String get contactSheetClearSearch => 'Clear search';

  @override
  String contactSheetContactsCount(int count) {
    return 'Contacts · $count';
  }

  @override
  String get contactSheetPickAContact => 'Pick a contact';

  @override
  String contactSheetUseName(String name) {
    return 'Use $name';
  }

  @override
  String get contactSheetThisContact => 'this contact';

  @override
  String get contactSheetLooksLikeProvider => 'Looks like a provider';

  @override
  String get contactSheetUnder18 => 'Under 18';

  @override
  String contactSheetWarnConfirm(String note) {
    return '⚠ $note — confirm they\'re not treating you';
  }

  @override
  String get contactSheetEligible => '✓ Eligible · 18+';

  @override
  String get contactSheetEnterManually => 'Enter someone manually';

  @override
  String get contactSheetHardBlock => 'hard block';

  @override
  String get contactSheetSoftWarn => 'soft warn';

  @override
  String get contactSheetRuleProvider =>
      'Your current treating provider or their employee';

  @override
  String get contactSheetRuleFacilityOwner =>
      'An owner/operator of a facility where you receive care';

  @override
  String get contactSheetWhoCantBeAgent => 'Who can\'t be your agent';

  @override
  String get contactSheetRulesFootnote =>
      'Under-18 is blocked automatically from the contact\'s birthday. We can\'t tell who your providers are, so anything that looks like a provider is a soft warning you can override — confirm only if they truly aren\'t treating you.';

  @override
  String get voiceMicPermission => 'Microphone permission is needed.';

  @override
  String get voiceTranscribeFailed =>
      'Couldn\'t transcribe. Try again, or type it instead.';

  @override
  String get voiceSpeechError => 'Speech recognition error.';

  @override
  String get voiceNeedsBrowser => 'Voice needs Chrome, Edge, or Safari.';

  @override
  String get voiceNotAvailable =>
      'Speech recognition is not available on this device.';

  @override
  String get voiceStatusTranscribing => '● Transcribing';

  @override
  String get voiceStatusRecording => '● Recording';

  @override
  String get voiceStatusPaused => '● Paused';

  @override
  String get voiceSayItYourWay => 'Say it your way.';

  @override
  String get voiceExplainAi =>
      'For better accuracy on medication names and conditions, your recording goes to Google\'s AI to transcribe. Review the text before saving.';

  @override
  String get voiceExplainBrowser =>
      'To transcribe, your browser sends the audio to its speech service (often Google). We don\'t keep the audio or text — edit it before saving.';

  @override
  String get voiceExplainDevice =>
      'Your device turns speech into text. We never store the audio — you can edit before saving.';

  @override
  String get voiceEmptyHintAi =>
      'Tap the red button, speak, then tap stop to transcribe…';

  @override
  String get voiceEmptyHintLive =>
      'Tap the red record button and start speaking…';

  @override
  String get voiceCancelA11y => 'Cancel voice recording';

  @override
  String get voiceConfirmA11y => 'Confirm and use transcript';

  @override
  String get voiceFooterAi =>
      'WE STORE NOTHING · GOOGLE\'S AI TRANSCRIBES THE RECORDING';

  @override
  String get voiceFooterBrowser =>
      'WE STORE NOTHING · YOUR BROWSER\'S SPEECH SERVICE TRANSCRIBES THE AUDIO';

  @override
  String get voiceFooterDevice =>
      'AUDIO ISN\'T SAVED · TRANSCRIPT STAYS IN THIS SESSION';

  @override
  String get voiceTranscribingCard => 'Transcribing your recording…';

  @override
  String get voiceStopRecording => 'Stop recording';

  @override
  String get voiceStartRecording => 'Start recording';

  @override
  String get pipelineGeneratingSuggestions =>
      'AI is generating personalized suggestions...';

  @override
  String get pipelineNoAdditionalSuggestions =>
      'AI could not generate additional suggestions.';

  @override
  String pipelineAutofillProblem(String error) {
    return 'Autofill hit a problem. $error';
  }

  @override
  String pipelineAppliedA11y(int count) {
    return 'Autofill applied $count fields to your directive';
  }

  @override
  String get pipelineAppliedNoneA11y =>
      'Autofill finished — no new fields were added';

  @override
  String get pipelinePastedImage => 'Pasted image';

  @override
  String get pipelineDocument => 'Document';

  @override
  String get pipelineKindPdf => 'PDF';

  @override
  String get pipelineKindPhoto => 'Photo';

  @override
  String get pipelineKindText => 'Text';

  @override
  String get pipelineKindAudio => 'Audio';

  @override
  String get pipelineKindFile => 'File';

  @override
  String get pipelineCancelled => 'Processing cancelled — nothing was applied.';

  @override
  String get pipelineSetupAiTitle => 'Set up AI to read documents';

  @override
  String get pipelineSetupAiBody =>
      'Snap-to-fill uses AI to read your uploaded document (photo, PDF, or text) and pull out details to fill your form — medications, conditions, care preferences, and your contact details. It needs an AI key — Gemini\'s free tier takes about 30 seconds to set up. You review every field before anything lands in your form.';

  @override
  String get pipelineSetupAi => 'Set up AI';

  @override
  String get pipelineDroppedFile => 'Dropped file';

  @override
  String get pipelineUnsupportedType =>
      'That file type isn\'t supported. Use a JPG, PNG, HEIC, PDF, or text file.';

  @override
  String pipelineRpmLimit(int pages, int remaining, int seconds) {
    return 'Processing $pages pages requires $pages requests, but only $remaining requests are available this minute. Please wait $seconds seconds or select fewer pages.';
  }

  @override
  String pipelineRpdLimit(int pages, int remaining, int limit) {
    return 'Processing $pages pages requires $pages requests, but only $remaining requests remain today (daily limit: $limit).';
  }

  @override
  String pipelineFileTooLarge(String name, String sizeMb) {
    return 'File \"$name\" is too large ($sizeMb MB). Maximum file size is 10 MB per document.';
  }

  @override
  String pipelineExtractingPage(int current, int total) {
    return 'Extracting page $current of $total...';
  }

  @override
  String get pipelineExtractingSingle =>
      'Extracting medical data from document...';

  @override
  String pipelineLooksLikeKind(String kind) {
    return ' (it looks like a $kind)';
  }

  @override
  String pipelineNotMedicalSingle(String kind) {
    return 'This doesn\'t look like a health or medical document$kind, so nothing was used. Upload a medical record, medication or allergy list, or an existing advance directive.';
  }

  @override
  String pipelineNotMedicalMulti(String kind) {
    return 'These don\'t look like health or medical documents$kind, so nothing was used.';
  }

  @override
  String get pipelineNoMedicalInfoSingle =>
      'No medical information found in this document.';

  @override
  String pipelineNoMedicalInfoMulti(int count) {
    return 'No medical information found in these $count pages.';
  }

  @override
  String get pipelineValidating => 'Validating medications and conditions...';

  @override
  String get pipelinePleaseWait => 'Please wait while processing...';

  @override
  String get pipelineBackWizard => 'Wizard';

  @override
  String get pipelineBackReview => 'Review';

  @override
  String get pipelineTitleSnapToFill => 'Snap to fill';

  @override
  String get pipelineTitleProcessing => 'Processing';

  @override
  String get pipelineTitleReview => 'Review Extracted Data';

  @override
  String get pipelineTitleGenerating => 'Generating Suggestions';

  @override
  String get pipelineTitleResults => 'AI Suggestions';

  @override
  String pipelinePickerFailed(String error) {
    return 'Couldn\'t open the file picker ($error). Try dragging the file onto the box above instead.';
  }

  @override
  String get pipelineCouldNotRead =>
      'We couldn\'t read that file. Please use a PDF, JPG, PNG, WEBP, HEIC, or plain-text file under 10 MB.';

  @override
  String get pipelineFormCombined => 'Combined';

  @override
  String get pipelineFormDeclaration => 'Declaration only';

  @override
  String get pipelineFormPoa => 'Power of Attorney only';

  @override
  String get pipelineFormCombinedSub =>
      'Treatment preferences AND a decision-maker (broadest).';

  @override
  String get pipelineFormDeclarationSub =>
      'Treatment preferences, without naming an agent.';

  @override
  String get pipelineFormPoaSub =>
      'Name a decision-maker, without listing preferences.';

  @override
  String get pipelineWhichForm => 'Which form do you want to fill?';

  @override
  String get pipelineWhichFormBody =>
      'Choose your form first — the AI will then read only the parts that form needs. Combined is the broadest; you can change this later.';

  @override
  String get pickSnapOptional => 'Snap to fill · optional';

  @override
  String get pickHeadlineLead => 'Have a photo handy? ';

  @override
  String get pickHeadlineAccent => 'We\'ll read it.';

  @override
  String get pickIntro =>
      'Drop a photo, PDF, or audio recording — ID, medication list, prescription label, an old directive, or just describe your wishes out loud — and the AI will extract what it can. You review every field before it lands in the form. Or skip and type it all yourself.';

  @override
  String get pickPrivacyNote =>
      'Your privacy: black out anything sensitive before uploading. You never have to upload personal details at all — any field can be typed in by hand to keep it confidential.';

  @override
  String get pickVoiceGuideLink =>
      'Recording a voice file? See the questionnaire & how-to';

  @override
  String get pickSkipTypeAll => 'Skip — I\'ll type it all';

  @override
  String get pickContinueStep2 => 'Continue to step 2';

  @override
  String get pickYourDocuments => 'Your documents';

  @override
  String pickFilesKeptInMemory(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count FILES · KEPT IN MEMORY',
      one: '1 FILE · KEPT IN MEMORY',
    );
    return '$_temp0';
  }

  @override
  String get pickClearAll => 'Clear all';

  @override
  String get pickHeldWithKey =>
      'Held on this device. Nothing is sent until you tap Read — then it goes to your AI provider to read.';

  @override
  String get pickHeldNoKey =>
      'Held on this device. Reading needs AI set up first (free, ~30 seconds) — nothing is sent until then.';

  @override
  String pickReadWithAi(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Read $count documents with AI',
      one: 'Read this document with AI',
    );
    return '$_temp0';
  }

  @override
  String get pickRemove => 'Remove';

  @override
  String get pickNoKeyTitle => 'AI isn\'t set up yet';

  @override
  String get pickNoKeyBody =>
      'You can see how snap-to-fill works below, but reading a real photo or PDF needs an AI key (Gemini\'s free tier takes about 30 seconds). You review every field before it lands in your form.';

  @override
  String get pickTryAgain => 'Try again';

  @override
  String get pickDropTitleCamera => 'Add a photo of your document';

  @override
  String get pickDropTitle => 'Drop a photo, PDF, or screenshot';

  @override
  String pickFormatsPaste(String shortcut) {
    return 'JPG · PNG · HEIC · PDF · up to 10 MB — or paste with $shortcut';
  }

  @override
  String get pickFormats => 'JPG · PNG · HEIC · PDF · up to 10 MB';

  @override
  String get pickBrowseFiles => 'Browse files';

  @override
  String get pickTakePhoto => 'Take a photo';

  @override
  String get pickSentToProvider =>
      'To autofill, your file — including any personal details in it — is sent to your AI provider to read. The app saves nothing (it\'s gone when this tab closes), but the provider may retain it (Gemini\'s free tier does). You review everything before it is added to your directive.';

  @override
  String get pickTargetId => 'Photo of ID';

  @override
  String get pickTargetIdSub => 'Name · DOB · address';

  @override
  String get pickTargetRx => 'Rx bottle / label';

  @override
  String get pickTargetRxSub => 'Drug · dose · schedule';

  @override
  String get pickTargetConditions => 'Conditions list';

  @override
  String get pickTargetConditionsSub => 'Diagnoses · allergies';

  @override
  String get pickTargetOther => 'Anything else';

  @override
  String get pickTargetOtherSub => 'Notes, old directive…';

  @override
  String get pickTargetOtherSubMobile => 'Old directive, notes…';

  @override
  String get pickWhatYouCanAdd => 'What you can add';

  @override
  String get pickWhatYouCanDrop => 'What you can drop here';

  @override
  String get pickOnAPhone => 'On a phone instead?';

  @override
  String get pickOnAPhoneBody =>
      'Open this page on your phone to snap a page directly with its camera.';

  @override
  String get pickTakePhotoSub =>
      'Opens your camera. Snap your ID, Rx label, anything.';

  @override
  String get pickPickFile => 'Pick a file';

  @override
  String get pickPickFileSub =>
      'From your photos or files. JPG, PNG, HEIC, PDF.';

  @override
  String get pickWhatHelpsMost => 'What helps most';

  @override
  String get pickFastest => 'FASTEST';

  @override
  String get pickSentToProviderShort =>
      'Your file (including any personal details) is sent to your AI provider to read it. The app saves nothing; the provider may retain it (Gemini\'s free tier does). You review before anything is added.';

  @override
  String pickReadingDocs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reading $count documents:',
      one: 'Reading 1 document:',
    );
    return '$_temp0';
  }

  @override
  String pickReadByAi(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files read by Google\'s AI to autofill.',
      one: 'Read by Google\'s AI to autofill.',
    );
    return '$_temp0';
  }

  @override
  String get reviewLabelMedPrefer => 'Preferred Medication';

  @override
  String get reviewLabelMedAvoid => 'Medication to Avoid';

  @override
  String get reviewLabelMedCurrent => 'Currently Taking';

  @override
  String get reviewLabelMedLimit => 'Restricted-Use Medication';

  @override
  String get reviewLabelCond => 'Condition';

  @override
  String get reviewLabelDiag => 'Diagnosis';

  @override
  String get reviewLabelAllergy => 'Allergy';

  @override
  String get reviewLabelHh => 'Health History';

  @override
  String get reviewLabelEffectiveCondition => 'When this kicks in (your words)';

  @override
  String get reviewLabelFacilityPrefer => 'Preferred Facility';

  @override
  String get reviewLabelFacilityAvoid => 'Facility to Avoid';

  @override
  String get reviewLabelDietary => 'Dietary';

  @override
  String get reviewLabelReligious => 'Religious/Cultural';

  @override
  String get reviewLabelActivities => 'Activities';

  @override
  String get reviewLabelCrisis => 'Crisis Intervention';

  @override
  String get reviewLabelCrisisPlan => 'Crisis plan';

  @override
  String get reviewLabelAgentAuthorityLimitations => 'Agent authority limits';

  @override
  String get reviewLabelEctConsent => 'ECT consent';

  @override
  String get reviewLabelExperimentalConsent => 'Experimental treatment consent';

  @override
  String get reviewLabelDrugTrialConsent => 'Drug trial consent';

  @override
  String get reviewLabelMedicationConsent => 'Medication consent';

  @override
  String get reviewLabelTriggerTwoProfessionals => 'Trigger: professionals';

  @override
  String get reviewLabelTriggerCourtOrder => 'Trigger: court order';

  @override
  String get reviewLabelTriggerInvoluntaryCommitment =>
      'Trigger: involuntary commitment';

  @override
  String get reviewLabelRoomPrefsNote => 'Room preferences';

  @override
  String get reviewLabelRoomPrefChips => 'Room options';

  @override
  String get reviewLabelRoommateSameGender => 'Same-gender roommate';

  @override
  String get reviewLabelGuardianCanRevoke => 'Guardian: override';

  @override
  String get reviewLabelGuardianCanChangeAgent => 'Guardian: replace agent';

  @override
  String get reviewLabelGuardianMustConsultAgent => 'Guardian: consult agent';

  @override
  String get reviewLabelAuthorityHospitalization => 'Agent: hospitalization';

  @override
  String get reviewLabelAuthorityMedication => 'Agent: medications';

  @override
  String get reviewLabelUlyssesOptin => 'Self-binding (Ulysses)';

  @override
  String get reviewLabelPetCustody => 'Pet care';

  @override
  String get reviewLabelChildrenCustody => 'Children / dependents';

  @override
  String get reviewLabelFamilyNotification => 'Who to notify';

  @override
  String get reviewLabelRecordsDisclosure => 'Records disclosure';

  @override
  String get reviewLabelOther => 'Other';

  @override
  String get reviewLabelPersonName => 'Your full name';

  @override
  String get reviewLabelPersonDob => 'Date of birth';

  @override
  String get reviewLabelPersonAddress1 => 'Street address';

  @override
  String get reviewLabelPersonAddress2 => 'Apt / suite / unit';

  @override
  String get reviewLabelPersonCity => 'City';

  @override
  String get reviewLabelPersonCounty => 'County';

  @override
  String get reviewLabelPersonState => 'State';

  @override
  String get reviewLabelPersonZip => 'ZIP code';

  @override
  String get reviewLabelPersonPhone => 'Your phone';

  @override
  String get reviewLabelPersonDoctorName => 'Primary doctor';

  @override
  String get reviewLabelPersonDoctorSpecialty => 'Doctor specialty';

  @override
  String get reviewLabelPersonDoctorPhone => 'Doctor\'s phone';

  @override
  String get reviewLabelPersonEvalDoctorName => 'Preferred evaluating doctor';

  @override
  String get reviewLabelPersonEvalDoctorContact => 'Evaluating doctor contact';

  @override
  String get reviewLabelAgentName => 'Agent name';

  @override
  String get reviewLabelAgentRelationship => 'Agent relationship';

  @override
  String get reviewLabelAgentAddress1 => 'Agent street address';

  @override
  String get reviewLabelAgentAddress2 => 'Agent apt / suite';

  @override
  String get reviewLabelAgentCity => 'Agent city';

  @override
  String get reviewLabelAgentState => 'Agent state';

  @override
  String get reviewLabelAgentZip => 'Agent ZIP';

  @override
  String get reviewLabelAgentPhone => 'Agent phone';

  @override
  String get reviewLabelAltAgentName => 'Alternate agent name';

  @override
  String get reviewLabelAltAgentRelationship => 'Alternate agent relationship';

  @override
  String get reviewLabelAltAgentAddress1 => 'Alt agent street address';

  @override
  String get reviewLabelAltAgentAddress2 => 'Alt agent apt / suite';

  @override
  String get reviewLabelAltAgentCity => 'Alt agent city';

  @override
  String get reviewLabelAltAgentState => 'Alt agent state';

  @override
  String get reviewLabelAltAgentZip => 'Alt agent ZIP';

  @override
  String get reviewLabelAltAgentPhone => 'Alternate agent phone';

  @override
  String get reviewLabelGuardianName => 'Guardian nominee';

  @override
  String get reviewLabelGuardianRelationship => 'Guardian relationship';

  @override
  String get reviewLabelGuardianAddress1 => 'Guardian street address';

  @override
  String get reviewLabelGuardianAddress2 => 'Guardian apt / suite';

  @override
  String get reviewLabelGuardianCity => 'Guardian city';

  @override
  String get reviewLabelGuardianState => 'Guardian state';

  @override
  String get reviewLabelGuardianZip => 'Guardian ZIP';

  @override
  String get reviewLabelGuardianPhone => 'Guardian phone';

  @override
  String get reviewSectionMedPrefer => 'Preferred Meds';

  @override
  String get reviewSectionMedAvoid => 'Meds to Avoid';

  @override
  String get reviewSectionMedCurrent => 'Currently Taking';

  @override
  String get reviewSectionMedLimit => 'Restricted-Use Meds';

  @override
  String get reviewSectionCond => 'Conditions';

  @override
  String get reviewSectionDiag => 'Diagnoses';

  @override
  String get reviewSectionAllergy => 'Allergies';

  @override
  String get reviewSectionHh => 'Health History';

  @override
  String get reviewSectionEffectiveCondition => 'When this kicks in';

  @override
  String get reviewSectionPerson => 'Your details';

  @override
  String get reviewSectionAgent => 'Your agent';

  @override
  String get reviewSectionAgentAuthority => 'Agent Authority';

  @override
  String get reviewSectionUlyssesOptin => 'Self-binding';

  @override
  String get reviewSectionCrisisPlan => 'Crisis Plan';

  @override
  String get reviewSectionConsent => 'Consent';

  @override
  String get reviewSectionRoomPreferences => 'Room Preferences';

  @override
  String get reviewSectionAltAgent => 'Alternate agent';

  @override
  String get reviewSectionGuardian => 'Guardian';

  @override
  String get reviewSectionOther => 'Other';

  @override
  String get reviewStepGroupWhenKicksIn => 'When this kicks in';

  @override
  String get reviewStepGroupDiagnoses => 'Diagnoses';

  @override
  String get reviewStepGroupAboutYou => 'About you';

  @override
  String get reviewStepGroupPeopleITrust => 'People I trust';

  @override
  String get reviewStepGroupGuardian => 'If a court appoints a guardian';

  @override
  String get reviewStepGroupWhereIWantCare => 'Where I want care';

  @override
  String get reviewStepGroupMedications => 'Medications';

  @override
  String get reviewStepGroupAllergies => 'Allergies & reactions';

  @override
  String get reviewStepGroupProceduresResearch => 'Procedures & research';

  @override
  String get reviewStepGroupAnythingElse => 'Anything else';

  @override
  String get reviewAiReadThisPhoto => 'AI READ THIS PHOTO';

  @override
  String get reviewHeresWhatWeRead => 'Here\'s what we read.';

  @override
  String get reviewHowToIntro =>
      'These are the details the AI pulled from your document. Here\'s how to use this page:';

  @override
  String get reviewHowToChecked =>
      'A checked box means it will be added to your form. Uncheck anything you don\'t want.';

  @override
  String get reviewHowToEdit =>
      'Tap any field to edit its wording before it\'s added.';

  @override
  String get reviewHowToGrouped =>
      'Results are grouped by form section (the same steps you\'ll see next). A \"Replaces what you have\" note means it would overwrite something you already entered — those start unchecked.';

  @override
  String reviewHowToFinish(String buttonLabel) {
    return 'When you\'re ready, tap \"$buttonLabel\" at the bottom to fill these into your form and continue — you\'ll land in the form to review everything.';
  }

  @override
  String reviewPiiRemoved(String items) {
    return 'PII was detected and removed before analysis: $items';
  }

  @override
  String get reviewAddToDirective => 'Add to your directive';

  @override
  String get reviewPhotoDiscarded =>
      'Your photo was sent to the AI to read, then discarded. Nothing is stored after you confirm or discard.';

  @override
  String reviewFieldsReady(int checked, int total) {
    return '$checked of $total fields ready to add';
  }

  @override
  String get reviewYouEntered => 'You entered';

  @override
  String get reviewAutofillFound => 'Autofill found';

  @override
  String get reviewKeepMine => 'Keep mine';

  @override
  String get reviewUseNew => 'Use new';

  @override
  String get reviewAddBoth => 'Add both';

  @override
  String get reviewConsolidateAi => 'Consolidate (AI)';

  @override
  String get reviewIdentityNotMerged =>
      'Identity fields aren\'t merged by the AI — double-check this one yourself.';

  @override
  String get reviewWillSave => 'Will save:';

  @override
  String get reviewSetupAiToConsolidate =>
      'Set up the AI assistant first to consolidate.';

  @override
  String get reviewAgentInitialsNote =>
      'This lets your agent decide. Under PA law (§5836(c)) it only takes effect if you physically initial this authorization on the printed form — confirm this is what you want.';

  @override
  String get reviewSmartIntro =>
      'The AI generated these additional suggestions based on your validated conditions and medications. Tap to edit, uncheck to skip. This is not medical or legal advice.';

  @override
  String get reviewGuidanceOnly =>
      'Guidance to read — not saved to your form. Set your choice in Procedures & research.';

  @override
  String get reviewAutofillInformation => 'Autofill Information';

  @override
  String get reviewApplyAll => 'Apply All';

  @override
  String get reviewDiscardAll => 'Discard all';

  @override
  String get reviewGenerateMore => 'Generate more';

  @override
  String get reviewIncludeField => 'Include this field';

  @override
  String get reviewNotAdded => 'Not added';

  @override
  String get reviewEdit => 'Edit';

  @override
  String get homeMakeItFindableInA => 'Make it findable in a crisis';

  @override
  String get homeShareCopiesCarryTheWallet =>
      'Share copies, carry the wallet card, tell your people where it is';

  @override
  String get homeSessionRestoredPersonalInfoMust =>
      'Session restored. Personal info must be re-entered.';

  @override
  String get homeDeleteDirective => 'Delete directive?';

  @override
  String get homeAllDataForThisDirective =>
      'All data for this directive will be permanently deleted.';

  @override
  String get homeDirectiveDeleted => 'Directive deleted.';

  @override
  String get homeRenameDirective => 'Rename directive';

  @override
  String get homeRenewDirective => 'Renew Directive?';

  @override
  String get homeThisWillCreateANew =>
      'This will create a new directive with the same treatment preferences and agent designations. Personal information, witnesses, and signatures will need to be re-entered.\n\nThe original directive will remain unchanged.';

  @override
  String get homeRenew => 'Renew';

  @override
  String get homeAmendThisDirective => 'Amend this directive?';

  @override
  String get homeAmendingOpensThisDirectiveSo =>
      'Amending opens this directive so you can change it — your existing answers stay in place.\n\nImportant: an amendment is only valid once you re-sign it on paper with two adult witnesses, the same way as the original (PA Act 194). Until you re-sign, this directive will show as an unsigned draft, and any printed copies of the old version stay in effect until you replace them.\n\nPrefer to keep the signed original untouched? Use “Renew (copy to new)” instead.';

  @override
  String get homeAmend => 'Amend';

  @override
  String get homePrivateByDesign => 'Private by design';

  @override
  String get homeLetSGetStarted => 'Let\'s get started.';

  @override
  String get homeRename => 'Rename';

  @override
  String get homeLabelShownInThisList =>
      'Label shown in this list only — never printed';

  @override
  String get homeRenewCopyToNew => 'Renew (copy to new)';

  @override
  String get homeAmendEditThisOne => 'Amend (edit this one)';

  @override
  String get homeRequiresReSigningReWitnessing =>
      'Requires re-signing & re-witnessing';

  @override
  String get homeRevoke => 'Revoke';

  @override
  String get homeTools => 'Tools';

  @override
  String get homePastDirectives => 'Past directives';

  @override
  String get homeStartANewDirective => 'Start a new directive';

  @override
  String get homeLoadingYourDirectives => 'Loading your directives';

  @override
  String get homeDisplayLabel => 'Display label';

  @override
  String get homeShownOnlyInThisList =>
      'Shown only in this list — never printed on the form. Leave empty to use the name on the directive.';

  @override
  String get homeCouldnTLoadYourDirectives => 'Couldn\'t load your directives.';

  @override
  String get homeNothingWasLostThisIs =>
      'Nothing was lost — this is a display problem, not a data one.';

  @override
  String get homeYourVoice => 'Your voice,\n';

  @override
  String get homeInYourWords => 'in your words.';

  @override
  String get homeLetSKeepYourVoice => 'Let\'s keep your voice clear.';

  @override
  String get homeStartYourDirective => 'Start your directive';

  @override
  String get homePrivateBodyWeb =>
      'Your directive never leaves this browser — no server, no account, no tracking. It lives only in this session, and only you choose who to share it with.';

  @override
  String get homePrivateBodyDevice =>
      'Your directive stays on your device. No ads, no tracking, no selling your data — only you choose who to share it with.';

  @override
  String homeHiName(String name) {
    return 'Hi, $name.\n';
  }

  @override
  String homeProfileA11y(String name) {
    return 'Profile $name';
  }

  @override
  String homeCardDraft(int step, int total, String date) {
    return 'Draft · step $step of $total · $date';
  }

  @override
  String homeCardPrepared(String date) {
    return 'Prepared · $date';
  }

  @override
  String get homeCardExpired => 'Expired · revoke or copy to new';

  @override
  String homeCardRevoked(String date) {
    return 'Revoked · $date';
  }

  @override
  String homeCardDirectiveYear(int year) {
    return 'Directive · $year';
  }

  @override
  String homeCardA11y(String name, String status) {
    return '$name. $status. Tap to open.';
  }

  @override
  String get crisisPlanHelpThePeopleAroundYou =>
      'Help the people around you spot trouble early — and know what actually helps you when they do.';

  @override
  String get crisisPlanAdd => 'Add';

  @override
  String get crisisPlanAdd2 => '+ Add';

  @override
  String get crisisPlanOptionalAddOnCrisisPlan =>
      'Optional add-on · Crisis plan';

  @override
  String get crisisPlanEarlyWarningSigns => 'Early warning signs';

  @override
  String get crisisPlanTriggersToWatchFor => 'Triggers to watch for';

  @override
  String get crisisPlanThingsThatGenuinelyHelp => 'Things that genuinely help';

  @override
  String get crisisPlanThingsToSayToMe => 'Things to say to me';

  @override
  String get crisisPlanDonTDoThese => 'Don\'t do these';

  @override
  String get crisisPlanTypeAShortNote => 'Type a short note';

  @override
  String get permissionsOverviewPaMhadRequestsSystemPermissions =>
      'PA MHAD requests system permissions only for features you actively use. Nothing is collected in the background. Each section below explains exactly what a permission unlocks, what the app does with the result, and what it never does.';

  @override
  String get permissionsOverviewWhatThisAppMayAsk =>
      'What this app may ask for';

  @override
  String get permissionsOverviewBiometricsPasscode => 'Biometrics / passcode';

  @override
  String get permissionsOverviewNotifications => 'Notifications';

  @override
  String get permissionsOverviewCamera => 'Camera';

  @override
  String get permissionsOverviewMicrophone => 'Microphone';

  @override
  String get permissionsOverviewContacts => 'Contacts';

  @override
  String get makeItFindableADirectiveOnlyHelpsIf =>
      'A directive only helps if the people treating you can find it when you cannot speak for yourself. Take a few minutes now to put copies where they will be looked for.';

  @override
  String get makeItFindableThisIsGeneralInformationAbout =>
      'This is general information about keeping your directive accessible, not legal advice.';

  @override
  String get makeItFindableCrisisReadiness => 'Crisis readiness';

  @override
  String get makeItFindableDoTheseNow => 'Do these now';

  @override
  String get makeItFindableShareItWithYourAgent =>
      'Share it with your agent and a trusted person';

  @override
  String get makeItFindableTheyShouldEachHaveA =>
      'They should each have a copy before any crisis — not only you.';

  @override
  String get makeItFindableGiveACopyToYour => 'Give a copy to your care team';

  @override
  String get makeItFindableAskYourPsychiatristTherapistPrimary =>
      'Ask your psychiatrist, therapist, primary-care doctor, and any facility to add it to your medical record.';

  @override
  String get makeItFindablePrintAndCarryTheWallet =>
      'Print and carry the wallet card';

  @override
  String get makeItFindableAPocketCardThatTells =>
      'A pocket card that tells responders you have a directive and how to reach your agent.';

  @override
  String get adminUpdateFederalRegisterRelevantFederalRules =>
      'Federal Register — relevant federal rules';

  @override
  String get adminUpdateFederalRulesTheAppReferences =>
      'Federal rules the app references. Use a link as the SOURCE for a verify-tier legal/dated change. State law (PA Act 194) is not covered here.';

  @override
  String get adminUpdateOpen => 'Open';

  @override
  String get adminUpdateSourceLinkCopied => 'Source link copied';

  @override
  String get adminUpdateCopyLink => 'Copy link';

  @override
  String get adminUpdateRestoreFromWhichBackup => 'Restore from which backup?';

  @override
  String get adminUpdateAdminDataUpdate => 'Admin · data update';

  @override
  String get adminUpdateEnterTheAdminPassphrase =>
      'Enter the admin passphrase.';

  @override
  String get adminUpdateUnlock => 'Unlock';

  @override
  String get adminUpdateDescribeTheUpdateTheAi =>
      'Describe the update. The AI drafts changes to the selected file with sources; you review and approve before anything is emitted. Legal/statutory and educational changes always need your explicit sign-off.';

  @override
  String get adminUpdateRevert => 'Revert';

  @override
  String get adminUpdateCheckBestGeminiModel => 'Check best Gemini model';

  @override
  String get adminUpdateCheckFederalRegister => 'Check Federal Register';

  @override
  String get adminUpdateCopiedUpdatedJson => 'Copied updated JSON';

  @override
  String get adminUpdateCopyJson => 'Copy JSON';

  @override
  String get adminUpdateAnotherUpdate => 'Another update';

  @override
  String get adminUpdatePassphrase => 'Passphrase';

  @override
  String get adminUpdateWhatToUpdate => 'What to update';

  @override
  String get adminUpdateAiProvider => 'AI provider';

  @override
  String get adminUpdateModel => 'Model';

  @override
  String get adminUpdateDescribeTheUpdate => 'Describe the update *';

  @override
  String get adminUpdateEGTheTrevorProject =>
      'e.g. \"The Trevor Project number changed to ...\" or \"Check Gemini\'s current free-tier rate limits\"';

  @override
  String get adminUpdateRequiredWhatShouldTheAi =>
      'Required — what should the AI draft a change to?';

  @override
  String get adminUpdateFocusAreaPathOptional => 'Focus area / path (optional)';

  @override
  String get adminUpdateRestrictTheAiToOne =>
      'Restrict the AI to one spot, e.g. \"config.timeoutsSeconds\" or \"sections.faq_valid\".';

  @override
  String get reminderSheetsQuickRenew5Min => 'Quick renew · ~5 min';

  @override
  String get reminderSheetsMostPeopleKeepTheSame =>
      'Most people keep the same answers. We\'ll pre-fill all 11 sections from your current directive — tap any card to change it, then print and sign the new copy in ink with two witnesses.';

  @override
  String get reminderSheetsStartQuickRenew => 'Start quick renew';

  @override
  String get reminderSheetsRemindMeNextWeek => 'Remind me next week';

  @override
  String get reminderSheetsWeLlRemindYouAgain =>
      'We\'ll remind you again 7 days before expiration.';

  @override
  String get reminderSheetsAnythingChanged => 'Anything changed?';

  @override
  String get reminderSheetsStillAccurateAllGood => 'Still accurate — all good';

  @override
  String get reminderSheetsEditMyDirective => 'Edit my directive';

  @override
  String get reminderSheetsIfYouEditAnythingYou =>
      'If you edit anything, you\'ll re-print and sign that updated copy in ink. Small changes can wait for your 2-year renewal.';

  @override
  String get reminderSheets3MonthCheckIn => '● 3-month check-in';

  @override
  String get reminderSheetsCommonThingsThatChange =>
      'Common things that change';

  @override
  String get reminderSheetsStillTheRightPeople => 'Still the right people?';

  @override
  String get reminderSheetsMedicationsUpToDate => 'Medications up to date?';

  @override
  String get reminderSheetsCarePreferencesStillRight =>
      'Care preferences still right?';

  @override
  String get reminderSheetsPaDirectivesExpireAfter2 =>
      'PA directives expire after 2 years. Yours runs out on ';

  @override
  String get reminderSheetsIfYouAreIncapableOf =>
      '. (If you are incapable of making mental health decisions when it would expire, it stays in effect until your capacity returns.)';

  @override
  String get reminderSheetsYourDirectiveIsStillValid =>
      'Your directive is still valid through ';

  @override
  String get reminderSheetsNoSigningNeededJustA =>
      ' — no signing needed. Just a quick gut-check that it still fits your life.';

  @override
  String get revocationMarkedRevokedOnThisDevice =>
      'Marked revoked on this device';

  @override
  String get revocationPer20PaCS =>
      'Per 20 Pa.C.S. §§ 5825 and 5839, revocation is effective only when communicated to your attending physician or provider. Marking this directive revoked here does not communicate it — you still need to tell each recipient.';

  @override
  String get revocationYouPickedTheseRecipientsTo =>
      'You picked these recipients to notify:';

  @override
  String get revocationContactEachRecipientYourselfCall =>
      'Contact each recipient yourself — call or email them — and ask the receiving provider to record the revocation in your chart. Revocation takes effect once your provider has been told.';

  @override
  String get revocationYourDirectiveWillNoLonger =>
      'Your directive will no longer be legally binding once you communicate the revocation to your attending physician or provider (20 Pa.C.S. §§ 5825, 5839). This app marks the directive revoked locally and helps you generate a revocation letter.';

  @override
  String get revocationThisDeclarationMayBeRevoked =>
      'This declaration may be revoked in whole or in part at any time, either orally or in writing, as long as I have not been found to be incapable of making mental health decisions. My revocation will be effective upon communication to my attending physician or other mental health care provider, either by me or a witness to my revocation, of the intent to revoke.';

  @override
  String get revocationNoBatchSendsPickEach =>
      'No batch sends — pick each recipient. The app keeps your choices in front of you as a checklist; you contact each recipient yourself (call, email, or in person).';

  @override
  String get revocationTypeRevokeToConfirm => 'Type REVOKE to confirm';

  @override
  String get revocationHowRevocationWorksInPa => 'How revocation works in PA';

  @override
  String get revocationStatutoryRevocationStatement =>
      'Statutory revocation statement';

  @override
  String get revocationWhoToNotifyOptIn =>
      'Who to notify (opt-in per recipient)';

  @override
  String get revocationPermanentAction => 'Permanent action';

  @override
  String get revocationRevoke => 'REVOKE';

  @override
  String get pastDirectiveDetailDeleteFromThisDevice =>
      'Delete from this device?';

  @override
  String get pastDirectiveDetailThisRemovesTheSavedDirective =>
      'This removes the saved directive from this device. The legal effect of any previously-signed paper copy is unchanged. This cannot be undone.';

  @override
  String get pastDirectiveDetailDirectiveDeletedFromThisDevice =>
      'Directive deleted from this device.';

  @override
  String get pastDirectiveDetailNoShareLogEntriesYet =>
      'No share log entries yet.';

  @override
  String get pastDirectiveDetailWeDonTTrackDelivery =>
      'We don\'t track delivery or receipt confirmation (that would need a server). Add entries manually as you distribute copies.';

  @override
  String get pastDirectiveDetailGeneratedOnDemand6Pages =>
      'Generated on demand · ~6 pages';

  @override
  String get pastDirectiveDetailWhoHadACopy => 'Who had a copy';

  @override
  String get pastDirectiveDetailActions => 'Actions';

  @override
  String get pastDirectiveDetailLoadingThisDirective =>
      'Loading this directive';

  @override
  String get pastDirectiveDetailCopyToANewDirective =>
      'Copy to a new directive';

  @override
  String get pastDirectiveDetailStartWithTheseAnswersComing =>
      'Start with these answers — coming with the renewal flow';

  @override
  String get pastDirectiveDetailOpenThePdf => 'Open the PDF';

  @override
  String get pastDirectiveDetailPrintOrSaveForYour =>
      'Print or save for your records';

  @override
  String get pastDirectiveDetailDeleteFromThisDevice2 =>
      'Delete from this device';

  @override
  String get pastDirectiveDetailSignedBy => 'SIGNED BY';

  @override
  String get pastDirectiveDetailWitness1 => 'WITNESS 1';

  @override
  String get pastDirectiveDetailWitness2 => 'WITNESS 2';

  @override
  String get pastDirectiveDetailDirective => 'Directive · ';

  @override
  String get pinDialogCreatePasscode => 'Create Passcode';

  @override
  String get pinDialogBiometricAuthenticationIsNotAvailable =>
      'Biometric authentication is not available on this device. Create a passcode to protect your private data.';

  @override
  String get pinDialogCreate => 'Create';

  @override
  String get pinDialogPaMhad => 'PA MHAD';

  @override
  String get pinDialogPrivateModeLocked => 'PRIVATE MODE · LOCKED';

  @override
  String get pinDialogEnterYourPasscodeToUnlock =>
      'Enter your passcode to unlock private mode.';

  @override
  String get pinDialogSwitchToPublicMode => 'Switch to public mode';

  @override
  String get pinDialogPasscode => 'Passcode';

  @override
  String get pinDialogAtLeast4Characters => 'At least 4 characters';

  @override
  String get pinDialogConfirmPasscode => 'Confirm Passcode';

  @override
  String get pinDialogUseYour => 'Use your ';

  @override
  String get pinDialogPasscode2 => 'passcode.';

  @override
  String get modeSelectionAuthenticationFailedOrWasCancelled =>
      'Authentication failed or was cancelled. Please try again.';

  @override
  String get modeSelectionHowShouldWeHandleYour =>
      'How should we handle your data?';

  @override
  String get modeSelectionYouCanChangeThisAnytime =>
      'You can change this anytime in Settings.';

  @override
  String get modeSelectionRecommended => 'RECOMMENDED';

  @override
  String get modeSelectionPrivacySetup => 'Privacy · setup';

  @override
  String get modeSelectionPrivateMode => 'Private mode';

  @override
  String get modeSelectionYourDataStaysOnThis =>
      'Your data stays on this device, encrypted. Unlock with biometrics or a passcode. You can come back to your draft anytime.';

  @override
  String get modeSelectionPublicMode => 'Public mode';

  @override
  String get modeSelectionNoDataIsSavedAfter =>
      'No data is saved after you close the app. Best for shared devices, or one-time use without leaving a trace.';

  @override
  String get sideEffectsForTheMedicationsYouRe =>
      'For the medications you\'re currently taking, here are common side effects — check the ones you actually have. Noting them (especially any that affect your daily activities) helps your care team. This is common-side-effect information, not medical advice.';

  @override
  String get sideEffectsSetUpAiToCheck => 'Set up AI to check side effects';

  @override
  String get sideEffectsThisUsesYourAiAssistant =>
      'This uses your AI assistant to list common side effects of your current medications for you to review.';

  @override
  String get sideEffectsWorthDiscussingWithYourDoctor =>
      'Worth discussing with your doctor';

  @override
  String get sideEffectsOptionalAddOn => 'Optional add-on';

  @override
  String get sideEffectsAskYourDoctorOrPharmacist =>
      'Ask your doctor or pharmacist';

  @override
  String get educationCategoryBrowserNoSectionsInThisCategory =>
      'No sections in this category yet.';

  @override
  String get educationMostOfThisComesStraight =>
      'Most of this comes straight from the official PA MHAD booklet, plus a few plain-language explainers. No marketing, no opinions — just the rules and what they mean.';

  @override
  String get educationSearchArticlesGlossaryFaqs =>
      'Search articles, glossary, FAQs…';

  @override
  String get educationYourDirectiveIsYourVoice =>
      '\"Your directive is your voice — written in advance, kept safe, honored when you can\'t speak for yourself.\"';

  @override
  String get educationPaOfficeOfMentalHealth =>
      '— PA OFFICE OF MENTAL HEALTH & SUBSTANCE ABUSE SERVICES · BOOKLET P.3';

  @override
  String get educationTypeToSearchEducationalContent =>
      'Type to search educational content...';

  @override
  String get educationBrowseAllTopics => 'Browse all topics';

  @override
  String get educationUnderstand => 'Understand ';

  @override
  String get educationYouSign => ' you sign.';

  @override
  String get learnAiPanelAskTheAi => 'Ask the AI';

  @override
  String get learnAiPanelSetUpAiAssistant => 'Set up AI assistant';

  @override
  String get learnAiPanelNotLegalOrMedicalAdvice =>
      'Not legal or medical advice.';

  @override
  String get learnAiPanelAskAQuestion => 'Ask a question…';

  @override
  String get educationArticleDetailTryIt => 'TRY IT';

  @override
  String get educationArticleDetailReadyToWriteYours => 'Ready to write yours?';

  @override
  String get educationArticleDetailTheGuidedWizardTakesAbout =>
      'The guided wizard takes about 20 minutes and works anonymously.';

  @override
  String get educationArticleDetailStartMyDirective => 'Start my directive';

  @override
  String get audioGuideCouldnTOpenTheQuestionnaire =>
      'Couldn\'t open the questionnaire to print. Please try again.';

  @override
  String get audioGuideRecordYourWishesByVoice => 'Record your wishes by voice';

  @override
  String get audioGuideDescribeYourWishesOutLoud =>
      'Describe your wishes out loud, upload the recording on the Snap-to-fill screen, and the AI fills your directive — you review every field before anything is saved.';

  @override
  String get audioGuidePrintTheQuestionnaire => 'Print the questionnaire';

  @override
  String get audioGuidePrintItToReadAloud =>
      'Print it to read aloud while you record, or to fill in by hand first.';

  @override
  String get audioGuidePrint => 'Print';

  @override
  String get audioGuideSetTheseInTheApp => 'Set these in the app:';

  @override
  String get audioGuideWorthSayingOutLoudAutofill =>
      'Worth saying out loud — autofill now captures these:';

  @override
  String get audioGuideHowToRecord => 'How to record';

  @override
  String get audioGuideWhatTheRecordingCanT => 'What the recording can\'t fill';

  @override
  String get ulyssesClauseBeforeYouAcknowledge => 'Before you acknowledge';

  @override
  String get ulyssesClauseThisIsASignificantDecision =>
      'This is a significant decision. Once you are found incapable, the directive cannot be revoked by you until capacity returns. We strongly recommend talking it through with a peer specialist or your clinician before saving.';

  @override
  String get ulyssesClauseIUnderstand => 'I understand';

  @override
  String get ulyssesClauseSometimesDuringACrisisPeople =>
      'Sometimes during a crisis, people refuse treatment that they\'d want when well. PA law honors what you wrote today, even if you protest in the moment.';

  @override
  String get ulyssesClauseSelfBindingUlysses => 'SELF-BINDING (\"Ulysses\")';

  @override
  String get ulyssesClauseTieMyselfToTheMast => 'Tie myself to the mast.';

  @override
  String get ulyssesClausePerPaAct19420 =>
      'Per PA Act 194 (20 Pa.C.S. §§ 5825, 5839), this directive may be revoked only while I have capacity. Once I\'m found incapable, what I wrote here stands — even over my in-the-moment protest — until capacity returns.';

  @override
  String get ulyssesClauseIAcknowledgeThis => 'I acknowledge this';

  @override
  String get ulyssesClauseRecordedInYourDirectivePdf =>
      'Recorded in your directive PDF.';

  @override
  String get ulyssesClauseBoundariesOnThisClause => 'Boundaries on this clause';

  @override
  String get exportCardsBeforeSharingEnsureThisDirective =>
      'Before sharing: ensure this directive has been signed, dated, and witnessed by two adults (18+) as required by PA Act 194. Give copies to your agent, physician, and support people.';

  @override
  String get exportCardsPrincipal => 'Principal';

  @override
  String get exportCardsTheExportedPdfIsNot =>
      'The exported PDF is not encrypted. Share only via channels you trust.';

  @override
  String get exportCardsImportantBeforeSharingEnsureThis =>
      'Important: Before sharing, ensure this directive has been signed, dated, and witnessed by two adults as required by PA Act 194. Give copies to your agent, physician, and support people.';

  @override
  String get pdfPreviewUsLetter8511 => 'US LETTER · 8.5×11\"';

  @override
  String get pdfPreviewShare => 'Share';

  @override
  String get pdfPreviewSizedForUsLetter8 =>
      'Sized for US Letter (8.5 × 11″) with 1-inch margins. The preview fills the width — use − / + to zoom.';

  @override
  String get pdfPreviewPages => 'PAGES';

  @override
  String get pdfPreviewExportShare => 'Export & share';

  @override
  String get pdfPreviewClosePreview => 'Close preview';

  @override
  String get pdfPreviewRenderingPdfPreview => 'Rendering PDF preview';

  @override
  String get pdfPreviewFitPageToWindow => 'Fit page to window';

  @override
  String get pdfPreviewYourDirective => 'Your directive, ';

  @override
  String get pdfPreviewOnPaper => 'on paper.';

  @override
  String get exportSelectAtLeastOneSection =>
      'Select at least one section to include.';

  @override
  String get exportIncompleteDirective => 'Incomplete Directive';

  @override
  String get exportGoBack => 'Go Back';

  @override
  String get exportEditDirective => 'Edit Directive';

  @override
  String get exportExportAnyway => 'Export Anyway';

  @override
  String get exportExportedFileIsNotEncrypted =>
      'Exported file is not encrypted';

  @override
  String get exportThePdfYouAreAbout =>
      'The PDF you are about to share contains your full mental-health directive (names, agents, medications, signatures). It is generated unencrypted because the underlying PDF library does not support password protection.\n\nShare only via channels you trust (e.g., direct hand-off, a secure email to a specific provider). Avoid public uploads, cloud links, or untrusted messaging apps.';

  @override
  String get exportIUnderstandContinue => 'I understand, continue';

  @override
  String get exportCouldnTGenerateThePdf => 'Couldn\'t generate the PDF.';

  @override
  String get exportSelectAtLeastOneSection2 =>
      'Select at least one section to preview.';

  @override
  String get exportNothingToDownloadYet => 'Nothing to download yet';

  @override
  String get exportStartADirectiveFirstThen =>
      'Start a directive first — then come back here to preview, download, and print it.';

  @override
  String get exportSelectFormsToInclude => 'Select forms to include:';

  @override
  String get exportAdditionalPages => 'Additional Pages:';

  @override
  String get exportPrintABlankFormFill =>
      'Print a blank form (fill in by hand)';

  @override
  String get exportPlainSignable => 'Plain (signable)';

  @override
  String get exportLegalInfoOnly => 'Legal (info only)';

  @override
  String get exportHeadsUpTheLegalLanguage =>
      'Heads up: the legal-language version is for reference only. Sign and use the plain-language official form.';

  @override
  String get exportOpenPdf => 'Open PDF';

  @override
  String get exportOpenWalletCardPdf => 'Open wallet card (PDF)';

  @override
  String get exportEncryptTheFile => 'Encrypt the file';

  @override
  String get exportDownload => 'Download';

  @override
  String get exportFhirJson => 'FHIR JSON';

  @override
  String get exportFhirXml => 'FHIR XML';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exportZipBundle => '.zip bundle';

  @override
  String get exportDoneBackToHome => 'Done — back to home';

  @override
  String get exportCopiedToClipboard => 'Copied to clipboard.';

  @override
  String get exportCouldnTSaveTheFile =>
      'Couldn\'t save the file. Please try again.';

  @override
  String get exportExportedYourDirectiveBundlePdf =>
      'Exported your directive bundle — PDF, JSON, XML and CSV.';

  @override
  String get exportCouldNotBuildTheZip => 'Could not build the .zip bundle.';

  @override
  String get exportCouldnTGenerateTheWallet =>
      'Couldn\'t generate the wallet card. Please try again.';

  @override
  String get exportYourOfficialDirective => 'Your official directive';

  @override
  String get exportKeepACopy => 'Keep a copy';

  @override
  String get exportAdvancedDataExports => 'Advanced · data exports';

  @override
  String get exportDeclarationPowerOfAttorneyMost =>
      'Declaration + Power of Attorney (most complete)';

  @override
  String get exportTreatmentPreferencesOnlyNoAgent =>
      'Treatment preferences only (no agent)';

  @override
  String get exportAgentAuthorityOnlyNoPersonal =>
      'Agent authority only (no personal preferences)';

  @override
  String get exportSupplementaryLegalInformation =>
      'Supplementary Legal Information';

  @override
  String get exportAdditionalLegalReferenceInformation =>
      'Additional legal reference information';

  @override
  String get exportDistributionChecklistNotes =>
      'Distribution Checklist & Notes';

  @override
  String get exportBlankPagesForHandwrittenNotes =>
      'Blank pages for handwritten notes';

  @override
  String get exportOpenThePdfDirectiveIn =>
      'Open the PDF directive in your viewer to print or save it';

  @override
  String get exportDownloadAnEditableCopyOf =>
      'Download an editable copy of your directive';

  @override
  String get exportExportAsFhirJsonFor =>
      'Export as FHIR JSON for electronic health records';

  @override
  String get exportExportAsFhirXmlFor =>
      'Export as FHIR XML for electronic health records';

  @override
  String get exportExportAsCsvSpreadsheet => 'Export as CSV spreadsheet';

  @override
  String get exportDownloadEverythingPdfJsonXml =>
      'Download everything (PDF, JSON, XML, CSV) as a zip bundle';

  @override
  String get exportYourDirective => 'Your directive,\n';

  @override
  String get appThemeWarmTeal => 'Warm Teal';

  @override
  String get appThemeBalancedCalmProfessional =>
      'Balanced, calm, professional.';

  @override
  String get appThemeDeepNavy => 'Deep Navy';

  @override
  String get appThemeFormalSteadyHighContrast =>
      'Formal, steady, high-contrast.';

  @override
  String get appThemeSageGreen => 'Sage Green';

  @override
  String get appThemeSoftNaturalApproachable => 'Soft, natural, approachable.';

  @override
  String get aiSetupReplyWithTheSingleWord => 'Reply with the single word: ok';

  @override
  String get aiSetupRemoveApiKey => 'Remove API Key?';

  @override
  String get aiSetupAiFeaturesWillBeDisabled =>
      'AI features will be disabled until a new key is added.';

  @override
  String get aiSetupApiKeyRemoved => 'API key removed';

  @override
  String get aiSetupAiAssistantSetup => 'AI assistant setup';

  @override
  String get aiSetupYourApiKeyWillNot =>
      'Your API key will not be saved permanently. It is kept in memory for this session, with a temporary copy for up to 10 minutes so you can recover it if the app reloads — then discarded when you close the app or clear your data.';

  @override
  String get aiSetupStep1OpenAPrivate =>
      'Step 1: Open a Private/Incognito Window';

  @override
  String get aiSetupYouLlNeedToSign =>
      'You\'ll need to sign into your Google account to get an API key. To protect your login on shared or public devices, open a private browsing window first:';

  @override
  String get aiSetupOnAPhoneTapThe =>
      'On a phone: tap the menu (⋮ or ⋯) and select \"New Incognito Tab\" or \"New Private Tab\".';

  @override
  String get aiSetupYourGoogleLoginWillBe =>
      'Your Google login will be automatically forgotten when you close the private window.';

  @override
  String get aiSetupPrivacyNotice => 'Privacy Notice';

  @override
  String get aiSetupHowYourDataIsHandled => 'How Your Data Is Handled';

  @override
  String get aiSetupYourDirectiveDataIsHeld =>
      '- Your directive data is held in memory only; on close or crash it is kept ~10 minutes for recovery, then wiped — never written to disk or a server\n- AI features are optional and the app works without them\n- Only text you explicitly send via AI chat or AI Suggest leaves your device\n- This app is not a medical or legal service\n- This app is not HIPAA-compliant';

  @override
  String get aiSetupCommonQuestions => 'Common Questions';

  @override
  String get aiSetupRemoveApiKey2 => 'Remove API key';

  @override
  String get aiSetupCreateAnApiKey => 'Create an API key';

  @override
  String get aiSetupCreateANewApiKey =>
      'Create a new API key on the API keys page; the defaults are fine.';

  @override
  String get aiSetupCopyAndPasteBelow => 'Copy and paste below';

  @override
  String get aiSetupPasteFromClipboard => 'Paste from clipboard';

  @override
  String get aiSetupTestingConnection => 'Testing connection';

  @override
  String get accessibilitySettingsAdjustHowTheAppFeels =>
      'Adjust how the app feels for you. Changes apply everywhere instantly.';

  @override
  String get accessibilitySettingsHowToUseReadAloud => 'How to use read-aloud';

  @override
  String get accessibilitySettingsResetAccessibilitySettings =>
      'Reset accessibility settings';

  @override
  String get accessibilitySettingsReadThisPageAloud => 'Read this page aloud';

  @override
  String get accessibilitySettingsYourBrowserAndDeviceAlready =>
      'Your browser and device already have read-aloud built in — they work better than an in-app reader, so use one of these:';

  @override
  String get accessibilitySettingsPeopleWhoITrustWill =>
      'People who I trust will make my decisions if I can\'t.';

  @override
  String get accessibilitySettingsEnglish => 'English';

  @override
  String get accessibilitySettingsEspaOl => 'Español';

  @override
  String get accessibilitySettingsAccessibility => 'Accessibility';

  @override
  String get accessibilitySettingsTextSize => 'Text size';

  @override
  String get accessibilitySettingsDyslexiaFriendlyFont =>
      'Dyslexia-friendly font';

  @override
  String get accessibilitySettingsBoldText => 'Bold text';

  @override
  String get accessibilitySettingsReduceMotion => 'Reduce motion';

  @override
  String get accessibilitySettingsHighContrast => 'High contrast';

  @override
  String get accessibilitySettingsReadAloud => 'Read aloud';

  @override
  String get accessibilitySettingsRightClickThePageRead =>
      'Right-click the page → “Read aloud” (Edge), or use the Reading mode / an extension in Chrome. Edge: Ctrl+Shift+U.';

  @override
  String get accessibilitySettingsSelectTextTapListenOr =>
      'Select text → tap “Listen”, or turn on Settings → Accessibility → Select to Speak / TalkBack.';

  @override
  String get accessibilitySettingsSettingsAccessibilitySpokenContentTurn =>
      'Settings → Accessibility → Spoken Content → turn on “Speak Screen”, then swipe down with two fingers.';

  @override
  String get accessibilitySettingsNarratorCtrlWinEnterOr =>
      'Narrator: Ctrl+Win+Enter. Or use Edge’s Read aloud above.';

  @override
  String get accessibilitySettingsSystemSettingsAccessibilitySpokenContent =>
      'System Settings → Accessibility → Spoken Content → “Speak selection”, then press Option+Esc.';

  @override
  String get privacyPolicyPrivacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyPaMhadAppPrivacyPolicy =>
      'PA MHAD App Privacy Policy';

  @override
  String get privacyPolicyReviewLegalDisclaimer => 'Review Legal Disclaimer';

  @override
  String get privacyPolicyDataWeCollect => 'Data We Collect';

  @override
  String get privacyPolicyThisAppCollectsOnlyThe =>
      'This app collects only the information you enter into your Mental Health Advance Directive forms, including:\n  - Personal information (name, address, phone, date of birth)\n  - Agent and witness information\n  - Treatment preferences and medication lists\n  - Digital signatures\n  - Additional instructions\n\nWe do not collect analytics, crash reports, device identifiers, or location data.';

  @override
  String get privacyPolicyHowDataIsStoredProtected =>
      'How Data Is Stored & Protected';

  @override
  String get privacyPolicyYourDirectiveDataIsNot =>
      'Your directive data is NOT transmitted to the app developer or any third party for storage.\n\nThis is a web app: your data is held in an in-memory database in your browser tab. If you close the tab or the app crashes, your work is kept on this device for about 10 minutes so you can reopen and recover it — then it is wiped. Nothing is written to a server. Export or print your directive to keep a permanent copy.';

  @override
  String get privacyPolicyAiFeaturesThirdPartyData =>
      'AI Features & Third-Party Data Sharing';

  @override
  String get privacyPolicyIfYouChooseToUse =>
      'If you choose to use the optional AI features (AI Assistant chat or AI Suggest), text you submit is sent to the AI provider you select — Google Gemini by default, or Anthropic Claude, OpenAI, or xAI Grok if you choose one and add your own key — for processing.\n\nOn Google\'s Gemini free tier, Google may:\n  - Use your input/output data to improve their products\n  - Allow human reviewers to read your inputs and outputs\n  - Retain data indefinitely (no automatic expiration)\nOther providers handle your data under their own API data policies — review the policy of whichever provider you use.\n\nThe app strips common personally identifiable information (SSNs, phone numbers, emails, dates of birth, addresses, names, and facility names) before sending your text to any provider, but this is a best-effort filter and cannot guarantee complete removal.\n\nAI features are entirely optional. The app is fully functional without them.';

  @override
  String get privacyPolicyGeminiFreeTierDataPractices =>
      'Gemini Free Tier Data Practices';

  @override
  String get privacyPolicyIfYouUseTheAi =>
      'If you use the AI features with Google\'s free Gemini tier, be aware of the following:\n\n1. Google retains AI conversation data indefinitely on the free tier. There is no automatic expiration.\n\n2. Human reviewers at Google may read your inputs and outputs as part of their quality and safety processes.\n\n3. Data sent to Gemini cannot be recalled or deleted by you or by this app. Once submitted, it is under Google\'s control.\n\n4. If you are concerned about data privacy, consider upgrading to the paid Gemini tier, which offers stronger data protection policies and does not use your data for model training.\n\nIf you select a different provider (Anthropic, OpenAI, or xAI) instead of Gemini, that provider\'s own data and retention policy applies — review it before sending sensitive content.\n\nYou can avoid all third-party data sharing by not using the AI features.';

  @override
  String get privacyPolicyInternationalUsersGdpr =>
      'International Users (GDPR)';

  @override
  String get privacyPolicyIfYouAreLocatedIn =>
      'If you are located in the European Economic Area (EEA), the UK, or Switzerland, the General Data Protection Regulation (GDPR) applies to your use of this app.\n\nLegal basis for processing: Your explicit consent, given through the in-app disclaimer and AI consent dialogs.\n\nYour rights under GDPR:\n  - Right to access: All your data is stored locally on your device — you have direct access at all times.\n  - Right to erasure: Use \"Delete All Data\" in the app menu to permanently erase all local data.\n  - Right to data portability: Export your directives as PDF or FHIR JSON (a standard health-records format) at any time.\n  - Right to withdraw consent: Stop using AI features at any time; remove your API key to prevent further data transmission.\n  - Right to restriction: You may use the app in Public Mode without any data persistence.\n\nData sent to your chosen AI provider is processed under that provider\'s own privacy policy and data processing terms. We cannot control or delete data once it has been sent.';

  @override
  String get privacyPolicyUsStateConsumerHealthData =>
      'US State Consumer Health Data Laws (CA, WA, CT, NV, NY)';

  @override
  String get privacyPolicyThisAppMayBeSubject =>
      'This app may be subject to state consumer-health-data privacy laws including California (CCPA/CPRA), Washington (My Health My Data Act / MHMDA), Connecticut (CTDPA health provisions), Nevada (SB 370), and New York (Health Information Privacy Act).\n\nMental-health-directive content is \"consumer health data\" under each of these laws. Under all of them: (1) We collect mental-health treatment-preference data **solely** to help you create your advance directive. (2) We **do not sell** your health data — there is no commercial recipient. (3) The only third party that may receive any of your text is the AI provider you choose (Google Gemini by default, or Anthropic, OpenAI, or xAI), and **only** if you affirmatively opt in to AI features each session. (4) We use no third-party SDKs, no analytics, no advertising frameworks, no tracking pixels or cookies. (5) You may delete all locally stored data at any time via \"Delete All Data\" in the app menu.\n\nWashington MHMDA includes a **private right of action**; we have designed the app to require explicit, per-session consent before any third-party transfer of consumer health data, and we treat written consent as conditional on the specific terms shown in the AI consent dialog.\n\nFor questions about your privacy rights, contact the developer using the channels listed in the Contact section below (multiple methods are provided per the FTC Health Breach Notification Rule).';

  @override
  String get privacyPolicyMedicalReferenceLookupsUS =>
      'Medical Reference Lookups (U.S. government data)';

  @override
  String get privacyPolicyToHelpYouFillIn =>
      'To help you fill in and understand your directive, the app looks things up in free, public U.S. government databases. These lookups use ONLY the single term or code needed for that lookup. They never receive your identity (your name, date of birth, address, or phone), the people you name (agents, witnesses, guardian), or your saved directive.\n\nWhat is sent, and to whom:\n  - Medication name you type → NLM RxTerms (autocomplete).\n  - Condition name you type → NLM ICD-10-CM (diagnosis lookup).\n  - A doctor / provider name you type into the optional doctor search → NLM NPI registry, used only to look that provider up in the public registry of healthcare providers.\n  - A condition (by its ICD-10 code) or a medication (by name, resolved to a code via NLM RxNav) → NLM MedlinePlus Connect, to fetch a plain-language explanation.\n  - A medication name → openFDA (U.S. Food & Drug Administration), to fetch that drug\'s official FDA label, which is used to ground the side-effects list.\n\nNo personal or identifying information is included in any of these requests — only the medical term, code, or provider name being looked up.\n\nNLM, NIH, and the FDA are not responsible for this product and do not endorse or recommend it. These services are for information only and are not medical advice — consult a qualified professional. The NLM Clinical Table services are rate-limited to 20 requests/second.\n\nSources: U.S. National Library of Medicine (RxTerms, ICD-10-CM, NPI registry, RxNav, MedlinePlus Connect); U.S. Food & Drug Administration (openFDA).';

  @override
  String get privacyPolicyPdfExportSharing => 'PDF Export & Sharing';

  @override
  String get privacyPolicyWhenYouExportAPdf =>
      'When you export a PDF of your directive, it is generated locally on your device. Sharing the PDF (via email, messaging, etc.) sends it through your device\'s standard sharing mechanism. The app cannot control where the PDF is stored once shared.';

  @override
  String get privacyPolicyYourRights => 'Your Rights';

  @override
  String get privacyPolicyYouCanDeleteAnyDirective =>
      'You can delete any directive at any time from the home screen. Deleting a directive removes all associated data (personal info, agents, medications, witnesses, signatures) from the local database.\n\nYou can remove your AI provider API key(s) at any time from the AI Setup screen.\n\nUninstalling the app removes all locally stored data.';

  @override
  String get privacyPolicyNoThirdPartyTracking => 'No Third-Party Tracking';

  @override
  String get privacyPolicyThisAppDoesNotInclude =>
      'This app does not include any third-party analytics SDKs, advertising frameworks, crash reporting services (such as Firebase, Crashlytics, or Sentry), or tracking pixels.\n\nThe only external network connections this app makes are:\n  - Your chosen AI provider — Google Gemini (default), Anthropic, OpenAI, or xAI — only when you use AI features\n  - NIH/NLM Clinical Table Search Service — medication, condition, and provider (doctor) lookups\n  - NLM MedlinePlus Connect & RxNav — plain-language condition and medication explanations (sends only an ICD-10 code or a medication name)\n  - openFDA / U.S. FDA — official drug labels used to ground the side-effects list (sends only a medication name)\n\nEach of these receives only the term or code being looked up — never your identity or your directive. No data is sent to the app developer at any time.';

  @override
  String get privacyPolicyHipaaCompliance => 'HIPAA & Compliance';

  @override
  String get privacyPolicyThisAppIsNotHipaa =>
      'This app is NOT HIPAA-compliant. It is not a covered entity or business associate under HIPAA. The app is intended for personal use by individuals preparing their own mental health advance directives.\n\nWhile this app implements privacy measures aligned with GDPR, CCPA, and MHMDA principles (as described above), it has not been independently audited or certified for compliance with these regulations. If you require verified regulatory compliance, consult with a privacy professional before use.';

  @override
  String get privacyPolicyBreachNotification => 'Breach Notification';

  @override
  String get privacyPolicyInAccordanceWithTheFtc =>
      'In accordance with the FTC Health Breach Notification Rule, if any unauthorized disclosure of your health information occurs through a security breach, we will notify affected users within 60 calendar days of discovering the breach.\n\nBecause this app stores data locally on your device and does not maintain a server-side database, breach risk is limited to the optional AI features. If your chosen AI provider notifies us of a breach affecting data sent through the app, we will pass that notification along through an in-app notice and a posting on the hosted privacy policy page.';

  @override
  String get privacyPolicyContact => 'Contact';

  @override
  String get settingsBrightness => 'Brightness';

  @override
  String get settingsScreenshotProtection => 'Screenshot Protection';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsPaMentalHealthAdvanceDirective =>
      'PA Mental Health Advance Directive\nUnder Pennsylvania Act 194 of 2004 (effective January 29, 2005)\n\nThis app helps you document your mental health treatment preferences. It is not legal or medical advice, and not a substitute for a licensed attorney or clinician. See the full Legal Disclaimer above for details.\n\nYour directive is valid for two years from the date you sign it — unless you are found incapable of making mental health decisions at the time it would expire, in which case it stays in effect until your capacity returns.\n\nForm content based on the official PA MHAD booklet published by the Disabilities Law Project (2005).';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLegalPrivacy => 'Legal & privacy';

  @override
  String get settingsChooseAProviderAndAdd =>
      'Choose a provider and add your API key';

  @override
  String get settingsTextSizeDyslexiaFontBold =>
      'Text size, dyslexia font, bold text, contrast, language';

  @override
  String get settingsHowYourDataIsStored =>
      'How your data is stored and protected';

  @override
  String get settingsPrivacyPermissions => 'Privacy & permissions';

  @override
  String get settingsWhatPermissionsTheAppUses =>
      'What permissions the app uses, and what we promise about each';

  @override
  String get settingsLegalDisclaimer => 'Legal Disclaimer';

  @override
  String get settingsTermsLimitationsAndYourLegal =>
      'Terms, limitations, and your legal rights';

  @override
  String get assistantMessageWidgetsVerifiedWithWebSearch =>
      'Verified with web search';

  @override
  String get assistantMessageWidgetsSources => 'Sources';

  @override
  String get assistantMessageWidgetsVerifyOnTheWeb => 'Verify on the web';

  @override
  String get assistantMessageWidgetsAiIsTyping => 'AI is typing';

  @override
  String get assistantContextPanelAskAboutFormTypesAgents =>
      'Ask about form types, agents, treatment preferences, or anything in the PA MHAD booklet. Try one of these:';

  @override
  String get assistantContextPanelPiiRedactionOn => 'PII REDACTION ON';

  @override
  String get assistantContextPanelNamesAddressesPhoneNumbersAnd =>
      'Names, addresses, phone numbers, and dates are replaced with placeholders before sending to Gemini. Suggestions come back with placeholders filled in locally.';

  @override
  String get assistantContextPanelContextTheAiSees => 'Context the AI sees';

  @override
  String get assistantContextPanelSuggestedPrompts => 'Suggested prompts';

  @override
  String get assistantContextPanelWhatICanHelpWith => 'What I can help with';

  @override
  String get assistantContextPanelPrivacy => 'Privacy';

  @override
  String get assistantContextPanelFormType => 'Form type';

  @override
  String get assistantContextPanelCurrentStep => 'Current step';

  @override
  String get assistantContextPanelFilledFields => 'Filled fields';

  @override
  String get assistantContextPanelPii => 'PII';

  @override
  String get assistantTheReplyFailed => 'The reply failed.';

  @override
  String get assistantStillFailingCheckYourConnection =>
      'Still failing — check your connection or key.';

  @override
  String get assistantClearConversation => 'Clear conversation?';

  @override
  String get assistantThisWillEraseAllMessages =>
      'This will erase all messages. This cannot be undone.';

  @override
  String get assistantClear => 'Clear';

  @override
  String get assistantToUseTheAiAssistant =>
      'To use the AI assistant, set up an AI key — Gemini\'s free tier works.';

  @override
  String get assistantSetUpFree => 'Set Up (Free)';

  @override
  String get assistantPersonalInfoRemoved => 'Personal info removed';

  @override
  String get assistantAskMeAnythingAboutYour =>
      'Ask me anything about your\nPA Mental Health Advance Directive';

  @override
  String get assistantSuggestedQuestions => 'Suggested questions:';

  @override
  String get assistantClearConversation2 => 'Clear conversation';

  @override
  String get assistantApiKeySettings => 'API key settings';

  @override
  String assistantDisclaimerNotLegalOrMedical(String phone) {
    return 'Disclaimer: Not legal or medical advice. For legal questions contact PA Protection and Advocacy: $phone ';
  }

  @override
  String get assistantAskAQuestionAboutYour =>
      'Ask a question about your directive...';

  @override
  String get assistantSend => 'Send';

  @override
  String get directiveFormChoiceWithAPoaOnlyForm =>
      'With a POA-only form, your agent will have authority to make mental health care decisions on your behalf, but the document will not include your personal treatment preferences.\n\nConsider using the Combined form instead to document both your preferences AND appoint an agent. This gives your care team the most guidance.';

  @override
  String get directiveFormChoiceContinueWithPoa => 'Continue with POA';

  @override
  String get directiveFormChoiceYouCanSwitchFormTypes =>
      'You can switch form types later if you change your mind — Combined is the broadest.';

  @override
  String get directiveFormChoiceCombinedDirective => 'Combined directive';

  @override
  String get directiveFormChoiceTreatmentPreferencesAndATrusted =>
      'Treatment preferences and a trusted decision-maker, in one document. 11 short steps · about 20 minutes.';

  @override
  String get directiveFormChoiceStartNow => 'Start now';

  @override
  String get directiveFormChoiceNotSureWhichFormFits =>
      'Not sure which form fits? Take the 4-question quiz.';

  @override
  String get directiveFormChoiceHelpMeChoose => 'Help me choose →';

  @override
  String get directiveFormChoicePowerOfAttorneyOnly => 'Power of attorney only';

  @override
  String get directiveFormChoiceTakeThe4QuestionQuiz =>
      'Take the 4-question quiz to choose a form';

  @override
  String get webLandingALegalDocumentThatTells =>
      'A legal document that tells doctors, family, and a person you trust how to care for you if you can’t speak for yourself. Free, anonymous, and takes about 20 minutes.';

  @override
  String get webLandingYouReWorkingAnonymouslyNothing =>
      'You’re working anonymously. Nothing is saved.';

  @override
  String get webLandingNoAccountNoCloudIf =>
      'No account, no cloud. If you close the tab or the app crashes, your work is kept on this device for 10 minutes so you can reopen and recover it — then it’s erased for good. Open your PDF and save it to keep a copy.';

  @override
  String get webLandingHowThisWorks => 'HOW THIS WORKS →';

  @override
  String get webLandingAnMhadIsYourVoice =>
      '“An MHAD is your voice when you can’t speak for yourself.”';

  @override
  String get webLandingPaMhadBookletOfficeOf =>
      '— PA MHAD booklet · Office of Mental Health';

  @override
  String get webLandingReadTheBasics => 'Read the basics →';

  @override
  String get webLandingPennsylvaniaAct194Of2004 =>
      'Pennsylvania · Act 194 of 2004';

  @override
  String get webLandingOurPrivacyPromise => 'Our privacy promise';

  @override
  String get webLandingFromTheBooklet => 'From the booklet';

  @override
  String get webLandingPrintABlankForm => 'Print a blank form';

  @override
  String get webLandingPrintBlankForm => 'Print blank form';

  @override
  String get webLandingTheBasics => 'The basics';

  @override
  String get webLandingMakeAMentalHealth => 'Make a mental health ';

  @override
  String get webLandingAdvanceDirective => 'advance directive.';

  @override
  String get homeToolsGridMakeItFindable => 'Make it findable';

  @override
  String get homeToolsGridCrisisHelp => 'Crisis help';

  @override
  String get homeDirectiveHeroDraft => '● Draft';

  @override
  String get homeDirectiveHeroContinueWhereYouLeftOff =>
      'Continue where you left off';

  @override
  String get facilitatorGetHelpEvidenceBased => 'Get help · evidence-based';

  @override
  String get facilitatorTalkToSomeoneTrained => 'Talk to someone trained';

  @override
  String get facilitatorPennsylvaniaPeerSpecialistsAndRights =>
      'Pennsylvania peer specialists and rights advocates help walk you through the form. Free; no booking system inside this app — call or visit a partner below.';

  @override
  String get facilitatorPrintReviewItTogether => 'Print + review it together';

  @override
  String get facilitatorPrintOrScreenShareYour =>
      'Print or screen-share your draft and walk through it with a friend, family member, or peer. They can\'t change anything in your app — that stays in your hands.';

  @override
  String get facilitatorEmailADraftToMy => 'Email a draft to my clinician';

  @override
  String get facilitatorGenerateThePdfInExport =>
      'Generate the PDF in Export, then send it via your phone\'s email app. Ask your therapist or psychiatrist for comments. You\'ll transcribe their suggestions back into the form yourself — this app doesn\'t connect to their EHR.';

  @override
  String get facilitatorCall => 'Call';

  @override
  String get facilitatorOpenWebsite => 'Open website';

  @override
  String get legalSheetFullLegalDisclosure => 'Full legal disclosure';

  @override
  String get legalSheetTheEightSectionsBelowWere =>
      'The eight sections below were accepted at first launch. Tap to expand.';

  @override
  String get legalSheetFullLegalSections => 'Full legal sections';

  @override
  String get legalSheetNotLegalOrMedicalAdvice => 'Not legal or medical advice';

  @override
  String get legalSheetNoProfessionalRelationship =>
      'No professional relationship';

  @override
  String get legalSheetUseAtYourOwnRisk => 'Use at your own risk';

  @override
  String get legalSheetRequirementsForAValidDirective =>
      'Requirements for a valid directive';

  @override
  String get legalSheetTwoYearValidity => 'Two-year validity';

  @override
  String get legalSheetRevocation => 'Revocation';

  @override
  String get legalSheetPrivacyAiFeatures => 'Privacy & AI features';

  @override
  String get legalSheetResourcesAssistance => 'Resources & assistance';

  @override
  String get legalSheetPaProtectionAdvocacy => 'PA Protection & Advocacy';

  @override
  String get legalSheetPaMentalHealthConsumersAssociation =>
      'PA Mental Health Consumers\' Association';

  @override
  String get legalSheetMentalHealthAssociationInPennsylvania =>
      'Mental Health Association in Pennsylvania';

  @override
  String get legalSheet988SuicideCrisisLifeline =>
      '988 Suicide & Crisis Lifeline';

  @override
  String get legalSheetThisAppHelpsPennsylvaniaResidents =>
      'This app helps Pennsylvania residents document their treatment preferences under ';

  @override
  String get legalSheetTheInformationIsForInformational =>
      '. The information is for informational purposes only and does ';

  @override
  String get legalSheetConstituteLegalOrMedicalAdvice =>
      ' constitute legal or medical advice.';

  @override
  String get legalSheetItIsNotAMedical =>
      'It is not a medical device. It does not diagnose, treat, cure, or prevent any condition. For treatment decisions, consult a qualified mental health professional. For legal questions, consult a licensed PA attorney.';

  @override
  String get legalSheetUseOfThisAppDoes => 'Use of this app does ';

  @override
  String get legalSheetCreateAnAttorneyClientRelationship =>
      ' create an attorney–client relationship, a provider–patient relationship, or any other professional relationship between you and the developer.';

  @override
  String get legalSheetYouAreSolelyResponsibleFor =>
      'You are solely responsible for making sure your directive meets all legal requirements under PA law, including proper execution with witnesses.';

  @override
  String get legalSheetInPlainTermsThisApp =>
      'In plain terms: this app helps you put your own wishes into a directive, and you use it at your own risk. Please review the finished document for accuracy — mistakes can happen, and details you entered may be out of date or incomplete. If you are ever unsure whether something is legally right for your situation, feel free to talk with an attorney. The formal version:';

  @override
  String get legalSheetThisAppIsProvided => 'This app is provided ';

  @override
  String get legalSheetAsIs => '\"as is\"';

  @override
  String get legalSheetWithoutWarrantiesOfAnyKind =>
      ', without warranties of any kind, and you use it at your own risk. To the fullest extent permitted by law, the developer is not liable for any damages arising from use of the app or any document created with it. You are responsible for reviewing your directive for accuracy and completeness; for legal questions specific to your situation, consult a licensed Pennsylvania attorney.';

  @override
  String get legalSheetAPaMentalHealthAdvance =>
      'A PA Mental Health Advance Directive is legally valid ';

  @override
  String get legalSheetWhen => ' when:';

  @override
  String get legalSheetYouThePrincipalHaveLegal =>
      'You (the principal) have legal capacity at the time of signing';

  @override
  String get legalSheetItIsSignedInThe => 'It is signed in the presence of ';

  @override
  String get legalSheetBothWitnessesMeetEligibilityRequirements =>
      'Both witnesses meet eligibility requirements under Act 194';

  @override
  String get legalSheetYourDesignatedAgentOrAlternate =>
      'your designated agent or alternate agent, your mental health care provider, or an employee of the facility where you receive treatment — unless they are related to you by blood, marriage, or adoption.';

  @override
  String get legalSheetThisAppCapturesTouchDrawn =>
      'This app captures touch-drawn signatures for convenience during preparation. The ';

  @override
  String get legalSheetDirectiveMustBeSignedIn =>
      ' directive must be signed in original ink, in the presence of your two witnesses, to be legally valid.';

  @override
  String get legalSheetOnceSignedProvidersAndYour =>
      'Once signed, providers and your agent ';

  @override
  String get legalSheetWithYourDirective20Pa =>
      ' with your directive (20 Pa.C.S. §§ 5804, 5842). However, a provider may decline to follow specific instructions that are against accepted medical practice, or when the provider is not physically available.';

  @override
  String get legalSheetUnderPaAct194An =>
      'Under PA Act 194, an MHAD is valid for ';

  @override
  String get legalSheetFromTheDateOfExecution =>
      ' from the date of execution unless revoked earlier — ';

  @override
  String get legalSheetOfMakingMentalHealthDecisions =>
      ' of making mental health decisions at the time it would expire, in which case it remains in effect until capacity returns. This app will remind you when your directive is approaching expiration.';

  @override
  String get legalSheetYouMayRevokeThisDirective =>
      'You may revoke this directive at any time while you have legal capacity by:';

  @override
  String get legalSheetNotifyingYourHealthcareProviderOr =>
      'Notifying your healthcare provider or agent in writing';

  @override
  String get legalSheetDestroyingTheDirective => 'Destroying the directive';

  @override
  String get legalSheetExecutingANewDirective => 'Executing a new directive';

  @override
  String get legalSheetNotifyEveryoneWhoHasCopies =>
      'Notify everyone who has copies of the revocation.';

  @override
  String get legalSheetThisIsAWebApp =>
      'This is a web app: your directive is held in memory in your browser only and is ';

  @override
  String get legalSheetIfYouCloseTheTab =>
      ' — if you close the tab or it crashes, your work is kept on this device for about 10 minutes for recovery, then wiped; it is never sent to a server. Export or print to keep a copy. This app is ';

  @override
  String get legalSheetHipaaCompliant => ' HIPAA-compliant.';

  @override
  String get legalSheetIfYouUseTheOptional =>
      'If you use the optional AI Assistant, text you send is transmitted to the AI provider you choose (Google Gemini by default; or Anthropic, OpenAI, or xAI). On Gemini\'s free tier, Google may use this data to improve their products and human reviewers may read inputs; other providers handle your data under their own API policies.';

  @override
  String get legalSheetToProtectYouTheApp => 'To protect you, the app ';

  @override
  String get legalSheetYourNameDateOfBirth =>
      ' — your name, date of birth, address, and the names and contact details of your agents and guardian are never included. Only non-identifying context (such as conditions, medications, and care preferences) is shared, and only if you choose to use the assistant. (Uploading a document for autofill is the one exception, described next.)';

  @override
  String get legalSheetDocumentsYouUploadForAutofill =>
      'Documents you upload for autofill are different: the whole file is sent to your chosen AI provider as-is, and to fill in your directive the AI reads the personal details in it (your name, date of birth, address, and your agent\'s or guardian\'s details). You review everything before it is saved. ';

  @override
  String get legalSheetBlackOutAnythingYouDon =>
      ' — black out anything you don\'t want sent, or simply type any field by hand to keep it private. Also avoid typing personal identifiers (full name, SSN, date of birth, address) directly into chat messages.';

  @override
  String get legalSheetSeparatelyToHelpYouFill =>
      'Separately, to help you fill in and understand your directive, the app looks up medications, conditions, and (optionally) your doctor in free, public U.S. government databases — the NIH/NLM Clinical Tables, MedlinePlus, and the FDA\'s openFDA. ';

  @override
  String get legalSheetNeverYourIdentityThePeople =>
      ' — never your identity, the people you name, or your saved directive. They are reference information, not medical advice.';

  @override
  String get legalSheetAiSuggestionsAreNotLegal =>
      'AI suggestions are not legal or medical advice — review carefully before accepting.';

  @override
  String get disclaimerAFewThingsToUnderstand => 'A few things to understand.';

  @override
  String get disclaimerThisToolHelpsYouWrite =>
      'This tool helps you write a Pennsylvania Mental Health Advance Directive under Act 194. Please read these before continuing.';

  @override
  String get disclaimerReadFullDisclaimer => 'Read full disclaimer';

  @override
  String get disclaimerGetStarted => 'Get started';

  @override
  String get disclaimerIM18OrOlder =>
      'I\'m 18 or older, and I understand and want to continue.';

  @override
  String get disclaimerBeforeYouBegin => 'Before you begin';

  @override
  String get disclaimerThisIsNotLegalAdvice => 'This is not legal advice';

  @override
  String get disclaimerWeGivePlainLanguageHelp =>
      'We give plain-language help, not legal counsel. For complex situations, talk to an attorney or advocate.';

  @override
  String get disclaimerItBecomesValidOnlyWhen =>
      'It becomes valid only when signed on paper';

  @override
  String get disclaimerPaLawRequiresYourSignature =>
      'PA law requires your signature plus two adult witnesses, in ink, in person. The app cannot sign for you.';

  @override
  String get disclaimerNothingIsSavedOrSent => 'Nothing is saved or sent to us';

  @override
  String get disclaimerYouCanStopOrChange =>
      'You can stop or change anything, anytime';

  @override
  String get disclaimerSkipQuestionsGoBackOr =>
      'Skip questions, go back, or revoke later. This is your voice — you stay in control.';

  @override
  String get onboardingWeLlWalkYouThrough =>
      'We\'ll walk you through it, step by step and in plain language: how you want to be treated during a mental health crisis — so your wishes are honored even when you can\'t speak for yourself.';

  @override
  String get onboardingValidTwoYearsFromSigning =>
      'Valid two years from signing — unless you are incapable when it would expire, when it stays in effect until your capacity returns. (PA Act 194, effective 2005.)';

  @override
  String get onboardingUploadADocumentToAutofill =>
      'Upload a document to autofill';

  @override
  String get onboardingContinueFromASavedFile => 'Continue from a saved file';

  @override
  String get onboardingFreeNoAccountNoTracking =>
      'Free · no account · no tracking · open source';

  @override
  String get onboardingPaMhadAct194 => 'PA MHAD · Act 194';

  @override
  String get onboardingInYour => 'In your\n';

  @override
  String get onboardingWords => 'words.';

  @override
  String get onboardingMakingThisChangesNothingToday =>
      'Making this changes nothing today. ';

  @override
  String get onboardingYouKeepEveryDecision => 'You keep every decision';

  @override
  String get onboardingUntilTwoProfessionalsFindYou =>
      ' until two professionals find you unable to decide for yourself.';

  @override
  String get aiConsistencyTheAiIsReviewingYour =>
      'The AI is reviewing your directive…';

  @override
  String get aiConsistencyAiReviewSkippedYouCan =>
      'AI review skipped — you can re-run it any time.';

  @override
  String get aiConsistencyRunAiReview => 'Run AI review';

  @override
  String get aiConsistencyIgnoreContinue => 'Ignore & continue';

  @override
  String get aiConsistencyResolveInWizard => 'Resolve in wizard';

  @override
  String get aiConsistencyLooksGoodContinue => 'Looks good — continue';

  @override
  String get aiConsistencyKeepBoth => 'Keep both';

  @override
  String get aiConsistencyAiReview => 'AI review';

  @override
  String get aiConsistencyConsistencyCheckCheckedAtReview =>
      'Consistency check · checked at Review';

  @override
  String get aiConsistencyCheckingYourDirective => 'Checking your directive';

  @override
  String get aiConsistencyYouSaidYourAgentDecides =>
      'You said your agent decides your medications, but the form says your agent is NOT authorized to consent to medications.';

  @override
  String get aiConsistencyTheseCancelEachOtherOut =>
      'These cancel each other out. The official form lets you set your own medication preferences and your agent’s authority separately — both are allowed — but as entered they oppose each other. Authorize your agent to consent to medications, or change the medication choice so they agree.';

  @override
  String get aiConsistencyYouDonTConsentTo =>
      'You don’t consent to any medications, but your agent is authorized to consent to them.';

  @override
  String get aiConsistencyTheOfficialFormLetsYou =>
      'The official form lets you set your own preference and your agent’s authority separately — both are valid — but as entered they oppose each other: your refusal of all medications versus your agent’s power to consent to any. Decide which should control and adjust the other.';

  @override
  String get aiConsistencyINoticed => 'I noticed ';

  @override
  String get draftRecoveryDialogRecoverUnsavedWork => 'Recover Unsaved Work?';

  @override
  String get draftRecoveryDialogDiscard => 'Discard';

  @override
  String get draftRecoveryDialogRestore => 'Restore';

  @override
  String get draftRecoveryDialogDraftRestoredPersonalInformationWill =>
      'Draft restored. Personal information will need to be re-entered.';

  @override
  String get draftRecoveryDialogCouldnTRestoreTheDraft =>
      'Couldn\'t restore the draft.';

  @override
  String get moreSheetResetAndStartFresh => 'Reset and start fresh?';

  @override
  String get moreSheetThisPermanentlyErasesEverythingIn =>
      'This permanently erases everything in this session — all directives, your AI key, and chat history — and returns you to a blank start.\n\nExport or print anything you want to keep first. This cannot be undone.';

  @override
  String get moreSheetResetEverything => 'Reset everything';

  @override
  String get moreSheetEverythingElseYouCanDo =>
      'Everything else you can do here.';

  @override
  String get moreSheetGetHelp => 'Get help';

  @override
  String get moreSheetReset => 'Reset';

  @override
  String get crisisSheet247FreeConfidential => '24/7 FREE, CONFIDENTIAL';

  @override
  String get crisisSheetRealPeopleAreStandingBy =>
      'Real people are standing by — phone, text, or chat.';

  @override
  String get crisisSheetCalling988ConnectsYouTo =>
      'Calling 988 connects you to a trained counselor in your area. It is free, confidential, and available 24 hours a day. Calling will not result in police being dispatched in most cases.';

  @override
  String get crisisSheetWhyTheseNumbers => 'Why these numbers?';

  @override
  String get crisisSheetIfYouOrSomeoneElse =>
      'If you or someone else is in immediate danger, call ';

  @override
  String get walletCardMh => 'MH';

  @override
  String get walletCardPaMhadAct194 => 'PA MHAD · ACT 194';

  @override
  String get walletCardHasAnActiveDirectiveOn =>
      'Has an active directive on file';

  @override
  String get walletCardAgent => 'AGENT';

  @override
  String get walletCardExp => 'EXP';

  @override
  String get webSidebarAct1942004 => 'ACT 194 · 2004';

  @override
  String get webSidebar247Lifeline => '24/7 LIFELINE';

  @override
  String get webSidebar988CrisisHelp => '988 · Crisis help';

  @override
  String get webSidebarClickForMoreInformation => 'Click for more information';

  @override
  String get webSidebarPeerSupportAdvocatesReferrals =>
      'Peer support · advocates · referrals';

  @override
  String get medlinePlusDialogNoPlainLanguageSummaryIs =>
      'No plain-language summary is available for this right now. You can search it on MedlinePlus.';

  @override
  String get medlinePlusDialogPlainLanguageInformationFromThe =>
      'Plain-language information from the U.S. National Library of Medicine (MedlinePlus). Educational only — not medical advice.';

  @override
  String get medlinePlusDialogReadMoreOnMedlineplus =>
      'Read more on MedlinePlus';

  @override
  String get fdaLabelDialogNoFdaLabelInformationIs =>
      'No FDA label information is available for this medication right now. Brand and generic spellings can differ — try the other one, or ask your pharmacist.';

  @override
  String get fdaLabelDialogOfficialUSFdaDrug =>
      'Official U.S. FDA drug-label text (openFDA). Reference only — not medical advice, and not personalized to you. Discuss anything here with your doctor or pharmacist.';

  @override
  String get aiConsentDialogBeforeYouUpload => 'Before you upload';

  @override
  String get aiConsentDialogNothingIsSavedToYour =>
      'Nothing is saved to your directive automatically — you review every field the AI fills in before it is applied.';

  @override
  String get aiConsentDialogUploadingIsOnlyAShortcut =>
      'Uploading is only a shortcut, never required:\n• Black out anything you don\'t want sent (ID or card numbers, other people\'s details) before uploading.\n• Or skip the upload and type any field by hand — typed fields stay on your device and are never sent to the AI.';

  @override
  String get aiConsentDialogSendToTheAi => 'Send to the AI';

  @override
  String get aiConsentDialogTranscribeWithAi => 'Transcribe with AI';

  @override
  String get aiConsentDialogYouReviewTheTextBefore =>
      'You review the text before it goes into your form. Prefer not to? Tap Cancel to use your device\'s built-in dictation instead, or just type — neither sends audio to the AI.';

  @override
  String get aiConsentDialogUseAi => 'Use AI';

  @override
  String get aiConsentDialogAiDataNotice => 'AI Data Notice';

  @override
  String get aiConsentDialogImportantPleaseReadBeforeContinuing =>
      'Important: Please read before continuing.\n';

  @override
  String get aiConsentDialogThisAiAssistantIsNot =>
      '• This AI assistant is NOT a therapist, doctor, or lawyer. It provides general information about PA Mental Health Advance Directives only.\n';

  @override
  String get aiConsentDialogNeverEnterPersonalInformationFull =>
      'NEVER enter personal information (full name, date of birth, Social Security number, address, phone number, email) into the AI chat or AI-powered features.\n\nThe app automatically strips common personal data, but this is not guaranteed. Personal information fields must be filled in manually — they are stored on your device only and never sent to the AI.';

  @override
  String get aiConsentDialogNotNow => 'Not Now';

  @override
  String get aiConsentDialogIAuthorize => 'I Authorize';

  @override
  String get addressFieldsTapTheIconToFill =>
      'Tap the icon to fill city & state';

  @override
  String get addressFieldsFillCityStateFromZip => 'Fill city & state from ZIP';

  @override
  String get mainTheAppCouldnTStart => 'The app couldn\'t start';

  @override
  String get mainPaMentalHealthAdvanceDirective =>
      'PA Mental Health Advance Directive';

  @override
  String get mainAppTitle => 'PA Mental Health Advance Directive';

  @override
  String get aiConsistencyStepsProcedures => 'Procedures + Agent authority';

  @override
  String get aiConsistencyStepsMeds => 'Medications + Agent authority';

  @override
  String aiConsistencyProcTitle(String name) {
    return 'You consented to $name yourself — the printed form will also state your agent is NOT authorized to consent to $name.';
  }

  @override
  String aiConsistencyProcBody(String name) {
    return 'Pennsylvania’s form lets you do both: give your own consent AND authorize your agent to consent on your behalf (that agent authorization needs your physical initials, §5836(c)). As entered, only your own consent is recorded, so the document says your agent may not consent to $name. That is allowed and may be exactly what you intend — keep both if so. If you also want your agent able to consent (e.g. if you later can’t decide), choose “My agent will decide” for $name.';
  }

  @override
  String aiConsistencyProcA(String name) {
    return 'You consent to $name';
  }

  @override
  String aiConsistencyProcB(String name) {
    return 'Agent not authorized: $name';
  }

  @override
  String aiConsistencyProcAction(String name) {
    return 'Review $name choice';
  }

  @override
  String get aiConsistencyProcEct => 'ECT';

  @override
  String get aiConsistencyProcExperimental => 'experimental studies';

  @override
  String get aiConsistencyProcDrugTrials => 'drug trials';

  @override
  String get aiConsistencyAgentDecidesMeds => 'Agent decides medications';

  @override
  String get aiConsistencyAgentNotAuthorizedMeds =>
      'Agent not authorized: medications';

  @override
  String get aiConsistencyEditMedications => 'Edit Medications';

  @override
  String get aiConsistencyEditAgentAuthority => 'Edit Agent authority';

  @override
  String get aiConsistencyNoMedsYou => 'No medications (you)';

  @override
  String get aiConsistencyAgentMayConsentMeds =>
      'Agent may consent: medications';

  @override
  String get aiConsistencySetupAiInvite =>
      'Set up the free AI assistant for an additional AI-powered review that suggests gaps and things to double-check. Optional — the rule-based check above always runs without it.';

  @override
  String get aiConsistencyNoSuggestions =>
      'The AI did not return any suggestions.';

  @override
  String aiConsistencyNotAdviceOptional(String notAdvice) {
    return '$notAdvice Optional suggestions based only on what you entered.';
  }

  @override
  String aiConsistencyCheckFailed(String error) {
    return 'Couldn\'t run the consistency check.\n$error';
  }

  @override
  String aiConsistencyThingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things',
      one: '1 thing',
    );
    return '$_temp0';
  }

  @override
  String get aiConsistencyAllConsistent =>
      'Everything looks internally consistent.';

  @override
  String get aiConsistencyWarningsOnly =>
      'These won\'t block you from generating the PDF — they are warnings you can fix or ignore.';

  @override
  String get aiConsistencyNoContradictions =>
      'No cross-step contradictions detected.';

  @override
  String get aiConsistencyRulesExplainer =>
      'The contradiction check above is built-in rules. When the AI assistant is set up, an additional AI review adds optional suggestions. Review anything before accepting — this screen warns; it doesn\'t block PDF generation.';

  @override
  String aiConsistencyConflictHeader(int number, String steps) {
    return 'CONFLICT · $number · $steps';
  }

  @override
  String get aiConsistencyVs => 'vs';

  @override
  String get crisisPlanHowIKnowIM => 'How I know I\'m not okay';

  @override
  String get crisisPlanHeadsUpThisSectionIs =>
      'Heads up: this section is yours alone — it isn\'t required by PA Act 194, but in practice it\'s the part agents and ER staff read first.';

  @override
  String get permissionsOverviewOnlyWhatWeNeed => 'Only what we need.';

  @override
  String get permissionsOverviewPermissionsAreManagedByYour =>
      'Permissions are managed by your device, not by this app. Open your device\'s Settings → PA MHAD to grant, revoke, or review any of the above at any time.';

  @override
  String get permissionsOverviewNoAnalyticsNoTrackingPixels =>
      'No analytics. No tracking pixels. No cookies. No third-party SDKs for advertising or measurement. The only outbound flows are the opt-in AI features (your chosen AI provider) and NLM medical-reference lookups, both with PII stripping at a single chokepoint.';

  @override
  String get makeItFindableMakeItFindableInA => 'Make it findable in a crisis.';

  @override
  String get makeItFindablePennsylvaniaHasNoStatewideDirective =>
      'Pennsylvania has no statewide directive registry, so the people in your life are the registry: make sure your agent, a trusted person, and your providers all know you have a directive and where to find it.';

  @override
  String get makeItFindableUnderPaAct194A =>
      'Under PA Act 194, a valid directive your care team can find is meant to be followed. Findability is what makes it work.';

  @override
  String get revocationAreYouSure => 'Are you sure?';

  @override
  String get revocationPutItInWritingSign =>
      'Put it in writing — sign and date a short statement that you are revoking this directive.';

  @override
  String get revocationTellYourAgentYourProviders =>
      'Tell your agent, your providers, and anyone holding a copy.';

  @override
  String get revocationDestroyOldCopiesOrClearly =>
      'Destroy old copies, or clearly mark them “REVOKED”.';

  @override
  String get revocationIfYouHaveAnyFurther =>
      'If you have any further questions about how revocation applies to you, it is wise to consult an attorney for clarification.';

  @override
  String get pastDirectiveDetailNoShareHistoryIsKept =>
      'No share history is kept — nothing is saved after you close the app, so this list is empty by design.';

  @override
  String get wizardAiRailFullView => 'Full view';

  @override
  String get wizardAiRailYourApiKeyStaysOn =>
      'Your API key stays on this device and is only used to answer your questions. You can fill out the whole wizard without it.';

  @override
  String get wizardAiRailReadingThisStep => 'Reading this step…';

  @override
  String get wizardAiRailSuggestedForThisStep => 'SUGGESTED FOR THIS STEP';

  @override
  String get wizardAiRailAskAnythingAboutThisStep =>
      'Ask anything about this step — answers appear here, and in the full assistant.';

  @override
  String get wizardAiRailNeedHelpWithThisStep =>
      'Need help with this step? Ask the AI';

  @override
  String get wizardAiRailAiHelpIsOffThe =>
      'AI help is off. The step heads-up, suggested questions, photo auto-fill, and the chat below aren\'t available until you set up AI.';

  @override
  String get wizardAiRailCheckingThisStep => 'Checking this step';

  @override
  String get wizardAiRailFindAPaFacilityBy =>
      'Find a PA facility by name or county…';

  @override
  String get wizardAiRailThinking => 'Thinking…';

  @override
  String get wizardAiRailAskAboutThisStep => 'Ask about this step…';

  @override
  String get wizardAiRailSending => 'Sending';

  @override
  String get sideEffectsBringAnythingYouCheckAnd =>
      'Bring anything you check — and especially anything marked \"discuss with your doctor\" — to your doctor or pharmacist. This list never tells you to start, stop, or change a medication.';

  @override
  String get sideEffectsTheseArePossibleInteractionsDrawn =>
      'These are possible interactions drawn from the medications’ FDA labels, written as questions to ask. They are not a warning to stop or change anything yourself — only your doctor or pharmacist can advise on your specific case.';

  @override
  String get sideEffectsAddTheMedicationsYouRe =>
      'Add the medications you\'re currently taking on the Medications step first, then come back here to check their common side effects.';

  @override
  String get audioGuideToTranscribeYourRecordingIncluding =>
      'To transcribe, your recording — including any personal details you speak — is sent to Google\'s AI. On the free tier it may be retained and reviewed, and can\'t be recalled. Don\'t say anything you\'re not comfortable sending; you can always type sensitive fields by hand instead.';

  @override
  String get ulyssesClauseIfFutureMeRefuses => 'If future-me refuses…';

  @override
  String get ulyssesClauseStronglyRecommendedTalkWithA =>
      'Strongly recommended: talk with a peer specialist or clinician before saving. See \"Get help\" in Settings.';

  @override
  String get aiSetupIsTheApiKeyReally => 'Is the API key really free?';

  @override
  String get aiSetupYesGoogleOffersAGenerous =>
      'Yes. Google offers a generous free tier for Gemini. There is no credit card required and no charge for typical personal use.';

  @override
  String get aiSetupWhatGoogleAccountShouldI =>
      'What Google account should I use?';

  @override
  String get aiSetupAnyGoogleAccountWorksA =>
      'Any Google account works — a personal Gmail is fine. You do not need a Google Cloud billing account.';

  @override
  String get aiSetupCanIRevokeTheKey => 'Can I revoke the key later?';

  @override
  String get aiSetupYesVisitAistudioGoogleCom =>
      'Yes. Visit aistudio.google.com/apikey at any time to delete or regenerate your key. You can also remove it from this app using the trash icon in the top-right.';

  @override
  String get aiSetupWhatIfIDonT => 'What if I don\'t add a key?';

  @override
  String get aiSetupTheAppWorksFullyWithout =>
      'The app works fully without AI. The form wizard, PDF generation, educational content, and all other features do not require an API key. AI is purely optional.';

  @override
  String get accessibilitySettingsMakeItReadable => 'Make it readable.';

  @override
  String get accessibilitySettingsLegalTextIsAlwaysRendered =>
      'Legal text is always rendered in English to preserve PA Act 194 wording.';

  @override
  String get facilitatorYouDonTHaveTo => 'You don\'t have to do this alone.';

  @override
  String get facilitatorPeerSpecialistAdvocateReferral =>
      '♥ Peer specialist / advocate referral';

  @override
  String get facilitatorSomeoneIAlreadyTrust => '👥 Someone I already trust';

  @override
  String get facilitatorMyCareTeam => '🧠 My care team';

  @override
  String get facilitatorPreferToDoItYourself =>
      'Prefer to do it yourself? That\'s fine — keep going from where you left off.';

  @override
  String get moreSheetCallOrText98824 => 'Call or text 988 · 24/7 support';

  @override
  String get moreSheetUploadADocumentPhotoOr =>
      'Upload a document, photo, or recording';

  @override
  String get moreSheetPreviewAndExportYourDirective =>
      'Preview and export your directive packet';

  @override
  String get moreSheetEraseThisSessionAndStart =>
      'Erase this session and start fresh';

  @override
  String get crisisSheetYouAreNotAlone => 'You are not alone.';

  @override
  String get crisisSheetCallOrText988 => 'Call or text 988';

  @override
  String get crisisSheetCall988Press1 => 'Call 988, press 1';

  @override
  String get crisisSheetCallTextChat => 'Call · text · chat';

  @override
  String get assistantSenderYou => 'You';

  @override
  String get assistantSenderAi => 'AI Assistant';

  @override
  String get aiSetupApiKeySetForThis => 'API key set for this session';

  @override
  String get aiSetupApiKeySaved => 'API key saved';

  @override
  String get aiSetupGetYourFreeGeminiApi => 'Get Your Free Gemini API Key';

  @override
  String aiSetupAddYourApiKey(Object label) {
    return 'Add Your $label API Key';
  }

  @override
  String get aiSetupTheAssistantUsesGoogleS =>
      'The assistant uses Google\'s Gemini model. You need a free API key from Google AI Studio — it takes about 30 seconds.';

  @override
  String aiSetupYouBringYourOwnApi(Object label) {
    return 'You bring your own $label API key. Your provider\'s usage limits and billing apply — this app never sees or charges for your usage. Gemini stays the free default if you\'d rather not pay.';
  }

  @override
  String get aiSetupOpenGoogleAiStudioIn =>
      'Open Google AI Studio (in your private window)';

  @override
  String aiSetupOpenInYourPrivateWindow(Object label) {
    return 'Open $label (in your private window)';
  }

  @override
  String get aiSetupUseAnyGoogleAccountPersonal =>
      'Use any Google account (personal Gmail works fine)';

  @override
  String get aiSetupSignInThenOpenThe => 'Sign in, then open the API keys page';

  @override
  String get aiSetupOpenAiStudio => 'Open AI Studio';

  @override
  String aiSetupOpen(Object label) {
    return 'Open $label';
  }

  @override
  String get aiSetupSignInWithGoogle => 'Sign in with Google';

  @override
  String aiSetupSignInTo(Object label) {
    return 'Sign in to $label';
  }

  @override
  String get aiSetupNoCreditCardOrPayment =>
      'No credit card or payment is needed. The free tier is generous and sufficient for this app.';

  @override
  String get aiSetupMostProvidersRequireAPaid =>
      'Most providers require a paid account with credits to use the API. Your provider bills you directly.';

  @override
  String get aiSetupKeySetForThisSession => 'Key set for this session';

  @override
  String get aiSetupKeySaved => 'Key saved';

  @override
  String get aiSetupShowApiKey => 'Show API key';

  @override
  String get aiSetupHideApiKey => 'Hide API key';

  @override
  String get aiSetupUseKeyForThisSession => 'Use Key for This Session';

  @override
  String get aiSetupSaveApiKey => 'Save API Key';

  @override
  String get aiSetupTesting => 'Testing…';

  @override
  String get aiSetupTestConnection => 'Test connection';

  @override
  String aiSetupThatDoesnTLookLike(Object label, Object keyHint) {
    return 'That doesn\'t look like a valid $label key ($keyHint).';
  }

  @override
  String aiSetupCouldNotPasteTryPasting(Object pasteShortcutLabel) {
    return 'Could not paste. Try pasting manually ($pasteShortcutLabel).';
  }

  @override
  String aiSetupMayBeBlockedByYour(Object label) {
    return '$label may be blocked by your browser\'s security (CORS) on the web. If it doesn\'t respond, pick Gemini or Claude — both work in the browser.';
  }

  @override
  String aiSetupTheKeyLooksLikeCopy(Object keyHint) {
    return 'The key looks like \"$keyHint\" — copy it, then use the paste button or paste it manually.';
  }

  @override
  String aiSetupApiKey(Object label) {
    return '$label API Key';
  }

  @override
  String get adminUpdateBlankUseTheAppS =>
      'Blank = use the app\'s saved Gemini key. Not stored.';

  @override
  String get adminUpdateEnteredForThisSessionOnly =>
      'Entered for this session only — not stored.';

  @override
  String get adminUpdateDrafting => 'Drafting…';

  @override
  String get adminUpdateStartUpdateWithAi => 'Start update with AI';

  @override
  String adminUpdateRestoreFromBackupFieldS(
    Object changesLength,
    Object assetPath,
  ) {
    return 'Restore from backup: $changesLength field(s) differ from the previous version of $assetPath. Tick the part(s) to roll back (all pre-ticked = full revert).';
  }

  @override
  String adminUpdateProposedChangeSReviewEach(Object changesLength) {
    return '$changesLength proposed change(s). Review each — tick VERIFY items only if you have confirmed them.';
  }

  @override
  String adminUpdateVerifyTierChangeSNot(Object verifyCount) {
    return '$verifyCount verify-tier change(s) not yet approved';
  }

  @override
  String get adminUpdateReady => 'Ready';

  @override
  String get adminUpdateBuildRestoredJson => 'Build restored JSON';

  @override
  String get adminUpdateBuildUpdatedJson => 'Build updated JSON';

  @override
  String adminUpdateContextInOut(
    Object displayName,
    Object note,
    Object inputTokenLimit,
    Object outputTokenLimit,
  ) {
    return '$displayName\n$note\ncontext $inputTokenLimit in / $outputTokenLimit out';
  }

  @override
  String adminUpdateBestGeminiModelNow(Object currentModel) {
    return 'Best Gemini model (now: $currentModel)';
  }

  @override
  String adminUpdateCheckTheNewestModelsLive(Object label) {
    return 'Check the newest $label models (live API)';
  }

  @override
  String adminUpdateApiKey(Object label) {
    return '$label API key';
  }

  @override
  String adminUpdateSource(Object source) {
    return 'Source: $source';
  }

  @override
  String adminUpdateRestoredTheSelectedFieldS(Object assetPath) {
    return 'RESTORED — the selected field(s) have been rolled back to the backup. Commit this over $assetPath to apply the roll-back.';
  }

  @override
  String adminUpdateUpdatedReplaceThatFileWith(Object assetPath) {
    return 'Updated $assetPath. Replace that file with this and commit — the release makes it live for everyone.';
  }

  @override
  String get reminderSheetsTimeToRenew => 'Time to renew.';

  @override
  String reminderSheetsTimeToRenew2(Object firstName) {
    return 'Time to renew, $firstName.';
  }

  @override
  String reminderSheetsExpires(Object dayLabel) {
    return '● Expires $dayLabel';
  }

  @override
  String get revocationWillBeReferencedInYour =>
      'Will be referenced in your revocation letter';

  @override
  String get revocationTapToInclude => 'Tap to include';

  @override
  String get revocationRevoking => 'Revoking…';

  @override
  String get revocationRevokeNow => 'Revoke now';

  @override
  String pastDirectiveDetailUnableToLoad(Object error) {
    return 'Unable to load: $error';
  }

  @override
  String pastDirectiveDetailTheDirectiveRemainsRegardless(Object status) {
    return 'The directive remains $status regardless';
  }

  @override
  String get pinDialogShowPasscode => 'Show passcode';

  @override
  String get pinDialogHidePasscode => 'Hide passcode';

  @override
  String get modeSelectionOnTheWebYourData =>
      'On the web your data is kept in memory only and is never sent to a server, so encrypted on-device (Private mode) storage is not available here.';

  @override
  String get modeSelectionThisAppIsNotHipaa =>
      'This app is not HIPAA-compliant. Nothing is sent to a server for storage.';

  @override
  String modeSelectionSelect(Object title, Object recommended) {
    return 'Select $title$recommended';
  }

  @override
  String sideEffectsCheckingCovers(Object currentMedsJoin) {
    return 'Checking covers: $currentMedsJoin';
  }

  @override
  String sideEffectsReCheckFor(Object currentMedsJoin) {
    return 'Re-check for: $currentMedsJoin';
  }

  @override
  String get sideEffectsCheckSideEffects => 'Check side effects';

  @override
  String get sideEffectsReCheck => 'Re-check';

  @override
  String sideEffectsMayAffect(Object adlImpact) {
    return 'May affect: $adlImpact';
  }

  @override
  String educationCategoryBrowserSections(
    Object title,
    Object count,
    Object sub,
  ) {
    return '$title, $count sections. $sub';
  }

  @override
  String get learnAiPanelAskAQuestionToGet =>
      'Ask a question to get started — e.g. \"What\'s the difference between a declaration and a power of attorney?\"';

  @override
  String get learnAiPanelSetUpTheFreeAi =>
      'Set up the free AI assistant to ask questions while you read.';

  @override
  String learnAiPanelPiiStripped(Object nameToUpperCase) {
    return '● $nameToUpperCase · PII STRIPPED';
  }

  @override
  String educationArticleDetailQuestionsContactPaProtectionAdvocacy(
    Object paProtectionAdvocacy,
  ) {
    return 'Questions? Contact PA Protection & Advocacy: $paProtectionAdvocacy';
  }

  @override
  String audioGuideExample(Object example) {
    return 'Example: $example';
  }

  @override
  String exportCardsExecuted(Object executionDate) {
    return 'Executed: $executionDate';
  }

  @override
  String exportCardsExpires(Object expirationDate) {
    return 'Expires: $expirationDate';
  }

  @override
  String get pdfPreviewFit => 'FIT';

  @override
  String pdfPreviewPageOf(Object current, Object pageCount) {
    return 'Page $current of $pageCount';
  }

  @override
  String pdfPreviewGoToPage(Object i) {
    return 'Go to page $i';
  }

  @override
  String pdfPreviewPage(Object i) {
    return 'Page $i';
  }

  @override
  String get exportGeneratingPdfPreview => 'Generating PDF preview';

  @override
  String get exportPreviewPdfBeforeSharing => 'Preview PDF before sharing';

  @override
  String exportTheFollowingFieldsAreEmpty(Object n) {
    return 'The following fields are empty or missing:\n\n$n\n\nAn incomplete directive may not be legally valid under PA Act 194. Export anyway?';
  }

  @override
  String privacyPolicyLastUpdated(
    Object privacyPolicyUpdated,
    Object privacyPolicyVersion,
  ) {
    return 'Last updated: $privacyPolicyUpdated ($privacyPolicyVersion)';
  }

  @override
  String privacyPolicyYouCanReachTheDeveloper(Object privacyPolicyUrl) {
    return 'The FTC Health Breach Notification Rule requires at least two contact methods. We provide:\n\n  - In-app: an in-app breach notice will be shown the next time you open the app if a breach affects you.\n  - Online: $privacyPolicyUrl (also used for breach postings if direct contact information is insufficient).';
  }

  @override
  String get settingsScreenshotsAreBlocked => 'Screenshots are blocked';

  @override
  String get settingsScreenshotsAreAllowed => 'Screenshots are allowed';

  @override
  String assistantMessageWidgetsAt(
    Object sender,
    Object timeStr,
    Object content,
  ) {
    return '$sender at $timeStr: $content';
  }

  @override
  String assistantActiveTextPiiStrippedBefore(Object model) {
    return '● ACTIVE · $model · TEXT PII STRIPPED BEFORE SEND';
  }

  @override
  String get assistantNotSetUpAddA => '○ NOT SET UP · ADD A KEY TO USE THE AI';

  @override
  String assistantOlderMessagesWereTrimmedTo(Object trimmedCount) {
    return '$trimmedCount older messages were trimmed to fit within the AI\'s context limit. Recent messages are preserved.';
  }

  @override
  String assistantNotLegalOrMedicalAdvice(Object paProtectionAdvocacy) {
    return 'Not legal or medical advice. For legal questions contact PA Protection & Advocacy: $paProtectionAdvocacy';
  }

  @override
  String assistantFreeTierRequestsMinRequests(
    Object model,
    Object maxRpm,
    Object maxRpd,
    Object tpmK,
    Object contextK,
  ) {
    return '$model free tier:\n$maxRpm requests/min\n$maxRpd requests/day\n${tpmK}K tokens/min\n${contextK}K max context';
  }

  @override
  String get homeToolsGridSuggestsChecks => 'Suggests + checks';

  @override
  String get homeToolsGridShareCarry => 'Share + carry';

  @override
  String get homeToolsGridNoDirectiveYet => 'No directive yet';

  @override
  String homeDirectiveHeroContinueYourLastEdited(
    Object formLabel,
    Object pctLabel,
    Object lastEdited,
  ) {
    return 'Continue your $formLabel — $pctLabel, last edited $lastEdited';
  }

  @override
  String homeDirectiveHeroStepOf(Object currentStep, Object totalSteps) {
    return 'Step $currentStep of $totalSteps';
  }

  @override
  String homeDirectiveHeroLastEdited(Object formLabel, Object lastEdited) {
    return '$formLabel · last edited $lastEdited';
  }

  @override
  String facilitatorPickTheKindOfSupport(Object facilitatorCompletionStat) {
    return '$facilitatorCompletionStat Pick the kind of support that fits today.';
  }

  @override
  String get disclaimerYouWorkAnonymouslyInThis =>
      'You work anonymously in this browser tab — no account, no cloud, no tracking. If you close the tab your work is kept on this device for about 10 minutes for recovery, then wiped — open and save your PDF to keep it.';

  @override
  String get disclaimerNoAccountNoCloudNo =>
      'No account, no cloud, no tracking — nothing goes to our servers. Anything you save stays encrypted on this device, where only you can open it.';

  @override
  String draftRecoveryDialogItLooksLikeTheApp(Object ageDescription) {
    return 'It looks like the app closed unexpectedly. An auto-saved draft was found from $ageDescription.\n\nThis draft contains your treatment preferences and medical data (no personal information was saved).\n\nWould you like to restore it?';
  }

  @override
  String stepDotsStepOf(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String stepDotsGoToStepOf(Object i, Object total) {
    return 'Go to step $i of $total';
  }

  @override
  String healthChipLearnAbout(Object label) {
    return 'Learn about $label';
  }

  @override
  String healthChipRemove(Object label) {
    return 'Remove $label';
  }

  @override
  String crisisSheetTextHomeTo(Object crisisTextLine) {
    return 'Text HOME to $crisisTextLine';
  }

  @override
  String crisisSheetTreatmentReferrals(Object samhsa) {
    return '$samhsa · treatment referrals';
  }

  @override
  String crisisSheetKnowYourRights(Object paProtectionAdvocacy) {
    return '$paProtectionAdvocacy · know your rights';
  }

  @override
  String fdaLabelDialogFdaLabel(Object medName) {
    return '$medName — FDA label';
  }

  @override
  String nlmAttributionSourceUSNationalLibrary(Object medicalDisclaimer) {
    return 'Source: U.S. National Library of Medicine. $medicalDisclaimer';
  }

  @override
  String aiConsentDialogToAutofillYourDirectiveThe(Object label) {
    return 'To autofill your directive, the whole document — including any personal details on it (names, dates of birth, addresses, phone numbers) — is sent to $label so it can read it and fill in your fields.';
  }

  @override
  String aiConsentDialogForMoreAccurateTranscriptionEspecially(Object label) {
    return 'For more accurate transcription (especially medication names and conditions), your voice recording — including any personal details you say — is sent to $label to turn into text.';
  }

  @override
  String aiConsentDialogTextYouEnterWillBe(Object label, Object provider) {
    return '• Text you enter will be sent to $label for AI processing. $provider\n';
  }

  @override
  String aiConsentDialogByTappingIAuthorizeYou(Object label) {
    return '\nBy tapping \"I Authorize,\" you consent to sending your text to $label for AI processing under these terms.\n\nThis notice appears once per session.';
  }

  @override
  String get exportDraftModeFinal => 'Final copy';

  @override
  String get exportDraftModeDraft => 'Draft';

  @override
  String get exportDraftModeSignedExists => 'Draft · signed copy exists';

  @override
  String exportOpenedManyPdfs(int count) {
    return 'Opened $count PDFs in new tabs — print or save each from your PDF viewer.';
  }

  @override
  String get exportOpenedOnePdf =>
      'Opened in a new tab — use Print or Download in your PDF viewer.';

  @override
  String get exportNoAgentDesignated =>
      'No agent designated — agent sections will be blank';

  @override
  String get exportWalletYourName => 'Your name';

  @override
  String get exportWalletSignToActivate => 'sign to activate';

  @override
  String get exportEffectiveCondition => 'Effective condition';

  @override
  String get exportWitnessSignatures => 'Witness signatures';

  @override
  String get exportPrintedCopyType => 'Printed copy type';

  @override
  String get exportADraftPrintsALight =>
      'A draft prints a light “DRAFT” watermark on every page — for sending a copy while you keep the signed paper original. Tick as many as you like — Download gives you one PDF of each.';

  @override
  String get exportDocumentLanguage => 'Document language';

  @override
  String get exportThePlainLanguageOfficialForm =>
      'The plain-language official form is the one you sign and use — it is the legally valid directive. The legal-language version restates it in formal statutory wording for reference only and is not the document you sign.';

  @override
  String get exportThisOpensYourDirectiveIn =>
      'This opens your directive in your PDF viewer (a new browser tab), where you can Print it or save/Download it — it will NOT download automatically.';

  @override
  String get exportWalletCard => 'Wallet card';

  @override
  String get exportACreditCardSizedSummary =>
      'A credit-card-sized summary you can print and carry.';

  @override
  String get exportSaveAnEditableCopy => 'Save an editable copy';

  @override
  String get exportNotAFinishedDocumentThis =>
      'Not a finished document — this is how you save your progress. The web app can’t store your work on this device, so download this file to keep it, then re-upload it later (here or on another device) to keep editing. Nothing is stored online.';

  @override
  String get exportEncryptingHindersOthersFromReading =>
      'Encrypting hinders others from reading it; the app still opens it with no passphrase.';

  @override
  String get exportMachineReadableFormats => 'Machine-readable formats';

  @override
  String get exportYourPdfAboveIsThe =>
      'Your PDF above is the document you sign — these are data exports for your records, a spreadsheet, or a health system. FHIR is the standard format hospitals use to exchange medical records; CSV is a spreadsheet file (opens in Excel or Google Sheets).';

  @override
  String aiSetupTestOk(String provider) {
    return '$provider responded. This key and model work.';
  }

  @override
  String get aiSetupPrivacyLeadGemini =>
      'On the Gemini free tier, Google may use data you send to improve their AI products, and human reviewers may read your inputs.';

  @override
  String aiSetupPrivacyLeadOther(String provider) {
    return 'Your $provider key sends data to $provider; their data-use and retention policy applies.';
  }

  @override
  String get aiSetupPrivacyKeyEphemeral =>
      'Your API key is kept in memory for this session, with a temporary copy for up to 10 minutes (for crash recovery); it is discarded when the session ends.';

  @override
  String get aiSetupPrivacyKeyStored =>
      'Your API key is stored securely on this device only and is never shared with anyone other than your AI provider.';

  @override
  String aiSetupPrivacyNoticeBody(String lead, String keyLine) {
    return '$lead\n\nThe AI features in this app send text you enter in form fields and chat messages to your AI provider\'s servers. Do not include personally identifying details (full legal name, Social Security number, date of birth, etc.) in AI chat or when using AI Suggest.\n\n$keyLine';
  }

  @override
  String get aiSetupDuckDuckGoNote =>
      'All browsing is private (Fire Button clears)';

  @override
  String aiSetupProviderFree(String provider) {
    return '$provider (free)';
  }

  @override
  String aiSetupShortcutWithMac(
    String browser,
    String shortcut,
    String macShortcut,
  ) {
    return '$browser:  $shortcut  (Mac: $macShortcut)';
  }

  @override
  String aiSetupShortcutMacOnly(String browser, String macShortcut) {
    return '$browser:  $macShortcut  (Mac only)';
  }

  @override
  String get feAiUnreachable =>
      'Couldn\'t reach the AI service. Check your internet connection. If you are using the web app, this provider may also be blocked by your browser\'s security policy — Gemini and Claude both work in the browser.';

  @override
  String get feNoInternet =>
      'No internet connection. Please check your network and try again.';

  @override
  String get feTimeout =>
      'The request timed out. Please check your connection and try again.';

  @override
  String get feBlocked =>
      'Couldn\'t reach the AI service — the request was blocked or the connection failed. Check your internet connection, and if you are on the web app try Gemini or Claude, which work in the browser.';

  @override
  String get feRateLimited =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get feKeyRejected =>
      'Your API key was rejected. Open AI setup and check the key is correct, still active, and belongs to the selected provider.';

  @override
  String get feModelUnavailable =>
      'The selected AI model isn\'t available — it may have been retired. Pick a different model in AI setup.';

  @override
  String get feEmptyResponse =>
      'The AI returned no results. Try again or enter the information manually.';

  @override
  String get feBadFormat =>
      'The AI response was not in the expected format. Please try again.';

  @override
  String get feServiceError =>
      'The AI service encountered an error. Please try again later.';

  @override
  String get fePermission =>
      'Permission was not granted. Please check your device settings.';

  @override
  String get feGeneric => 'Something went wrong. Please try again.';

  @override
  String assistantSendError(String error) {
    return 'Sorry, I encountered an error: $error';
  }

  @override
  String assistantVerifyError(String error) {
    return 'Sorry, I couldn\'t verify that on the web: $error';
  }

  @override
  String get permissionsOverviewUnlockingEncryptedOnDeviceStorage =>
      'Unlocking encrypted on-device storage (native app only; not used by the web app).';

  @override
  String get permissionsOverviewUsedOnlyToVerifyYour =>
      'Used only to verify your identity on unlock';

  @override
  String get permissionsOverviewBiometricDataNeverLeavesThe =>
      'Biometric data never leaves the OS keystore';

  @override
  String get permissionsOverviewNoBiometricDataIsSent =>
      'No biometric data is sent to any server';

  @override
  String get permissionsOverviewFallsBackToAPasscode =>
      'Falls back to a passcode you choose if biometrics fail';

  @override
  String get permissionsOverviewNotApplicableOnThisPlatform =>
      'Not applicable on this platform';

  @override
  String get permissionsOverviewRemindingYouAboutWitnessSigning =>
      'Reminding you about witness signing, renewals, and check-ins.';

  @override
  String get permissionsOverviewYouChooseWhichRemindersTo =>
      'You choose which reminders to enable';

  @override
  String get permissionsOverviewNotificationsAreScheduledLocallyOn =>
      'Notifications are scheduled locally on this device';

  @override
  String get permissionsOverviewNoContentPiiDirectiveText =>
      'No content (PII, directive text) is in any notification body';

  @override
  String get permissionsOverviewDisablePerCategoryInDevice =>
      'Disable per-category in device Settings → Notifications';

  @override
  String get permissionsOverviewSnappingAPhotoOfYour =>
      'Snapping a photo of your ID, medication labels, or condition lists for AI-assisted field extraction. Coming in a later release.';

  @override
  String get permissionsOverviewPhotoIsSentToAi =>
      'Photo is sent to AI only to read it';

  @override
  String get permissionsOverviewPhotoIsDiscardedRightAfter =>
      'Photo is discarded right after extraction';

  @override
  String get permissionsOverviewNothingIsSavedToYour =>
      'Nothing is saved to your device\'s photo library by default';

  @override
  String get permissionsOverviewYouReviewEveryFieldBefore =>
      'You review every field before it\'s used';

  @override
  String get permissionsOverviewNotYetWiredFeatureIn =>
      'Not yet wired — feature in a future release';

  @override
  String get permissionsOverviewSpeakingLongFormAnswersE =>
      'Speaking long-form answers (e.g. \"anything else\") instead of typing. Coming in a later release.';

  @override
  String get permissionsOverviewAudioIsProcessedOnDevice =>
      'Audio is processed on-device when possible';

  @override
  String get permissionsOverviewIfSentToAiFor =>
      'If sent to AI for transcription, it isn\'t stored';

  @override
  String get permissionsOverviewTranscriptStaysInYourSession =>
      'Transcript stays in your session — never uploaded';

  @override
  String get permissionsOverviewToggleOffAtAnyTime =>
      'Toggle off at any time in Settings';

  @override
  String get permissionsOverviewPickingAnAgentOrWitness =>
      'Picking an agent or witness from your address book instead of typing their details. Coming in a later release.';

  @override
  String get permissionsOverviewWeNeverUploadYourContacts =>
      'We never upload your contacts';

  @override
  String get permissionsOverviewSearchRunsLocallyOnThis =>
      'Search runs locally on this device';

  @override
  String get permissionsOverviewOnlyTheContactYouPick =>
      'Only the contact you pick is brought into the directive';

  @override
  String get permissionsOverviewYouCanRevokeAccessIn =>
      'You can revoke access in Settings any time';

  @override
  String get permissionsOverviewAvailableOsManaged => 'Available · OS-managed';

  @override
  String get eduBrowseIntroduction => 'Introduction';

  @override
  String get eduBrowseWhatAnMhadIsAnd =>
      'What an MHAD is and who should sign one';

  @override
  String get eduBrowseCombinedForm => 'Combined Form';

  @override
  String get eduBrowseBothAnAgentAndTreatment =>
      'Both an agent and treatment preferences';

  @override
  String get eduBrowseTreatmentPreferencesWithoutAnAgent =>
      'Treatment preferences without an agent';

  @override
  String get eduBrowsePowerOfAttorney => 'Power of Attorney';

  @override
  String get eduBrowseAgentDesignationWithoutPreferences =>
      'Agent designation without preferences';

  @override
  String get eduBrowseFrequentlyAsked => 'Frequently Asked';

  @override
  String get eduBrowseCommonQuestionsAboutMhads =>
      'Common questions about MHADs';

  @override
  String get eduBrowseGlossary => 'Glossary';

  @override
  String get eduBrowseEveryLegalTermDefined => 'Every legal term, defined';

  @override
  String get eduBrowseBeyondTheBooklet => 'Beyond the Booklet';

  @override
  String get eduBrowseTopicsNotCoveredInThe =>
      'Topics not covered in the official PA booklet';

  @override
  String get eduBrowseYourChecklist => 'Your Checklist';

  @override
  String get eduBrowseStepByStepDistributionRevocation =>
      'Step-by-step distribution + revocation guides';

  @override
  String get webLandingPreferPaperOpenAnyOf =>
      'Prefer paper? Open any of the three empty official forms to print and fill in by hand — no account or wizard needed.';

  @override
  String get webLandingNoAccountRequired => 'No account required';

  @override
  String get webLandingNoEmailNoPasswordNo =>
      'No email, no password, no sign-up.';

  @override
  String get webLandingNothingLeavesYourBrowser =>
      'Nothing leaves your browser';

  @override
  String get webLandingYourAnswersLiveInThis =>
      'Your answers live in this tab. We never see them.';

  @override
  String get webLandingNoCookiesNoTracking => 'No cookies, no tracking';

  @override
  String get webLandingNoAnalyticsNoThirdParty =>
      'No analytics, no third-party scripts.';

  @override
  String get webLandingYouKeepTheFile => 'You keep the file';

  @override
  String get webLandingSaveThePdfFromYour =>
      'Save the PDF from your viewer — that’s the only copy.';

  @override
  String get pinDialogPasscodeTooShort =>
      'Passcode must be at least 4 characters.';

  @override
  String get pinDialogPasscodesDontMatch => 'Passcodes do not match.';

  @override
  String get pinDialogUnlockPrivateMode => 'Unlock private mode';

  @override
  String get pinDialogEnterPasscode => 'Please enter your passcode.';

  @override
  String get pinDialogTooManyAttempts =>
      'Too many attempts. Please wait 30 seconds.';

  @override
  String get pinDialogIncorrectPasscode =>
      'Incorrect passcode. Please try again.';

  @override
  String get deviceSecurityWarningTitle => 'Device Security Warning';

  @override
  String get deviceSecurityWarningBody =>
      'Your device appears to be rooted/jailbroken. This may put your sensitive health data at risk. Consider using a non-modified device for storing advance directives.';

  @override
  String get deviceSecurityIUnderstand => 'I Understand';

  @override
  String get blankFormPrintTitle => 'Print a blank form';

  @override
  String blankFormPrintError(String error) {
    return 'Could not open the blank form to print: $error';
  }

  @override
  String launchCopiedToClipboard(String value) {
    return '$value copied to clipboard';
  }

  @override
  String get reminderRenewMetricSections => 'sections';

  @override
  String get reminderRenewMetricWetInk => 'wet-ink';

  @override
  String get reminderRenewMetricSigning => 'signing';

  @override
  String get reminderRenewMetricMin => 'min';

  @override
  String get educationBefore => 'before';

  @override
  String get assistantGeneralQuestion => 'General question';

  @override
  String get assistantContextPanelStrippedBeforeSend => 'Stripped before send';

  @override
  String get assistantSuggestWalkMeThroughFillingOut =>
      'Walk me through filling out my directive step by step';

  @override
  String get assistantSuggestWhatIsAMentalHealth =>
      'What is a Mental Health Advance Directive?';

  @override
  String get assistantSuggestWhatSTheDifferenceBetween =>
      'What\'s the difference between Combined, Declaration, and POA?';

  @override
  String get assistantSuggestWhoCanBeMyAgent => 'Who can be my agent?';

  @override
  String get assistantSuggestWhatMedicationsShouldIList =>
      'What medications should I list?';

  @override
  String get assistantSuggestWhatDoesEctMean => 'What does ECT mean?';

  @override
  String get assistantSuggestHowLongIsTheDirective =>
      'How long is the directive valid?';

  @override
  String get assistantSuggestCanIChangeMyDirective =>
      'Can I change my directive later?';

  @override
  String get ulyssesOnlyAppliesOnceIHave =>
      'Only applies once I have been formally found to lack capacity';

  @override
  String get ulyssesOnlyForTreatmentsIExplicitly =>
      'Only for treatments I explicitly named (medications, ECT, facility)';

  @override
  String get ulyssesDoesNotAuthorizePhysicalRestraint =>
      'Does not authorize physical restraint';

  @override
  String get ulyssesACourtAppointedGuardianNot =>
      'A court-appointed guardian (not the agent) may revoke, suspend, or terminate';

  @override
  String get ulyssesMyDirectiveStillTerminatesAt =>
      'My directive still terminates at 2 years — unless I am incapable when it would expire, in which case it remains in effect (§§ 5824(e), 5834(c))';

  @override
  String homeHeroPercentComplete(int percent) {
    return '$percent% complete';
  }

  @override
  String get homeHeroReadyToReviewSign => 'Ready to review & sign';

  @override
  String homeHeroMoreSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '~ $count more steps',
      one: '~ 1 more step',
    );
    return '$_temp0';
  }

  @override
  String get homeHeroCombinedForm => 'Combined form';

  @override
  String get homeHeroDeclarationOnly => 'Declaration only';

  @override
  String homeHeroNamedMhad(String name) {
    return '$name’s MHAD';
  }

  @override
  String get homeHeroYourMhad => 'Your MHAD';

  @override
  String get educationNoResultsFound => 'No results found.';

  @override
  String educationNoResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get relativeJustNow => 'just now';

  @override
  String relativeMinsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mins ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String relativeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String relativeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get revocationNotifyPrimaryCareDoctor => 'Primary care doctor';

  @override
  String get revocationNotifyPsychiatristTherapist =>
      'Psychiatrist / therapist';

  @override
  String get revocationNotifyNearestHospitalEr => 'Nearest hospital ER';

  @override
  String get revocationNotifyPharmacy => 'Pharmacy';

  @override
  String get revocationNotifyLocalRightsAdvocate => 'Local rights advocate';

  @override
  String get legalSheetBoldNot => 'not';

  @override
  String get legalSheetBoldOnly => 'only';

  @override
  String get legalSheetBoldTwoAdultWitnesses => 'two adult witnesses';

  @override
  String get legalSheetBoldWitnessesCannotBe => 'Witnesses cannot be: ';

  @override
  String get legalSheetBoldPrinted => 'printed';

  @override
  String get legalSheetBoldMustComply => 'must comply';

  @override
  String get legalSheetBoldTwoYears => 'two years';

  @override
  String get legalSheetBoldUnlessYouAreFoundIncapable =>
      'unless you are found incapable';

  @override
  String get legalSheetBoldNotSavedPermanently => 'not saved permanently';

  @override
  String get legalSheetBoldAutomaticallyKeepsIdentifyingDetailsOut =>
      'automatically keeps identifying details out of what it sends to the AI assistant and its suggestions';

  @override
  String get legalSheetBoldUploadingIsNeverRequired =>
      'Uploading is never required';

  @override
  String get legalSheetBoldTheseLookupsSendOnlyThe =>
      'These lookups send only the medical term, code, or provider name being searched';

  @override
  String get legalSheetYourRightsUnderAct194 => 'Your rights under Act 194';

  @override
  String get legalSheet247FreeConfidential => '24/7, free, confidential';

  @override
  String get legalSheetCallOrText988 => 'Call or text 988';

  @override
  String get crisisPlanTheFirstThingsINotice =>
      'The first things I notice when my mood shifts.';

  @override
  String get crisisPlanExternalThingsThatHaveSet =>
      'External things that have set off episodes before.';

  @override
  String get crisisPlanSpecificConcreteNotSelfCare =>
      'Specific, concrete. Not \'self-care\' — what actually works.';

  @override
  String get crisisPlanWordsThatGroundMeUseful =>
      'Words that ground me. Useful for staff, EMS, family.';

  @override
  String get crisisPlanApproachesThatEscalateMeBe =>
      'Approaches that escalate me. Be specific.';

  @override
  String get reminderSheetsAgentsPrimaryAndAlternate =>
      'Agents — primary and alternate';

  @override
  String get reminderSheetsCurrentMedsOnesYouDon =>
      'Current meds, ones you don\'t want, allergies';

  @override
  String get reminderSheetsPreferredFacilityRoomEnvironment =>
      'Preferred facility, room environment';

  @override
  String get accessibilitySettingsAtkinsonHyperlegibleClearerEasierLetter =>
      'Atkinson Hyperlegible — clearer, easier letter shapes';

  @override
  String get accessibilitySettingsHeavierTextWeightEverywhere =>
      'Heavier text weight everywhere';

  @override
  String get accessibilitySettingsRemovesScreenTransitionsAndAnimations =>
      'Removes screen transitions and animations';

  @override
  String get accessibilitySettingsMaximizesSeparationBetweenTextAnd =>
      'Maximizes separation between text and background';

  @override
  String get accessibilitySettingsUseYourBrowserOrDevice =>
      'Use your browser or device read-aloud — see the guide below';

  @override
  String get accessibilitySettingsChromeEdgeDesktop =>
      'Chrome / Edge (desktop)';

  @override
  String get directiveFormChoiceTreatmentPreferencesWithoutNamingAn =>
      'Treatment preferences without naming an agent.';

  @override
  String get directiveFormChoiceNameADecisionMakerWithout =>
      'Name a decision-maker without listing preferences.';

  @override
  String get homeToolsGridFaqGlossary => 'FAQ, glossary';

  @override
  String get homeToolsGrid988More => '988 + more';

  @override
  String get facilitator45Min => '~45 min';

  @override
  String get facilitatorFree => 'Free';

  @override
  String get facilitatorPaBased => 'PA-based';

  @override
  String get facilitatorInPerson => 'In person';

  @override
  String get facilitatorYouStayInControl => 'You stay in control';

  @override
  String get facilitatorEmailComposer => 'Email composer';

  @override
  String get facilitatorManualTranscribeBack => 'Manual transcribe back';

  @override
  String get modeSelectionBiometrics => 'Biometrics';

  @override
  String get modeSelectionAes256 => 'AES-256';

  @override
  String get modeSelectionSaveDrafts => 'Save drafts';

  @override
  String get modeSelectionAcrossSessions => 'Across sessions';

  @override
  String get modeSelectionNothingSaved => 'Nothing saved';

  @override
  String get modeSelectionInMemoryOnly => 'In-memory only';

  @override
  String get modeSelectionSingleSession => 'Single session';

  @override
  String get pdfPreviewLoading => 'Loading…';

  @override
  String get pdfPreviewSelectASectionToPreview =>
      'Select a section to preview.';

  @override
  String get pdfPreviewCouldNotRenderThePreview =>
      'Could not render the preview.';

  @override
  String reminderSheetsStepN(int n) {
    return 'Step $n';
  }

  @override
  String get sideEffectsNoneFound =>
      'We couldn\'t find common side effects to list right now. You can add anything you\'re experiencing in the Anything-else step, and always raise side-effect concerns with your doctor.';

  @override
  String get sideEffectsGenerateError =>
      'Something went wrong generating the list. Please try again, or note side effects yourself.';

  @override
  String get inputPhoneInvalid => 'Enter a valid 10-digit phone number';

  @override
  String get inputZipInvalid => 'Enter a 5-digit or 5+4-digit ZIP';

  @override
  String get audioGuideTipQualityDoesnTMatterAny =>
      'Quality doesn\'t matter. Any phone voice memo works — the AI downsamples audio anyway, so a small low-quality file transcribes just as well as a large one.';

  @override
  String get audioGuideTipKeepEachClipShortUnder =>
      'Keep each clip short — under about 2 minutes. Record one clip per section below and upload them together; the app merges them. Long clips can time out.';

  @override
  String get audioGuideTipSayMedicationAndDoctorNames =>
      'Say medication and doctor names slowly and spell them. The AI won\'t guess a drug or condition it didn\'t clearly hear.';

  @override
  String get stepSubtitleAboutYou =>
      'Just the basics so this document is uniquely yours. Drop a photo of your ID and we\'ll read these for you.';

  @override
  String get stepSubtitleWhenItKicksIn =>
      'The conditions under which your directive becomes active. You can pick more than one.';

  @override
  String get stepSubtitlePeopleITrust =>
      'They speak for you if you can\'t. You can name a primary, an alternate, and set limits on what they decide.';

  @override
  String get stepSubtitleGuardianNomination =>
      'Rare, but worth planning for. A guardian is named by a court — not by you — and has broader authority than an agent.';

  @override
  String get stepSubtitleWhereIWantCare =>
      'Facilities you prefer — and any you specifically want to avoid — plus room and environment preferences.';

  @override
  String get stepSubtitleDiagnoses =>
      'Help your care team see the whole picture in a crisis. Search by name — we attach the ICD-10 code your doctors use.';

  @override
  String get stepSubtitleMedications =>
      'What you take now (for your care team) plus the medications you refuse, limit, or prefer. Your refusals and limits are binding under Act 194.';

  @override
  String get stepSubtitleAllergies =>
      'Drug allergies, sensitivities, past adverse reactions. This is the most-checked section by ER staff.';

  @override
  String get stepSubtitleProceduresResearch =>
      'Three treatments under PA law need your explicit consent. Set each one — your agent fills any gaps.';

  @override
  String get stepSubtitleAnythingElse =>
      'Free-form preferences not covered above. This is your voice — write it how you\'d say it.';

  @override
  String get stepSubtitleReviewAndSign =>
      'One last look, then we\'ll make your signing packet. Tap any section to edit.';

  @override
  String get formTypeNameCombined => 'Combined Declaration & Power of Attorney';

  @override
  String get formTypeNameDeclaration => 'Declaration Only';

  @override
  String get formTypeNamePoa => 'Power of Attorney Only';

  @override
  String get formTypeShortCombined => 'Combined';

  @override
  String get formTypeShortDeclaration => 'Declaration';

  @override
  String get formTypeShortPoa => 'Power of Attorney';

  @override
  String get stepTitleAboutYou => 'About you';

  @override
  String get stepTitleWhenItKicksIn => 'When this kicks in';

  @override
  String get stepTitlePeopleITrust => 'People I trust';

  @override
  String get stepTitleGuardianNomination => 'If a court appoints a guardian';

  @override
  String get stepTitleWhereIWantCare => 'Where I want care';

  @override
  String get stepTitleDiagnoses => 'Diagnoses';

  @override
  String get stepTitleMedications => 'Medications';

  @override
  String get stepTitleAllergies => 'Allergies & reactions';

  @override
  String get stepTitleProceduresResearch => 'Procedures & research';

  @override
  String get stepTitleAnythingElse => 'Anything else';

  @override
  String get stepTitleReviewAndSign => 'Review';

  @override
  String get directiveStatusRevoked => 'Revoked';

  @override
  String get directiveStatusExpired => 'Expired';

  @override
  String get directiveStatusActive => 'Active';

  @override
  String get directiveStatusDraft => 'Draft';

  @override
  String pastDirectiveSignedOn(String date) {
    return 'signed $date';
  }

  @override
  String pastDirectiveExpiredOn(String date) {
    return 'expired $date';
  }

  @override
  String pastDirectiveExpiresOn(String date) {
    return 'expires $date';
  }

  @override
  String get settingsDefaultUserName => 'PA MHAD user';

  @override
  String rateDailyLimitUsed(int max) {
    return 'You\'ve used all $max free requests for today. The limit resets at midnight. Consider upgrading to a paid API key for higher limits.';
  }

  @override
  String rateTooManyThisMinute(int max, int seconds) {
    return 'Too many requests this minute (limit: $max/min). Please wait $seconds seconds.';
  }

  @override
  String rateTokenLimitThisMinute(int thousands) {
    return 'Token limit reached this minute (${thousands}K/min). Please wait a moment before sending another request.';
  }

  @override
  String get rateDailyLimitReached => 'Daily limit reached';

  @override
  String rateWaitStatus(int seconds, int remaining) {
    return 'Wait ${seconds}s • $remaining requests left today';
  }

  @override
  String rateRemainingStatus(int remainingToday, int remainingMinute) {
    return '$remainingToday requests left today • $remainingMinute this minute';
  }

  @override
  String llmHeicUnsupported(String provider) {
    return '$provider can\'t read HEIC/HEIF photos (the iPhone default). Switch to Gemini, or re-save the photo as JPEG or PNG first.';
  }

  @override
  String llmPdfUnsupported(String provider) {
    return '$provider can\'t read PDFs here — switch to Gemini or Claude, or paste the document text instead.';
  }

  @override
  String llmFileTypeUnsupported(String provider, String mimeType) {
    return '$provider can\'t read $mimeType files here — switch to Gemini, or paste the text instead.';
  }

  @override
  String llmRateLimited(String provider) {
    return 'Too many requests to $provider. Please wait a minute and try again.';
  }

  @override
  String llmGeminiKeyRejected(String provider) {
    return '$provider rejected your API key. Open AI setup and check the key is correct, still active, and has the Generative Language API enabled.';
  }

  @override
  String llmGeminiModelNotFound(String provider, String model) {
    return '$provider doesn\'t recognise the model \"$model\" — it may have been retired. Pick a different model in AI setup.';
  }

  @override
  String llmNetworkError(String provider, String detail) {
    return 'Couldn\'t reach $provider ($detail). Check your internet connection. If you are on the web app, this provider may also be blocked by your browser\'s CORS policy — Gemini and Claude both work in the browser.';
  }

  @override
  String llmKeyRejected(String provider) {
    return '$provider rejected your API key. Open AI setup and check the key is correct, still active, and belongs to $provider.';
  }

  @override
  String llmModelNotFound(String provider, String model) {
    return '$provider doesn\'t recognise the model \"$model\". Pick a different model in AI setup.';
  }

  @override
  String get importFileUnreadable =>
      'Could not read the file — it is corrupted or not an MHAD directive file.';

  @override
  String get importFileUnrecognized =>
      'This file is not a recognized directive file.';

  @override
  String get importFileCorrupted => 'The file is corrupted.';

  @override
  String get importNotDirectiveFile => 'This is not a directive file.';

  @override
  String get importNotMhadFile => 'This is not an MHAD directive file.';

  @override
  String get importNewerVersion =>
      'This file was made by a newer version of the app. Please update to open it.';

  @override
  String get importNoDirectiveData => 'The file contains no directive data.';

  @override
  String get breachNoticeDefaultTitle => 'Notice of a data security incident';

  @override
  String get breachNoticeWhatHappened => 'What happened';

  @override
  String get breachNoticeInformationInvolved => 'What information was involved';

  @override
  String get breachNoticeThirdParties => 'Who obtained the information';

  @override
  String get breachNoticeWhatWeAreDoing => 'What we are doing';

  @override
  String get breachNoticeWhatYouCanDo => 'What you can do';

  @override
  String get breachNoticeContactUs => 'How to contact us';

  @override
  String get breachNoticeAcknowledge => 'I have read this notice';
}
