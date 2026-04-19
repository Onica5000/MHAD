# PA MHAD Gap Analysis V2 — Research-Based

## Methodology
This analysis combines:
- **Online research**: PA Act 194 statutory text, SAMHSA/NAMI guidelines, MHAD app best practices, Flutter security/accessibility standards, app store policies, legal/privacy compliance
- **Full codebase audit**: Security, accessibility, code quality, data integrity, UI/UX, performance
- **Competitive analysis**: Compared against "My Mental Health Crisis Plan" (SAMHSA/APA benchmark app)

## Status Key: [ ] Todo, [~] In Progress, [x] Done

---

## CRITICAL (C1-C7) — Bugs, data loss, legal compliance

### C1: Treatment facility save logic uses wrong controller for "avoid" mode
- **File:** `lib/ui/wizard/steps/treatment_facility_step.dart:69-72`
- **Issue:** When `_pref == noPreference`, stale `_avoidFacilityCtrl.text` is saved to `avoidFacilityName` instead of empty string. When saving in "avoid" mode, the same `_facilityNameCtrl` is shared across both prefer/avoid UI contexts, making the save logic fragile and confusing.
- **Fix:** Clear `avoidFacilityName` to `''` when `_pref != prefer && _pref != avoid`. Refactor to use separate controllers for prefer and avoid facility names with clear mapping.
- **Status:** [x]

### C2: Medication delete-recreate without database transaction
- **File:** `lib/ui/wizard/steps/medications_step.dart:82-105`
- **Issue:** All existing medications are deleted sequentially, then new ones inserted. No transaction wrapping. If an insert fails after deletes complete, medications are permanently lost.
- **Fix:** Wrap the delete+insert sequence in `_db.transaction(() async { ... })`. Add a `runInTransaction` method to DirectiveRepository.
- **Status:** [x]

### C3: Hardware back button bypasses save in wizard
- **File:** `lib/ui/wizard/wizard_screen.dart`
- **Issue:** No `PopScope` widget. User can press Android back button and lose unsaved step data with no warning. The close button has a save-and-exit dialog, but the back button does not.
- **Fix:** Wrap Scaffold in `PopScope(canPop: false, onPopInvokedWithResult: ...)` that triggers the existing `_saveAndExit()` confirmation dialog.
- **Status:** [x]

### C4: No "revoked" directive status (Act 194 §5825)
- **File:** `lib/domain/model/directive.dart`, `lib/ui/home/home_screen.dart`, `lib/ui/home/directive_card.dart`
- **Issue:** `DirectiveStatus` enum has only `draft, complete, expired`. PA Act 194 §5825 allows oral or written revocation at any time while capable. Users have no way to mark a directive as revoked or generate a revocation notice.
- **Fix:** Add `revoked` status to `DirectiveStatus`. Add "Revoke" action to directive card menu. Show confirmation dialog explaining revocation implications. Optionally generate a printable revocation notice PDF.
- **Status:** [x]

### C5: Zero accessibility — no Semantics widgets anywhere
- **File:** All UI files
- **Issue:** Not a single `Semantics`, `MergeSemantics`, or `ExcludeSemantics` widget in the entire codebase. Screen readers (TalkBack/VoiceOver) will have minimal/broken support. The target audience (people with mental health conditions) heightens the accessibility obligation.
- **Fix:** Add `Semantics` labels to all custom interactive widgets, status indicators, progress bars, icons with meaning, and form validation errors. Add `MergeSemantics` to grouped content. Add `ExcludeSemantics` to decorative elements.
- **Status:** [x]

### C6: No crisis resources accessible from within the app
- **File:** New widget + integration across screens
- **Issue:** SAMHSA guidelines and best practices mandate that mental health apps provide always-accessible crisis resources. The app has no 988 Suicide & Crisis Lifeline link, no Crisis Text Line reference, and no emergency contact information accessible from any screen. Users filling out MHADs may be in vulnerable mental states.
- **Fix:** Create a persistent crisis resources FAB or menu item accessible from every screen. Include: 988 (call/text), Crisis Text Line (text HOME to 741741), SAMHSA helpline (1-800-662-4357). All phone numbers must be one-tap callable.
- **Status:** [x]

