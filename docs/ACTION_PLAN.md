# PA Mental Health Advance Directive App -- Action Plan

## Document Summary

The source PDF (PA MHAD.pdf, 47 meaningful pages) is a Pennsylvania Mental Health Advance Directive booklet (PA Act 194 of 2004) containing:

- **Educational content** (pp. 1-23): Introduction, FAQ, instructions for each form type, glossary of terms
- **Three fillable legal forms** (pp. 24-45):
  1. **Combined Declaration + Power of Attorney** (pp. 25-32, most comprehensive)
  2. **Declaration Only** (pp. 33-38)
  3. **Power of Attorney Only** (pp. 39-45)

Each form collects: personal info, agent/alternate agent designation, treatment facility preferences, medication preferences (with exceptions/limitations/preferences tables), ECT consent, experimental study consent, drug trial consent, additional instructions (health history, dietary, religious, children custody, pet custody, family notification, records disclosure), guardian nomination, and execution (signatures, witnesses, dates). The directive is valid for 2 years under PA Act 194.

---

## Key Architecture Decisions

- **Cross-platform** via Flutter/Dart targeting Android and iOS
  - Android builds on Windows locally
  - iOS builds via Codemagic CI (macOS runner) — no Mac required for development
- **External AI API** (Claude) with an abstraction layer (`AiAssistant` interface) to swap in on-device inference later
- **Pixel-perfect PDF reproduction** with only dynamic expansion of text areas where user content exceeds the original allotted space
- **All three form types** from day one
- **User-controlled print scope**: choose any combination of forms to include in the final PDF output, regardless of how much data was entered

---

## Phase 1: Project Setup & Tooling ✅ COMPLETE

1. **Flutter 3.41.4 / Dart 3.11.1** installed at `D:\flutter`
2. **Directory structure**:
   ```
   lib/
     data/
       database/     -- Drift tables + generated code
       repository/   -- DirectiveRepository
     domain/
       model/        -- directive.dart (enums, FormType.steps extension)
     ai/             -- AiAssistant interface + ClaudeApiAssistant
     ui/
       theme/        -- Material3 teal theme
       home/         -- HomeScreen
       wizard/       -- Step-by-step form flow
       education/    -- FAQ, instructions, glossary
       assistant/    -- AI chat UI
       export/       -- PDF preview & print options
       router.dart   -- GoRouter config
     main.dart
   android/          -- Flutter Android project
   ios/              -- Flutter iOS project (full Xcode project, builds via Codemagic)
   ```
3. **Dependencies** (all resolved):
   - `drift` + `drift_flutter` — type-safe SQLite with code generation
   - `flutter_riverpod` + `riverpod_annotation` — state management
   - `go_router` — navigation
   - `http` — Claude API calls
   - `pdf` + `printing` — PDF generation and sharing
   - `signature` — signature capture pad
   - `flutter_secure_storage` — encrypted API key storage
   - `intl` — date formatting
4. **`CLAUDE.md`** established with project conventions

---

## Phase 2: Data Modeling ✅ COMPLETE

1. **Unified data model** -- a single `Directive` row captures all possible fields across all three form types. Each form type uses a subset:

   | Field Group | Combined | Declaration | POA |
   |---|---|---|---|
   | Personal Info | Y | Y | Y |
   | Effective Condition | Y | Y | Y |
   | Treatment Facility Prefs | Y | Y | Y |
   | Medication Prefs | Y | Y | Y |
   | ECT Preference | Y | Y | Y |
   | Experimental Studies | Y | Y | Y |
   | Drug Trials | Y | Y | Y |
   | Additional Instructions | Y | Y | Y |
   | Agent Designation | Y | N | Y |
   | Alternate Agent | Y | N | Y |
   | Agent Authority/Limits | Y | N | Y |
   | Guardian Nomination | Y | Y | Y |
   | Execution/Witnesses | Y | Y | Y |

2. **Key model distinctions**:
   - Combined form's medication section has an extra option: "I have designated an agent under the Power of Attorney portion to make decisions related to medication" (same for ECT, experimental studies, drug trials). This option doesn't exist in Declaration-only.
   - POA form's medication section is structured slightly differently: consent is tied to agent agreement rather than direct physician recommendation.
   - The legal boilerplate text differs between all three forms (must be exact per form).

