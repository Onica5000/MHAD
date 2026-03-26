// Centralized UI strings for future localization (l10n) support.
//
// This file extracts the most common and important hardcoded strings from
// across the MHAD app into a single location. When the project adopts
// flutter_localizations / intl / arb-based localization, these constants
// can be replaced with generated message lookups.
//
// Usage (future): replace direct string literals in widgets with
//   AppStrings.<constant>
// and eventually with Intl.message() or context.l10n.<key> equivalents.

/// Contains all user-visible strings used across the MHAD app UI.
///
/// Organized by feature area. Every value is a `static const String` so it
/// can be used in const widget constructors and is tree-shaken when unused.
class AppStrings {
  AppStrings._(); // prevent instantiation

  // ---------------------------------------------------------------------------
  // App-wide
  // ---------------------------------------------------------------------------

  static const appTitle = 'PA Mental Health Advance Directive';

  static const appTitleMultiline = 'PA Mental Health\nAdvance Directive';

  // ---------------------------------------------------------------------------
  // Common button labels
  // ---------------------------------------------------------------------------

  static const cancel = 'Cancel';

  static const delete = 'Delete';

  static const save = 'Save';

  static const saveAndExit = 'Save & Exit';

  static const continueLabel = 'Continue';

  static const back = 'Back';

  static const next = 'Next';

  static const finish = 'Finish';

  static const close = 'Close';

  static const clear = 'Clear';

  static const accept = 'Accept';

  static const dismiss = 'Dismiss';

  static const iUnderstand = 'I Understand';

  static const iAuthorize = 'I Authorize';

  // ---------------------------------------------------------------------------
  // Home screen
  // ---------------------------------------------------------------------------

  static const newDirective = 'New Directive';

  static const myDirectives = 'My Directives';

  static const noDirectivesYet = 'No directives yet';

  static const noDirectivesHint = 'Tap "New Directive" to get started';

  static const learnAboutMhads = 'Learn About MHADs';

  static const learnAboutMhadsSubtitle =
      'FAQ, instructions, glossary, legal details & checklist';

  static const getHelp = 'Get Help';

  static const privacyPolicy = 'Privacy Policy';

  static const deleteAllData = 'Delete All Data';

  static const exportAllData = 'Export All Data';

  static const switchToPublicMode = 'Switch to Public Mode';

  // ---------------------------------------------------------------------------
  // Disclaimer / legal
  // ---------------------------------------------------------------------------

  static const disclaimerBanner =
      'This app helps you document your mental health preferences. '
      'It is not legal advice. Directives are valid for 2 years under '
      'PA Act 194 of 2004.';

  static const importantNotice = 'Important Notice';

  static const pleaseReadCarefully =
      'Please read carefully before using this app.';

  static const notLegalAdvice = 'Not Legal or Medical Advice';

  static const iAmAdult = 'I am 18 years of age or older, or an emancipated minor';

  static const disclaimerAcceptPrefix =
      'By tapping "I Understand" you confirm you have read and '
      'understand the above information.';

  static const aiNotLegalAdvice =
      'AI-generated \u00b7 Not legal, medical, or therapeutic advice';

  static const aiSuggestNotLegalAdvice =
      'AI suggestions are not legal advice. Review carefully before accepting.';

  // ---------------------------------------------------------------------------
  // Directive status labels
  // ---------------------------------------------------------------------------

  static const statusDraft = 'Draft';

  static const statusComplete = 'Complete';

  static const statusExpired = 'Expired';

  static const statusRevoked = 'Revoked';

  // ---------------------------------------------------------------------------
  // Form type labels
  // ---------------------------------------------------------------------------

  static const formTypeCombined = 'Combined';

  static const formTypeDeclaration = 'Declaration';

  static const formTypePoa = 'Power of Attorney';

  static const formTypePoaShort = 'POA';

  // ---------------------------------------------------------------------------
  // Form type selection screen
  // ---------------------------------------------------------------------------

  static const chooseFormType = 'Choose Form Type';

  static const whichFormType =
      'Which type of directive would you like to create?';

  static const formTypeHint =
      'Not sure? The Combined form gives you the most options \u2014 '
      'you can designate an agent AND document your treatment preferences.';

  static const recommended = 'Recommended';

  static const helpMeChoose = 'Help me choose';

  // ---------------------------------------------------------------------------
  // Wizard
  // ---------------------------------------------------------------------------

  static const saveExitTitle = 'Save & Exit';

  static const saveExitMessage =
      'Your progress on this step will be saved. '
      'You can return to continue later (Private Mode only).';