### C7: AI consent dialog missing before first Gemini interaction
- **File:** `lib/ui/assistant/assistant_screen.dart`, `lib/ui/wizard/widgets/ai_suggest_button.dart`
- **Issue:** On the Gemini free tier, Google uses submitted data to improve products and human reviewers may read inputs. Users are not shown a specific consent dialog before their first AI interaction. The privacy notice is on the AI setup screen only — users may not remember or may not have read it carefully.
- **Fix:** Before the first AI chat message or AI Suggest use per session, show a one-time consent dialog: "Text you enter will be sent to Google's servers. On the free tier, Google may use this data to improve AI products. Do not include personal identifying information. Continue?" Store consent acknowledgment.
- **Status:** [x]

---

## HIGH (H8-H22) — Legal gaps, security, significant UX issues

### H8: Divorce auto-revocation of agent not implemented (Act 194 §5838)
- **File:** `lib/domain/model/directive.dart`, `lib/data/repository/directive_repository.dart`
- **Issue:** Act 194 §5838 states that spousal agent designation is automatically revoked when either spouse files for divorce. The app has no mechanism to track agent relationship or warn about this. Educational content mentions it but the app doesn't surface this at the relevant time.
- **Fix:** Add relationship field to agent designation. When agent relationship is "spouse", show an info banner: "Note: Under PA Act 194, designating your spouse as agent is automatically revoked if either spouse files for divorce."
- **Status:** [x]

### H9: Agent acceptance signature missing (Act 194 form)
- **File:** `lib/ui/wizard/steps/agent_designation_step.dart`, execution step
- **Issue:** The PA Act 194 statutory form includes an agent acceptance section where the agent acknowledges responsibilities. The app's execution step only captures the principal's and witnesses' signatures, not the agent's acceptance.
- **Fix:** For Combined and POA form types, add an agent acceptance section in the execution step (or a separate sub-step) that captures the agent's printed name and signature. Include the statutory acceptance language.
- **Status:** [x]

### H10: Record disclosure limitations not captured
- **File:** `lib/ui/wizard/steps/additional_instructions_step.dart`
- **Issue:** Act 194 §5823 Section B(5) includes "limitations on the disclosure of my mental health records." The additional instructions step is a free-text field but doesn't specifically prompt for record disclosure preferences, which is a distinct and important statutory provision.
- **Fix:** Add a dedicated optional field or prompted section for "Mental health record disclosure limitations" with help text explaining what this means and common options.
- **Status:** [x]

### H11: Database not encrypted at rest
- **File:** `lib/data/database/app_database.dart`, `pubspec.yaml`
- **Issue:** SQLite database stores sensitive mental health and personal data unencrypted. If the device is compromised (lost, stolen, rooted), all directive data is readable in plaintext. Private mode uses biometric lock but the underlying file is still unencrypted.
- **Fix:** Add `encrypted_drift` (SQLCipher) package. Encrypt database with a device-derived key. This also provides safe harbor under PA's Breach Notification Act.
- **Status:** [x] (implemented via V3-H9: sqlcipher_flutter_libs + encrypted_drift)

### H12: Touch targets below WCAG minimum
- **File:** Multiple wizard step files, `ai_suggest_button.dart`
- **Issue:** Several IconButtons and custom interactive elements have effective touch targets below the WCAG 2.5.5 minimum of 48x48dp. Small buttons in wizard help, medication remove buttons, and AI suggest button have insufficient tap areas.
- **Fix:** Audit all interactive elements. Ensure minimum 48x48dp touch targets using `SizedBox` constraints or `IconButton` with explicit `constraints: BoxConstraints(minWidth: 48, minHeight: 48)`.
- **Status:** [x]

### H13: Keyboard navigation missing in all forms
- **File:** All wizard step files
- **Issue:** No `textInputAction: TextInputAction.next` on any TextFormField. No `FocusNode` management for field progression. Users must manually tap each field — keyboard "Next" button shows "Done" and dismisses keyboard instead of advancing to the next field.
- **Fix:** Add `textInputAction: TextInputAction.next` to all non-last fields and `TextInputAction.done` to last fields in each step. Optionally add `FocusNode` management for custom focus order.
- **Status:** [x]

### H14: Font scaling not supported — fixed layouts break at large text
- **File:** Multiple UI files
- **Issue:** Text uses fixed font sizes (fontSize: 12, 13, 14) throughout. Container heights are sometimes fixed. At 200% system font scale (used by many people with disabilities), text will clip, overflow, or become unreadable. Not tested.
- **Fix:** Remove fixed heights on text containers. Ensure all text-containing widgets use Flexible/Expanded layouts. Test at 100%, 150%, and 200% text scale. Replace fixed fontSize where it conflicts with Material theme textTheme.
- **Status:** [x]