3. **Drift schema** (`lib/data/database/app_database.dart`):
   - `Directives` table (id, formType, status, personal info fields, effectiveCondition)
   - `Agents` table (primary + alternate agent info)
   - `MedicationEntries` table (exception / limitation / preferred rows)
   - `DirectivePrefs` table (consent options for medications, ECT, experimental, drug trials)
   - `AdditionalInstructionsTable` (10 free-text sub-sections)
   - `Witnesses` table (2 witnesses with signature fields)
   - `GuardianNominations` table
   - After any schema change: run `flutter pub run build_runner build --delete-conflicting-outputs`

4. **`DirectiveRepository`** (`lib/data/repository/directive_repository.dart`): full CRUD for all tables

5. **`FormType.steps`** extension returns the correct ordered list of `WizardStep` values per form type, automatically omitting agent sections for Declaration-only

---

## Phase 3: UI -- Form Wizard

1. **Home screen** (`lib/ui/home/home_screen.dart` — scaffold done):
   - "New Directive" FAB → form type selection
   - List of saved/in-progress directives with status chips (wire up via Riverpod `StreamProvider`)
   - "Learn More" card → educational content
   - Search bar (searches educational content + glossary + saved directives)

2. **Form type selection screen** (`lib/ui/wizard/form_type_selection_screen.dart`):
   - Three cards explaining Combined, Declaration, POA with key differences highlighted
   - "Help me choose" button opens AI assistant in selection-context mode

3. **Wizard scaffold** (`lib/ui/wizard/wizard_screen.dart`):
   - Drives from `FormType.steps` list — no hardcoded step counts
   - Step progress indicator at top
   - Each step is a separate widget in `lib/ui/wizard/steps/`
   - Bottom bar: Back / Save & Exit / Next
   - Floating AI assistant button (bottom-right)
   - Auto-saves on every field change via Riverpod + repository

4. **Wizard step widgets** (one file per step in `lib/ui/wizard/steps/`):
   - `personal_info_step.dart`
   - `effective_condition_step.dart`
   - `treatment_facility_step.dart`
   - `medications_step.dart` — dynamic add/remove rows for each of the 3 medication tables
   - `ect_step.dart`
   - `experimental_studies_step.dart`
   - `drug_trials_step.dart`
   - `additional_instructions_step.dart` — expandable sub-sections
   - `agent_designation_step.dart` (Combined + POA only)
   - `alternate_agent_step.dart` (Combined + POA only)
   - `agent_authority_step.dart` (Combined + POA only)
   - `guardian_nomination_step.dart`
   - `review_step.dart` — read-only summary of all entries with edit links
   - `execution_step.dart` — date picker, `Signature` widget for principal + 2 witnesses

5. **Each step includes**:
   - Contextual "Help" bottom sheet showing relevant instruction text from the PDF
   - Validation with `Form` + `GlobalKey<FormState>` — required fields highlighted, age ≥ 18 enforced
   - Save & exit preserves draft state

---

## Phase 4: Educational Content ✅ COMPLETE

1. **Structured content** hardcoded in `lib/data/educational_content.dart` (no DB needed — content never changes):
   - `EducationSection` model: `{ id, title, formTypes, pageRef, content }`
   - Introduction
   - FAQ (each Q&A as a separate entry)
   - Combined instructions (each sub-section)
   - Declaration instructions (each sub-section)
   - POA instructions (each sub-section)
   - Glossary (each term/definition pair)

2. **Search**: Dart `String.contains` / simple scoring across all content entries — no FTS needed at this scale

3. **Contextual linking**: each `WizardStep` maps to a list of `EducationSection` IDs — the "Help" button in the wizard filters to those sections automatically

---

## Phase 5: AI Assistant ✅ COMPLETE

1. **Architecture** (in `lib/ai/`):
   ```
   AiAssistant (abstract class)
   ├── ClaudeApiAssistant  (current — uses http package, claude-opus-4-6)
   └── LocalModelAssistant (future swap-in)
   ```
   - API key stored in `flutter_secure_storage`, never in source
   - System prompt embeds full PA MHAD educational content + glossary
   - Conversation history maintained in Riverpod `StateNotifierProvider` per session

2. **Context injection**: when the user opens the assistant from a wizard step:
   - Which form type they're filling out
   - Which section they're on
   - What they've entered so far (passed via `AssistantContext`)

3. **Use cases**:
   - "What medications should I list?" — AI asks about history/side effects
   - "What does ECT mean?" — explains using glossary + FAQ
   - "Should I pick Combined or Declaration?" — walks through differences
   - "What should I write for crisis intervention?" — prompts with questions

