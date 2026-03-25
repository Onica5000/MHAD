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
      'Your progress on this step will be saved. You can return to continue later (Private Mode only).';

  @override
  String get legalDisclaimer =>
      'This app does not provide legal advice. Information is for educational purposes only and does not substitute for a licensed attorney. Consult a legal professional before executing any legal document.';

  @override
  String get aiDisclaimer =>
      'The AI assistant provides general information only. It is not a substitute for legal, medical, or professional advice.';

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
}
