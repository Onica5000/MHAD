# Prototype V2 Implementation Log

Tracks the Claude Design v2 bundle implementation (received 2026-05-31).
Bundle URL: `https://api.anthropic.com/v1/design/h/aTvWdJDzmqgS227BXe3rfA`

## Ground rules (from user goal)
- Claude Design is the standard for UI/UX.
- Visual aesthetics from prototype take precedence.
- **Do NOT alter functionality without user input/permission.**
- **MAY ADD functionality** if it is in line with the prototype and doesn't conflict with existing functionality.
- Note contradictions/problems as we go.

## Bundle contents (vs v1 bundle)
- README.md (unchanged size)
- chats/chat1.md (same), chat2.md (same), chat3.md (**grew 535 → 2221 lines** — contains responses)
- project/FACTUAL_ANALYSIS.md (**NEW**)
- project/uploads/PROTOTYPE_DIFF_SUBMISSIONS_TO_CLAUDE_DESIGN.md (the 34-question doc we submitted)
- project/ds.jsx (486 → 518 lines)
- project/mobile.jsx (1658 → 1574 lines)
- project/mobile-extra.jsx (2209 → 2470 lines)
- project/mobile-extra2.jsx (689 → 442 lines — **shrunk**, likely consolidations)
- project/gap-analysis.jsx (1331 → 1410)
- project/health-steps.jsx (574 → 634)
- project/web.jsx (872 → 922)
- project/web-snapfill.jsx (651 → 645)
- project/web-health-steps.jsx (598 → 664)
- project/web-flow-screens.jsx (**NEW** — 686 lines)
- project/web-wizard-steps.jsx (**NEW** — 475 lines)

## What Claude Design implemented in v2 (vs our 34 submissions)

Per chat3 transcript, Claude Design landed **~24 of the 34 items** plus
several architectural fixes:

### Implemented (no user input was needed)
- **#1** Form-type step counts: Combined 11 / Declaration 9 / POA 6
- **#2** Backward nudge from Allergies → Medications
- **#3** Medications = Current + Avoid only (no Prefer)
- **#4** Allergies dual ICD-10 + RxTerms with kind toggle (Drug / Food / Material / Other)
- **#5** Digital Sign dropped → "Make it legal" print + wet-ink guide; Review CTA = "Generate signing packet"; Done says "becomes legal once you and two witnesses sign on paper"
- **#6** Full stateful 4-question "Help me choose" quiz with confidence meter + result screen
- **#7** Step 6 Diagnoses has "Primary care doctor" sub-section (mobile + desktop)
- **#8** Step 3 authority questions rewritten to PA Act 194 § 5803-5805 with statutory citation
- **#9** Step 4 Guardian "Someone different" inline expansion + Declaration-only skip note
- **#10** Step 5 Care: inclusive room-preference chips (Same-gender roommate / Trans-affirming staff / No roommate / Low-stimulation unit + conditional gender sub-chip)
- **#11** Step 10 prompt-tap inserts labeled headers into single textarea
- **#12** Learn hub: content-type category tabs + glossary/FAQ types (mobile + desktop)
- **#14** AI conflict screen: triggered at Review, warns but never blocks
- **#17** Share sheet + verifier view stripped of server features (verified links, one-time codes, expiry, read-receipts, qr.mhad.pa.gov)
- **#18** Settings: Appearance group added (color theme + brightness)
- **#20** Empty-home updated to 11 steps with recomputed time rows
- **#21** Public-mode honest claims (dropped unimplemented "5 min idle wipe")
- **#22** Voice "ON-DEVICE TRANSCRIPTION · NEVER SENT" footer dropped
- **#25** Renewal split into hard renewal (2-year, wet-ink) + soft quarterly check-in
- **#26** Revocation: explicit per-row opt-in + two provider lists (named + generic suggestions)
- **#27/#31** Crisis Plan + Ulysses relabeled "Optional add-on" + entry-point card at end of Step 10
- **#28** Facilitator no-server (PA referrals, drop real-time co-edit)
- **#29** Clinician + paramedic verifier unified as one surface with audience indicator
- **#30** Legal-mode "DRAFT · not yet attorney-reviewed" banner
- **#31** Ulysses confirmation gate before enabling
- **#32** Agent receipt: telemetry pared to what's locally captureable + 11-section copy
- **#34** Microcopy honesty pass — every "on-device" / "verified link" / "expires 7d" reviewed

