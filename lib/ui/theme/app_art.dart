import 'package:flutter/widgets.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/widgets/design/spot_illustration.dart';

/// Every illustration the app ships, in one place.
///
/// Mirrors `tool/art/art_manifest.json` (the generation source of truth):
/// `test/unit/app_art_test.dart` fails if an id is missing on either side, if
/// a file is missing on disk, or if its folder isn't declared in pubspec.yaml.
/// Images are AI-generated with Grok Imagine (image_gen) and never contain
/// text, so they work in every locale.
enum AppArt {
  // ── Welcome (pre-app gates) ────────────────────────────────────────────
  welcomeDisclaimerTall('welcome', 'welcome_disclaimer_tall', 2 / 3, Alignment.center, SpotArt.document),
  welcomeDisclaimerWide('welcome', 'welcome_disclaimer_wide', 16 / 9, Alignment.centerRight, SpotArt.document),
  welcomeOnboardingTall('welcome', 'welcome_onboarding_tall', 2 / 3, Alignment.center, SpotArt.voice),
  welcomeOnboardingWide('welcome', 'welcome_onboarding_wide', 16 / 9, Alignment.centerLeft, SpotArt.voice),

  // ── Home ───────────────────────────────────────────────────────────────
  homeHero('home', 'home_hero', 16 / 9, Alignment.center, SpotArt.welcome),
  formCombined('home', 'form_combined', 3 / 2, Alignment.center, SpotArt.people),
  formDeclaration('home', 'form_declaration', 3 / 2, Alignment.center, SpotArt.document),
  formPoa('home', 'form_poa', 3 / 2, Alignment.center, SpotArt.people),
  startUpload('home', 'start_upload', 3 / 2, Alignment.center, SpotArt.document),
  startResume('home', 'start_resume', 3 / 2, Alignment.center, SpotArt.document),
  startPrint('home', 'start_print', 3 / 2, Alignment.center, SpotArt.document),
  homePrivacy('home', 'home_privacy', 3 / 2, Alignment.center, SpotArt.shield),
  homeQuiz('home', 'home_quiz', 1, Alignment.center, SpotArt.search),

  // ── Learn ──────────────────────────────────────────────────────────────
  learnHero('learn', 'learn_hero', 16 / 9, Alignment.center, SpotArt.book),
  learnArticles('learn', 'learn_articles', 1, Alignment.center, SpotArt.book),
  learnGlossary('learn', 'learn_glossary', 1, Alignment.center, SpotArt.search),
  learnFaq('learn', 'learn_faq', 1, Alignment.center, SpotArt.voice),
  learnChecklists('learn', 'learn_checklists', 1, Alignment.center, SpotArt.success),
  learnEmpty('learn', 'learn_empty', 1, Alignment.center, SpotArt.search),

  // ── AI ─────────────────────────────────────────────────────────────────
  aiAssistant('ai', 'ai_assistant', 1, Alignment.center, SpotArt.voice),
  aiSetup('ai', 'ai_setup', 3 / 2, Alignment.center, SpotArt.shield),
  aiCheck('ai', 'ai_check', 3 / 2, Alignment.center, SpotArt.success),

  // ── Wizard steps ───────────────────────────────────────────────────────
  stepAboutYou('steps', 'step_about_you', 1, Alignment.center, SpotArt.document),
  stepWhenItKicksIn('steps', 'step_when_it_kicks_in', 1, Alignment.center, SpotArt.calendar),
  stepPeopleITrust('steps', 'step_people_i_trust', 1, Alignment.center, SpotArt.people),
  stepGuardian('steps', 'step_guardian', 1, Alignment.center, SpotArt.shield),
  stepWhereIWantCare('steps', 'step_where_i_want_care', 1, Alignment.center, SpotArt.welcome),
  stepDiagnoses('steps', 'step_diagnoses', 1, Alignment.center, SpotArt.document),
  stepAllergies('steps', 'step_allergies', 1, Alignment.center, SpotArt.shield),
  stepMedications('steps', 'step_medications', 1, Alignment.center, SpotArt.calendar),
  stepProceduresResearch('steps', 'step_procedures_research', 1, Alignment.center, SpotArt.search),
  stepAnythingElse('steps', 'step_anything_else', 1, Alignment.center, SpotArt.voice),
  stepReview('steps', 'step_review', 1, Alignment.center, SpotArt.success),

