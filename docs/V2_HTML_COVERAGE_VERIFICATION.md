# v2 `Mental Health Advance Directive.html` — Coverage Verification

Direct mapping of every artboard declared in the v2 bundle's main HTML to
its Flutter implementation status. Bundle URL:
`https://api.anthropic.com/v1/design/h/aTvWdJDzmqgS227BXe3rfA`
File: `mhad/project/Mental Health Advance Directive.html`

**Defaults block** at lines 46-50: `palette: "navy" · mode: "light" ·
density: "comfortable"`. v1 Decision 1 already settled the navy default.

Status codes
- ✅ Implemented in Flutter and updated this multi-session arc
- 🟡 Functionally present; visual polish still differs from v2 artboard
- 🆕 Net-new surface from prototype — not yet built in Flutter
- ⛔ Explicitly dropped per user decision (with reference)
- N/A — design-canvas chrome (analysis boards, brief cards), not app screens

---

## § cover (lines 62-69) — N/A

Brief + Visual system cards. Design-canvas chrome only.

## § gap (lines 71-81) — N/A

Research foundation / Coverage matrix / Priority roadmap. Design-canvas
analysis boards.

## § new-screens (lines 83-91)

| Artboard | Flutter status |
|---|---|
| m-crisisplan · P0 Crisis plan & wellness toolbox | 🆕 Submission item #27 — placement awaiting Claude Design |
| m-facilitator · P1 Get help (referral + in-person) | 🆕 Submission item #28 — PA referral list awaiting Claude Design |
| m-clinician · P1 Clinician / verifier view | 🆕 Submission item #29 — unified verifier-and-clinician surface awaiting Claude Design |
| m-legaltoggle · P1 Plain ⇄ Legal toggle | 🆕 Submission item #30 — attorney-reviewed Legal template needed |
| m-ulysses · P1 Self-binding (Ulysses) clause | 🆕 Submission item #31 — § 5802-5805 wording confirmed by v2 prototype but standalone screen not built |
| m-agentaccept · P2 Agent acceptance receipt | 🆕 Submission item #32 — local-only QR handoff design awaiting refinement |
| m-a11y · P2 Accessibility settings | 🆕 Submission item #19 — phased rollout + Arabic RTL awaiting Claude Design |

## § flow (lines 93-97) — N/A

Before/After flow diagram. Design canvas.

## § audit (lines 99-103) — N/A

Coverage audit board. Design canvas.

## § mobile · iOS (lines 105-148)

