# PA MHAD Gap Analysis Implementation Plan

## Status Key: [ ] Todo, [~] In Progress, [x] Done

---

## CRITICAL (1-6)

### C1: Chat history sent to Gemini unstripped
- **File:** `lib/ui/assistant/assistant_screen.dart`
- **Fix:** Strip PII from every `ChatMessage.content` in the history list before passing to `sendMessage()`
- **Status:** [x]

### C2: AI Suggest sends raw field content
- **File:** `lib/ui/wizard/widgets/ai_suggest_button.dart`
- **Fix:** Call `PiiStripper.strip()` on `currentText` before embedding in prompt template
- **Status:** [x]

### C3: Signature pad white background in dark mode
- **File:** `lib/ui/wizard/steps/execution_step.dart`
- **Fix:** Replace `Colors.white` with `Theme.of(context).colorScheme.surface`
- **Status:** [x]

### C4: Effective Condition help text omits evaluator options
- **File:** `lib/ui/wizard/steps/effective_condition_step.dart`
- **Fix:** Update help text to include full list: psychiatrist + another psychiatrist, psychologist, family physician, attending physician, or MH professional
- **Status:** [x]

### C5: Agent Designation help text adds non-MHAD restriction
- **File:** `lib/ui/wizard/steps/agent_designation_step.dart`
- **Fix:** Remove "financial interest in your estate" — not in Act 194. Keep only the actual Act 194 prohibitions.
- **Status:** [x]

### C6: Dead claude_api_assistant.dart file
- **File:** `lib/ai/claude_api_assistant.dart`
- **Fix:** Delete the file. Remove any remaining imports/references.
- **Status:** [x]

---

## HIGH (7-19)

### H7: PII stripper doesn't detect full names
- **File:** `lib/ai/pii_stripper.dart`
- **Fix:** Add name-pattern regex for common formats: "Dr. First Last", "Mr./Mrs./Ms. First Last", and standalone "First Last" preceded by keywords like "agent", "sister", "brother", "friend", "named"
- **Status:** [x]

### H8: Unlabeled dates of birth not caught
- **File:** `lib/ai/pii_stripper.dart`
- **Fix:** Add a broader date pattern that catches MM/DD/YYYY and MM-DD-YYYY without requiring a "DOB:" label, but only when preceded by birth-related or personal context words to limit false positives
- **Status:** [x]

### H9: No in-app privacy policy
- **Files:** New `lib/ui/settings/privacy_policy_screen.dart`, update `lib/ui/router.dart`, add link from settings
- **Fix:** Create a privacy policy screen with sections covering: data collected, local storage, Gemini API data sharing, no analytics/telemetry, user rights (delete data), contact info
- **Status:** [x]

### H10: No API call timeout
- **File:** `lib/ai/gemini_api_assistant.dart`
- **Fix:** Wrap `chat.sendMessage()` with `.timeout(const Duration(seconds: 30))` and catch `TimeoutException`
- **Status:** [x]

### H11: No global error handler
- **File:** `lib/main.dart`
- **Fix:** Add `FlutterError.onError` handler and wrap `runApp` in `runZonedGuarded` to catch async errors. Log to debugPrint.
- **Status:** [x]

### H12: No database indexes
- **File:** `lib/data/database/app_database.dart`
- **Fix:** Add `@TableIndex` annotations on `directiveId` columns for: Agents, MedicationEntries, Witnesses, DirectivePrefs, AdditionalInstructionsTable, GuardianNominations. Bump schema version and add migration.
- **Status:** [x]

### H13: No database migration strategy
- **File:** `lib/data/database/app_database.dart`
- **Fix:** Add `MigrationStrategy` with `onUpgrade` handler. Implement migration from v1 to v2 (adding indexes).
- **Status:** [x]

### H14: Glossary missing key terms
- **File:** `lib/data/educational_content.dart`
- **Fix:** Add glossary entries for: "Incapacity", "Psychotropic Medication", "Involuntary Commitment"
- **Status:** [x]

### H15: ECT/Drug Trials help text missing agent auth constraint
- **Files:** `lib/ui/wizard/steps/ect_step.dart`, `lib/ui/wizard/steps/drug_trials_step.dart`
- **Fix:** Add to help text: "Under PA Act 194, your agent is NOT allowed to consent to ECT/experimental treatment unless you specifically authorize it in this section."
- **Status:** [x]

