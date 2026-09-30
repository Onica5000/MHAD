import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/app_localizations.dart';

/// Localized display labels for domain enums. The English getters on the
/// enums themselves (`displayName`, `shortName`, `subtitle`) stay as-is for
/// the AI context and PDF paths, which are English by design.
extension FormTypeL10n on FormType {
  String label(AppLocalizations l) => switch (this) {
        FormType.combined => l.formTypeNameCombined,
        FormType.declaration => l.formTypeNameDeclaration,
        FormType.poa => l.formTypeNamePoa,
      };

  String shortLabel(AppLocalizations l) => switch (this) {
        FormType.combined => l.formTypeShortCombined,
        FormType.declaration => l.formTypeShortDeclaration,
        FormType.poa => l.formTypeShortPoa,
      };
}

extension WizardStepL10n on WizardStep {
  String title(AppLocalizations l) => switch (this) {
        WizardStep.aboutYou => l.stepTitleAboutYou,
        WizardStep.whenItKicksIn => l.stepTitleWhenItKicksIn,
        WizardStep.peopleITrust => l.stepTitlePeopleITrust,
        WizardStep.guardianNomination => l.stepTitleGuardianNomination,
        WizardStep.whereIWantCare => l.stepTitleWhereIWantCare,
        WizardStep.diagnoses => l.stepTitleDiagnoses,
        WizardStep.medications => l.stepTitleMedications,
        WizardStep.allergies => l.stepTitleAllergies,
        WizardStep.proceduresResearch => l.stepTitleProceduresResearch,
        WizardStep.anythingElse => l.stepTitleAnythingElse,
        WizardStep.reviewAndSign => l.stepTitleReviewAndSign,
      };

  String localizedSubtitle(AppLocalizations l) => switch (this) {
        WizardStep.aboutYou => l.stepSubtitleAboutYou,
        WizardStep.whenItKicksIn => l.stepSubtitleWhenItKicksIn,
        WizardStep.peopleITrust => l.stepSubtitlePeopleITrust,
        WizardStep.guardianNomination => l.stepSubtitleGuardianNomination,
        WizardStep.whereIWantCare => l.stepSubtitleWhereIWantCare,
        WizardStep.diagnoses => l.stepSubtitleDiagnoses,
        WizardStep.medications => l.stepSubtitleMedications,
        WizardStep.allergies => l.stepSubtitleAllergies,
        WizardStep.proceduresResearch => l.stepSubtitleProceduresResearch,
        WizardStep.anythingElse => l.stepSubtitleAnythingElse,
        WizardStep.reviewAndSign => l.stepSubtitleReviewAndSign,
      };
}
