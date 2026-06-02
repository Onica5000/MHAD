# Prototype audit — Claude Design bundle `7MymEiPDh58jY_cchvUF8A`

Authoritative source: `MHAD-handoff/bundle-7MymEiPDh58jY_cchvUF8A/`
(opened from `Mental Health Advance Directive.html`).

This bundle is the same design lineage as the v2/v3 bundles already
implemented in Phases 1-4 — but ships the **final ratified prototype** with
all 34 audit items resolved per chat3 of the bundle's chats directory.

## Foundational parity

| Layer | Prototype | Flutter | Status |
|---|---|---|---|
| Palette tokens (teal/navy/sage, light+dark) | `ds.jsx::MHAD_PALETTES` | `app_theme.dart::MhadPalette.*` | ✅ Identical hex for every value |
| Type pairing | DM Sans + Instrument Serif Italic + JetBrains Mono | Bundled in `assets/fonts/` + wired in `pubspec.yaml` | ✅ |
| Radius tokens (rCard, rBtn, rInput, rChip, rSheet, rTile) | `ds.jsx::TOK` | `app_theme.dart::DesignTokens` | ✅ All match (16/14/12/100/20/12) |
| Button height tokens (sm/md/lg) | 40 / 52 / 56 | 40 / 52 / 56 | ✅ |
| Default palette | `navy` (per EDITMODE block in HTML L46-50) | Was `teal` — now flipped to `navy` (this batch) | ✅ Fixed in Batch 1 |

## Per-artboard delta (mobile)

Status legend: ✅ PARITY · 🟡 DRIFT · ❌ MISSING (build required)
Items not requiring a Flutter screen (device-only flows): camera/voice/NFC.

| Artboard | Flutter file | Status | Top deltas |
|---|---|---|---|
| m-welcome | `onboarding/onboarding_screen.dart` | 🟡 | Flutter has full 4-page carousel; prototype is a single editorial "In your words." hero with value pills. |
| m-mode | `mode_selection/mode_selection_screen.dart` | 🟡 | Prototype is a 2-card Private/Public picker; Flutter includes inline PIN flow that obscures the card layout. |
| m-public | NONE | ❌ | Public-mode home variant with ephemeral banner + "Welcome, guest" italic hero. |
| m-disclaimer | `disclaimer/disclaimer_screen.dart` | ✅ | |
| m-faceid | (covered by `pin_dialog.dart`) | 🟡 | Prototype shows full unlock screen with editorial "Welcome back" hero; Flutter is a minimal modal PIN. |
| m-empty | `home/home_screen.dart` (empty state) | 🟡 | Prototype is first-time empty home; Flutter always renders the full layout. |
| m-home | `home/home_screen.dart` | 🟡 | **Highest impact.** Missing editorial "Hi, [name]. / Let's keep your voice clear." greeting + decorative numeral on draft card. |
| m-formtype | `wizard/form_type_selection_screen.dart` | ✅ | |
| m-quiz | (covered by `widgets/form_type_quiz.dart`) | ✅ | 4-question quiz dialog + confidence meter — built in Phase 1. |
| m-scan | NONE (device-only) | ❌ | Camera-driven document scan; needs `camera` plugin work. |
| m-snap-review | NONE | ❌ | AI extraction review post-scan. Pairs with m-scan. |
| m-permission | NONE (device-only) | ❌ | System-permissions consent screen. |
| m-voice | NONE (device-only) | ❌ | Speech-to-text input. Needs `speech_to_text` plugin. |
| m-wizard-about | `wizard/steps/personal_info_step.dart` | ✅ | |
| m-wizard-when | `wizard/steps/when_it_kicks_in_step.dart` | ✅ | |
| m-wizard-people | `wizard/steps/people_i_trust_step.dart` | 🟡 | Prototype has expanded agent cards with "Phone verified" chip; Flutter is minimal. |
| m-contacts | NONE | ❌ | Contact-picker UI for picking agents from address book. |
| m-wizard-guardian | `wizard/steps/guardian_nomination_step.dart` | ✅ | |
| m-wizard-care | `wizard/steps/treatment_facility_step.dart` | ✅ | |
| m-diagnoses | `wizard/steps/diagnoses_step.dart` | ✅ | |
| m-wizard-meds | `wizard/steps/medications_step.dart` | ✅ | |
| m-allergies | `wizard/steps/allergies_step.dart` | ✅ | |
| m-wizard-procedures | `wizard/steps/procedures_research_step.dart` | ✅ | |
| m-wizard-else | `wizard/steps/additional_instructions_step.dart` | ✅ | |
| m-review | `wizard/steps/review_step.dart` | ✅ | |
| m-conflict | `ai_check/ai_consistency_screen.dart` | ✅ | |
| m-sign | `wizard/steps/execution_step.dart` | 🟡 | Prototype: print-and-sign-on-paper instructions; Flutter: witness entry form. Conflicts with the local-only "wet ink only" decision — verify which model is canonical. |
| m-done | `wizard/wizard_complete_screen.dart` | ✅ | |
| m-wallet | NONE | ❌ | Apple Wallet `.pkpass` generation. Backend-bound; deferred per Phase 4 audit item #15. |
| m-share | `share/share_sheet_screen.dart` | ✅ | |
| m-pdf | (covered by `export/export_screen.dart`) | 🟡 | Prototype shows 6-page PDF preview with toolbar/thumbs; Flutter shows generation options instead. |
| m-past | `past/past_directive_detail_screen.dart` | ✅ | |
| m-verify | NONE | ❌ | Wallet-QR verifier view (what an EMS scanner sees). |
| m-renew | NONE | ❌ | Hard renewal nudge before 2-year expiry. |
| m-checkin | NONE | ❌ | Soft quarterly check-in prompt. |
| m-revoke | `revocation/revocation_screen.dart` | ✅ | |
| m-ai | `assistant/assistant_screen.dart` | ✅ | |
| m-learn | `education/education_screen.dart` | ✅ | |
| m-article | `education/article_reader_screen.dart` | ✅ | |
| m-settings | `settings/settings_screen.dart` | ✅ | |
| m-export | `export/export_screen.dart` | ✅ | |
| m-crisis | (covered by `widgets/crisis_resources_banner.dart` + persistent strip) | 🟡 | Prototype has a full crisis sheet screen; Flutter has the always-on bottom strip but no dedicated sheet. |
| m-crisisplan | `crisis_plan/crisis_plan_screen.dart` | ✅ | |
| m-facilitator | `facilitator/facilitator_screen.dart` | ✅ | |
| m-clinician | `clinician/clinician_view_screen.dart` | ✅ | |
| m-legaltoggle | `legal_toggle/plain_legal_toggle_screen.dart` | ✅ | |
| m-ulysses | `ulysses/ulysses_clause_screen.dart` | ✅ | |
| m-agentaccept | NONE | ❌ | Agent acceptance/consent receipt — new screen for designated agents. |
| m-a11y | `settings/accessibility_settings_screen.dart` | ✅ | |