### H16: Disclaimer missing witness qualification details
- **File:** `lib/ui/disclaimer/disclaimer_screen.dart`
- **Fix:** Expand Section 4 to state who cannot be a witness: the agent, the agent's spouse, healthcare providers currently treating you
- **Status:** [x]

### H17: Disclaimer missing digital signature warning
- **File:** `lib/ui/disclaimer/disclaimer_screen.dart`
- **Fix:** Add note to Section 4: the app creates digital touch-drawn signatures for convenience, but the printed directive must be signed with original ink signatures in the presence of witnesses
- **Status:** [x]

### H18: No offline detection for AI features
- **Files:** `lib/ui/wizard/widgets/ai_suggest_button.dart`, `lib/ui/assistant/assistant_screen.dart`
- **Fix:** Catch `SocketException` / network errors specifically and show user-friendly "No internet connection" message instead of raw error
- **Status:** [x] (handled via friendly error messages in gemini_api_assistant.dart)

### H19: Hardcoded widths in Review Step
- **File:** `lib/ui/wizard/steps/review_step.dart`
- **Fix:** Replace `SizedBox(width: 140)` with `Flexible` or `Expanded` + `ConstrainedBox` pattern
- **Status:** [x]

---

## MEDIUM (20-31)

### M20: Conversation history unbounded in memory
- **Status:** [x]

### M21: Hardcoded phone number repeated 6 times
- **Status:** [x]

### M22: No test coverage for services
- **Status:** [x] (DisclaimerService tests added — 7 tests)

### M23: Only 2 widget tests
- **Status:** [x] (PII stripper tests expanded with named person + unlabeled DOB tests)

### M24: FAQ missing common questions
- **Status:** [x] (3 new FAQ entries: out-of-state, provider non-compliance, capacity disagreement)

### M25: AI Suggest prompt doesn't reference Act 194
- **Status:** [x] (done in C2 fix)

### M26: Missing supplementary §5811
- **Status:** [x] (Declaration of Incapacity section added)

### M27: No confirmation when exiting wizard mid-form
- **Status:** [x]

### M28: No confirmation when clearing AI chat
- **Status:** [x]

### M29: Form fields lack input formatting
- **Status:** [x] (phone fields now filter to digits/phone chars + hint text)

### M30: Hardcoded colors for status chips/badges
- **Status:** [x] (directive_card + education_screen use theme colors)

### M31: No data export/backup feature
- **Status:** [x] (DataExportService + share_plus + menu item in private mode)

---

## LOW (32-38)

### L32: Checklist missing items
- **File:** `lib/data/educational_content.dart`
- **Fix:** Add checklist items: "Document Agent Discussions", "Update Emergency Contacts Annually"
- **Status:** [x]

### L33: Supplementary sections lack policy rationale
- **File:** `lib/data/educational_content.dart`
- **Fix:** Add brief "why this matters" explanations to agent limits and other key supplementary sections
- **Status:** [x]

### L34: No success screen after wizard completion
- **Files:** New `lib/ui/wizard/wizard_complete_screen.dart`, update router
- **Fix:** Show completion screen with next-steps guidance: "Print your directive", "Sign with witnesses", "Distribute copies"
- **Status:** [x]

### L35: No form auto-population from prior directive
- **File:** `lib/ui/wizard/steps/personal_info_step.dart`
- **Fix:** When creating a new directive, offer to copy personal info from most recent existing directive
- **Status:** [x]

### L36: Generic error messages shown to users
- **Files:** `lib/ui/wizard/widgets/ai_suggest_button.dart`, `lib/ui/assistant/assistant_screen.dart`
- **Fix:** Map technical exceptions to friendly messages: SocketException → "No internet", TimeoutException → "Request timed out", rate limit → "Too many requests"
- **Status:** [x] (handled via friendly error messages in gemini_api_assistant.dart)

### L37: API key not cleared from controller memory on dispose
- **File:** `lib/ui/settings/ai_setup_screen.dart`
- **Fix:** Add `_keyCtrl.clear()` before `_keyCtrl.dispose()` in dispose method
- **Status:** [x]

### L38: Missing rate limit handling for Gemini free tier
- **File:** `lib/ai/gemini_api_assistant.dart`
- **Fix:** Catch rate limit errors (HTTP 429) and show user-friendly message with retry suggestion
- **Status:** [x] (handled via H10 rate limit catch in gemini_api_assistant.dart)
