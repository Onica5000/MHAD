import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PA Mental Health\nAdvance Directive'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @navAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get navAsk;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @navStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get navStart;

  /// No description provided for @navAutofill.
  ///
  /// In en, this message translates to:
  /// **'Autofill'**
  String get navAutofill;

  /// No description provided for @navAiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI assistant'**
  String get navAiAssistant;

  /// No description provided for @navDownloadPrint.
  ///
  /// In en, this message translates to:
  /// **'Download & print'**
  String get navDownloadPrint;

  /// No description provided for @navResetForm.
  ///
  /// In en, this message translates to:
  /// **'Reset Form'**
  String get navResetForm;

  /// No description provided for @badgeAiReady.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get badgeAiReady;

  /// No description provided for @badgeAiSetUp.
  ///
  /// In en, this message translates to:
  /// **'SET UP'**
  String get badgeAiSetUp;

  /// No description provided for @newDirective.
  ///
  /// In en, this message translates to:
  /// **'New Directive'**
  String get newDirective;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @assistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get assistant;

  /// No description provided for @exportDirective.
  ///
  /// In en, this message translates to:
  /// **'Export Directive'**
  String get exportDirective;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @combinedForm.
  ///
  /// In en, this message translates to:
  /// **'Combined Declaration & Power of Attorney'**
  String get combinedForm;

  /// No description provided for @declarationOnly.
  ///
  /// In en, this message translates to:
  /// **'Declaration Only'**
  String get declarationOnly;

  /// No description provided for @poaOnly.
  ///
  /// In en, this message translates to:
  /// **'Power of Attorney Only'**
  String get poaOnly;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @zipCode.
  ///
  /// In en, this message translates to:
  /// **'ZIP code'**
  String get zipCode;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @effectiveCondition.
  ///
  /// In en, this message translates to:
  /// **'Effective Condition'**
  String get effectiveCondition;

  /// No description provided for @treatmentFacility.
  ///
  /// In en, this message translates to:
  /// **'Treatment Facility'**
  String get treatmentFacility;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @ectPreferences.
  ///
  /// In en, this message translates to:
  /// **'ECT Preferences'**
  String get ectPreferences;

  /// No description provided for @experimentalStudies.
  ///
  /// In en, this message translates to:
  /// **'Experimental Studies'**
  String get experimentalStudies;

  /// No description provided for @drugTrials.
  ///
  /// In en, this message translates to:
  /// **'Drug Trials'**
  String get drugTrials;

  /// No description provided for @additionalInstructions.
  ///
  /// In en, this message translates to:
  /// **'Additional Instructions'**
  String get additionalInstructions;

  /// No description provided for @agentDesignation.
  ///
  /// In en, this message translates to:
  /// **'Agent Designation'**
  String get agentDesignation;

  /// No description provided for @alternateAgent.
  ///
  /// In en, this message translates to:
  /// **'Alternate Agent'**
  String get alternateAgent;

  /// No description provided for @agentAuthority.
  ///
  /// In en, this message translates to:
  /// **'Agent Authority & Limits'**
  String get agentAuthority;

  /// No description provided for @guardianNomination.
  ///
  /// In en, this message translates to:
  /// **'Guardian Nomination'**
  String get guardianNomination;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @execution.
  ///
  /// In en, this message translates to:
  /// **'Execution'**
  String get execution;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @revoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get revoked;

  /// No description provided for @saveAndExit.
  ///
  /// In en, this message translates to:
  /// **'Save & Exit'**
  String get saveAndExit;

  /// No description provided for @saveAndExitMessage.
  ///
  /// In en, this message translates to:
  /// **'Your work isn\'t saved permanently — it stays in this browser only and is wiped when you close the tab (kept about 10 minutes for crash recovery). Export or print to keep a copy.'**
  String get saveAndExitMessage;

  /// No description provided for @previewPdf.
  ///
  /// In en, this message translates to:
  /// **'Preview PDF'**
  String get previewPdf;

  /// No description provided for @sharePrint.
  ///
  /// In en, this message translates to:
  /// **'Share / Print'**
  String get sharePrint;

  /// No description provided for @generateWalletCard.
  ///
  /// In en, this message translates to:
  /// **'Generate Wallet Card'**
  String get generateWalletCard;

  /// No description provided for @importFromDocument.
  ///
  /// In en, this message translates to:
  /// **'Import from Document'**
  String get importFromDocument;

  /// No description provided for @importFromContacts.
  ///
  /// In en, this message translates to:
  /// **'Import from Contacts'**
  String get importFromContacts;

  /// No description provided for @seeExamples.
  ///
  /// In en, this message translates to:
  /// **'See examples'**
  String get seeExamples;

  /// No description provided for @aiSuggest.
  ///
  /// In en, this message translates to:
  /// **'AI Suggest'**
  String get aiSuggest;

  /// No description provided for @stepNOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepNOfTotal(int current, int total);

  /// No description provided for @percentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String percentComplete(int percent);

  /// No description provided for @lastEdited.
  ///
  /// In en, this message translates to:
  /// **'Last edited {date}'**
  String lastEdited(String date);

  /// No description provided for @nSections.
  ///
  /// In en, this message translates to:
  /// **'{filled} of {total} sections'**
  String nSections(int filled, int total);

  /// No description provided for @procResearchEctLabel.
  ///
  /// In en, this message translates to:
  /// **'Electroconvulsive therapy (ECT)'**
  String get procResearchEctLabel;

  /// No description provided for @procResearchExperimentalLabel.
  ///
  /// In en, this message translates to:
  /// **'Experimental studies'**
  String get procResearchExperimentalLabel;

  /// No description provided for @procResearchDrugTrialsLabel.
  ///
  /// In en, this message translates to:
  /// **'Drug trials'**
  String get procResearchDrugTrialsLabel;

  /// No description provided for @procResearchWhyTheseThree.
  ///
  /// In en, this message translates to:
  /// **'Why these three? PA Act 194 specifically calls out ECT, experimental studies, and drug trials as requiring documented consent. Other treatments fall under your general preferences.'**
  String get procResearchWhyTheseThree;

  /// No description provided for @procResearchAgentAuthority.
  ///
  /// In en, this message translates to:
  /// **'Agent authority for these three: your agent cannot consent to ECT, experimental studies, or drug trials on your behalf unless you expressly grant that power below. Without an express grant, only you can consent — or these will not be available during incapacity.'**
  String get procResearchAgentAuthority;

  /// No description provided for @procResearchNeverAuthorizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Never authorized under PA Act 194'**
  String get procResearchNeverAuthorizedTitle;

  /// No description provided for @procResearchNeverAuthorizedBody.
  ///
  /// In en, this message translates to:
  /// **'By statute (20 Pa.C.S. § 5836(b)), this directive can never convey the power to consent to the following — no clause in this document and no decision by your agent can authorize them:'**
  String get procResearchNeverAuthorizedBody;

  /// No description provided for @procResearchPsychosurgery.
  ///
  /// In en, this message translates to:
  /// **'Psychosurgery (brain surgery meant to change mood or behavior)'**
  String get procResearchPsychosurgery;

  /// No description provided for @procResearchParentalRights.
  ///
  /// In en, this message translates to:
  /// **'Termination of parental rights'**
  String get procResearchParentalRights;

  /// No description provided for @signScreenPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing signing packet'**
  String get signScreenPreparing;

  /// No description provided for @signScreenBackToReview.
  ///
  /// In en, this message translates to:
  /// **'Back to review'**
  String get signScreenBackToReview;

  /// No description provided for @executionHelpText.
  ///
  /// In en, this message translates to:
  /// **'Per 20 Pa.C.S. § 5822 / § 5832, a Mental Health Advance Directive must be signed on paper by you and two adult witnesses, all present at the same time. The app cannot witness it for you — this step walks you through what to do.'**
  String get executionHelpText;

  /// No description provided for @executionFinalStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Final step · on paper'**
  String get executionFinalStepLabel;

  /// No description provided for @executionHeading.
  ///
  /// In en, this message translates to:
  /// **'Make it legal — with a pen.'**
  String get executionHeading;

  /// No description provided for @executionIntro.
  ///
  /// In en, this message translates to:
  /// **'Pennsylvania law requires a real signature on paper. We can\'t witness it for you — but here\'s exactly what to do.'**
  String get executionIntro;

  /// No description provided for @executionWhyNotAppLead.
  ///
  /// In en, this message translates to:
  /// **'Why not sign in the app? '**
  String get executionWhyNotAppLead;

  /// No description provided for @executionWhyNotAppBody.
  ///
  /// In en, this message translates to:
  /// **'Under Act 194 the directive is only valid when you and two adult witnesses sign the '**
  String get executionWhyNotAppBody;

  /// No description provided for @executionSamePaperDocument.
  ///
  /// In en, this message translates to:
  /// **'same paper document'**
  String get executionSamePaperDocument;

  /// No description provided for @executionWhyNotAppTail.
  ///
  /// In en, this message translates to:
  /// **', together. A tap-to-sign wouldn\'t hold up.'**
  String get executionWhyNotAppTail;

  /// No description provided for @executionAnyFormValid.
  ///
  /// In en, this message translates to:
  /// **'You don’t have to use a specific form. Pennsylvania’s official forms are recommended, not required — what makes your directive valid is its content and being signed and witnessed correctly. If a facility hands you a different form, this one still counts.'**
  String get executionAnyFormValid;

  /// No description provided for @executionStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Print the packet'**
  String get executionStep1Title;

  /// No description provided for @executionStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Print the PDF we just made. It already has signature lines for you and two witnesses.'**
  String get executionStep1Body;

  /// No description provided for @executionStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Gather two adult witnesses'**
  String get executionStep2Title;

  /// No description provided for @executionStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Both must be 18 or older and in the room with you when you sign. (Who can’t witness is below.)'**
  String get executionStep2Body;

  /// No description provided for @executionStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Everyone signs, same place, same time'**
  String get executionStep3Title;

  /// No description provided for @executionStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Sign and date the witness page in front of both witnesses. They sign right after you, while you watch.'**
  String get executionStep3Body;

  /// No description provided for @executionWitnessLead.
  ///
  /// In en, this message translates to:
  /// **'A witness '**
  String get executionWitnessLead;

  /// No description provided for @executionWitnessCannot.
  ///
  /// In en, this message translates to:
  /// **'cannot'**
  String get executionWitnessCannot;

  /// No description provided for @executionWitnessRest.
  ///
  /// In en, this message translates to:
  /// **' be your agent or alternate agent, your mental health care provider, or an employee of the facility where you receive treatment — unless they are related to you by blood, marriage, or adoption.'**
  String get executionWitnessRest;

  /// No description provided for @executionInYourPacket.
  ///
  /// In en, this message translates to:
  /// **'In your packet'**
  String get executionInYourPacket;

  /// No description provided for @executionPacketMhadTitle.
  ///
  /// In en, this message translates to:
  /// **'Your completed MHAD'**
  String get executionPacketMhadTitle;

  /// No description provided for @executionPacketMhadSub.
  ///
  /// In en, this message translates to:
  /// **'PDF · PA Act 194 format'**
  String get executionPacketMhadSub;

  /// No description provided for @executionPacketSignatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Signature & witness page'**
  String get executionPacketSignatureTitle;

  /// No description provided for @executionPacketSignatureSub.
  ///
  /// In en, this message translates to:
  /// **'Pre-filled with your name and the date lines'**
  String get executionPacketSignatureSub;

  /// No description provided for @executionPacketWitnessTitle.
  ///
  /// In en, this message translates to:
  /// **'Witness eligibility guide'**
  String get executionPacketWitnessTitle;

  /// No description provided for @executionPacketWitnessSub.
  ///
  /// In en, this message translates to:
  /// **'One page — who can and can\'t sign'**
  String get executionPacketWitnessSub;

  /// No description provided for @executionPacketAfterTitle.
  ///
  /// In en, this message translates to:
  /// **'What to do after signing'**
  String get executionPacketAfterTitle;

  /// No description provided for @executionPacketAfterSub.
  ///
  /// In en, this message translates to:
  /// **'Who to give copies to, how to distribute'**
  String get executionPacketAfterSub;

  /// No description provided for @executionPreviewPacket.
  ///
  /// In en, this message translates to:
  /// **'Preview & open packet'**
  String get executionPreviewPacket;

  /// No description provided for @executionNotYetValid.
  ///
  /// In en, this message translates to:
  /// **'NOT YET VALID · BECOMES LEGAL ONCE SIGNED ON PAPER BY YOU + 2 WITNESSES'**
  String get executionNotYetValid;

  /// No description provided for @reviewStepNotProvidedYet.
  ///
  /// In en, this message translates to:
  /// **'Not provided yet'**
  String get reviewStepNotProvidedYet;

  /// No description provided for @reviewStepNoInfoEntered.
  ///
  /// In en, this message translates to:
  /// **'No information entered'**
  String get reviewStepNoInfoEntered;

  /// No description provided for @reviewStepA11yNoInfo.
  ///
  /// In en, this message translates to:
  /// **'{label}. No information entered.'**
  String reviewStepA11yNoInfo(String label);

  /// No description provided for @reviewStepPrimaryAgent.
  ///
  /// In en, this message translates to:
  /// **'Primary Agent'**
  String get reviewStepPrimaryAgent;

  /// No description provided for @reviewStepWhereIWantCare.
  ///
  /// In en, this message translates to:
  /// **'Where I want care'**
  String get reviewStepWhereIWantCare;

  /// No description provided for @reviewStepMedicalDiagnoses.
  ///
  /// In en, this message translates to:
  /// **'Medical Diagnoses'**
  String get reviewStepMedicalDiagnoses;

  /// No description provided for @reviewStepAllergiesReactions.
  ///
  /// In en, this message translates to:
  /// **'Allergies & reactions'**
  String get reviewStepAllergiesReactions;

  /// No description provided for @reviewStepProceduresResearch.
  ///
  /// In en, this message translates to:
  /// **'Procedures & research'**
  String get reviewStepProceduresResearch;

  /// No description provided for @reviewStepName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get reviewStepName;

  /// No description provided for @reviewStepPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get reviewStepPhone;

  /// No description provided for @reviewStepCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get reviewStepCondition;

  /// No description provided for @reviewStepRelationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get reviewStepRelationship;

  /// No description provided for @reviewStepTreatmentFacility.
  ///
  /// In en, this message translates to:
  /// **'Treatment facility'**
  String get reviewStepTreatmentFacility;

  /// No description provided for @reviewStepMedicationConsent.
  ///
  /// In en, this message translates to:
  /// **'Medication consent'**
  String get reviewStepMedicationConsent;

  /// No description provided for @reviewStepAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get reviewStepAllergies;

  /// No description provided for @reviewStepNeverGive.
  ///
  /// In en, this message translates to:
  /// **'Never give'**
  String get reviewStepNeverGive;

  /// No description provided for @reviewStepWithLimits.
  ///
  /// In en, this message translates to:
  /// **'With limits'**
  String get reviewStepWithLimits;

  /// No description provided for @reviewStepPreferred.
  ///
  /// In en, this message translates to:
  /// **'Preferred'**
  String get reviewStepPreferred;

  /// No description provided for @reviewStepEctConsent.
  ///
  /// In en, this message translates to:
  /// **'ECT consent'**
  String get reviewStepEctConsent;

  /// No description provided for @reviewStepDrugTrials.
  ///
  /// In en, this message translates to:
  /// **'Drug trials'**
  String get reviewStepDrugTrials;

  /// No description provided for @reviewStepActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get reviewStepActivities;

  /// No description provided for @reviewStepCrisisIntervention.
  ///
  /// In en, this message translates to:
  /// **'Crisis intervention'**
  String get reviewStepCrisisIntervention;

  /// No description provided for @reviewStepHealthHistory.
  ///
  /// In en, this message translates to:
  /// **'Health history'**
  String get reviewStepHealthHistory;

  /// No description provided for @reviewStepDietary.
  ///
  /// In en, this message translates to:
  /// **'Dietary'**
  String get reviewStepDietary;

  /// No description provided for @reviewStepReligious.
  ///
  /// In en, this message translates to:
  /// **'Religious'**
  String get reviewStepReligious;

  /// No description provided for @reviewStepChildren.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get reviewStepChildren;

  /// No description provided for @reviewStepFamilyNotification.
  ///
  /// In en, this message translates to:
  /// **'Family notification'**
  String get reviewStepFamilyNotification;

  /// No description provided for @reviewStepRecordsDisclosure.
  ///
  /// In en, this message translates to:
  /// **'Records disclosure'**
  String get reviewStepRecordsDisclosure;

  /// No description provided for @reviewStepPetCare.
  ///
  /// In en, this message translates to:
  /// **'Pet care'**
  String get reviewStepPetCare;

  /// No description provided for @reviewStepOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reviewStepOther;

  /// No description provided for @reviewStepWhoPhone.
  ///
  /// In en, this message translates to:
  /// **'{who}\'s phone number'**
  String reviewStepWhoPhone(String who);

  /// No description provided for @reviewStepWhoAddress.
  ///
  /// In en, this message translates to:
  /// **'{who}\'s address'**
  String reviewStepWhoAddress(String who);

  /// No description provided for @reviewStepYourPrimaryAgent.
  ///
  /// In en, this message translates to:
  /// **'your primary agent'**
  String get reviewStepYourPrimaryAgent;

  /// No description provided for @reviewStepYourAlternateAgent.
  ///
  /// In en, this message translates to:
  /// **'your alternate agent'**
  String get reviewStepYourAlternateAgent;

  /// No description provided for @reviewStepYourGuardianNominee.
  ///
  /// In en, this message translates to:
  /// **'your guardian nominee'**
  String get reviewStepYourGuardianNominee;

  /// No description provided for @reviewStepLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get reviewStepLoading;

  /// No description provided for @reviewStepOneLastLook.
  ///
  /// In en, this message translates to:
  /// **'One last look, then we\'ll make your signing packet.'**
  String get reviewStepOneLastLook;

  /// No description provided for @reviewStepOneSectionNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'1 section still needs your attention before signing.'**
  String get reviewStepOneSectionNeedsAttention;

  /// No description provided for @reviewStepSectionsNeedAttention.
  ///
  /// In en, this message translates to:
  /// **'{count} sections still need your attention before signing.'**
  String reviewStepSectionsNeedAttention(int count);

  /// No description provided for @reviewStepAllGood.
  ///
  /// In en, this message translates to:
  /// **'Everything looks good. All sections reviewed.'**
  String get reviewStepAllGood;

  /// No description provided for @reviewStepOptionalGather.
  ///
  /// In en, this message translates to:
  /// **'Optional, but worth gathering before you sign: {items}. They help your care team reach the people you named — you can still sign without them.'**
  String reviewStepOptionalGather(String items);

  /// No description provided for @reviewStepAtAGlance.
  ///
  /// In en, this message translates to:
  /// **'Your directive at a glance'**
  String get reviewStepAtAGlance;

  /// No description provided for @reviewStepOptionalCheck.
  ///
  /// In en, this message translates to:
  /// **'Optional check'**
  String get reviewStepOptionalCheck;

  /// No description provided for @reviewStepRunConsistencyCheck.
  ///
  /// In en, this message translates to:
  /// **'Run a consistency check'**
  String get reviewStepRunConsistencyCheck;

  /// No description provided for @reviewStepConsistencyCheckHelp.
  ///
  /// In en, this message translates to:
  /// **'Scans your answers for cross-step contradictions (e.g. an agent-consent that conflicts with an avoid list), and — if the AI is set up — adds an optional AI review of gaps to double-check. Optional; you can sign without it.'**
  String get reviewStepConsistencyCheckHelp;

  /// No description provided for @reviewStepReadyToSign.
  ///
  /// In en, this message translates to:
  /// **'Ready to sign?'**
  String get reviewStepReadyToSign;

  /// No description provided for @reviewStepReadyToSignBody.
  ///
  /// In en, this message translates to:
  /// **'Review all sections above. When satisfied, tap Preview to continue to signing and dating the directive.'**
  String get reviewStepReadyToSignBody;

  /// No description provided for @reviewStepProvidersMustComply.
  ///
  /// In en, this message translates to:
  /// **'Providers must comply '**
  String get reviewStepProvidersMustComply;

  /// No description provided for @reviewStepProvidersMustComplyBody.
  ///
  /// In en, this message translates to:
  /// **'with your directive under PA Act 194 (20 Pa.C.S. §§ 5804, 5842). A provider may decline specific instructions only if they conflict with accepted medical practice, or when the provider is not physically available.'**
  String get reviewStepProvidersMustComplyBody;

  /// No description provided for @reviewStepExperimentalStudies.
  ///
  /// In en, this message translates to:
  /// **'Experimental studies'**
  String get reviewStepExperimentalStudies;

  /// No description provided for @wizardProgressSaved.
  ///
  /// In en, this message translates to:
  /// **'Progress saved'**
  String get wizardProgressSaved;

  /// No description provided for @wizardLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get wizardLoading;

  /// No description provided for @wizardError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get wizardError;

  /// No description provided for @wizardUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this directive.'**
  String get wizardUnableToLoad;

  /// No description provided for @wizardBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get wizardBackToHome;

  /// No description provided for @wizardNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get wizardNotFound;

  /// No description provided for @wizardDirectiveNotFound.
  ///
  /// In en, this message translates to:
  /// **'Directive not found.'**
  String get wizardDirectiveNotFound;

  /// No description provided for @wizardPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get wizardPreview;

  /// No description provided for @wizardContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get wizardContinue;

  /// No description provided for @wizardSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get wizardSaved;

  /// No description provided for @wizardIncompletePrivate.
  ///
  /// In en, this message translates to:
  /// **'Some fields are incomplete — you can come back to finish later.'**
  String get wizardIncompletePrivate;

  /// No description provided for @wizardIncompletePublic.
  ///
  /// In en, this message translates to:
  /// **'Some fields are incomplete — you can fill them in before you finish.'**
  String get wizardIncompletePublic;

  /// No description provided for @wizardExitWithoutSaving.
  ///
  /// In en, this message translates to:
  /// **'Exit Without Saving?'**
  String get wizardExitWithoutSaving;

  /// No description provided for @wizardExitWebBody.
  ///
  /// In en, this message translates to:
  /// **'The web app does not save your progress permanently.\n\nIf you leave, close the tab, or the app crashes, your work is kept on this device for 10 minutes so you can reopen and recover it — then it’s erased. Export or print your document to keep a copy.'**
  String get wizardExitWebBody;

  /// No description provided for @wizardExitPublicBody.
  ///
  /// In en, this message translates to:
  /// **'You are in Public Mode — your data is stored in memory only and will be lost when the app closes.\n\nExport or print your document before leaving. To save across sessions, use Private Mode instead.'**
  String get wizardExitPublicBody;

  /// No description provided for @wizardStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get wizardStay;

  /// No description provided for @wizardExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get wizardExit;

  /// No description provided for @wizardSaveExitBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress on this step will be saved. You can return to continue later.'**
  String get wizardSaveExitBody;

  /// No description provided for @wizardYourDirective.
  ///
  /// In en, this message translates to:
  /// **'YOUR DIRECTIVE'**
  String get wizardYourDirective;

  /// No description provided for @personalInfoStepReuseDetails.
  ///
  /// In en, this message translates to:
  /// **'Reuse your details from {name}?'**
  String personalInfoStepReuseDetails(String name);

  /// No description provided for @personalInfoStepCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get personalInfoStepCopy;

  /// No description provided for @personalInfoStepZipFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter a 5-digit ZIP first.'**
  String get personalInfoStepZipFirst;

  /// No description provided for @personalInfoStepZipLookupFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t look up that ZIP — you can type it in.'**
  String get personalInfoStepZipLookupFailed;

  /// No description provided for @personalInfoStepCountyName.
  ///
  /// In en, this message translates to:
  /// **'{county} County'**
  String personalInfoStepCountyName(String county);

  /// No description provided for @personalInfoStepFilled.
  ///
  /// In en, this message translates to:
  /// **'Filled: {filled}'**
  String personalInfoStepFilled(String filled);

  /// No description provided for @personalInfoStepDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Use MM/DD/YYYY format'**
  String get personalInfoStepDateFormat;

  /// No description provided for @personalInfoStepInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid date'**
  String get personalInfoStepInvalidDate;

  /// No description provided for @personalInfoStepDobFuture.
  ///
  /// In en, this message translates to:
  /// **'Date of birth can\'t be in the future'**
  String get personalInfoStepDobFuture;

  /// No description provided for @personalInfoStepMustBeAdult.
  ///
  /// In en, this message translates to:
  /// **'Must be 18 or older (or an emancipated minor) to create a directive'**
  String get personalInfoStepMustBeAdult;

  /// No description provided for @personalInfoStepSelectDob.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get personalInfoStepSelectDob;

  /// No description provided for @personalInfoStepHelp.
  ///
  /// In en, this message translates to:
  /// **'Provide your legal name as it appears on official documents. You must be 18 years of age or older, or an emancipated minor, to create a Mental Health Advance Directive under PA Act 194 of 2004.'**
  String get personalInfoStepHelp;

  /// No description provided for @personalInfoStepFullLegalName.
  ///
  /// In en, this message translates to:
  /// **'Full legal name *'**
  String get personalInfoStepFullLegalName;

  /// No description provided for @personalInfoStepFullLegalNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Use your full legal name as it appears on official ID'**
  String get personalInfoStepFullLegalNameHelper;

  /// No description provided for @personalInfoStepDobLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth (MM/DD/YYYY) *'**
  String get personalInfoStepDobLabel;

  /// No description provided for @personalInfoStepDobHelper.
  ///
  /// In en, this message translates to:
  /// **'Used to verify your identity on the directive'**
  String get personalInfoStepDobHelper;

  /// No description provided for @personalInfoStepPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get personalInfoStepPickDate;

  /// No description provided for @personalInfoStepStreetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street address'**
  String get personalInfoStepStreetAddress;

  /// No description provided for @personalInfoStepStreetAddressHelper.
  ///
  /// In en, this message translates to:
  /// **'Your current residential address'**
  String get personalInfoStepStreetAddressHelper;

  /// No description provided for @personalInfoStepAddress2.
  ///
  /// In en, this message translates to:
  /// **'Apt, suite, unit, etc.'**
  String get personalInfoStepAddress2;

  /// No description provided for @personalInfoStepCounty.
  ///
  /// In en, this message translates to:
  /// **'County'**
  String get personalInfoStepCounty;

  /// No description provided for @personalInfoStepZip.
  ///
  /// In en, this message translates to:
  /// **'ZIP'**
  String get personalInfoStepZip;

  /// No description provided for @personalInfoStepZipHint.
  ///
  /// In en, this message translates to:
  /// **'12345 or 12345-6789'**
  String get personalInfoStepZipHint;

  /// No description provided for @personalInfoStepZipHelper.
  ///
  /// In en, this message translates to:
  /// **'Tap the icon to fill city, county & state'**
  String get personalInfoStepZipHelper;

  /// No description provided for @personalInfoStepZipTooltip.
  ///
  /// In en, this message translates to:
  /// **'Fill city, county & state from ZIP'**
  String get personalInfoStepZipTooltip;

  /// No description provided for @personalInfoStepZipInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter 5-digit or 5+4-digit ZIP'**
  String get personalInfoStepZipInvalid;

  /// No description provided for @personalInfoStepPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit phone number'**
  String get personalInfoStepPhoneInvalid;

  /// No description provided for @peopleTrustPrimaryAgent.
  ///
  /// In en, this message translates to:
  /// **'PRIMARY AGENT'**
  String get peopleTrustPrimaryAgent;

  /// No description provided for @peopleTrustAlternateAgent.
  ///
  /// In en, this message translates to:
  /// **'ALTERNATE AGENT'**
  String get peopleTrustAlternateAgent;

  /// No description provided for @peopleTrustWhatCanTheyDecide.
  ///
  /// In en, this message translates to:
  /// **'What can they decide?'**
  String get peopleTrustWhatCanTheyDecide;

  /// No description provided for @peopleTrustAuthorityIntro.
  ///
  /// In en, this message translates to:
  /// **'Limit or expand your agent’s authority. Default is broad authority.'**
  String get peopleTrustAuthorityIntro;

  /// No description provided for @peopleTrustLegendAgentDecides.
  ///
  /// In en, this message translates to:
  /// **'\"Agent decides\"'**
  String get peopleTrustLegendAgentDecides;

  /// No description provided for @peopleTrustLegendGrants.
  ///
  /// In en, this message translates to:
  /// **' grants the power; '**
  String get peopleTrustLegendGrants;

  /// No description provided for @peopleTrustLegendNo.
  ///
  /// In en, this message translates to:
  /// **'\"No\"'**
  String get peopleTrustLegendNo;

  /// No description provided for @peopleTrustLegendWithholds.
  ///
  /// In en, this message translates to:
  /// **' withholds it entirely; '**
  String get peopleTrustLegendWithholds;

  /// No description provided for @peopleTrustLegendIf.
  ///
  /// In en, this message translates to:
  /// **'\"If…\"'**
  String get peopleTrustLegendIf;

  /// No description provided for @peopleTrustLegendCondition.
  ///
  /// In en, this message translates to:
  /// **' lets you add a condition in your own words.'**
  String get peopleTrustLegendCondition;

  /// No description provided for @peopleTrustPrimaryBadge.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get peopleTrustPrimaryBadge;

  /// No description provided for @peopleTrustAddSomeone.
  ///
  /// In en, this message translates to:
  /// **'Add someone'**
  String get peopleTrustAddSomeone;

  /// No description provided for @peopleTrustOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get peopleTrustOptional;

  /// No description provided for @peopleTrustContactPicker.
  ///
  /// In en, this message translates to:
  /// **'Contact picker'**
  String get peopleTrustContactPicker;

  /// No description provided for @peopleTrustPhoneOnFile.
  ///
  /// In en, this message translates to:
  /// **'Phone on file'**
  String get peopleTrustPhoneOnFile;

  /// No description provided for @agentDesigHelp.
  ///
  /// In en, this message translates to:
  /// **'Your agent must be 18 or older. Under PA Act 194, they cannot be your mental health care provider or an employee of a mental health care facility or residential facility where you receive care — unless they are related to you. Choose someone you trust to honor your wishes.'**
  String get agentDesigHelp;

  /// No description provided for @agentDesigTitle.
  ///
  /// In en, this message translates to:
  /// **'Primary Agent Designation'**
  String get agentDesigTitle;

  /// No description provided for @agentDesigAgentDefinition.
  ///
  /// In en, this message translates to:
  /// **'An agent (healthcare proxy) is someone you choose to make mental health care decisions on your behalf when you cannot.'**
  String get agentDesigAgentDefinition;

  /// No description provided for @agentDesigRelationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get agentDesigRelationship;

  /// No description provided for @agentDesigSpouseNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Under PA Act 194 §5838, if you designate your spouse as your agent, that designation is automatically revoked if either spouse files for divorce, unless you state otherwise in this directive.'**
  String get agentDesigSpouseNote;

  /// No description provided for @altAgentHelp.
  ///
  /// In en, this message translates to:
  /// **'Your agent must be 18 or older. They cannot be your treating physician, an employee of your treatment facility (unless a relative), or someone with financial interest in your estate. Choose someone you trust to honor your wishes.'**
  String get altAgentHelp;

  /// No description provided for @altAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Alternate Agent Designation'**
  String get altAgentTitle;

  /// No description provided for @altAgentActsIf.
  ///
  /// In en, this message translates to:
  /// **'Your alternate agent acts if your primary agent is unable or unwilling to serve.'**
  String get altAgentActsIf;

  /// No description provided for @altAgentSameAuthority.
  ///
  /// In en, this message translates to:
  /// **'The alternate agent has the same authority as the primary agent but only steps in when the primary agent cannot act.'**
  String get altAgentSameAuthority;

  /// No description provided for @altAgentNotRequired.
  ///
  /// In en, this message translates to:
  /// **'You are not required to designate an alternate agent.'**
  String get altAgentNotRequired;

  /// No description provided for @altAgentRelationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get altAgentRelationship;

  /// No description provided for @agentAuthHelp.
  ///
  /// In en, this message translates to:
  /// **'Consider carefully before restricting your agent\'s authority. Broad authority gives your agent flexibility to respond to situations you may not anticipate.'**
  String get agentAuthHelp;

  /// No description provided for @agentAuthIntro.
  ///
  /// In en, this message translates to:
  /// **'By default your agent has broad authority to make mental health treatment decisions. You may restrict this authority here.'**
  String get agentAuthIntro;

  /// No description provided for @agentAuthScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Important: Scope of Authority (20 Pa.C.S. § 5836)'**
  String get agentAuthScopeTitle;

  /// No description provided for @agentAuthScopeBody.
  ///
  /// In en, this message translates to:
  /// **'The checkboxes below apply ONLY to:\n  • Voluntary hospitalization (admission to a treatment facility)\n  • General psychiatric medications\n\nThey do NOT cover:\n  • Electroconvulsive therapy (ECT)\n  • Experimental studies or procedures\n  • Clinical drug trials\n\nYour consent choices for ECT, experimental studies, and drug trials are set on their dedicated pages earlier in this form. Under PA Act 194, your agent CANNOT override those decisions — they are binding regardless of agent authority.'**
  String get agentAuthScopeBody;

  /// No description provided for @agentAuthStandardLead.
  ///
  /// In en, this message translates to:
  /// **'The standard your agent must follow: '**
  String get agentAuthStandardLead;

  /// No description provided for @agentAuthStandardBody.
  ///
  /// In en, this message translates to:
  /// **'under § 5836(d), your agent is legally bound to make the decision you would make if you were competent, guided by what you write in this directive and any clear prior instructions, after consulting with providers. The more you fill in, the closer their decisions can match yours.'**
  String get agentAuthStandardBody;

  /// No description provided for @agentAuthHospitalization.
  ///
  /// In en, this message translates to:
  /// **'Agent may consent to voluntary hospitalization'**
  String get agentAuthHospitalization;

  /// No description provided for @agentAuthHospitalizationSub.
  ///
  /// In en, this message translates to:
  /// **'Admission to a psychiatric treatment facility only'**
  String get agentAuthHospitalizationSub;

  /// No description provided for @agentAuthMedication.
  ///
  /// In en, this message translates to:
  /// **'Agent may consent to medication'**
  String get agentAuthMedication;

  /// No description provided for @agentAuthMedicationSub.
  ///
  /// In en, this message translates to:
  /// **'General psychiatric medications only — does not include ECT'**
  String get agentAuthMedicationSub;

  /// No description provided for @agentAuthExamplesField.
  ///
  /// In en, this message translates to:
  /// **'Agent Limitations'**
  String get agentAuthExamplesField;

  /// No description provided for @agentAuthExample1.
  ///
  /// In en, this message translates to:
  /// **'My agent may not consent to electroconvulsive therapy (ECT) under any circumstances.'**
  String get agentAuthExample1;

  /// No description provided for @agentAuthExample2.
  ///
  /// In en, this message translates to:
  /// **'My agent should consult with my therapist, Dr. Smith, before agreeing to any changes in my medication regimen.'**
  String get agentAuthExample2;

  /// No description provided for @agentAuthExample3.
  ///
  /// In en, this message translates to:
  /// **'My agent may consent to voluntary inpatient admission for up to 72 hours, but may not consent to longer stays without consulting my family.'**
  String get agentAuthExample3;

  /// No description provided for @agentAuthLimitationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional limitations or instructions (optional)'**
  String get agentAuthLimitationsLabel;

  /// No description provided for @guardianNomNoPreference.
  ///
  /// In en, this message translates to:
  /// **'No preference'**
  String get guardianNomNoPreference;

  /// No description provided for @guardianNomNoPreferenceHint.
  ///
  /// In en, this message translates to:
  /// **'Let the court decide. They will usually appoint a family member or county guardianship office.'**
  String get guardianNomNoPreferenceHint;

  /// No description provided for @guardianNomSameAsPrimary.
  ///
  /// In en, this message translates to:
  /// **'Same as my primary agent'**
  String get guardianNomSameAsPrimary;

  /// No description provided for @guardianNomSameAsPrimaryHint.
  ///
  /// In en, this message translates to:
  /// **'The simplest path. The court is not required to follow this, but it is strong guidance.'**
  String get guardianNomSameAsPrimaryHint;

  /// No description provided for @guardianNomSameAsAlternate.
  ///
  /// In en, this message translates to:
  /// **'Same as my alternate agent'**
  String get guardianNomSameAsAlternate;

  /// No description provided for @guardianNomSameAsAlternateHint.
  ///
  /// In en, this message translates to:
  /// **'Use this if your alternate would be a better fit for a longer-term guardianship role.'**
  String get guardianNomSameAsAlternateHint;

  /// No description provided for @guardianNomDifferent.
  ///
  /// In en, this message translates to:
  /// **'Someone different'**
  String get guardianNomDifferent;

  /// No description provided for @guardianNomDifferentHint.
  ///
  /// In en, this message translates to:
  /// **'Choose another person — e.g. an attorney, sibling, or close friend not already named.'**
  String get guardianNomDifferentHint;

  /// No description provided for @guardianNomHelp.
  ///
  /// In en, this message translates to:
  /// **'Your nomination is not binding — the court will consider it but makes the final decision on who to appoint.'**
  String get guardianNomHelp;

  /// No description provided for @guardianNomOptionalIntro.
  ///
  /// In en, this message translates to:
  /// **'This section is optional. You may nominate a guardian in case a court ever needs to appoint one for you.'**
  String get guardianNomOptionalIntro;

  /// No description provided for @guardianNomGuardianVsAgent.
  ///
  /// In en, this message translates to:
  /// **'A guardian is different from your agent. A guardian is appointed by a court during formal incapacity proceedings. This nomination tells the court who you prefer.'**
  String get guardianNomGuardianVsAgent;

  /// No description provided for @guardianNomPreferredGuardian.
  ///
  /// In en, this message translates to:
  /// **'Preferred guardian'**
  String get guardianNomPreferredGuardian;

  /// No description provided for @guardianNomPickWhatFits.
  ///
  /// In en, this message translates to:
  /// **'Pick what fits — your nomination is guidance for the court, not a binding instruction.'**
  String get guardianNomPickWhatFits;

  /// No description provided for @guardianNomNomineeFullName.
  ///
  /// In en, this message translates to:
  /// **'Nominee full name'**
  String get guardianNomNomineeFullName;

  /// No description provided for @guardianNomRelationshipToYou.
  ///
  /// In en, this message translates to:
  /// **'Relationship to you'**
  String get guardianNomRelationshipToYou;

  /// No description provided for @guardianNomConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Conditions on the guardianship'**
  String get guardianNomConditionsTitle;

  /// No description provided for @guardianNomConditionsIntro.
  ///
  /// In en, this message translates to:
  /// **'If a court appoints a guardian, set the limits you want it to honor. These are guidance for the court, not binding.'**
  String get guardianNomConditionsIntro;

  /// No description provided for @guardianNomCanChangeAgent.
  ///
  /// In en, this message translates to:
  /// **'Can change my agent'**
  String get guardianNomCanChangeAgent;

  /// No description provided for @guardianNomCanChangeAgentHint.
  ///
  /// In en, this message translates to:
  /// **'When or how may the guardian change my agent? (optional)'**
  String get guardianNomCanChangeAgentHint;

  /// No description provided for @guardianNomCanOverride.
  ///
  /// In en, this message translates to:
  /// **'Can override this directive'**
  String get guardianNomCanOverride;

  /// No description provided for @guardianNomCanOverrideSub.
  ///
  /// In en, this message translates to:
  /// **'Revoke, suspend, or terminate it.'**
  String get guardianNomCanOverrideSub;

  /// No description provided for @guardianNomCanOverrideHint.
  ///
  /// In en, this message translates to:
  /// **'Any limits on overriding this directive? (optional)'**
  String get guardianNomCanOverrideHint;

  /// No description provided for @guardianNomMustConsult.
  ///
  /// In en, this message translates to:
  /// **'Must consult my agent first'**
  String get guardianNomMustConsult;

  /// No description provided for @guardianNomMustConsultHint.
  ///
  /// In en, this message translates to:
  /// **'What should the guardian consult my agent about? (optional)'**
  String get guardianNomMustConsultHint;

  /// No description provided for @diagnosesAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} is already added'**
  String diagnosesAlreadyAdded(String name);

  /// No description provided for @diagnosesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a condition (e.g. depression, ADHD)…'**
  String get diagnosesSearchHint;

  /// No description provided for @diagnosesClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get diagnosesClearSearch;

  /// No description provided for @diagnosesHelpText.
  ///
  /// In en, this message translates to:
  /// **'Search for your psychiatric and medical diagnoses using ICD-10 codes. These are the official medical classification codes used by healthcare providers. Adding your diagnoses helps your care team and agent understand your conditions.\n\nPsychiatric diagnoses (F-codes) and medical diagnoses are shown in separate sections.\n\nThis lookup is free and uses the NIH Clinical Tables Service — no AI tokens are used.'**
  String get diagnosesHelpText;

  /// No description provided for @diagnosesPsychiatric.
  ///
  /// In en, this message translates to:
  /// **'Psychiatric'**
  String get diagnosesPsychiatric;

  /// No description provided for @diagnosesMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get diagnosesMedical;

  /// No description provided for @diagnosesNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get diagnosesNoResults;

  /// No description provided for @diagnosesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No diagnoses added yet'**
  String get diagnosesEmptyTitle;

  /// No description provided for @diagnosesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Use the search above to find and add your diagnoses.'**
  String get diagnosesEmptyBody;

  /// No description provided for @diagnosesAddedOne.
  ///
  /// In en, this message translates to:
  /// **'Added · {count} condition'**
  String diagnosesAddedOne(int count);

  /// No description provided for @diagnosesAddedMany.
  ///
  /// In en, this message translates to:
  /// **'Added · {count} conditions'**
  String diagnosesAddedMany(int count);

  /// No description provided for @diagnosesPsychiatricCount.
  ///
  /// In en, this message translates to:
  /// **'Psychiatric ({count})'**
  String diagnosesPsychiatricCount(int count);

  /// No description provided for @diagnosesMedicalCount.
  ///
  /// In en, this message translates to:
  /// **'Medical ({count})'**
  String diagnosesMedicalCount(int count);

  /// No description provided for @diagnosesDoctorSection.
  ///
  /// In en, this message translates to:
  /// **'Primary care doctor · optional'**
  String get diagnosesDoctorSection;

  /// No description provided for @diagnosesDoctorName.
  ///
  /// In en, this message translates to:
  /// **'Doctor name'**
  String get diagnosesDoctorName;

  /// No description provided for @diagnosesDoctorNameHint.
  ///
  /// In en, this message translates to:
  /// **'Type a name to search the provider registry'**
  String get diagnosesDoctorNameHint;

  /// No description provided for @diagnosesNpiNote.
  ///
  /// In en, this message translates to:
  /// **'Provider names from the NPI registry (NIH Clinical Tables). Verify details before relying on them.'**
  String get diagnosesNpiNote;

  /// No description provided for @diagnosesSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get diagnosesSpecialty;

  /// No description provided for @diagnosesPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get diagnosesPhone;

  /// No description provided for @diagnosesDescribeSemantics.
  ///
  /// In en, this message translates to:
  /// **'Describe a condition to find its official name'**
  String get diagnosesDescribeSemantics;

  /// No description provided for @diagnosesDescribeLead.
  ///
  /// In en, this message translates to:
  /// **'Don\'t know the official name? '**
  String get diagnosesDescribeLead;

  /// No description provided for @diagnosesDescribeBold.
  ///
  /// In en, this message translates to:
  /// **'Describe how it shows up for you'**
  String get diagnosesDescribeBold;

  /// No description provided for @diagnosesDescribeTail.
  ///
  /// In en, this message translates to:
  /// **' and I\'ll suggest the closest ICD-10 code for you to confirm.'**
  String get diagnosesDescribeTail;

  /// No description provided for @diagnosesTry.
  ///
  /// In en, this message translates to:
  /// **'Try →'**
  String get diagnosesTry;

  /// No description provided for @diagnosesFooter.
  ///
  /// In en, this message translates to:
  /// **'You\'re not required to list anything. Anything you do list is shared only with the people your directive names.'**
  String get diagnosesFooter;

  /// No description provided for @diagnosesAddedName.
  ///
  /// In en, this message translates to:
  /// **'Added “{name}”'**
  String diagnosesAddedName(String name);

  /// No description provided for @diagnosesAlreadyAddedQuoted.
  ///
  /// In en, this message translates to:
  /// **'“{name}” is already added'**
  String diagnosesAlreadyAddedQuoted(String name);

  /// No description provided for @diagnosesDescribeTitle.
  ///
  /// In en, this message translates to:
  /// **'Describe what you experience'**
  String get diagnosesDescribeTitle;

  /// No description provided for @diagnosesDescribeIntro.
  ///
  /// In en, this message translates to:
  /// **'In your own words — symptoms, how it affects you, when it happens. We\'ll suggest possible conditions and confirm each against the ICD-10 registry. These are suggestions to review, not a diagnosis.'**
  String get diagnosesDescribeIntro;

  /// No description provided for @diagnosesDescribeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. long stretches where I feel hopeless and can\'t get out of bed'**
  String get diagnosesDescribeHint;

  /// No description provided for @diagnosesFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding…'**
  String get diagnosesFinding;

  /// No description provided for @diagnosesFindMatches.
  ///
  /// In en, this message translates to:
  /// **'Find matches'**
  String get diagnosesFindMatches;

  /// No description provided for @diagnosesNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No close matches. Try adding more detail, or use the search box on the page if you know part of the name.'**
  String get diagnosesNoMatches;

  /// No description provided for @diagnosesSuggestionsNote.
  ///
  /// In en, this message translates to:
  /// **'Suggestions only — confirm with your records or your doctor. Codes from NIH Clinical Tables (ICD-10-CM).'**
  String get diagnosesSuggestionsNote;

  /// No description provided for @diagnosesDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get diagnosesDone;

  /// No description provided for @allergiesKindDrug.
  ///
  /// In en, this message translates to:
  /// **'Drug'**
  String get allergiesKindDrug;

  /// No description provided for @allergiesKindFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get allergiesKindFood;

  /// No description provided for @allergiesKindMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get allergiesKindMaterial;

  /// No description provided for @allergiesKindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get allergiesKindOther;

  /// No description provided for @allergiesSearchDrugHint.
  ///
  /// In en, this message translates to:
  /// **'Search a drug or class…'**
  String get allergiesSearchDrugHint;

  /// No description provided for @allergiesSearchFoodHint.
  ///
  /// In en, this message translates to:
  /// **'Search food allergens…'**
  String get allergiesSearchFoodHint;

  /// No description provided for @allergiesSearchMaterialHint.
  ///
  /// In en, this message translates to:
  /// **'Search material allergens…'**
  String get allergiesSearchMaterialHint;

  /// No description provided for @allergiesSearchOtherHint.
  ///
  /// In en, this message translates to:
  /// **'Search other allergens…'**
  String get allergiesSearchOtherHint;

  /// No description provided for @allergiesAddedToNeverWant.
  ///
  /// In en, this message translates to:
  /// **'Added {name} to “Medications I never want”.'**
  String allergiesAddedToNeverWant(String name);

  /// No description provided for @allergiesCodeSevere.
  ///
  /// In en, this message translates to:
  /// **'SEVERE'**
  String get allergiesCodeSevere;

  /// No description provided for @allergiesCodeModerate.
  ///
  /// In en, this message translates to:
  /// **'MOD'**
  String get allergiesCodeModerate;

  /// No description provided for @allergiesCodeMild.
  ///
  /// In en, this message translates to:
  /// **'MILD'**
  String get allergiesCodeMild;

  /// No description provided for @allergiesHelpText.
  ///
  /// In en, this message translates to:
  /// **'List drug allergies, sensitivities, and past adverse reactions. ER staff check this section first. Severity = Mild / Moderate / Severe. Allergies and the \"Medications I never want\" list are separate sections — add a medication you refuse there yourself.'**
  String get allergiesHelpText;

  /// No description provided for @allergiesAddSection.
  ///
  /// In en, this message translates to:
  /// **'Add an allergy'**
  String get allergiesAddSection;

  /// No description provided for @allergiesSourceRxTerms.
  ///
  /// In en, this message translates to:
  /// **'RxTerms · NLM clinical tables'**
  String get allergiesSourceRxTerms;

  /// No description provided for @allergiesSourceIcd.
  ///
  /// In en, this message translates to:
  /// **'ICD-10-CM · NLM clinical tables'**
  String get allergiesSourceIcd;

  /// No description provided for @allergiesNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get allergiesNoResults;

  /// No description provided for @allergiesSourceNote.
  ///
  /// In en, this message translates to:
  /// **'Drug allergies search RxTerms. Food, material & other allergies search ICD-10 (e.g. Z91.01 food allergy, T78.4 unspecified allergy).'**
  String get allergiesSourceNote;

  /// No description provided for @allergiesSeveritySection.
  ///
  /// In en, this message translates to:
  /// **'Severity & reaction'**
  String get allergiesSeveritySection;

  /// No description provided for @allergiesHowSerious.
  ///
  /// In en, this message translates to:
  /// **'How serious is it?'**
  String get allergiesHowSerious;

  /// No description provided for @allergiesWhatHappens.
  ///
  /// In en, this message translates to:
  /// **'What happens'**
  String get allergiesWhatHappens;

  /// No description provided for @allergiesReactionsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Hives, Swelling, Throat closing'**
  String get allergiesReactionsHint;

  /// No description provided for @allergiesAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add allergy'**
  String get allergiesAddButton;

  /// No description provided for @allergiesAddedOne.
  ///
  /// In en, this message translates to:
  /// **'Added · {count} allergy'**
  String allergiesAddedOne(int count);

  /// No description provided for @allergiesAddedMany.
  ///
  /// In en, this message translates to:
  /// **'Added · {count} allergies'**
  String allergiesAddedMany(int count);

  /// No description provided for @allergiesFooter.
  ///
  /// In en, this message translates to:
  /// **'You\'re not required to list anything. Anything you do list is shared only with the people your directive names.'**
  String get allergiesFooter;

  /// No description provided for @allergiesClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get allergiesClearSearch;

  /// No description provided for @allergiesMatches.
  ///
  /// In en, this message translates to:
  /// **'{count} matches'**
  String allergiesMatches(int count);

  /// No description provided for @allergiesSeverityMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get allergiesSeverityMild;

  /// No description provided for @allergiesSeverityMildDesc.
  ///
  /// In en, this message translates to:
  /// **'rash, mild GI'**
  String get allergiesSeverityMildDesc;

  /// No description provided for @allergiesSeverityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get allergiesSeverityModerate;

  /// No description provided for @allergiesSeverityModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'hives, swelling'**
  String get allergiesSeverityModerateDesc;

  /// No description provided for @allergiesSeveritySevere.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get allergiesSeveritySevere;

  /// No description provided for @allergiesSeveritySevereDesc.
  ///
  /// In en, this message translates to:
  /// **'anaphylaxis · ER'**
  String get allergiesSeveritySevereDesc;

  /// No description provided for @allergiesSeveritySemantics.
  ///
  /// In en, this message translates to:
  /// **'{label} severity'**
  String allergiesSeveritySemantics(String label);

  /// No description provided for @medsStepMaxPerCategory.
  ///
  /// In en, this message translates to:
  /// **'Maximum {max} medications per category'**
  String medsStepMaxPerCategory(int max);

  /// No description provided for @medsStepHelpText.
  ///
  /// In en, this message translates to:
  /// **'List medications by name. Your preferences apply to generic, brand name, and trade name equivalents unless you specify otherwise in the notes — to request brand-name only, note it in the reason field.\n\nNarrow Therapeutic Index (NTI) drugs — ones with only a small safety margin between a helpful dose and a harmful one, like lithium, carbamazepine, and valproic acid — cannot have generics substituted under PA law (35 P.S. §960.3). These are marked with an \"NTI\" badge when you search.'**
  String get medsStepHelpText;

  /// No description provided for @medsStepHeadsUpLead.
  ///
  /// In en, this message translates to:
  /// **'Heads up — '**
  String get medsStepHeadsUpLead;

  /// No description provided for @medsStepHeadsUpBody.
  ///
  /// In en, this message translates to:
  /// **'your refusal of a medication and any limits you set on its use are binding under PA Act 194, but '**
  String get medsStepHeadsUpBody;

  /// No description provided for @medsStepHeadsUpBold.
  ///
  /// In en, this message translates to:
  /// **'specific dosage instructions are not binding'**
  String get medsStepHeadsUpBold;

  /// No description provided for @medsStepHeadsUpTail.
  ///
  /// In en, this message translates to:
  /// **' on the physician — they choose the dose.'**
  String get medsStepHeadsUpTail;

  /// No description provided for @medsStepAgentDecides.
  ///
  /// In en, this message translates to:
  /// **'I have designated an agent to make decisions about my medications'**
  String get medsStepAgentDecides;

  /// No description provided for @medsStepCurrentTitle.
  ///
  /// In en, this message translates to:
  /// **'Medications I am currently taking'**
  String get medsStepCurrentTitle;

  /// No description provided for @medsStepCurrentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For your care team’s reference — not a preference'**
  String get medsStepCurrentSubtitle;

  /// No description provided for @medsStepNeverTitle.
  ///
  /// In en, this message translates to:
  /// **'Medications I NEVER want'**
  String get medsStepNeverTitle;

  /// No description provided for @medsStepNeverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These medications should not be administered'**
  String get medsStepNeverSubtitle;

  /// No description provided for @medsStepLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Medications with limitations'**
  String get medsStepLimitTitle;

  /// No description provided for @medsStepLimitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'May be given but with restrictions'**
  String get medsStepLimitSubtitle;

  /// No description provided for @medsStepPreferredTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferred medications'**
  String get medsStepPreferredTitle;

  /// No description provided for @medsStepPreferredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Medications that have worked well for you'**
  String get medsStepPreferredSubtitle;

  /// No description provided for @medsStepSideEffectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Side effects you may be experiencing'**
  String get medsStepSideEffectsTitle;

  /// No description provided for @medsStepSideEffectsBody.
  ///
  /// In en, this message translates to:
  /// **'For the medications you take now, check common side effects — especially any that affect your daily activities — so your care team knows. Needs AI set up. Not medical advice.'**
  String get medsStepSideEffectsBody;

  /// No description provided for @medsStepNtiNote.
  ///
  /// In en, this message translates to:
  /// **'Narrow therapeutic index drug — {note}. Pennsylvania law bars generic substitution for these; note any monitoring needs below. (Informational, not medical advice.)'**
  String medsStepNtiNote(String note);

  /// No description provided for @medsStepDosageLabel.
  ///
  /// In en, this message translates to:
  /// **'Dosage (e.g. 20 mg twice daily)'**
  String get medsStepDosageLabel;

  /// No description provided for @medsStepReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason / notes (optional)'**
  String get medsStepReasonLabel;

  /// No description provided for @medsStepLearnAbout.
  ///
  /// In en, this message translates to:
  /// **'Learn about {name}'**
  String medsStepLearnAbout(String name);

  /// No description provided for @medsStepMedlineInfo.
  ///
  /// In en, this message translates to:
  /// **'Plain-language info (MedlinePlus)'**
  String get medsStepMedlineInfo;

  /// No description provided for @medsStepFdaInfo.
  ///
  /// In en, this message translates to:
  /// **'Official FDA label (side effects & interactions)'**
  String get medsStepFdaInfo;

  /// No description provided for @medsStepRemoveDefault.
  ///
  /// In en, this message translates to:
  /// **'Remove medication'**
  String get medsStepRemoveDefault;

  /// No description provided for @medsStepRemoveNamed.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String medsStepRemoveNamed(String name);

  /// No description provided for @medsStepAddToList.
  ///
  /// In en, this message translates to:
  /// **'Add medication to {title} list'**
  String medsStepAddToList(String title);

  /// No description provided for @medsStepAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add medication'**
  String get medsStepAddButton;

  /// No description provided for @facilityRoommateWomen.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get facilityRoommateWomen;

  /// No description provided for @facilityRoommateMen.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get facilityRoommateMen;

  /// No description provided for @facilityRoommateSameAsIdentity.
  ///
  /// In en, this message translates to:
  /// **'Same as my gender identity'**
  String get facilityRoommateSameAsIdentity;

  /// No description provided for @facilityRoommateSpecify.
  ///
  /// In en, this message translates to:
  /// **'Let me specify'**
  String get facilityRoommateSpecify;

  /// No description provided for @facilityHelpText.
  ///
  /// In en, this message translates to:
  /// **'You may specify treatment facilities you prefer or want to avoid. These preferences guide your agent and treatment providers but may not always be possible to honor. Both sections are optional.'**
  String get facilityHelpText;

  /// No description provided for @facilityNoPreferenceBanner.
  ///
  /// In en, this message translates to:
  /// **'Leave both sections empty if you have no preference. Your directive will indicate \"No Preference\" for treatment facilities.'**
  String get facilityNoPreferenceBanner;

  /// No description provided for @facilityPreferredTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferred Facilities'**
  String get facilityPreferredTitle;

  /// No description provided for @facilityPreferredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Facilities where you would prefer to be treated'**
  String get facilityPreferredSubtitle;

  /// No description provided for @facilityAvoidTitle.
  ///
  /// In en, this message translates to:
  /// **'Facilities to Avoid'**
  String get facilityAvoidTitle;

  /// No description provided for @facilityAvoidSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Facilities where you do not want to be treated'**
  String get facilityAvoidSubtitle;

  /// No description provided for @facilityOtherRoomPrefsLabel.
  ///
  /// In en, this message translates to:
  /// **'Other room preferences'**
  String get facilityOtherRoomPrefsLabel;

  /// No description provided for @facilityOtherRoomPrefsHint.
  ///
  /// In en, this message translates to:
  /// **'Anything else about your room or surroundings — e.g. low lighting, near a window, away from loud areas…'**
  String get facilityOtherRoomPrefsHint;

  /// No description provided for @facilityRoomSingle.
  ///
  /// In en, this message translates to:
  /// **'Single room'**
  String get facilityRoomSingle;

  /// No description provided for @facilityRoomWindow.
  ///
  /// In en, this message translates to:
  /// **'Window if possible'**
  String get facilityRoomWindow;

  /// No description provided for @facilityRoomQuietFloor.
  ///
  /// In en, this message translates to:
  /// **'Quiet floor'**
  String get facilityRoomQuietFloor;

  /// No description provided for @facilityRoomSameGender.
  ///
  /// In en, this message translates to:
  /// **'Same-gender roommate'**
  String get facilityRoomSameGender;

  /// No description provided for @facilityRoomNoRoommate.
  ///
  /// In en, this message translates to:
  /// **'No roommate'**
  String get facilityRoomNoRoommate;

  /// No description provided for @facilityRoomTransAffirming.
  ///
  /// In en, this message translates to:
  /// **'Trans-affirming staff'**
  String get facilityRoomTransAffirming;

  /// No description provided for @facilityRoomLowStimulation.
  ///
  /// In en, this message translates to:
  /// **'Low-stimulation unit'**
  String get facilityRoomLowStimulation;

  /// No description provided for @facilityRoomPrefsTitle.
  ///
  /// In en, this message translates to:
  /// **'Room preferences'**
  String get facilityRoomPrefsTitle;

  /// No description provided for @facilityRoomPrefsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional — guides staff if a choice is available.'**
  String get facilityRoomPrefsSubtitle;

  /// No description provided for @facilityRoommateMatchPrompt.
  ///
  /// In en, this message translates to:
  /// **'For \"same-gender roommate\", match me with:'**
  String get facilityRoommateMatchPrompt;

  /// No description provided for @facilityMatchMeWithLabel.
  ///
  /// In en, this message translates to:
  /// **'Match me with'**
  String get facilityMatchMeWithLabel;

  /// No description provided for @facilityMatchMeWithHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your roommate-matching preference'**
  String get facilityMatchMeWithHint;

  /// No description provided for @facilityNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Facility name'**
  String get facilityNameLabel;

  /// No description provided for @facilityNameHint.
  ///
  /// In en, this message translates to:
  /// **'Type to search facilities'**
  String get facilityNameHint;

  /// No description provided for @facilityLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location (optional)'**
  String get facilityLocationLabel;

  /// No description provided for @facilityLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 123 Main St, Philadelphia, PA'**
  String get facilityLocationHint;

  /// No description provided for @facilityRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove facility'**
  String get facilityRemoveTooltip;

  /// No description provided for @facilityAddToSemantics.
  ///
  /// In en, this message translates to:
  /// **'Add facility to {title}'**
  String facilityAddToSemantics(String title);

  /// No description provided for @facilityAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add facility'**
  String get facilityAddButton;

  /// No description provided for @facilityNpiAttribution.
  ///
  /// In en, this message translates to:
  /// **'Facility names from the NPI registry (NIH Clinical Tables). Verify details before relying on them.'**
  String get facilityNpiAttribution;

  /// No description provided for @addlInstrHelpText.
  ///
  /// In en, this message translates to:
  /// **'These sections are all optional. Use them to give guidance to your agent and treatment team beyond the basic preferences above.'**
  String get addlInstrHelpText;

  /// No description provided for @addlInstrExampleFieldName.
  ///
  /// In en, this message translates to:
  /// **'Additional Instructions'**
  String get addlInstrExampleFieldName;

  /// No description provided for @addlInstrExample1.
  ///
  /// In en, this message translates to:
  /// **'I find listening to calming music and going for walks helpful during periods of distress. Please allow me access to my personal music player.'**
  String get addlInstrExample1;

  /// No description provided for @addlInstrExample2.
  ///
  /// In en, this message translates to:
  /// **'I am vegetarian for religious reasons. Please ensure my dietary needs are respected during any inpatient stay. I would also like access to a chaplain or spiritual advisor.'**
  String get addlInstrExample2;

  /// No description provided for @addlInstrExample3.
  ///
  /// In en, this message translates to:
  /// **'Please notify my sister, Jane Doe, if I am admitted. Do not contact my ex-spouse under any circumstances. My therapist, Dr. Smith, should be informed of any treatment changes.'**
  String get addlInstrExample3;

  /// No description provided for @addlInstrActivitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Activities & Environment'**
  String get addlInstrActivitiesTitle;

  /// No description provided for @addlInstrActivitiesHint.
  ///
  /// In en, this message translates to:
  /// **'Preferences about daily activities, environment, restraints, seclusion'**
  String get addlInstrActivitiesHint;

  /// No description provided for @addlInstrActivitiesDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe activities that help you feel better (e.g., walking, reading, music) and your preferences about your physical environment during treatment. You can also state whether you consent to or refuse the use of restraints (being physically held or strapped down, or given medication to restrict your movement or behavior — a \"chemical restraint\") or seclusion (being confined alone in a room).'**
  String get addlInstrActivitiesDescription;

  /// No description provided for @addlInstrCrisisTitle.
  ///
  /// In en, this message translates to:
  /// **'Crisis Intervention'**
  String get addlInstrCrisisTitle;

  /// No description provided for @addlInstrCrisisHint.
  ///
  /// In en, this message translates to:
  /// **'What helps or doesn\'t help during a crisis'**
  String get addlInstrCrisisHint;

  /// No description provided for @addlInstrCrisisDescription.
  ///
  /// In en, this message translates to:
  /// **'Based on your past experience, describe what helps you during a mental health crisis and what makes things worse. This helps your treatment team respond in the way that works best for you.'**
  String get addlInstrCrisisDescription;

  /// No description provided for @addlInstrDeescTitle.
  ///
  /// In en, this message translates to:
  /// **'De-escalation Techniques'**
  String get addlInstrDeescTitle;

  /// No description provided for @addlInstrDeescHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., music, deep breathing, quiet room, weighted blanket'**
  String get addlInstrDeescHint;

  /// No description provided for @addlInstrDeescDescription.
  ///
  /// In en, this message translates to:
  /// **'List specific techniques or strategies that help calm you when you are distressed. Examples include listening to music, deep breathing, being in a quiet room, using a weighted blanket, speaking with a specific person, or going for a walk.'**
  String get addlInstrDeescDescription;

  /// No description provided for @addlInstrTriggersTitle.
  ///
  /// In en, this message translates to:
  /// **'Potential Crisis Triggers'**
  String get addlInstrTriggersTitle;

  /// No description provided for @addlInstrTriggersHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., loud environments, specific topics, being alone'**
  String get addlInstrTriggersHint;

  /// No description provided for @addlInstrTriggersDescription.
  ///
  /// In en, this message translates to:
  /// **'Identify situations, environments, or topics that may trigger or worsen a crisis for you. This helps your treatment team avoid these triggers. Examples: loud environments, being touched without permission, certain conversation topics, being left alone, or specific people.'**
  String get addlInstrTriggersDescription;

  /// No description provided for @addlInstrHealthHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Health History'**
  String get addlInstrHealthHistoryTitle;

  /// No description provided for @addlInstrHealthHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Relevant mental health history, diagnoses, hospitalizations'**
  String get addlInstrHealthHistoryHint;

  /// No description provided for @addlInstrHealthHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Summarize your relevant mental health history, including past diagnoses, hospitalizations, and treatments that worked well or did not work. This gives your treatment team context about your care history.'**
  String get addlInstrHealthHistoryDescription;

  /// No description provided for @addlInstrDietaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Dietary Preferences'**
  String get addlInstrDietaryTitle;

  /// No description provided for @addlInstrDietaryHint.
  ///
  /// In en, this message translates to:
  /// **'Food restrictions, preferences, religious dietary laws'**
  String get addlInstrDietaryHint;

  /// No description provided for @addlInstrDietaryDescription.
  ///
  /// In en, this message translates to:
  /// **'List any food allergies, dietary restrictions, or preferences your treatment team should know about. This includes religious dietary laws (e.g., kosher, halal, vegetarian), food intolerances, and any foods to avoid due to medication interactions.'**
  String get addlInstrDietaryDescription;

  /// No description provided for @addlInstrReligiousTitle.
  ///
  /// In en, this message translates to:
  /// **'Religious & Spiritual'**
  String get addlInstrReligiousTitle;

  /// No description provided for @addlInstrReligiousHint.
  ///
  /// In en, this message translates to:
  /// **'Religious practices, spiritual needs, clergy contact'**
  String get addlInstrReligiousHint;

  /// No description provided for @addlInstrReligiousDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe any religious or spiritual practices that are important to you during treatment. This may include prayer times, clergy or chaplain visits, religious texts or items you would like to have access to, fasting observances, or faith-based coping practices.'**
  String get addlInstrReligiousDescription;

  /// No description provided for @addlInstrChildrenTitle.
  ///
  /// In en, this message translates to:
  /// **'Children & Custody'**
  String get addlInstrChildrenTitle;

  /// No description provided for @addlInstrChildrenHint.
  ///
  /// In en, this message translates to:
  /// **'Instructions regarding care of your minor children'**
  String get addlInstrChildrenHint;

  /// No description provided for @addlInstrChildrenDescription.
  ///
  /// In en, this message translates to:
  /// **'If you have minor children or dependents, describe who should care for them if you are hospitalized. Include contact information for caregivers, school details, and any custody arrangements your treatment team should be aware of.'**
  String get addlInstrChildrenDescription;

  /// No description provided for @addlInstrFamilyNotifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Notification'**
  String get addlInstrFamilyNotifyTitle;

  /// No description provided for @addlInstrFamilyNotifyHint.
  ///
  /// In en, this message translates to:
  /// **'Who should be notified and how'**
  String get addlInstrFamilyNotifyHint;

  /// No description provided for @addlInstrFamilyNotifyDescription.
  ///
  /// In en, this message translates to:
  /// **'Specify who should be notified if you are hospitalized or if your treatment changes. Include how to reach them and what information may be shared. You can also specify people who should NOT be contacted.'**
  String get addlInstrFamilyNotifyDescription;

  /// No description provided for @addlInstrPetCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Pet Care'**
  String get addlInstrPetCareTitle;

  /// No description provided for @addlInstrPetCareHint.
  ///
  /// In en, this message translates to:
  /// **'Instructions for care of your pets'**
  String get addlInstrPetCareHint;

  /// No description provided for @addlInstrPetCareDescription.
  ///
  /// In en, this message translates to:
  /// **'If you have pets, describe who should care for them if you are hospitalized. Include the caregiver\'s contact information, feeding and medication schedules, veterinary contacts, and any special care instructions.'**
  String get addlInstrPetCareDescription;

  /// No description provided for @addlInstrReproTitle.
  ///
  /// In en, this message translates to:
  /// **'Reproductive Health Care'**
  String get addlInstrReproTitle;

  /// No description provided for @addlInstrReproHint.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy testing, contraception, etc.'**
  String get addlInstrReproHint;

  /// No description provided for @addlInstrReproDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe any reproductive health care preferences your treatment team should know about. This may include whether you want pregnancy testing before medication changes, contraception preferences, or reproductive health conditions that could affect your treatment.'**
  String get addlInstrReproDescription;

  /// No description provided for @addlInstrOtherTitle.
  ///
  /// In en, this message translates to:
  /// **'Other Instructions'**
  String get addlInstrOtherTitle;

  /// No description provided for @addlInstrOtherHint.
  ///
  /// In en, this message translates to:
  /// **'Any other instructions not covered above'**
  String get addlInstrOtherHint;

  /// No description provided for @addlInstrOtherDescription.
  ///
  /// In en, this message translates to:
  /// **'Use this section for any instructions to your treatment team or agent that are not covered by the sections above. This is a catch-all for anything else you want to communicate about your care preferences.'**
  String get addlInstrOtherDescription;

  /// No description provided for @addlInstrRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Records Disclosure & Limitations'**
  String get addlInstrRecordsTitle;

  /// No description provided for @addlInstrRecordsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose who may — and may not — receive copies of your mental health records. Under 20 Pa.C.S. § 5836(e), the disclosure authority you grant here can override certain confidentiality protections (including drug & alcohol, mental-health-procedures, and HIV confidentiality laws), so be specific.'**
  String get addlInstrRecordsDescription;

  /// No description provided for @addlInstrRecordsReleaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Who may receive my records'**
  String get addlInstrRecordsReleaseLabel;

  /// No description provided for @addlInstrRecordsReleaseHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. my agent Jane Doe; my treatment team; Dr. Smith'**
  String get addlInstrRecordsReleaseHint;

  /// No description provided for @addlInstrRecordsWithholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Who must NOT receive my records'**
  String get addlInstrRecordsWithholdLabel;

  /// No description provided for @addlInstrRecordsWithholdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. my ex-spouse; specific family members'**
  String get addlInstrRecordsWithholdHint;

  /// No description provided for @addlInstrRecordsOtherLabel.
  ///
  /// In en, this message translates to:
  /// **'Other limitations on disclosure'**
  String get addlInstrRecordsOtherLabel;

  /// No description provided for @addlInstrRecordsOtherHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. release only records from the last 12 months'**
  String get addlInstrRecordsOtherHint;

  /// No description provided for @addlInstrOptionalAddOns.
  ///
  /// In en, this message translates to:
  /// **'Optional add-ons'**
  String get addlInstrOptionalAddOns;

  /// No description provided for @addlInstrCrisisPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Crisis plan'**
  String get addlInstrCrisisPlanTitle;

  /// No description provided for @addlInstrCrisisPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your early-warning signs, triggers, what genuinely helps, and what not to do. Not required by Act 194 — but it\'s the part agents and ER staff read first.'**
  String get addlInstrCrisisPlanSubtitle;

  /// No description provided for @addlInstrUlyssesTitle.
  ///
  /// In en, this message translates to:
  /// **'Self-binding (Ulysses) clause'**
  String get addlInstrUlyssesTitle;

  /// No description provided for @addlInstrUlyssesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge that, once two professionals find you incapable, what you wrote stands even over your in-the-moment protest, until capacity returns (20 Pa.C.S. §§ 5824, 5834).'**
  String get addlInstrUlyssesSubtitle;

  /// No description provided for @effCondHelpText.
  ///
  /// In en, this message translates to:
  /// **'Describe the circumstances under which you want this directive to take effect — for example, \"when two qualified professionals certify that I lack capacity to make treatment decisions.\" Under PA Act 194, the declaration becomes operative when a psychiatrist and one of the following certify you lack capacity: another psychiatrist, a licensed psychologist, your family physician, your attending physician, or another mental health treatment professional.'**
  String get effCondHelpText;

  /// No description provided for @effCondTakeEffectWhen.
  ///
  /// In en, this message translates to:
  /// **'This directive should take effect when…'**
  String get effCondTakeEffectWhen;

  /// No description provided for @effCondTriggerTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'A psychiatrist + one other professional find I lack capacity'**
  String get effCondTriggerTwoTitle;

  /// No description provided for @effCondTriggerTwoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The standard PA Act 194 trigger — two qualified professionals certify you can\'t make mental-health treatment decisions.'**
  String get effCondTriggerTwoSubtitle;

  /// No description provided for @effCondTriggerCourtTitle.
  ///
  /// In en, this message translates to:
  /// **'A court determines I lack capacity'**
  String get effCondTriggerCourtTitle;

  /// No description provided for @effCondTriggerCommitTitle.
  ///
  /// In en, this message translates to:
  /// **'I am involuntarily committed'**
  String get effCondTriggerCommitTitle;

  /// No description provided for @effCondAnythingElseTitle.
  ///
  /// In en, this message translates to:
  /// **'Anything else about timing (optional)'**
  String get effCondAnythingElseTitle;

  /// No description provided for @effCondAnythingElseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your own words, or pick an example to start from.'**
  String get effCondAnythingElseSubtitle;

  /// No description provided for @effCondExampleFieldName.
  ///
  /// In en, this message translates to:
  /// **'Effective Condition'**
  String get effCondExampleFieldName;

  /// No description provided for @effCondExample1.
  ///
  /// In en, this message translates to:
  /// **'This directive takes effect when I am unable to make mental health treatment decisions for myself, as determined by two qualified professionals.'**
  String get effCondExample1;

  /// No description provided for @effCondExample2.
  ///
  /// In en, this message translates to:
  /// **'This directive becomes effective any time I am admitted to a psychiatric facility or crisis unit, whether voluntary or involuntary, and I am unable to clearly communicate my wishes.'**
  String get effCondExample2;

  /// No description provided for @effCondExample3.
  ///
  /// In en, this message translates to:
  /// **'This directive takes effect when I am experiencing a severe episode of psychosis, mania, or dissociation that prevents me from understanding my treatment options or communicating my preferences.'**
  String get effCondExample3;

  /// No description provided for @effCondExample4.
  ///
  /// In en, this message translates to:
  /// **'This directive becomes effective when I tell my agent or treatment provider that I want it activated, or when I am unable to make consistent and informed decisions about my mental health care.'**
  String get effCondExample4;

  /// No description provided for @effCondExample5.
  ///
  /// In en, this message translates to:
  /// **'This directive is effective when my designated agent, in consultation with any treating professional, determines that I would benefit from having my pre-stated treatment preferences followed.'**
  String get effCondExample5;

  /// No description provided for @effCondOwnWordsLabel.
  ///
  /// In en, this message translates to:
  /// **'In your own words (optional)'**
  String get effCondOwnWordsLabel;

  /// No description provided for @effCondDoctorTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferred evaluating doctor (optional)'**
  String get effCondDoctorTitle;

  /// No description provided for @effCondDoctorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If you have a preferred doctor to evaluate your capacity, enter their information below.'**
  String get effCondDoctorSubtitle;

  /// No description provided for @effCondDoctorNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name of Doctor'**
  String get effCondDoctorNameLabel;

  /// No description provided for @effCondDoctorContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Address / Phone Number'**
  String get effCondDoctorContactLabel;

  /// No description provided for @consentChoiceEctSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'TREATMENT CONSENT'**
  String get consentChoiceEctSectionLabel;

  /// No description provided for @consentChoiceEctTitle.
  ///
  /// In en, this message translates to:
  /// **'Electroconvulsive Therapy (ECT)'**
  String get consentChoiceEctTitle;

  /// No description provided for @consentChoiceEctSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ECT is a psychiatric treatment in which seizures are electrically induced. State your preferences below.'**
  String get consentChoiceEctSubtitle;

  /// No description provided for @consentChoiceEctHelpText.
  ///
  /// In en, this message translates to:
  /// **'ECT can be an effective treatment for severe depression and other conditions. Under PA law, you can consent in advance, refuse in advance, or set conditions.'**
  String get consentChoiceEctHelpText;

  /// No description provided for @consentChoiceEctInfoBannerText.
  ///
  /// In en, this message translates to:
  /// **'Under PA Act 194, your agent cannot consent to ECT unless you explicitly authorize it here.'**
  String get consentChoiceEctInfoBannerText;

  /// No description provided for @consentChoiceEctNoTitle.
  ///
  /// In en, this message translates to:
  /// **'I do not consent to ECT'**
  String get consentChoiceEctNoTitle;

  /// No description provided for @consentChoiceEctNoDescription.
  ///
  /// In en, this message translates to:
  /// **'ECT must not be performed on me.'**
  String get consentChoiceEctNoDescription;

  /// No description provided for @consentChoiceEctYesTitle.
  ///
  /// In en, this message translates to:
  /// **'I consent to ECT'**
  String get consentChoiceEctYesTitle;

  /// No description provided for @consentChoiceEctYesDescription.
  ///
  /// In en, this message translates to:
  /// **'My provider may perform ECT if indicated.'**
  String get consentChoiceEctYesDescription;

  /// No description provided for @consentChoiceEctAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'My agent will decide about ECT'**
  String get consentChoiceEctAgentTitle;

  /// No description provided for @consentChoiceEctAgentDescription.
  ///
  /// In en, this message translates to:
  /// **'Authorize your agent to consent to or refuse ECT on your behalf.'**
  String get consentChoiceEctAgentDescription;

  /// No description provided for @consentChoiceEctConditionalHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., only if other treatments have failed and my agent agrees'**
  String get consentChoiceEctConditionalHint;

  /// No description provided for @consentChoiceExperimentalSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'RESEARCH CONSENT'**
  String get consentChoiceExperimentalSectionLabel;

  /// No description provided for @consentChoiceExperimentalTitle.
  ///
  /// In en, this message translates to:
  /// **'Experimental Studies'**
  String get consentChoiceExperimentalTitle;

  /// No description provided for @consentChoiceExperimentalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'State your preferences regarding participation in experimental research during mental health treatment.'**
  String get consentChoiceExperimentalSubtitle;

  /// No description provided for @consentChoiceExperimentalHelpText.
  ///
  /// In en, this message translates to:
  /// **'You have the right to consent to or refuse participation in experimental research. Your preferences here will guide your care team and agent.'**
  String get consentChoiceExperimentalHelpText;

  /// No description provided for @consentChoiceExperimentalInfoBannerText.
  ///
  /// In en, this message translates to:
  /// **'Under PA Act 194, your agent cannot consent to experimental research unless you explicitly authorize it here.'**
  String get consentChoiceExperimentalInfoBannerText;

  /// No description provided for @consentChoiceExperimentalNoDescription.
  ///
  /// In en, this message translates to:
  /// **'I refuse participation in experimental studies.'**
  String get consentChoiceExperimentalNoDescription;

  /// No description provided for @consentChoiceExperimentalYesTitle.
  ///
  /// In en, this message translates to:
  /// **'I consent to experimental studies'**
  String get consentChoiceExperimentalYesTitle;

  /// No description provided for @consentChoiceExperimentalYesDescription.
  ///
  /// In en, this message translates to:
  /// **'I am willing to participate in research studies during treatment.'**
  String get consentChoiceExperimentalYesDescription;

  /// No description provided for @consentChoiceExperimentalConditionalHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., only non-invasive studies approved by my agent'**
  String get consentChoiceExperimentalConditionalHint;

  /// No description provided for @consentChoiceDrugTrialsSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'CLINICAL TRIALS'**
  String get consentChoiceDrugTrialsSectionLabel;

  /// No description provided for @consentChoiceDrugTrialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Trials'**
  String get consentChoiceDrugTrialsTitle;

  /// No description provided for @consentChoiceDrugTrialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'State your preferences regarding participation in clinical drug trials during mental health treatment.'**
  String get consentChoiceDrugTrialsSubtitle;

  /// No description provided for @consentChoiceDrugTrialsHelpText.
  ///
  /// In en, this message translates to:
  /// **'Clinical drug trials test new medications. You can consent, refuse, or set conditions for your participation.'**
  String get consentChoiceDrugTrialsHelpText;

  /// No description provided for @consentChoiceDrugTrialsInfoBannerText.
  ///
  /// In en, this message translates to:
  /// **'Under PA Act 194, your agent cannot consent to drug trials unless you explicitly authorize it here.'**
  String get consentChoiceDrugTrialsInfoBannerText;

  /// No description provided for @consentChoiceDrugTrialsNoDescription.
  ///
  /// In en, this message translates to:
  /// **'I refuse participation in drug trials.'**
  String get consentChoiceDrugTrialsNoDescription;

  /// No description provided for @consentChoiceDrugTrialsYesTitle.
  ///
  /// In en, this message translates to:
  /// **'I consent to drug trials'**
  String get consentChoiceDrugTrialsYesTitle;

  /// No description provided for @consentChoiceDrugTrialsYesDescription.
  ///
  /// In en, this message translates to:
  /// **'I am willing to participate in clinical drug trials.'**
  String get consentChoiceDrugTrialsYesDescription;

  /// No description provided for @consentChoiceDrugTrialsConditionalHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., only trials with an independent safety monitor'**
  String get consentChoiceDrugTrialsConditionalHint;

  /// No description provided for @consentChoiceConditionalTitle.
  ///
  /// In en, this message translates to:
  /// **'I consent under specific conditions'**
  String get consentChoiceConditionalTitle;

  /// No description provided for @consentChoiceConditionalDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe the conditions in the box below.'**
  String get consentChoiceConditionalDescription;

  /// No description provided for @consentChoiceConditionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get consentChoiceConditionsLabel;

  /// No description provided for @consentChoiceNoConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'I do not consent'**
  String get consentChoiceNoConsentTitle;

  /// No description provided for @consentChoiceAgentDecidesTitle.
  ///
  /// In en, this message translates to:
  /// **'My agent will decide'**
  String get consentChoiceAgentDecidesTitle;

  /// No description provided for @consentChoiceAgentDecidesDescription.
  ///
  /// In en, this message translates to:
  /// **'Authorize your agent to consent or refuse on your behalf.'**
  String get consentChoiceAgentDecidesDescription;

  /// Fallback title of the FTC Health Breach Notification Rule in-app notice (legal copy: human review before translating).
  ///
  /// In en, this message translates to:
  /// **'Notice of a data security incident'**
  String get breachNoticeDefaultTitle;

  /// No description provided for @breachNoticeWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened'**
  String get breachNoticeWhatHappened;

  /// No description provided for @breachNoticeInformationInvolved.
  ///
  /// In en, this message translates to:
  /// **'What information was involved'**
  String get breachNoticeInformationInvolved;

  /// No description provided for @breachNoticeThirdParties.
  ///
  /// In en, this message translates to:
  /// **'Who obtained the information'**
  String get breachNoticeThirdParties;

  /// No description provided for @breachNoticeWhatWeAreDoing.
  ///
  /// In en, this message translates to:
  /// **'What we are doing'**
  String get breachNoticeWhatWeAreDoing;

  /// No description provided for @breachNoticeWhatYouCanDo.
  ///
  /// In en, this message translates to:
  /// **'What you can do'**
  String get breachNoticeWhatYouCanDo;

  /// No description provided for @breachNoticeContactUs.
  ///
  /// In en, this message translates to:
  /// **'How to contact us'**
  String get breachNoticeContactUs;

  /// No description provided for @breachNoticeAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'I have read this notice'**
  String get breachNoticeAcknowledge;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
