// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Directiva Anticipada de\nSalud Mental de PA';

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
  String get newDirective => 'Nueva Directiva';

  @override
  String get home => 'Inicio';

  @override
  String get education => 'Educación';

  @override
  String get assistant => 'Asistente';

  @override
  String get exportDirective => 'Exportar Directiva';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get finish => 'Finalizar';

  @override
  String get done => 'Listo';

  @override
  String get delete => 'Eliminar';

  @override
  String get close => 'Cerrar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get ok => 'Aceptar';

  @override
  String get retry => 'Reintentar';

  @override
  String get required => 'Obligatorio';

  @override
  String get combinedForm => 'Declaración Combinada y Poder de Salud Mental';

  @override
  String get declarationOnly => 'Solo Declaración';

  @override
  String get poaOnly => 'Solo Poder Notarial';

  @override
  String get personalInfo => 'Información Personal';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get dateOfBirth => 'Fecha de nacimiento';

  @override
  String get address => 'Dirección';

  @override
  String get city => 'Ciudad';

  @override
  String get state => 'Estado';

  @override
  String get zipCode => 'Código postal';

  @override
  String get phone => 'Teléfono';

  @override
  String get effectiveCondition => 'Condición de Vigencia';

  @override
  String get treatmentFacility => 'Centro de Tratamiento';

  @override
  String get medications => 'Medicamentos';

  @override
  String get ectPreferences => 'Preferencias de TEC';

  @override
  String get experimentalStudies => 'Estudios Experimentales';

  @override
  String get drugTrials => 'Ensayos Clínicos';

  @override
  String get additionalInstructions => 'Instrucciones Adicionales';

  @override
  String get agentDesignation => 'Designación de Agente';

  @override
  String get alternateAgent => 'Agente Alternativo';

  @override
  String get agentAuthority => 'Autoridad y Límites del Agente';

  @override
  String get guardianNomination => 'Nominación de Tutor';

  @override
  String get review => 'Revisar';

  @override
  String get execution => 'Ejecución';

  @override
  String get draft => 'Borrador';

  @override
  String get complete => 'Completa';

  @override
  String get expired => 'Vencida';

  @override
  String get revoked => 'Revocada';

  @override
  String get saveAndExit => 'Guardar y Salir';

  @override
  String get saveAndExitMessage =>
      'Su progreso en este paso se guardará. Puede regresar para continuar más tarde (solo en Modo Privado).';

  @override
  String get previewPdf => 'Vista Previa del PDF';

  @override
  String get sharePrint => 'Compartir / Imprimir';

  @override
  String get generateWalletCard => 'Generar Tarjeta de Billetera';

  @override
  String get importFromDocument => 'Importar de Documento';

  @override
  String get importFromContacts => 'Importar de Contactos';

  @override
  String get seeExamples => 'Ver ejemplos';

  @override
  String get aiSuggest => 'Sugerencia IA';

  @override
  String stepNOfTotal(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String percentComplete(int percent) {
    return '$percent% completado';
  }

  @override
  String lastEdited(String date) {
    return 'Última edición $date';
  }

  @override
  String nSections(int filled, int total) {
    return '$filled de $total secciones';
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
}