  static const directiveNotFound = 'Directive not found.';

  // ---------------------------------------------------------------------------
  // Wizard complete screen
  // ---------------------------------------------------------------------------

  static const directiveComplete = 'Directive Complete';

  static const directiveSaved = 'Your directive is saved!';

  static const nextStepsIntro =
      'Here are the next steps to make it legally valid:';

  static const exportPdf = 'Export PDF';

  static const goToHome = 'Go to Home';

  static const distributionChecklist = 'Distribution Checklist';

  static const afterPrintingAndSigning =
      'After printing and signing, give copies to:';

  // ---------------------------------------------------------------------------
  // Export screen
  // ---------------------------------------------------------------------------

  static const exportDirective = 'Export Directive';

  static const previewPdf = 'Preview PDF';

  static const pdfPreview = 'PDF Preview';

  static const sharePrint = 'Share / Print';

  static const selectFormsToInclude = 'Select forms to include:';

  static const additionalPages = 'Additional Pages:';

  static const selectAtLeastOneSection =
      'Select at least one section to include.';

  static const selectAtLeastOnePreview =
      'Select at least one section to preview.';

  static const exportDisclaimer =
      'Before sharing: ensure this directive has been signed, dated, '
      'and witnessed by two adults (18+) as required by PA Act 194. '
      'Give copies to your agent, physician, and support people.';

  static const principal = 'Principal';

  // ---------------------------------------------------------------------------
  // AI assistant
  // ---------------------------------------------------------------------------

  static const aiAssistant = 'AI Assistant';

  static const aiAssistantSetup = 'AI Assistant Setup';

  static const askQuestionHint = 'Ask a question about your directive...';

  static const aiSuggestion = 'AI Suggestion';

  static const suggestedQuestions = 'Suggested questions:';

  static const clearConversation = 'Clear conversation?';

  static const clearConversationMessage =
      'This will erase all messages. This cannot be undone.';

  static const aiDataNotice = 'AI Data Notice';

  static const setUpFree = 'Set Up (Free)';

  static const aiSetupPrompt =
      'To use the AI assistant, set up your free Gemini API key.';

  static const privacyNotice = 'Privacy Notice';

  static const saveApiKey = 'Save API Key';

  static const removeApiKey = 'Remove API Key?';

  static const apiKeySaved = 'API key saved';

  static const apiKeyRemoved = 'API key removed';

  // ---------------------------------------------------------------------------
  // Mode selection
  // ---------------------------------------------------------------------------

  static const chooseAccessMode = 'Choose Access Mode';

  static const publicMode = 'Public Mode';

  static const privateMode = 'Private Mode';

  static const sessionSelectionFooter =
      'This selection applies to this session only. '
      'You will be asked again the next time you open the app.';

  static const authFailed =
      'Authentication failed or was cancelled. Please try again.';

  // ---------------------------------------------------------------------------
  // Error messages
  // ---------------------------------------------------------------------------

  static const errorLoadingDirectives = 'Error loading directives';

  static const errorGeneratingPdf = 'Error generating PDF';

  static const exportFailed = 'Export failed';

  static const failedToDeleteData = 'Failed to delete data';

  static const allDataDeleted = 'All data deleted successfully.';

  static const aiSuggestionFailed = 'AI suggestion failed';

  static const enterTextFirst = 'Enter some text first, then tap AI Suggest.';

  // ---------------------------------------------------------------------------
  // Confirmation dialogs
  // ---------------------------------------------------------------------------

  static const deleteDirectiveTitle = 'Delete directive?';

  static const deleteDirectiveMessage =
      'This cannot be undone. All data for this directive will be '
      'permanently deleted.';

  static const revokeDirectiveTitle = 'Revoke Directive?';

  static const deleteAllTitle = 'Delete All Data?';

  static const switchToPublicTitle = 'Switch to Public Mode?';

  // ---------------------------------------------------------------------------
  // Crisis resources
  // ---------------------------------------------------------------------------

  static const crisisResources = 'Crisis Resources';

  static const needHelpNow = 'Need help now? Tap for crisis resources';

  static const crisis988Title = '988 Suicide & Crisis Lifeline';

  static const crisisTextLineTitle = 'Crisis Text Line';

  static const samhsaTitle = 'SAMHSA Helpline';

  // ---------------------------------------------------------------------------
  // Accessibility / semantics
  // ---------------------------------------------------------------------------

  static const loading = 'Loading';

  static const saving = 'Saving';

  static const error = 'Error';

  static const notFound = 'Not found';
}
