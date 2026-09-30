import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/data/educational_content.dart';
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

/// Localizes a step name carried in [AssistantContext.stepName]. That field
/// holds the English [WizardStepExt.displayName] because it also feeds the AI
/// prompt. 'Learning' is the Learn page's context; anything else passes
/// through unchanged.
String localizedStepName(String stepName, AppLocalizations l) {
  for (final s in WizardStep.values) {
    if (s.displayName == stepName) return s.title(l);
  }
  if (stepName == 'Learning') return l.assistantContextLearning;
  return stepName;
}

extension EducationCategoryL10n on EducationCategory {
  String label(AppLocalizations l) => switch (this) {
        EducationCategory.intro => l.eduBrowseIntroduction,
        EducationCategory.faq => l.educationCategoryFaq,
        EducationCategory.combined => l.eduBrowseCombinedForm,
        EducationCategory.declaration => l.formTypeShortDeclaration,
        EducationCategory.poa => l.eduBrowsePowerOfAttorney,
        EducationCategory.glossary => l.eduBrowseGlossary,
        EducationCategory.supplementary => l.eduBrowseBeyondTheBooklet,
        EducationCategory.checklist => l.eduBrowseYourChecklist,
      };
}
