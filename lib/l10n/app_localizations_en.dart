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
}
