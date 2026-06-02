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
| m-welcome | `onboarding/onboarding_screen.dart` | 🟢 | Page 1 of the carousel now carries the prototype's editorial hero hallmarks: "In your **words**." dual-color italic + 4 value pills ("Valid 2 years", "2 witnesses", "PA Act 194", "Stays on your device"). Pages 2-4 of the carousel (educational content) intentionally retained — would lose functionality to compress to a single screen. |
| m-mode | `mode_selection/mode_selection_screen.dart` | ✅ | (Initial audit flagged this as DRIFT; on re-read the screen IS the prototype layout — `_Card2` widgets, "Step 1 of 3 · setup" label, recommended badge, HIPAA footnote. The PIN flow the audit saw is post-pick auth, not the mode picker.) |
| m-public | `home/home_screen.dart` (Public-mode branch) | ✅ | Dark ephemeral status strip (`_EphemeralBar`) above home content; greeting swaps to "Welcome, guest. / Quick draft, no trace." (`_PublicGuestGreeting`) italic editorial. Existing `_PublicModeNotice` warning card retained for End-Session + 10-minute-recovery copy the prototype omits. |
| m-disclaimer | `disclaimer/disclaimer_screen.dart` | ✅ | |
| m-faceid | `mode_selection/pin_dialog.dart::PinEntryDialog` | ✅ | Rebuilt as a full-screen editorial unlock (matches prototype `ScrFaceID`): brand row top-left, centered "lock" glyph in a 124pt rounded tile with pulse-ring overlay, italic dual-color "Use your **passcode.**" heading, dynamic monospace status pill ("AUTHENTICATING…" / "ATTEMPT N / 5" / "LOCKED · WAIT 30S"), 18pt monospace passcode field with 6-letter spacing, "Unlock" CTA, "Switch to public mode" ghost dismiss. API unchanged (`PinEntryDialog.show(context)` still returns `Future<bool?>`). |
| m-empty | `home/home_screen.dart::_EmptyDirectives` | ✅ | Rebuilt to match prototype's editorial hero: 1.5px primary border + 200pt decorative italic numeral, "Your first directive" tinted label, "About 15 minutes. / That's all." italic h2, three monospace pill timeline rows, embedded "Start my directive" CTA. |
| m-home | `home/home_screen.dart` | 🟡 | **Highest impact.** Missing editorial "Hi, [name]. / Let's keep your voice clear." greeting + decorative numeral on draft card. |
| m-formtype | `wizard/form_type_selection_screen.dart` | ✅ | |
| m-quiz | (covered by `widgets/form_type_quiz.dart`) | ✅ | 4-question quiz dialog + confidence meter — built in Phase 1. |
| m-scan | NONE (device-only) | ❌ | Camera-driven document scan; needs `camera` plugin work. |
| m-snap-review | NONE | ❌ | AI extraction review post-scan. Pairs with m-scan. |
| m-permission | NONE (device-only) | ❌ | System-permissions consent screen. |
| m-voice | NONE (device-only) | ❌ | Speech-to-text input. Needs `speech_to_text` plugin. |
| m-wizard-about | `wizard/steps/personal_info_step.dart` | ✅ | |
| m-wizard-when | `wizard/steps/when_it_kicks_in_step.dart` | ✅ | |
| m-wizard-people | `wizard/steps/people_i_trust_step.dart` | 🟢 | Added the prototype's right-aligned "20 Pa.C.S. § 5836" monospace statute badge next to the "What can they decide?" section label, plus the dashed-border "Agent decides / No / If…" explainer card below the authority section. The compact agent-card layout (with "Phone verified" chip + Contact picker action chips) is intentionally NOT applied — it would replace the data-entry forms with a tap-to-expand pattern, which is a functional UX change beyond the scope of a visual sweep. |
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
| m-verify | `verify/wallet_verify_screen.dart` | ✅ | Dark-themed read-only verifier preview (what an EMS / ER scanner sees on QR scan). Status banner (green when active, red otherwise) with "ACT 194" pill · principal card with initials avatar + monospace DOB/city · "Call first" agent row with `tel:` launch · Treatment flags pulled from real data: severe allergies → "Avoid: X" crisis flags, `ectConsent`/`drugTrialConsent` mapped to crisis/warn tones, room-preference summary as ok flag. Reachable from directive card overflow menu as "Preview QR view". |
| m-renew | `reminders/reminder_sheets.dart::showRenewalNudge` | 🟢 | Modal bottom sheet built (warning palette, italic "Time to renew, [Name].", days-until-expiry pill, primaryTint "Quick renew · ~5 min" card, "Start quick renew" CTA wired to existing `onRenew` callback). Accessible via the directive card overflow menu. **Auto-trigger policy** (28 days before `expirationDate`) deferred — needs notification scheduling. |
| m-checkin | `reminders/reminder_sheets.dart::showQuarterlyCheckIn` | 🟢 | Modal bottom sheet built (primary palette, italic "Anything changed?", form-type-aware "Common things that change" 3-row list, "Still accurate — all good" + "Edit my directive" CTAs). Accessible via the directive card overflow menu. **Auto-trigger policy** (90 days since `updatedAt`) deferred — needs SharedPreferences "last-shown" tracking + notification scheduling. |
| m-revoke | `revocation/revocation_screen.dart` | ✅ | |
| m-ai | `assistant/assistant_screen.dart` | ✅ | |
| m-learn | `education/education_screen.dart` | ✅ | |
| m-article | `education/article_reader_screen.dart` | ✅ | |
| m-settings | `settings/settings_screen.dart` | ✅ | |
| m-export | `export/export_screen.dart` | ✅ | |
| m-crisis | `widgets/design/crisis_sheet.dart` + `crisis_top_bar.dart` | ✅ | (Initial audit flagged 🟡; on re-read the prototype's `ScrCrisis` bottom-sheet IS implemented as `showCrisisSheet()` — DraggableScrollableSheet with drag handle, "24/7 FREE, CONFIDENTIAL" pill, "You are not alone." editorial heading, 4 prototype crisis rows + 988-accent + 1 extra Veterans line, plus an educational "Why these numbers?" footer the prototype doesn't have. Wired from the persistent strip tap, home tile, and disclaimer. Coverage exceeds prototype.) |
| m-crisisplan | `crisis_plan/crisis_plan_screen.dart` | ✅ | |
| m-facilitator | `facilitator/facilitator_screen.dart` | ✅ | |
| m-clinician | `clinician/clinician_view_screen.dart` | ✅ | |
| m-legaltoggle | `legal_toggle/plain_legal_toggle_screen.dart` | ✅ | |
| m-ulysses | `ulysses/ulysses_clause_screen.dart` | ✅ | |
| m-agentaccept | NONE | ⏸ | Agent acceptance/consent receipt. The screen presupposes an online agent-acceptance flow (agent receives a link, reviews the directive, taps acknowledgments, signs digitally) which does NOT exist in the current architecture — directives are signed in ink with witnesses, not digitally by agents. Building only the post-acceptance receipt would imply functionality that isn't there. Deferred pending design conversation on whether to add an agent-acceptance flow or repurpose the screen as a manual "log that my agent accepted in person" record. |
| m-a11y | `settings/accessibility_settings_screen.dart` | ✅ | |