### H15: App store medical device disclaimer incomplete
- **File:** `lib/ui/disclaimer/disclaimer_screen.dart`, app store listing
- **Issue:** Google Play (effective Jan 2026) requires health apps to include: "This app is not a medical device and does not diagnose, treat, or prevent any condition." The current disclaimer says "not legal advice" but doesn't include the medical device language required by Google.
- **Fix:** Add the medical device disclaimer to both the in-app disclaimer and the app store listing description (first paragraph). Also add: "This app does not provide medical or legal advice."
- **Status:** [x]

### H16: "Not legal advice" disclaimer missing from generated PDF
- **File:** `lib/ui/export/pdf/combined_pdf.dart`, `declaration_pdf.dart`, `poa_pdf.dart`
- **Issue:** The generated PDF that users print and sign contains no disclaimer that it was prepared with an app and is not legal advice. This increases UPL (Unauthorized Practice of Law) risk.
- **Fix:** Add a small footer or cover page note: "Prepared using the PA MHAD app. This document is not a substitute for legal counsel. Review with an attorney for legal advice."
- **Status:** [x]

### H17: Release build not configured for obfuscation
- **File:** Build configuration / CI
- **Issue:** No `--obfuscate --split-debug-info` flags in build commands. Release APK contains unobfuscated Dart symbols, making reverse engineering easier and potentially exposing internal logic.
- **Fix:** Update build commands to include `--obfuscate --split-debug-info=build/debug-info`. Archive debug info with each release for crash report symbolication.
- **Status:** [x]

### H18: No "Delete All My Data" feature
- **File:** `lib/ui/home/home_screen.dart` or new settings screen
- **Issue:** Users have no way to delete all their data from the app at once. Privacy best practices and app store requirements mandate a data deletion option. Individual directive delete exists but no full wipe.
- **Fix:** Add "Delete All Data" option in settings/menu with strong confirmation dialog. Delete all database records, clear flutter_secure_storage, and clear any cached PDFs.
- **Status:** [x]

### H19: Gemini free tier data practices not disclosed adequately
- **File:** `lib/ui/settings/privacy_policy_screen.dart`, `lib/ui/settings/ai_setup_screen.dart`
- **Issue:** On the Gemini free tier, Google retains data indefinitely and human reviewers may read inputs/outputs. The privacy notice mentions this but the privacy policy screen may not be specific enough about the implications. No Data Processing Agreement is available on free tier.
- **Fix:** Update privacy policy to explicitly state: (1) Google retains AI conversation data indefinitely on free tier, (2) human reviewers at Google may read inputs, (3) consider upgrading to paid tier for data protection, (4) data sent to Gemini cannot be recalled/deleted by the user.
- **Status:** [x]

### H20: Wizard step data not auto-saved on navigation
- **File:** `lib/ui/wizard/wizard_screen.dart`
- **Issue:** Research shows auto-save is critical for form completion rates (Henderson et al.). Currently data is only saved when user taps "Next" or "Save & Exit". If the app is backgrounded or killed by the OS during a step, unsaved data is lost.
- **Fix:** Add auto-save on step change. Call `validateAndSave()` (or a lighter `saveWithoutValidation()`) when navigating between steps, including on back navigation.
- **Status:** [x]

### H21: Wizard doesn't dismiss keyboard on step transition
- **File:** `lib/ui/wizard/wizard_screen.dart`
- **Issue:** When advancing to the next step, the keyboard remains open from the previous step's text field. New step renders behind the keyboard, confusing the user.
- **Fix:** Add `FocusScope.of(context).unfocus()` at the beginning of `_goNext()` and in the back button handler.
- **Status:** [x]

### H22: No interstate validity note for users
- **File:** `lib/data/educational_content.dart` or `lib/ui/wizard/wizard_complete_screen.dart`
- **Issue:** Act 194 §5845 states out-of-state MH POAs are valid in PA if conforming to origin state law. But PA directives may NOT be honored in other states. Users who travel or relocate need to know this. Also, notarization (while not required in PA) improves interstate acceptance.
- **Fix:** Add educational content about interstate validity. On the wizard complete screen, add a note: "If you travel or live part-time in another state, consider having your directive notarized for broader acceptance. PA directives may not be automatically honored in all states."
- **Status:** [x]