4. **Guardrails**:
   - Persistent "Not legal advice" banner in `AssistantScreen`
   - AI instructed never to fabricate medication names or legal citations
   - Suggests PA Protection & Advocacy (1-800-692-7443) for legal questions

5. **UI** (`lib/ui/assistant/assistant_screen.dart`):
   - Chat bubble list with user/assistant roles
   - Text input + send button
   - Context chip showing which form section opened the chat
   - Dismiss returns to the wizard step that launched it

---

## Phase 6: PDF Generation (Pixel-Perfect) ✅ COMPLETE

This is the most technically demanding phase. The `pdf` package (pub.dev) uses a coordinate-based drawing API — no HTML conversion.

1. **Template approach**:
   - Measure and map every element of the original PDF: fonts, sizes, margins, line positions, checkbox positions, teal header bars
   - `lib/ui/export/pdf/` contains one layout file per form type:
     - `combined_pdf.dart`
     - `declaration_pdf.dart`
     - `poa_pdf.dart`
   - Shared drawing primitives in `pdf_helpers.dart` (teal header bar, text field box, checkbox, signature line)

2. **Single cross-platform renderer**:
   - The `pdf` package runs identically on Android and iOS — no `expect/actual`, no platform split
   - `PdfGenerator` class in `lib/ui/export/pdf/pdf_generator.dart` takes a `DirectiveData` bundle and returns `Uint8List`
   - `printing` package handles share/print on both platforms

3. **Dynamic text area expansion**:
   - Use `pdf` package's `TextStyle` + `measureText` to calculate rendered height
   - If content exceeds the original allotted box height, expand the box and shift all subsequent elements down
   - Page breaks inserted automatically when content approaches the bottom margin

4. **User-controlled print scope** (`lib/ui/export/export_screen.dart`):
   - Checkboxes to include/exclude:
     - [ ] Combined Declaration & Power of Attorney
     - [ ] Declaration Only
     - [ ] Power of Attorney Only
   - The app maps the user's single data set into whichever form(s) they select
   - Selected forms are concatenated into one PDF in original document order
   - Warning shown if a selected form requires data not yet entered (e.g., POA selected but no agent designated)

5. **Wallet card** (pp. 1-2 of original): optionally prepended, pre-filled with name, agent name, agent phone

---

## Phase 7: Testing & Quality

1. **PDF fidelity**: screenshot generated PDF alongside original, visually compare layout alignment
2. **Widget tests** (`test/`): each wizard step widget tested with mock repository
3. **Unit tests**: `DirectiveRepository`, `FormType.steps`, `PdfGenerator` output structure
4. **AI integration tests**: mock `AiAssistant`, verify context injection and history threading
5. **Riverpod provider tests**: verify state transitions through the wizard flow
6. **Accessibility**: `flutter_semantics` audit, dynamic text sizes, color contrast (Material3 baseline)

---

## Phase 8: Polish & Release Prep

1. **Encryption at rest**: `drift` database encrypted with `sqlcipher_flutter_libs` (swap `sqlite3_flutter_libs`)
2. **2-year expiration reminder**: `flutter_local_notifications` scheduled when `expirationDate` is set
3. **First-launch legal disclaimer** screen with "I understand" acknowledgment stored in `SharedPreferences`
4. **Resource links**: PA Protection & Advocacy, PMHCA, Mental Health Association in PA (from p. 4 of PDF)
5. **App icon**: teal/white design using `flutter_launcher_icons` package
6. **Codemagic CI setup**: YAML workflow for iOS build + App Store distribution
7. **Obfuscation**: `flutter build apk --obfuscate --split-debug-info` for release

---

## Suggested Build Order

| Order | Phase | Rationale |
|---|---|---|
| 1 | Phase 1 (Project Setup) | ✅ Done |
| 2 | Phase 2 (Data Models) | ✅ Done |
| 3 | Phase 3 (Form Wizard UI) | Core user interaction |
| 4 | Phase 6 (PDF Generation) | Highest risk / most complex — start early |
| 5 | Phase 4 (Educational Content) | Low risk, adds immediate value |
| 6 | Phase 5 (AI Assistant) | Enhancement layer, can overlap with Phase 4 |
| 7 | Phase 7 (Testing) | Ongoing; formal pass after Phase 6 |
| 8 | Phase 8 (Polish) | Final prep before release |
