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

  /// No description provided for @voiceInputOpenDictation.
  ///
  /// In en, this message translates to:
  /// **'Open voice dictation'**
  String get voiceInputOpenDictation;

  /// No description provided for @voiceInputDictateText.
  ///
  /// In en, this message translates to:
  /// **'Dictate text'**
  String get voiceInputDictateText;

  /// No description provided for @savedImportCouldNotRead.
  ///
  /// In en, this message translates to:
  /// **'Could not read that file.'**
  String get savedImportCouldNotRead;

  /// No description provided for @savedImportImportedAsDraft.
  ///
  /// In en, this message translates to:
  /// **'Imported as an editable draft. After reviewing, re-sign and re-witness it to make it valid again — the previous signature does not carry over.'**
  String get savedImportImportedAsDraft;

  /// No description provided for @contactPickerBtnMissingName.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get contactPickerBtnMissingName;

  /// No description provided for @contactPickerBtnMissingAddress.
  ///
  /// In en, this message translates to:
  /// **'address'**
  String get contactPickerBtnMissingAddress;

  /// No description provided for @contactPickerBtnMissingPhone.
  ///
  /// In en, this message translates to:
  /// **'phone number'**
  String get contactPickerBtnMissingPhone;

  /// No description provided for @contactPickerBtnMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Contact is missing: {fields}. Please fill in the missing fields manually.'**
  String contactPickerBtnMissingFields(String fields);

  /// No description provided for @contactPickerBtnImportA11y.
  ///
  /// In en, this message translates to:
  /// **'Import from contacts'**
  String get contactPickerBtnImportA11y;

  /// No description provided for @contactPickerBtnImport.
  ///
  /// In en, this message translates to:
  /// **'Import from Contacts'**
  String get contactPickerBtnImport;

  /// No description provided for @medAutoSelectA11y.
  ///
  /// In en, this message translates to:
  /// **'Select medication {name}'**
  String medAutoSelectA11y(String name);

  /// No description provided for @medAutoSelectNtiA11y.
  ///
  /// In en, this message translates to:
  /// **'Select medication {name}, narrow therapeutic index drug'**
  String medAutoSelectNtiA11y(String name);

  /// No description provided for @medAutoNtiTooltip.
  ///
  /// In en, this message translates to:
  /// **'Narrow Therapeutic Index (NTI) drug — no generic substitution in PA'**
  String get medAutoNtiTooltip;

  /// No description provided for @medAutoNtiBadge.
  ///
  /// In en, this message translates to:
  /// **'NTI'**
  String get medAutoNtiBadge;

  /// No description provided for @medAutoSelectStrengthA11y.
  ///
  /// In en, this message translates to:
  /// **'Select {medication}'**
  String medAutoSelectStrengthA11y(String medication);

  /// No description provided for @medAutoFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Medication name'**
  String get medAutoFieldLabel;

  /// No description provided for @medAutoSearchingA11y.
  ///
  /// In en, this message translates to:
  /// **'Searching medications'**
  String get medAutoSearchingA11y;

  /// No description provided for @wizardHelpA11y.
  ///
  /// In en, this message translates to:
  /// **'Help for this step. Opens help sheet.'**
  String get wizardHelpA11y;

  /// No description provided for @wizardHelpButton.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get wizardHelpButton;

  /// No description provided for @wizardHelpLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get wizardHelpLearnMore;

  /// No description provided for @wizardHelpQuestionsContact.
  ///
  /// In en, this message translates to:
  /// **'Questions? Contact PA Protection & Advocacy: {phone}'**
  String wizardHelpQuestionsContact(String phone);

  /// No description provided for @neverWantCrossAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to “Medications I never want”?'**
  String get neverWantCrossAddTitle;

  /// No description provided for @neverWantCrossAddBodySingle.
  ///
  /// In en, this message translates to:
  /// **'You listed a drug allergy. Do you also want to refuse it as a medication, adding it to your “Medications I never want” list?'**
  String get neverWantCrossAddBodySingle;

  /// No description provided for @neverWantCrossAddBodyMulti.
  ///
  /// In en, this message translates to:
  /// **'You listed these drug allergies. Choose any you also want to refuse as medications — they’ll be added to your “Medications I never want” list.'**
  String get neverWantCrossAddBodyMulti;

  /// No description provided for @neverWantCrossAddNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get neverWantCrossAddNotNow;

  /// No description provided for @neverWantCrossAddConfirmSingle.
  ///
  /// In en, this message translates to:
  /// **'Add to never-want'**
  String get neverWantCrossAddConfirmSingle;

  /// No description provided for @neverWantCrossAddConfirmMulti.
  ///
  /// In en, this message translates to:
  /// **'Add selected'**
  String get neverWantCrossAddConfirmMulti;

  /// No description provided for @exampleTextSeeExamples.
  ///
  /// In en, this message translates to:
  /// **'See examples'**
  String get exampleTextSeeExamples;

  /// No description provided for @exampleTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Example: {fieldName}'**
  String exampleTextTitle(String fieldName);

  /// No description provided for @exampleTextIntro.
  ///
  /// In en, this message translates to:
  /// **'Here are some examples of what others have written. Use your own words to describe your specific preferences.'**
  String get exampleTextIntro;

  /// No description provided for @exampleTextNumbered.
  ///
  /// In en, this message translates to:
  /// **'Example {number}'**
  String exampleTextNumbered(int number);

  /// No description provided for @exampleTextDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'These are samples only. Your directive should reflect your own wishes and circumstances.'**
  String get exampleTextDisclaimer;

  /// No description provided for @exampleTextGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get exampleTextGotIt;

  /// No description provided for @quizQ1Headline.
  ///
  /// In en, this message translates to:
  /// **'Do you have someone in mind to **speak for you**?'**
  String get quizQ1Headline;

  /// No description provided for @quizQ1Sub.
  ///
  /// In en, this message translates to:
  /// **'A family member, partner, or close friend who could make treatment decisions if you can\'t.'**
  String get quizQ1Sub;

  /// No description provided for @quizQ1O1Label.
  ///
  /// In en, this message translates to:
  /// **'Yes — and I trust them completely'**
  String get quizQ1O1Label;

  /// No description provided for @quizQ1O1Hint.
  ///
  /// In en, this message translates to:
  /// **'You probably want a Combined or POA-only form.'**
  String get quizQ1O1Hint;

  /// No description provided for @quizQ1O2Label.
  ///
  /// In en, this message translates to:
  /// **'Yes, but I want to set firm limits'**
  String get quizQ1O2Label;

  /// No description provided for @quizQ1O2Hint.
  ///
  /// In en, this message translates to:
  /// **'Combined gives you both an agent and a binding declaration.'**
  String get quizQ1O2Hint;

  /// No description provided for @quizQ1O3Label.
  ///
  /// In en, this message translates to:
  /// **'No — I want providers to follow my written wishes'**
  String get quizQ1O3Label;

  /// No description provided for @quizQ1O3Hint.
  ///
  /// In en, this message translates to:
  /// **'Declaration-only is for you.'**
  String get quizQ1O3Hint;

  /// No description provided for @quizQ1O4Label.
  ///
  /// In en, this message translates to:
  /// **'I\'m not sure yet'**
  String get quizQ1O4Label;

  /// No description provided for @quizQ1O4Hint.
  ///
  /// In en, this message translates to:
  /// **'No problem — we can come back to this.'**
  String get quizQ1O4Hint;

  /// No description provided for @quizQ2Headline.
  ///
  /// In en, this message translates to:
  /// **'Do you want to **write down** specific treatment preferences?'**
  String get quizQ2Headline;

  /// No description provided for @quizQ2Sub.
  ///
  /// In en, this message translates to:
  /// **'Medications, facilities, ECT, experimental studies, drug trials.'**
  String get quizQ2Sub;

  /// No description provided for @quizQ2O1Label.
  ///
  /// In en, this message translates to:
  /// **'Yes — I have specific things I want or refuse'**
  String get quizQ2O1Label;

  /// No description provided for @quizQ2O1Hint.
  ///
  /// In en, this message translates to:
  /// **'You probably want a Combined or Declaration form.'**
  String get quizQ2O1Hint;

  /// No description provided for @quizQ2O2Label.
  ///
  /// In en, this message translates to:
  /// **'Some preferences, but I\'d rather my agent decide'**
  String get quizQ2O2Label;

  /// No description provided for @quizQ2O2Hint.
  ///
  /// In en, this message translates to:
  /// **'Combined still works — agent decides where you didn\'t write.'**
  String get quizQ2O2Hint;

  /// No description provided for @quizQ2O3Label.
  ///
  /// In en, this message translates to:
  /// **'No — let my agent or doctors decide everything'**
  String get quizQ2O3Label;

  /// No description provided for @quizQ2O3Hint.
  ///
  /// In en, this message translates to:
  /// **'Power of Attorney only is the lightest path.'**
  String get quizQ2O3Hint;

  /// No description provided for @quizQ2O4Label.
  ///
  /// In en, this message translates to:
  /// **'I\'m not sure yet'**
  String get quizQ2O4Label;

  /// No description provided for @quizQ2O4Hint.
  ///
  /// In en, this message translates to:
  /// **'No problem — Combined leaves both doors open.'**
  String get quizQ2O4Hint;

  /// No description provided for @quizQ3Headline.
  ///
  /// In en, this message translates to:
  /// **'If you can\'t decide, **whose voice** should reach the doctors first?'**
  String get quizQ3Headline;

  /// No description provided for @quizQ3Sub.
  ///
  /// In en, this message translates to:
  /// **'The directive you write today, or the person you trust?'**
  String get quizQ3Sub;

  /// No description provided for @quizQ3O1Label.
  ///
  /// In en, this message translates to:
  /// **'What I wrote — even over what someone says in the moment'**
  String get quizQ3O1Label;

  /// No description provided for @quizQ3O1Hint.
  ///
  /// In en, this message translates to:
  /// **'Declaration-only or Combined with strong written preferences.'**
  String get quizQ3O1Hint;

  /// No description provided for @quizQ3O2Label.
  ///
  /// In en, this message translates to:
  /// **'My agent — they can read the situation in real time'**
  String get quizQ3O2Label;

  /// No description provided for @quizQ3O2Hint.
  ///
  /// In en, this message translates to:
  /// **'POA-only or Combined where the agent has broad authority.'**
  String get quizQ3O2Hint;

  /// No description provided for @quizQ3O3Label.
  ///
  /// In en, this message translates to:
  /// **'Both — what I wrote, with my agent filling gaps'**
  String get quizQ3O3Label;

  /// No description provided for @quizQ3O3Hint.
  ///
  /// In en, this message translates to:
  /// **'Combined is the strongest fit.'**
  String get quizQ3O3Hint;

  /// No description provided for @quizQ3O4Label.
  ///
  /// In en, this message translates to:
  /// **'I\'m not sure yet'**
  String get quizQ3O4Label;

  /// No description provided for @quizQ3O4Hint.
  ///
  /// In en, this message translates to:
  /// **'No problem — Combined supports both pathways.'**
  String get quizQ3O4Hint;

  /// No description provided for @quizQ4Headline.
  ///
  /// In en, this message translates to:
  /// **'What\'s the **most important** thing this document does for you?'**
  String get quizQ4Headline;

  /// No description provided for @quizQ4Sub.
  ///
  /// In en, this message translates to:
  /// **'There\'s no wrong answer — this just confirms what we\'re seeing.'**
  String get quizQ4Sub;

  /// No description provided for @quizQ4O1Label.
  ///
  /// In en, this message translates to:
  /// **'Names who I trust to speak for me'**
  String get quizQ4O1Label;

  /// No description provided for @quizQ4O1Hint.
  ///
  /// In en, this message translates to:
  /// **'Combined or POA-only.'**
  String get quizQ4O1Hint;

  /// No description provided for @quizQ4O2Label.
  ///
  /// In en, this message translates to:
  /// **'Locks in specific treatments I want — or refuse'**
  String get quizQ4O2Label;

  /// No description provided for @quizQ4O2Hint.
  ///
  /// In en, this message translates to:
  /// **'Combined or Declaration-only.'**
  String get quizQ4O2Hint;

  /// No description provided for @quizQ4O3Label.
  ///
  /// In en, this message translates to:
  /// **'Both — equally'**
  String get quizQ4O3Label;

  /// No description provided for @quizQ4O3Hint.
  ///
  /// In en, this message translates to:
  /// **'Combined.'**
  String get quizQ4O3Hint;

  /// No description provided for @quizQ4O4Label.
  ///
  /// In en, this message translates to:
  /// **'Just having something on file'**
  String get quizQ4O4Label;

  /// No description provided for @quizQ4O4Hint.
  ///
  /// In en, this message translates to:
  /// **'Any form works. Combined gives the broadest coverage.'**
  String get quizQ4O4Hint;

  /// No description provided for @quizQuestionEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Help me choose · question {current} of {total}'**
  String quizQuestionEyebrow(int current, int total);

  /// No description provided for @quizInYourWords.
  ///
  /// In en, this message translates to:
  /// **'In your words'**
  String get quizInYourWords;

  /// No description provided for @quizResultEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Help me choose · result'**
  String get quizResultEyebrow;

  /// No description provided for @quizRecommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get quizRecommendedForYou;

  /// No description provided for @quizYouProbablyWant.
  ///
  /// In en, this message translates to:
  /// **'You probably want\n'**
  String get quizYouProbablyWant;

  /// No description provided for @quizLegendCombined.
  ///
  /// In en, this message translates to:
  /// **'Combined'**
  String get quizLegendCombined;

  /// No description provided for @quizLegendDeclaration.
  ///
  /// In en, this message translates to:
  /// **'Declaration only'**
  String get quizLegendDeclaration;

  /// No description provided for @quizLegendPoa.
  ///
  /// In en, this message translates to:
  /// **'Power of Attorney only'**
  String get quizLegendPoa;

  /// No description provided for @quizRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get quizRetake;

  /// No description provided for @quizUseForm.
  ///
  /// In en, this message translates to:
  /// **'Use {formName}'**
  String quizUseForm(String formName);

  /// No description provided for @quizFormNameCombined.
  ///
  /// In en, this message translates to:
  /// **'Combined'**
  String get quizFormNameCombined;

  /// No description provided for @quizFormNameDeclaration.
  ///
  /// In en, this message translates to:
  /// **'Declaration'**
  String get quizFormNameDeclaration;

  /// No description provided for @quizFormNamePoa.
  ///
  /// In en, this message translates to:
  /// **'POA'**
  String get quizFormNamePoa;

  /// No description provided for @quizExplainCombined.
  ///
  /// In en, this message translates to:
  /// **'Includes both your treatment preferences AND an agent designation. The most comprehensive option — and what most people choose.'**
  String get quizExplainCombined;

  /// No description provided for @quizExplainPoa.
  ///
  /// In en, this message translates to:
  /// **'Designates an agent to make decisions for you, without locking in specific treatment preferences. Best when you trust someone completely and want them to decide in the moment.'**
  String get quizExplainPoa;

  /// No description provided for @quizExplainDeclaration.
  ///
  /// In en, this message translates to:
  /// **'Documents your treatment preferences without naming an agent. Your treatment team will follow your written wishes directly.'**
  String get quizExplainDeclaration;

  /// No description provided for @aiSuggestDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Draft'**
  String get aiSuggestDraftTitle;

  /// No description provided for @aiSuggestSuggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Suggestion'**
  String get aiSuggestSuggestionTitle;

  /// No description provided for @aiSuggestYourText.
  ///
  /// In en, this message translates to:
  /// **'Your text:'**
  String get aiSuggestYourText;

  /// No description provided for @aiSuggestDraftLabel.
  ///
  /// In en, this message translates to:
  /// **'AI draft:'**
  String get aiSuggestDraftLabel;

  /// No description provided for @aiSuggestSuggestionLabel.
  ///
  /// In en, this message translates to:
  /// **'AI suggestion:'**
  String get aiSuggestSuggestionLabel;

  /// No description provided for @aiSuggestReviewCarefully.
  ///
  /// In en, this message translates to:
  /// **'{notAdvice} Review carefully.'**
  String aiSuggestReviewCarefully(String notAdvice);

  /// No description provided for @aiSuggestDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get aiSuggestDismiss;

  /// No description provided for @aiSuggestAddToMine.
  ///
  /// In en, this message translates to:
  /// **'Add to mine'**
  String get aiSuggestAddToMine;

  /// No description provided for @aiSuggestUseDraft.
  ///
  /// In en, this message translates to:
  /// **'Use this draft'**
  String get aiSuggestUseDraft;

  /// No description provided for @aiSuggestUseInstead.
  ///
  /// In en, this message translates to:
  /// **'Use instead'**
  String get aiSuggestUseInstead;

  /// No description provided for @aiSuggestAppliedA11y.
  ///
  /// In en, this message translates to:
  /// **'AI suggestion applied. Undo available.'**
  String get aiSuggestAppliedA11y;

  /// No description provided for @aiSuggestApplied.
  ///
  /// In en, this message translates to:
  /// **'AI suggestion applied.'**
  String get aiSuggestApplied;

  /// No description provided for @aiSuggestUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get aiSuggestUndo;

  /// No description provided for @aiSuggestLoadingA11y.
  ///
  /// In en, this message translates to:
  /// **'AI Suggest, loading suggestion for {fieldName}'**
  String aiSuggestLoadingA11y(String fieldName);

  /// No description provided for @aiSuggestForFieldA11y.
  ///
  /// In en, this message translates to:
  /// **'AI Suggest for {fieldName}'**
  String aiSuggestForFieldA11y(String fieldName);

  /// No description provided for @aiSuggestSetupA11y.
  ///
  /// In en, this message translates to:
  /// **'Set up AI Assistant to use suggestions'**
  String get aiSuggestSetupA11y;

  /// No description provided for @aiSuggestTooltip.
  ///
  /// In en, this message translates to:
  /// **'Get an AI suggestion for this field'**
  String get aiSuggestTooltip;

  /// No description provided for @aiSuggestSetupTooltip.
  ///
  /// In en, this message translates to:
  /// **'Set up AI Assistant to use this feature'**
  String get aiSuggestSetupTooltip;

  /// No description provided for @aiSuggestIconTooltip.
  ///
  /// In en, this message translates to:
  /// **'AI suggestion'**
  String get aiSuggestIconTooltip;

  /// No description provided for @contactSheetPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Contact permission is required to import.'**
  String get contactSheetPermissionRequired;

  /// No description provided for @contactSheetRolePrimaryAgent.
  ///
  /// In en, this message translates to:
  /// **'primary agent'**
  String get contactSheetRolePrimaryAgent;

  /// No description provided for @contactSheetPickYour.
  ///
  /// In en, this message translates to:
  /// **'Pick your '**
  String get contactSheetPickYour;

  /// No description provided for @contactSheetLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'From your phone\'s contacts. We never upload them — search runs locally.'**
  String get contactSheetLocalOnly;

  /// No description provided for @contactSheetSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or number'**
  String get contactSheetSearchHint;

  /// No description provided for @contactSheetClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get contactSheetClearSearch;

  /// No description provided for @contactSheetContactsCount.
  ///
  /// In en, this message translates to:
  /// **'Contacts · {count}'**
  String contactSheetContactsCount(int count);

  /// No description provided for @contactSheetPickAContact.
  ///
  /// In en, this message translates to:
  /// **'Pick a contact'**
  String get contactSheetPickAContact;

  /// No description provided for @contactSheetUseName.
  ///
  /// In en, this message translates to:
  /// **'Use {name}'**
  String contactSheetUseName(String name);

  /// No description provided for @contactSheetThisContact.
  ///
  /// In en, this message translates to:
  /// **'this contact'**
  String get contactSheetThisContact;

  /// No description provided for @contactSheetLooksLikeProvider.
  ///
  /// In en, this message translates to:
  /// **'Looks like a provider'**
  String get contactSheetLooksLikeProvider;

  /// No description provided for @contactSheetUnder18.
  ///
  /// In en, this message translates to:
  /// **'Under 18'**
  String get contactSheetUnder18;

  /// No description provided for @contactSheetWarnConfirm.
  ///
  /// In en, this message translates to:
  /// **'⚠ {note} — confirm they\'re not treating you'**
  String contactSheetWarnConfirm(String note);

  /// No description provided for @contactSheetEligible.
  ///
  /// In en, this message translates to:
  /// **'✓ Eligible · 18+'**
  String get contactSheetEligible;

  /// No description provided for @contactSheetEnterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter someone manually'**
  String get contactSheetEnterManually;

  /// No description provided for @contactSheetHardBlock.
  ///
  /// In en, this message translates to:
  /// **'hard block'**
  String get contactSheetHardBlock;

  /// No description provided for @contactSheetSoftWarn.
  ///
  /// In en, this message translates to:
  /// **'soft warn'**
  String get contactSheetSoftWarn;

  /// No description provided for @contactSheetRuleProvider.
  ///
  /// In en, this message translates to:
  /// **'Your current treating provider or their employee'**
  String get contactSheetRuleProvider;

  /// No description provided for @contactSheetRuleFacilityOwner.
  ///
  /// In en, this message translates to:
  /// **'An owner/operator of a facility where you receive care'**
  String get contactSheetRuleFacilityOwner;

  /// No description provided for @contactSheetWhoCantBeAgent.
  ///
  /// In en, this message translates to:
  /// **'Who can\'t be your agent'**
  String get contactSheetWhoCantBeAgent;

  /// No description provided for @contactSheetRulesFootnote.
  ///
  /// In en, this message translates to:
  /// **'Under-18 is blocked automatically from the contact\'s birthday. We can\'t tell who your providers are, so anything that looks like a provider is a soft warning you can override — confirm only if they truly aren\'t treating you.'**
  String get contactSheetRulesFootnote;

  /// No description provided for @voiceMicPermission.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is needed.'**
  String get voiceMicPermission;

  /// No description provided for @voiceTranscribeFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t transcribe. Try again, or type it instead.'**
  String get voiceTranscribeFailed;

  /// No description provided for @voiceSpeechError.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition error.'**
  String get voiceSpeechError;

  /// No description provided for @voiceNeedsBrowser.
  ///
  /// In en, this message translates to:
  /// **'Voice needs Chrome, Edge, or Safari.'**
  String get voiceNeedsBrowser;

  /// No description provided for @voiceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is not available on this device.'**
  String get voiceNotAvailable;

  /// No description provided for @voiceStatusTranscribing.
  ///
  /// In en, this message translates to:
  /// **'● Transcribing'**
  String get voiceStatusTranscribing;

  /// No description provided for @voiceStatusRecording.
  ///
  /// In en, this message translates to:
  /// **'● Recording'**
  String get voiceStatusRecording;

  /// No description provided for @voiceStatusPaused.
  ///
  /// In en, this message translates to:
  /// **'● Paused'**
  String get voiceStatusPaused;

  /// No description provided for @voiceSayItYourWay.
  ///
  /// In en, this message translates to:
  /// **'Say it your way.'**
  String get voiceSayItYourWay;

  /// No description provided for @voiceExplainAi.
  ///
  /// In en, this message translates to:
  /// **'For better accuracy on medication names and conditions, your recording goes to Google\'s AI to transcribe. Review the text before saving.'**
  String get voiceExplainAi;

  /// No description provided for @voiceExplainBrowser.
  ///
  /// In en, this message translates to:
  /// **'To transcribe, your browser sends the audio to its speech service (often Google). We don\'t keep the audio or text — edit it before saving.'**
  String get voiceExplainBrowser;

  /// No description provided for @voiceExplainDevice.
  ///
  /// In en, this message translates to:
  /// **'Your device turns speech into text. We never store the audio — you can edit before saving.'**
  String get voiceExplainDevice;

  /// No description provided for @voiceEmptyHintAi.
  ///
  /// In en, this message translates to:
  /// **'Tap the red button, speak, then tap stop to transcribe…'**
  String get voiceEmptyHintAi;

  /// No description provided for @voiceEmptyHintLive.
  ///
  /// In en, this message translates to:
  /// **'Tap the red record button and start speaking…'**
  String get voiceEmptyHintLive;

  /// No description provided for @voiceCancelA11y.
  ///
  /// In en, this message translates to:
  /// **'Cancel voice recording'**
  String get voiceCancelA11y;

  /// No description provided for @voiceConfirmA11y.
  ///
  /// In en, this message translates to:
  /// **'Confirm and use transcript'**
  String get voiceConfirmA11y;

  /// No description provided for @voiceFooterAi.
  ///
  /// In en, this message translates to:
  /// **'WE STORE NOTHING · GOOGLE\'S AI TRANSCRIBES THE RECORDING'**
  String get voiceFooterAi;

  /// No description provided for @voiceFooterBrowser.
  ///
  /// In en, this message translates to:
  /// **'WE STORE NOTHING · YOUR BROWSER\'S SPEECH SERVICE TRANSCRIBES THE AUDIO'**
  String get voiceFooterBrowser;

  /// No description provided for @voiceFooterDevice.
  ///
  /// In en, this message translates to:
  /// **'AUDIO ISN\'T SAVED · TRANSCRIPT STAYS IN THIS SESSION'**
  String get voiceFooterDevice;

  /// No description provided for @voiceTranscribingCard.
  ///
  /// In en, this message translates to:
  /// **'Transcribing your recording…'**
  String get voiceTranscribingCard;

  /// No description provided for @voiceStopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get voiceStopRecording;

  /// No description provided for @voiceStartRecording.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get voiceStartRecording;

  /// No description provided for @pipelineGeneratingSuggestions.
  ///
  /// In en, this message translates to:
  /// **'AI is generating personalized suggestions...'**
  String get pipelineGeneratingSuggestions;

  /// No description provided for @pipelineNoAdditionalSuggestions.
  ///
  /// In en, this message translates to:
  /// **'AI could not generate additional suggestions.'**
  String get pipelineNoAdditionalSuggestions;

  /// No description provided for @pipelineAutofillProblem.
  ///
  /// In en, this message translates to:
  /// **'Autofill hit a problem. {error}'**
  String pipelineAutofillProblem(String error);

  /// No description provided for @pipelineAppliedA11y.
  ///
  /// In en, this message translates to:
  /// **'Autofill applied {count} fields to your directive'**
  String pipelineAppliedA11y(int count);

  /// No description provided for @pipelineAppliedNoneA11y.
  ///
  /// In en, this message translates to:
  /// **'Autofill finished — no new fields were added'**
  String get pipelineAppliedNoneA11y;

  /// No description provided for @pipelinePastedImage.
  ///
  /// In en, this message translates to:
  /// **'Pasted image'**
  String get pipelinePastedImage;

  /// No description provided for @pipelineDocument.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get pipelineDocument;

  /// No description provided for @pipelineKindPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pipelineKindPdf;

  /// No description provided for @pipelineKindPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get pipelineKindPhoto;

  /// No description provided for @pipelineKindText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get pipelineKindText;

  /// No description provided for @pipelineKindAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get pipelineKindAudio;

  /// No description provided for @pipelineKindFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get pipelineKindFile;

  /// No description provided for @pipelineCancelled.
  ///
  /// In en, this message translates to:
  /// **'Processing cancelled — nothing was applied.'**
  String get pipelineCancelled;

  /// No description provided for @pipelineSetupAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up AI to read documents'**
  String get pipelineSetupAiTitle;

  /// No description provided for @pipelineSetupAiBody.
  ///
  /// In en, this message translates to:
  /// **'Snap-to-fill uses AI to read your uploaded document (photo, PDF, or text) and pull out details to fill your form — medications, conditions, care preferences, and your contact details. It needs an AI key — Gemini\'s free tier takes about 30 seconds to set up. You review every field before anything lands in your form.'**
  String get pipelineSetupAiBody;

  /// No description provided for @pipelineSetupAi.
  ///
  /// In en, this message translates to:
  /// **'Set up AI'**
  String get pipelineSetupAi;

  /// No description provided for @pipelineDroppedFile.
  ///
  /// In en, this message translates to:
  /// **'Dropped file'**
  String get pipelineDroppedFile;

  /// No description provided for @pipelineUnsupportedType.
  ///
  /// In en, this message translates to:
  /// **'That file type isn\'t supported. Use a JPG, PNG, HEIC, PDF, or text file.'**
  String get pipelineUnsupportedType;

  /// No description provided for @pipelineRpmLimit.
  ///
  /// In en, this message translates to:
  /// **'Processing {pages} pages requires {pages} requests, but only {remaining} requests are available this minute. Please wait {seconds} seconds or select fewer pages.'**
  String pipelineRpmLimit(int pages, int remaining, int seconds);

  /// No description provided for @pipelineRpdLimit.
  ///
  /// In en, this message translates to:
  /// **'Processing {pages} pages requires {pages} requests, but only {remaining} requests remain today (daily limit: {limit}).'**
  String pipelineRpdLimit(int pages, int remaining, int limit);

  /// No description provided for @pipelineFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File \"{name}\" is too large ({sizeMb} MB). Maximum file size is 10 MB per document.'**
  String pipelineFileTooLarge(String name, String sizeMb);

  /// No description provided for @pipelineExtractingPage.
  ///
  /// In en, this message translates to:
  /// **'Extracting page {current} of {total}...'**
  String pipelineExtractingPage(int current, int total);

  /// No description provided for @pipelineExtractingSingle.
  ///
  /// In en, this message translates to:
  /// **'Extracting medical data from document...'**
  String get pipelineExtractingSingle;

  /// No description provided for @pipelineLooksLikeKind.
  ///
  /// In en, this message translates to:
  /// **' (it looks like a {kind})'**
  String pipelineLooksLikeKind(String kind);

  /// No description provided for @pipelineNotMedicalSingle.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t look like a health or medical document{kind}, so nothing was used. Upload a medical record, medication or allergy list, or an existing advance directive.'**
  String pipelineNotMedicalSingle(String kind);

  /// No description provided for @pipelineNotMedicalMulti.
  ///
  /// In en, this message translates to:
  /// **'These don\'t look like health or medical documents{kind}, so nothing was used.'**
  String pipelineNotMedicalMulti(String kind);

  /// No description provided for @pipelineNoMedicalInfoSingle.
  ///
  /// In en, this message translates to:
  /// **'No medical information found in this document.'**
  String get pipelineNoMedicalInfoSingle;

  /// No description provided for @pipelineNoMedicalInfoMulti.
  ///
  /// In en, this message translates to:
  /// **'No medical information found in these {count} pages.'**
  String pipelineNoMedicalInfoMulti(int count);

  /// No description provided for @pipelineValidating.
  ///
  /// In en, this message translates to:
  /// **'Validating medications and conditions...'**
  String get pipelineValidating;

  /// No description provided for @pipelinePleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait while processing...'**
  String get pipelinePleaseWait;

  /// No description provided for @pipelineBackWizard.
  ///
  /// In en, this message translates to:
  /// **'Wizard'**
  String get pipelineBackWizard;

  /// No description provided for @pipelineBackReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get pipelineBackReview;

  /// No description provided for @pipelineTitleSnapToFill.
  ///
  /// In en, this message translates to:
  /// **'Snap to fill'**
  String get pipelineTitleSnapToFill;

  /// No description provided for @pipelineTitleProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get pipelineTitleProcessing;

  /// No description provided for @pipelineTitleReview.
  ///
  /// In en, this message translates to:
  /// **'Review Extracted Data'**
  String get pipelineTitleReview;

  /// No description provided for @pipelineTitleGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating Suggestions'**
  String get pipelineTitleGenerating;

  /// No description provided for @pipelineTitleResults.
  ///
  /// In en, this message translates to:
  /// **'AI Suggestions'**
  String get pipelineTitleResults;

  /// No description provided for @pipelinePickerFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the file picker ({error}). Try dragging the file onto the box above instead.'**
  String pipelinePickerFailed(String error);

  /// No description provided for @pipelineCouldNotRead.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t read that file. Please use a PDF, JPG, PNG, WEBP, HEIC, or plain-text file under 10 MB.'**
  String get pipelineCouldNotRead;

  /// No description provided for @pipelineFormCombined.
  ///
  /// In en, this message translates to:
  /// **'Combined'**
  String get pipelineFormCombined;

  /// No description provided for @pipelineFormDeclaration.
  ///
  /// In en, this message translates to:
  /// **'Declaration only'**
  String get pipelineFormDeclaration;

  /// No description provided for @pipelineFormPoa.
  ///
  /// In en, this message translates to:
  /// **'Power of Attorney only'**
  String get pipelineFormPoa;

  /// No description provided for @pipelineFormCombinedSub.
  ///
  /// In en, this message translates to:
  /// **'Treatment preferences AND a decision-maker (broadest).'**
  String get pipelineFormCombinedSub;

  /// No description provided for @pipelineFormDeclarationSub.
  ///
  /// In en, this message translates to:
  /// **'Treatment preferences, without naming an agent.'**
  String get pipelineFormDeclarationSub;

  /// No description provided for @pipelineFormPoaSub.
  ///
  /// In en, this message translates to:
  /// **'Name a decision-maker, without listing preferences.'**
  String get pipelineFormPoaSub;

  /// No description provided for @pipelineWhichForm.
  ///
  /// In en, this message translates to:
  /// **'Which form do you want to fill?'**
  String get pipelineWhichForm;

  /// No description provided for @pipelineWhichFormBody.
  ///
  /// In en, this message translates to:
  /// **'Choose your form first — the AI will then read only the parts that form needs. Combined is the broadest; you can change this later.'**
  String get pipelineWhichFormBody;

  /// No description provided for @pickSnapOptional.
  ///
  /// In en, this message translates to:
  /// **'Snap to fill · optional'**
  String get pickSnapOptional;

  /// No description provided for @pickHeadlineLead.
  ///
  /// In en, this message translates to:
  /// **'Have a photo handy? '**
  String get pickHeadlineLead;

  /// No description provided for @pickHeadlineAccent.
  ///
  /// In en, this message translates to:
  /// **'We\'ll read it.'**
  String get pickHeadlineAccent;

  /// No description provided for @pickIntro.
  ///
  /// In en, this message translates to:
  /// **'Drop a photo, PDF, or audio recording — ID, medication list, prescription label, an old directive, or just describe your wishes out loud — and the AI will extract what it can. You review every field before it lands in the form. Or skip and type it all yourself.'**
  String get pickIntro;

  /// No description provided for @pickPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your privacy: black out anything sensitive before uploading. You never have to upload personal details at all — any field can be typed in by hand to keep it confidential.'**
  String get pickPrivacyNote;

  /// No description provided for @pickVoiceGuideLink.
  ///
  /// In en, this message translates to:
  /// **'Recording a voice file? See the questionnaire & how-to'**
  String get pickVoiceGuideLink;

  /// No description provided for @pickSkipTypeAll.
  ///
  /// In en, this message translates to:
  /// **'Skip — I\'ll type it all'**
  String get pickSkipTypeAll;

  /// No description provided for @pickContinueStep2.
  ///
  /// In en, this message translates to:
  /// **'Continue to step 2'**
  String get pickContinueStep2;

  /// No description provided for @pickYourDocuments.
  ///
  /// In en, this message translates to:
  /// **'Your documents'**
  String get pickYourDocuments;

  /// No description provided for @pickFilesKeptInMemory.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 FILE · KEPT IN MEMORY} other{{count} FILES · KEPT IN MEMORY}}'**
  String pickFilesKeptInMemory(int count);

  /// No description provided for @pickClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get pickClearAll;

  /// No description provided for @pickHeldWithKey.
  ///
  /// In en, this message translates to:
  /// **'Held on this device. Nothing is sent until you tap Read — then it goes to your AI provider to read.'**
  String get pickHeldWithKey;

  /// No description provided for @pickHeldNoKey.
  ///
  /// In en, this message translates to:
  /// **'Held on this device. Reading needs AI set up first (free, ~30 seconds) — nothing is sent until then.'**
  String get pickHeldNoKey;

  /// No description provided for @pickReadWithAi.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Read this document with AI} other{Read {count} documents with AI}}'**
  String pickReadWithAi(int count);

  /// No description provided for @pickRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get pickRemove;

  /// No description provided for @pickNoKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'AI isn\'t set up yet'**
  String get pickNoKeyTitle;

  /// No description provided for @pickNoKeyBody.
  ///
  /// In en, this message translates to:
  /// **'You can see how snap-to-fill works below, but reading a real photo or PDF needs an AI key (Gemini\'s free tier takes about 30 seconds). You review every field before it lands in your form.'**
  String get pickNoKeyBody;

  /// No description provided for @pickTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get pickTryAgain;

  /// No description provided for @pickDropTitleCamera.
  ///
  /// In en, this message translates to:
  /// **'Add a photo of your document'**
  String get pickDropTitleCamera;

  /// No description provided for @pickDropTitle.
  ///
  /// In en, this message translates to:
  /// **'Drop a photo, PDF, or screenshot'**
  String get pickDropTitle;

  /// No description provided for @pickFormatsPaste.
  ///
  /// In en, this message translates to:
  /// **'JPG · PNG · HEIC · PDF · up to 10 MB — or paste with {shortcut}'**
  String pickFormatsPaste(String shortcut);

  /// No description provided for @pickFormats.
  ///
  /// In en, this message translates to:
  /// **'JPG · PNG · HEIC · PDF · up to 10 MB'**
  String get pickFormats;

  /// No description provided for @pickBrowseFiles.
  ///
  /// In en, this message translates to:
  /// **'Browse files'**
  String get pickBrowseFiles;

  /// No description provided for @pickTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get pickTakePhoto;

  /// No description provided for @pickSentToProvider.
  ///
  /// In en, this message translates to:
  /// **'To autofill, your file — including any personal details in it — is sent to your AI provider to read. The app saves nothing (it\'s gone when this tab closes), but the provider may retain it (Gemini\'s free tier does). You review everything before it is added to your directive.'**
  String get pickSentToProvider;

  /// No description provided for @pickTargetId.
  ///
  /// In en, this message translates to:
  /// **'Photo of ID'**
  String get pickTargetId;

  /// No description provided for @pickTargetIdSub.
  ///
  /// In en, this message translates to:
  /// **'Name · DOB · address'**
  String get pickTargetIdSub;

  /// No description provided for @pickTargetRx.
  ///
  /// In en, this message translates to:
  /// **'Rx bottle / label'**
  String get pickTargetRx;

  /// No description provided for @pickTargetRxSub.
  ///
  /// In en, this message translates to:
  /// **'Drug · dose · schedule'**
  String get pickTargetRxSub;

  /// No description provided for @pickTargetConditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions list'**
  String get pickTargetConditions;

  /// No description provided for @pickTargetConditionsSub.
  ///
  /// In en, this message translates to:
  /// **'Diagnoses · allergies'**
  String get pickTargetConditionsSub;

  /// No description provided for @pickTargetOther.
  ///
  /// In en, this message translates to:
  /// **'Anything else'**
  String get pickTargetOther;

  /// No description provided for @pickTargetOtherSub.
  ///
  /// In en, this message translates to:
  /// **'Notes, old directive…'**
  String get pickTargetOtherSub;

  /// No description provided for @pickTargetOtherSubMobile.
  ///
  /// In en, this message translates to:
  /// **'Old directive, notes…'**
  String get pickTargetOtherSubMobile;

  /// No description provided for @pickWhatYouCanAdd.
  ///
  /// In en, this message translates to:
  /// **'What you can add'**
  String get pickWhatYouCanAdd;

  /// No description provided for @pickWhatYouCanDrop.
  ///
  /// In en, this message translates to:
  /// **'What you can drop here'**
  String get pickWhatYouCanDrop;

  /// No description provided for @pickOnAPhone.
  ///
  /// In en, this message translates to:
  /// **'On a phone instead?'**
  String get pickOnAPhone;

  /// No description provided for @pickOnAPhoneBody.
  ///
  /// In en, this message translates to:
  /// **'Open this page on your phone to snap a page directly with its camera.'**
  String get pickOnAPhoneBody;

  /// No description provided for @pickTakePhotoSub.
  ///
  /// In en, this message translates to:
  /// **'Opens your camera. Snap your ID, Rx label, anything.'**
  String get pickTakePhotoSub;

  /// No description provided for @pickPickFile.
  ///
  /// In en, this message translates to:
  /// **'Pick a file'**
  String get pickPickFile;

  /// No description provided for @pickPickFileSub.
  ///
  /// In en, this message translates to:
  /// **'From your photos or files. JPG, PNG, HEIC, PDF.'**
  String get pickPickFileSub;

  /// No description provided for @pickWhatHelpsMost.
  ///
  /// In en, this message translates to:
  /// **'What helps most'**
  String get pickWhatHelpsMost;

  /// No description provided for @pickFastest.
  ///
  /// In en, this message translates to:
  /// **'FASTEST'**
  String get pickFastest;

  /// No description provided for @pickSentToProviderShort.
  ///
  /// In en, this message translates to:
  /// **'Your file (including any personal details) is sent to your AI provider to read it. The app saves nothing; the provider may retain it (Gemini\'s free tier does). You review before anything is added.'**
  String get pickSentToProviderShort;

  /// No description provided for @pickReadingDocs.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Reading 1 document:} other{Reading {count} documents:}}'**
  String pickReadingDocs(int count);

  /// No description provided for @pickReadByAi.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Read by Google\'s AI to autofill.} other{{count} files read by Google\'s AI to autofill.}}'**
  String pickReadByAi(int count);

  /// No description provided for @reviewLabelMedPrefer.
  ///
  /// In en, this message translates to:
  /// **'Preferred Medication'**
  String get reviewLabelMedPrefer;

  /// No description provided for @reviewLabelMedAvoid.
  ///
  /// In en, this message translates to:
  /// **'Medication to Avoid'**
  String get reviewLabelMedAvoid;

  /// No description provided for @reviewLabelMedCurrent.
  ///
  /// In en, this message translates to:
  /// **'Currently Taking'**
  String get reviewLabelMedCurrent;

  /// No description provided for @reviewLabelMedLimit.
  ///
  /// In en, this message translates to:
  /// **'Restricted-Use Medication'**
  String get reviewLabelMedLimit;

  /// No description provided for @reviewLabelCond.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get reviewLabelCond;

  /// No description provided for @reviewLabelDiag.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get reviewLabelDiag;

  /// No description provided for @reviewLabelAllergy.
  ///
  /// In en, this message translates to:
  /// **'Allergy'**
  String get reviewLabelAllergy;

  /// No description provided for @reviewLabelHh.
  ///
  /// In en, this message translates to:
  /// **'Health History'**
  String get reviewLabelHh;

  /// No description provided for @reviewLabelEffectiveCondition.
  ///
  /// In en, this message translates to:
  /// **'When this kicks in (your words)'**
  String get reviewLabelEffectiveCondition;

  /// No description provided for @reviewLabelFacilityPrefer.
  ///
  /// In en, this message translates to:
  /// **'Preferred Facility'**
  String get reviewLabelFacilityPrefer;

  /// No description provided for @reviewLabelFacilityAvoid.
  ///
  /// In en, this message translates to:
  /// **'Facility to Avoid'**
  String get reviewLabelFacilityAvoid;

  /// No description provided for @reviewLabelDietary.
  ///
  /// In en, this message translates to:
  /// **'Dietary'**
  String get reviewLabelDietary;

  /// No description provided for @reviewLabelReligious.
  ///
  /// In en, this message translates to:
  /// **'Religious/Cultural'**
  String get reviewLabelReligious;

  /// No description provided for @reviewLabelActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get reviewLabelActivities;

  /// No description provided for @reviewLabelCrisis.
  ///
  /// In en, this message translates to:
  /// **'Crisis Intervention'**
  String get reviewLabelCrisis;

  /// No description provided for @reviewLabelCrisisPlan.
  ///
  /// In en, this message translates to:
  /// **'Crisis plan'**
  String get reviewLabelCrisisPlan;

  /// No description provided for @reviewLabelAgentAuthorityLimitations.
  ///
  /// In en, this message translates to:
  /// **'Agent authority limits'**
  String get reviewLabelAgentAuthorityLimitations;

  /// No description provided for @reviewLabelEctConsent.
  ///
  /// In en, this message translates to:
  /// **'ECT consent'**
  String get reviewLabelEctConsent;

  /// No description provided for @reviewLabelExperimentalConsent.
  ///
  /// In en, this message translates to:
  /// **'Experimental treatment consent'**
  String get reviewLabelExperimentalConsent;

  /// No description provided for @reviewLabelDrugTrialConsent.
  ///
  /// In en, this message translates to:
  /// **'Drug trial consent'**
  String get reviewLabelDrugTrialConsent;

  /// No description provided for @reviewLabelMedicationConsent.
  ///
  /// In en, this message translates to:
  /// **'Medication consent'**
  String get reviewLabelMedicationConsent;

  /// No description provided for @reviewLabelTriggerTwoProfessionals.
  ///
  /// In en, this message translates to:
  /// **'Trigger: professionals'**
  String get reviewLabelTriggerTwoProfessionals;

  /// No description provided for @reviewLabelTriggerCourtOrder.
  ///
  /// In en, this message translates to:
  /// **'Trigger: court order'**
  String get reviewLabelTriggerCourtOrder;

  /// No description provided for @reviewLabelTriggerInvoluntaryCommitment.
  ///
  /// In en, this message translates to:
  /// **'Trigger: involuntary commitment'**
  String get reviewLabelTriggerInvoluntaryCommitment;

  /// No description provided for @reviewLabelRoomPrefsNote.
  ///
  /// In en, this message translates to:
  /// **'Room preferences'**
  String get reviewLabelRoomPrefsNote;

  /// No description provided for @reviewLabelRoomPrefChips.
  ///
  /// In en, this message translates to:
  /// **'Room options'**
  String get reviewLabelRoomPrefChips;

  /// No description provided for @reviewLabelRoommateSameGender.
  ///
  /// In en, this message translates to:
  /// **'Same-gender roommate'**
  String get reviewLabelRoommateSameGender;

  /// No description provided for @reviewLabelGuardianCanRevoke.
  ///
  /// In en, this message translates to:
  /// **'Guardian: override'**
  String get reviewLabelGuardianCanRevoke;

  /// No description provided for @reviewLabelGuardianCanChangeAgent.
  ///
  /// In en, this message translates to:
  /// **'Guardian: replace agent'**
  String get reviewLabelGuardianCanChangeAgent;

  /// No description provided for @reviewLabelGuardianMustConsultAgent.
  ///
  /// In en, this message translates to:
  /// **'Guardian: consult agent'**
  String get reviewLabelGuardianMustConsultAgent;

  /// No description provided for @reviewLabelAuthorityHospitalization.
  ///
  /// In en, this message translates to:
  /// **'Agent: hospitalization'**
  String get reviewLabelAuthorityHospitalization;

  /// No description provided for @reviewLabelAuthorityMedication.
  ///
  /// In en, this message translates to:
  /// **'Agent: medications'**
  String get reviewLabelAuthorityMedication;

  /// No description provided for @reviewLabelUlyssesOptin.
  ///
  /// In en, this message translates to:
  /// **'Self-binding (Ulysses)'**
  String get reviewLabelUlyssesOptin;

  /// No description provided for @reviewLabelPetCustody.
  ///
  /// In en, this message translates to:
  /// **'Pet care'**
  String get reviewLabelPetCustody;

  /// No description provided for @reviewLabelChildrenCustody.
  ///
  /// In en, this message translates to:
  /// **'Children / dependents'**
  String get reviewLabelChildrenCustody;

  /// No description provided for @reviewLabelFamilyNotification.
  ///
  /// In en, this message translates to:
  /// **'Who to notify'**
  String get reviewLabelFamilyNotification;

  /// No description provided for @reviewLabelRecordsDisclosure.
  ///
  /// In en, this message translates to:
  /// **'Records disclosure'**
  String get reviewLabelRecordsDisclosure;

  /// No description provided for @reviewLabelOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reviewLabelOther;

  /// No description provided for @reviewLabelPersonName.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get reviewLabelPersonName;

  /// No description provided for @reviewLabelPersonDob.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get reviewLabelPersonDob;

  /// No description provided for @reviewLabelPersonAddress1.
  ///
  /// In en, this message translates to:
  /// **'Street address'**
  String get reviewLabelPersonAddress1;

  /// No description provided for @reviewLabelPersonAddress2.
  ///
  /// In en, this message translates to:
  /// **'Apt / suite / unit'**
  String get reviewLabelPersonAddress2;

  /// No description provided for @reviewLabelPersonCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get reviewLabelPersonCity;

  /// No description provided for @reviewLabelPersonCounty.
  ///
  /// In en, this message translates to:
  /// **'County'**
  String get reviewLabelPersonCounty;

  /// No description provided for @reviewLabelPersonState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get reviewLabelPersonState;

  /// No description provided for @reviewLabelPersonZip.
  ///
  /// In en, this message translates to:
  /// **'ZIP code'**
  String get reviewLabelPersonZip;

  /// No description provided for @reviewLabelPersonPhone.
  ///
  /// In en, this message translates to:
  /// **'Your phone'**
  String get reviewLabelPersonPhone;

  /// No description provided for @reviewLabelPersonDoctorName.
  ///
  /// In en, this message translates to:
  /// **'Primary doctor'**
  String get reviewLabelPersonDoctorName;

  /// No description provided for @reviewLabelPersonDoctorSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Doctor specialty'**
  String get reviewLabelPersonDoctorSpecialty;

  /// No description provided for @reviewLabelPersonDoctorPhone.
  ///
  /// In en, this message translates to:
  /// **'Doctor\'s phone'**
  String get reviewLabelPersonDoctorPhone;

  /// No description provided for @reviewLabelPersonEvalDoctorName.
  ///
  /// In en, this message translates to:
  /// **'Preferred evaluating doctor'**
  String get reviewLabelPersonEvalDoctorName;

  /// No description provided for @reviewLabelPersonEvalDoctorContact.
  ///
  /// In en, this message translates to:
  /// **'Evaluating doctor contact'**
  String get reviewLabelPersonEvalDoctorContact;

  /// No description provided for @reviewLabelAgentName.
  ///
  /// In en, this message translates to:
  /// **'Agent name'**
  String get reviewLabelAgentName;

  /// No description provided for @reviewLabelAgentRelationship.
  ///
  /// In en, this message translates to:
  /// **'Agent relationship'**
  String get reviewLabelAgentRelationship;

  /// No description provided for @reviewLabelAgentAddress1.
  ///
  /// In en, this message translates to:
  /// **'Agent street address'**
  String get reviewLabelAgentAddress1;

  /// No description provided for @reviewLabelAgentAddress2.
  ///
  /// In en, this message translates to:
  /// **'Agent apt / suite'**
  String get reviewLabelAgentAddress2;

  /// No description provided for @reviewLabelAgentCity.
  ///
  /// In en, this message translates to:
  /// **'Agent city'**
  String get reviewLabelAgentCity;

  /// No description provided for @reviewLabelAgentState.
  ///
  /// In en, this message translates to:
  /// **'Agent state'**
  String get reviewLabelAgentState;

  /// No description provided for @reviewLabelAgentZip.
  ///
  /// In en, this message translates to:
  /// **'Agent ZIP'**
  String get reviewLabelAgentZip;

  /// No description provided for @reviewLabelAgentPhone.
  ///
  /// In en, this message translates to:
  /// **'Agent phone'**
  String get reviewLabelAgentPhone;

  /// No description provided for @reviewLabelAltAgentName.
  ///
  /// In en, this message translates to:
  /// **'Alternate agent name'**
  String get reviewLabelAltAgentName;

  /// No description provided for @reviewLabelAltAgentRelationship.
  ///
  /// In en, this message translates to:
  /// **'Alternate agent relationship'**
  String get reviewLabelAltAgentRelationship;

  /// No description provided for @reviewLabelAltAgentAddress1.
  ///
  /// In en, this message translates to:
  /// **'Alt agent street address'**
  String get reviewLabelAltAgentAddress1;

  /// No description provided for @reviewLabelAltAgentAddress2.
  ///
  /// In en, this message translates to:
  /// **'Alt agent apt / suite'**
  String get reviewLabelAltAgentAddress2;

  /// No description provided for @reviewLabelAltAgentCity.
  ///
  /// In en, this message translates to:
  /// **'Alt agent city'**
  String get reviewLabelAltAgentCity;

  /// No description provided for @reviewLabelAltAgentState.
  ///
  /// In en, this message translates to:
  /// **'Alt agent state'**
  String get reviewLabelAltAgentState;

  /// No description provided for @reviewLabelAltAgentZip.
  ///
  /// In en, this message translates to:
  /// **'Alt agent ZIP'**
  String get reviewLabelAltAgentZip;

  /// No description provided for @reviewLabelAltAgentPhone.
  ///
  /// In en, this message translates to:
  /// **'Alternate agent phone'**
  String get reviewLabelAltAgentPhone;

  /// No description provided for @reviewLabelGuardianName.
  ///
  /// In en, this message translates to:
  /// **'Guardian nominee'**
  String get reviewLabelGuardianName;

  /// No description provided for @reviewLabelGuardianRelationship.
  ///
  /// In en, this message translates to:
  /// **'Guardian relationship'**
  String get reviewLabelGuardianRelationship;

  /// No description provided for @reviewLabelGuardianAddress1.
  ///
  /// In en, this message translates to:
  /// **'Guardian street address'**
  String get reviewLabelGuardianAddress1;

  /// No description provided for @reviewLabelGuardianAddress2.
  ///
  /// In en, this message translates to:
  /// **'Guardian apt / suite'**
  String get reviewLabelGuardianAddress2;

  /// No description provided for @reviewLabelGuardianCity.
  ///
  /// In en, this message translates to:
  /// **'Guardian city'**
  String get reviewLabelGuardianCity;

  /// No description provided for @reviewLabelGuardianState.
  ///
  /// In en, this message translates to:
  /// **'Guardian state'**
  String get reviewLabelGuardianState;

  /// No description provided for @reviewLabelGuardianZip.
  ///
  /// In en, this message translates to:
  /// **'Guardian ZIP'**
  String get reviewLabelGuardianZip;

  /// No description provided for @reviewLabelGuardianPhone.
  ///
  /// In en, this message translates to:
  /// **'Guardian phone'**
  String get reviewLabelGuardianPhone;

  /// No description provided for @reviewSectionMedPrefer.
  ///
  /// In en, this message translates to:
  /// **'Preferred Meds'**
  String get reviewSectionMedPrefer;

  /// No description provided for @reviewSectionMedAvoid.
  ///
  /// In en, this message translates to:
  /// **'Meds to Avoid'**
  String get reviewSectionMedAvoid;

  /// No description provided for @reviewSectionMedCurrent.
  ///
  /// In en, this message translates to:
  /// **'Currently Taking'**
  String get reviewSectionMedCurrent;

  /// No description provided for @reviewSectionMedLimit.
  ///
  /// In en, this message translates to:
  /// **'Restricted-Use Meds'**
  String get reviewSectionMedLimit;

  /// No description provided for @reviewSectionCond.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get reviewSectionCond;

  /// No description provided for @reviewSectionDiag.
  ///
  /// In en, this message translates to:
  /// **'Diagnoses'**
  String get reviewSectionDiag;

  /// No description provided for @reviewSectionAllergy.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get reviewSectionAllergy;

  /// No description provided for @reviewSectionHh.
  ///
  /// In en, this message translates to:
  /// **'Health History'**
  String get reviewSectionHh;

  /// No description provided for @reviewSectionEffectiveCondition.
  ///
  /// In en, this message translates to:
  /// **'When this kicks in'**
  String get reviewSectionEffectiveCondition;

  /// No description provided for @reviewSectionPerson.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get reviewSectionPerson;

  /// No description provided for @reviewSectionAgent.
  ///
  /// In en, this message translates to:
  /// **'Your agent'**
  String get reviewSectionAgent;

  /// No description provided for @reviewSectionAgentAuthority.
  ///
  /// In en, this message translates to:
  /// **'Agent Authority'**
  String get reviewSectionAgentAuthority;

  /// No description provided for @reviewSectionUlyssesOptin.
  ///
  /// In en, this message translates to:
  /// **'Self-binding'**
  String get reviewSectionUlyssesOptin;

  /// No description provided for @reviewSectionCrisisPlan.
  ///
  /// In en, this message translates to:
  /// **'Crisis Plan'**
  String get reviewSectionCrisisPlan;

  /// No description provided for @reviewSectionConsent.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get reviewSectionConsent;

  /// No description provided for @reviewSectionRoomPreferences.
  ///
  /// In en, this message translates to:
  /// **'Room Preferences'**
  String get reviewSectionRoomPreferences;

  /// No description provided for @reviewSectionAltAgent.
  ///
  /// In en, this message translates to:
  /// **'Alternate agent'**
  String get reviewSectionAltAgent;

  /// No description provided for @reviewSectionGuardian.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get reviewSectionGuardian;

  /// No description provided for @reviewSectionOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reviewSectionOther;

  /// No description provided for @reviewStepGroupWhenKicksIn.
  ///
  /// In en, this message translates to:
  /// **'When this kicks in'**
  String get reviewStepGroupWhenKicksIn;

  /// No description provided for @reviewStepGroupDiagnoses.
  ///
  /// In en, this message translates to:
  /// **'Diagnoses'**
  String get reviewStepGroupDiagnoses;

  /// No description provided for @reviewStepGroupAboutYou.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get reviewStepGroupAboutYou;

  /// No description provided for @reviewStepGroupPeopleITrust.
  ///
  /// In en, this message translates to:
  /// **'People I trust'**
  String get reviewStepGroupPeopleITrust;

  /// No description provided for @reviewStepGroupGuardian.
  ///
  /// In en, this message translates to:
  /// **'If a court appoints a guardian'**
  String get reviewStepGroupGuardian;

  /// No description provided for @reviewStepGroupWhereIWantCare.
  ///
  /// In en, this message translates to:
  /// **'Where I want care'**
  String get reviewStepGroupWhereIWantCare;

  /// No description provided for @reviewStepGroupMedications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get reviewStepGroupMedications;

  /// No description provided for @reviewStepGroupAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies & reactions'**
  String get reviewStepGroupAllergies;

  /// No description provided for @reviewStepGroupProceduresResearch.
  ///
  /// In en, this message translates to:
  /// **'Procedures & research'**
  String get reviewStepGroupProceduresResearch;

  /// No description provided for @reviewStepGroupAnythingElse.
  ///
  /// In en, this message translates to:
  /// **'Anything else'**
  String get reviewStepGroupAnythingElse;

  /// No description provided for @reviewAiReadThisPhoto.
  ///
  /// In en, this message translates to:
  /// **'AI READ THIS PHOTO'**
  String get reviewAiReadThisPhoto;

  /// No description provided for @reviewHeresWhatWeRead.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what we read.'**
  String get reviewHeresWhatWeRead;

  /// No description provided for @reviewHowToIntro.
  ///
  /// In en, this message translates to:
  /// **'These are the details the AI pulled from your document. Here\'s how to use this page:'**
  String get reviewHowToIntro;

  /// No description provided for @reviewHowToChecked.
  ///
  /// In en, this message translates to:
  /// **'A checked box means it will be added to your form. Uncheck anything you don\'t want.'**
  String get reviewHowToChecked;

  /// No description provided for @reviewHowToEdit.
  ///
  /// In en, this message translates to:
  /// **'Tap any field to edit its wording before it\'s added.'**
  String get reviewHowToEdit;

  /// No description provided for @reviewHowToGrouped.
  ///
  /// In en, this message translates to:
  /// **'Results are grouped by form section (the same steps you\'ll see next). A \"Replaces what you have\" note means it would overwrite something you already entered — those start unchecked.'**
  String get reviewHowToGrouped;

  /// No description provided for @reviewHowToFinish.
  ///
  /// In en, this message translates to:
  /// **'When you\'re ready, tap \"{buttonLabel}\" at the bottom to fill these into your form and continue — you\'ll land in the form to review everything.'**
  String reviewHowToFinish(String buttonLabel);

  /// No description provided for @reviewPiiRemoved.
  ///
  /// In en, this message translates to:
  /// **'PII was detected and removed before analysis: {items}'**
  String reviewPiiRemoved(String items);

  /// No description provided for @reviewAddToDirective.
  ///
  /// In en, this message translates to:
  /// **'Add to your directive'**
  String get reviewAddToDirective;

  /// No description provided for @reviewPhotoDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Your photo was sent to the AI to read, then discarded. Nothing is stored after you confirm or discard.'**
  String get reviewPhotoDiscarded;

  /// No description provided for @reviewFieldsReady.
  ///
  /// In en, this message translates to:
  /// **'{checked} of {total} fields ready to add'**
  String reviewFieldsReady(int checked, int total);

  /// No description provided for @reviewYouEntered.
  ///
  /// In en, this message translates to:
  /// **'You entered'**
  String get reviewYouEntered;

  /// No description provided for @reviewAutofillFound.
  ///
  /// In en, this message translates to:
  /// **'Autofill found'**
  String get reviewAutofillFound;

  /// No description provided for @reviewKeepMine.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get reviewKeepMine;

  /// No description provided for @reviewUseNew.
  ///
  /// In en, this message translates to:
  /// **'Use new'**
  String get reviewUseNew;

  /// No description provided for @reviewAddBoth.
  ///
  /// In en, this message translates to:
  /// **'Add both'**
  String get reviewAddBoth;

  /// No description provided for @reviewConsolidateAi.
  ///
  /// In en, this message translates to:
  /// **'Consolidate (AI)'**
  String get reviewConsolidateAi;

  /// No description provided for @reviewIdentityNotMerged.
  ///
  /// In en, this message translates to:
  /// **'Identity fields aren\'t merged by the AI — double-check this one yourself.'**
  String get reviewIdentityNotMerged;

  /// No description provided for @reviewWillSave.
  ///
  /// In en, this message translates to:
  /// **'Will save:'**
  String get reviewWillSave;

  /// No description provided for @reviewSetupAiToConsolidate.
  ///
  /// In en, this message translates to:
  /// **'Set up the AI assistant first to consolidate.'**
  String get reviewSetupAiToConsolidate;

  /// No description provided for @reviewAgentInitialsNote.
  ///
  /// In en, this message translates to:
  /// **'This lets your agent decide. Under PA law (§5836(c)) it only takes effect if you physically initial this authorization on the printed form — confirm this is what you want.'**
  String get reviewAgentInitialsNote;

  /// No description provided for @reviewSmartIntro.
  ///
  /// In en, this message translates to:
  /// **'The AI generated these additional suggestions based on your validated conditions and medications. Tap to edit, uncheck to skip. This is not medical or legal advice.'**
  String get reviewSmartIntro;

  /// No description provided for @reviewGuidanceOnly.
  ///
  /// In en, this message translates to:
  /// **'Guidance to read — not saved to your form. Set your choice in Procedures & research.'**
  String get reviewGuidanceOnly;

  /// No description provided for @reviewAutofillInformation.
  ///
  /// In en, this message translates to:
  /// **'Autofill Information'**
  String get reviewAutofillInformation;

  /// No description provided for @reviewApplyAll.
  ///
  /// In en, this message translates to:
  /// **'Apply All'**
  String get reviewApplyAll;

  /// No description provided for @reviewDiscardAll.
  ///
  /// In en, this message translates to:
  /// **'Discard all'**
  String get reviewDiscardAll;

  /// No description provided for @reviewGenerateMore.
  ///
  /// In en, this message translates to:
  /// **'Generate more'**
  String get reviewGenerateMore;

  /// No description provided for @reviewIncludeField.
  ///
  /// In en, this message translates to:
  /// **'Include this field'**
  String get reviewIncludeField;

  /// No description provided for @reviewNotAdded.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get reviewNotAdded;

  /// No description provided for @reviewEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get reviewEdit;

  /// No description provided for @homeMakeItFindableInA.
  ///
  /// In en, this message translates to:
  /// **'Make it findable in a crisis'**
  String get homeMakeItFindableInA;

  /// No description provided for @homeShareCopiesCarryTheWallet.
  ///
  /// In en, this message translates to:
  /// **'Share copies, carry the wallet card, tell your people where it is'**
  String get homeShareCopiesCarryTheWallet;

  /// No description provided for @homeSessionRestoredPersonalInfoMust.
  ///
  /// In en, this message translates to:
  /// **'Session restored. Personal info must be re-entered.'**
  String get homeSessionRestoredPersonalInfoMust;

  /// No description provided for @homeDeleteDirective.
  ///
  /// In en, this message translates to:
  /// **'Delete directive?'**
  String get homeDeleteDirective;

  /// No description provided for @homeAllDataForThisDirective.
  ///
  /// In en, this message translates to:
  /// **'All data for this directive will be permanently deleted.'**
  String get homeAllDataForThisDirective;

  /// No description provided for @homeDirectiveDeleted.
  ///
  /// In en, this message translates to:
  /// **'Directive deleted.'**
  String get homeDirectiveDeleted;

  /// No description provided for @homeRenameDirective.
  ///
  /// In en, this message translates to:
  /// **'Rename directive'**
  String get homeRenameDirective;

  /// No description provided for @homeRenewDirective.
  ///
  /// In en, this message translates to:
  /// **'Renew Directive?'**
  String get homeRenewDirective;

  /// No description provided for @homeThisWillCreateANew.
  ///
  /// In en, this message translates to:
  /// **'This will create a new directive with the same treatment preferences and agent designations. Personal information, witnesses, and signatures will need to be re-entered.\n\nThe original directive will remain unchanged.'**
  String get homeThisWillCreateANew;

  /// No description provided for @homeRenew.
  ///
  /// In en, this message translates to:
  /// **'Renew'**
  String get homeRenew;

  /// No description provided for @homeAmendThisDirective.
  ///
  /// In en, this message translates to:
  /// **'Amend this directive?'**
  String get homeAmendThisDirective;

  /// No description provided for @homeAmendingOpensThisDirectiveSo.
  ///
  /// In en, this message translates to:
  /// **'Amending opens this directive so you can change it — your existing answers stay in place.\n\nImportant: an amendment is only valid once you re-sign it on paper with two adult witnesses, the same way as the original (PA Act 194). Until you re-sign, this directive will show as an unsigned draft, and any printed copies of the old version stay in effect until you replace them.\n\nPrefer to keep the signed original untouched? Use “Renew (copy to new)” instead.'**
  String get homeAmendingOpensThisDirectiveSo;

  /// No description provided for @homeAmend.
  ///
  /// In en, this message translates to:
  /// **'Amend'**
  String get homeAmend;

  /// No description provided for @homePrivateByDesign.
  ///
  /// In en, this message translates to:
  /// **'Private by design'**
  String get homePrivateByDesign;

  /// No description provided for @homeLetSGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started.'**
  String get homeLetSGetStarted;

  /// No description provided for @homeRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get homeRename;

  /// No description provided for @homeLabelShownInThisList.
  ///
  /// In en, this message translates to:
  /// **'Label shown in this list only — never printed'**
  String get homeLabelShownInThisList;

  /// No description provided for @homeRenewCopyToNew.
  ///
  /// In en, this message translates to:
  /// **'Renew (copy to new)'**
  String get homeRenewCopyToNew;

  /// No description provided for @homeAmendEditThisOne.
  ///
  /// In en, this message translates to:
  /// **'Amend (edit this one)'**
  String get homeAmendEditThisOne;

  /// No description provided for @homeRequiresReSigningReWitnessing.
  ///
  /// In en, this message translates to:
  /// **'Requires re-signing & re-witnessing'**
  String get homeRequiresReSigningReWitnessing;

  /// No description provided for @homeRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get homeRevoke;

  /// No description provided for @homeTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get homeTools;

  /// No description provided for @homePastDirectives.
  ///
  /// In en, this message translates to:
  /// **'Past directives'**
  String get homePastDirectives;

  /// No description provided for @homeStartANewDirective.
  ///
  /// In en, this message translates to:
  /// **'Start a new directive'**
  String get homeStartANewDirective;

  /// No description provided for @homeLoadingYourDirectives.
  ///
  /// In en, this message translates to:
  /// **'Loading your directives'**
  String get homeLoadingYourDirectives;

  /// No description provided for @homeDisplayLabel.
  ///
  /// In en, this message translates to:
  /// **'Display label'**
  String get homeDisplayLabel;

  /// No description provided for @homeShownOnlyInThisList.
  ///
  /// In en, this message translates to:
  /// **'Shown only in this list — never printed on the form. Leave empty to use the name on the directive.'**
  String get homeShownOnlyInThisList;

  /// No description provided for @homeCouldnTLoadYourDirectives.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your directives.'**
  String get homeCouldnTLoadYourDirectives;

  /// No description provided for @homeNothingWasLostThisIs.
  ///
  /// In en, this message translates to:
  /// **'Nothing was lost — this is a display problem, not a data one.'**
  String get homeNothingWasLostThisIs;

  /// No description provided for @homeYourVoice.
  ///
  /// In en, this message translates to:
  /// **'Your voice,\n'**
  String get homeYourVoice;

  /// No description provided for @homeInYourWords.
  ///
  /// In en, this message translates to:
  /// **'in your words.'**
  String get homeInYourWords;

  /// No description provided for @homeLetSKeepYourVoice.
  ///
  /// In en, this message translates to:
  /// **'Let\'s keep your voice clear.'**
  String get homeLetSKeepYourVoice;

  /// No description provided for @homeStartYourDirective.
  ///
  /// In en, this message translates to:
  /// **'Start your directive'**
  String get homeStartYourDirective;

  /// No description provided for @homePrivateBodyWeb.
  ///
  /// In en, this message translates to:
  /// **'Your directive never leaves this browser — no server, no account, no tracking. It lives only in this session, and only you choose who to share it with.'**
  String get homePrivateBodyWeb;

  /// No description provided for @homePrivateBodyDevice.
  ///
  /// In en, this message translates to:
  /// **'Your directive stays on your device. No ads, no tracking, no selling your data — only you choose who to share it with.'**
  String get homePrivateBodyDevice;

  /// No description provided for @homeHiName.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}.\n'**
  String homeHiName(String name);

  /// No description provided for @homeProfileA11y.
  ///
  /// In en, this message translates to:
  /// **'Profile {name}'**
  String homeProfileA11y(String name);

  /// No description provided for @homeCardDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft · step {step} of {total} · {date}'**
  String homeCardDraft(int step, int total, String date);

  /// No description provided for @homeCardPrepared.
  ///
  /// In en, this message translates to:
  /// **'Prepared · {date}'**
  String homeCardPrepared(String date);

  /// No description provided for @homeCardExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired · revoke or copy to new'**
  String get homeCardExpired;

  /// No description provided for @homeCardRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked · {date}'**
  String homeCardRevoked(String date);

  /// No description provided for @homeCardDirectiveYear.
  ///
  /// In en, this message translates to:
  /// **'Directive · {year}'**
  String homeCardDirectiveYear(int year);

  /// No description provided for @homeCardA11y.
  ///
  /// In en, this message translates to:
  /// **'{name}. {status}. Tap to open.'**
  String homeCardA11y(String name, String status);

  /// No description provided for @crisisPlanHelpThePeopleAroundYou.
  ///
  /// In en, this message translates to:
  /// **'Help the people around you spot trouble early — and know what actually helps you when they do.'**
  String get crisisPlanHelpThePeopleAroundYou;

  /// No description provided for @crisisPlanAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get crisisPlanAdd;

  /// No description provided for @crisisPlanAdd2.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get crisisPlanAdd2;

  /// No description provided for @crisisPlanOptionalAddOnCrisisPlan.
  ///
  /// In en, this message translates to:
  /// **'Optional add-on · Crisis plan'**
  String get crisisPlanOptionalAddOnCrisisPlan;

  /// No description provided for @crisisPlanEarlyWarningSigns.
  ///
  /// In en, this message translates to:
  /// **'Early warning signs'**
  String get crisisPlanEarlyWarningSigns;

  /// No description provided for @crisisPlanTriggersToWatchFor.
  ///
  /// In en, this message translates to:
  /// **'Triggers to watch for'**
  String get crisisPlanTriggersToWatchFor;

  /// No description provided for @crisisPlanThingsThatGenuinelyHelp.
  ///
  /// In en, this message translates to:
  /// **'Things that genuinely help'**
  String get crisisPlanThingsThatGenuinelyHelp;

  /// No description provided for @crisisPlanThingsToSayToMe.
  ///
  /// In en, this message translates to:
  /// **'Things to say to me'**
  String get crisisPlanThingsToSayToMe;

  /// No description provided for @crisisPlanDonTDoThese.
  ///
  /// In en, this message translates to:
  /// **'Don\'t do these'**
  String get crisisPlanDonTDoThese;

  /// No description provided for @crisisPlanTypeAShortNote.
  ///
  /// In en, this message translates to:
  /// **'Type a short note'**
  String get crisisPlanTypeAShortNote;

  /// No description provided for @permissionsOverviewPaMhadRequestsSystemPermissions.
  ///
  /// In en, this message translates to:
  /// **'PA MHAD requests system permissions only for features you actively use. Nothing is collected in the background. Each section below explains exactly what a permission unlocks, what the app does with the result, and what it never does.'**
  String get permissionsOverviewPaMhadRequestsSystemPermissions;

  /// No description provided for @permissionsOverviewWhatThisAppMayAsk.
  ///
  /// In en, this message translates to:
  /// **'What this app may ask for'**
  String get permissionsOverviewWhatThisAppMayAsk;

  /// No description provided for @permissionsOverviewBiometricsPasscode.
  ///
  /// In en, this message translates to:
  /// **'Biometrics / passcode'**
  String get permissionsOverviewBiometricsPasscode;

  /// No description provided for @permissionsOverviewNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permissionsOverviewNotifications;

  /// No description provided for @permissionsOverviewCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get permissionsOverviewCamera;

  /// No description provided for @permissionsOverviewMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get permissionsOverviewMicrophone;

  /// No description provided for @permissionsOverviewContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get permissionsOverviewContacts;

  /// No description provided for @makeItFindableADirectiveOnlyHelpsIf.
  ///
  /// In en, this message translates to:
  /// **'A directive only helps if the people treating you can find it when you cannot speak for yourself. Take a few minutes now to put copies where they will be looked for.'**
  String get makeItFindableADirectiveOnlyHelpsIf;

  /// No description provided for @makeItFindableThisIsGeneralInformationAbout.
  ///
  /// In en, this message translates to:
  /// **'This is general information about keeping your directive accessible, not legal advice.'**
  String get makeItFindableThisIsGeneralInformationAbout;

  /// No description provided for @makeItFindableCrisisReadiness.
  ///
  /// In en, this message translates to:
  /// **'Crisis readiness'**
  String get makeItFindableCrisisReadiness;

  /// No description provided for @makeItFindableDoTheseNow.
  ///
  /// In en, this message translates to:
  /// **'Do these now'**
  String get makeItFindableDoTheseNow;

  /// No description provided for @makeItFindableShareItWithYourAgent.
  ///
  /// In en, this message translates to:
  /// **'Share it with your agent and a trusted person'**
  String get makeItFindableShareItWithYourAgent;

  /// No description provided for @makeItFindableTheyShouldEachHaveA.
  ///
  /// In en, this message translates to:
  /// **'They should each have a copy before any crisis — not only you.'**
  String get makeItFindableTheyShouldEachHaveA;

  /// No description provided for @makeItFindableGiveACopyToYour.
  ///
  /// In en, this message translates to:
  /// **'Give a copy to your care team'**
  String get makeItFindableGiveACopyToYour;

  /// No description provided for @makeItFindableAskYourPsychiatristTherapistPrimary.
  ///
  /// In en, this message translates to:
  /// **'Ask your psychiatrist, therapist, primary-care doctor, and any facility to add it to your medical record.'**
  String get makeItFindableAskYourPsychiatristTherapistPrimary;

  /// No description provided for @makeItFindablePrintAndCarryTheWallet.
  ///
  /// In en, this message translates to:
  /// **'Print and carry the wallet card'**
  String get makeItFindablePrintAndCarryTheWallet;

  /// No description provided for @makeItFindableAPocketCardThatTells.
  ///
  /// In en, this message translates to:
  /// **'A pocket card that tells responders you have a directive and how to reach your agent.'**
  String get makeItFindableAPocketCardThatTells;

  /// No description provided for @adminUpdateFederalRegisterRelevantFederalRules.
  ///
  /// In en, this message translates to:
  /// **'Federal Register — relevant federal rules'**
  String get adminUpdateFederalRegisterRelevantFederalRules;

  /// No description provided for @adminUpdateFederalRulesTheAppReferences.
  ///
  /// In en, this message translates to:
  /// **'Federal rules the app references. Use a link as the SOURCE for a verify-tier legal/dated change. State law (PA Act 194) is not covered here.'**
  String get adminUpdateFederalRulesTheAppReferences;

  /// No description provided for @adminUpdateOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get adminUpdateOpen;

  /// No description provided for @adminUpdateSourceLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Source link copied'**
  String get adminUpdateSourceLinkCopied;

  /// No description provided for @adminUpdateCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get adminUpdateCopyLink;

  /// No description provided for @adminUpdateRestoreFromWhichBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from which backup?'**
  String get adminUpdateRestoreFromWhichBackup;

  /// No description provided for @adminUpdateAdminDataUpdate.
  ///
  /// In en, this message translates to:
  /// **'Admin · data update'**
  String get adminUpdateAdminDataUpdate;

  /// No description provided for @adminUpdateEnterTheAdminPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Enter the admin passphrase.'**
  String get adminUpdateEnterTheAdminPassphrase;

  /// No description provided for @adminUpdateUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get adminUpdateUnlock;

  /// No description provided for @adminUpdateDescribeTheUpdateTheAi.
  ///
  /// In en, this message translates to:
  /// **'Describe the update. The AI drafts changes to the selected file with sources; you review and approve before anything is emitted. Legal/statutory and educational changes always need your explicit sign-off.'**
  String get adminUpdateDescribeTheUpdateTheAi;

  /// No description provided for @adminUpdateRevert.
  ///
  /// In en, this message translates to:
  /// **'Revert'**
  String get adminUpdateRevert;

  /// No description provided for @adminUpdateCheckBestGeminiModel.
  ///
  /// In en, this message translates to:
  /// **'Check best Gemini model'**
  String get adminUpdateCheckBestGeminiModel;

  /// No description provided for @adminUpdateCheckFederalRegister.
  ///
  /// In en, this message translates to:
  /// **'Check Federal Register'**
  String get adminUpdateCheckFederalRegister;

  /// No description provided for @adminUpdateCopiedUpdatedJson.
  ///
  /// In en, this message translates to:
  /// **'Copied updated JSON'**
  String get adminUpdateCopiedUpdatedJson;

  /// No description provided for @adminUpdateCopyJson.
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get adminUpdateCopyJson;

  /// No description provided for @adminUpdateAnotherUpdate.
  ///
  /// In en, this message translates to:
  /// **'Another update'**
  String get adminUpdateAnotherUpdate;

  /// No description provided for @adminUpdatePassphrase.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get adminUpdatePassphrase;

  /// No description provided for @adminUpdateWhatToUpdate.
  ///
  /// In en, this message translates to:
  /// **'What to update'**
  String get adminUpdateWhatToUpdate;

  /// No description provided for @adminUpdateAiProvider.
  ///
  /// In en, this message translates to:
  /// **'AI provider'**
  String get adminUpdateAiProvider;

  /// No description provided for @adminUpdateModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get adminUpdateModel;

  /// No description provided for @adminUpdateDescribeTheUpdate.
  ///
  /// In en, this message translates to:
  /// **'Describe the update *'**
  String get adminUpdateDescribeTheUpdate;

  /// No description provided for @adminUpdateEGTheTrevorProject.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"The Trevor Project number changed to ...\" or \"Check Gemini\'s current free-tier rate limits\"'**
  String get adminUpdateEGTheTrevorProject;

  /// No description provided for @adminUpdateRequiredWhatShouldTheAi.
  ///
  /// In en, this message translates to:
  /// **'Required — what should the AI draft a change to?'**
  String get adminUpdateRequiredWhatShouldTheAi;

  /// No description provided for @adminUpdateFocusAreaPathOptional.
  ///
  /// In en, this message translates to:
  /// **'Focus area / path (optional)'**
  String get adminUpdateFocusAreaPathOptional;

  /// No description provided for @adminUpdateRestrictTheAiToOne.
  ///
  /// In en, this message translates to:
  /// **'Restrict the AI to one spot, e.g. \"config.timeoutsSeconds\" or \"sections.faq_valid\".'**
  String get adminUpdateRestrictTheAiToOne;

  /// No description provided for @reminderSheetsQuickRenew5Min.
  ///
  /// In en, this message translates to:
  /// **'Quick renew · ~5 min'**
  String get reminderSheetsQuickRenew5Min;

  /// No description provided for @reminderSheetsMostPeopleKeepTheSame.
  ///
  /// In en, this message translates to:
  /// **'Most people keep the same answers. We\'ll pre-fill all 11 sections from your current directive — tap any card to change it, then print and sign the new copy in ink with two witnesses.'**
  String get reminderSheetsMostPeopleKeepTheSame;

  /// No description provided for @reminderSheetsStartQuickRenew.
  ///
  /// In en, this message translates to:
  /// **'Start quick renew'**
  String get reminderSheetsStartQuickRenew;

  /// No description provided for @reminderSheetsRemindMeNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Remind me next week'**
  String get reminderSheetsRemindMeNextWeek;

  /// No description provided for @reminderSheetsWeLlRemindYouAgain.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you again 7 days before expiration.'**
  String get reminderSheetsWeLlRemindYouAgain;

  /// No description provided for @reminderSheetsAnythingChanged.
  ///
  /// In en, this message translates to:
  /// **'Anything changed?'**
  String get reminderSheetsAnythingChanged;

  /// No description provided for @reminderSheetsStillAccurateAllGood.
  ///
  /// In en, this message translates to:
  /// **'Still accurate — all good'**
  String get reminderSheetsStillAccurateAllGood;

  /// No description provided for @reminderSheetsEditMyDirective.
  ///
  /// In en, this message translates to:
  /// **'Edit my directive'**
  String get reminderSheetsEditMyDirective;

  /// No description provided for @reminderSheetsIfYouEditAnythingYou.
  ///
  /// In en, this message translates to:
  /// **'If you edit anything, you\'ll re-print and sign that updated copy in ink. Small changes can wait for your 2-year renewal.'**
  String get reminderSheetsIfYouEditAnythingYou;

  /// No description provided for @reminderSheets3MonthCheckIn.
  ///
  /// In en, this message translates to:
  /// **'● 3-month check-in'**
  String get reminderSheets3MonthCheckIn;

  /// No description provided for @reminderSheetsCommonThingsThatChange.
  ///
  /// In en, this message translates to:
  /// **'Common things that change'**
  String get reminderSheetsCommonThingsThatChange;

  /// No description provided for @reminderSheetsStillTheRightPeople.
  ///
  /// In en, this message translates to:
  /// **'Still the right people?'**
  String get reminderSheetsStillTheRightPeople;

  /// No description provided for @reminderSheetsMedicationsUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Medications up to date?'**
  String get reminderSheetsMedicationsUpToDate;

  /// No description provided for @reminderSheetsCarePreferencesStillRight.
  ///
  /// In en, this message translates to:
  /// **'Care preferences still right?'**
  String get reminderSheetsCarePreferencesStillRight;

  /// No description provided for @reminderSheetsPaDirectivesExpireAfter2.
  ///
  /// In en, this message translates to:
  /// **'PA directives expire after 2 years. Yours runs out on '**
  String get reminderSheetsPaDirectivesExpireAfter2;

  /// No description provided for @reminderSheetsIfYouAreIncapableOf.
  ///
  /// In en, this message translates to:
  /// **'. (If you are incapable of making mental health decisions when it would expire, it stays in effect until your capacity returns.)'**
  String get reminderSheetsIfYouAreIncapableOf;

  /// No description provided for @reminderSheetsYourDirectiveIsStillValid.
  ///
  /// In en, this message translates to:
  /// **'Your directive is still valid through '**
  String get reminderSheetsYourDirectiveIsStillValid;

  /// No description provided for @reminderSheetsNoSigningNeededJustA.
  ///
  /// In en, this message translates to:
  /// **' — no signing needed. Just a quick gut-check that it still fits your life.'**
  String get reminderSheetsNoSigningNeededJustA;

  /// No description provided for @revocationMarkedRevokedOnThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Marked revoked on this device'**
  String get revocationMarkedRevokedOnThisDevice;

  /// No description provided for @revocationPer20PaCS.
  ///
  /// In en, this message translates to:
  /// **'Per 20 Pa.C.S. §§ 5825 and 5839, revocation is effective only when communicated to your attending physician or provider. Marking this directive revoked here does not communicate it — you still need to tell each recipient.'**
  String get revocationPer20PaCS;

  /// No description provided for @revocationYouPickedTheseRecipientsTo.
  ///
  /// In en, this message translates to:
  /// **'You picked these recipients to notify:'**
  String get revocationYouPickedTheseRecipientsTo;

  /// No description provided for @revocationContactEachRecipientYourselfCall.
  ///
  /// In en, this message translates to:
  /// **'Contact each recipient yourself — call or email them — and ask the receiving provider to record the revocation in your chart. Revocation takes effect once your provider has been told.'**
  String get revocationContactEachRecipientYourselfCall;

  /// No description provided for @revocationYourDirectiveWillNoLonger.
  ///
  /// In en, this message translates to:
  /// **'Your directive will no longer be legally binding once you communicate the revocation to your attending physician or provider (20 Pa.C.S. §§ 5825, 5839). This app marks the directive revoked locally and helps you generate a revocation letter.'**
  String get revocationYourDirectiveWillNoLonger;

  /// No description provided for @revocationThisDeclarationMayBeRevoked.
  ///
  /// In en, this message translates to:
  /// **'This declaration may be revoked in whole or in part at any time, either orally or in writing, as long as I have not been found to be incapable of making mental health decisions. My revocation will be effective upon communication to my attending physician or other mental health care provider, either by me or a witness to my revocation, of the intent to revoke.'**
  String get revocationThisDeclarationMayBeRevoked;

  /// No description provided for @revocationNoBatchSendsPickEach.
  ///
  /// In en, this message translates to:
  /// **'No batch sends — pick each recipient. The app keeps your choices in front of you as a checklist; you contact each recipient yourself (call, email, or in person).'**
  String get revocationNoBatchSendsPickEach;

  /// No description provided for @revocationTypeRevokeToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type REVOKE to confirm'**
  String get revocationTypeRevokeToConfirm;

  /// No description provided for @revocationHowRevocationWorksInPa.
  ///
  /// In en, this message translates to:
  /// **'How revocation works in PA'**
  String get revocationHowRevocationWorksInPa;

  /// No description provided for @revocationStatutoryRevocationStatement.
  ///
  /// In en, this message translates to:
  /// **'Statutory revocation statement'**
  String get revocationStatutoryRevocationStatement;

  /// No description provided for @revocationWhoToNotifyOptIn.
  ///
  /// In en, this message translates to:
  /// **'Who to notify (opt-in per recipient)'**
  String get revocationWhoToNotifyOptIn;

  /// No description provided for @revocationPermanentAction.
  ///
  /// In en, this message translates to:
  /// **'Permanent action'**
  String get revocationPermanentAction;

  /// No description provided for @revocationRevoke.
  ///
  /// In en, this message translates to:
  /// **'REVOKE'**
  String get revocationRevoke;

  /// No description provided for @pastDirectiveDetailDeleteFromThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Delete from this device?'**
  String get pastDirectiveDetailDeleteFromThisDevice;

  /// No description provided for @pastDirectiveDetailThisRemovesTheSavedDirective.
  ///
  /// In en, this message translates to:
  /// **'This removes the saved directive from this device. The legal effect of any previously-signed paper copy is unchanged. This cannot be undone.'**
  String get pastDirectiveDetailThisRemovesTheSavedDirective;

  /// No description provided for @pastDirectiveDetailDirectiveDeletedFromThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Directive deleted from this device.'**
  String get pastDirectiveDetailDirectiveDeletedFromThisDevice;

  /// No description provided for @pastDirectiveDetailNoShareLogEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No share log entries yet.'**
  String get pastDirectiveDetailNoShareLogEntriesYet;

  /// No description provided for @pastDirectiveDetailWeDonTTrackDelivery.
  ///
  /// In en, this message translates to:
  /// **'We don\'t track delivery or receipt confirmation (that would need a server). Add entries manually as you distribute copies.'**
  String get pastDirectiveDetailWeDonTTrackDelivery;

  /// No description provided for @pastDirectiveDetailGeneratedOnDemand6Pages.
  ///
  /// In en, this message translates to:
  /// **'Generated on demand · ~6 pages'**
  String get pastDirectiveDetailGeneratedOnDemand6Pages;

  /// No description provided for @pastDirectiveDetailWhoHadACopy.
  ///
  /// In en, this message translates to:
  /// **'Who had a copy'**
  String get pastDirectiveDetailWhoHadACopy;

  /// No description provided for @pastDirectiveDetailActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get pastDirectiveDetailActions;

  /// No description provided for @pastDirectiveDetailLoadingThisDirective.
  ///
  /// In en, this message translates to:
  /// **'Loading this directive'**
  String get pastDirectiveDetailLoadingThisDirective;

  /// No description provided for @pastDirectiveDetailCopyToANewDirective.
  ///
  /// In en, this message translates to:
  /// **'Copy to a new directive'**
  String get pastDirectiveDetailCopyToANewDirective;

  /// No description provided for @pastDirectiveDetailStartWithTheseAnswersComing.
  ///
  /// In en, this message translates to:
  /// **'Start with these answers — coming with the renewal flow'**
  String get pastDirectiveDetailStartWithTheseAnswersComing;

  /// No description provided for @pastDirectiveDetailOpenThePdf.
  ///
  /// In en, this message translates to:
  /// **'Open the PDF'**
  String get pastDirectiveDetailOpenThePdf;

  /// No description provided for @pastDirectiveDetailPrintOrSaveForYour.
  ///
  /// In en, this message translates to:
  /// **'Print or save for your records'**
  String get pastDirectiveDetailPrintOrSaveForYour;

  /// No description provided for @pastDirectiveDetailDeleteFromThisDevice2.
  ///
  /// In en, this message translates to:
  /// **'Delete from this device'**
  String get pastDirectiveDetailDeleteFromThisDevice2;

  /// No description provided for @pastDirectiveDetailSignedBy.
  ///
  /// In en, this message translates to:
  /// **'SIGNED BY'**
  String get pastDirectiveDetailSignedBy;

  /// No description provided for @pastDirectiveDetailWitness1.
  ///
  /// In en, this message translates to:
  /// **'WITNESS 1'**
  String get pastDirectiveDetailWitness1;

  /// No description provided for @pastDirectiveDetailWitness2.
  ///
  /// In en, this message translates to:
  /// **'WITNESS 2'**
  String get pastDirectiveDetailWitness2;

  /// No description provided for @pastDirectiveDetailDirective.
  ///
  /// In en, this message translates to:
  /// **'Directive · '**
  String get pastDirectiveDetailDirective;

  /// No description provided for @pinDialogCreatePasscode.
  ///
  /// In en, this message translates to:
  /// **'Create Passcode'**
  String get pinDialogCreatePasscode;

  /// No description provided for @pinDialogBiometricAuthenticationIsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available on this device. Create a passcode to protect your private data.'**
  String get pinDialogBiometricAuthenticationIsNotAvailable;

  /// No description provided for @pinDialogCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get pinDialogCreate;

  /// No description provided for @pinDialogPaMhad.
  ///
  /// In en, this message translates to:
  /// **'PA MHAD'**
  String get pinDialogPaMhad;

  /// No description provided for @pinDialogPrivateModeLocked.
  ///
  /// In en, this message translates to:
  /// **'PRIVATE MODE · LOCKED'**
  String get pinDialogPrivateModeLocked;

  /// No description provided for @pinDialogEnterYourPasscodeToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Enter your passcode to unlock private mode.'**
  String get pinDialogEnterYourPasscodeToUnlock;

  /// No description provided for @pinDialogSwitchToPublicMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to public mode'**
  String get pinDialogSwitchToPublicMode;

  /// No description provided for @pinDialogPasscode.
  ///
  /// In en, this message translates to:
  /// **'Passcode'**
  String get pinDialogPasscode;

  /// No description provided for @pinDialogAtLeast4Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 4 characters'**
  String get pinDialogAtLeast4Characters;

  /// No description provided for @pinDialogConfirmPasscode.
  ///
  /// In en, this message translates to:
  /// **'Confirm Passcode'**
  String get pinDialogConfirmPasscode;

  /// No description provided for @pinDialogUseYour.
  ///
  /// In en, this message translates to:
  /// **'Use your '**
  String get pinDialogUseYour;

  /// No description provided for @pinDialogPasscode2.
  ///
  /// In en, this message translates to:
  /// **'passcode.'**
  String get pinDialogPasscode2;

  /// No description provided for @modeSelectionAuthenticationFailedOrWasCancelled.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed or was cancelled. Please try again.'**
  String get modeSelectionAuthenticationFailedOrWasCancelled;

  /// No description provided for @modeSelectionHowShouldWeHandleYour.
  ///
  /// In en, this message translates to:
  /// **'How should we handle your data?'**
  String get modeSelectionHowShouldWeHandleYour;

  /// No description provided for @modeSelectionYouCanChangeThisAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Settings.'**
  String get modeSelectionYouCanChangeThisAnytime;

  /// No description provided for @modeSelectionRecommended.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED'**
  String get modeSelectionRecommended;

  /// No description provided for @modeSelectionPrivacySetup.
  ///
  /// In en, this message translates to:
  /// **'Privacy · setup'**
  String get modeSelectionPrivacySetup;

  /// No description provided for @modeSelectionPrivateMode.
  ///
  /// In en, this message translates to:
  /// **'Private mode'**
  String get modeSelectionPrivateMode;

  /// No description provided for @modeSelectionYourDataStaysOnThis.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this device, encrypted. Unlock with biometrics or a passcode. You can come back to your draft anytime.'**
  String get modeSelectionYourDataStaysOnThis;

  /// No description provided for @modeSelectionPublicMode.
  ///
  /// In en, this message translates to:
  /// **'Public mode'**
  String get modeSelectionPublicMode;

  /// No description provided for @modeSelectionNoDataIsSavedAfter.
  ///
  /// In en, this message translates to:
  /// **'No data is saved after you close the app. Best for shared devices, or one-time use without leaving a trace.'**
  String get modeSelectionNoDataIsSavedAfter;

  /// No description provided for @sideEffectsForTheMedicationsYouRe.
  ///
  /// In en, this message translates to:
  /// **'For the medications you\'re currently taking, here are common side effects — check the ones you actually have. Noting them (especially any that affect your daily activities) helps your care team. This is common-side-effect information, not medical advice.'**
  String get sideEffectsForTheMedicationsYouRe;

  /// No description provided for @sideEffectsSetUpAiToCheck.
  ///
  /// In en, this message translates to:
  /// **'Set up AI to check side effects'**
  String get sideEffectsSetUpAiToCheck;

  /// No description provided for @sideEffectsThisUsesYourAiAssistant.
  ///
  /// In en, this message translates to:
  /// **'This uses your AI assistant to list common side effects of your current medications for you to review.'**
  String get sideEffectsThisUsesYourAiAssistant;

  /// No description provided for @sideEffectsWorthDiscussingWithYourDoctor.
  ///
  /// In en, this message translates to:
  /// **'Worth discussing with your doctor'**
  String get sideEffectsWorthDiscussingWithYourDoctor;

  /// No description provided for @sideEffectsOptionalAddOn.
  ///
  /// In en, this message translates to:
  /// **'Optional add-on'**
  String get sideEffectsOptionalAddOn;

  /// No description provided for @sideEffectsAskYourDoctorOrPharmacist.
  ///
  /// In en, this message translates to:
  /// **'Ask your doctor or pharmacist'**
  String get sideEffectsAskYourDoctorOrPharmacist;

  /// No description provided for @educationCategoryBrowserNoSectionsInThisCategory.
  ///
  /// In en, this message translates to:
  /// **'No sections in this category yet.'**
  String get educationCategoryBrowserNoSectionsInThisCategory;

  /// No description provided for @educationMostOfThisComesStraight.
  ///
  /// In en, this message translates to:
  /// **'Most of this comes straight from the official PA MHAD booklet, plus a few plain-language explainers. No marketing, no opinions — just the rules and what they mean.'**
  String get educationMostOfThisComesStraight;

  /// No description provided for @educationSearchArticlesGlossaryFaqs.
  ///
  /// In en, this message translates to:
  /// **'Search articles, glossary, FAQs…'**
  String get educationSearchArticlesGlossaryFaqs;

  /// No description provided for @educationYourDirectiveIsYourVoice.
  ///
  /// In en, this message translates to:
  /// **'\"Your directive is your voice — written in advance, kept safe, honored when you can\'t speak for yourself.\"'**
  String get educationYourDirectiveIsYourVoice;

  /// No description provided for @educationPaOfficeOfMentalHealth.
  ///
  /// In en, this message translates to:
  /// **'— PA OFFICE OF MENTAL HEALTH & SUBSTANCE ABUSE SERVICES · BOOKLET P.3'**
  String get educationPaOfficeOfMentalHealth;

  /// No description provided for @educationTypeToSearchEducationalContent.
  ///
  /// In en, this message translates to:
  /// **'Type to search educational content...'**
  String get educationTypeToSearchEducationalContent;

  /// No description provided for @educationBrowseAllTopics.
  ///
  /// In en, this message translates to:
  /// **'Browse all topics'**
  String get educationBrowseAllTopics;

  /// No description provided for @educationUnderstand.
  ///
  /// In en, this message translates to:
  /// **'Understand '**
  String get educationUnderstand;

  /// No description provided for @educationYouSign.
  ///
  /// In en, this message translates to:
  /// **' you sign.'**
  String get educationYouSign;

  /// No description provided for @learnAiPanelAskTheAi.
  ///
  /// In en, this message translates to:
  /// **'Ask the AI'**
  String get learnAiPanelAskTheAi;

  /// No description provided for @learnAiPanelSetUpAiAssistant.
  ///
  /// In en, this message translates to:
  /// **'Set up AI assistant'**
  String get learnAiPanelSetUpAiAssistant;

  /// No description provided for @learnAiPanelNotLegalOrMedicalAdvice.
  ///
  /// In en, this message translates to:
  /// **'Not legal or medical advice.'**
  String get learnAiPanelNotLegalOrMedicalAdvice;

  /// No description provided for @learnAiPanelAskAQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a question…'**
  String get learnAiPanelAskAQuestion;

  /// No description provided for @educationArticleDetailTryIt.
  ///
  /// In en, this message translates to:
  /// **'TRY IT'**
  String get educationArticleDetailTryIt;

  /// No description provided for @educationArticleDetailReadyToWriteYours.
  ///
  /// In en, this message translates to:
  /// **'Ready to write yours?'**
  String get educationArticleDetailReadyToWriteYours;

  /// No description provided for @educationArticleDetailTheGuidedWizardTakesAbout.
  ///
  /// In en, this message translates to:
  /// **'The guided wizard takes about 20 minutes and works anonymously.'**
  String get educationArticleDetailTheGuidedWizardTakesAbout;

  /// No description provided for @educationArticleDetailStartMyDirective.
  ///
  /// In en, this message translates to:
  /// **'Start my directive'**
  String get educationArticleDetailStartMyDirective;

  /// No description provided for @audioGuideCouldnTOpenTheQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the questionnaire to print. Please try again.'**
  String get audioGuideCouldnTOpenTheQuestionnaire;

  /// No description provided for @audioGuideRecordYourWishesByVoice.
  ///
  /// In en, this message translates to:
  /// **'Record your wishes by voice'**
  String get audioGuideRecordYourWishesByVoice;

  /// No description provided for @audioGuideDescribeYourWishesOutLoud.
  ///
  /// In en, this message translates to:
  /// **'Describe your wishes out loud, upload the recording on the Snap-to-fill screen, and the AI fills your directive — you review every field before anything is saved.'**
  String get audioGuideDescribeYourWishesOutLoud;

  /// No description provided for @audioGuidePrintTheQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Print the questionnaire'**
  String get audioGuidePrintTheQuestionnaire;

  /// No description provided for @audioGuidePrintItToReadAloud.
  ///
  /// In en, this message translates to:
  /// **'Print it to read aloud while you record, or to fill in by hand first.'**
  String get audioGuidePrintItToReadAloud;

  /// No description provided for @audioGuidePrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get audioGuidePrint;

  /// No description provided for @audioGuideSetTheseInTheApp.
  ///
  /// In en, this message translates to:
  /// **'Set these in the app:'**
  String get audioGuideSetTheseInTheApp;

  /// No description provided for @audioGuideWorthSayingOutLoudAutofill.
  ///
  /// In en, this message translates to:
  /// **'Worth saying out loud — autofill now captures these:'**
  String get audioGuideWorthSayingOutLoudAutofill;

  /// No description provided for @audioGuideHowToRecord.
  ///
  /// In en, this message translates to:
  /// **'How to record'**
  String get audioGuideHowToRecord;

  /// No description provided for @audioGuideWhatTheRecordingCanT.
  ///
  /// In en, this message translates to:
  /// **'What the recording can\'t fill'**
  String get audioGuideWhatTheRecordingCanT;

  /// No description provided for @ulyssesClauseBeforeYouAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'Before you acknowledge'**
  String get ulyssesClauseBeforeYouAcknowledge;

  /// No description provided for @ulyssesClauseThisIsASignificantDecision.
  ///
  /// In en, this message translates to:
  /// **'This is a significant decision. Once you are found incapable, the directive cannot be revoked by you until capacity returns. We strongly recommend talking it through with a peer specialist or your clinician before saving.'**
  String get ulyssesClauseThisIsASignificantDecision;

  /// No description provided for @ulyssesClauseIUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get ulyssesClauseIUnderstand;

  /// No description provided for @ulyssesClauseSometimesDuringACrisisPeople.
  ///
  /// In en, this message translates to:
  /// **'Sometimes during a crisis, people refuse treatment that they\'d want when well. PA law honors what you wrote today, even if you protest in the moment.'**
  String get ulyssesClauseSometimesDuringACrisisPeople;

  /// No description provided for @ulyssesClauseSelfBindingUlysses.
  ///
  /// In en, this message translates to:
  /// **'SELF-BINDING (\"Ulysses\")'**
  String get ulyssesClauseSelfBindingUlysses;

  /// No description provided for @ulyssesClauseTieMyselfToTheMast.
  ///
  /// In en, this message translates to:
  /// **'Tie myself to the mast.'**
  String get ulyssesClauseTieMyselfToTheMast;

  /// No description provided for @ulyssesClausePerPaAct19420.
  ///
  /// In en, this message translates to:
  /// **'Per PA Act 194 (20 Pa.C.S. §§ 5825, 5839), this directive may be revoked only while I have capacity. Once I\'m found incapable, what I wrote here stands — even over my in-the-moment protest — until capacity returns.'**
  String get ulyssesClausePerPaAct19420;

  /// No description provided for @ulyssesClauseIAcknowledgeThis.
  ///
  /// In en, this message translates to:
  /// **'I acknowledge this'**
  String get ulyssesClauseIAcknowledgeThis;

  /// No description provided for @ulyssesClauseRecordedInYourDirectivePdf.
  ///
  /// In en, this message translates to:
  /// **'Recorded in your directive PDF.'**
  String get ulyssesClauseRecordedInYourDirectivePdf;

  /// No description provided for @ulyssesClauseBoundariesOnThisClause.
  ///
  /// In en, this message translates to:
  /// **'Boundaries on this clause'**
  String get ulyssesClauseBoundariesOnThisClause;

  /// No description provided for @exportCardsBeforeSharingEnsureThisDirective.
  ///
  /// In en, this message translates to:
  /// **'Before sharing: ensure this directive has been signed, dated, and witnessed by two adults (18+) as required by PA Act 194. Give copies to your agent, physician, and support people.'**
  String get exportCardsBeforeSharingEnsureThisDirective;

  /// No description provided for @exportCardsPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get exportCardsPrincipal;

  /// No description provided for @exportCardsTheExportedPdfIsNot.
  ///
  /// In en, this message translates to:
  /// **'The exported PDF is not encrypted. Share only via channels you trust.'**
  String get exportCardsTheExportedPdfIsNot;

  /// No description provided for @exportCardsImportantBeforeSharingEnsureThis.
  ///
  /// In en, this message translates to:
  /// **'Important: Before sharing, ensure this directive has been signed, dated, and witnessed by two adults as required by PA Act 194. Give copies to your agent, physician, and support people.'**
  String get exportCardsImportantBeforeSharingEnsureThis;

  /// No description provided for @pdfPreviewUsLetter8511.
  ///
  /// In en, this message translates to:
  /// **'US LETTER · 8.5×11\"'**
  String get pdfPreviewUsLetter8511;

  /// No description provided for @pdfPreviewShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get pdfPreviewShare;

  /// No description provided for @pdfPreviewSizedForUsLetter8.
  ///
  /// In en, this message translates to:
  /// **'Sized for US Letter (8.5 × 11″) with 1-inch margins. The preview fills the width — use − / + to zoom.'**
  String get pdfPreviewSizedForUsLetter8;

  /// No description provided for @pdfPreviewPages.
  ///
  /// In en, this message translates to:
  /// **'PAGES'**
  String get pdfPreviewPages;

  /// No description provided for @pdfPreviewExportShare.
  ///
  /// In en, this message translates to:
  /// **'Export & share'**
  String get pdfPreviewExportShare;

  /// No description provided for @pdfPreviewClosePreview.
  ///
  /// In en, this message translates to:
  /// **'Close preview'**
  String get pdfPreviewClosePreview;

  /// No description provided for @pdfPreviewRenderingPdfPreview.
  ///
  /// In en, this message translates to:
  /// **'Rendering PDF preview'**
  String get pdfPreviewRenderingPdfPreview;

  /// No description provided for @pdfPreviewFitPageToWindow.
  ///
  /// In en, this message translates to:
  /// **'Fit page to window'**
  String get pdfPreviewFitPageToWindow;

  /// No description provided for @pdfPreviewYourDirective.
  ///
  /// In en, this message translates to:
  /// **'Your directive, '**
  String get pdfPreviewYourDirective;

  /// No description provided for @pdfPreviewOnPaper.
  ///
  /// In en, this message translates to:
  /// **'on paper.'**
  String get pdfPreviewOnPaper;

  /// No description provided for @exportSelectAtLeastOneSection.
  ///
  /// In en, this message translates to:
  /// **'Select at least one section to include.'**
  String get exportSelectAtLeastOneSection;

  /// No description provided for @exportIncompleteDirective.
  ///
  /// In en, this message translates to:
  /// **'Incomplete Directive'**
  String get exportIncompleteDirective;

  /// No description provided for @exportGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get exportGoBack;

  /// No description provided for @exportEditDirective.
  ///
  /// In en, this message translates to:
  /// **'Edit Directive'**
  String get exportEditDirective;

  /// No description provided for @exportExportAnyway.
  ///
  /// In en, this message translates to:
  /// **'Export Anyway'**
  String get exportExportAnyway;

  /// No description provided for @exportExportedFileIsNotEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Exported file is not encrypted'**
  String get exportExportedFileIsNotEncrypted;

  /// No description provided for @exportThePdfYouAreAbout.
  ///
  /// In en, this message translates to:
  /// **'The PDF you are about to share contains your full mental-health directive (names, agents, medications, signatures). It is generated unencrypted because the underlying PDF library does not support password protection.\n\nShare only via channels you trust (e.g., direct hand-off, a secure email to a specific provider). Avoid public uploads, cloud links, or untrusted messaging apps.'**
  String get exportThePdfYouAreAbout;

  /// No description provided for @exportIUnderstandContinue.
  ///
  /// In en, this message translates to:
  /// **'I understand, continue'**
  String get exportIUnderstandContinue;

  /// No description provided for @exportCouldnTGenerateThePdf.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t generate the PDF.'**
  String get exportCouldnTGenerateThePdf;

  /// No description provided for @exportSelectAtLeastOneSection2.
  ///
  /// In en, this message translates to:
  /// **'Select at least one section to preview.'**
  String get exportSelectAtLeastOneSection2;

  /// No description provided for @exportNothingToDownloadYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing to download yet'**
  String get exportNothingToDownloadYet;

  /// No description provided for @exportStartADirectiveFirstThen.
  ///
  /// In en, this message translates to:
  /// **'Start a directive first — then come back here to preview, download, and print it.'**
  String get exportStartADirectiveFirstThen;

  /// No description provided for @exportSelectFormsToInclude.
  ///
  /// In en, this message translates to:
  /// **'Select forms to include:'**
  String get exportSelectFormsToInclude;

  /// No description provided for @exportAdditionalPages.
  ///
  /// In en, this message translates to:
  /// **'Additional Pages:'**
  String get exportAdditionalPages;

  /// No description provided for @exportPrintABlankFormFill.
  ///
  /// In en, this message translates to:
  /// **'Print a blank form (fill in by hand)'**
  String get exportPrintABlankFormFill;

  /// No description provided for @exportPlainSignable.
  ///
  /// In en, this message translates to:
  /// **'Plain (signable)'**
  String get exportPlainSignable;

  /// No description provided for @exportLegalInfoOnly.
  ///
  /// In en, this message translates to:
  /// **'Legal (info only)'**
  String get exportLegalInfoOnly;

  /// No description provided for @exportHeadsUpTheLegalLanguage.
  ///
  /// In en, this message translates to:
  /// **'Heads up: the legal-language version is for reference only. Sign and use the plain-language official form.'**
  String get exportHeadsUpTheLegalLanguage;

  /// No description provided for @exportOpenPdf.
  ///
  /// In en, this message translates to:
  /// **'Open PDF'**
  String get exportOpenPdf;

  /// No description provided for @exportOpenWalletCardPdf.
  ///
  /// In en, this message translates to:
  /// **'Open wallet card (PDF)'**
  String get exportOpenWalletCardPdf;

  /// No description provided for @exportEncryptTheFile.
  ///
  /// In en, this message translates to:
  /// **'Encrypt the file'**
  String get exportEncryptTheFile;

  /// No description provided for @exportDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get exportDownload;

  /// No description provided for @exportFhirJson.
  ///
  /// In en, this message translates to:
  /// **'FHIR JSON'**
  String get exportFhirJson;

  /// No description provided for @exportFhirXml.
  ///
  /// In en, this message translates to:
  /// **'FHIR XML'**
  String get exportFhirXml;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get exportCsv;

  /// No description provided for @exportZipBundle.
  ///
  /// In en, this message translates to:
  /// **'.zip bundle'**
  String get exportZipBundle;

  /// No description provided for @exportDoneBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Done — back to home'**
  String get exportDoneBackToHome;

  /// No description provided for @exportCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard.'**
  String get exportCopiedToClipboard;

  /// No description provided for @exportCouldnTSaveTheFile.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the file. Please try again.'**
  String get exportCouldnTSaveTheFile;

  /// No description provided for @exportExportedYourDirectiveBundlePdf.
  ///
  /// In en, this message translates to:
  /// **'Exported your directive bundle — PDF, JSON, XML and CSV.'**
  String get exportExportedYourDirectiveBundlePdf;

  /// No description provided for @exportCouldNotBuildTheZip.
  ///
  /// In en, this message translates to:
  /// **'Could not build the .zip bundle.'**
  String get exportCouldNotBuildTheZip;

  /// No description provided for @exportCouldnTGenerateTheWallet.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t generate the wallet card. Please try again.'**
  String get exportCouldnTGenerateTheWallet;

  /// No description provided for @exportYourOfficialDirective.
  ///
  /// In en, this message translates to:
  /// **'Your official directive'**
  String get exportYourOfficialDirective;

  /// No description provided for @exportKeepACopy.
  ///
  /// In en, this message translates to:
  /// **'Keep a copy'**
  String get exportKeepACopy;

  /// No description provided for @exportAdvancedDataExports.
  ///
  /// In en, this message translates to:
  /// **'Advanced · data exports'**
  String get exportAdvancedDataExports;

  /// No description provided for @exportDeclarationPowerOfAttorneyMost.
  ///
  /// In en, this message translates to:
  /// **'Declaration + Power of Attorney (most complete)'**
  String get exportDeclarationPowerOfAttorneyMost;

  /// No description provided for @exportTreatmentPreferencesOnlyNoAgent.
  ///
  /// In en, this message translates to:
  /// **'Treatment preferences only (no agent)'**
  String get exportTreatmentPreferencesOnlyNoAgent;

  /// No description provided for @exportAgentAuthorityOnlyNoPersonal.
  ///
  /// In en, this message translates to:
  /// **'Agent authority only (no personal preferences)'**
  String get exportAgentAuthorityOnlyNoPersonal;

  /// No description provided for @exportSupplementaryLegalInformation.
  ///
  /// In en, this message translates to:
  /// **'Supplementary Legal Information'**
  String get exportSupplementaryLegalInformation;

  /// No description provided for @exportAdditionalLegalReferenceInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional legal reference information'**
  String get exportAdditionalLegalReferenceInformation;

  /// No description provided for @exportDistributionChecklistNotes.
  ///
  /// In en, this message translates to:
  /// **'Distribution Checklist & Notes'**
  String get exportDistributionChecklistNotes;

  /// No description provided for @exportBlankPagesForHandwrittenNotes.
  ///
  /// In en, this message translates to:
  /// **'Blank pages for handwritten notes'**
  String get exportBlankPagesForHandwrittenNotes;

  /// No description provided for @exportOpenThePdfDirectiveIn.
  ///
  /// In en, this message translates to:
  /// **'Open the PDF directive in your viewer to print or save it'**
  String get exportOpenThePdfDirectiveIn;

  /// No description provided for @exportDownloadAnEditableCopyOf.
  ///
  /// In en, this message translates to:
  /// **'Download an editable copy of your directive'**
  String get exportDownloadAnEditableCopyOf;

  /// No description provided for @exportExportAsFhirJsonFor.
  ///
  /// In en, this message translates to:
  /// **'Export as FHIR JSON for electronic health records'**
  String get exportExportAsFhirJsonFor;

  /// No description provided for @exportExportAsFhirXmlFor.
  ///
  /// In en, this message translates to:
  /// **'Export as FHIR XML for electronic health records'**
  String get exportExportAsFhirXmlFor;

  /// No description provided for @exportExportAsCsvSpreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV spreadsheet'**
  String get exportExportAsCsvSpreadsheet;

  /// No description provided for @exportDownloadEverythingPdfJsonXml.
  ///
  /// In en, this message translates to:
  /// **'Download everything (PDF, JSON, XML, CSV) as a zip bundle'**
  String get exportDownloadEverythingPdfJsonXml;

  /// No description provided for @exportYourDirective.
  ///
  /// In en, this message translates to:
  /// **'Your directive,\n'**
  String get exportYourDirective;

  /// No description provided for @appThemeWarmTeal.
  ///
  /// In en, this message translates to:
  /// **'Warm Teal'**
  String get appThemeWarmTeal;

  /// No description provided for @appThemeBalancedCalmProfessional.
  ///
  /// In en, this message translates to:
  /// **'Balanced, calm, professional.'**
  String get appThemeBalancedCalmProfessional;

  /// No description provided for @appThemeDeepNavy.
  ///
  /// In en, this message translates to:
  /// **'Deep Navy'**
  String get appThemeDeepNavy;

  /// No description provided for @appThemeFormalSteadyHighContrast.
  ///
  /// In en, this message translates to:
  /// **'Formal, steady, high-contrast.'**
  String get appThemeFormalSteadyHighContrast;

  /// No description provided for @appThemeSageGreen.
  ///
  /// In en, this message translates to:
  /// **'Sage Green'**
  String get appThemeSageGreen;

  /// No description provided for @appThemeSoftNaturalApproachable.
  ///
  /// In en, this message translates to:
  /// **'Soft, natural, approachable.'**
  String get appThemeSoftNaturalApproachable;

  /// No description provided for @aiSetupReplyWithTheSingleWord.
  ///
  /// In en, this message translates to:
  /// **'Reply with the single word: ok'**
  String get aiSetupReplyWithTheSingleWord;

  /// No description provided for @aiSetupRemoveApiKey.
  ///
  /// In en, this message translates to:
  /// **'Remove API Key?'**
  String get aiSetupRemoveApiKey;

  /// No description provided for @aiSetupAiFeaturesWillBeDisabled.
  ///
  /// In en, this message translates to:
  /// **'AI features will be disabled until a new key is added.'**
  String get aiSetupAiFeaturesWillBeDisabled;

  /// No description provided for @aiSetupApiKeyRemoved.
  ///
  /// In en, this message translates to:
  /// **'API key removed'**
  String get aiSetupApiKeyRemoved;

  /// No description provided for @aiSetupAiAssistantSetup.
  ///
  /// In en, this message translates to:
  /// **'AI assistant setup'**
  String get aiSetupAiAssistantSetup;

  /// No description provided for @aiSetupYourApiKeyWillNot.
  ///
  /// In en, this message translates to:
  /// **'Your API key will not be saved permanently. It is kept in memory for this session, with a temporary copy for up to 10 minutes so you can recover it if the app reloads — then discarded when you close the app or clear your data.'**
  String get aiSetupYourApiKeyWillNot;

  /// No description provided for @aiSetupStep1OpenAPrivate.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Open a Private/Incognito Window'**
  String get aiSetupStep1OpenAPrivate;

  /// No description provided for @aiSetupYouLlNeedToSign.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign into your Google account to get an API key. To protect your login on shared or public devices, open a private browsing window first:'**
  String get aiSetupYouLlNeedToSign;

  /// No description provided for @aiSetupOnAPhoneTapThe.
  ///
  /// In en, this message translates to:
  /// **'On a phone: tap the menu (⋮ or ⋯) and select \"New Incognito Tab\" or \"New Private Tab\".'**
  String get aiSetupOnAPhoneTapThe;

  /// No description provided for @aiSetupYourGoogleLoginWillBe.
  ///
  /// In en, this message translates to:
  /// **'Your Google login will be automatically forgotten when you close the private window.'**
  String get aiSetupYourGoogleLoginWillBe;

  /// No description provided for @aiSetupPrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'Privacy Notice'**
  String get aiSetupPrivacyNotice;

  /// No description provided for @aiSetupHowYourDataIsHandled.
  ///
  /// In en, this message translates to:
  /// **'How Your Data Is Handled'**
  String get aiSetupHowYourDataIsHandled;

  /// No description provided for @aiSetupYourDirectiveDataIsHeld.
  ///
  /// In en, this message translates to:
  /// **'- Your directive data is held in memory only; on close or crash it is kept ~10 minutes for recovery, then wiped — never written to disk or a server\n- AI features are optional and the app works without them\n- Only text you explicitly send via AI chat or AI Suggest leaves your device\n- This app is not a medical or legal service\n- This app is not HIPAA-compliant'**
  String get aiSetupYourDirectiveDataIsHeld;

  /// No description provided for @aiSetupCommonQuestions.
  ///
  /// In en, this message translates to:
  /// **'Common Questions'**
  String get aiSetupCommonQuestions;

  /// No description provided for @aiSetupRemoveApiKey2.
  ///
  /// In en, this message translates to:
  /// **'Remove API key'**
  String get aiSetupRemoveApiKey2;

  /// No description provided for @aiSetupCreateAnApiKey.
  ///
  /// In en, this message translates to:
  /// **'Create an API key'**
  String get aiSetupCreateAnApiKey;

  /// No description provided for @aiSetupCreateANewApiKey.
  ///
  /// In en, this message translates to:
  /// **'Create a new API key on the API keys page; the defaults are fine.'**
  String get aiSetupCreateANewApiKey;

  /// No description provided for @aiSetupCopyAndPasteBelow.
  ///
  /// In en, this message translates to:
  /// **'Copy and paste below'**
  String get aiSetupCopyAndPasteBelow;

  /// No description provided for @aiSetupPasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get aiSetupPasteFromClipboard;

  /// No description provided for @aiSetupTestingConnection.
  ///
  /// In en, this message translates to:
  /// **'Testing connection'**
  String get aiSetupTestingConnection;

  /// No description provided for @accessibilitySettingsAdjustHowTheAppFeels.
  ///
  /// In en, this message translates to:
  /// **'Adjust how the app feels for you. Changes apply everywhere instantly.'**
  String get accessibilitySettingsAdjustHowTheAppFeels;

  /// No description provided for @accessibilitySettingsHowToUseReadAloud.
  ///
  /// In en, this message translates to:
  /// **'How to use read-aloud'**
  String get accessibilitySettingsHowToUseReadAloud;

  /// No description provided for @accessibilitySettingsResetAccessibilitySettings.
  ///
  /// In en, this message translates to:
  /// **'Reset accessibility settings'**
  String get accessibilitySettingsResetAccessibilitySettings;

  /// No description provided for @accessibilitySettingsReadThisPageAloud.
  ///
  /// In en, this message translates to:
  /// **'Read this page aloud'**
  String get accessibilitySettingsReadThisPageAloud;

  /// No description provided for @accessibilitySettingsYourBrowserAndDeviceAlready.
  ///
  /// In en, this message translates to:
  /// **'Your browser and device already have read-aloud built in — they work better than an in-app reader, so use one of these:'**
  String get accessibilitySettingsYourBrowserAndDeviceAlready;

  /// No description provided for @accessibilitySettingsPeopleWhoITrustWill.
  ///
  /// In en, this message translates to:
  /// **'People who I trust will make my decisions if I can\'t.'**
  String get accessibilitySettingsPeopleWhoITrustWill;

  /// No description provided for @accessibilitySettingsEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get accessibilitySettingsEnglish;

  /// No description provided for @accessibilitySettingsEspaOl.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get accessibilitySettingsEspaOl;

  /// No description provided for @accessibilitySettingsAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibilitySettingsAccessibility;

  /// No description provided for @accessibilitySettingsTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get accessibilitySettingsTextSize;

  /// No description provided for @accessibilitySettingsDyslexiaFriendlyFont.
  ///
  /// In en, this message translates to:
  /// **'Dyslexia-friendly font'**
  String get accessibilitySettingsDyslexiaFriendlyFont;

  /// No description provided for @accessibilitySettingsBoldText.
  ///
  /// In en, this message translates to:
  /// **'Bold text'**
  String get accessibilitySettingsBoldText;

  /// No description provided for @accessibilitySettingsReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get accessibilitySettingsReduceMotion;

  /// No description provided for @accessibilitySettingsHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get accessibilitySettingsHighContrast;

  /// No description provided for @accessibilitySettingsReadAloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get accessibilitySettingsReadAloud;

  /// No description provided for @accessibilitySettingsRightClickThePageRead.
  ///
  /// In en, this message translates to:
  /// **'Right-click the page → “Read aloud” (Edge), or use the Reading mode / an extension in Chrome. Edge: Ctrl+Shift+U.'**
  String get accessibilitySettingsRightClickThePageRead;

  /// No description provided for @accessibilitySettingsSelectTextTapListenOr.
  ///
  /// In en, this message translates to:
  /// **'Select text → tap “Listen”, or turn on Settings → Accessibility → Select to Speak / TalkBack.'**
  String get accessibilitySettingsSelectTextTapListenOr;

  /// No description provided for @accessibilitySettingsSettingsAccessibilitySpokenContentTurn.
  ///
  /// In en, this message translates to:
  /// **'Settings → Accessibility → Spoken Content → turn on “Speak Screen”, then swipe down with two fingers.'**
  String get accessibilitySettingsSettingsAccessibilitySpokenContentTurn;

  /// No description provided for @accessibilitySettingsNarratorCtrlWinEnterOr.
  ///
  /// In en, this message translates to:
  /// **'Narrator: Ctrl+Win+Enter. Or use Edge’s Read aloud above.'**
  String get accessibilitySettingsNarratorCtrlWinEnterOr;

  /// No description provided for @accessibilitySettingsSystemSettingsAccessibilitySpokenContent.
  ///
  /// In en, this message translates to:
  /// **'System Settings → Accessibility → Spoken Content → “Speak selection”, then press Option+Esc.'**
  String get accessibilitySettingsSystemSettingsAccessibilitySpokenContent;

  /// No description provided for @privacyPolicyPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyPrivacyPolicy;

  /// No description provided for @privacyPolicyPaMhadAppPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'PA MHAD App Privacy Policy'**
  String get privacyPolicyPaMhadAppPrivacyPolicy;

  /// No description provided for @privacyPolicyReviewLegalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Review Legal Disclaimer'**
  String get privacyPolicyReviewLegalDisclaimer;

  /// No description provided for @privacyPolicyDataWeCollect.
  ///
  /// In en, this message translates to:
  /// **'Data We Collect'**
  String get privacyPolicyDataWeCollect;

  /// No description provided for @privacyPolicyThisAppCollectsOnlyThe.
  ///
  /// In en, this message translates to:
  /// **'This app collects only the information you enter into your Mental Health Advance Directive forms, including:\n  - Personal information (name, address, phone, date of birth)\n  - Agent and witness information\n  - Treatment preferences and medication lists\n  - Digital signatures\n  - Additional instructions\n\nWe do not collect analytics, crash reports, device identifiers, or location data.'**
  String get privacyPolicyThisAppCollectsOnlyThe;

  /// No description provided for @privacyPolicyHowDataIsStoredProtected.
  ///
  /// In en, this message translates to:
  /// **'How Data Is Stored & Protected'**
  String get privacyPolicyHowDataIsStoredProtected;

  /// No description provided for @privacyPolicyYourDirectiveDataIsNot.
  ///
  /// In en, this message translates to:
  /// **'Your directive data is NOT transmitted to the app developer or any third party for storage.\n\nThis is a web app: your data is held in an in-memory database in your browser tab. If you close the tab or the app crashes, your work is kept on this device for about 10 minutes so you can reopen and recover it — then it is wiped. Nothing is written to a server. Export or print your directive to keep a permanent copy.'**
  String get privacyPolicyYourDirectiveDataIsNot;

  /// No description provided for @privacyPolicyAiFeaturesThirdPartyData.
  ///
  /// In en, this message translates to:
  /// **'AI Features & Third-Party Data Sharing'**
  String get privacyPolicyAiFeaturesThirdPartyData;

  /// No description provided for @privacyPolicyIfYouChooseToUse.
  ///
  /// In en, this message translates to:
  /// **'If you choose to use the optional AI features (AI Assistant chat or AI Suggest), text you submit is sent to the AI provider you select — Google Gemini by default, or Anthropic Claude, OpenAI, or xAI Grok if you choose one and add your own key — for processing.\n\nOn Google\'s Gemini free tier, Google may:\n  - Use your input/output data to improve their products\n  - Allow human reviewers to read your inputs and outputs\n  - Retain data indefinitely (no automatic expiration)\nOther providers handle your data under their own API data policies — review the policy of whichever provider you use.\n\nThe app strips common personally identifiable information (SSNs, phone numbers, emails, dates of birth, addresses, names, and facility names) before sending your text to any provider, but this is a best-effort filter and cannot guarantee complete removal.\n\nAI features are entirely optional. The app is fully functional without them.'**
  String get privacyPolicyIfYouChooseToUse;

  /// No description provided for @privacyPolicyGeminiFreeTierDataPractices.
  ///
  /// In en, this message translates to:
  /// **'Gemini Free Tier Data Practices'**
  String get privacyPolicyGeminiFreeTierDataPractices;

  /// No description provided for @privacyPolicyIfYouUseTheAi.
  ///
  /// In en, this message translates to:
  /// **'If you use the AI features with Google\'s free Gemini tier, be aware of the following:\n\n1. Google retains AI conversation data indefinitely on the free tier. There is no automatic expiration.\n\n2. Human reviewers at Google may read your inputs and outputs as part of their quality and safety processes.\n\n3. Data sent to Gemini cannot be recalled or deleted by you or by this app. Once submitted, it is under Google\'s control.\n\n4. If you are concerned about data privacy, consider upgrading to the paid Gemini tier, which offers stronger data protection policies and does not use your data for model training.\n\nIf you select a different provider (Anthropic, OpenAI, or xAI) instead of Gemini, that provider\'s own data and retention policy applies — review it before sending sensitive content.\n\nYou can avoid all third-party data sharing by not using the AI features.'**
  String get privacyPolicyIfYouUseTheAi;

  /// No description provided for @privacyPolicyInternationalUsersGdpr.
  ///
  /// In en, this message translates to:
  /// **'International Users (GDPR)'**
  String get privacyPolicyInternationalUsersGdpr;

  /// No description provided for @privacyPolicyIfYouAreLocatedIn.
  ///
  /// In en, this message translates to:
  /// **'If you are located in the European Economic Area (EEA), the UK, or Switzerland, the General Data Protection Regulation (GDPR) applies to your use of this app.\n\nLegal basis for processing: Your explicit consent, given through the in-app disclaimer and AI consent dialogs.\n\nYour rights under GDPR:\n  - Right to access: All your data is stored locally on your device — you have direct access at all times.\n  - Right to erasure: Use \"Delete All Data\" in the app menu to permanently erase all local data.\n  - Right to data portability: Export your directives as PDF or FHIR JSON (a standard health-records format) at any time.\n  - Right to withdraw consent: Stop using AI features at any time; remove your API key to prevent further data transmission.\n  - Right to restriction: You may use the app in Public Mode without any data persistence.\n\nData sent to your chosen AI provider is processed under that provider\'s own privacy policy and data processing terms. We cannot control or delete data once it has been sent.'**
  String get privacyPolicyIfYouAreLocatedIn;

  /// No description provided for @privacyPolicyUsStateConsumerHealthData.
  ///
  /// In en, this message translates to:
  /// **'US State Consumer Health Data Laws (CA, WA, CT, NV, NY)'**
  String get privacyPolicyUsStateConsumerHealthData;

  /// No description provided for @privacyPolicyThisAppMayBeSubject.
  ///
  /// In en, this message translates to:
  /// **'This app may be subject to state consumer-health-data privacy laws including California (CCPA/CPRA), Washington (My Health My Data Act / MHMDA), Connecticut (CTDPA health provisions), Nevada (SB 370), and New York (Health Information Privacy Act).\n\nMental-health-directive content is \"consumer health data\" under each of these laws. Under all of them: (1) We collect mental-health treatment-preference data **solely** to help you create your advance directive. (2) We **do not sell** your health data — there is no commercial recipient. (3) The only third party that may receive any of your text is the AI provider you choose (Google Gemini by default, or Anthropic, OpenAI, or xAI), and **only** if you affirmatively opt in to AI features each session. (4) We use no third-party SDKs, no analytics, no advertising frameworks, no tracking pixels or cookies. (5) You may delete all locally stored data at any time via \"Delete All Data\" in the app menu.\n\nWashington MHMDA includes a **private right of action**; we have designed the app to require explicit, per-session consent before any third-party transfer of consumer health data, and we treat written consent as conditional on the specific terms shown in the AI consent dialog.\n\nFor questions about your privacy rights, contact the developer using the channels listed in the Contact section below (multiple methods are provided per the FTC Health Breach Notification Rule).'**
  String get privacyPolicyThisAppMayBeSubject;

  /// No description provided for @privacyPolicyMedicalReferenceLookupsUS.
  ///
  /// In en, this message translates to:
  /// **'Medical Reference Lookups (U.S. government data)'**
  String get privacyPolicyMedicalReferenceLookupsUS;

  /// No description provided for @privacyPolicyToHelpYouFillIn.
  ///
  /// In en, this message translates to:
  /// **'To help you fill in and understand your directive, the app looks things up in free, public U.S. government databases. These lookups use ONLY the single term or code needed for that lookup. They never receive your identity (your name, date of birth, address, or phone), the people you name (agents, witnesses, guardian), or your saved directive.\n\nWhat is sent, and to whom:\n  - Medication name you type → NLM RxTerms (autocomplete).\n  - Condition name you type → NLM ICD-10-CM (diagnosis lookup).\n  - A doctor / provider name you type into the optional doctor search → NLM NPI registry, used only to look that provider up in the public registry of healthcare providers.\n  - A condition (by its ICD-10 code) or a medication (by name, resolved to a code via NLM RxNav) → NLM MedlinePlus Connect, to fetch a plain-language explanation.\n  - A medication name → openFDA (U.S. Food & Drug Administration), to fetch that drug\'s official FDA label, which is used to ground the side-effects list.\n\nNo personal or identifying information is included in any of these requests — only the medical term, code, or provider name being looked up.\n\nNLM, NIH, and the FDA are not responsible for this product and do not endorse or recommend it. These services are for information only and are not medical advice — consult a qualified professional. The NLM Clinical Table services are rate-limited to 20 requests/second.\n\nSources: U.S. National Library of Medicine (RxTerms, ICD-10-CM, NPI registry, RxNav, MedlinePlus Connect); U.S. Food & Drug Administration (openFDA).'**
  String get privacyPolicyToHelpYouFillIn;

  /// No description provided for @privacyPolicyPdfExportSharing.
  ///
  /// In en, this message translates to:
  /// **'PDF Export & Sharing'**
  String get privacyPolicyPdfExportSharing;

  /// No description provided for @privacyPolicyWhenYouExportAPdf.
  ///
  /// In en, this message translates to:
  /// **'When you export a PDF of your directive, it is generated locally on your device. Sharing the PDF (via email, messaging, etc.) sends it through your device\'s standard sharing mechanism. The app cannot control where the PDF is stored once shared.'**
  String get privacyPolicyWhenYouExportAPdf;

  /// No description provided for @privacyPolicyYourRights.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get privacyPolicyYourRights;

  /// No description provided for @privacyPolicyYouCanDeleteAnyDirective.
  ///
  /// In en, this message translates to:
  /// **'You can delete any directive at any time from the home screen. Deleting a directive removes all associated data (personal info, agents, medications, witnesses, signatures) from the local database.\n\nYou can remove your AI provider API key(s) at any time from the AI Setup screen.\n\nUninstalling the app removes all locally stored data.'**
  String get privacyPolicyYouCanDeleteAnyDirective;

  /// No description provided for @privacyPolicyNoThirdPartyTracking.
  ///
  /// In en, this message translates to:
  /// **'No Third-Party Tracking'**
  String get privacyPolicyNoThirdPartyTracking;

  /// No description provided for @privacyPolicyThisAppDoesNotInclude.
  ///
  /// In en, this message translates to:
  /// **'This app does not include any third-party analytics SDKs, advertising frameworks, crash reporting services (such as Firebase, Crashlytics, or Sentry), or tracking pixels.\n\nThe only external network connections this app makes are:\n  - Your chosen AI provider — Google Gemini (default), Anthropic, OpenAI, or xAI — only when you use AI features\n  - NIH/NLM Clinical Table Search Service — medication, condition, and provider (doctor) lookups\n  - NLM MedlinePlus Connect & RxNav — plain-language condition and medication explanations (sends only an ICD-10 code or a medication name)\n  - openFDA / U.S. FDA — official drug labels used to ground the side-effects list (sends only a medication name)\n\nEach of these receives only the term or code being looked up — never your identity or your directive. No data is sent to the app developer at any time.'**
  String get privacyPolicyThisAppDoesNotInclude;

  /// No description provided for @privacyPolicyHipaaCompliance.
  ///
  /// In en, this message translates to:
  /// **'HIPAA & Compliance'**
  String get privacyPolicyHipaaCompliance;

  /// No description provided for @privacyPolicyThisAppIsNotHipaa.
  ///
  /// In en, this message translates to:
  /// **'This app is NOT HIPAA-compliant. It is not a covered entity or business associate under HIPAA. The app is intended for personal use by individuals preparing their own mental health advance directives.\n\nWhile this app implements privacy measures aligned with GDPR, CCPA, and MHMDA principles (as described above), it has not been independently audited or certified for compliance with these regulations. If you require verified regulatory compliance, consult with a privacy professional before use.'**
  String get privacyPolicyThisAppIsNotHipaa;

  /// No description provided for @privacyPolicyBreachNotification.
  ///
  /// In en, this message translates to:
  /// **'Breach Notification'**
  String get privacyPolicyBreachNotification;

  /// No description provided for @privacyPolicyInAccordanceWithTheFtc.
  ///
  /// In en, this message translates to:
  /// **'In accordance with the FTC Health Breach Notification Rule, if any unauthorized disclosure of your health information occurs through a security breach, we will notify affected users within 60 calendar days of discovering the breach.\n\nBecause this app stores data locally on your device and does not maintain a server-side database, breach risk is limited to the optional AI features. If your chosen AI provider notifies us of a breach affecting data sent through the app, we will pass that notification along through an in-app notice and a posting on the hosted privacy policy page.'**
  String get privacyPolicyInAccordanceWithTheFtc;

  /// No description provided for @privacyPolicyContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacyPolicyContact;

  /// No description provided for @settingsBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get settingsBrightness;

  /// No description provided for @settingsScreenshotProtection.
  ///
  /// In en, this message translates to:
  /// **'Screenshot Protection'**
  String get settingsScreenshotProtection;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsPaMentalHealthAdvanceDirective.
  ///
  /// In en, this message translates to:
  /// **'PA Mental Health Advance Directive\nUnder Pennsylvania Act 194 of 2004 (effective January 29, 2005)\n\nThis app helps you document your mental health treatment preferences. It is not legal or medical advice, and not a substitute for a licensed attorney or clinician. See the full Legal Disclaimer above for details.\n\nYour directive is valid for two years from the date you sign it — unless you are found incapable of making mental health decisions at the time it would expire, in which case it stays in effect until your capacity returns.\n\nForm content based on the official PA MHAD booklet published by the Disabilities Law Project (2005).'**
  String get settingsPaMentalHealthAdvanceDirective;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsLegalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Legal & privacy'**
  String get settingsLegalPrivacy;

  /// No description provided for @settingsChooseAProviderAndAdd.
  ///
  /// In en, this message translates to:
  /// **'Choose a provider and add your API key'**
  String get settingsChooseAProviderAndAdd;

  /// No description provided for @settingsTextSizeDyslexiaFontBold.
  ///
  /// In en, this message translates to:
  /// **'Text size, dyslexia font, bold text, contrast, language'**
  String get settingsTextSizeDyslexiaFontBold;

  /// No description provided for @settingsHowYourDataIsStored.
  ///
  /// In en, this message translates to:
  /// **'How your data is stored and protected'**
  String get settingsHowYourDataIsStored;

  /// No description provided for @settingsPrivacyPermissions.
  ///
  /// In en, this message translates to:
  /// **'Privacy & permissions'**
  String get settingsPrivacyPermissions;

  /// No description provided for @settingsWhatPermissionsTheAppUses.
  ///
  /// In en, this message translates to:
  /// **'What permissions the app uses, and what we promise about each'**
  String get settingsWhatPermissionsTheAppUses;

  /// No description provided for @settingsLegalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Legal Disclaimer'**
  String get settingsLegalDisclaimer;

  /// No description provided for @settingsTermsLimitationsAndYourLegal.
  ///
  /// In en, this message translates to:
  /// **'Terms, limitations, and your legal rights'**
  String get settingsTermsLimitationsAndYourLegal;

  /// No description provided for @assistantMessageWidgetsVerifiedWithWebSearch.
  ///
  /// In en, this message translates to:
  /// **'Verified with web search'**
  String get assistantMessageWidgetsVerifiedWithWebSearch;

  /// No description provided for @assistantMessageWidgetsSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get assistantMessageWidgetsSources;

  /// No description provided for @assistantMessageWidgetsVerifyOnTheWeb.
  ///
  /// In en, this message translates to:
  /// **'Verify on the web'**
  String get assistantMessageWidgetsVerifyOnTheWeb;

  /// No description provided for @assistantMessageWidgetsAiIsTyping.
  ///
  /// In en, this message translates to:
  /// **'AI is typing'**
  String get assistantMessageWidgetsAiIsTyping;

  /// No description provided for @assistantContextPanelAskAboutFormTypesAgents.
  ///
  /// In en, this message translates to:
  /// **'Ask about form types, agents, treatment preferences, or anything in the PA MHAD booklet. Try one of these:'**
  String get assistantContextPanelAskAboutFormTypesAgents;

  /// No description provided for @assistantContextPanelPiiRedactionOn.
  ///
  /// In en, this message translates to:
  /// **'PII REDACTION ON'**
  String get assistantContextPanelPiiRedactionOn;

  /// No description provided for @assistantContextPanelNamesAddressesPhoneNumbersAnd.
  ///
  /// In en, this message translates to:
  /// **'Names, addresses, phone numbers, and dates are replaced with placeholders before sending to Gemini. Suggestions come back with placeholders filled in locally.'**
  String get assistantContextPanelNamesAddressesPhoneNumbersAnd;

  /// No description provided for @assistantContextPanelContextTheAiSees.
  ///
  /// In en, this message translates to:
  /// **'Context the AI sees'**
  String get assistantContextPanelContextTheAiSees;

  /// No description provided for @assistantContextPanelSuggestedPrompts.
  ///
  /// In en, this message translates to:
  /// **'Suggested prompts'**
  String get assistantContextPanelSuggestedPrompts;

  /// No description provided for @assistantContextPanelWhatICanHelpWith.
  ///
  /// In en, this message translates to:
  /// **'What I can help with'**
  String get assistantContextPanelWhatICanHelpWith;

  /// No description provided for @assistantContextPanelPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get assistantContextPanelPrivacy;

  /// No description provided for @assistantContextPanelFormType.
  ///
  /// In en, this message translates to:
  /// **'Form type'**
  String get assistantContextPanelFormType;

  /// No description provided for @assistantContextPanelCurrentStep.
  ///
  /// In en, this message translates to:
  /// **'Current step'**
  String get assistantContextPanelCurrentStep;

  /// No description provided for @assistantContextPanelFilledFields.
  ///
  /// In en, this message translates to:
  /// **'Filled fields'**
  String get assistantContextPanelFilledFields;

  /// No description provided for @assistantContextPanelPii.
  ///
  /// In en, this message translates to:
  /// **'PII'**
  String get assistantContextPanelPii;

  /// No description provided for @assistantTheReplyFailed.
  ///
  /// In en, this message translates to:
  /// **'The reply failed.'**
  String get assistantTheReplyFailed;

  /// No description provided for @assistantStillFailingCheckYourConnection.
  ///
  /// In en, this message translates to:
  /// **'Still failing — check your connection or key.'**
  String get assistantStillFailingCheckYourConnection;

  /// No description provided for @assistantClearConversation.
  ///
  /// In en, this message translates to:
  /// **'Clear conversation?'**
  String get assistantClearConversation;

  /// No description provided for @assistantThisWillEraseAllMessages.
  ///
  /// In en, this message translates to:
  /// **'This will erase all messages. This cannot be undone.'**
  String get assistantThisWillEraseAllMessages;

  /// No description provided for @assistantClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get assistantClear;

  /// No description provided for @assistantToUseTheAiAssistant.
  ///
  /// In en, this message translates to:
  /// **'To use the AI assistant, set up an AI key — Gemini\'s free tier works.'**
  String get assistantToUseTheAiAssistant;

  /// No description provided for @assistantSetUpFree.
  ///
  /// In en, this message translates to:
  /// **'Set Up (Free)'**
  String get assistantSetUpFree;

  /// No description provided for @assistantPersonalInfoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Personal info removed'**
  String get assistantPersonalInfoRemoved;

  /// No description provided for @assistantAskMeAnythingAboutYour.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about your\nPA Mental Health Advance Directive'**
  String get assistantAskMeAnythingAboutYour;

  /// No description provided for @assistantSuggestedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Suggested questions:'**
  String get assistantSuggestedQuestions;

  /// No description provided for @assistantClearConversation2.
  ///
  /// In en, this message translates to:
  /// **'Clear conversation'**
  String get assistantClearConversation2;

  /// No description provided for @assistantApiKeySettings.
  ///
  /// In en, this message translates to:
  /// **'API key settings'**
  String get assistantApiKeySettings;

  /// No description provided for @assistantDisclaimerNotLegalOrMedical.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer: Not legal or medical advice. For legal questions contact PA Protection and Advocacy: {phone} '**
  String assistantDisclaimerNotLegalOrMedical(String phone);

  /// No description provided for @assistantAskAQuestionAboutYour.
  ///
  /// In en, this message translates to:
  /// **'Ask a question about your directive...'**
  String get assistantAskAQuestionAboutYour;

  /// No description provided for @assistantSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get assistantSend;

  /// No description provided for @directiveFormChoiceWithAPoaOnlyForm.
  ///
  /// In en, this message translates to:
  /// **'With a POA-only form, your agent will have authority to make mental health care decisions on your behalf, but the document will not include your personal treatment preferences.\n\nConsider using the Combined form instead to document both your preferences AND appoint an agent. This gives your care team the most guidance.'**
  String get directiveFormChoiceWithAPoaOnlyForm;

  /// No description provided for @directiveFormChoiceContinueWithPoa.
  ///
  /// In en, this message translates to:
  /// **'Continue with POA'**
  String get directiveFormChoiceContinueWithPoa;

  /// No description provided for @directiveFormChoiceYouCanSwitchFormTypes.
  ///
  /// In en, this message translates to:
  /// **'You can switch form types later if you change your mind — Combined is the broadest.'**
  String get directiveFormChoiceYouCanSwitchFormTypes;

  /// No description provided for @directiveFormChoiceCombinedDirective.
  ///
  /// In en, this message translates to:
  /// **'Combined directive'**
  String get directiveFormChoiceCombinedDirective;

  /// No description provided for @directiveFormChoiceTreatmentPreferencesAndATrusted.
  ///
  /// In en, this message translates to:
  /// **'Treatment preferences and a trusted decision-maker, in one document. 11 short steps · about 20 minutes.'**
  String get directiveFormChoiceTreatmentPreferencesAndATrusted;

  /// No description provided for @directiveFormChoiceStartNow.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get directiveFormChoiceStartNow;

  /// No description provided for @directiveFormChoiceNotSureWhichFormFits.
  ///
  /// In en, this message translates to:
  /// **'Not sure which form fits? Take the 4-question quiz.'**
  String get directiveFormChoiceNotSureWhichFormFits;

  /// No description provided for @directiveFormChoiceHelpMeChoose.
  ///
  /// In en, this message translates to:
  /// **'Help me choose →'**
  String get directiveFormChoiceHelpMeChoose;

  /// No description provided for @directiveFormChoicePowerOfAttorneyOnly.
  ///
  /// In en, this message translates to:
  /// **'Power of attorney only'**
  String get directiveFormChoicePowerOfAttorneyOnly;

  /// No description provided for @directiveFormChoiceTakeThe4QuestionQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take the 4-question quiz to choose a form'**
  String get directiveFormChoiceTakeThe4QuestionQuiz;

  /// No description provided for @webLandingALegalDocumentThatTells.
  ///
  /// In en, this message translates to:
  /// **'A legal document that tells doctors, family, and a person you trust how to care for you if you can’t speak for yourself. Free, anonymous, and takes about 20 minutes.'**
  String get webLandingALegalDocumentThatTells;

  /// No description provided for @webLandingYouReWorkingAnonymouslyNothing.
  ///
  /// In en, this message translates to:
  /// **'You’re working anonymously. Nothing is saved.'**
  String get webLandingYouReWorkingAnonymouslyNothing;

  /// No description provided for @webLandingNoAccountNoCloudIf.
  ///
  /// In en, this message translates to:
  /// **'No account, no cloud. If you close the tab or the app crashes, your work is kept on this device for 10 minutes so you can reopen and recover it — then it’s erased for good. Open your PDF and save it to keep a copy.'**
  String get webLandingNoAccountNoCloudIf;

  /// No description provided for @webLandingHowThisWorks.
  ///
  /// In en, this message translates to:
  /// **'HOW THIS WORKS →'**
  String get webLandingHowThisWorks;

  /// No description provided for @webLandingAnMhadIsYourVoice.
  ///
  /// In en, this message translates to:
  /// **'“An MHAD is your voice when you can’t speak for yourself.”'**
  String get webLandingAnMhadIsYourVoice;

  /// No description provided for @webLandingPaMhadBookletOfficeOf.
  ///
  /// In en, this message translates to:
  /// **'— PA MHAD booklet · Office of Mental Health'**
  String get webLandingPaMhadBookletOfficeOf;

  /// No description provided for @webLandingReadTheBasics.
  ///
  /// In en, this message translates to:
  /// **'Read the basics →'**
  String get webLandingReadTheBasics;

  /// No description provided for @webLandingPennsylvaniaAct194Of2004.
  ///
  /// In en, this message translates to:
  /// **'Pennsylvania · Act 194 of 2004'**
  String get webLandingPennsylvaniaAct194Of2004;

  /// No description provided for @webLandingOurPrivacyPromise.
  ///
  /// In en, this message translates to:
  /// **'Our privacy promise'**
  String get webLandingOurPrivacyPromise;

  /// No description provided for @webLandingFromTheBooklet.
  ///
  /// In en, this message translates to:
  /// **'From the booklet'**
  String get webLandingFromTheBooklet;

  /// No description provided for @webLandingPrintABlankForm.
  ///
  /// In en, this message translates to:
  /// **'Print a blank form'**
  String get webLandingPrintABlankForm;

  /// No description provided for @webLandingPrintBlankForm.
  ///
  /// In en, this message translates to:
  /// **'Print blank form'**
  String get webLandingPrintBlankForm;

  /// No description provided for @webLandingTheBasics.
  ///
  /// In en, this message translates to:
  /// **'The basics'**
  String get webLandingTheBasics;

  /// No description provided for @webLandingMakeAMentalHealth.
  ///
  /// In en, this message translates to:
  /// **'Make a mental health '**
  String get webLandingMakeAMentalHealth;

  /// No description provided for @webLandingAdvanceDirective.
  ///
  /// In en, this message translates to:
  /// **'advance directive.'**
  String get webLandingAdvanceDirective;

  /// No description provided for @homeToolsGridMakeItFindable.
  ///
  /// In en, this message translates to:
  /// **'Make it findable'**
  String get homeToolsGridMakeItFindable;

  /// No description provided for @homeToolsGridCrisisHelp.
  ///
  /// In en, this message translates to:
  /// **'Crisis help'**
  String get homeToolsGridCrisisHelp;

  /// No description provided for @homeDirectiveHeroDraft.
  ///
  /// In en, this message translates to:
  /// **'● Draft'**
  String get homeDirectiveHeroDraft;

  /// No description provided for @homeDirectiveHeroContinueWhereYouLeftOff.
  ///
  /// In en, this message translates to:
  /// **'Continue where you left off'**
  String get homeDirectiveHeroContinueWhereYouLeftOff;

  /// No description provided for @facilitatorGetHelpEvidenceBased.
  ///
  /// In en, this message translates to:
  /// **'Get help · evidence-based'**
  String get facilitatorGetHelpEvidenceBased;

  /// No description provided for @facilitatorTalkToSomeoneTrained.
  ///
  /// In en, this message translates to:
  /// **'Talk to someone trained'**
  String get facilitatorTalkToSomeoneTrained;

  /// No description provided for @facilitatorPennsylvaniaPeerSpecialistsAndRights.
  ///
  /// In en, this message translates to:
  /// **'Pennsylvania peer specialists and rights advocates help walk you through the form. Free; no booking system inside this app — call or visit a partner below.'**
  String get facilitatorPennsylvaniaPeerSpecialistsAndRights;

  /// No description provided for @facilitatorPrintReviewItTogether.
  ///
  /// In en, this message translates to:
  /// **'Print + review it together'**
  String get facilitatorPrintReviewItTogether;

  /// No description provided for @facilitatorPrintOrScreenShareYour.
  ///
  /// In en, this message translates to:
  /// **'Print or screen-share your draft and walk through it with a friend, family member, or peer. They can\'t change anything in your app — that stays in your hands.'**
  String get facilitatorPrintOrScreenShareYour;

  /// No description provided for @facilitatorEmailADraftToMy.
  ///
  /// In en, this message translates to:
  /// **'Email a draft to my clinician'**
  String get facilitatorEmailADraftToMy;

  /// No description provided for @facilitatorGenerateThePdfInExport.
  ///
  /// In en, this message translates to:
  /// **'Generate the PDF in Export, then send it via your phone\'s email app. Ask your therapist or psychiatrist for comments. You\'ll transcribe their suggestions back into the form yourself — this app doesn\'t connect to their EHR.'**
  String get facilitatorGenerateThePdfInExport;

  /// No description provided for @facilitatorCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get facilitatorCall;

  /// No description provided for @facilitatorOpenWebsite.
  ///
  /// In en, this message translates to:
  /// **'Open website'**
  String get facilitatorOpenWebsite;

  /// No description provided for @legalSheetFullLegalDisclosure.
  ///
  /// In en, this message translates to:
  /// **'Full legal disclosure'**
  String get legalSheetFullLegalDisclosure;

  /// No description provided for @legalSheetTheEightSectionsBelowWere.
  ///
  /// In en, this message translates to:
  /// **'The eight sections below were accepted at first launch. Tap to expand.'**
  String get legalSheetTheEightSectionsBelowWere;

  /// No description provided for @legalSheetFullLegalSections.
  ///
  /// In en, this message translates to:
  /// **'Full legal sections'**
  String get legalSheetFullLegalSections;

  /// No description provided for @legalSheetNotLegalOrMedicalAdvice.
  ///
  /// In en, this message translates to:
  /// **'Not legal or medical advice'**
  String get legalSheetNotLegalOrMedicalAdvice;

  /// No description provided for @legalSheetNoProfessionalRelationship.
  ///
  /// In en, this message translates to:
  /// **'No professional relationship'**
  String get legalSheetNoProfessionalRelationship;

  /// No description provided for @legalSheetUseAtYourOwnRisk.
  ///
  /// In en, this message translates to:
  /// **'Use at your own risk'**
  String get legalSheetUseAtYourOwnRisk;

  /// No description provided for @legalSheetRequirementsForAValidDirective.
  ///
  /// In en, this message translates to:
  /// **'Requirements for a valid directive'**
  String get legalSheetRequirementsForAValidDirective;

  /// No description provided for @legalSheetTwoYearValidity.
  ///
  /// In en, this message translates to:
  /// **'Two-year validity'**
  String get legalSheetTwoYearValidity;

  /// No description provided for @legalSheetRevocation.
  ///
  /// In en, this message translates to:
  /// **'Revocation'**
  String get legalSheetRevocation;

  /// No description provided for @legalSheetPrivacyAiFeatures.
  ///
  /// In en, this message translates to:
  /// **'Privacy & AI features'**
  String get legalSheetPrivacyAiFeatures;

  /// No description provided for @legalSheetResourcesAssistance.
  ///
  /// In en, this message translates to:
  /// **'Resources & assistance'**
  String get legalSheetResourcesAssistance;

  /// No description provided for @legalSheetPaProtectionAdvocacy.
  ///
  /// In en, this message translates to:
  /// **'PA Protection & Advocacy'**
  String get legalSheetPaProtectionAdvocacy;

  /// No description provided for @legalSheetPaMentalHealthConsumersAssociation.
  ///
  /// In en, this message translates to:
  /// **'PA Mental Health Consumers\' Association'**
  String get legalSheetPaMentalHealthConsumersAssociation;

  /// No description provided for @legalSheetMentalHealthAssociationInPennsylvania.
  ///
  /// In en, this message translates to:
  /// **'Mental Health Association in Pennsylvania'**
  String get legalSheetMentalHealthAssociationInPennsylvania;

  /// No description provided for @legalSheet988SuicideCrisisLifeline.
  ///
  /// In en, this message translates to:
  /// **'988 Suicide & Crisis Lifeline'**
  String get legalSheet988SuicideCrisisLifeline;

  /// No description provided for @legalSheetThisAppHelpsPennsylvaniaResidents.
  ///
  /// In en, this message translates to:
  /// **'This app helps Pennsylvania residents document their treatment preferences under '**
  String get legalSheetThisAppHelpsPennsylvaniaResidents;

  /// No description provided for @legalSheetTheInformationIsForInformational.
  ///
  /// In en, this message translates to:
  /// **'. The information is for informational purposes only and does '**
  String get legalSheetTheInformationIsForInformational;

  /// No description provided for @legalSheetConstituteLegalOrMedicalAdvice.
  ///
  /// In en, this message translates to:
  /// **' constitute legal or medical advice.'**
  String get legalSheetConstituteLegalOrMedicalAdvice;

  /// No description provided for @legalSheetItIsNotAMedical.
  ///
  /// In en, this message translates to:
  /// **'It is not a medical device. It does not diagnose, treat, cure, or prevent any condition. For treatment decisions, consult a qualified mental health professional. For legal questions, consult a licensed PA attorney.'**
  String get legalSheetItIsNotAMedical;

  /// No description provided for @legalSheetUseOfThisAppDoes.
  ///
  /// In en, this message translates to:
  /// **'Use of this app does '**
  String get legalSheetUseOfThisAppDoes;

  /// No description provided for @legalSheetCreateAnAttorneyClientRelationship.
  ///
  /// In en, this message translates to:
  /// **' create an attorney–client relationship, a provider–patient relationship, or any other professional relationship between you and the developer.'**
  String get legalSheetCreateAnAttorneyClientRelationship;

  /// No description provided for @legalSheetYouAreSolelyResponsibleFor.
  ///
  /// In en, this message translates to:
  /// **'You are solely responsible for making sure your directive meets all legal requirements under PA law, including proper execution with witnesses.'**
  String get legalSheetYouAreSolelyResponsibleFor;

  /// No description provided for @legalSheetInPlainTermsThisApp.
  ///
  /// In en, this message translates to:
  /// **'In plain terms: this app helps you put your own wishes into a directive, and you use it at your own risk. Please review the finished document for accuracy — mistakes can happen, and details you entered may be out of date or incomplete. If you are ever unsure whether something is legally right for your situation, feel free to talk with an attorney. The formal version:'**
  String get legalSheetInPlainTermsThisApp;

  /// No description provided for @legalSheetThisAppIsProvided.
  ///
  /// In en, this message translates to:
  /// **'This app is provided '**
  String get legalSheetThisAppIsProvided;

  /// No description provided for @legalSheetAsIs.
  ///
  /// In en, this message translates to:
  /// **'\"as is\"'**
  String get legalSheetAsIs;

  /// No description provided for @legalSheetWithoutWarrantiesOfAnyKind.
  ///
  /// In en, this message translates to:
  /// **', without warranties of any kind, and you use it at your own risk. To the fullest extent permitted by law, the developer is not liable for any damages arising from use of the app or any document created with it. You are responsible for reviewing your directive for accuracy and completeness; for legal questions specific to your situation, consult a licensed Pennsylvania attorney.'**
  String get legalSheetWithoutWarrantiesOfAnyKind;

  /// No description provided for @legalSheetAPaMentalHealthAdvance.
  ///
  /// In en, this message translates to:
  /// **'A PA Mental Health Advance Directive is legally valid '**
  String get legalSheetAPaMentalHealthAdvance;

  /// No description provided for @legalSheetWhen.
  ///
  /// In en, this message translates to:
  /// **' when:'**
  String get legalSheetWhen;

  /// No description provided for @legalSheetYouThePrincipalHaveLegal.
  ///
  /// In en, this message translates to:
  /// **'You (the principal) have legal capacity at the time of signing'**
  String get legalSheetYouThePrincipalHaveLegal;

  /// No description provided for @legalSheetItIsSignedInThe.
  ///
  /// In en, this message translates to:
  /// **'It is signed in the presence of '**
  String get legalSheetItIsSignedInThe;

  /// No description provided for @legalSheetBothWitnessesMeetEligibilityRequirements.
  ///
  /// In en, this message translates to:
  /// **'Both witnesses meet eligibility requirements under Act 194'**
  String get legalSheetBothWitnessesMeetEligibilityRequirements;

  /// No description provided for @legalSheetYourDesignatedAgentOrAlternate.
  ///
  /// In en, this message translates to:
  /// **'your designated agent or alternate agent, your mental health care provider, or an employee of the facility where you receive treatment — unless they are related to you by blood, marriage, or adoption.'**
  String get legalSheetYourDesignatedAgentOrAlternate;

  /// No description provided for @legalSheetThisAppCapturesTouchDrawn.
  ///
  /// In en, this message translates to:
  /// **'This app captures touch-drawn signatures for convenience during preparation. The '**
  String get legalSheetThisAppCapturesTouchDrawn;

  /// No description provided for @legalSheetDirectiveMustBeSignedIn.
  ///
  /// In en, this message translates to:
  /// **' directive must be signed in original ink, in the presence of your two witnesses, to be legally valid.'**
  String get legalSheetDirectiveMustBeSignedIn;

  /// No description provided for @legalSheetOnceSignedProvidersAndYour.
  ///
  /// In en, this message translates to:
  /// **'Once signed, providers and your agent '**
  String get legalSheetOnceSignedProvidersAndYour;

  /// No description provided for @legalSheetWithYourDirective20Pa.
  ///
  /// In en, this message translates to:
  /// **' with your directive (20 Pa.C.S. §§ 5804, 5842). However, a provider may decline to follow specific instructions that are against accepted medical practice, or when the provider is not physically available.'**
  String get legalSheetWithYourDirective20Pa;

  /// No description provided for @legalSheetUnderPaAct194An.
  ///
  /// In en, this message translates to:
  /// **'Under PA Act 194, an MHAD is valid for '**
  String get legalSheetUnderPaAct194An;

  /// No description provided for @legalSheetFromTheDateOfExecution.
  ///
  /// In en, this message translates to:
  /// **' from the date of execution unless revoked earlier — '**
  String get legalSheetFromTheDateOfExecution;

  /// No description provided for @legalSheetOfMakingMentalHealthDecisions.
  ///
  /// In en, this message translates to:
  /// **' of making mental health decisions at the time it would expire, in which case it remains in effect until capacity returns. This app will remind you when your directive is approaching expiration.'**
  String get legalSheetOfMakingMentalHealthDecisions;

  /// No description provided for @legalSheetYouMayRevokeThisDirective.
  ///
  /// In en, this message translates to:
  /// **'You may revoke this directive at any time while you have legal capacity by:'**
  String get legalSheetYouMayRevokeThisDirective;

  /// No description provided for @legalSheetNotifyingYourHealthcareProviderOr.
  ///
  /// In en, this message translates to:
  /// **'Notifying your healthcare provider or agent in writing'**
  String get legalSheetNotifyingYourHealthcareProviderOr;

  /// No description provided for @legalSheetDestroyingTheDirective.
  ///
  /// In en, this message translates to:
  /// **'Destroying the directive'**
  String get legalSheetDestroyingTheDirective;

  /// No description provided for @legalSheetExecutingANewDirective.
  ///
  /// In en, this message translates to:
  /// **'Executing a new directive'**
  String get legalSheetExecutingANewDirective;

  /// No description provided for @legalSheetNotifyEveryoneWhoHasCopies.
  ///
  /// In en, this message translates to:
  /// **'Notify everyone who has copies of the revocation.'**
  String get legalSheetNotifyEveryoneWhoHasCopies;

  /// No description provided for @legalSheetThisIsAWebApp.
  ///
  /// In en, this message translates to:
  /// **'This is a web app: your directive is held in memory in your browser only and is '**
  String get legalSheetThisIsAWebApp;

  /// No description provided for @legalSheetIfYouCloseTheTab.
  ///
  /// In en, this message translates to:
  /// **' — if you close the tab or it crashes, your work is kept on this device for about 10 minutes for recovery, then wiped; it is never sent to a server. Export or print to keep a copy. This app is '**
  String get legalSheetIfYouCloseTheTab;

  /// No description provided for @legalSheetHipaaCompliant.
  ///
  /// In en, this message translates to:
  /// **' HIPAA-compliant.'**
  String get legalSheetHipaaCompliant;

  /// No description provided for @legalSheetIfYouUseTheOptional.
  ///
  /// In en, this message translates to:
  /// **'If you use the optional AI Assistant, text you send is transmitted to the AI provider you choose (Google Gemini by default; or Anthropic, OpenAI, or xAI). On Gemini\'s free tier, Google may use this data to improve their products and human reviewers may read inputs; other providers handle your data under their own API policies.'**
  String get legalSheetIfYouUseTheOptional;

  /// No description provided for @legalSheetToProtectYouTheApp.
  ///
  /// In en, this message translates to:
  /// **'To protect you, the app '**
  String get legalSheetToProtectYouTheApp;

  /// No description provided for @legalSheetYourNameDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **' — your name, date of birth, address, and the names and contact details of your agents and guardian are never included. Only non-identifying context (such as conditions, medications, and care preferences) is shared, and only if you choose to use the assistant. (Uploading a document for autofill is the one exception, described next.)'**
  String get legalSheetYourNameDateOfBirth;

  /// No description provided for @legalSheetDocumentsYouUploadForAutofill.
  ///
  /// In en, this message translates to:
  /// **'Documents you upload for autofill are different: the whole file is sent to your chosen AI provider as-is, and to fill in your directive the AI reads the personal details in it (your name, date of birth, address, and your agent\'s or guardian\'s details). You review everything before it is saved. '**
  String get legalSheetDocumentsYouUploadForAutofill;

  /// No description provided for @legalSheetBlackOutAnythingYouDon.
  ///
  /// In en, this message translates to:
  /// **' — black out anything you don\'t want sent, or simply type any field by hand to keep it private. Also avoid typing personal identifiers (full name, SSN, date of birth, address) directly into chat messages.'**
  String get legalSheetBlackOutAnythingYouDon;

  /// No description provided for @legalSheetSeparatelyToHelpYouFill.
  ///
  /// In en, this message translates to:
  /// **'Separately, to help you fill in and understand your directive, the app looks up medications, conditions, and (optionally) your doctor in free, public U.S. government databases — the NIH/NLM Clinical Tables, MedlinePlus, and the FDA\'s openFDA. '**
  String get legalSheetSeparatelyToHelpYouFill;

  /// No description provided for @legalSheetNeverYourIdentityThePeople.
  ///
  /// In en, this message translates to:
  /// **' — never your identity, the people you name, or your saved directive. They are reference information, not medical advice.'**
  String get legalSheetNeverYourIdentityThePeople;

  /// No description provided for @legalSheetAiSuggestionsAreNotLegal.
  ///
  /// In en, this message translates to:
  /// **'AI suggestions are not legal or medical advice — review carefully before accepting.'**
  String get legalSheetAiSuggestionsAreNotLegal;

  /// No description provided for @disclaimerAFewThingsToUnderstand.
  ///
  /// In en, this message translates to:
  /// **'A few things to understand.'**
  String get disclaimerAFewThingsToUnderstand;

  /// No description provided for @disclaimerThisToolHelpsYouWrite.
  ///
  /// In en, this message translates to:
  /// **'This tool helps you write a Pennsylvania Mental Health Advance Directive under Act 194. Please read these before continuing.'**
  String get disclaimerThisToolHelpsYouWrite;

  /// No description provided for @disclaimerReadFullDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Read full disclaimer'**
  String get disclaimerReadFullDisclaimer;

  /// No description provided for @disclaimerGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get disclaimerGetStarted;

  /// No description provided for @disclaimerIM18OrOlder.
  ///
  /// In en, this message translates to:
  /// **'I\'m 18 or older, and I understand and want to continue.'**
  String get disclaimerIM18OrOlder;

  /// No description provided for @disclaimerBeforeYouBegin.
  ///
  /// In en, this message translates to:
  /// **'Before you begin'**
  String get disclaimerBeforeYouBegin;

  /// No description provided for @disclaimerThisIsNotLegalAdvice.
  ///
  /// In en, this message translates to:
  /// **'This is not legal advice'**
  String get disclaimerThisIsNotLegalAdvice;

  /// No description provided for @disclaimerWeGivePlainLanguageHelp.
  ///
  /// In en, this message translates to:
  /// **'We give plain-language help, not legal counsel. For complex situations, talk to an attorney or advocate.'**
  String get disclaimerWeGivePlainLanguageHelp;

  /// No description provided for @disclaimerItBecomesValidOnlyWhen.
  ///
  /// In en, this message translates to:
  /// **'It becomes valid only when signed on paper'**
  String get disclaimerItBecomesValidOnlyWhen;

  /// No description provided for @disclaimerPaLawRequiresYourSignature.
  ///
  /// In en, this message translates to:
  /// **'PA law requires your signature plus two adult witnesses, in ink, in person. The app cannot sign for you.'**
  String get disclaimerPaLawRequiresYourSignature;

  /// No description provided for @disclaimerNothingIsSavedOrSent.
  ///
  /// In en, this message translates to:
  /// **'Nothing is saved or sent to us'**
  String get disclaimerNothingIsSavedOrSent;

  /// No description provided for @disclaimerYouCanStopOrChange.
  ///
  /// In en, this message translates to:
  /// **'You can stop or change anything, anytime'**
  String get disclaimerYouCanStopOrChange;

  /// No description provided for @disclaimerSkipQuestionsGoBackOr.
  ///
  /// In en, this message translates to:
  /// **'Skip questions, go back, or revoke later. This is your voice — you stay in control.'**
  String get disclaimerSkipQuestionsGoBackOr;

  /// No description provided for @onboardingWeLlWalkYouThrough.
  ///
  /// In en, this message translates to:
  /// **'We\'ll walk you through it, step by step and in plain language: how you want to be treated during a mental health crisis — so your wishes are honored even when you can\'t speak for yourself.'**
  String get onboardingWeLlWalkYouThrough;

  /// No description provided for @onboardingValidTwoYearsFromSigning.
  ///
  /// In en, this message translates to:
  /// **'Valid two years from signing — unless you are incapable when it would expire, when it stays in effect until your capacity returns. (PA Act 194, effective 2005.)'**
  String get onboardingValidTwoYearsFromSigning;

  /// No description provided for @onboardingUploadADocumentToAutofill.
  ///
  /// In en, this message translates to:
  /// **'Upload a document to autofill'**
  String get onboardingUploadADocumentToAutofill;

  /// No description provided for @onboardingContinueFromASavedFile.
  ///
  /// In en, this message translates to:
  /// **'Continue from a saved file'**
  String get onboardingContinueFromASavedFile;

  /// No description provided for @onboardingFreeNoAccountNoTracking.
  ///
  /// In en, this message translates to:
  /// **'Free · no account · no tracking · open source'**
  String get onboardingFreeNoAccountNoTracking;

  /// No description provided for @onboardingPaMhadAct194.
  ///
  /// In en, this message translates to:
  /// **'PA MHAD · Act 194'**
  String get onboardingPaMhadAct194;

  /// No description provided for @onboardingInYour.
  ///
  /// In en, this message translates to:
  /// **'In your\n'**
  String get onboardingInYour;

  /// No description provided for @onboardingWords.
  ///
  /// In en, this message translates to:
  /// **'words.'**
  String get onboardingWords;

  /// No description provided for @onboardingMakingThisChangesNothingToday.
  ///
  /// In en, this message translates to:
  /// **'Making this changes nothing today. '**
  String get onboardingMakingThisChangesNothingToday;

  /// No description provided for @onboardingYouKeepEveryDecision.
  ///
  /// In en, this message translates to:
  /// **'You keep every decision'**
  String get onboardingYouKeepEveryDecision;

  /// No description provided for @onboardingUntilTwoProfessionalsFindYou.
  ///
  /// In en, this message translates to:
  /// **' until two professionals find you unable to decide for yourself.'**
  String get onboardingUntilTwoProfessionalsFindYou;

  /// No description provided for @aiConsistencyTheAiIsReviewingYour.
  ///
  /// In en, this message translates to:
  /// **'The AI is reviewing your directive…'**
  String get aiConsistencyTheAiIsReviewingYour;

  /// No description provided for @aiConsistencyAiReviewSkippedYouCan.
  ///
  /// In en, this message translates to:
  /// **'AI review skipped — you can re-run it any time.'**
  String get aiConsistencyAiReviewSkippedYouCan;

  /// No description provided for @aiConsistencyRunAiReview.
  ///
  /// In en, this message translates to:
  /// **'Run AI review'**
  String get aiConsistencyRunAiReview;

  /// No description provided for @aiConsistencyIgnoreContinue.
  ///
  /// In en, this message translates to:
  /// **'Ignore & continue'**
  String get aiConsistencyIgnoreContinue;

  /// No description provided for @aiConsistencyResolveInWizard.
  ///
  /// In en, this message translates to:
  /// **'Resolve in wizard'**
  String get aiConsistencyResolveInWizard;

  /// No description provided for @aiConsistencyLooksGoodContinue.
  ///
  /// In en, this message translates to:
  /// **'Looks good — continue'**
  String get aiConsistencyLooksGoodContinue;

  /// No description provided for @aiConsistencyKeepBoth.
  ///
  /// In en, this message translates to:
  /// **'Keep both'**
  String get aiConsistencyKeepBoth;

  /// No description provided for @aiConsistencyAiReview.
  ///
  /// In en, this message translates to:
  /// **'AI review'**
  String get aiConsistencyAiReview;

  /// No description provided for @aiConsistencyConsistencyCheckCheckedAtReview.
  ///
  /// In en, this message translates to:
  /// **'Consistency check · checked at Review'**
  String get aiConsistencyConsistencyCheckCheckedAtReview;

  /// No description provided for @aiConsistencyCheckingYourDirective.
  ///
  /// In en, this message translates to:
  /// **'Checking your directive'**
  String get aiConsistencyCheckingYourDirective;

  /// No description provided for @aiConsistencyYouSaidYourAgentDecides.
  ///
  /// In en, this message translates to:
  /// **'You said your agent decides your medications, but the form says your agent is NOT authorized to consent to medications.'**
  String get aiConsistencyYouSaidYourAgentDecides;

  /// No description provided for @aiConsistencyTheseCancelEachOtherOut.
  ///
  /// In en, this message translates to:
  /// **'These cancel each other out. The official form lets you set your own medication preferences and your agent’s authority separately — both are allowed — but as entered they oppose each other. Authorize your agent to consent to medications, or change the medication choice so they agree.'**
  String get aiConsistencyTheseCancelEachOtherOut;

  /// No description provided for @aiConsistencyYouDonTConsentTo.
  ///
  /// In en, this message translates to:
  /// **'You don’t consent to any medications, but your agent is authorized to consent to them.'**
  String get aiConsistencyYouDonTConsentTo;

  /// No description provided for @aiConsistencyTheOfficialFormLetsYou.
  ///
  /// In en, this message translates to:
  /// **'The official form lets you set your own preference and your agent’s authority separately — both are valid — but as entered they oppose each other: your refusal of all medications versus your agent’s power to consent to any. Decide which should control and adjust the other.'**
  String get aiConsistencyTheOfficialFormLetsYou;

  /// No description provided for @aiConsistencyINoticed.
  ///
  /// In en, this message translates to:
  /// **'I noticed '**
  String get aiConsistencyINoticed;

  /// No description provided for @draftRecoveryDialogRecoverUnsavedWork.
  ///
  /// In en, this message translates to:
  /// **'Recover Unsaved Work?'**
  String get draftRecoveryDialogRecoverUnsavedWork;

  /// No description provided for @draftRecoveryDialogDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get draftRecoveryDialogDiscard;

  /// No description provided for @draftRecoveryDialogRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get draftRecoveryDialogRestore;

  /// No description provided for @draftRecoveryDialogDraftRestoredPersonalInformationWill.
  ///
  /// In en, this message translates to:
  /// **'Draft restored. Personal information will need to be re-entered.'**
  String get draftRecoveryDialogDraftRestoredPersonalInformationWill;

  /// No description provided for @draftRecoveryDialogCouldnTRestoreTheDraft.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore the draft.'**
  String get draftRecoveryDialogCouldnTRestoreTheDraft;

  /// No description provided for @moreSheetResetAndStartFresh.
  ///
  /// In en, this message translates to:
  /// **'Reset and start fresh?'**
  String get moreSheetResetAndStartFresh;

  /// No description provided for @moreSheetThisPermanentlyErasesEverythingIn.
  ///
  /// In en, this message translates to:
  /// **'This permanently erases everything in this session — all directives, your AI key, and chat history — and returns you to a blank start.\n\nExport or print anything you want to keep first. This cannot be undone.'**
  String get moreSheetThisPermanentlyErasesEverythingIn;

  /// No description provided for @moreSheetResetEverything.
  ///
  /// In en, this message translates to:
  /// **'Reset everything'**
  String get moreSheetResetEverything;

  /// No description provided for @moreSheetEverythingElseYouCanDo.
  ///
  /// In en, this message translates to:
  /// **'Everything else you can do here.'**
  String get moreSheetEverythingElseYouCanDo;

  /// No description provided for @moreSheetGetHelp.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get moreSheetGetHelp;

  /// No description provided for @moreSheetReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get moreSheetReset;

  /// No description provided for @crisisSheet247FreeConfidential.
  ///
  /// In en, this message translates to:
  /// **'24/7 FREE, CONFIDENTIAL'**
  String get crisisSheet247FreeConfidential;

  /// No description provided for @crisisSheetRealPeopleAreStandingBy.
  ///
  /// In en, this message translates to:
  /// **'Real people are standing by — phone, text, or chat.'**
  String get crisisSheetRealPeopleAreStandingBy;

  /// No description provided for @crisisSheetCalling988ConnectsYouTo.
  ///
  /// In en, this message translates to:
  /// **'Calling 988 connects you to a trained counselor in your area. It is free, confidential, and available 24 hours a day. Calling will not result in police being dispatched in most cases.'**
  String get crisisSheetCalling988ConnectsYouTo;

  /// No description provided for @crisisSheetWhyTheseNumbers.
  ///
  /// In en, this message translates to:
  /// **'Why these numbers?'**
  String get crisisSheetWhyTheseNumbers;

  /// No description provided for @crisisSheetIfYouOrSomeoneElse.
  ///
  /// In en, this message translates to:
  /// **'If you or someone else is in immediate danger, call '**
  String get crisisSheetIfYouOrSomeoneElse;

  /// No description provided for @walletCardMh.
  ///
  /// In en, this message translates to:
  /// **'MH'**
  String get walletCardMh;

  /// No description provided for @walletCardPaMhadAct194.
  ///
  /// In en, this message translates to:
  /// **'PA MHAD · ACT 194'**
  String get walletCardPaMhadAct194;

  /// No description provided for @walletCardHasAnActiveDirectiveOn.
  ///
  /// In en, this message translates to:
  /// **'Has an active directive on file'**
  String get walletCardHasAnActiveDirectiveOn;

  /// No description provided for @walletCardAgent.
  ///
  /// In en, this message translates to:
  /// **'AGENT'**
  String get walletCardAgent;

  /// No description provided for @walletCardExp.
  ///
  /// In en, this message translates to:
  /// **'EXP'**
  String get walletCardExp;

  /// No description provided for @webSidebarAct1942004.
  ///
  /// In en, this message translates to:
  /// **'ACT 194 · 2004'**
  String get webSidebarAct1942004;

  /// No description provided for @webSidebar247Lifeline.
  ///
  /// In en, this message translates to:
  /// **'24/7 LIFELINE'**
  String get webSidebar247Lifeline;

  /// No description provided for @webSidebar988CrisisHelp.
  ///
  /// In en, this message translates to:
  /// **'988 · Crisis help'**
  String get webSidebar988CrisisHelp;

  /// No description provided for @webSidebarClickForMoreInformation.
  ///
  /// In en, this message translates to:
  /// **'Click for more information'**
  String get webSidebarClickForMoreInformation;

  /// No description provided for @webSidebarPeerSupportAdvocatesReferrals.
  ///
  /// In en, this message translates to:
  /// **'Peer support · advocates · referrals'**
  String get webSidebarPeerSupportAdvocatesReferrals;

  /// No description provided for @medlinePlusDialogNoPlainLanguageSummaryIs.
  ///
  /// In en, this message translates to:
  /// **'No plain-language summary is available for this right now. You can search it on MedlinePlus.'**
  String get medlinePlusDialogNoPlainLanguageSummaryIs;

  /// No description provided for @medlinePlusDialogPlainLanguageInformationFromThe.
  ///
  /// In en, this message translates to:
  /// **'Plain-language information from the U.S. National Library of Medicine (MedlinePlus). Educational only — not medical advice.'**
  String get medlinePlusDialogPlainLanguageInformationFromThe;

  /// No description provided for @medlinePlusDialogReadMoreOnMedlineplus.
  ///
  /// In en, this message translates to:
  /// **'Read more on MedlinePlus'**
  String get medlinePlusDialogReadMoreOnMedlineplus;

  /// No description provided for @fdaLabelDialogNoFdaLabelInformationIs.
  ///
  /// In en, this message translates to:
  /// **'No FDA label information is available for this medication right now. Brand and generic spellings can differ — try the other one, or ask your pharmacist.'**
  String get fdaLabelDialogNoFdaLabelInformationIs;

  /// No description provided for @fdaLabelDialogOfficialUSFdaDrug.
  ///
  /// In en, this message translates to:
  /// **'Official U.S. FDA drug-label text (openFDA). Reference only — not medical advice, and not personalized to you. Discuss anything here with your doctor or pharmacist.'**
  String get fdaLabelDialogOfficialUSFdaDrug;

  /// No description provided for @aiConsentDialogBeforeYouUpload.
  ///
  /// In en, this message translates to:
  /// **'Before you upload'**
  String get aiConsentDialogBeforeYouUpload;

  /// No description provided for @aiConsentDialogNothingIsSavedToYour.
  ///
  /// In en, this message translates to:
  /// **'Nothing is saved to your directive automatically — you review every field the AI fills in before it is applied.'**
  String get aiConsentDialogNothingIsSavedToYour;

  /// No description provided for @aiConsentDialogUploadingIsOnlyAShortcut.
  ///
  /// In en, this message translates to:
  /// **'Uploading is only a shortcut, never required:\n• Black out anything you don\'t want sent (ID or card numbers, other people\'s details) before uploading.\n• Or skip the upload and type any field by hand — typed fields stay on your device and are never sent to the AI.'**
  String get aiConsentDialogUploadingIsOnlyAShortcut;

  /// No description provided for @aiConsentDialogSendToTheAi.
  ///
  /// In en, this message translates to:
  /// **'Send to the AI'**
  String get aiConsentDialogSendToTheAi;

  /// No description provided for @aiConsentDialogTranscribeWithAi.
  ///
  /// In en, this message translates to:
  /// **'Transcribe with AI'**
  String get aiConsentDialogTranscribeWithAi;

  /// No description provided for @aiConsentDialogYouReviewTheTextBefore.
  ///
  /// In en, this message translates to:
  /// **'You review the text before it goes into your form. Prefer not to? Tap Cancel to use your device\'s built-in dictation instead, or just type — neither sends audio to the AI.'**
  String get aiConsentDialogYouReviewTheTextBefore;

  /// No description provided for @aiConsentDialogUseAi.
  ///
  /// In en, this message translates to:
  /// **'Use AI'**
  String get aiConsentDialogUseAi;

  /// No description provided for @aiConsentDialogAiDataNotice.
  ///
  /// In en, this message translates to:
  /// **'AI Data Notice'**
  String get aiConsentDialogAiDataNotice;

  /// No description provided for @aiConsentDialogImportantPleaseReadBeforeContinuing.
  ///
  /// In en, this message translates to:
  /// **'Important: Please read before continuing.\n'**
  String get aiConsentDialogImportantPleaseReadBeforeContinuing;

  /// No description provided for @aiConsentDialogThisAiAssistantIsNot.
  ///
  /// In en, this message translates to:
  /// **'• This AI assistant is NOT a therapist, doctor, or lawyer. It provides general information about PA Mental Health Advance Directives only.\n'**
  String get aiConsentDialogThisAiAssistantIsNot;

  /// No description provided for @aiConsentDialogNeverEnterPersonalInformationFull.
  ///
  /// In en, this message translates to:
  /// **'NEVER enter personal information (full name, date of birth, Social Security number, address, phone number, email) into the AI chat or AI-powered features.\n\nThe app automatically strips common personal data, but this is not guaranteed. Personal information fields must be filled in manually — they are stored on your device only and never sent to the AI.'**
  String get aiConsentDialogNeverEnterPersonalInformationFull;

  /// No description provided for @aiConsentDialogNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get aiConsentDialogNotNow;

  /// No description provided for @aiConsentDialogIAuthorize.
  ///
  /// In en, this message translates to:
  /// **'I Authorize'**
  String get aiConsentDialogIAuthorize;

  /// No description provided for @addressFieldsTapTheIconToFill.
  ///
  /// In en, this message translates to:
  /// **'Tap the icon to fill city & state'**
  String get addressFieldsTapTheIconToFill;

  /// No description provided for @addressFieldsFillCityStateFromZip.
  ///
  /// In en, this message translates to:
  /// **'Fill city & state from ZIP'**
  String get addressFieldsFillCityStateFromZip;

  /// No description provided for @mainTheAppCouldnTStart.
  ///
  /// In en, this message translates to:
  /// **'The app couldn\'t start'**
  String get mainTheAppCouldnTStart;

  /// No description provided for @mainPaMentalHealthAdvanceDirective.
  ///
  /// In en, this message translates to:
  /// **'PA Mental Health Advance Directive'**
  String get mainPaMentalHealthAdvanceDirective;

  /// No description provided for @mainAppTitle.
  ///
  /// In en, this message translates to:
  /// **'PA Mental Health Advance Directive'**
  String get mainAppTitle;

  /// No description provided for @aiConsistencyStepsProcedures.
  ///
  /// In en, this message translates to:
  /// **'Procedures + Agent authority'**
  String get aiConsistencyStepsProcedures;

  /// No description provided for @aiConsistencyStepsMeds.
  ///
  /// In en, this message translates to:
  /// **'Medications + Agent authority'**
  String get aiConsistencyStepsMeds;

  /// No description provided for @aiConsistencyProcTitle.
  ///
  /// In en, this message translates to:
  /// **'You consented to {name} yourself — the printed form will also state your agent is NOT authorized to consent to {name}.'**
  String aiConsistencyProcTitle(String name);

  /// No description provided for @aiConsistencyProcBody.
  ///
  /// In en, this message translates to:
  /// **'Pennsylvania’s form lets you do both: give your own consent AND authorize your agent to consent on your behalf (that agent authorization needs your physical initials, §5836(c)). As entered, only your own consent is recorded, so the document says your agent may not consent to {name}. That is allowed and may be exactly what you intend — keep both if so. If you also want your agent able to consent (e.g. if you later can’t decide), choose “My agent will decide” for {name}.'**
  String aiConsistencyProcBody(String name);

  /// No description provided for @aiConsistencyProcA.
  ///
  /// In en, this message translates to:
  /// **'You consent to {name}'**
  String aiConsistencyProcA(String name);

  /// No description provided for @aiConsistencyProcB.
  ///
  /// In en, this message translates to:
  /// **'Agent not authorized: {name}'**
  String aiConsistencyProcB(String name);

  /// No description provided for @aiConsistencyProcAction.
  ///
  /// In en, this message translates to:
  /// **'Review {name} choice'**
  String aiConsistencyProcAction(String name);

  /// No description provided for @aiConsistencyProcEct.
  ///
  /// In en, this message translates to:
  /// **'ECT'**
  String get aiConsistencyProcEct;

  /// No description provided for @aiConsistencyProcExperimental.
  ///
  /// In en, this message translates to:
  /// **'experimental studies'**
  String get aiConsistencyProcExperimental;

  /// No description provided for @aiConsistencyProcDrugTrials.
  ///
  /// In en, this message translates to:
  /// **'drug trials'**
  String get aiConsistencyProcDrugTrials;

  /// No description provided for @aiConsistencyAgentDecidesMeds.
  ///
  /// In en, this message translates to:
  /// **'Agent decides medications'**
  String get aiConsistencyAgentDecidesMeds;

  /// No description provided for @aiConsistencyAgentNotAuthorizedMeds.
  ///
  /// In en, this message translates to:
  /// **'Agent not authorized: medications'**
  String get aiConsistencyAgentNotAuthorizedMeds;

  /// No description provided for @aiConsistencyEditMedications.
  ///
  /// In en, this message translates to:
  /// **'Edit Medications'**
  String get aiConsistencyEditMedications;

  /// No description provided for @aiConsistencyEditAgentAuthority.
  ///
  /// In en, this message translates to:
  /// **'Edit Agent authority'**
  String get aiConsistencyEditAgentAuthority;

  /// No description provided for @aiConsistencyNoMedsYou.
  ///
  /// In en, this message translates to:
  /// **'No medications (you)'**
  String get aiConsistencyNoMedsYou;

  /// No description provided for @aiConsistencyAgentMayConsentMeds.
  ///
  /// In en, this message translates to:
  /// **'Agent may consent: medications'**
  String get aiConsistencyAgentMayConsentMeds;

  /// No description provided for @aiConsistencySetupAiInvite.
  ///
  /// In en, this message translates to:
  /// **'Set up the free AI assistant for an additional AI-powered review that suggests gaps and things to double-check. Optional — the rule-based check above always runs without it.'**
  String get aiConsistencySetupAiInvite;

  /// No description provided for @aiConsistencyNoSuggestions.
  ///
  /// In en, this message translates to:
  /// **'The AI did not return any suggestions.'**
  String get aiConsistencyNoSuggestions;

  /// No description provided for @aiConsistencyNotAdviceOptional.
  ///
  /// In en, this message translates to:
  /// **'{notAdvice} Optional suggestions based only on what you entered.'**
  String aiConsistencyNotAdviceOptional(String notAdvice);

  /// No description provided for @aiConsistencyCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t run the consistency check.\n{error}'**
  String aiConsistencyCheckFailed(String error);

  /// No description provided for @aiConsistencyThingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thing} other{{count} things}}'**
  String aiConsistencyThingsCount(int count);

  /// No description provided for @aiConsistencyAllConsistent.
  ///
  /// In en, this message translates to:
  /// **'Everything looks internally consistent.'**
  String get aiConsistencyAllConsistent;

  /// No description provided for @aiConsistencyWarningsOnly.
  ///
  /// In en, this message translates to:
  /// **'These won\'t block you from generating the PDF — they are warnings you can fix or ignore.'**
  String get aiConsistencyWarningsOnly;

  /// No description provided for @aiConsistencyNoContradictions.
  ///
  /// In en, this message translates to:
  /// **'No cross-step contradictions detected.'**
  String get aiConsistencyNoContradictions;

  /// No description provided for @aiConsistencyRulesExplainer.
  ///
  /// In en, this message translates to:
  /// **'The contradiction check above is built-in rules. When the AI assistant is set up, an additional AI review adds optional suggestions. Review anything before accepting — this screen warns; it doesn\'t block PDF generation.'**
  String get aiConsistencyRulesExplainer;

  /// No description provided for @aiConsistencyConflictHeader.
  ///
  /// In en, this message translates to:
  /// **'CONFLICT · {number} · {steps}'**
  String aiConsistencyConflictHeader(int number, String steps);

  /// No description provided for @aiConsistencyVs.
  ///
  /// In en, this message translates to:
  /// **'vs'**
  String get aiConsistencyVs;

  /// No description provided for @crisisPlanHowIKnowIM.
  ///
  /// In en, this message translates to:
  /// **'How I know I\'m not okay'**
  String get crisisPlanHowIKnowIM;

  /// No description provided for @crisisPlanHeadsUpThisSectionIs.
  ///
  /// In en, this message translates to:
  /// **'Heads up: this section is yours alone — it isn\'t required by PA Act 194, but in practice it\'s the part agents and ER staff read first.'**
  String get crisisPlanHeadsUpThisSectionIs;

  /// No description provided for @permissionsOverviewOnlyWhatWeNeed.
  ///
  /// In en, this message translates to:
  /// **'Only what we need.'**
  String get permissionsOverviewOnlyWhatWeNeed;

  /// No description provided for @permissionsOverviewPermissionsAreManagedByYour.
  ///
  /// In en, this message translates to:
  /// **'Permissions are managed by your device, not by this app. Open your device\'s Settings → PA MHAD to grant, revoke, or review any of the above at any time.'**
  String get permissionsOverviewPermissionsAreManagedByYour;

  /// No description provided for @permissionsOverviewNoAnalyticsNoTrackingPixels.
  ///
  /// In en, this message translates to:
  /// **'No analytics. No tracking pixels. No cookies. No third-party SDKs for advertising or measurement. The only outbound flows are the opt-in AI features (your chosen AI provider) and NLM medical-reference lookups, both with PII stripping at a single chokepoint.'**
  String get permissionsOverviewNoAnalyticsNoTrackingPixels;

  /// No description provided for @makeItFindableMakeItFindableInA.
  ///
  /// In en, this message translates to:
  /// **'Make it findable in a crisis.'**
  String get makeItFindableMakeItFindableInA;

  /// No description provided for @makeItFindablePennsylvaniaHasNoStatewideDirective.
  ///
  /// In en, this message translates to:
  /// **'Pennsylvania has no statewide directive registry, so the people in your life are the registry: make sure your agent, a trusted person, and your providers all know you have a directive and where to find it.'**
  String get makeItFindablePennsylvaniaHasNoStatewideDirective;

  /// No description provided for @makeItFindableUnderPaAct194A.
  ///
  /// In en, this message translates to:
  /// **'Under PA Act 194, a valid directive your care team can find is meant to be followed. Findability is what makes it work.'**
  String get makeItFindableUnderPaAct194A;

  /// No description provided for @revocationAreYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get revocationAreYouSure;

  /// No description provided for @revocationPutItInWritingSign.
  ///
  /// In en, this message translates to:
  /// **'Put it in writing — sign and date a short statement that you are revoking this directive.'**
  String get revocationPutItInWritingSign;

  /// No description provided for @revocationTellYourAgentYourProviders.
  ///
  /// In en, this message translates to:
  /// **'Tell your agent, your providers, and anyone holding a copy.'**
  String get revocationTellYourAgentYourProviders;

  /// No description provided for @revocationDestroyOldCopiesOrClearly.
  ///
  /// In en, this message translates to:
  /// **'Destroy old copies, or clearly mark them “REVOKED”.'**
  String get revocationDestroyOldCopiesOrClearly;

  /// No description provided for @revocationIfYouHaveAnyFurther.
  ///
  /// In en, this message translates to:
  /// **'If you have any further questions about how revocation applies to you, it is wise to consult an attorney for clarification.'**
  String get revocationIfYouHaveAnyFurther;

  /// No description provided for @pastDirectiveDetailNoShareHistoryIsKept.
  ///
  /// In en, this message translates to:
  /// **'No share history is kept — nothing is saved after you close the app, so this list is empty by design.'**
  String get pastDirectiveDetailNoShareHistoryIsKept;

  /// No description provided for @wizardAiRailFullView.
  ///
  /// In en, this message translates to:
  /// **'Full view'**
  String get wizardAiRailFullView;

  /// No description provided for @wizardAiRailYourApiKeyStaysOn.
  ///
  /// In en, this message translates to:
  /// **'Your API key stays on this device and is only used to answer your questions. You can fill out the whole wizard without it.'**
  String get wizardAiRailYourApiKeyStaysOn;

  /// No description provided for @wizardAiRailReadingThisStep.
  ///
  /// In en, this message translates to:
  /// **'Reading this step…'**
  String get wizardAiRailReadingThisStep;

  /// No description provided for @wizardAiRailSuggestedForThisStep.
  ///
  /// In en, this message translates to:
  /// **'SUGGESTED FOR THIS STEP'**
  String get wizardAiRailSuggestedForThisStep;

  /// No description provided for @wizardAiRailAskAnythingAboutThisStep.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about this step — answers appear here, and in the full assistant.'**
  String get wizardAiRailAskAnythingAboutThisStep;

  /// No description provided for @wizardAiRailNeedHelpWithThisStep.
  ///
  /// In en, this message translates to:
  /// **'Need help with this step? Ask the AI'**
  String get wizardAiRailNeedHelpWithThisStep;

  /// No description provided for @wizardAiRailAiHelpIsOffThe.
  ///
  /// In en, this message translates to:
  /// **'AI help is off. The step heads-up, suggested questions, photo auto-fill, and the chat below aren\'t available until you set up AI.'**
  String get wizardAiRailAiHelpIsOffThe;

  /// No description provided for @wizardAiRailCheckingThisStep.
  ///
  /// In en, this message translates to:
  /// **'Checking this step'**
  String get wizardAiRailCheckingThisStep;

  /// No description provided for @wizardAiRailFindAPaFacilityBy.
  ///
  /// In en, this message translates to:
  /// **'Find a PA facility by name or county…'**
  String get wizardAiRailFindAPaFacilityBy;

  /// No description provided for @wizardAiRailThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get wizardAiRailThinking;

  /// No description provided for @wizardAiRailAskAboutThisStep.
  ///
  /// In en, this message translates to:
  /// **'Ask about this step…'**
  String get wizardAiRailAskAboutThisStep;

  /// No description provided for @wizardAiRailSending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get wizardAiRailSending;

  /// No description provided for @sideEffectsBringAnythingYouCheckAnd.
  ///
  /// In en, this message translates to:
  /// **'Bring anything you check — and especially anything marked \"discuss with your doctor\" — to your doctor or pharmacist. This list never tells you to start, stop, or change a medication.'**
  String get sideEffectsBringAnythingYouCheckAnd;

  /// No description provided for @sideEffectsTheseArePossibleInteractionsDrawn.
  ///
  /// In en, this message translates to:
  /// **'These are possible interactions drawn from the medications’ FDA labels, written as questions to ask. They are not a warning to stop or change anything yourself — only your doctor or pharmacist can advise on your specific case.'**
  String get sideEffectsTheseArePossibleInteractionsDrawn;

  /// No description provided for @sideEffectsAddTheMedicationsYouRe.
  ///
  /// In en, this message translates to:
  /// **'Add the medications you\'re currently taking on the Medications step first, then come back here to check their common side effects.'**
  String get sideEffectsAddTheMedicationsYouRe;

  /// No description provided for @audioGuideToTranscribeYourRecordingIncluding.
  ///
  /// In en, this message translates to:
  /// **'To transcribe, your recording — including any personal details you speak — is sent to Google\'s AI. On the free tier it may be retained and reviewed, and can\'t be recalled. Don\'t say anything you\'re not comfortable sending; you can always type sensitive fields by hand instead.'**
  String get audioGuideToTranscribeYourRecordingIncluding;

  /// No description provided for @ulyssesClauseIfFutureMeRefuses.
  ///
  /// In en, this message translates to:
  /// **'If future-me refuses…'**
  String get ulyssesClauseIfFutureMeRefuses;

  /// No description provided for @ulyssesClauseStronglyRecommendedTalkWithA.
  ///
  /// In en, this message translates to:
  /// **'Strongly recommended: talk with a peer specialist or clinician before saving. See \"Get help\" in Settings.'**
  String get ulyssesClauseStronglyRecommendedTalkWithA;

  /// No description provided for @aiSetupIsTheApiKeyReally.
  ///
  /// In en, this message translates to:
  /// **'Is the API key really free?'**
  String get aiSetupIsTheApiKeyReally;

  /// No description provided for @aiSetupYesGoogleOffersAGenerous.
  ///
  /// In en, this message translates to:
  /// **'Yes. Google offers a generous free tier for Gemini. There is no credit card required and no charge for typical personal use.'**
  String get aiSetupYesGoogleOffersAGenerous;

  /// No description provided for @aiSetupWhatGoogleAccountShouldI.
  ///
  /// In en, this message translates to:
  /// **'What Google account should I use?'**
  String get aiSetupWhatGoogleAccountShouldI;

  /// No description provided for @aiSetupAnyGoogleAccountWorksA.
  ///
  /// In en, this message translates to:
  /// **'Any Google account works — a personal Gmail is fine. You do not need a Google Cloud billing account.'**
  String get aiSetupAnyGoogleAccountWorksA;

  /// No description provided for @aiSetupCanIRevokeTheKey.
  ///
  /// In en, this message translates to:
  /// **'Can I revoke the key later?'**
  String get aiSetupCanIRevokeTheKey;

  /// No description provided for @aiSetupYesVisitAistudioGoogleCom.
  ///
  /// In en, this message translates to:
  /// **'Yes. Visit aistudio.google.com/apikey at any time to delete or regenerate your key. You can also remove it from this app using the trash icon in the top-right.'**
  String get aiSetupYesVisitAistudioGoogleCom;

  /// No description provided for @aiSetupWhatIfIDonT.
  ///
  /// In en, this message translates to:
  /// **'What if I don\'t add a key?'**
  String get aiSetupWhatIfIDonT;

  /// No description provided for @aiSetupTheAppWorksFullyWithout.
  ///
  /// In en, this message translates to:
  /// **'The app works fully without AI. The form wizard, PDF generation, educational content, and all other features do not require an API key. AI is purely optional.'**
  String get aiSetupTheAppWorksFullyWithout;

  /// No description provided for @accessibilitySettingsMakeItReadable.
  ///
  /// In en, this message translates to:
  /// **'Make it readable.'**
  String get accessibilitySettingsMakeItReadable;

  /// No description provided for @accessibilitySettingsLegalTextIsAlwaysRendered.
  ///
  /// In en, this message translates to:
  /// **'Legal text is always rendered in English to preserve PA Act 194 wording.'**
  String get accessibilitySettingsLegalTextIsAlwaysRendered;

  /// No description provided for @facilitatorYouDonTHaveTo.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to do this alone.'**
  String get facilitatorYouDonTHaveTo;

  /// No description provided for @facilitatorPeerSpecialistAdvocateReferral.
  ///
  /// In en, this message translates to:
  /// **'♥ Peer specialist / advocate referral'**
  String get facilitatorPeerSpecialistAdvocateReferral;

  /// No description provided for @facilitatorSomeoneIAlreadyTrust.
  ///
  /// In en, this message translates to:
  /// **'👥 Someone I already trust'**
  String get facilitatorSomeoneIAlreadyTrust;

  /// No description provided for @facilitatorMyCareTeam.
  ///
  /// In en, this message translates to:
  /// **'🧠 My care team'**
  String get facilitatorMyCareTeam;

  /// No description provided for @facilitatorPreferToDoItYourself.
  ///
  /// In en, this message translates to:
  /// **'Prefer to do it yourself? That\'s fine — keep going from where you left off.'**
  String get facilitatorPreferToDoItYourself;

  /// No description provided for @moreSheetCallOrText98824.
  ///
  /// In en, this message translates to:
  /// **'Call or text 988 · 24/7 support'**
  String get moreSheetCallOrText98824;

  /// No description provided for @moreSheetUploadADocumentPhotoOr.
  ///
  /// In en, this message translates to:
  /// **'Upload a document, photo, or recording'**
  String get moreSheetUploadADocumentPhotoOr;

  /// No description provided for @moreSheetPreviewAndExportYourDirective.
  ///
  /// In en, this message translates to:
  /// **'Preview and export your directive packet'**
  String get moreSheetPreviewAndExportYourDirective;

  /// No description provided for @moreSheetEraseThisSessionAndStart.
  ///
  /// In en, this message translates to:
  /// **'Erase this session and start fresh'**
  String get moreSheetEraseThisSessionAndStart;

  /// No description provided for @crisisSheetYouAreNotAlone.
  ///
  /// In en, this message translates to:
  /// **'You are not alone.'**
  String get crisisSheetYouAreNotAlone;

  /// No description provided for @crisisSheetCallOrText988.
  ///
  /// In en, this message translates to:
  /// **'Call or text 988'**
  String get crisisSheetCallOrText988;

  /// No description provided for @crisisSheetCall988Press1.
  ///
  /// In en, this message translates to:
  /// **'Call 988, press 1'**
  String get crisisSheetCall988Press1;

  /// No description provided for @crisisSheetCallTextChat.
  ///
  /// In en, this message translates to:
  /// **'Call · text · chat'**
  String get crisisSheetCallTextChat;

  /// No description provided for @assistantSenderYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get assistantSenderYou;

  /// No description provided for @assistantSenderAi.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get assistantSenderAi;

  /// No description provided for @aiSetupApiKeySetForThis.
  ///
  /// In en, this message translates to:
  /// **'API key set for this session'**
  String get aiSetupApiKeySetForThis;

  /// No description provided for @aiSetupApiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'API key saved'**
  String get aiSetupApiKeySaved;

  /// No description provided for @aiSetupGetYourFreeGeminiApi.
  ///
  /// In en, this message translates to:
  /// **'Get Your Free Gemini API Key'**
  String get aiSetupGetYourFreeGeminiApi;

  /// No description provided for @aiSetupAddYourApiKey.
  ///
  /// In en, this message translates to:
  /// **'Add Your {label} API Key'**
  String aiSetupAddYourApiKey(Object label);

  /// No description provided for @aiSetupTheAssistantUsesGoogleS.
  ///
  /// In en, this message translates to:
  /// **'The assistant uses Google\'s Gemini model. You need a free API key from Google AI Studio — it takes about 30 seconds.'**
  String get aiSetupTheAssistantUsesGoogleS;

  /// No description provided for @aiSetupYouBringYourOwnApi.
  ///
  /// In en, this message translates to:
  /// **'You bring your own {label} API key. Your provider\'s usage limits and billing apply — this app never sees or charges for your usage. Gemini stays the free default if you\'d rather not pay.'**
  String aiSetupYouBringYourOwnApi(Object label);

  /// No description provided for @aiSetupOpenGoogleAiStudioIn.
  ///
  /// In en, this message translates to:
  /// **'Open Google AI Studio (in your private window)'**
  String get aiSetupOpenGoogleAiStudioIn;

  /// No description provided for @aiSetupOpenInYourPrivateWindow.
  ///
  /// In en, this message translates to:
  /// **'Open {label} (in your private window)'**
  String aiSetupOpenInYourPrivateWindow(Object label);

  /// No description provided for @aiSetupUseAnyGoogleAccountPersonal.
  ///
  /// In en, this message translates to:
  /// **'Use any Google account (personal Gmail works fine)'**
  String get aiSetupUseAnyGoogleAccountPersonal;

  /// No description provided for @aiSetupSignInThenOpenThe.
  ///
  /// In en, this message translates to:
  /// **'Sign in, then open the API keys page'**
  String get aiSetupSignInThenOpenThe;

  /// No description provided for @aiSetupOpenAiStudio.
  ///
  /// In en, this message translates to:
  /// **'Open AI Studio'**
  String get aiSetupOpenAiStudio;

  /// No description provided for @aiSetupOpen.
  ///
  /// In en, this message translates to:
  /// **'Open {label}'**
  String aiSetupOpen(Object label);

  /// No description provided for @aiSetupSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get aiSetupSignInWithGoogle;

  /// No description provided for @aiSetupSignInTo.
  ///
  /// In en, this message translates to:
  /// **'Sign in to {label}'**
  String aiSetupSignInTo(Object label);

  /// No description provided for @aiSetupNoCreditCardOrPayment.
  ///
  /// In en, this message translates to:
  /// **'No credit card or payment is needed. The free tier is generous and sufficient for this app.'**
  String get aiSetupNoCreditCardOrPayment;

  /// No description provided for @aiSetupMostProvidersRequireAPaid.
  ///
  /// In en, this message translates to:
  /// **'Most providers require a paid account with credits to use the API. Your provider bills you directly.'**
  String get aiSetupMostProvidersRequireAPaid;

  /// No description provided for @aiSetupKeySetForThisSession.
  ///
  /// In en, this message translates to:
  /// **'Key set for this session'**
  String get aiSetupKeySetForThisSession;

  /// No description provided for @aiSetupKeySaved.
  ///
  /// In en, this message translates to:
  /// **'Key saved'**
  String get aiSetupKeySaved;

  /// No description provided for @aiSetupShowApiKey.
  ///
  /// In en, this message translates to:
  /// **'Show API key'**
  String get aiSetupShowApiKey;

  /// No description provided for @aiSetupHideApiKey.
  ///
  /// In en, this message translates to:
  /// **'Hide API key'**
  String get aiSetupHideApiKey;

  /// No description provided for @aiSetupUseKeyForThisSession.
  ///
  /// In en, this message translates to:
  /// **'Use Key for This Session'**
  String get aiSetupUseKeyForThisSession;

  /// No description provided for @aiSetupSaveApiKey.
  ///
  /// In en, this message translates to:
  /// **'Save API Key'**
  String get aiSetupSaveApiKey;

  /// No description provided for @aiSetupTesting.
  ///
  /// In en, this message translates to:
  /// **'Testing…'**
  String get aiSetupTesting;

  /// No description provided for @aiSetupTestConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get aiSetupTestConnection;

  /// No description provided for @aiSetupThatDoesnTLookLike.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a valid {label} key ({keyHint}).'**
  String aiSetupThatDoesnTLookLike(Object label, Object keyHint);

  /// No description provided for @aiSetupCouldNotPasteTryPasting.
  ///
  /// In en, this message translates to:
  /// **'Could not paste. Try pasting manually ({pasteShortcutLabel}).'**
  String aiSetupCouldNotPasteTryPasting(Object pasteShortcutLabel);

  /// No description provided for @aiSetupMayBeBlockedByYour.
  ///
  /// In en, this message translates to:
  /// **'{label} may be blocked by your browser\'s security (CORS) on the web. If it doesn\'t respond, pick Gemini or Claude — both work in the browser.'**
  String aiSetupMayBeBlockedByYour(Object label);

  /// No description provided for @aiSetupTheKeyLooksLikeCopy.
  ///
  /// In en, this message translates to:
  /// **'The key looks like \"{keyHint}\" — copy it, then use the paste button or paste it manually.'**
  String aiSetupTheKeyLooksLikeCopy(Object keyHint);

  /// No description provided for @aiSetupApiKey.
  ///
  /// In en, this message translates to:
  /// **'{label} API Key'**
  String aiSetupApiKey(Object label);

  /// No description provided for @adminUpdateBlankUseTheAppS.
  ///
  /// In en, this message translates to:
  /// **'Blank = use the app\'s saved Gemini key. Not stored.'**
  String get adminUpdateBlankUseTheAppS;

  /// No description provided for @adminUpdateEnteredForThisSessionOnly.
  ///
  /// In en, this message translates to:
  /// **'Entered for this session only — not stored.'**
  String get adminUpdateEnteredForThisSessionOnly;

  /// No description provided for @adminUpdateDrafting.
  ///
  /// In en, this message translates to:
  /// **'Drafting…'**
  String get adminUpdateDrafting;

  /// No description provided for @adminUpdateStartUpdateWithAi.
  ///
  /// In en, this message translates to:
  /// **'Start update with AI'**
  String get adminUpdateStartUpdateWithAi;

  /// No description provided for @adminUpdateRestoreFromBackupFieldS.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup: {changesLength} field(s) differ from the previous version of {assetPath}. Tick the part(s) to roll back (all pre-ticked = full revert).'**
  String adminUpdateRestoreFromBackupFieldS(
    Object changesLength,
    Object assetPath,
  );

  /// No description provided for @adminUpdateProposedChangeSReviewEach.
  ///
  /// In en, this message translates to:
  /// **'{changesLength} proposed change(s). Review each — tick VERIFY items only if you have confirmed them.'**
  String adminUpdateProposedChangeSReviewEach(Object changesLength);

  /// No description provided for @adminUpdateVerifyTierChangeSNot.
  ///
  /// In en, this message translates to:
  /// **'{verifyCount} verify-tier change(s) not yet approved'**
  String adminUpdateVerifyTierChangeSNot(Object verifyCount);

  /// No description provided for @adminUpdateReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get adminUpdateReady;

  /// No description provided for @adminUpdateBuildRestoredJson.
  ///
  /// In en, this message translates to:
  /// **'Build restored JSON'**
  String get adminUpdateBuildRestoredJson;

  /// No description provided for @adminUpdateBuildUpdatedJson.
  ///
  /// In en, this message translates to:
  /// **'Build updated JSON'**
  String get adminUpdateBuildUpdatedJson;

  /// No description provided for @adminUpdateContextInOut.
  ///
  /// In en, this message translates to:
  /// **'{displayName}\n{note}\ncontext {inputTokenLimit} in / {outputTokenLimit} out'**
  String adminUpdateContextInOut(
    Object displayName,
    Object note,
    Object inputTokenLimit,
    Object outputTokenLimit,
  );

  /// No description provided for @adminUpdateBestGeminiModelNow.
  ///
  /// In en, this message translates to:
  /// **'Best Gemini model (now: {currentModel})'**
  String adminUpdateBestGeminiModelNow(Object currentModel);

  /// No description provided for @adminUpdateCheckTheNewestModelsLive.
  ///
  /// In en, this message translates to:
  /// **'Check the newest {label} models (live API)'**
  String adminUpdateCheckTheNewestModelsLive(Object label);

  /// No description provided for @adminUpdateApiKey.
  ///
  /// In en, this message translates to:
  /// **'{label} API key'**
  String adminUpdateApiKey(Object label);

  /// No description provided for @adminUpdateSource.
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String adminUpdateSource(Object source);

  /// No description provided for @adminUpdateRestoredTheSelectedFieldS.
  ///
  /// In en, this message translates to:
  /// **'RESTORED — the selected field(s) have been rolled back to the backup. Commit this over {assetPath} to apply the roll-back.'**
  String adminUpdateRestoredTheSelectedFieldS(Object assetPath);

  /// No description provided for @adminUpdateUpdatedReplaceThatFileWith.
  ///
  /// In en, this message translates to:
  /// **'Updated {assetPath}. Replace that file with this and commit — the release makes it live for everyone.'**
  String adminUpdateUpdatedReplaceThatFileWith(Object assetPath);

  /// No description provided for @reminderSheetsTimeToRenew.
  ///
  /// In en, this message translates to:
  /// **'Time to renew.'**
  String get reminderSheetsTimeToRenew;

  /// No description provided for @reminderSheetsTimeToRenew2.
  ///
  /// In en, this message translates to:
  /// **'Time to renew, {firstName}.'**
  String reminderSheetsTimeToRenew2(Object firstName);

  /// No description provided for @reminderSheetsExpires.
  ///
  /// In en, this message translates to:
  /// **'● Expires {dayLabel}'**
  String reminderSheetsExpires(Object dayLabel);

  /// No description provided for @revocationWillBeReferencedInYour.
  ///
  /// In en, this message translates to:
  /// **'Will be referenced in your revocation letter'**
  String get revocationWillBeReferencedInYour;

  /// No description provided for @revocationTapToInclude.
  ///
  /// In en, this message translates to:
  /// **'Tap to include'**
  String get revocationTapToInclude;

  /// No description provided for @revocationRevoking.
  ///
  /// In en, this message translates to:
  /// **'Revoking…'**
  String get revocationRevoking;

  /// No description provided for @revocationRevokeNow.
  ///
  /// In en, this message translates to:
  /// **'Revoke now'**
  String get revocationRevokeNow;

  /// No description provided for @pastDirectiveDetailUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load: {error}'**
  String pastDirectiveDetailUnableToLoad(Object error);

  /// No description provided for @pastDirectiveDetailTheDirectiveRemainsRegardless.
  ///
  /// In en, this message translates to:
  /// **'The directive remains {status} regardless'**
  String pastDirectiveDetailTheDirectiveRemainsRegardless(Object status);

  /// No description provided for @pinDialogShowPasscode.
  ///
  /// In en, this message translates to:
  /// **'Show passcode'**
  String get pinDialogShowPasscode;

  /// No description provided for @pinDialogHidePasscode.
  ///
  /// In en, this message translates to:
  /// **'Hide passcode'**
  String get pinDialogHidePasscode;

  /// No description provided for @modeSelectionOnTheWebYourData.
  ///
  /// In en, this message translates to:
  /// **'On the web your data is kept in memory only and is never sent to a server, so encrypted on-device (Private mode) storage is not available here.'**
  String get modeSelectionOnTheWebYourData;

  /// No description provided for @modeSelectionThisAppIsNotHipaa.
  ///
  /// In en, this message translates to:
  /// **'This app is not HIPAA-compliant. Nothing is sent to a server for storage.'**
  String get modeSelectionThisAppIsNotHipaa;

  /// No description provided for @modeSelectionSelect.
  ///
  /// In en, this message translates to:
  /// **'Select {title}{recommended}'**
  String modeSelectionSelect(Object title, Object recommended);

  /// No description provided for @sideEffectsCheckingCovers.
  ///
  /// In en, this message translates to:
  /// **'Checking covers: {currentMedsJoin}'**
  String sideEffectsCheckingCovers(Object currentMedsJoin);

  /// No description provided for @sideEffectsReCheckFor.
  ///
  /// In en, this message translates to:
  /// **'Re-check for: {currentMedsJoin}'**
  String sideEffectsReCheckFor(Object currentMedsJoin);

  /// No description provided for @sideEffectsCheckSideEffects.
  ///
  /// In en, this message translates to:
  /// **'Check side effects'**
  String get sideEffectsCheckSideEffects;

  /// No description provided for @sideEffectsReCheck.
  ///
  /// In en, this message translates to:
  /// **'Re-check'**
  String get sideEffectsReCheck;

  /// No description provided for @sideEffectsMayAffect.
  ///
  /// In en, this message translates to:
  /// **'May affect: {adlImpact}'**
  String sideEffectsMayAffect(Object adlImpact);

  /// No description provided for @educationCategoryBrowserSections.
  ///
  /// In en, this message translates to:
  /// **'{title}, {count} sections. {sub}'**
  String educationCategoryBrowserSections(
    Object title,
    Object count,
    Object sub,
  );

  /// No description provided for @learnAiPanelAskAQuestionToGet.
  ///
  /// In en, this message translates to:
  /// **'Ask a question to get started — e.g. \"What\'s the difference between a declaration and a power of attorney?\"'**
  String get learnAiPanelAskAQuestionToGet;

  /// No description provided for @learnAiPanelSetUpTheFreeAi.
  ///
  /// In en, this message translates to:
  /// **'Set up the free AI assistant to ask questions while you read.'**
  String get learnAiPanelSetUpTheFreeAi;

  /// No description provided for @learnAiPanelPiiStripped.
  ///
  /// In en, this message translates to:
  /// **'● {nameToUpperCase} · PII STRIPPED'**
  String learnAiPanelPiiStripped(Object nameToUpperCase);

  /// No description provided for @educationArticleDetailQuestionsContactPaProtectionAdvocacy.
  ///
  /// In en, this message translates to:
  /// **'Questions? Contact PA Protection & Advocacy: {paProtectionAdvocacy}'**
  String educationArticleDetailQuestionsContactPaProtectionAdvocacy(
    Object paProtectionAdvocacy,
  );

  /// No description provided for @audioGuideExample.
  ///
  /// In en, this message translates to:
  /// **'Example: {example}'**
  String audioGuideExample(Object example);

  /// No description provided for @exportCardsExecuted.
  ///
  /// In en, this message translates to:
  /// **'Executed: {executionDate}'**
  String exportCardsExecuted(Object executionDate);

  /// No description provided for @exportCardsExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires: {expirationDate}'**
  String exportCardsExpires(Object expirationDate);

  /// No description provided for @pdfPreviewFit.
  ///
  /// In en, this message translates to:
  /// **'FIT'**
  String get pdfPreviewFit;

  /// No description provided for @pdfPreviewPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {pageCount}'**
  String pdfPreviewPageOf(Object current, Object pageCount);

  /// No description provided for @pdfPreviewGoToPage.
  ///
  /// In en, this message translates to:
  /// **'Go to page {i}'**
  String pdfPreviewGoToPage(Object i);

  /// No description provided for @pdfPreviewPage.
  ///
  /// In en, this message translates to:
  /// **'Page {i}'**
  String pdfPreviewPage(Object i);

  /// No description provided for @exportGeneratingPdfPreview.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF preview'**
  String get exportGeneratingPdfPreview;

  /// No description provided for @exportPreviewPdfBeforeSharing.
  ///
  /// In en, this message translates to:
  /// **'Preview PDF before sharing'**
  String get exportPreviewPdfBeforeSharing;

  /// No description provided for @exportTheFollowingFieldsAreEmpty.
  ///
  /// In en, this message translates to:
  /// **'The following fields are empty or missing:\n\n{n}\n\nAn incomplete directive may not be legally valid under PA Act 194. Export anyway?'**
  String exportTheFollowingFieldsAreEmpty(Object n);

  /// No description provided for @privacyPolicyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {privacyPolicyUpdated} ({privacyPolicyVersion})'**
  String privacyPolicyLastUpdated(
    Object privacyPolicyUpdated,
    Object privacyPolicyVersion,
  );

  /// No description provided for @privacyPolicyYouCanReachTheDeveloper.
  ///
  /// In en, this message translates to:
  /// **'The FTC Health Breach Notification Rule requires at least two contact methods. We provide:\n\n  - In-app: an in-app breach notice will be shown the next time you open the app if a breach affects you.\n  - Online: {privacyPolicyUrl} (also used for breach postings if direct contact information is insufficient).'**
  String privacyPolicyYouCanReachTheDeveloper(Object privacyPolicyUrl);

  /// No description provided for @settingsScreenshotsAreBlocked.
  ///
  /// In en, this message translates to:
  /// **'Screenshots are blocked'**
  String get settingsScreenshotsAreBlocked;

  /// No description provided for @settingsScreenshotsAreAllowed.
  ///
  /// In en, this message translates to:
  /// **'Screenshots are allowed'**
  String get settingsScreenshotsAreAllowed;

  /// No description provided for @assistantMessageWidgetsAt.
  ///
  /// In en, this message translates to:
  /// **'{sender} at {timeStr}: {content}'**
  String assistantMessageWidgetsAt(
    Object sender,
    Object timeStr,
    Object content,
  );

  /// No description provided for @assistantActiveTextPiiStrippedBefore.
  ///
  /// In en, this message translates to:
  /// **'● ACTIVE · {model} · TEXT PII STRIPPED BEFORE SEND'**
  String assistantActiveTextPiiStrippedBefore(Object model);

  /// No description provided for @assistantNotSetUpAddA.
  ///
  /// In en, this message translates to:
  /// **'○ NOT SET UP · ADD A KEY TO USE THE AI'**
  String get assistantNotSetUpAddA;

  /// No description provided for @assistantOlderMessagesWereTrimmedTo.
  ///
  /// In en, this message translates to:
  /// **'{trimmedCount} older messages were trimmed to fit within the AI\'s context limit. Recent messages are preserved.'**
  String assistantOlderMessagesWereTrimmedTo(Object trimmedCount);

  /// No description provided for @assistantNotLegalOrMedicalAdvice.
  ///
  /// In en, this message translates to:
  /// **'Not legal or medical advice. For legal questions contact PA Protection & Advocacy: {paProtectionAdvocacy}'**
  String assistantNotLegalOrMedicalAdvice(Object paProtectionAdvocacy);

  /// No description provided for @assistantFreeTierRequestsMinRequests.
  ///
  /// In en, this message translates to:
  /// **'{model} free tier:\n{maxRpm} requests/min\n{maxRpd} requests/day\n{tpmK}K tokens/min\n{contextK}K max context'**
  String assistantFreeTierRequestsMinRequests(
    Object model,
    Object maxRpm,
    Object maxRpd,
    Object tpmK,
    Object contextK,
  );

  /// No description provided for @homeToolsGridSuggestsChecks.
  ///
  /// In en, this message translates to:
  /// **'Suggests + checks'**
  String get homeToolsGridSuggestsChecks;

  /// No description provided for @homeToolsGridShareCarry.
  ///
  /// In en, this message translates to:
  /// **'Share + carry'**
  String get homeToolsGridShareCarry;

  /// No description provided for @homeToolsGridNoDirectiveYet.
  ///
  /// In en, this message translates to:
  /// **'No directive yet'**
  String get homeToolsGridNoDirectiveYet;

  /// No description provided for @homeDirectiveHeroContinueYourLastEdited.
  ///
  /// In en, this message translates to:
  /// **'Continue your {formLabel} — {pctLabel}, last edited {lastEdited}'**
  String homeDirectiveHeroContinueYourLastEdited(
    Object formLabel,
    Object pctLabel,
    Object lastEdited,
  );

  /// No description provided for @homeDirectiveHeroStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {currentStep} of {totalSteps}'**
  String homeDirectiveHeroStepOf(Object currentStep, Object totalSteps);

  /// No description provided for @homeDirectiveHeroLastEdited.
  ///
  /// In en, this message translates to:
  /// **'{formLabel} · last edited {lastEdited}'**
  String homeDirectiveHeroLastEdited(Object formLabel, Object lastEdited);

  /// No description provided for @facilitatorPickTheKindOfSupport.
  ///
  /// In en, this message translates to:
  /// **'{facilitatorCompletionStat} Pick the kind of support that fits today.'**
  String facilitatorPickTheKindOfSupport(Object facilitatorCompletionStat);

  /// No description provided for @disclaimerYouWorkAnonymouslyInThis.
  ///
  /// In en, this message translates to:
  /// **'You work anonymously in this browser tab — no account, no cloud, no tracking. If you close the tab your work is kept on this device for about 10 minutes for recovery, then wiped — open and save your PDF to keep it.'**
  String get disclaimerYouWorkAnonymouslyInThis;

  /// No description provided for @disclaimerNoAccountNoCloudNo.
  ///
  /// In en, this message translates to:
  /// **'No account, no cloud, no tracking — nothing goes to our servers. Anything you save stays encrypted on this device, where only you can open it.'**
  String get disclaimerNoAccountNoCloudNo;

  /// No description provided for @draftRecoveryDialogItLooksLikeTheApp.
  ///
  /// In en, this message translates to:
  /// **'It looks like the app closed unexpectedly. An auto-saved draft was found from {ageDescription}.\n\nThis draft contains your treatment preferences and medical data (no personal information was saved).\n\nWould you like to restore it?'**
  String draftRecoveryDialogItLooksLikeTheApp(Object ageDescription);

  /// No description provided for @stepDotsStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepDotsStepOf(Object current, Object total);

  /// No description provided for @stepDotsGoToStepOf.
  ///
  /// In en, this message translates to:
  /// **'Go to step {i} of {total}'**
  String stepDotsGoToStepOf(Object i, Object total);

  /// No description provided for @healthChipLearnAbout.
  ///
  /// In en, this message translates to:
  /// **'Learn about {label}'**
  String healthChipLearnAbout(Object label);

  /// No description provided for @healthChipRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove {label}'**
  String healthChipRemove(Object label);

  /// No description provided for @crisisSheetTextHomeTo.
  ///
  /// In en, this message translates to:
  /// **'Text HOME to {crisisTextLine}'**
  String crisisSheetTextHomeTo(Object crisisTextLine);

  /// No description provided for @crisisSheetTreatmentReferrals.
  ///
  /// In en, this message translates to:
  /// **'{samhsa} · treatment referrals'**
  String crisisSheetTreatmentReferrals(Object samhsa);

  /// No description provided for @crisisSheetKnowYourRights.
  ///
  /// In en, this message translates to:
  /// **'{paProtectionAdvocacy} · know your rights'**
  String crisisSheetKnowYourRights(Object paProtectionAdvocacy);

  /// No description provided for @fdaLabelDialogFdaLabel.
  ///
  /// In en, this message translates to:
  /// **'{medName} — FDA label'**
  String fdaLabelDialogFdaLabel(Object medName);

  /// No description provided for @nlmAttributionSourceUSNationalLibrary.
  ///
  /// In en, this message translates to:
  /// **'Source: U.S. National Library of Medicine. {medicalDisclaimer}'**
  String nlmAttributionSourceUSNationalLibrary(Object medicalDisclaimer);

  /// No description provided for @aiConsentDialogToAutofillYourDirectiveThe.
  ///
  /// In en, this message translates to:
  /// **'To autofill your directive, the whole document — including any personal details on it (names, dates of birth, addresses, phone numbers) — is sent to {label} so it can read it and fill in your fields.'**
  String aiConsentDialogToAutofillYourDirectiveThe(Object label);

  /// No description provided for @aiConsentDialogForMoreAccurateTranscriptionEspecially.
  ///
  /// In en, this message translates to:
  /// **'For more accurate transcription (especially medication names and conditions), your voice recording — including any personal details you say — is sent to {label} to turn into text.'**
  String aiConsentDialogForMoreAccurateTranscriptionEspecially(Object label);

  /// No description provided for @aiConsentDialogTextYouEnterWillBe.
  ///
  /// In en, this message translates to:
  /// **'• Text you enter will be sent to {label} for AI processing. {provider}\n'**
  String aiConsentDialogTextYouEnterWillBe(Object label, Object provider);

  /// No description provided for @aiConsentDialogByTappingIAuthorizeYou.
  ///
  /// In en, this message translates to:
  /// **'\nBy tapping \"I Authorize,\" you consent to sending your text to {label} for AI processing under these terms.\n\nThis notice appears once per session.'**
  String aiConsentDialogByTappingIAuthorizeYou(Object label);

  /// No description provided for @exportDraftModeFinal.
  ///
  /// In en, this message translates to:
  /// **'Final copy'**
  String get exportDraftModeFinal;

  /// No description provided for @exportDraftModeDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get exportDraftModeDraft;

  /// No description provided for @exportDraftModeSignedExists.
  ///
  /// In en, this message translates to:
  /// **'Draft · signed copy exists'**
  String get exportDraftModeSignedExists;

  /// No description provided for @exportOpenedManyPdfs.
  ///
  /// In en, this message translates to:
  /// **'Opened {count} PDFs in new tabs — print or save each from your PDF viewer.'**
  String exportOpenedManyPdfs(int count);

  /// No description provided for @exportOpenedOnePdf.
  ///
  /// In en, this message translates to:
  /// **'Opened in a new tab — use Print or Download in your PDF viewer.'**
  String get exportOpenedOnePdf;

  /// No description provided for @exportNoAgentDesignated.
  ///
  /// In en, this message translates to:
  /// **'No agent designated — agent sections will be blank'**
  String get exportNoAgentDesignated;

  /// No description provided for @exportWalletYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get exportWalletYourName;

  /// No description provided for @exportWalletSignToActivate.
  ///
  /// In en, this message translates to:
  /// **'sign to activate'**
  String get exportWalletSignToActivate;

  /// No description provided for @exportEffectiveCondition.
  ///
  /// In en, this message translates to:
  /// **'Effective condition'**
  String get exportEffectiveCondition;

  /// No description provided for @exportWitnessSignatures.
  ///
  /// In en, this message translates to:
  /// **'Witness signatures'**
  String get exportWitnessSignatures;

  /// No description provided for @exportPrintedCopyType.
  ///
  /// In en, this message translates to:
  /// **'Printed copy type'**
  String get exportPrintedCopyType;

  /// No description provided for @exportADraftPrintsALight.
  ///
  /// In en, this message translates to:
  /// **'A draft prints a light “DRAFT” watermark on every page — for sending a copy while you keep the signed paper original. Tick as many as you like — Download gives you one PDF of each.'**
  String get exportADraftPrintsALight;

  /// No description provided for @exportDocumentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Document language'**
  String get exportDocumentLanguage;

  /// No description provided for @exportThePlainLanguageOfficialForm.
  ///
  /// In en, this message translates to:
  /// **'The plain-language official form is the one you sign and use — it is the legally valid directive. The legal-language version restates it in formal statutory wording for reference only and is not the document you sign.'**
  String get exportThePlainLanguageOfficialForm;

  /// No description provided for @exportThisOpensYourDirectiveIn.
  ///
  /// In en, this message translates to:
  /// **'This opens your directive in your PDF viewer (a new browser tab), where you can Print it or save/Download it — it will NOT download automatically.'**
  String get exportThisOpensYourDirectiveIn;

  /// No description provided for @exportWalletCard.
  ///
  /// In en, this message translates to:
  /// **'Wallet card'**
  String get exportWalletCard;

  /// No description provided for @exportACreditCardSizedSummary.
  ///
  /// In en, this message translates to:
  /// **'A credit-card-sized summary you can print and carry.'**
  String get exportACreditCardSizedSummary;

  /// No description provided for @exportSaveAnEditableCopy.
  ///
  /// In en, this message translates to:
  /// **'Save an editable copy'**
  String get exportSaveAnEditableCopy;

  /// No description provided for @exportNotAFinishedDocumentThis.
  ///
  /// In en, this message translates to:
  /// **'Not a finished document — this is how you save your progress. The web app can’t store your work on this device, so download this file to keep it, then re-upload it later (here or on another device) to keep editing. Nothing is stored online.'**
  String get exportNotAFinishedDocumentThis;

  /// No description provided for @exportEncryptingHindersOthersFromReading.
  ///
  /// In en, this message translates to:
  /// **'Encrypting hinders others from reading it; the app still opens it with no passphrase.'**
  String get exportEncryptingHindersOthersFromReading;

  /// No description provided for @exportMachineReadableFormats.
  ///
  /// In en, this message translates to:
  /// **'Machine-readable formats'**
  String get exportMachineReadableFormats;

  /// No description provided for @exportYourPdfAboveIsThe.
  ///
  /// In en, this message translates to:
  /// **'Your PDF above is the document you sign — these are data exports for your records, a spreadsheet, or a health system. FHIR is the standard format hospitals use to exchange medical records; CSV is a spreadsheet file (opens in Excel or Google Sheets).'**
  String get exportYourPdfAboveIsThe;

  /// No description provided for @aiSetupTestOk.
  ///
  /// In en, this message translates to:
  /// **'{provider} responded. This key and model work.'**
  String aiSetupTestOk(String provider);

  /// No description provided for @aiSetupPrivacyLeadGemini.
  ///
  /// In en, this message translates to:
  /// **'On the Gemini free tier, Google may use data you send to improve their AI products, and human reviewers may read your inputs.'**
  String get aiSetupPrivacyLeadGemini;

  /// No description provided for @aiSetupPrivacyLeadOther.
  ///
  /// In en, this message translates to:
  /// **'Your {provider} key sends data to {provider}; their data-use and retention policy applies.'**
  String aiSetupPrivacyLeadOther(String provider);

  /// No description provided for @aiSetupPrivacyKeyEphemeral.
  ///
  /// In en, this message translates to:
  /// **'Your API key is kept in memory for this session, with a temporary copy for up to 10 minutes (for crash recovery); it is discarded when the session ends.'**
  String get aiSetupPrivacyKeyEphemeral;

  /// No description provided for @aiSetupPrivacyKeyStored.
  ///
  /// In en, this message translates to:
  /// **'Your API key is stored securely on this device only and is never shared with anyone other than your AI provider.'**
  String get aiSetupPrivacyKeyStored;

  /// No description provided for @aiSetupPrivacyNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'{lead}\n\nThe AI features in this app send text you enter in form fields and chat messages to your AI provider\'s servers. Do not include personally identifying details (full legal name, Social Security number, date of birth, etc.) in AI chat or when using AI Suggest.\n\n{keyLine}'**
  String aiSetupPrivacyNoticeBody(String lead, String keyLine);

  /// No description provided for @aiSetupDuckDuckGoNote.
  ///
  /// In en, this message translates to:
  /// **'All browsing is private (Fire Button clears)'**
  String get aiSetupDuckDuckGoNote;

  /// No description provided for @aiSetupProviderFree.
  ///
  /// In en, this message translates to:
  /// **'{provider} (free)'**
  String aiSetupProviderFree(String provider);

  /// No description provided for @aiSetupShortcutWithMac.
  ///
  /// In en, this message translates to:
  /// **'{browser}:  {shortcut}  (Mac: {macShortcut})'**
  String aiSetupShortcutWithMac(
    String browser,
    String shortcut,
    String macShortcut,
  );

  /// No description provided for @aiSetupShortcutMacOnly.
  ///
  /// In en, this message translates to:
  /// **'{browser}:  {macShortcut}  (Mac only)'**
  String aiSetupShortcutMacOnly(String browser, String macShortcut);

  /// No description provided for @feAiUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the AI service. Check your internet connection. If you are using the web app, this provider may also be blocked by your browser\'s security policy — Gemini and Claude both work in the browser.'**
  String get feAiUnreachable;

  /// No description provided for @feNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get feNoInternet;

  /// No description provided for @feTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please check your connection and try again.'**
  String get feTimeout;

  /// No description provided for @feBlocked.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the AI service — the request was blocked or the connection failed. Check your internet connection, and if you are on the web app try Gemini or Claude, which work in the browser.'**
  String get feBlocked;

  /// No description provided for @feRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get feRateLimited;

  /// No description provided for @feKeyRejected.
  ///
  /// In en, this message translates to:
  /// **'Your API key was rejected. Open AI setup and check the key is correct, still active, and belongs to the selected provider.'**
  String get feKeyRejected;

  /// No description provided for @feModelUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The selected AI model isn\'t available — it may have been retired. Pick a different model in AI setup.'**
  String get feModelUnavailable;

  /// No description provided for @feEmptyResponse.
  ///
  /// In en, this message translates to:
  /// **'The AI returned no results. Try again or enter the information manually.'**
  String get feEmptyResponse;

  /// No description provided for @feBadFormat.
  ///
  /// In en, this message translates to:
  /// **'The AI response was not in the expected format. Please try again.'**
  String get feBadFormat;

  /// No description provided for @feServiceError.
  ///
  /// In en, this message translates to:
  /// **'The AI service encountered an error. Please try again later.'**
  String get feServiceError;

  /// No description provided for @fePermission.
  ///
  /// In en, this message translates to:
  /// **'Permission was not granted. Please check your device settings.'**
  String get fePermission;

  /// No description provided for @feGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get feGeneric;

  /// No description provided for @assistantSendError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I encountered an error: {error}'**
  String assistantSendError(String error);

  /// No description provided for @assistantVerifyError.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I couldn\'t verify that on the web: {error}'**
  String assistantVerifyError(String error);

  /// No description provided for @permissionsOverviewUnlockingEncryptedOnDeviceStorage.
  ///
  /// In en, this message translates to:
  /// **'Unlocking encrypted on-device storage (native app only; not used by the web app).'**
  String get permissionsOverviewUnlockingEncryptedOnDeviceStorage;

  /// No description provided for @permissionsOverviewUsedOnlyToVerifyYour.
  ///
  /// In en, this message translates to:
  /// **'Used only to verify your identity on unlock'**
  String get permissionsOverviewUsedOnlyToVerifyYour;

  /// No description provided for @permissionsOverviewBiometricDataNeverLeavesThe.
  ///
  /// In en, this message translates to:
  /// **'Biometric data never leaves the OS keystore'**
  String get permissionsOverviewBiometricDataNeverLeavesThe;

  /// No description provided for @permissionsOverviewNoBiometricDataIsSent.
  ///
  /// In en, this message translates to:
  /// **'No biometric data is sent to any server'**
  String get permissionsOverviewNoBiometricDataIsSent;

  /// No description provided for @permissionsOverviewFallsBackToAPasscode.
  ///
  /// In en, this message translates to:
  /// **'Falls back to a passcode you choose if biometrics fail'**
  String get permissionsOverviewFallsBackToAPasscode;

  /// No description provided for @permissionsOverviewNotApplicableOnThisPlatform.
  ///
  /// In en, this message translates to:
  /// **'Not applicable on this platform'**
  String get permissionsOverviewNotApplicableOnThisPlatform;

  /// No description provided for @permissionsOverviewRemindingYouAboutWitnessSigning.
  ///
  /// In en, this message translates to:
  /// **'Reminding you about witness signing, renewals, and check-ins.'**
  String get permissionsOverviewRemindingYouAboutWitnessSigning;

  /// No description provided for @permissionsOverviewYouChooseWhichRemindersTo.
  ///
  /// In en, this message translates to:
  /// **'You choose which reminders to enable'**
  String get permissionsOverviewYouChooseWhichRemindersTo;

  /// No description provided for @permissionsOverviewNotificationsAreScheduledLocallyOn.
  ///
  /// In en, this message translates to:
  /// **'Notifications are scheduled locally on this device'**
  String get permissionsOverviewNotificationsAreScheduledLocallyOn;

  /// No description provided for @permissionsOverviewNoContentPiiDirectiveText.
  ///
  /// In en, this message translates to:
  /// **'No content (PII, directive text) is in any notification body'**
  String get permissionsOverviewNoContentPiiDirectiveText;

  /// No description provided for @permissionsOverviewDisablePerCategoryInDevice.
  ///
  /// In en, this message translates to:
  /// **'Disable per-category in device Settings → Notifications'**
  String get permissionsOverviewDisablePerCategoryInDevice;

  /// No description provided for @permissionsOverviewSnappingAPhotoOfYour.
  ///
  /// In en, this message translates to:
  /// **'Snapping a photo of your ID, medication labels, or condition lists for AI-assisted field extraction. Coming in a later release.'**
  String get permissionsOverviewSnappingAPhotoOfYour;

  /// No description provided for @permissionsOverviewPhotoIsSentToAi.
  ///
  /// In en, this message translates to:
  /// **'Photo is sent to AI only to read it'**
  String get permissionsOverviewPhotoIsSentToAi;

  /// No description provided for @permissionsOverviewPhotoIsDiscardedRightAfter.
  ///
  /// In en, this message translates to:
  /// **'Photo is discarded right after extraction'**
  String get permissionsOverviewPhotoIsDiscardedRightAfter;

  /// No description provided for @permissionsOverviewNothingIsSavedToYour.
  ///
  /// In en, this message translates to:
  /// **'Nothing is saved to your device\'s photo library by default'**
  String get permissionsOverviewNothingIsSavedToYour;

  /// No description provided for @permissionsOverviewYouReviewEveryFieldBefore.
  ///
  /// In en, this message translates to:
  /// **'You review every field before it\'s used'**
  String get permissionsOverviewYouReviewEveryFieldBefore;

  /// No description provided for @permissionsOverviewNotYetWiredFeatureIn.
  ///
  /// In en, this message translates to:
  /// **'Not yet wired — feature in a future release'**
  String get permissionsOverviewNotYetWiredFeatureIn;

  /// No description provided for @permissionsOverviewSpeakingLongFormAnswersE.
  ///
  /// In en, this message translates to:
  /// **'Speaking long-form answers (e.g. \"anything else\") instead of typing. Coming in a later release.'**
  String get permissionsOverviewSpeakingLongFormAnswersE;

  /// No description provided for @permissionsOverviewAudioIsProcessedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Audio is processed on-device when possible'**
  String get permissionsOverviewAudioIsProcessedOnDevice;

  /// No description provided for @permissionsOverviewIfSentToAiFor.
  ///
  /// In en, this message translates to:
  /// **'If sent to AI for transcription, it isn\'t stored'**
  String get permissionsOverviewIfSentToAiFor;

  /// No description provided for @permissionsOverviewTranscriptStaysInYourSession.
  ///
  /// In en, this message translates to:
  /// **'Transcript stays in your session — never uploaded'**
  String get permissionsOverviewTranscriptStaysInYourSession;

  /// No description provided for @permissionsOverviewToggleOffAtAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Toggle off at any time in Settings'**
  String get permissionsOverviewToggleOffAtAnyTime;

  /// No description provided for @permissionsOverviewPickingAnAgentOrWitness.
  ///
  /// In en, this message translates to:
  /// **'Picking an agent or witness from your address book instead of typing their details. Coming in a later release.'**
  String get permissionsOverviewPickingAnAgentOrWitness;

  /// No description provided for @permissionsOverviewWeNeverUploadYourContacts.
  ///
  /// In en, this message translates to:
  /// **'We never upload your contacts'**
  String get permissionsOverviewWeNeverUploadYourContacts;

  /// No description provided for @permissionsOverviewSearchRunsLocallyOnThis.
  ///
  /// In en, this message translates to:
  /// **'Search runs locally on this device'**
  String get permissionsOverviewSearchRunsLocallyOnThis;

  /// No description provided for @permissionsOverviewOnlyTheContactYouPick.
  ///
  /// In en, this message translates to:
  /// **'Only the contact you pick is brought into the directive'**
  String get permissionsOverviewOnlyTheContactYouPick;

  /// No description provided for @permissionsOverviewYouCanRevokeAccessIn.
  ///
  /// In en, this message translates to:
  /// **'You can revoke access in Settings any time'**
  String get permissionsOverviewYouCanRevokeAccessIn;

  /// No description provided for @permissionsOverviewAvailableOsManaged.
  ///
  /// In en, this message translates to:
  /// **'Available · OS-managed'**
  String get permissionsOverviewAvailableOsManaged;

  /// No description provided for @eduBrowseIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get eduBrowseIntroduction;

  /// No description provided for @eduBrowseWhatAnMhadIsAnd.
  ///
  /// In en, this message translates to:
  /// **'What an MHAD is and who should sign one'**
  String get eduBrowseWhatAnMhadIsAnd;

  /// No description provided for @eduBrowseCombinedForm.
  ///
  /// In en, this message translates to:
  /// **'Combined Form'**
  String get eduBrowseCombinedForm;

  /// No description provided for @eduBrowseBothAnAgentAndTreatment.
  ///
  /// In en, this message translates to:
  /// **'Both an agent and treatment preferences'**
  String get eduBrowseBothAnAgentAndTreatment;

  /// No description provided for @eduBrowseTreatmentPreferencesWithoutAnAgent.
  ///
  /// In en, this message translates to:
  /// **'Treatment preferences without an agent'**
  String get eduBrowseTreatmentPreferencesWithoutAnAgent;

  /// No description provided for @eduBrowsePowerOfAttorney.
  ///
  /// In en, this message translates to:
  /// **'Power of Attorney'**
  String get eduBrowsePowerOfAttorney;

  /// No description provided for @eduBrowseAgentDesignationWithoutPreferences.
  ///
  /// In en, this message translates to:
  /// **'Agent designation without preferences'**
  String get eduBrowseAgentDesignationWithoutPreferences;

  /// No description provided for @eduBrowseFrequentlyAsked.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked'**
  String get eduBrowseFrequentlyAsked;

  /// No description provided for @eduBrowseCommonQuestionsAboutMhads.
  ///
  /// In en, this message translates to:
  /// **'Common questions about MHADs'**
  String get eduBrowseCommonQuestionsAboutMhads;

  /// No description provided for @eduBrowseGlossary.
  ///
  /// In en, this message translates to:
  /// **'Glossary'**
  String get eduBrowseGlossary;

  /// No description provided for @eduBrowseEveryLegalTermDefined.
  ///
  /// In en, this message translates to:
  /// **'Every legal term, defined'**
  String get eduBrowseEveryLegalTermDefined;

  /// No description provided for @eduBrowseBeyondTheBooklet.
  ///
  /// In en, this message translates to:
  /// **'Beyond the Booklet'**
  String get eduBrowseBeyondTheBooklet;

  /// No description provided for @eduBrowseTopicsNotCoveredInThe.
  ///
  /// In en, this message translates to:
  /// **'Topics not covered in the official PA booklet'**
  String get eduBrowseTopicsNotCoveredInThe;

  /// No description provided for @eduBrowseYourChecklist.
  ///
  /// In en, this message translates to:
  /// **'Your Checklist'**
  String get eduBrowseYourChecklist;

  /// No description provided for @eduBrowseStepByStepDistributionRevocation.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step distribution + revocation guides'**
  String get eduBrowseStepByStepDistributionRevocation;

  /// No description provided for @webLandingPreferPaperOpenAnyOf.
  ///
  /// In en, this message translates to:
  /// **'Prefer paper? Open any of the three empty official forms to print and fill in by hand — no account or wizard needed.'**
  String get webLandingPreferPaperOpenAnyOf;

  /// No description provided for @webLandingNoAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'No account required'**
  String get webLandingNoAccountRequired;

  /// No description provided for @webLandingNoEmailNoPasswordNo.
  ///
  /// In en, this message translates to:
  /// **'No email, no password, no sign-up.'**
  String get webLandingNoEmailNoPasswordNo;

  /// No description provided for @webLandingNothingLeavesYourBrowser.
  ///
  /// In en, this message translates to:
  /// **'Nothing leaves your browser'**
  String get webLandingNothingLeavesYourBrowser;

  /// No description provided for @webLandingYourAnswersLiveInThis.
  ///
  /// In en, this message translates to:
  /// **'Your answers live in this tab. We never see them.'**
  String get webLandingYourAnswersLiveInThis;

  /// No description provided for @webLandingNoCookiesNoTracking.
  ///
  /// In en, this message translates to:
  /// **'No cookies, no tracking'**
  String get webLandingNoCookiesNoTracking;

  /// No description provided for @webLandingNoAnalyticsNoThirdParty.
  ///
  /// In en, this message translates to:
  /// **'No analytics, no third-party scripts.'**
  String get webLandingNoAnalyticsNoThirdParty;

  /// No description provided for @webLandingYouKeepTheFile.
  ///
  /// In en, this message translates to:
  /// **'You keep the file'**
  String get webLandingYouKeepTheFile;

  /// No description provided for @webLandingSaveThePdfFromYour.
  ///
  /// In en, this message translates to:
  /// **'Save the PDF from your viewer — that’s the only copy.'**
  String get webLandingSaveThePdfFromYour;

  /// No description provided for @pinDialogPasscodeTooShort.
  ///
  /// In en, this message translates to:
  /// **'Passcode must be at least 4 characters.'**
  String get pinDialogPasscodeTooShort;

  /// No description provided for @pinDialogPasscodesDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passcodes do not match.'**
  String get pinDialogPasscodesDontMatch;

  /// No description provided for @pinDialogUnlockPrivateMode.
  ///
  /// In en, this message translates to:
  /// **'Unlock private mode'**
  String get pinDialogUnlockPrivateMode;

  /// No description provided for @pinDialogEnterPasscode.
  ///
  /// In en, this message translates to:
  /// **'Please enter your passcode.'**
  String get pinDialogEnterPasscode;

  /// No description provided for @pinDialogTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait 30 seconds.'**
  String get pinDialogTooManyAttempts;

  /// No description provided for @pinDialogIncorrectPasscode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect passcode. Please try again.'**
  String get pinDialogIncorrectPasscode;

  /// No description provided for @deviceSecurityWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Security Warning'**
  String get deviceSecurityWarningTitle;

  /// No description provided for @deviceSecurityWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Your device appears to be rooted/jailbroken. This may put your sensitive health data at risk. Consider using a non-modified device for storing advance directives.'**
  String get deviceSecurityWarningBody;

  /// No description provided for @deviceSecurityIUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I Understand'**
  String get deviceSecurityIUnderstand;

  /// No description provided for @blankFormPrintTitle.
  ///
  /// In en, this message translates to:
  /// **'Print a blank form'**
  String get blankFormPrintTitle;

  /// No description provided for @blankFormPrintError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the blank form to print: {error}'**
  String blankFormPrintError(String error);

  /// No description provided for @launchCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'{value} copied to clipboard'**
  String launchCopiedToClipboard(String value);

  /// No description provided for @reminderRenewMetricSections.
  ///
  /// In en, this message translates to:
  /// **'sections'**
  String get reminderRenewMetricSections;

  /// No description provided for @reminderRenewMetricWetInk.
  ///
  /// In en, this message translates to:
  /// **'wet-ink'**
  String get reminderRenewMetricWetInk;

  /// No description provided for @reminderRenewMetricSigning.
  ///
  /// In en, this message translates to:
  /// **'signing'**
  String get reminderRenewMetricSigning;

  /// No description provided for @reminderRenewMetricMin.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get reminderRenewMetricMin;

  /// No description provided for @educationBefore.
  ///
  /// In en, this message translates to:
  /// **'before'**
  String get educationBefore;

  /// No description provided for @assistantGeneralQuestion.
  ///
  /// In en, this message translates to:
  /// **'General question'**
  String get assistantGeneralQuestion;

  /// No description provided for @assistantContextPanelStrippedBeforeSend.
  ///
  /// In en, this message translates to:
  /// **'Stripped before send'**
  String get assistantContextPanelStrippedBeforeSend;

  /// No description provided for @assistantSuggestWalkMeThroughFillingOut.
  ///
  /// In en, this message translates to:
  /// **'Walk me through filling out my directive step by step'**
  String get assistantSuggestWalkMeThroughFillingOut;

  /// No description provided for @assistantSuggestWhatIsAMentalHealth.
  ///
  /// In en, this message translates to:
  /// **'What is a Mental Health Advance Directive?'**
  String get assistantSuggestWhatIsAMentalHealth;

  /// No description provided for @assistantSuggestWhatSTheDifferenceBetween.
  ///
  /// In en, this message translates to:
  /// **'What\'s the difference between Combined, Declaration, and POA?'**
  String get assistantSuggestWhatSTheDifferenceBetween;

  /// No description provided for @assistantSuggestWhoCanBeMyAgent.
  ///
  /// In en, this message translates to:
  /// **'Who can be my agent?'**
  String get assistantSuggestWhoCanBeMyAgent;

  /// No description provided for @assistantSuggestWhatMedicationsShouldIList.
  ///
  /// In en, this message translates to:
  /// **'What medications should I list?'**
  String get assistantSuggestWhatMedicationsShouldIList;

  /// No description provided for @assistantSuggestWhatDoesEctMean.
  ///
  /// In en, this message translates to:
  /// **'What does ECT mean?'**
  String get assistantSuggestWhatDoesEctMean;

  /// No description provided for @assistantSuggestHowLongIsTheDirective.
  ///
  /// In en, this message translates to:
  /// **'How long is the directive valid?'**
  String get assistantSuggestHowLongIsTheDirective;

  /// No description provided for @assistantSuggestCanIChangeMyDirective.
  ///
  /// In en, this message translates to:
  /// **'Can I change my directive later?'**
  String get assistantSuggestCanIChangeMyDirective;

  /// No description provided for @ulyssesOnlyAppliesOnceIHave.
  ///
  /// In en, this message translates to:
  /// **'Only applies once I have been formally found to lack capacity'**
  String get ulyssesOnlyAppliesOnceIHave;

  /// No description provided for @ulyssesOnlyForTreatmentsIExplicitly.
  ///
  /// In en, this message translates to:
  /// **'Only for treatments I explicitly named (medications, ECT, facility)'**
  String get ulyssesOnlyForTreatmentsIExplicitly;

  /// No description provided for @ulyssesDoesNotAuthorizePhysicalRestraint.
  ///
  /// In en, this message translates to:
  /// **'Does not authorize physical restraint'**
  String get ulyssesDoesNotAuthorizePhysicalRestraint;

  /// No description provided for @ulyssesACourtAppointedGuardianNot.
  ///
  /// In en, this message translates to:
  /// **'A court-appointed guardian (not the agent) may revoke, suspend, or terminate'**
  String get ulyssesACourtAppointedGuardianNot;

  /// No description provided for @ulyssesMyDirectiveStillTerminatesAt.
  ///
  /// In en, this message translates to:
  /// **'My directive still terminates at 2 years — unless I am incapable when it would expire, in which case it remains in effect (§§ 5824(e), 5834(c))'**
  String get ulyssesMyDirectiveStillTerminatesAt;

  /// No description provided for @homeHeroPercentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String homeHeroPercentComplete(int percent);

  /// No description provided for @homeHeroReadyToReviewSign.
  ///
  /// In en, this message translates to:
  /// **'Ready to review & sign'**
  String get homeHeroReadyToReviewSign;

  /// No description provided for @homeHeroMoreSteps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{~ 1 more step} other{~ {count} more steps}}'**
  String homeHeroMoreSteps(int count);

  /// No description provided for @homeHeroCombinedForm.
  ///
  /// In en, this message translates to:
  /// **'Combined form'**
  String get homeHeroCombinedForm;

  /// No description provided for @homeHeroDeclarationOnly.
  ///
  /// In en, this message translates to:
  /// **'Declaration only'**
  String get homeHeroDeclarationOnly;

  /// No description provided for @homeHeroNamedMhad.
  ///
  /// In en, this message translates to:
  /// **'{name}’s MHAD'**
  String homeHeroNamedMhad(String name);

  /// No description provided for @homeHeroYourMhad.
  ///
  /// In en, this message translates to:
  /// **'Your MHAD'**
  String get homeHeroYourMhad;

  /// No description provided for @educationNoResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get educationNoResultsFound;

  /// No description provided for @educationNoResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String educationNoResultsFor(String query);

  /// No description provided for @relativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get relativeJustNow;

  /// No description provided for @relativeMinsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min ago} other{{count} mins ago}}'**
  String relativeMinsAgo(int count);

  /// No description provided for @relativeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String relativeHoursAgo(int count);

  /// No description provided for @relativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String relativeDaysAgo(int count);

  /// No description provided for @revocationNotifyPrimaryCareDoctor.
  ///
  /// In en, this message translates to:
  /// **'Primary care doctor'**
  String get revocationNotifyPrimaryCareDoctor;

  /// No description provided for @revocationNotifyPsychiatristTherapist.
  ///
  /// In en, this message translates to:
  /// **'Psychiatrist / therapist'**
  String get revocationNotifyPsychiatristTherapist;

  /// No description provided for @revocationNotifyNearestHospitalEr.
  ///
  /// In en, this message translates to:
  /// **'Nearest hospital ER'**
  String get revocationNotifyNearestHospitalEr;

  /// No description provided for @revocationNotifyPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get revocationNotifyPharmacy;

  /// No description provided for @revocationNotifyLocalRightsAdvocate.
  ///
  /// In en, this message translates to:
  /// **'Local rights advocate'**
  String get revocationNotifyLocalRightsAdvocate;

  /// No description provided for @legalSheetBoldNot.
  ///
  /// In en, this message translates to:
  /// **'not'**
  String get legalSheetBoldNot;

  /// No description provided for @legalSheetBoldOnly.
  ///
  /// In en, this message translates to:
  /// **'only'**
  String get legalSheetBoldOnly;

  /// No description provided for @legalSheetBoldTwoAdultWitnesses.
  ///
  /// In en, this message translates to:
  /// **'two adult witnesses'**
  String get legalSheetBoldTwoAdultWitnesses;

  /// No description provided for @legalSheetBoldWitnessesCannotBe.
  ///
  /// In en, this message translates to:
  /// **'Witnesses cannot be: '**
  String get legalSheetBoldWitnessesCannotBe;

  /// No description provided for @legalSheetBoldPrinted.
  ///
  /// In en, this message translates to:
  /// **'printed'**
  String get legalSheetBoldPrinted;

  /// No description provided for @legalSheetBoldMustComply.
  ///
  /// In en, this message translates to:
  /// **'must comply'**
  String get legalSheetBoldMustComply;

  /// No description provided for @legalSheetBoldTwoYears.
  ///
  /// In en, this message translates to:
  /// **'two years'**
  String get legalSheetBoldTwoYears;

  /// No description provided for @legalSheetBoldUnlessYouAreFoundIncapable.
  ///
  /// In en, this message translates to:
  /// **'unless you are found incapable'**
  String get legalSheetBoldUnlessYouAreFoundIncapable;

  /// No description provided for @legalSheetBoldNotSavedPermanently.
  ///
  /// In en, this message translates to:
  /// **'not saved permanently'**
  String get legalSheetBoldNotSavedPermanently;

  /// No description provided for @legalSheetBoldAutomaticallyKeepsIdentifyingDetailsOut.
  ///
  /// In en, this message translates to:
  /// **'automatically keeps identifying details out of what it sends to the AI assistant and its suggestions'**
  String get legalSheetBoldAutomaticallyKeepsIdentifyingDetailsOut;

  /// No description provided for @legalSheetBoldUploadingIsNeverRequired.
  ///
  /// In en, this message translates to:
  /// **'Uploading is never required'**
  String get legalSheetBoldUploadingIsNeverRequired;

  /// No description provided for @legalSheetBoldTheseLookupsSendOnlyThe.
  ///
  /// In en, this message translates to:
  /// **'These lookups send only the medical term, code, or provider name being searched'**
  String get legalSheetBoldTheseLookupsSendOnlyThe;

  /// No description provided for @legalSheetYourRightsUnderAct194.
  ///
  /// In en, this message translates to:
  /// **'Your rights under Act 194'**
  String get legalSheetYourRightsUnderAct194;

  /// No description provided for @legalSheet247FreeConfidential.
  ///
  /// In en, this message translates to:
  /// **'24/7, free, confidential'**
  String get legalSheet247FreeConfidential;

  /// No description provided for @legalSheetCallOrText988.
  ///
  /// In en, this message translates to:
  /// **'Call or text 988'**
  String get legalSheetCallOrText988;

  /// No description provided for @crisisPlanTheFirstThingsINotice.
  ///
  /// In en, this message translates to:
  /// **'The first things I notice when my mood shifts.'**
  String get crisisPlanTheFirstThingsINotice;

  /// No description provided for @crisisPlanExternalThingsThatHaveSet.
  ///
  /// In en, this message translates to:
  /// **'External things that have set off episodes before.'**
  String get crisisPlanExternalThingsThatHaveSet;

  /// No description provided for @crisisPlanSpecificConcreteNotSelfCare.
  ///
  /// In en, this message translates to:
  /// **'Specific, concrete. Not \'self-care\' — what actually works.'**
  String get crisisPlanSpecificConcreteNotSelfCare;

  /// No description provided for @crisisPlanWordsThatGroundMeUseful.
  ///
  /// In en, this message translates to:
  /// **'Words that ground me. Useful for staff, EMS, family.'**
  String get crisisPlanWordsThatGroundMeUseful;

  /// No description provided for @crisisPlanApproachesThatEscalateMeBe.
  ///
  /// In en, this message translates to:
  /// **'Approaches that escalate me. Be specific.'**
  String get crisisPlanApproachesThatEscalateMeBe;

  /// No description provided for @reminderSheetsAgentsPrimaryAndAlternate.
  ///
  /// In en, this message translates to:
  /// **'Agents — primary and alternate'**
  String get reminderSheetsAgentsPrimaryAndAlternate;

  /// No description provided for @reminderSheetsCurrentMedsOnesYouDon.
  ///
  /// In en, this message translates to:
  /// **'Current meds, ones you don\'t want, allergies'**
  String get reminderSheetsCurrentMedsOnesYouDon;

  /// No description provided for @reminderSheetsPreferredFacilityRoomEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Preferred facility, room environment'**
  String get reminderSheetsPreferredFacilityRoomEnvironment;

  /// No description provided for @accessibilitySettingsAtkinsonHyperlegibleClearerEasierLetter.
  ///
  /// In en, this message translates to:
  /// **'Atkinson Hyperlegible — clearer, easier letter shapes'**
  String get accessibilitySettingsAtkinsonHyperlegibleClearerEasierLetter;

  /// No description provided for @accessibilitySettingsHeavierTextWeightEverywhere.
  ///
  /// In en, this message translates to:
  /// **'Heavier text weight everywhere'**
  String get accessibilitySettingsHeavierTextWeightEverywhere;

  /// No description provided for @accessibilitySettingsRemovesScreenTransitionsAndAnimations.
  ///
  /// In en, this message translates to:
  /// **'Removes screen transitions and animations'**
  String get accessibilitySettingsRemovesScreenTransitionsAndAnimations;

  /// No description provided for @accessibilitySettingsMaximizesSeparationBetweenTextAnd.
  ///
  /// In en, this message translates to:
  /// **'Maximizes separation between text and background'**
  String get accessibilitySettingsMaximizesSeparationBetweenTextAnd;

  /// No description provided for @accessibilitySettingsUseYourBrowserOrDevice.
  ///
  /// In en, this message translates to:
  /// **'Use your browser or device read-aloud — see the guide below'**
  String get accessibilitySettingsUseYourBrowserOrDevice;

  /// No description provided for @accessibilitySettingsChromeEdgeDesktop.
  ///
  /// In en, this message translates to:
  /// **'Chrome / Edge (desktop)'**
  String get accessibilitySettingsChromeEdgeDesktop;

  /// No description provided for @directiveFormChoiceTreatmentPreferencesWithoutNamingAn.
  ///
  /// In en, this message translates to:
  /// **'Treatment preferences without naming an agent.'**
  String get directiveFormChoiceTreatmentPreferencesWithoutNamingAn;

  /// No description provided for @directiveFormChoiceNameADecisionMakerWithout.
  ///
  /// In en, this message translates to:
  /// **'Name a decision-maker without listing preferences.'**
  String get directiveFormChoiceNameADecisionMakerWithout;

  /// No description provided for @homeToolsGridFaqGlossary.
  ///
  /// In en, this message translates to:
  /// **'FAQ, glossary'**
  String get homeToolsGridFaqGlossary;

  /// No description provided for @homeToolsGrid988More.
  ///
  /// In en, this message translates to:
  /// **'988 + more'**
  String get homeToolsGrid988More;

  /// No description provided for @facilitator45Min.
  ///
  /// In en, this message translates to:
  /// **'~45 min'**
  String get facilitator45Min;

  /// No description provided for @facilitatorFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get facilitatorFree;

  /// No description provided for @facilitatorPaBased.
  ///
  /// In en, this message translates to:
  /// **'PA-based'**
  String get facilitatorPaBased;

  /// No description provided for @facilitatorInPerson.
  ///
  /// In en, this message translates to:
  /// **'In person'**
  String get facilitatorInPerson;

  /// No description provided for @facilitatorYouStayInControl.
  ///
  /// In en, this message translates to:
  /// **'You stay in control'**
  String get facilitatorYouStayInControl;

  /// No description provided for @facilitatorEmailComposer.
  ///
  /// In en, this message translates to:
  /// **'Email composer'**
  String get facilitatorEmailComposer;

  /// No description provided for @facilitatorManualTranscribeBack.
  ///
  /// In en, this message translates to:
  /// **'Manual transcribe back'**
  String get facilitatorManualTranscribeBack;

  /// No description provided for @modeSelectionBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get modeSelectionBiometrics;

  /// No description provided for @modeSelectionAes256.
  ///
  /// In en, this message translates to:
  /// **'AES-256'**
  String get modeSelectionAes256;

  /// No description provided for @modeSelectionSaveDrafts.
  ///
  /// In en, this message translates to:
  /// **'Save drafts'**
  String get modeSelectionSaveDrafts;

  /// No description provided for @modeSelectionAcrossSessions.
  ///
  /// In en, this message translates to:
  /// **'Across sessions'**
  String get modeSelectionAcrossSessions;

  /// No description provided for @modeSelectionNothingSaved.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved'**
  String get modeSelectionNothingSaved;

  /// No description provided for @modeSelectionInMemoryOnly.
  ///
  /// In en, this message translates to:
  /// **'In-memory only'**
  String get modeSelectionInMemoryOnly;

  /// No description provided for @modeSelectionSingleSession.
  ///
  /// In en, this message translates to:
  /// **'Single session'**
  String get modeSelectionSingleSession;

  /// No description provided for @pdfPreviewLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get pdfPreviewLoading;

  /// No description provided for @pdfPreviewSelectASectionToPreview.
  ///
  /// In en, this message translates to:
  /// **'Select a section to preview.'**
  String get pdfPreviewSelectASectionToPreview;

  /// No description provided for @pdfPreviewCouldNotRenderThePreview.
  ///
  /// In en, this message translates to:
  /// **'Could not render the preview.'**
  String get pdfPreviewCouldNotRenderThePreview;

  /// No description provided for @reminderSheetsStepN.
  ///
  /// In en, this message translates to:
  /// **'Step {n}'**
  String reminderSheetsStepN(int n);

  /// No description provided for @sideEffectsNoneFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find common side effects to list right now. You can add anything you\'re experiencing in the Anything-else step, and always raise side-effect concerns with your doctor.'**
  String get sideEffectsNoneFound;

  /// No description provided for @sideEffectsGenerateError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong generating the list. Please try again, or note side effects yourself.'**
  String get sideEffectsGenerateError;

  /// No description provided for @inputPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit phone number'**
  String get inputPhoneInvalid;

  /// No description provided for @inputZipInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a 5-digit or 5+4-digit ZIP'**
  String get inputZipInvalid;

  /// No description provided for @audioGuideTipQualityDoesnTMatterAny.
  ///
  /// In en, this message translates to:
  /// **'Quality doesn\'t matter. Any phone voice memo works — the AI downsamples audio anyway, so a small low-quality file transcribes just as well as a large one.'**
  String get audioGuideTipQualityDoesnTMatterAny;

  /// No description provided for @audioGuideTipKeepEachClipShortUnder.
  ///
  /// In en, this message translates to:
  /// **'Keep each clip short — under about 2 minutes. Record one clip per section below and upload them together; the app merges them. Long clips can time out.'**
  String get audioGuideTipKeepEachClipShortUnder;

  /// No description provided for @audioGuideTipSayMedicationAndDoctorNames.
  ///
  /// In en, this message translates to:
  /// **'Say medication and doctor names slowly and spell them. The AI won\'t guess a drug or condition it didn\'t clearly hear.'**
  String get audioGuideTipSayMedicationAndDoctorNames;

  /// No description provided for @stepSubtitleAboutYou.
  ///
  /// In en, this message translates to:
  /// **'Just the basics so this document is uniquely yours. Drop a photo of your ID and we\'ll read these for you.'**
  String get stepSubtitleAboutYou;

  /// No description provided for @stepSubtitleWhenItKicksIn.
  ///
  /// In en, this message translates to:
  /// **'The conditions under which your directive becomes active. You can pick more than one.'**
  String get stepSubtitleWhenItKicksIn;

  /// No description provided for @stepSubtitlePeopleITrust.
  ///
  /// In en, this message translates to:
  /// **'They speak for you if you can\'t. You can name a primary, an alternate, and set limits on what they decide.'**
  String get stepSubtitlePeopleITrust;

  /// No description provided for @stepSubtitleGuardianNomination.
  ///
  /// In en, this message translates to:
  /// **'Rare, but worth planning for. A guardian is named by a court — not by you — and has broader authority than an agent.'**
  String get stepSubtitleGuardianNomination;

  /// No description provided for @stepSubtitleWhereIWantCare.
  ///
  /// In en, this message translates to:
  /// **'Facilities you prefer — and any you specifically want to avoid — plus room and environment preferences.'**
  String get stepSubtitleWhereIWantCare;

  /// No description provided for @stepSubtitleDiagnoses.
  ///
  /// In en, this message translates to:
  /// **'Help your care team see the whole picture in a crisis. Search by name — we attach the ICD-10 code your doctors use.'**
  String get stepSubtitleDiagnoses;

  /// No description provided for @stepSubtitleMedications.
  ///
  /// In en, this message translates to:
  /// **'What you take now (for your care team) plus the medications you refuse, limit, or prefer. Your refusals and limits are binding under Act 194.'**
  String get stepSubtitleMedications;

  /// No description provided for @stepSubtitleAllergies.
  ///
  /// In en, this message translates to:
  /// **'Drug allergies, sensitivities, past adverse reactions. This is the most-checked section by ER staff.'**
  String get stepSubtitleAllergies;

  /// No description provided for @stepSubtitleProceduresResearch.
  ///
  /// In en, this message translates to:
  /// **'Three treatments under PA law need your explicit consent. Set each one — your agent fills any gaps.'**
  String get stepSubtitleProceduresResearch;

  /// No description provided for @stepSubtitleAnythingElse.
  ///
  /// In en, this message translates to:
  /// **'Free-form preferences not covered above. This is your voice — write it how you\'d say it.'**
  String get stepSubtitleAnythingElse;

  /// No description provided for @stepSubtitleReviewAndSign.
  ///
  /// In en, this message translates to:
  /// **'One last look, then we\'ll make your signing packet. Tap any section to edit.'**
  String get stepSubtitleReviewAndSign;

  /// No description provided for @formTypeNameCombined.
  ///
  /// In en, this message translates to:
  /// **'Combined Declaration & Power of Attorney'**
  String get formTypeNameCombined;

  /// No description provided for @formTypeNameDeclaration.
  ///
  /// In en, this message translates to:
  /// **'Declaration Only'**
  String get formTypeNameDeclaration;

  /// No description provided for @formTypeNamePoa.
  ///
  /// In en, this message translates to:
  /// **'Power of Attorney Only'**
  String get formTypeNamePoa;

  /// No description provided for @formTypeShortCombined.
  ///
  /// In en, this message translates to:
  /// **'Combined'**
  String get formTypeShortCombined;

  /// No description provided for @formTypeShortDeclaration.
  ///
  /// In en, this message translates to:
  /// **'Declaration'**
  String get formTypeShortDeclaration;

  /// No description provided for @formTypeShortPoa.
  ///
  /// In en, this message translates to:
  /// **'Power of Attorney'**
  String get formTypeShortPoa;

  /// No description provided for @stepTitleAboutYou.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get stepTitleAboutYou;

  /// No description provided for @stepTitleWhenItKicksIn.
  ///
  /// In en, this message translates to:
  /// **'When this kicks in'**
  String get stepTitleWhenItKicksIn;

  /// No description provided for @stepTitlePeopleITrust.
  ///
  /// In en, this message translates to:
  /// **'People I trust'**
  String get stepTitlePeopleITrust;

  /// No description provided for @stepTitleGuardianNomination.
  ///
  /// In en, this message translates to:
  /// **'If a court appoints a guardian'**
  String get stepTitleGuardianNomination;

  /// No description provided for @stepTitleWhereIWantCare.
  ///
  /// In en, this message translates to:
  /// **'Where I want care'**
  String get stepTitleWhereIWantCare;

  /// No description provided for @stepTitleDiagnoses.
  ///
  /// In en, this message translates to:
  /// **'Diagnoses'**
  String get stepTitleDiagnoses;

  /// No description provided for @stepTitleMedications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get stepTitleMedications;

  /// No description provided for @stepTitleAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies & reactions'**
  String get stepTitleAllergies;

  /// No description provided for @stepTitleProceduresResearch.
  ///
  /// In en, this message translates to:
  /// **'Procedures & research'**
  String get stepTitleProceduresResearch;

  /// No description provided for @stepTitleAnythingElse.
  ///
  /// In en, this message translates to:
  /// **'Anything else'**
  String get stepTitleAnythingElse;

  /// No description provided for @stepTitleReviewAndSign.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepTitleReviewAndSign;

  /// No description provided for @directiveStatusRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get directiveStatusRevoked;

  /// No description provided for @directiveStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get directiveStatusExpired;

  /// No description provided for @directiveStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get directiveStatusActive;

  /// No description provided for @directiveStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get directiveStatusDraft;

  /// No description provided for @pastDirectiveSignedOn.
  ///
  /// In en, this message translates to:
  /// **'signed {date}'**
  String pastDirectiveSignedOn(String date);

  /// No description provided for @pastDirectiveExpiredOn.
  ///
  /// In en, this message translates to:
  /// **'expired {date}'**
  String pastDirectiveExpiredOn(String date);

  /// No description provided for @pastDirectiveExpiresOn.
  ///
  /// In en, this message translates to:
  /// **'expires {date}'**
  String pastDirectiveExpiresOn(String date);

  /// No description provided for @settingsDefaultUserName.
  ///
  /// In en, this message translates to:
  /// **'PA MHAD user'**
  String get settingsDefaultUserName;

  /// No description provided for @rateDailyLimitUsed.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all {max} free requests for today. The limit resets at midnight. Consider upgrading to a paid API key for higher limits.'**
  String rateDailyLimitUsed(int max);

  /// No description provided for @rateTooManyThisMinute.
  ///
  /// In en, this message translates to:
  /// **'Too many requests this minute (limit: {max}/min). Please wait {seconds} seconds.'**
  String rateTooManyThisMinute(int max, int seconds);

  /// No description provided for @rateTokenLimitThisMinute.
  ///
  /// In en, this message translates to:
  /// **'Token limit reached this minute ({thousands}K/min). Please wait a moment before sending another request.'**
  String rateTokenLimitThisMinute(int thousands);

  /// No description provided for @rateDailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached'**
  String get rateDailyLimitReached;

  /// No description provided for @rateWaitStatus.
  ///
  /// In en, this message translates to:
  /// **'Wait {seconds}s • {remaining} requests left today'**
  String rateWaitStatus(int seconds, int remaining);

  /// No description provided for @rateRemainingStatus.
  ///
  /// In en, this message translates to:
  /// **'{remainingToday} requests left today • {remainingMinute} this minute'**
  String rateRemainingStatus(int remainingToday, int remainingMinute);

  /// No description provided for @llmHeicUnsupported.
  ///
  /// In en, this message translates to:
  /// **'{provider} can\'t read HEIC/HEIF photos (the iPhone default). Switch to Gemini, or re-save the photo as JPEG or PNG first.'**
  String llmHeicUnsupported(String provider);

  /// No description provided for @llmPdfUnsupported.
  ///
  /// In en, this message translates to:
  /// **'{provider} can\'t read PDFs here — switch to Gemini or Claude, or paste the document text instead.'**
  String llmPdfUnsupported(String provider);

  /// No description provided for @llmFileTypeUnsupported.
  ///
  /// In en, this message translates to:
  /// **'{provider} can\'t read {mimeType} files here — switch to Gemini, or paste the text instead.'**
  String llmFileTypeUnsupported(String provider, String mimeType);

  /// No description provided for @llmRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests to {provider}. Please wait a minute and try again.'**
  String llmRateLimited(String provider);

  /// No description provided for @llmGeminiKeyRejected.
  ///
  /// In en, this message translates to:
  /// **'{provider} rejected your API key. Open AI setup and check the key is correct, still active, and has the Generative Language API enabled.'**
  String llmGeminiKeyRejected(String provider);

  /// No description provided for @llmGeminiModelNotFound.
  ///
  /// In en, this message translates to:
  /// **'{provider} doesn\'t recognise the model \"{model}\" — it may have been retired. Pick a different model in AI setup.'**
  String llmGeminiModelNotFound(String provider, String model);

  /// No description provided for @llmNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach {provider} ({detail}). Check your internet connection. If you are on the web app, this provider may also be blocked by your browser\'s CORS policy — Gemini and Claude both work in the browser.'**
  String llmNetworkError(String provider, String detail);

  /// No description provided for @llmKeyRejected.
  ///
  /// In en, this message translates to:
  /// **'{provider} rejected your API key. Open AI setup and check the key is correct, still active, and belongs to {provider}.'**
  String llmKeyRejected(String provider);

  /// No description provided for @llmModelNotFound.
  ///
  /// In en, this message translates to:
  /// **'{provider} doesn\'t recognise the model \"{model}\". Pick a different model in AI setup.'**
  String llmModelNotFound(String provider, String model);

  /// No description provided for @importFileUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Could not read the file — it is corrupted or not an MHAD directive file.'**
  String get importFileUnreadable;

  /// No description provided for @importFileUnrecognized.
  ///
  /// In en, this message translates to:
  /// **'This file is not a recognized directive file.'**
  String get importFileUnrecognized;

  /// No description provided for @importFileCorrupted.
  ///
  /// In en, this message translates to:
  /// **'The file is corrupted.'**
  String get importFileCorrupted;

  /// No description provided for @importNotDirectiveFile.
  ///
  /// In en, this message translates to:
  /// **'This is not a directive file.'**
  String get importNotDirectiveFile;

  /// No description provided for @importNotMhadFile.
  ///
  /// In en, this message translates to:
  /// **'This is not an MHAD directive file.'**
  String get importNotMhadFile;

  /// No description provided for @importNewerVersion.
  ///
  /// In en, this message translates to:
  /// **'This file was made by a newer version of the app. Please update to open it.'**
  String get importNewerVersion;

  /// No description provided for @importNoDirectiveData.
  ///
  /// In en, this message translates to:
  /// **'The file contains no directive data.'**
  String get importNoDirectiveData;

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

  /// Placeholder for typed dates. The field parses US month/day/year order, so translations must keep that order (e.g. es: MM/DD/AAAA).
  ///
  /// In en, this message translates to:
  /// **'MM/DD/YYYY'**
  String get dateInputHint;
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