**Tally:** 34 PARITY / 6 DRIFT (2 partial 🟢) / 3 MISSING-buildable (2 🟢 partial — sheets built, auto-trigger deferred) / 3 MISSING-device-only-deferred / 1 MISSING-backend-deferred (m-wallet) / 1 MISSING-architecture-deferred (m-agentaccept).
(Batch 5 part 1: m-faceid ✅ editorial unlock screen; `w-wizard` desktop step rail at ≥1000px landed.)

## Web/desktop artboards

Not yet audited — covered in a later batch. Bundle defines:
`w-disclaimer`, `w-home`, `w-formtype`, `w-quiz`, `w-snapfill`, `w-snapfill-mobile`, `w-wiz-mobile`, `w-snapreview`, `w-voice`,
`w-wiz-about`, `w-wiz-when`, `w-wizard`, `w-wiz-guardian`, `w-wiz-care`, `w-diagnoses`, `w-medications`, `w-allergies`,
`w-wiz-procedures`, `w-wiz-else`, `w-review`, `w-conflict`, `w-sign`, `w-done`, `w-export`, `w-dataexport`, `w-share`,
`w-revoke`, `w-learn`, `w-article`, `w-ai`, `w-settings`, `w-crisis`.

Key items:
- **`w-wizard`** — desktop wizard with a left step rail at ≥1000px. Built in Batch 5: `wizard_screen.dart` now wraps its body in a `LayoutBuilder`; at width ≥1000 it shows `_WideStepRail` (240px column listing all 11 steps with done/current/pending dots + "STEP N / TOTAL" editorial header) alongside the existing form column (max width 760px). Read-only in this pass — rail items don't accept clicks because jumping mid-wizard would skip per-step validation; navigation stays on the Continue/Back bar.
- **`w-wiz-mobile`** — desktop AI right-rail collapses into a tappable bottom sheet at the 1000px breakpoint. Per chat3, this was the last piece added to the prototype (item #33c). The wizard already exposes "Ask the AI" via its overflow menu; surfacing it as a persistent "Need help?" bar/sheet is deferred — touches existing AI route plumbing.

## Pass plan

| Batch | What | Status |
|---|---|---|
| 0 | Read prototype source + delta table (this doc) | ✅ Complete (this commit) |
| 1 | Default palette teal→navy, design-token sync | ✅ Complete (this commit) |
| 2 | Highest-visibility DRIFT fixes — start with m-home editorial greeting | 🟡 In progress |
| 3 | Remaining DRIFT items (m-welcome, m-mode, m-faceid, m-empty, m-wizard-people, m-sign, m-pdf, m-crisis sheet) | 🟢 6 of 8 done: m-empty ✅ · m-welcome 🟢 · m-mode ✅ · m-crisis ✅ · m-wizard-people 🟢. Still pending: m-faceid (needs route/state work — see Batch 5), m-sign (functional conflict with wet-ink design — needs user input), m-pdf (lower-visibility export thumbs). |
| 4 | Build MISSING-buildable screens (m-public, m-contacts, m-verify, m-renew, m-checkin, m-agentaccept) | 🟢 m-public ✅ · m-renew 🟢 · m-checkin 🟢 · m-verify ✅. m-agentaccept ⏸ deferred (no upstream agent-acceptance flow exists). m-contacts deferred to Batch 6 (needs `flutter_contacts` plugin + permission). |
| 5 | Web/desktop responsive layout + w-wiz-mobile bottom-sheet AI rail | 🟢 m-faceid ✅ + `w-wizard` desktop step rail landed (Batch 5 part 1). Still pending: `w-wiz-mobile` AI bottom sheet, m-pdf preview thumbs, full per-screen web layouts (dashboard / share / learn). |
| 6 (deferred) | Device-only screens (m-scan / m-voice / m-wallet) — need plugin + signing pipeline | ⏳ Defer until plugin/cryptography scope is decided |

Each batch ends with `flutter analyze` + `flutter test` clean and one commit
pushed to `main`. This doc gets updated after each batch.