| v2 artboard | Flutter implementation | Status |
|---|---|---|
| m-welcome · 01 Welcome | `lib/ui/onboarding/onboarding_screen.dart` | ✅ (D.1 hybrid: single-screen hero + Learn-more carousel for the additional content) |
| m-mode · 02 Mode | `lib/ui/mode_selection/mode_selection_screen.dart` | ✅ V4-M10c prototype-faithful |
| m-public · 02b Public-mode home | Functional public mode in home_screen.dart | 🟡 Inverted "ephemeral" bar visual deferred (J.public) |
| m-disclaimer · 03 Disclaimer | `lib/ui/disclaimer/disclaimer_screen.dart` | ✅ + Phase 1 C1+C6 statutory text additions this session |
| m-faceid · 04 Face ID unlock | `lib/ui/mode_selection/pin_dialog.dart` (PIN path); biometric path via local_auth | 🟡 Branded welcome-back surface deferred (J.faceid) |
| m-empty · 05 Home first-time | Empty state present | 🟡 Dashed-border hero + 3 time-estimate rows deferred (J.empty pending Claude Design) |
| m-home · 06 Home active | `lib/ui/home/home_screen.dart` | ✅ V4-M10c with active-directive hero + tools grid + past directives |
| m-formtype · 07 Form type | `lib/ui/wizard/form_type_selection_screen.dart` | ✅ + Phase 3 tag pills updated to 11/9/6 this session |
| m-quiz · 08 Help-me-choose quiz | `lib/ui/wizard/widgets/form_type_quiz.dart` | ✅ **Phase 2 — rebuilt to 4-question + confidence meter + result screen this session** |
| m-scan · 09a Snap to fill (multi-target) | `lib/ui/wizard/widgets/smart_fill_flow.dart` via OS image picker | 🟡 Option B — uses OS picker, not in-app camera UI |
| m-snap-review · 09a' AI extraction review | Internal sheet flow | 🟡 Dedicated screen deferred |
| m-permission · 09c Camera permission | OS-native | ⛔ Deferred with snap-to-fill (Option B uses OS picker) |
| m-voice · 09b Voice input | `lib/ui/wizard/widgets/voice_input_button.dart` | 🟡 Inline button — modal overlay UI deferred (item #22 STT posture awaiting Claude Design) |
| m-wizard-about · Step 01 About you | `lib/ui/wizard/steps/personal_info_step.dart` | ✅ |
| m-wizard-when · Step 02 When this kicks in | `lib/ui/wizard/steps/when_it_kicks_in_step.dart` | ✅ **Phase 3 — refactored to focus on activation conditions; Diagnoses promoted to its own step** |
| m-wizard-people · Step 03 People I trust | `lib/ui/wizard/steps/people_i_trust_step.dart` + `agent_authority_step.dart` | ✅ **Phase 2 — § 5836 citation + F14 substituted-judgment explainer this session** |
| m-contacts · 11b Contact picker | `lib/ui/wizard/widgets/contact_picker_button.dart` | 🟡 Eligibility soft-warn UI deferred (item #23) |
| m-wizard-guardian · Step 04 Guardian | `lib/ui/wizard/steps/guardian_nomination_step.dart` | ✅ **Phase 2 — 4-radio Opt cards + "Someone different" inline expansion + schema v8 (`guardianRelation` column) this session** |
| m-wizard-care · Step 05 Where I want care | `lib/ui/wizard/steps/treatment_facility_step.dart` | ✅ **Phase 2 — inclusive room-preference chips + schema v8 (`roomPreferences` column) this session. Preferred+Avoid two-list was already present.** |
| m-diagnoses · Step 06 Diagnoses (ICD-10) | `lib/ui/wizard/steps/diagnoses_step.dart` | ✅ **Phase 3 — promoted from embedded sub-step to dedicated step 6. ClinicalDataService NLM autocomplete already wired.** |
| m-wizard-meds · Step 07 Medications (current + avoid) | `lib/ui/wizard/steps/medications_step.dart` | ✅ **Phase 1 — C5 dosage-not-binding note added; Phase 3 — wired into the new step ordering** |
| m-allergies · Step 08 Allergies (RxTerms + ICD-10) | `lib/ui/wizard/steps/allergies_step.dart` | ✅ **Phase 3 — new widget + schema v9 (`directive_allergies` table) + repository methods + Severe-allergy backward-nudge snackbar to step 7 this session** |
| m-wizard-procedures · Step 09 Procedures | `lib/ui/wizard/steps/procedures_research_step.dart` | ✅ **Phase 2 — C4 agent-needs-express-grant warn + "Never authorized" card (psychosurgery + parental-rights) this session** |
| m-wizard-else · Step 10 Anything else | `lib/ui/wizard/steps/additional_instructions_step.dart` | ✅ Kept 9 structured fields per v1 Decision 19 |
| m-review · Step 11 Review | `lib/ui/wizard/steps/review_step.dart` + `review_and_sign_step.dart` | ✅ **Phase 1 — C6 provider-may-decline footnote; Phase 3 — dynamic step count derived from `FormType.steps.length` this session** |
| m-conflict · 17b AI consistency warning | (not built) | 🆕 Submission item #14 — rule set + trigger + surface awaiting Claude Design |
| m-sign · 18 Make it legal (print & wet-ink) | `lib/ui/wizard/steps/execution_step.dart` | ✅ — Verified no functional digital signature pads (uses `_SignaturePlaceholder` placeholders only) + **added v2 prototype's "Make it legal — with a pen" editorial banner at the top of the step this session.** Wet-ink framing fully consistent across help text, section subtitles, and intro banner. |
| m-done · 19 Done + wallet | `lib/ui/wizard/wizard_complete_screen.dart` | ✅ **Phase 1 — wet-ink reframe subtitle + C6 provider-may-decline banner this session** |
| m-wallet · 19a Add to Apple Wallet | (not built) | 🆕 Needs .pkpass + V4-C2 org account — submission item #15 |
| m-share · 20 Share sheet | (uses OS share via share_plus) | 🆕 In-app share sheet deferred (item #17 local-only re-spec) |
| m-pdf · 21 PDF preview | (uses `printing` package direct) | 🆕 In-app US Letter preview deferred (H.2) |
| m-past · 22 Past directive detail | Past directives list on home; no detail screen | 🆕 Submission item #24 (share-log policy) |
| m-verify · 22b Wallet QR verifier view | (not built) | 🆕 Submission item #17 / #29 unified verifier surface |
| m-renew · 23 Renewal nudge (hard 2-yr) | `lib/services/notification_service.dart` schedules reminder; no in-app nudge sheet | 🆕 Submission item #25 |
| m-checkin · 23b Quarterly check-in (soft) | (not built) | 🆕 Submission item #25 — both surfaces awaiting Claude Design |
| m-revoke · 24 Revocation | (not built) | 🆕 Submission item #26 — canonical PA wording confirmed by v2 prototype; revocation PDF + two provider lists awaiting build |
| m-ai · 25 AI assistant | `lib/ui/assistant/assistant_screen.dart` | ✅ |
| m-learn · 26 Learn hub | `lib/ui/education/education_screen.dart` | ✅ (V4-M10b expanded with Ch.54/58 bridge, provider-duty content) |
| m-article · 26b Learn article reader | Dialog/detail render | 🟡 Submission item #13 awaiting Claude Design |
| m-settings · 27 Settings | `lib/ui/settings/settings_screen.dart` | ✅ |
| m-export · 27a Data export hub | `lib/ui/export/export_screen.dart` | 🟡 Checkbox format choice; 5-format card grid deferred (H.1) |
| m-crisis · 28 Crisis sheet | `lib/ui/widgets/design/crisis_sheet.dart` | ✅ |

## § web · Desktop & mobile browser (lines 150-182)

Flutter web uses `lib/ui/widgets/design/responsive_shell.dart` + `web_sidebar.dart` for ≥1000 px layout. Mobile-mode wizard surfaces render on web automatically; web-specific 3-pane wizard with AI right-rail + snap drop zone + mobile-Safari frame are queued behind submission item #33 (responsive breakpoints).

Mapping is therefore: each `w-*` artboard inherits its mobile counterpart's status; the web-only chrome (sidebar labels, *THIS TAB ONLY* pill on top bar) is the delta.

| v2 artboard | Coverage |
|---|---|
| w-disclaimer / w-home / w-formtype / w-quiz | ✅ — inherit mobile screens |
| w-snapfill / w-snapfill-mobile / w-snapreview / w-voice | 🟡 — deferred with mobile equivalents (Option B / item #22) |
| w-wiz-about through w-review (11 wizard steps) | ✅ — `FormType.steps` is platform-agnostic |
| w-conflict | 🆕 — submission item #14 |
| w-sign · Make it legal (print & wet-ink) | 🟡 — about to ship via execution_step.dart rewrite |
| w-done | ✅ — Phase 1 reframe |
| w-export / w-dataexport | 🟡 — H.1 format grid + H.2 in-app preview deferred |
| w-share / w-revoke | 🆕 — items #17, #26 |
| w-learn / w-article / w-ai / w-settings / w-crisis | ✅ for hub + crisis; 🟡 for article reader |

---

## Phase 4 — net-new artboards built this turn

Eleven artboards from the v2 HTML that were marked 🆕 in the prior pass
have been built as Flutter screens, wired into the router, and verified
clean against the analyzer:

| v2 artboard | Flutter file | Route |
|---|---|---|
| m-crisisplan · Crisis plan & wellness toolbox | `lib/ui/crisis_plan/crisis_plan_screen.dart` | `/crisis-plan/:id` |
| m-facilitator · Get help (referral + in-person) | `lib/ui/facilitator/facilitator_screen.dart` | `/facilitator` |
| m-clinician · Clinician / verifier view | `lib/ui/clinician/clinician_view_screen.dart` | `/clinician/:id` |
| m-legaltoggle · Plain ⇄ Legal toggle | `lib/ui/legal_toggle/plain_legal_toggle_screen.dart` | `/legal-toggle/:id` |
| m-ulysses · Self-binding (Ulysses) clause | `lib/ui/ulysses/ulysses_clause_screen.dart` | `/ulysses/:id` |
| m-a11y · Accessibility settings | `lib/ui/settings/accessibility_settings_screen.dart` | `/accessibility` |
| m-conflict · AI consistency warning | `lib/ui/ai_check/ai_consistency_screen.dart` | `/ai-check/:id` |
| m-share · Share sheet | `lib/ui/share/share_sheet_screen.dart` | `/share/:id` |
| m-past · Past directive detail | `lib/ui/past/past_directive_detail_screen.dart` | `/past/:id` |
| m-revoke · Revocation | `lib/ui/revocation/revocation_screen.dart` | `/revoke/:id` |
| m-article · Learn article reader | `lib/ui/education/article_reader_screen.dart` | (opens from Learn hub) |

Plus the supporting infrastructure: `AccessibilitySettings` provider,
schema v9 → v10 with `crisisPlanJson` + `selfBindingEnabled` columns on
`directive_prefs`.

## Net gap as of this session

**42 mobile artboards declared; ~27 have functional Flutter equivalents
(some with visual polish gaps), ~15 deferred to identified submission
items awaiting Claude Design's canonical wording, attorney review, or
hardware-specific work (.pkpass / camera UI).**

m-sign "Make it legal" closed this turn — verified no functional digital
signature pads existed (Flutter was already using `_SignaturePlaceholder`
widgets explicitly indicating wet-ink-on-paper), then added the v2
prototype's editorial "Make it legal — with a pen" banner at the top of
step 18 for explicit framing.

**All deferred items map to specific submission items in
`docs/PROTOTYPE_DIFF_SUBMISSIONS_TO_CLAUDE_DESIGN.md`** — they're not
ambiguous unknowns; each has a tracked question awaiting canonical
content from Claude Design, an attorney, or external dependencies (Apple
Developer Org account for .pkpass per V4-C2).