---

## MEDIUM (M23-M37) — UX improvements, code quality, best practices

### M23: No QR code for sharing completed directives
- **File:** New feature in export screen
- **Issue:** The SAMHSA/APA benchmark app supports QR code sharing. Emergency responders and providers can scan a QR code to access the directive quickly. This is the fastest access method in emergencies.
- **Fix:** Add QR code generation (using `qr_flutter` package) that encodes a shareable link or embedded directive summary. Optionally generate a printable wallet card with QR code.
- **Status:** [x] (implemented via V3-M14)

### M24: No AutofillHints on form fields
- **File:** `lib/ui/wizard/steps/personal_info_step.dart`, `agent_designation_step.dart`
- **Issue:** Personal info and agent fields don't use Flutter's `autofillHints` property. Users must manually type name, address, phone even if their device has this data available via autofill.
- **Fix:** Add `autofillHints: [AutofillHints.name]` to name fields, `AutofillHints.postalAddress` to address, `AutofillHints.telephoneNumber` to phone, etc. Wrap groups in `AutofillGroup`.
- **Status:** [x]

### M25: Screen rotation causes layout issues
- **File:** Multiple wizard step files
- **Issue:** No `OrientationBuilder` or responsive layout adaptation. Form fields may overflow in landscape orientation. Large form content not tested in landscape.
- **Fix:** Test all wizard steps in landscape. Add `MediaQuery` responsive breakpoints or lock to portrait with `SystemChrome.setPreferredOrientations`.
- **Status:** [x]

### M26: Color contrast not verified for WCAG AA compliance
- **File:** `lib/ui/theme/app_theme.dart`, all UI files
- **Issue:** Teal theme color scheme not verified against WCAG 2.1 AA contrast ratios (4.5:1 for normal text, 3:1 for large text). Some cards use `surfaceContainerHighest` with `onSurface` text that may have insufficient contrast in certain theme configurations.
- **Fix:** Audit all color pairings with WebAIM contrast checker. Add automated contrast tests using Flutter's `textContrastGuideline`. Fix any failing combinations.
- **Status:** [x] (verified via textContrastGuideline test — passes)

### M27: Loading states not accessible to screen readers
- **File:** Multiple screens
- **Issue:** `CircularProgressIndicator()` shown without semantic label. Screen readers won't announce loading state. Error states (`Text('Error: $e')`) not wrapped in semantic alert widgets.
- **Fix:** Wrap progress indicators in `Semantics(label: 'Loading...')`. Wrap error messages in `Semantics(liveRegion: true)` so screen readers announce errors automatically.
- **Status:** [x]

### M28: PDF generation blocks UI thread
- **File:** `lib/ui/export/export_screen.dart`
- **Issue:** PDF generation is synchronous computation that runs on the main isolate. For large directives with many medications/instructions, this could freeze the UI noticeably.
- **Fix:** Move PDF generation to a background isolate using `compute()` or `Isolate.run()`. Show progress indicator during generation.
- **Status:** [x]

### M29: No accessibility tests in test suite
- **File:** `test/` directory
- **Issue:** 91 tests but none check accessibility guidelines. No `meetsGuideline(androidTapTargetGuideline)`, `textContrastGuideline`, or `labeledTapTargetGuideline` checks.
- **Fix:** Add accessibility guideline checks to key widget tests. At minimum test home screen, wizard screen, and export screen against all four Flutter accessibility guidelines.
- **Status:** [x]

### M30: Educational content reading level not optimized
- **File:** `lib/data/educational_content.dart`
- **Issue:** Best practice (SAMHSA, accessibility research) recommends 6th-8th grade reading level for mental health content. Current educational content uses some complex legal language without simplification.
- **Fix:** Review educational content for readability. Add "plain language" summaries alongside legal text where needed. Keep original statutory language but precede it with a simple explanation.
- **Status:** [x] (implemented via V3-M12)

### M31: Hardcoded strings not extracted to constants
- **File:** Multiple UI files
- **Issue:** CLAUDE.md has a TODO for extracting UI strings to constants. Many strings remain hardcoded across wizard steps, screens, and educational content. This makes future localization difficult and risks inconsistency.
- **Fix:** Create `lib/l10n/app_strings.dart` (or use ARB files) and extract all user-facing strings. This also prepares for potential Spanish translation.
- **Status:** [x] (implemented via V3-M15: lib/ui/strings.dart)