  // ── After the wizard ───────────────────────────────────────────────────
  flowSign('flow', 'flow_sign', 3 / 2, Alignment.center, SpotArt.people),
  flowExport('flow', 'flow_export', 3 / 2, Alignment.center, SpotArt.document),
  flowFindable('flow', 'flow_findable', 3 / 2, Alignment.center, SpotArt.search),
  flowCrisisPlan('flow', 'flow_crisis_plan', 3 / 2, Alignment.center, SpotArt.shield),
  flowUlysses('flow', 'flow_ulysses', 3 / 2, Alignment.center, SpotArt.welcome),
  flowSideEffects('flow', 'flow_side_effects', 3 / 2, Alignment.center, SpotArt.document),
  flowRevocation('flow', 'flow_revocation', 3 / 2, Alignment.center, SpotArt.document),
  flowPast('flow', 'flow_past', 3 / 2, Alignment.center, SpotArt.calendar),
  flowFacilitator('flow', 'flow_facilitator', 3 / 2, Alignment.center, SpotArt.people),
  flowAudio('flow', 'flow_audio', 1, Alignment.center, SpotArt.voice),

  // ── Settings & misc ────────────────────────────────────────────────────
  miscSettings('misc', 'misc_settings', 3 / 2, Alignment.center, SpotArt.document),
  miscAccessibility('misc', 'misc_accessibility', 1, Alignment.center, SpotArt.book),
  miscPrivacy('misc', 'misc_privacy', 1, Alignment.center, SpotArt.shield),
  miscError('misc', 'misc_error', 1, Alignment.center, SpotArt.search);

  /// Folder under `assets/images/` (each is declared in pubspec.yaml).
  final String group;

  /// Manifest id == file name (without extension).
  final String id;

  /// Width ÷ height of the generated image.
  final double aspectRatio;

  /// Where to keep the subject when the image is cropped (`BoxFit.cover`).
  final Alignment focal;

  /// Code-drawn stand-in shown if the asset fails to load.
  final SpotArt fallback;

  const AppArt(this.group, this.id, this.aspectRatio, this.focal, this.fallback);

  String get assetPath => 'assets/images/$group/$id.webp';

  /// Pixel width of the shipped WebP (matches the manifest's `widths`), the
  /// ceiling for decode size.
  int get maxPixelWidth => switch (aspectRatio) {
        > 1.6 => 1600, // 16:9
        > 1.2 => 1200, // 3:2
        < 0.8 => 900, // 2:3
        _ => 800, // 1:1
      };
}

/// The illustration for each wizard step — one definition, used by the step
/// header (and anything else that shows a step's art).
extension WizardStepArt on WizardStep {
  AppArt get art => switch (this) {
        WizardStep.aboutYou => AppArt.stepAboutYou,
        WizardStep.whenItKicksIn => AppArt.stepWhenItKicksIn,
        WizardStep.peopleITrust => AppArt.stepPeopleITrust,
        WizardStep.guardianNomination => AppArt.stepGuardian,
        WizardStep.whereIWantCare => AppArt.stepWhereIWantCare,
        WizardStep.diagnoses => AppArt.stepDiagnoses,
        WizardStep.medications => AppArt.stepMedications,
        WizardStep.allergies => AppArt.stepAllergies,
        WizardStep.proceduresResearch => AppArt.stepProceduresResearch,
        WizardStep.anythingElse => AppArt.stepAnythingElse,
        WizardStep.reviewAndSign => AppArt.stepReview,
      };
}