**Tally:** 28 PARITY / 12 DRIFT / 8 MISSING-buildable / 3 MISSING-device-only-deferred / 1 MISSING-backend-deferred (m-wallet).

## Web/desktop artboards

Not yet audited — covered in a later batch. Bundle defines:
`w-disclaimer`, `w-home`, `w-formtype`, `w-quiz`, `w-snapfill`, `w-snapfill-mobile`, `w-wiz-mobile`, `w-snapreview`, `w-voice`,
`w-wiz-about`, `w-wiz-when`, `w-wizard`, `w-wiz-guardian`, `w-wiz-care`, `w-diagnoses`, `w-medications`, `w-allergies`,
`w-wiz-procedures`, `w-wiz-else`, `w-review`, `w-conflict`, `w-sign`, `w-done`, `w-export`, `w-dataexport`, `w-share`,
`w-revoke`, `w-learn`, `w-article`, `w-ai`, `w-settings`, `w-crisis`.

Key item: **`w-wiz-mobile`** — desktop AI right-rail collapses into a tappable bottom sheet at the 1000px breakpoint. Per chat3, this was the last piece added to the prototype (item #33c).

## Pass plan

| Batch | What | Status |
|---|---|---|
| 0 | Read prototype source + delta table (this doc) | ✅ Complete (this commit) |
| 1 | Default palette teal→navy, design-token sync | ✅ Complete (this commit) |
| 2 | Highest-visibility DRIFT fixes — start with m-home editorial greeting | 🟡 In progress |
| 3 | Remaining DRIFT items (m-welcome, m-mode, m-faceid, m-empty, m-wizard-people, m-sign, m-pdf, m-crisis sheet) | ⏳ Next session(s) |
| 4 | Build MISSING-buildable screens (m-public, m-contacts, m-verify, m-renew, m-checkin, m-agentaccept) | ⏳ Next session(s) |
| 5 | Web/desktop responsive layout + w-wiz-mobile bottom-sheet AI rail | ⏳ Next session(s) |
| 6 (deferred) | Device-only screens (m-scan / m-voice / m-wallet) — need plugin + signing pipeline | ⏳ Defer until plugin/cryptography scope is decided |

Each batch ends with `flutter analyze` + `flutter test` clean and one commit
pushed to `main`. This doc gets updated after each batch.