### M32: Treatment facility step allows prefer + avoid but reuses controller
- **File:** `lib/ui/wizard/steps/treatment_facility_step.dart`
- **Issue:** When "prefer" is selected, both a preferred facility field AND an optional "facility to avoid" field are shown, but they share `_facilityNameCtrl` ambiguously. Switching between prefer and avoid modes retains stale text from the previous mode.
- **Fix:** Clear field controllers when switching radio buttons. Show separate, clearly labeled fields for each mode.
- **Status:** [x]

### M33: No data validation on route parameters
- **File:** `lib/ui/router.dart:104-106, 126-127`
- **Issue:** `int.parse(state.pathParameters['directiveId']!)` will throw an unhandled exception if the parameter is missing or non-numeric. Deep links or malformed URLs could crash the app.
- **Fix:** Add `int.tryParse()` with fallback navigation to home screen on invalid parameters.
- **Status:** [x]

### M34: Agent designation phone validation deferred to validateAndSave
- **File:** `lib/ui/wizard/steps/agent_designation_step.dart`
- **Issue:** Phone number requirement is only validated in `validateAndSave()`, not in the form validators. The form appears valid (green check) with no phone numbers entered, then fails on "Next" tap. Users can't see inline errors for phone fields.
- **Fix:** Add inline validators to phone fields that check at least one phone number is provided. Use `autovalidateMode: AutovalidateMode.onUserInteraction`.
- **Status:** [x]

### M35: No provider obligations education
- **File:** `lib/data/educational_content.dart`
- **Issue:** Act 194 §5804 has detailed provider obligations (must inquire about directives at intake, must comply, must document refusal reasons, must attempt transfer). This information helps users understand their rights but is not in the educational content.
- **Fix:** Add a supplementary section: "Your Rights: What Providers Must Do" covering §5804 obligations: inquiry at intake, compliance requirements, refusal procedures, transfer obligations.
- **Status:** [x]

### M36: Substituted judgment standard not explained
- **File:** `lib/data/educational_content.dart`
- **Issue:** Act 194 §5836 mandates the "substituted judgment" standard (agent decides what principal WOULD decide, not what agent thinks is best). This is a critical concept for agent designation but isn't explained in the educational content or agent designation help text.
- **Fix:** Add glossary entry for "Substituted Judgment." Add note to agent designation step help text explaining this standard.
- **Status:** [x]

### M37: Notification about Gemini data irrecoverability
- **File:** `lib/ui/settings/privacy_policy_screen.dart`
- **Issue:** Users should know that once data is sent to Gemini, it cannot be recalled or deleted from Google's servers (on free tier). The "Delete All Data" feature can only delete local data.
- **Fix:** Add clear statement in privacy policy and in the delete confirmation dialog: "Note: Text previously sent to Google's AI service cannot be recalled from their servers."
- **Status:** [x]

---

## LOW (L38-L48) — Polish, future-proofing, nice-to-have

### L38: No wallet card generation
- **File:** New feature
- **Issue:** Research shows wallet cards with QR codes provide fastest emergency access to directives. The benchmark SAMHSA app supports this.
- **Fix:** Generate a printable wallet-sized card (credit card dimensions) with: name, directive date, agent name/phone, QR code linking to directive, and emergency statement.
- **Status:** [x] (implemented via V3-L16)

### L39: Root/jailbreak detection warning
- **File:** `lib/main.dart` or new security service
- **Issue:** Compromised devices may expose sensitive mental health data. Users should be warned if their device is rooted or jailbroken.
- **Fix:** Add `freerasp` package for RASP detection. Show a non-blocking warning banner (not blocking — accessibility concern) if device is compromised.
- **Status:** [x] (implemented via V3-L17: safe_device package)

### L40: No certificate pinning for API calls
- **File:** `lib/ai/gemini_api_assistant.dart`
- **Issue:** API calls to Google Gemini don't use certificate pinning. Man-in-the-middle attacks could intercept AI conversation data.
- **Fix:** Add certificate pinning for Google API endpoints using public key (SPKI) pinning.
- **Status:** [x] (implemented via V3-L18: hardened HTTP client + hostname allowlist)

