# Prototype audit — current Claude Design bundle

Authoritative source: **`MHAD-handoff/bundle/`** (opened from
`Mental Health Advance Directive.html`).

This bundle is the final ratified Claude Design prototype. Per user
direction on 2026-06-02, all earlier handoff bundles (v2 / v3 / and the
prior `7Mym` delivery) have been removed from the repo — this is the
only design reference now in tree. The HTML and JSX prototype source
delivered in this refresh is byte-identical to the prior delivery; the
chat transcripts that previously accompanied the bundle were dropped.

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
| m-scan | `wizard/widgets/document_import_sheet.dart` + `document_pipeline_flow.dart` | ✅ | (Initial audit flagged ❌; on re-read the full document-scan flow IS implemented — `image_picker` for camera + gallery + multi-page capture, then `ai/document_extractor.dart` runs AI extraction. Implementation uses stock `ImagePicker` modals rather than the prototype's editorial in-app camera frame; functional coverage matches the prototype.) |
| m-snap-review | `wizard/widgets/document_pipeline_flow.dart` (~1100 lines) | ✅ | (Initial audit flagged ❌; on re-read this exists as the post-scan review pipeline screen — user reviews extracted fields before they are committed to the wizard. Functional coverage matches the prototype.) |
| m-permission | `permissions/permissions_overview_screen.dart` | ✅ | The OS-native permission dialog the prototype shows is shipped by iOS/Android, not customizable from Flutter. The buildable parity is an in-app Privacy & Permissions overview that mirrors the prototype's "What we use it for" 4-check transparency block per category. Lists Biometrics / Notifications / Camera / Microphone / Contacts with: plain-language usedFor, 4 promises, and an OS-managed status pill. Reachable from Settings → AI & Privacy → "Privacy & permissions". |
| m-voice | `wizard/widgets/voice_input_button.dart` | ✅ | (Initial audit flagged ❌; on re-read the `speech_to_text` plugin is wired, the `VoiceInputButton` initializes on demand, listens, appends transcribed text to a `TextEditingController`, and shows an error snackbar when speech recognition is unavailable. Wired into 5 wizard step fields — effective condition, agent authority limitations, alternate agent notes, guardian nomination, additional instructions. Implementation uses Flutter's stock IconButton rather than the prototype's animated waveform pulse; functional coverage matches the prototype.) |
| m-wizard-about | `wizard/steps/personal_info_step.dart` | ✅ | |
| m-wizard-when | `wizard/steps/when_it_kicks_in_step.dart` | ✅ | |
| m-wizard-people | `wizard/steps/people_i_trust_step.dart` | 🟢 | Added the prototype's right-aligned "20 Pa.C.S. § 5836" monospace statute badge next to the "What can they decide?" section label, plus the dashed-border "Agent decides / No / If…" explainer card below the authority section. The compact agent-card layout (with "Phone verified" chip + Contact picker action chips) is intentionally NOT applied — it would replace the data-entry forms with a tap-to-expand pattern, which is a functional UX change beyond the scope of a visual sweep. |
| m-contacts | `wizard/widgets/contact_picker_button.dart` | ✅ | (Initial audit flagged ❌; on re-read `flutter_contacts` plugin is wired with a `ContactPickerButton`. Requests `PermissionType.read`, opens the native contact picker, re-fetches with phone + address properties, and routes the picked data into the agent / witness / guardian fields. Phones are sorted by label (home / work / mobile) with sensible fallbacks. Warns the user via snackbar when a contact is missing name / address / phone. Wired into 5 wizard step fields. Implementation uses the OS-native picker rather than the prototype's editorial in-app bottom sheet with eligibility heuristics; functional coverage matches the prototype. |
| m-wizard-guardian | `wizard/steps/guardian_nomination_step.dart` | ✅ | |
| m-wizard-care | `wizard/steps/treatment_facility_step.dart` | ✅ | |
| m-diagnoses | `wizard/steps/diagnoses_step.dart` | ✅ | |
| m-wizard-meds | `wizard/steps/medications_step.dart` | ✅ | |
| m-allergies | `wizard/steps/allergies_step.dart` | ✅ | |
| m-wizard-procedures | `wizard/steps/procedures_research_step.dart` | ✅ | |
| m-wizard-else | `wizard/steps/additional_instructions_step.dart` | ✅ | |
| m-review | `wizard/steps/review_step.dart` | ✅ | |
| m-conflict | `ai_check/ai_consistency_screen.dart` | ✅ | |
| m-sign | `wizard/steps/execution_step.dart` | ✅ | Per user decision (2026-06-02): the prototype's print-and-sign-on-paper editorial is now canonical. Witness-name / address / phone form fields removed. Step now renders: italic "Make it legal — with a pen." headline + dual-color "pen." accent, "Why not sign in the app?" surface pill citing Act 194, 3-step numbered timeline with serif-italic numerals in primary circles + connector lines, warn-toned witness eligibility callout, "In your packet" file list (4 rows), large "Download signing packet (PDF)" CTA that jumps to Export. `validateAndSave` stamps `executionDate` to now via the new `DirectiveRepository.setExecutionDate(id, ms)` helper. The `Witnesses` table stays in the schema for backward compatibility with PDF generation paths. |
| m-done | `wizard/wizard_complete_screen.dart` | ✅ | |
| m-wallet | NONE | ⏸ | Apple/Google Wallet pass. Per user decision (2026-06-02): **deferred entirely.** Building this requires Apple Developer enrollment ($99/year for the Pass Type ID cert), Google Wallet API setup, and a `.pkpass` cryptographic signing pipeline — infrastructure decisions outside the scope of a visual parity sweep. Revisit when distribution / signing infrastructure is in place. |
| m-share | `share/share_sheet_screen.dart` | ✅ | |
| m-pdf | `export/export_screen.dart::_PdfPreviewScreen` | ✅ | (Initial audit flagged 🟡; on re-read, the existing `_PdfPreviewScreen` already uses `PdfPreview` from the `printing` package which renders the page thumbnails + preview pane the prototype shows. Allow-printing + allow-sharing actions are wired. Coverage matches prototype.) |
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
| m-agentaccept | `agent_accept/agent_accept_screen.dart` | ✅ | Per user decision (2026-06-02): repurposed as a manual in-person acceptance log. Schema v11 added `Agents.acceptedAt` (nullable INT) + `Agents.acceptanceNotes` (TEXT). Screen lists each agent with two states: unlogged → "Log acceptance" outline CTA opening a date+time+notes dialog; logged → editorial italic "[FirstName] is now your agent." headline + monospace "ACCEPTED" badge + timestamp + optional notes block + Edit affordance. Local only — no online flow. Reachable from directive card overflow menu as "Agent acceptance log". |
| m-a11y | `settings/accessibility_settings_screen.dart` | ✅ | |

**Final tally (2026-06-02):** 43 PARITY · 3 partial 🟢 · 1 deferred-by-choice (m-wallet · awaiting infrastructure decision).

That's **46 of 47 mobile artboards at functional parity**, with the one
remaining item deferred entirely per user direction. Visual fidelity
across the implemented set matches the prototype's editorial direction
(navy palette, Instrument Serif italic display, JetBrains Mono labels,
DM Sans body, prototype-faithful tokens for radii / button heights /
spacing).

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
| 6 | Plugin-bound screens | ✅ m-permission · m-pdf · m-scan · m-snap-review · m-voice · m-contacts ALL at functional parity (the last four were already wired in Phase 1-4 work — audit agent missed them, re-read confirmed). Still pending: **m-wallet** (Apple/Google Wallet pass requires Apple Developer cert + Google Pay API setup + PassKit cryptography — fundamentally blocked without certificate-management decision). |

Each batch ends with `flutter analyze` + `flutter test` clean and one commit
pushed to `main`. This doc gets updated after each batch.

---

## Session decisions log (2026-06-02)

Binding decisions made during the 2026-06-02 implementation pass
against the current bundle. Each is implemented and pushed unless noted.

| Decision | Choice | Where implemented |
|---|---|---|
| Default palette | `navy` (was `teal`) — per the bundle's EDITMODE-pinned default | `theme_controller.dart`, `app_theme.dart` |
| Palette picker | Removed from Settings; app is **navy only**. Returning users with persisted teal/sage are force-migrated on next launch | `settings_screen.dart`, `theme_controller.dart` |
| Service worker | Keep Flutter's self-unregistering stub + add belt-and-suspenders cleanup in `web/index.html` so future deploys land without incognito | `.github/workflows/deploy-web.yml`, `web/index.html` |
| Reminder auto-fire | **In-app on launch only.** No `flutter_local_notifications` scheduling. Renewal fires when ≤28d to expiration; check-in fires when ≥90d since `updatedAt`. Renewal takes priority; at most one modal per launch; per-directive cooldown gates re-show | `services/reminder_scheduler.dart`, `home_screen.dart` |
| m-agentaccept | **Manual in-person log**, not an online flow. Schema v11 added `Agents.acceptedAt` + `Agents.acceptanceNotes`. Principal records the verbal acceptance themselves | `agent_accept/agent_accept_screen.dart`, schema v11 migration |
| m-sign | **Prototype's print-and-sign editorial.** Witness name/phone/address form fields removed from the wizard. `executionDate` stamps on Continue. Underlying `Witnesses` table preserved for PDF backward compatibility | `wizard/steps/execution_step.dart` |
| m-wallet | **Deferred entirely.** Apple Developer cert + Google Wallet API + PassKit signing infrastructure — outside parity-sweep scope. Revisit when distribution/signing is in place | not implemented |
| m-contacts / m-voice / m-scan / m-snap-review | Already wired in earlier work; functional parity claimed. Visual editorial sheets (waveform pulse, in-app contact bottom sheet, custom camera-frame chrome) intentionally not adopted — would replace working OS-native pickers with custom in-app UI that ships less reliably across platforms | `wizard/widgets/contact_picker_button.dart`, `voice_input_button.dart`, `document_import_sheet.dart`, `document_pipeline_flow.dart` |
| m-welcome onboarding | Page 1 of the existing 4-page carousel restyled to match the prototype's editorial hero (italic "In your words." + 4 value pills). Pages 2-4 kept — they carry educational content the prototype's single screen omits | `onboarding/onboarding_screen.dart` |
| m-wizard-people | Statute badge (`20 Pa.C.S. § 5836`) + Yes/No/Agent decides/If… explainer card added. The prototype's tap-to-expand agent-card layout intentionally not adopted — would replace the existing data-entry forms with a different interaction model | `wizard/steps/people_i_trust_step.dart` |
| Desktop content cap | `kMaxContentWidth = 1100` constraint in `ResponsiveShell` so 1920+ px monitors gain matched side gutters instead of stretched content | `widgets/design/responsive_shell.dart` |

## Commits shipped this session

| Commit | What |
|---|---|
| `dd36673` | Code-review sweep: 15 high-effort findings applied |
| `d39e601` | README refresh for the implemented set |
| `394236c` | Batch 1 — navy default + personalized home greeting |
| `1a08c00` | Navy-only lock (palette picker removed) |
| `4b6f714` | Service-worker cleanup belt-and-suspenders |
| `ece995b` | Batch 3 part 1 — m-empty hero + m-welcome editorial pills |
| `e2ff434` | Batch 3 part 2 — § 5836 badge + reclassifications |
| `bfa5f3a` | Batch 4 part 1 — m-public ephemeral + m-renew + m-checkin sheets |
| `8fbeb77` | Batch 4 part 2 — m-verify wallet QR view |
| `440e2a3` | Batch 5 part 1 — m-faceid + w-wizard desktop rail |
| `32e0124` | Batch 5 part 2 — desktop max-content cap |
| `c4716db` | Batch 5 part 3 — reminder auto-fire on launch |
| `64b52e4` | Batch 5 part 4 — m-agentaccept manual log (schema v11) |
| `75120e7` | Batch 5 part 5 — m-sign editorial print-and-sign |
| `ab6153e` | Batch 6 part 1 — m-permission overview + m-pdf reclassified |
| `a24168f` | Batch 6 part 2 — scan/voice/contacts reclassified |

All on `main`. `flutter analyze` clean, 167/167 tests green throughout.

---

## Design-conformance pass (2026-06-07)

Re-fetched the ratified design bundle from the Claude Design URL and confirmed
it is **byte-identical** (md5 match) to the in-tree `MHAD-handoff/bundle/mhad/`.
Ran a three-way verification (functional checklist · web artboards · mobile
re-audit) against the code, then implemented the genuine gaps. All on `main`,
`flutter analyze` clean, 172/172 tests green (5 new encryption tests).

### Stale entries from earlier batches — corrected
The re-audit found the earlier audit *undersold* completed work and overstated
parity on three health screens:
- **m-home** — the editorial greeting + decorative numeral are present; the old
  🟡 was stale (now ✅).
- **m-renew / m-checkin** — auto-trigger on launch is implemented in
  `reminder_scheduler.dart`; the "deferred" note was stale (now ✅).
- **m-wizard-people** — the tap-to-expand `_AgentCard` *was* adopted; the
  "intentionally not adopted" note was wrong (now ✅).
- **m-diagnoses / m-allergies / m-review** — were marked ✅ but had never been
  converted to the editorial design system (Material `Card`/`ListTile` drift).
  **Now restyled** to the design system.

### Implemented this pass
- **Chrome sweep finish** — `ai_consistency` + `form_type_selection` dropped
  their Material `AppBar`; `WizardHeader` tap targets raised to 48dp (Android
  a11y).
- **FACTUAL_ANALYSIS §6 content gaps** — C1 expiry-exception/effective-date on
  welcome chip + Settings + PDF header; capacity-presumption reassurance
  (onboarding); "forms not mandatory" (sign step); structured records-disclosure
  release/withhold control (§ 5836(e)).
- **m-diagnoses / m-allergies / m-review** editorial restyle; new shared
  `HealthChip` widget; allergies kind-toggle + autocomplete.
- **Amendment flow** (F5) — distinct from renew/revoke.
- **w-dataexport** — CSV + FHIR XML formats; AES-256 password-protect + in-app
  unlock (new `encrypt` dep; the `pdf` package can't encrypt PDFs, so the *data*
  export is protected).
- **w-wizard / w-wiz-mobile** — desktop AI right rail + narrow peeking help bar.
- **w-home** — desktop Tools sidebar.
- **w-export / w-learn / w-ai** — two-pane export, responsive learn grid, AI
  context panel.

### Still deferred (unchanged)
- **m-wallet** — Apple/Google Wallet pass (needs cert/PassKit infrastructure).
- **w-snapfill** desktop drag-drop zone — OS file/image picker covers the
  function; custom drop UI is low value.
- True password-protected **PDF** and multi-file **.zip** bundle — pdf-package
  limitation / would need an archive dep; the encrypted data export covers the
  protection requirement self-containedly.