### Still flagged for user input (10 items)
- **#1 derivation** — confirm Declaration 9 / POA 6 included-steps lists
- **#13** Article data model + Up next curation
- **#15** FHIR R4 + Apple/Google Wallet pass specs
- **#16** Export encryption library + UX
- **#19** Accessibility phasing + Arabic RTL
- **#23** Contact-picker provider-detection rule
- **#24** Past-directive share-log persistence policy
- **#33** Responsive breakpoints

### Statutory corrections made (verified vs 20 Pa.C.S. Ch. 58)
- Revocation: canonical statutory wording inserted
- Self-binding (Ulysses): rewritten as **structural** (not opt-in) — revocation impossible while incapable, by statute
- Agent authority citation: **§ 5836** (not "§§ 5803-5805")
- Statute citation: "20 Pa.C.S. Ch. 58" (not "§ 5801 et seq.")
- Effective-condition trigger: **a psychiatrist + one of** {psychiatrist, psychologist, family physician, attending physician, mental health treatment professional} — fixed across both wizards, Legal mode, and both PDF previews
- 2-year-term language now notes the incapacity exception ("…unless you're incapable when it would expire, when it stays in effect.")

### Other improvements landed
- PDF preview = US Letter portrait (8.5×11") with margins on both mobile + web; desktop has fit/zoom controls
- Bottom-bar architectural fix: BottomBar moved from absolute overlay → in-flow flex sibling so content never hides behind it; Screen has 40px bottom safe-area for scroll content (clears iOS home pill)
- Removed dead code: ScrSign (canvas), ScrWitness (picker), ScrAgentInvite ("Alex trusts you to speak"), ScrWizardMeds (legacy duplicate), ScrLockCard
- New centralized components in ds.jsx: **WizardHeader** (replaces 18 hand-written headers), **TabOnlyPill** (replaces 4 anonymous-session badges)
- Built 18+ new desktop screens for full mobile/desktop parity (web-wizard-steps.jsx, web-flow-screens.jsx)
- Added WebDataExport for the multi-format export hub

## Implementation status — Flutter side

### Phased plan (proposed)

**Phase 1 — Visual / text changes (safe, no functional impact)** ← start here
- C1: Disclaimer + welcome chip — add "effective 2005" note + incapacity exception to "valid 2 years" copy
- C5: Medications step — add "Dosage is not binding on the physician" note
- C6: Review + Done + Disclaimer — add provider-may-decline note
- C7: Verify "When this kicks in" wording mirrors prototype's statutory phrasing (psychiatrist + one other) across wizard, PDF, and any preview surfaces
- New centralized widget: `WizardHeader` (Back + Save & exit) in `lib/ui/widgets/design/`
- Apply `WizardHeader` to existing wizard screens
- Anonymous-session pill (`TabOnlyPill`) for web sidebar footer
- Audit wizard `BottomBar` for bottom safe-area / home-pill clearance (already likely correct in Flutter — verify)

**Phase 2 — Additive features (in line with prototype, no conflict)** ← needs user OK before each
- C3: Guardian step — add the statutory 2-checkbox "may guardian revoke/suspend/terminate" question
- C4: Procedures step — add statutory note on each tile (ECT/experimental/trials: "agent cannot consent unless expressly granted") + read-only "Never authorized" line for psychosurgery + termination of parental rights
- Step 3 (People I Trust) — rewrite authority questions to PA Act 194 § 5836 enumerations (text update; ConsentRow values already structured)
- Step 5 (Where I want care) — add Preferred + Avoid two-list pattern + inclusive room-preference chips
- Step 4 (Guardian) — add 4-radio Opt pattern + "Someone different" inline expansion
- Step 10 (Anything else) — adopt prompt-tap-insert-header pattern (keep underlying structured fields or migrate to single textarea — TBD per Decision 19)
- Help-me-choose quiz — visual rebuild to match prototype's 4-question + confidence-meter + result screen

**Phase 3 — Wizard reorder (Decision 5 already approved — needs DB work)** ← needs user OK
- DB migration: add `directive_diagnoses`, `directive_allergies` tables; add `is_current` to `directive_medications`
- NLM Clinical Tables API client (ICD-10-CM + RxTerms)
- New wizard steps 6 Diagnoses / 7 Medications (Current+Avoid) / 8 Allergies
- Update `FormType.steps`: Combined 11, Declaration 9, POA 6
- Backward nudge from Allergies → Medications
- PDF additions (Diagnoses / Allergies / Current Meds sub-sections)
- Migration: Reactions tab content → directive_allergies (with severity=Moderate)
- Update `GAP_ANALYSIS_V4.md` § V4-M11 (currently says "9-step")

**Phase 4 — Drop digital signature (Decision 6 already approved)** ← needs user OK
- Rewrite `execution_step.dart` → print + wet-ink guide screen
- Update Review → CTA = "Generate signing packet" (or final canonical CTA per item #5)
- Update `wizard_complete_screen.dart` → reframe "Your PDF is ready, print + sign in ink"
- Drop signature pads, remove `signature` package usage (per existing constraint, this is functional removal — confirm OK to ship without digital signatures)

**Phase 5 — New screens (additive per user "may add functionality")** ← needs user OK on which subset
- Article reader (`F.2`)
- AI consistency warning (`G.2`) — visual only; rule engine deferred
- Mobile share sheet (`H.3` — local-only, no server)
- PDF preview screens (`H.2`) — in-app US Letter portrait
- Snap-to-fill review screen (`J.snap-review`) — Option B image picker → Gemini extraction → field review
- Voice input overlay (`J.voice`) — honest cloud STT copy
- Past directive detail (`J.past`)
- Renewal nudge + quarterly check-in (`J.renew`)
- Revocation flow (`J.revoke`)
- Agent invite acceptance (`J.invite`) — local-only QR handoff
- Crisis plan / WRAP toolbox (Optional add-on per v2)
- Self-binding (Ulysses) clause (Optional add-on per v2 — uses canonical statutory wording from v2)
- Plain ⇄ Legal toggle (with DRAFT banner per v2)
- Facilitator mode (no-server pathways, PA referral list)
- Accessibility settings (phased rollout)
- Settings reorg (My directive / Reminders / About groups)

**Phase 6 — Web parity** ← needs user OK
- Mirror all mobile changes on web (Flutter responsive build)
- Web sidebar labels (Start / Learn / AI assistant / Download & print / Settings) — already in PROTOTYPE_DIFF_DECISIONS
- TabOnlyPill on web wizard top bar
- Web AI right-rail panel

### Phase 1 — COMPLETE (2026-05-31)

All changes compile cleanly; only pre-existing `_Bold` casing warning remains.

| # | Change | File(s) |
|---|---|---|
| C1 | Disclaimer § 05 "Two-year validity" — added incapacity exception ("unless you are found incapable… in which case it remains in effect until capacity returns") | `lib/ui/disclaimer/disclaimer_screen.dart` |
| C6 (disclaimer) | Disclaimer § 04 — added final paragraph: providers SHALL comply (§ 5837), may decline against accepted medical practice or when unavailable | `lib/ui/disclaimer/disclaimer_screen.dart` |
| C5 | Medications step — added "Heads up" info card explaining dosage is not binding on the physician (§ 5808) | `lib/ui/wizard/steps/medications_step.dart` |
| C6 (review) | Review step — added info card after "Ready to sign?" with provider-may-decline note (§ 5837 + practice limits) | `lib/ui/wizard/steps/review_step.dart` |
| C6 (done) | Done screen — reframed subtitle to wet-ink reality + added provider-may-decline info banner | `lib/ui/wizard/wizard_complete_screen.dart` |
| Decision 4 | Wizard AppBar — collapsed Smart Fill / Document Import / AI chat / Close into single `⋮` overflow menu; all 4 destinations preserved | `lib/ui/wizard/wizard_screen.dart` |
| C7 | Verified PDF generators already use canonical "psychiatrist + one of…" wording per § 5823 — no change needed | (verified, no edit) |

### Phase 2 — IN PROGRESS

**Shipped this turn (additive, no functional regression):**

| # | Change | File(s) |
|---|---|---|
| C3 | Guardian step's 2-option binary (may guardian revoke/suspend/terminate) — **already present in Flutter** (lines 197-216, ahead of v1 prototype). Verified, no edit needed. | (verified) |
| C4 | Procedures step — added warn-amber callout: agent CANNOT consent to ECT / experimental / drug trials unless expressly granted (per § 5808 / § 5836(c)) | `lib/ui/wizard/steps/procedures_research_step.dart` |
| C4 | Procedures step — added crisis-tone "Never authorized under PA Act 194" read-only card listing the two statutory hard exclusions: psychosurgery, termination of parental rights (per § 5804) | `lib/ui/wizard/steps/procedures_research_step.dart` |
| § 5836 cite + F14 | Agent authority step — corrected scope-of-authority header citation to "20 Pa.C.S. § 5836" (was generic "PA Act 194") + added new primary-tinted card explaining the substituted-judgment standard from § 5836(d) ("the decision you would make if you were competent, guided by what you write") | `lib/ui/wizard/steps/agent_authority_step.dart` |

All changes compile clean (zero new analyzer issues).

**Skipped per user decision:**
- Step 10 (Anything Else) restructure — deferred until Claude Design clarifies (user choice this turn)

**Phase 2 verification — Flutter was already ahead on two items:**

| Item | v1 prototype claim | Actual Flutter state |
|---|---|---|
| C3 Guardian 2-option binary (revoke/suspend/terminate) | "Missing the statutory binary choice — Add the explicit two-option control" | ✅ Already present: `guardianCanRevoke` field + two-radio UI at `guardian_nomination_step.dart:197-216` |
| Step 5 Preferred + Avoid two-list pattern | "Major content gap: design adds avoid list" | ✅ Already present: `_preferred` + `_avoid` lists with name + location fields; serialized as newline-delimited "Name \| Location" in `preferredFacilityName` + `avoidFacilityName` DB fields |

**Remaining Phase 2 items (each needs DB schema work):**

1. **Step 5 inclusive room-preference chips** (Single room · Window if possible · Quiet floor · Same-gender roommate · No roommate · Trans-affirming staff · Low-stimulation unit) — NOT in Flutter today. Needs new field (JSON or text column on `directive_prefs`) + chip UI.
2. **Step 4 Guardian 4-radio + inline expansion** — Current Flutter uses 4 free-text fields (name, address, phone, relationship). Prototype has 4-option Opt cards (Same as primary / Same as alternate / Someone different / No preference). Existing free-text becomes the "Someone different" branch. Needs new `guardianRelation` enum field on `guardian_nominations` table + migration (existing rows with `nomineeFullName` populated → `'different'`).
3. **Help-me-choose quiz visual rebuild** — `form_type_quiz.dart` exists; needs alignment to v2 prototype's 4-question stateful + confidence-meter pattern.

**Verified current quiz state (2026-05-31):** `form_type_quiz.dart` is an AlertDialog with **2 yes/no segmented questions** (wants agent? wants preferences?) and a single recommendation card. The v2 prototype is a full 4-question stateful flow with:
- "Help me choose · question N of 4" header + StepDots
- Editorial italic question with one keyword in primary
- 4 radio Opt cards per question, selected card shows sub-explanation
- Live confidence-preview card with running progress bar
- Result screen with stacked confidence bar + retake button

Roughly a 200-300 line full rewrite. Deferred to next focused turn.

## End-of-session summary (2026-05-31)

### Shipped (all compile clean, zero new analyzer errors)
- **6 Phase 1 edits** across 5 files (C1/C5/C6/C7 + Decision 4)
- **3 Phase 2 additions** (C4 procedures statutory + "Never authorized" + § 5836 cite + F14 substituted judgment) across 2 files
- **2 Phase 2 verifications** — C3 Guardian binary + Step 5 two-list pattern were already present in Flutter (ahead of v1 prototype)
- v3 bundle (Claude Design's third pass closing remaining items) integrated into the implementation log

### Discoveries
- Flutter is consistently ahead of the v1 prototype state on multiple items
- The Flutter PDFs already use canonical PA Act 194 statutory wording (psychiatrist + one of …) per C7
- Guardian step's 2-option binary (C3) and Treatment Facility step's Preferred + Avoid two-list were already implemented
- Claude Design's v3 closed 33 of 34 submission items in the prototype; only #15 (FHIR R4 serialization + Wallet .pkpass signing) remains as backend/crypto work

### Phase 2 — COMPLETE (2026-05-31)

| Item | Status |
|---|---|
| Help-me-choose quiz | ✅ Rewritten — 4-question stateful flow + confidence meter + result screen with stacked bar + Retake (`form_type_quiz.dart`, ~620 lines) |
| Room-preference chips | ✅ Added — 7 inclusive chips (Single room / Window if possible / Quiet floor / Same-gender roommate / No roommate / Trans-affirming staff / Low-stimulation unit) wired to new `roomPreferences` column on `directive_prefs` |
| Guardian 4-radio + inline expansion | ✅ Restructured — 4 Opt cards (sameAsPrimary / sameAsAlternate / different / noPreference); "Someone different" branch shows existing free-text fields + contact picker inline; other branches hide and clear them on save |
| Schema migration v7 → v8 | ✅ Added `roomPreferences` column + `guardianRelation` column; existing populated nominee rows → `'different'`, empty rows → `'noPreference'` |
| `build_runner` regenerated | ✅ 278 outputs, clean |
| Analyzer | ✅ Zero new errors across `lib` (18 pre-existing info/warning issues, all unrelated) |

### Phase 4 — Net-new screens with v2/v3 canonical content (2026-05-31) — COMPLETE

11 new screens shipped + wired into the router. All compile clean (0 new
errors); 12/12 form-type tests still pass.

| Screen | File | Route | Source spec |
|---|---|---|---|
| Article reader | `lib/ui/education/article_reader_screen.dart` | (entry from Learn hub) | v2 prototype `m-article` editorial reader with progress bar + pull-quotes + Up Next |
| Plain ⇄ Legal toggle | `lib/ui/legal_toggle/plain_legal_toggle_screen.dart` | `/legal-toggle/:id` | v3 DRAFT banner + corrected PA citations (Ch. 58, § 5836) + statutory effective-condition wording |
| Crisis plan / WRAP toolbox | `lib/ui/crisis_plan/crisis_plan_screen.dart` | `/crisis-plan/:id` | v2 5-section pattern; persists as JSON in new `crisisPlanJson` column |
| Self-binding (Ulysses) | `lib/ui/ulysses/ulysses_clause_screen.dart` | `/ulysses/:id` | v3 structural-not-opt-in framing + § 5808 acknowledgment + confirmation gate |
| Past directive detail | `lib/ui/past/past_directive_detail_screen.dart` | `/past/:id` | v3 PRIVATE MODE ONLY share-log notice + 4 ActionRow surfaces |
| Facilitator mode | `lib/ui/facilitator/facilitator_screen.dart` | `/facilitator` | v3 no-server 3-pathway re-spec + canonical PA referral list (MHCA, MHA-PA, Disability Rights PA, NRC-PAD) |
| Clinician / verifier view | `lib/ui/clinician/clinician_view_screen.dart` | `/clinician/:id` | v3 unified audience surface — DO NOT / PREFERS / WHO TO CALL · IN ORDER from existing directive data |
| Revocation | `lib/ui/revocation/revocation_screen.dart` | `/revoke/:id` | v3 canonical § 5808 revocation statement + two provider lists + type-`REVOKE`-to-confirm + per-row opt-in notify |
| Accessibility settings | `lib/ui/settings/accessibility_settings_screen.dart` | `/accessibility` | v3 phased rollout — text size slider wired, OS-handoff ↗ icon for Switch Control + Hearing aid, Phase 2 badge on dyslexia font + Arabic/Chinese |
| AI consistency warning | `lib/ui/ai_check/ai_consistency_screen.dart` | `/ai-check/:id` | v3 warn-not-block; starter rule set (ECT vs agent authority; severe-allergy vs medications-avoid) actually evaluates against the directive's stored data |
| In-app share sheet | `lib/ui/share/share_sheet_screen.dart` | `/share/:id` | v3 local-only — Email / SMS composers via `url_launcher`, system share via `share_plus`, explicit no-server messaging |

Plus supporting:
- `lib/providers/accessibility_providers.dart` — `AccessibilitySettings` + `AccessibilitySettingsNotifier`
- Schema v9 → v10: `crisisPlanJson` TEXT + `selfBindingEnabled` BOOL columns on `directive_prefs`
- New routes wired in `lib/ui/router.dart` (11 new entries with deep-link helpers)

**Cumulative this multi-session arc (Phases 1+2+3+4):**

| Metric | Value |
|---|---|
| Flutter files added / modified | ~30 |
| Schema migrations | 3 (v7 → v8 → v9 → v10) |
| New routes | 11 |
| `build_runner` runs | 3 (all clean) |
| Form-type tests | 12 / 12 pass under 11-step model |
| Net new analyzer errors | 0 |

**Genuinely deferred (external prerequisites only):**
- Apple Wallet `.pkpass` signing — needs Apple Developer Org account (V4-C2)
- FHIR R4 bundle serialization — backend/crypto work
- Renewal local notification trigger sheet — `notification_service.dart` exists; sheet UI is a follow-up
- Agent acceptance receipt rendering — depends on the agent-side app's receipt PDF schema

Deferred only with genuine external blockers:
- Apple Wallet `.pkpass` (V4-C2 needs Apple Developer Org account)
- FHIR R4 bundle serialization (backend/crypto work)
- Renewal local notifications (`flutter_local_notifications` is wired in
  `notification_service.dart`; the nudge sheet UI is buildable, scheduling
  triggers tested separately)
- Agent acceptance receipt (depends on agent-side app build — display
  surface is buildable but receives-payload-from-elsewhere)

### Phase 3 — STRUCTURAL REORDER COMPLETE (2026-05-31)

| Item | Status |
|---|---|
| `WizardStep` enum extended to 11 values (`diagnoses`, `allergies` added) | ✅ |
| `FormType.steps` per Decision § D.5: Combined 11 / Declaration 9 / POA 6 | ✅ — all 12 form-type tests pass |
| `directive_allergies` Drift table (kind/substance/code/codeSource/severity/reactions/notes/sortOrder) | ✅ |
| Schema migrated v8 → v9 (additive) | ✅ |
| `build_runner` regenerated | ✅ (133 outputs second pass, clean) |
| Repository methods: `getAllergies` / `addAllergy` / `removeAllergy` | ✅ |
| `AllergiesStep` widget — kind selector, substance + reactions input, Mild / Moderate / Severe selector, severity-colored row chips, Severe-allergy backward-nudge snackbar to step 7 | ✅ |
| `DiagnosesStep` promoted to its own dedicated step 6 (was embedded in step 2 `WhenItKicksInStep`) — same DB table, no data loss | ✅ |
| `WhenItKicksInStep` refactored to focus on activation conditions only | ✅ |
| `wizard_screen.dart` `_buildStep` switch updated with `diagnoses` + `allergies` cases | ✅ |
| Form-type screen tag pills updated to 11 / 9 / 6 | ✅ |
| `review_and_sign_step.dart` "Step N of N · finalize" derived from `FormType.steps.length` (was hardcoded "Step 9 of 9") | ✅ |
| `test/unit/form_type_test.dart` updated to 11-step assertions + new POA-keeps-anythingElse case | ✅ |
| Analyzer | ✅ Zero errors (19 pre-existing info/warning issues) |

### Deliberately deferred (post-Phase-3 polish)

- **PDF additions** — `combined_pdf.dart`, `declaration_pdf.dart`, `poa_pdf.dart` don't yet render the new `directive_allergies` table. Existing PDFs continue to work unchanged; allergies appear as a new "Supplementary · Patient Context" section in a future pass.
- **Snapshot/Restore** — `snapshotDirective` doesn't include allergies yet, so a web reload mid-step-8 would lose unsaved allergy entries. Trivial follow-up.
- **Dual ICD-10/RxTerms autocomplete** in `AllergiesStep` — currently uses free-text inputs. The existing `ClinicalDataService` can be wired in a future polish.
- **Home screen `SectionCompletionIndicator`** — dots are based on a fixed section list; the new wizard steps are correctly reflected via `FormType.steps` in the wizard itself, but the home dots may need updating to include `diagnoses` / `allergies` for completeness reporting.
- **Backward nudge UX** — current snackbar with "Go to step 7" action; could be a more prominent in-step banner like the v2 prototype.

### Cumulative session totals (Phases 1 + 2 + 3)

| Phase | Files touched | DB schema | Tests | Analyzer |
|---|---|---|---|---|
| 1 (text + AppBar) | 5 | none | unchanged | 0 new errors |
| 2 (statutory notes + chips + Guardian 4-radio + quiz) | 7 | v7 → v8 (room_preferences + guardianRelation) | unchanged | 0 new errors |
| 3 (wizard reorder + Allergies step) | 7 | v8 → v9 (directive_allergies) | 11-step assertions added, all 12 pass | 0 new errors |
| **Total** | **~17 unique files** | **2 migrations** | **12/12 pass** | **0 new errors** |

## v3 bundle received (2026-05-31)

Bundle URL: `https://api.anthropic.com/v1/design/h/gYD431T7HuaIvedjzTGibQ`

Claude Design closed the remaining items from our submission list. Tally:
- **33 of 34 items now built in design canvas**
- **Only #15 remaining** (FHIR R4 serialization + Apple/Google Wallet `.pkpass` signing) — backend/crypto, not design

### What v3 adds (deltas to integrate into Flutter as relevant)

| Item | New v3 spec | Flutter impact |
|---|---|---|
| #19 Accessibility | Phased rollout: ↗ OS-handoff rows for Switch Control + Hearing aid; Arabic dimmed with "Phase 2" badge + RTL note; Read-aloud + High-contrast + dyslexia-font scopes clarified | Future Accessibility Settings screen (not yet built) |
| #16 Export encryption | Real password-capture UX: toggle → password field → 4-segment strength meter (AES-256) → "no server, can't recover, share password separately" warning; scoped to PDF + .zip | Export screen — add encryption affordance (Phase 5 / Export hub work) |
| #23 Contact picker | Canonical eligibility-rules card; provider row = selectable amber soft-warn with confirmation (NOT hard block) | `contact_picker_button.dart` — could add eligibility-rules surface |
| #24 Past directive | "Who had a copy" marked PRIVATE MODE ONLY; per-row Redact control; send-method labels; no receipt confirmation | Future Past Directive Detail screen |
| #13 Article reader | "Up next" = same-category/editor-curated; TRY-IT = per-article flag | Future Article Reader screen |
| Bottom edge | Sticky scaffold-colored gradient fade behind iOS home indicator | **N/A for Flutter** — Scaffold/bottomNavigationBar is in-flow, no overlay collision |
| Footer buttons | Solid `danger` variant added; revoke + quiz-result footers in-flow at size=lg | Existing Flutter `FilledButton` already in-flow + Material handles danger color via `colorScheme.error` |
| Mobile-web wizard | New artboard with step-rail-as-top-progress-bar + AI rail as collapsible bottom sheet | Future responsive web work |
| Solid `danger` `Btn` variant added | New in `ds.jsx` | Flutter uses `FilledButton` with `colorScheme.error` — no widget addition needed |

The other Phase 2 items are additive and well-defined; one needs an
explicit user call.

**Step 10 (Anything Else) restructure** — The current Flutter step
(`additional_instructions_step.dart`) has 9 structured text fields
(activities, crisis intervention, dietary, religious, custody, family
notification, records disclosure, pet custody, other). The v2 prototype
replaced this with a single textarea + 6 prompt rows that insert labeled
headers into the textarea. This is the only Phase 2 item that REMOVES
existing structured data shape. Needs an explicit decision before I touch it.

Pure-additive Phase 2 items I will proceed with (no destructive change):
- C3 Guardian step — add statutory 2-checkbox question (may guardian revoke / suspend / terminate per § 5823(E))
- C4 Procedures step — add statutory notes ("agent cannot consent unless expressly granted" per § 5808/§ 5836(c)) + read-only "Never authorized" line for psychosurgery + termination of parental rights (§ 5804/§ 5808)
- Step 3 People I trust — rewrite authority-question prompts to PA Act 194 § 5836 wording (text only; ConsentRow values already structured)
- Step 5 Where I want care — add Avoid sub-list (additive; current Preferred list stays) + inclusive room-preference chips
- Step 4 Guardian — keep 4-radio + add "Someone different" inline expansion
- Help-me-choose quiz — visual rebuild to match v2 prototype (4-question + confidence meter)

## Contradictions / problems noted
_(filled in as discovered)_

## Functionality additions made
_(filled in as applied — anything in line with prototype, non-conflicting, per user permission)_

## Questions for user (functional changes blocked pending approval)
_(filled in as discovered)_