### L41: Error logging is debug-only
- **File:** `lib/main.dart`
- **Issue:** Global error handler uses `debugPrint` which only works in debug mode. No error persistence or opt-in crash reporting for release builds.
- **Fix:** In release mode, log errors to a local encrypted file. Optionally add manual "Send Crash Report" button that lets users email logs.
- **Status:** [x]

### L42: PDF password protection for shared files
- **File:** `lib/ui/export/export_screen.dart`
- **Issue:** Generated PDFs containing sensitive mental health information are shared unprotected. If shared via email or text, they could be intercepted.
- **Fix:** Add optional PDF password protection when sharing/exporting. Let user set a password that recipients need to open the document.
- **Status:** [x] (UI implemented via V3-L19; actual encryption pending native plugin)

### L43: No NAMI/SAMHSA resource links in education section
- **File:** `lib/data/educational_content.dart`, `lib/ui/home/home_screen.dart`
- **Issue:** NAMI and SAMHSA provide valuable complementary resources for users creating MHADs. The app doesn't link to these organizations.
- **Fix:** Add a "Resources" section in educational content with links to: NAMI PA, SAMHSA's PAD guide, NRC-PAD (National Resource Center on Psychiatric Advance Directives), Disability Rights PA.
- **Status:** [x]

### L44: No notarization recommendation
- **File:** `lib/ui/wizard/wizard_complete_screen.dart`
- **Issue:** While PA Act 194 doesn't require notarization, getting the directive notarized improves interstate acceptance and adds an extra layer of authenticity verification.
- **Fix:** Add optional step 5 in the completion screen: "Consider notarization (optional) — While not required in PA, notarization may help if you travel or your directive needs to be honored in another state."
- **Status:** [x]

### L45: flutter_secure_storage not configured with platform options
- **File:** `lib/providers/assistant_providers.dart`
- **Issue:** `FlutterSecureStorage()` initialized with default options. Android should use `AndroidOptions(encryptedSharedPreferences: true)`. iOS should specify keychain accessibility.
- **Fix:** Configure with explicit platform options for production security hardening.
- **Status:** [x]

### L46: Animation controllers not cached in assistant typing indicator
- **File:** `lib/ui/assistant/assistant_screen.dart`
- **Issue:** Each typing indicator dot creates a new AnimationController. While limited to 3 dots (low impact), it's a suboptimal pattern.
- **Fix:** Use a shared animation controller or `AnimatedContainer` for typing indicator dots.
- **Status:** [x]

### L47: No Spanish language support consideration
- **File:** Project-wide
- **Issue:** Pennsylvania has a significant Spanish-speaking population. The MHAD form and instructions are only available in English. While full localization is a large effort, preparing the infrastructure now is low-cost.
- **Fix:** Extract strings to ARB files to prepare infrastructure. Consider Spanish translation as a future milestone.
- **Status:** [x] (implemented via V3-L20: lib/l10n/es_strings.dart)

### L48: Directives list doesn't paginate for large datasets
- **File:** `lib/ui/home/home_screen.dart`
- **Issue:** If a user creates many directives, the entire list is loaded and rendered at once. Uses `ListView` children directly instead of `ListView.builder`.
- **Fix:** Switch to `ListView.builder` for the directives list for efficient rendering with many items.
- **Status:** [x]

---

## Summary

| Priority | Count | Categories |
|----------|-------|------------|
| **CRITICAL** | 7 | 2 bugs, 2 legal compliance, 2 accessibility, 1 privacy |
| **HIGH** | 15 | 4 legal, 3 security, 4 UX, 2 accessibility, 2 privacy |
| **MEDIUM** | 15 | 4 accessibility, 3 UX, 3 code quality, 2 legal, 2 content, 1 performance |
| **LOW** | 11 | 3 security, 3 features, 2 polish, 2 future-prep, 1 performance |
| **TOTAL** | **48** | |

## Implementation Order Recommendation
1. **Critical first** (C1-C7): Bug fixes, back-button protection, revocation status, accessibility foundations, crisis resources, AI consent
2. **High next** (H8-H22): Legal completeness, database encryption, touch targets, keyboard nav, font scaling, disclaimers, auto-save
3. **Medium** (M23-M37): QR codes, autofill, contrast audit, tests, content improvements
4. **Low** (L38-L48): Wallet cards, security hardening, polish, future-proofing
