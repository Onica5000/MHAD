# Claude Design ↔ Current MHAD Flutter App — Comprehensive Differences Audit

**Date:** 2026-05-28
**Author:** Visual-vs-functionality assessment of the Claude Design handoff
(`mhad/project/*`) against the current Flutter codebase on `main`.
**Source of visual truth:** Claude Design bundle (default palette `navy`, but
all three palettes already supported in `app_theme.dart`).
**Source of functional truth:** current codebase, including the prototype-
fidelity sweep recorded in `docs/GAP_ANALYSIS_V4.md` § V4-M10c.
**Status:** Assessment only. No code has been changed. Use this doc to decide
which items to ship; tick them off as they land.

**Principle (per user):** visually, Claude Design takes precedence;
functionally, the existing app takes precedence. Where the design omits an
existing functional surface, that surface is flagged 🛡 and must be preserved
even when adopting the design's look.

---

## Legend

- ✅ Already faithful — design and app match
- 🟡 Partial — same direction, but visual details / order / labels differ
- 🔴 Material visual difference — needs work to match design
- 🆕 Screen / feature exists in design only — no Flutter equivalent yet
- 🛡 Functional surface the design omits — **must be preserved** even when
  adopting the design look
- ❗ Structural change with downstream code impact (database, PDF, router,
  `FormType.steps`)

---

## A. Design-system layer (tokens, type, palettes)

| Item | Design | App now | Diff |
|---|---|---|---|
| Color palettes (Warm Teal · Deep Navy · Sage, light/dark) | 3 palettes with full role tokens | All 3 already in `app_theme.dart` | ✅ Match (`ds.jsx` explicitly says it was "lifted directly from `lib/ui/theme/app_theme.dart`") |
| Default palette on first launch | `navy` (per `Mental Health Advance Directive.html` DEFAULTS block) | `teal` | 🟡 1-line change in theme controller if you want to match the prototype's parked-state default |
| Type pairing | DM Sans 400/500/600/700, Instrument Serif italic, JetBrains Mono | All three already wired; fallbacks Georgia / Consolas | ✅ |
| Editorial italic numerals (54 px) above wizard step heads | `SerifNumeral` 54 px + MONO `Step N of Y` caption | `StepHead` widget already renders this pattern | ✅ |
| Filled-white card inputs (radius 12, 1.5 px border, 48 px height) | `Field` token | `app_theme.dart` `inputDecorationTheme` | ✅ |
| Crisis pill / top bar (red 988 24/7) | `CrisisBar` (full + compact) on every screen | `CrisisTopBar` already on every top-level screen | ✅ |
| Floating bottom-nav pill (Home · Learn · Ask · Settings) | Yes, fully rounded, only-active label | `MhadBottomNav` already matches | ✅ |
| Wide-≥1000-px left sidebar | `WebSidebar` 232 px | `WebSidebar` + `ResponsiveShell` already exist | ✅ |
| Wallet card (gradient `primary → primaryDark`, "MH" italic watermark, QR strip) | Done | `WalletCard` widget matches | ✅ |
| Crisis sheet (988 / Crisis Text Line / SAMHSA / PA P&A) | Done | `CrisisSheet` matches | ✅ |

**Net:** the entire visual atom layer is already in place. Most of the
differences below are *which screens use which atoms* and *which labels /
sections they show*, not foundational styling.

---

## B. Navigation / app shell

| Item | Design | App now | Diff |
|---|---|---|---|
| **Mobile bottom nav** items | Home · Learn · Ask · Settings | Same | ✅ |
| **Web sidebar** items | "Start" · "Learn" · "AI assistant" · "Download & print" · "Settings" | Currently "My directives" · "Learn" · "AI" · "Export & share" · "Settings" (`web_sidebar.dart`) | 🟡 Rename only — labels in the design intentionally avoid persistence connotations |
| **Web sidebar footer** | Dashed-border lock tile + `"Anonymous session"` over MONO `"NOTHING SAVED · NO ACCOUNT"` | Currently shows a user identity chip (AK · PRIVATE · FACE ID) | 🟡 Already partly migrated per the May-2026 anti-persistence pass; verify the footer chip is gone |
| **Wizard AppBar action icons** (Smart Fill · Document Import · AI Chat · Close) | Design shows only `"Back"` + `"Save & exit"` text links (no icons) | App has 4 icon actions on the AppBar | 🛡 **Keep app behavior** — these are functional entry points to real features. `GAP_ANALYSIS_V4.md` already records the decision to keep them; the design is visually simpler but functionally lossy. Option: collapse them into a single overflow-menu button to recover visual minimalism without losing the destinations. |
| **No hamburger drawer** | Design never uses one | App already removed `app_drawer.dart` | ✅ |

---

## C. Wizard structure (the largest structural difference)

❗ **Step count and ordering differ.** The design's canonical flow (`flow.jsx`
+ every wizard artboard) is **11 steps**. The app's `FormType.steps` is
**9 steps**.

| # | Design (11 steps) | App now (9 steps) | Diff |
|---|---|---|---|
| 1 | About you | About You | ✅ |
| 2 | When this kicks in *(diagnoses merged in as optional chips)* | When This Kicks In *(same — diagnoses are inline chips)* | ✅ |
| 3 | People I trust *(POA/Combined only)* | People I Trust *(same)* | ✅ |
| 4 | If a court appoints a guardian | If a Court Appoints a Guardian | ✅ |
| 5 | Where I want care | Where I Want Care | ✅ |
| **6** | **🆕 Diagnoses (ICD-10 autocomplete · NLM Clinical Tables)** | *(no separate step — diagnoses are chips inside step 2)* | 🔴❗ **Net-new step.** Visually huge. Functionally requires: (a) ICD-10 autocomplete UI, (b) NLM clinical-tables API client, (c) Drift schema for diagnosis codes + provenance + diagnosis date/provider, (d) PDF section. |
| **7** | **🆕 Allergies & reactions (RxTerms · severity Mild/Mod/Severe + reaction chips)** | *(absent)* | 🔴❗ **Net-new step.** Requires: RxTerms API client, severity + reaction-chip data model, cross-link into medications step (`Haldol → Severe` auto-fills "avoid Haldol" in step 8), PDF section. |
| **8** | Medications **two-section** — Section A "Current medications" (informational, RxTerms autocomplete) + Section B "Crisis preferences" (binding, prefer/avoid columns, **AUTO-LINKED** badge from allergies) | Step 6 "Medications" with **3 tabs** Prefer / Avoid / Reactions (preferences-only, no "current meds informational" concept) | 🔴 Major rework. Adds the "informational current meds" half-screen and the auto-link from allergies. Reactions tab content largely moves into step 7. |
| 9 | Procedures & research (ECT · experimental · drug trials, three consent tiles) | Step 7 Procedures & Research (same content) | ✅ (renumber only) |
| 10 | Anything else | Step 8 Anything Else | ✅ (renumber only) |
| 11 | Review *(then `Sign & witness` as a separate destination, **not** a tab inside Review)* | Step 9 Review **+ tab** "Sign & witnesses" (one screen, two tabs) | 🟡 The design treats Review and Sign as **two distinct screens** sequenced one after the other. App currently merges them in `review_and_sign_step.dart`. |

🛡 Functionally preserved either way: all 15 PA-statute fields. The merges in
steps 2/3/8/9 already happened — the only legal-coverage gap if you adopt
11 steps is making sure diagnoses + allergies fields persist correctly even
when the user is on a form type (Declaration-only) that the design lets skip
them.

**Decision point:** keep 9 or move to 11? If you move to 11, you inherit
ICD-10 + RxTerms infrastructure and the cross-step auto-link logic, plus
three new PDF sections. (`docs/GAP_ANALYSIS_V4.md` § V4-M11 still says
"9-step" — that doc would also need updating.)

---

## D. Screen-by-screen — top-level & onboarding

### D1. Welcome / Onboarding

- **Design** (`ScrWelcome`): single screen. Status spacer + floating 988 pill
  top-right (no full CrisisBar). Editorial 68 px italic `"In your"` /
  `"words."` ("words." in primary). Sub: *"Document how you want to be
  treated during a mental health crisis — so your wishes are honored even
  when you can't speak for yourself."* Four icon chips:
  *Valid 2 years · 2 witnesses · PA Act 194 · Stays on your device*. Primary
  `"Get started"` + ghost `"I already have a directive"`. Footer:
  *"Free · no account · no tracking · open source"*.
- **App now** (`onboarding_screen.dart`): **4-slide PageView carousel**
  ("In your words" → "What You Can Include" → "What to Have Ready" →
  "Takes About 20–40 Minutes") with dot progress + Skip + Next.
- 🔴 **Big difference.** Design is one screen, app is four. The italic hero
  on page 1 matches; the carousel is design-extra.
- 🛡 The 4-slide content (what to expect, what to have ready) is genuinely
  useful onboarding the design omitted. Option: keep slide 1 styled like
  `ScrWelcome` (chips + two CTAs) but keep slides 2-4 behind a
  `"Learn more"` ghost button.

### D2. Mode selection

- **Design** (`ScrMode`): SectionLabel `"Step 1 of 3 · setup"`, H1
  `"How should we handle your data?"`, two Card2 cards (Private + Public)
  with Recommended badge floating on Private, badge pills inside, footer
  `"This app is not HIPAA-compliant…"`.
- **App now**: ✅ Already prototype-faithful (per V4-M10c). Verify chip
  labels match exactly: design uses `"Face ID"` (Apple) vs app probably
  uses `"Biometrics"` — this is intentional cross-platform; **keep
  `"Biometrics"`** functionally (Android too).
- ✅ Acceptable.

### D3. Disclaimer

- **Design** (`Disclaimer Screen.html`): editorial 44 px italic *"A few
  important things."*. **Warn TL;DR card** with `AlertTri`:
  *"Short version — This app helps you document your preferences. It is
  not legal or medical advice. To be valid, your directive must be signed
  in front of two adult witnesses. Tap each section below to expand."*
  Read-progress meter `"X / 8 READ"` with a 3 px primary bar. 8 accordion
  sections (first open by default). **Two checkboxes** (`"I'm 18 or older,
  or an emancipated minor."` + `"I understand this app is not legal or
  medical advice."`) — Continue **disabled** until both checked. Footer
  micro: *"You can re-read this anytime from Settings → Legal."* Floating
  `"Need 988"` red pill top-right (no full CrisisBar).
- **App now** (`disclaimer_screen.dart`): ✅ Already implements the
  editorial header, TL;DR banner, accordion sections, progress meter,
  **two checkboxes**, and the 988 pill. (V4-M10c records this.)
- ✅ Acceptable. Minor: confirm the section ORDER in the app matches
  design: `01 Not legal/medical advice → 02 No professional relationship
  → 03 No warranty → 04 Validity reqs → 05 2-year → 06 Revocation →
  07 Privacy/AI → 08 Resources`.

### D4. Home (active draft)

- **Design** (`ScrHome`): SectionLabel date (`"Saturday · May 14"`).
  Greeting row: SERIF italic `"Hi, Alex."` + smaller muted *"Let's keep
  your voice clear."* and right-aligned 40 px avatar `"AK"`. **Active
  directive hero** = solid primary card with translucent `"3"` watermark,
  `● Draft` badge, `Step 3 of 11` MONO, `"My MHAD"` title, sub
  `"Combined form · last edited 2 hours ago"`, white-on-track 4 px
  progress (33 %), white pill `"Continue where you left off"`. Outline
  `"Start a new directive"` button. **Tools 2×2 grid** (Sparkles "AI
  assistant / Suggests + checks", Book "Learn / FAQ, glossary", Wallet
  "Wallet card / Carry a copy", Heart "Crisis help / 988 + more").
  **Past directives** section (one card "Directive · 2023" + DotsH menu).
- **App now** (`home_screen.dart`): ✅ Per V4-M10c, the
  `_ActiveDirectiveHero` (with progress + Continue CTA) and `_ToolsGrid`
  (2×2) were added. Existing `DirectiveCard` list, `_LearnMoreCard`,
  `ProviderResourcesCard`, and "New Directive" FAB were preserved.
- ✅ Mostly there. 🟡 Remaining nits:
  - Design uses `"Step X of 11"` on the hero — app shows the step counter
    against the app's 9-step model. Will align automatically if you adopt
    11 steps.
  - Design's greeting includes the **named user** (`"Hi, Alex."`); app
    must keep this generic in **public mode** (anonymized) — already
    handled by the recent anonymous pass on web; check mobile parity.

### D5. Form type selection

- **Design** (`ScrFormType`): radio-dot `Opt` cards with title + sub + MONO
  tag pills, RECOMMENDED badge on Combined, primaryLight `"Help me choose
  →"` banner with Sparkles. Tag pills: **Combined = "11 steps" · "Agents +
  preferences" · "Most common"**; **Declaration only = "6 steps" · "No
  agents"**; **POA only = "7 steps" · "Agents only"**.
- **App now** (`form_type_selection_screen.dart`): ✅ Per V4-M10c, already
  uses Opt radio cards + tag pills + primaryLight quiz banner. Tag pills
  currently say `"9 steps"`, `"8 steps"`, `"9 steps"` — would change to
  **11 / 6 / 7** if you adopt the new flow.
- ✅ Acceptable.
- 🛡 The screen also contains: POA-confirmation dialog, AI setup prompt,
  snapshot/restore logic, loading overlay, "Import from Existing" button.
  **Design omits all of these** but they are functional value-adds —
  keep.

### D6. "Help me choose" quiz

- **Design** (`MobileExtra · quiz`): `"Help me choose · question 2 of 4"`,
  StepDots 2/4, big italic question *"Do you have someone in mind to
  **speak for you**?"*, 4 radio cards, primaryTint **result preview** card
  with confidence bar `"50% CONFIDENT · 2 MORE QUESTIONS"`.
- **App now** (`form_type_quiz.dart` exists in `lib/ui/wizard/widgets/`):
  🟡 The widget exists but has not been verified to match the 4-question
  funnel with confidence-meter visual. Likely needs visual polish to the
  design's pattern.
- Recommend: open the file and verify against the design.

---

## E. Wizard-step screens

For every step the chrome (CrisisBar compact + Back/Save&exit row + StepDots
+ StepHead with 54 px italic numeral + body + WizardBottomBar) is already
structurally correct in the app. Below are content / visual diffs only.

### E1. Step 1 — About You

- **Design**: Includes a **Smart Fill hero card** at the top of the form —
  solid primary background, italic *"Snap a photo. We'll read it and fill
  the wizard."* 2×2 capture grid (**Photo of ID** [START HERE] · **Rx
  bottle / label** · **Conditions list** · **Anything else**). Privacy
  footnote. Then divider *"or by hand"*. Then fields with **SourcePill**
  chips next to each label (`"✓ ID PHOTO"` / `"✓ CONTACTS"`).
- **App now**: Has a Smart Fill flow (`smart_fill_flow.dart`) and Document
  Import sheet, but they live behind an AppBar action icon, not as the
  hero at the top of step 1.
- 🔴 To match design: move/promote the Smart Fill launcher to top of
  step 1 with the 2×2 multi-target capture grid, then add `SourcePill`
  badges to filled fields. Functionally additive — Smart Fill already
  exists.

### E2. Step 2 — When This Kicks In

- **Design**: SectionLabel `"Activation triggers"`. **3 checkbox trigger
  rows** (with 22 px filled-primary box when checked), each row a 1.5 px
  border that turns primary when checked: (1) *"Two providers find me
  unable to decide"*, (2) *"A court determines I lack capacity"*, (3)
  *"I'm involuntarily committed"* — with the §302/303/304 sub. Then
  SectionLabel `"Relevant diagnoses · optional"`, helper *"Helps providers
  understand context. Skip if you'd rather not say."*, filled SANS chips
  with trailing X (Bipolar II · Generalized anxiety · PTSD) + dashed
  `+ Add`. Multiline field *"Anything else providers should know"*.
  Dashed-bordered surface info callout: *"You're never required to
  disclose a diagnosis. Anything here is for providers' situational
  awareness only."*
- **App now** (`effective_condition_step.dart`): currently a single
  free-text field for effective condition + a preferred doctor
  sub-section.
- 🔴 Significant visual + structural diff. The design treats this as **two
  distinct decision blocks** (triggers + diagnoses chips). If you adopt
  the 11-step flow, the diagnoses chips here become a lighter version of
  step 6, and a checkbox-trigger affordance replaces the free-text input.
- 🛡 The app's "preferred doctor name/contact" section is **not** present
  in the design but matches a functional PA-form field; keep.

### E3. Step 3 — People I Trust

- **Design**: Two **Agent cards** (1.5 px primary border on the expanded
  primary, plain border on the collapsed alternate), 38 px avatar + name
  + sub + chevron. Expanded card shows `"✓ Contact picker"`,
  `"✓ Phone verified"`, `"Edit details"` chips on a dashed top border.
  Then SectionLabel `"What can they decide?"` followed by **5 ConsentRow
  rows** (Yes / No / Agent decides / If…) for:
  1. *"Talk to my doctors and review records"* → yes
  2. *"Admit me to a mental health facility"* → if
  3. *"Consent to medications on my behalf"* → agent
  4. *"Consent to ECT (electroconvulsive therapy)"* → no
  5. *"Decide where I live during treatment"* → agent
- **App now** (`agent_designation_step.dart` + `alternate_agent_step.dart`
  + `agent_authority_step.dart`): three separate sub-step files combined
  into one People-I-Trust step.
- 🟡 Likely already presents three sections — verify the **5 specific
  ConsentRow questions** in app match the design wording; the design's
  wording is the canonical microcopy you should adopt.

### E4. Step 4 — Guardian

- **Design**: 4 radio Opt rows (Same as primary / Same as alternate /
  Someone different / No preference). Each row names the linked agent so
  it's obvious. Then **3 ConsentRow questions** for guardian conditions:
  *Can change my agent · Can override this directive · Must consult my
  agent first*. AI-tip callout: *"Most people pick their primary agent.
  Keeping it consistent reduces conflict if both roles ever activate."*
- **App now** (`guardian_nomination_step.dart`): likely free-text fields;
  not the 4-radio + 3-ConsentRow pattern.
- 🟡 Microcopy + layout difference. Adopt the design pattern; keep any
  current persistence fields that store the choice.

### E5. Step 5 — Where I Want Care

- **Design**: Two subsections with colored dots — green `Preferred`
  (`"2 ADDED"`) listing 2 facility cards with green dot, then red `Avoid
  if possible` (`"1 ADDED"`) listing 1 facility with red dot. Dashed add
  buttons in matching tone. **Room preferences** chip row: *Single room ·
  Window if possible · Quiet floor · Female roommate only · No roommate*.
  Multiline *"Anything else about location"*.
- **App now** (`treatment_facility_step.dart`): single facility-preference
  section with a `ConsentRow`.
- 🔴 Major content gap: design adds **avoid list** + **room-preference
  chips** that the current app doesn't expose. Functionally these are
  real preferences the PA form supports as free text. Adopting them
  needs schema for "facility lists" and "room preference flags" (or just
  store as structured JSON in additional instructions).

### E6. Step 6 — Diagnoses 🆕 (NEW in design)

See § C. Visual: SearchField with ICD-10 badge + glowing autocomplete
dropdown (showing realistic NLM-Clinical-Tables F31.* matches for "bipo"),
**added-conditions chips** (code chip + name + sub + RxTerms/ICD-10 source
tag + trailing X). AI-fallback callout (*"Don't know the official name?
Describe how it shows up for you…"*). Privacy italic footer.

### E7. Step 7 — Allergies 🆕 (NEW in design)

See § C. Visual: SectionLabel `"Add a drug allergy"` + SearchField with
**RxTerms** badge + autocomplete showing penicillin V/G/amoxicillin
(cross-reactive warning visible). **Severity selector** Mild · Moderate ·
**Severe** (color-coded; Severe glows crisis-red when active). **Reaction
chips**: Anaphylaxis · Hives · Swelling · Throat closing · + Add. Three
example added allergies color-toned by severity (Haldol/SEVERE/crisis,
Latex/MOD/warn, Shellfish/MILD/primary). **Warn callout**: *"Why this
matters here. If you list Haldol → Severe, the Treatment Preferences step
will auto-suggest 'do not administer Haldol' and bind your agent to that
refusal."*

### E8. Step 8 — Medications (split visual)

- **Design** (`ScrMedicationsV2`, `health-steps.jsx`): two clearly-labeled
  sections.
  - **A · Current medications** with mono pill `"3 · INFORMATIONAL"`.
    RxTerms search + autocomplete open for `"sertra"`. Three current-med
    chips (SSRI Sertraline 100 mg AM, MOOD Lamotrigine 200 mg BID, PRN
    Hydroxyzine 25 mg PRN). Dashed add row *"Add another current
    medication / OR SNAP A LABEL"*.
  - Dashed divider.
  - **B · Crisis preferences** with red MONO `"BINDING"`. Side-by-side
    **PREFER** (green) Lorazepam / **AVOID** (red) Haloperidol — with
    `"Auto-linked from Allergies"` provenance tag. AI callout pre-fills
    the link.
- **App now** (`medications_step.dart`): single `Prefer / Avoid /
  Reactions` tab UI (preferences only — V4-M10c calls this the
  "preferences-only" path).
- 🔴 Major visual + functional rework if adopting 11-step flow. The
  "current medications" section is genuinely new functionality
  (informational, not binding). Cross-step auto-link logic is new.

### E9. Step 9 — Procedures & Research

- **Design** (`ScrWizardProcedures`): three Tile cards with 36 px
  primaryTint icon tile, Info icon next to title, description, then
  ConsentRow, then italic info reminder of the user's choice. Three
  tiles:
  1. **Electroconvulsive therapy (ECT)** — *"A procedure that uses brief
     electrical pulses to treat severe depression and some other
     conditions."* — ConsentRow `if` — *"You said: only if my primary
     agent agrees."*
  2. **Experimental studies** — *"Research that isn't yet approved as
     standard care. Participation is always voluntary."* — ConsentRow
     `no`
  3. **Drug trials** — *"Testing new medications that aren't yet
     FDA-approved for your diagnosis."* — ConsentRow `agent`
  - Dashed surface callout: *"Why these three? PA Act 194 specifically
    calls out ECT, experimental studies, and drug trials as requiring
    documented consent. Other treatments fall under your general
    preferences."*
- **App now**: three sub-steps already consolidated (`ect_step.dart`,
  `experimental_studies_step.dart`, `drug_trials_step.dart` co-exist as
  files but the wizard step shows them together). 🟡 Verify they render
  as the design's **3-tile pattern** with the *Why these three?*
  callout.

### E10. Step 10 — Anything Else

- **Design** (`ScrWizardElse`): big multiline textarea (min-height 180,
  MONO char counter `"247 / 1000"`, blinking primary cursor). **AI
  Rephrase callout** with `"Rephrase →"` link. SectionLabel `"Common
  things to consider"`. **6 Prompt rows** (icon + label, "used" rows =
  primaryTint + Check; "unused" rows = card + Plus):
  - ✓ Shield "Restraints & seclusion"
  - ✓ Heart "Comfort items (pets, photos…)"
  - Users "Visitors I want / don't want"
  - Phone "Who to contact (and who not to)"
  - Book "Religious or spiritual practices"
  - Calendar "Care of pets, kids, plants at home"
- **App now** (`additional_instructions_step.dart`): multiple categorized
  text areas (activities, crisis intervention, dietary, religious,
  custody, family notification, records, pet custody, other).
- 🔴 Major UI difference. Design uses one big textarea + tappable prompt
  seeds; app uses many separate fields.
- 🛡 The app's multiple fields are queryable / structured (PDF can section
  them, AI can address each). Adopting the design means moving to
  free-text + prompts — which loses structure. Option: keep the
  structured fields under the hood but render a single textarea on
  screen and seed-prompts insert headers (`"Restraints & seclusion: …"`)
  into it.

### E11. Step 11 — Review

- **Design** (`ScrReview`): one screen. Status banner (`"Everything looks
  good. 1 optional warning."`), list of 8 row cards each with primaryTint
  italic serif numeral, label + ellipsized summary, trailing green check
  or amber warn icon, trailing pencil. Sticky bottom: ghost `"Preview
  PDF"` + primary `"Continue to sign"`.
- **App now** (`review_step.dart` inside the combined
  `review_and_sign_step.dart`): scroll list with section summaries.
- 🟡 Verify the list-with-numeral pattern + status banner match the
  design.

### E12. Sign & Witness (separate from Review in the design)

- **Design** (`ScrSign`): editorial *"Make it legal."*, sub *"You and two
  adult witnesses must sign in the same place, at the same time."*. Three
  SigPad cards (Principal · Alex M. Kowalski · signed; Witness 1 · Maria
  Chen · signed; Witness 2 · `Tap to add` · unsigned). 76 px dashed-border
  canvas with a signed-state SVG scribble. **Warn callout**: *"Witnesses
  must be 18+, present when you sign, and not your designated agent."*
  Date row with Calendar icon: *"Signed today, May 14, 2026 · valid
  through May 14, 2028"*. Sticky *"Finish & export"*.
- **App now**: lives as the second tab inside the Review step.
- 🟡 Move to a separate route/screen or keep as tab? Design treats it as
  its own destination. Functionally either works; visually they should be
  sequential, not tabbed.
- 🛡 Full-screen signature canvas (`MobileExtra2 · sign-canvas`) exists in
  the design (paper texture #fffdf8, ruled line, pressure gauge,
  `"SHA-256 PINNED"` mono footer) — the app's signature pad is simpler.
  🆕 If you want pixel parity, build the dedicated full-screen canvas.

### E13. Done + Wallet (`wizard_complete_screen.dart`)

- **Design** (`ScrDone`): no CrisisBar. SectionLabel `"● Complete"`, giant
  64 px italic *"You did it."* (two lines, primary "it"). **Wallet card**
  with QR (gradient + "MH" watermark + Alex Kowalski + AGENT/EXP fields).
  **Share checklist** of 5 rows (primary agent ✓ · alternate ✓ · PCP ·
  psychiatrist · trusted family). **Three tonal action buttons** (PDF ·
  Share · Wallet). Note: design **does NOT include** an explicit "What to
  do next" 5-step checklist or an error banner (these are app-specific).
- **App now**: ✅ Matches the editorial heading + wallet card. **Adds** a
  "What to do next" checklist + an error banner + a separate "Export PDF"
  full-width button below.
- 🟡 The app additions are functionally helpful. Decision: keep additions
  or trim to match the cleaner design? Recommend keep — the design is
  more aspirational than instructive at this point.

### E14. Crisis sheet

- **Design** (`ScrCrisis`): bottom sheet over dimmed home, `"● 24/7 free,
  confidential"`, italic *"You are not alone."*, 4 resource rows (988 in
  crisis-tone accent + Crisis Text Line + SAMHSA + PA P&A in surface
  tone), ghost Close.
- **App now** (`crisis_sheet.dart`): ✅ Matches the four-resource list.
- ✅ Acceptable.

---

## F. Education / Learn

### F1. Mobile Learn hub

- **Design** (`MobileExtra · learn`): editorial *"Understand before you
  sign."*. Search pill. **2-column card grid** with **first card spanning
  full-width as a SOLID TEAL featured card** carrying a translucent `"?"`
  watermark — `"What is an MHAD?"` / `"4 MIN · MOST READ"`. Other cards:
  Users "Picking the right agent / 5 MIN", Shield "Your rights / 7 MIN",
  Brain "When does it activate? / 3 MIN", FileText "Glossary / 2 MIN".
  **Pull-quote card** (primaryTint, italic primaryDark): *"Your directive
  is your voice — written in advance, kept safe, honored when you can't
  speak for yourself."* — `— PA MHAD BOOKLET · OMHSAS`.
- **App now** (`education_screen.dart`): has the editorial header +
  category dropdown + section list (per V3-H8 / V4-M10b expansions).
- 🔴 Visual rework: card grid with featured solid-teal hero card +
  pull-quote card are visually distinct from the current list.
  Functionally the app's content is richer (Ch.54/Ch.58 bridge, advocate
  checklist) and that must be preserved.

### F2. Article reader 🆕

- **Design** (`MobileExtra · article`): 2 px reading-progress bar, MONO
  `"LEARN · 4 MIN"`, large italic title, byline, body 15 px line-height
  1.65, **pull-quote with left teal border**, ordered list, **"TRY IT"
  CTA card** in primaryTint, "Up next" rows.
- **App now**: no dedicated reader screen — articles open in dialogs or
  as in-screen detail.
- 🆕 New screen if you want pixel parity.

---

## G. AI assistant

### G1. AI assistant (mobile)

- **Design** (`MobileExtra · ai`): Header `"AI assistant"` + MONO `"● ON ·
  GEMINI · PII STRIPPED"`. **First-time consent banner** in warn-amber
  (Shield): *"Heads up. Messages go to Google Gemini. Names, addresses &
  dates are auto-stripped, but review suggestions before accepting."*
  Underlined links "Privacy details" · "Turn off". AI bubble with MONO
  label `"GEMINI · NOT LEGAL ADVICE"`. User bubble teal onPrimary
  `"YOU"`. AI response includes a **redaction badge** `"GEMINI · 🔒 3
  FIELDS REDACTED"`. Embedded **"SUGGESTED FOR STEP 8"** primaryTint card
  with italic suggested wording + primary sm `"Use this"` + ghost sm
  `"Edit"`. Suggested-prompt chips. Rounded input pill with Sparkles,
  Mic, primary send button.
- **App now** (`assistant_screen.dart`): functional Gemini chat with PII
  consent gate, rate-limit handling. Visuals are mostly Material chat
  bubbles without the design's MONO labels or redaction badges or
  suggestion-card affordance.
- 🔴 Heavy visual upgrade — but the design's **"suggestion card with Use
  this / Edit"** affordance is a new functional capability (suggested
  text → field). That requires the AI response format to carry
  structured suggestions.

### G2. AI consistency warning 🆕

- **Design** (`MobileExtra2 · conflict`): editorial *"I noticed two
  things."* ("two things" in warn-amber). Two **amber conflict cards**
  showing two clashing answers + an inner explanatory card. Buttons
  "Edit step X" / "Keep both" etc. AI-note callout. Bottom bar: `"Ignore
  & continue"` / `"Resolve in order →"`.
- **App now**: no consistency-warning surface.
- 🆕 New screen + new functionality (consistency engine that detects
  internal contradictions).

---

## H. Export / share

### H1. Mobile export & data export hub

- **Design** (`MobileExtra2 · export`): editorial *"Take it with you."*.
  **5 format cards** (each 44 px primaryTint icon + name + `.ext` MONO
  chip + sub + `~size` + Download icon). **PDF · official form
  (RECOMMENDED badge)**, **Structured data .json**, **HL7 FHIR R4
  .xml**, **Wallet pass .pkpass**, **Spreadsheet .csv**. Dashed "Bundle
  everything as a zip" surface card. Optional encryption callout (Lock
  icon): *"Optional: encrypt the export with a password. They'll need it
  to open the file."*
- **App now** (`export_screen.dart`): a single multi-checkbox form
  (Combined / Declaration / POA / Supplementary / Notes) + "share"
  button + unencrypted-file warning. V4-M8 records that password
  protection was removed.
- 🔴 Major UX rework + new export targets (JSON, FHIR, wallet pass, CSV)
  are net-new functionality. Optional encryption affordance is also
  re-introduced (the design shows it as a callout).

### H2. PDF preview (mobile + web)

- **Design** (`MobileExtra · pdf` and web `export`): mobile = paper sheet
  in serif body with section heads (`SECTION 1. EFFECTIVE CONDITION` …)
  and 6-page thumbnail strip + Save · Print · Share tonal bar. Web =
  same paper preview + right-side controls (checkboxes for sections +
  wallet card preview + Download PDF + warning *"Download before you
  close. Nothing is saved on our end…"*).
- **App now**: PDF preview is via `printing` package — no in-app
  paper-preview screen; PDFs go straight to system share.
- 🟡 The design's in-app paper preview with page thumbnails is a UX
  upgrade. Functionally, the current path works fine.

### H3. Share sheet 🆕

- **Design** (`MobileExtra · share`): bottom sheet over dimmed Done
  screen. *"Who needs a copy?"*. Horizontal contacts row (avatars + role
  chips). 4-column "Send via" grid (Email · Text · QR · Print). 4-row
  "They get" preview (Full directive PDF · Wallet-card summary ·
  Verification QR + link expires 7 days · Read-receipt request).
- **App now**: uses system share sheet only.
- 🆕 New in-app share sheet with QR + read-receipt functionality.

### H4. Wallet handoff (Apple Wallet) 🆕

- **Design** (`MobileExtra2 · wallet`): black sheet with full pass preview
  + back-of-pass details + privacy strip + white "Add to Wallet" button.
- **App now**: only the wallet **card visual** exists; no `.pkpass`
  handoff.
- 🆕 New functionality if desired.

### H5. PDF wallet card + QR verifier view 🆕

- **Design** (`MobileExtra · verify`): **dark-themed surface** (whole
  screen is `text` color) to signal "not the principal's phone." Green
  active-and-valid banner. Treatment flags color-coded (Avoid Haldol
  crisis-red, No ECT crisis-red, Drug trials warn-amber, Restraints
  ok-green). Footer MONO `"VERIFIED VIA SIGNED LINK ·
  QR.MHAD.PA.GOV/AK-2026"`.
- **App now**: no verifier-side view.
- 🆕 Net new — requires a signed-link / QR resolution endpoint (likely a
  static web page on the same hosting domain as the privacy policy URL
  needed for V4-C1).

---

## I. Settings

### I1. Mobile Settings

- **Design** (`MobileExtra · settings`): profile chip on a solid-primary
  card with avatar AK + `"● PRIVATE MODE · FACE ID"`. **Grouped lists**:
  - **My directive** — View current · Renew or replace · Past directives
    (value "2") · **Revoke directive** (danger-red row)
  - **Data & privacy** — Mode · Biometric unlock · AI assistant ·
    Auto-lock after (value "5 min") · Export my data · **Delete all my
    data** (danger-red)
  - **Reminders** — Expiration reminder · Annual check-in
  - **About** — Re-read disclaimer · Your rights · Crisis resources ·
    Open-source & credits · Version
- **App now** (`settings_screen.dart`): per Explore inventory —
  Appearance (color theme + brightness) and AI & Privacy (AI setup,
  Privacy policy, Legal disclaimer, Screenshot protection toggle).
- 🔴 The design adds whole groups (My directive · Reminders · About)
  that don't exist on Settings today. **Reminders** group implies
  notification scheduling. **Revoke / Delete all** are danger-red rows
  for sensitive lifecycle actions. The "Auto-lock after" setting exposes
  a value the app already supports.
- 🛡 Color-theme + brightness in app should remain — the design omits
  these because the prototype uses a global toolbar, not in-screen
  controls.

### I2. Accessibility settings 🆕

- **Design** (`GapScreens · a11y`): editorial *"Make it readable."*. Live
  preview line with size slider (4 stops Small/Default/Large/Huge).
  **Reading toggles**: Dyslexia-friendly font (Atkinson Hyperlegible) /
  Read aloud / Reduce motion / High contrast. **Language**: segmented
  selector English · Español · 中文 · العربية with footnote *"Legal
  text is always rendered in English to preserve PA Act 194 wording."*
  **Hardware toggles**: VoiceOver hints / Switch Control / Hearing aid
  pairing.
- **App now**: no in-app accessibility settings (delegates to OS); V4-H7
  flags only partial Spanish localization (no Atkinson Hyperlegible, no
  in-app language picker).
- 🆕 New screen + functionality.

---

## J. Other net-new screens in the design

| Screen | Where in design | What it does | Status in app |
|---|---|---|---|
| Face ID unlock | `MobileExtra · faceid` | Welcome-back lock screen with face-scan SVG, *"Use passcode instead"* / *"Switch to public mode"* | 🆕 PIN dialog exists but no Face ID brand surface |
| First-time empty home | `MobileExtra · empty` | Dashed primary-bordered hero card, time-estimate rows, three "Before you start" article rows | 🟡 Home shows an empty state but not this specific hero |
| Public-mode home | `MobileExtra · public` | Inverted near-black "Public mode · nothing is saved" bar above CrisisBar; privacy-promise hero; 2×2 "what you can still do" grid | 🟡 Public-mode home exists but visually differs |
| Snap-to-fill camera (multi-target) | `MobileExtra · scan` | Black camera with target pills, viewfinder, AI callouts on detected fields, on-device lock chip | 🆕 No camera UI built in app (uses platform pickers) |
| AI extraction review | `MobileExtra · snap-review` | Card listing extracted fields with checkboxes + edit + `→ Step X` routing pills | 🆕 |
| Camera permission prompt | `MobileExtra2 · permission` | Dark iOS-system sheet with trust checklist | 🆕 |
| Voice input recording | `MobileExtra · voice` | Modal with waveform, timer `0:14`, live caption, red square stop button | 🆕 (voice button exists in fields; the recording overlay doesn't) |
| Contact picker | `MobileExtra · contacts` | Modal with search, eligible/ineligible (dimmed red) rows, manual-entry dashed button | 🟡 Contact picker exists; eligibility UI may not |
| Past directive detail | `MobileExtra · past` | Expired badge, document preview, "Who had a copy", danger-tone Delete row | 🆕 |
| Renewal nudge | `MobileExtra · renew` | Modal bottom sheet, amber "Expires in 28 days", quick-renew callout | 🆕 |
| Revocation flow | `MobileExtra · revoke` | Crisis-badge "Permanent action", notify checklist, type-`REVOKE`-to-confirm field, solid-red destructive button | 🆕 |
| Agent invite acceptance | `MobileExtra · invite` | Slim teal verified bar, principal card, duties list, accept/decline buttons | 🆕 |
| Witness picker | `MobileExtra2 · witness` | Eligibility chips (18+ · NOT YOUR AGENT · …), dimmed ineligible rows with reasons | 🆕 |
| Signature canvas (full screen) | `MobileExtra2 · sign-canvas` | Paper-texture canvas, pressure gauge, MONO `SHA-256 PINNED` footer | 🟡 Current sign uses simpler signature pad |
| Crisis plan & wellness toolbox (WRAP) | `GapScreens · crisisplan` | 5 sections: early-warning signs, triggers (red), things that help, things to say, don't-do (red); + Add chips | 🆕 P0 in design's roadmap |
| Lock-screen Live Activity | `GapScreens · lockcard` | Pure-black iOS lock screen with frosted MHAD card + Show QR / Call Jordan / `988` red | 🆕 |
| Facilitator mode | `GapScreens · facilitator` | "20× more often" hero, three pathways (peer / friend / clinician) | 🆕 P0 |
| Clinician view | `GapScreens · clinician` | Dark navy banner, severity-coded Do Not / Prefers / Who to call cards, audit footer | 🆕 P1 |
| Plain ⇄ Legal toggle | `GapScreens · legaltoggle` | Segmented toggle, same content in conversational vs Act 194 statutory voice | 🆕 P1 |
| Self-binding (Ulysses) clause | `GapScreens · ulysses` | Big primary toggle card *"Tie myself to the mast."*, boundary checklist | 🆕 P1 |
| Agent acceptance receipt | `GapScreens · agentaccept` | Green-check editorial header, receipt card with identity/read/duties/signature key-values, signature scrawl | 🆕 P2 |

---

## K. Web-app differences (mobile-browser + desktop)

| Item | Design | App now |
|---|---|---|
| **Anonymous-mode banner on dashboard** | Top-of-dashboard primaryTint banner *"You're working anonymously. Nothing is saved."* with explanation + MONO "HOW THIS WORKS →" | Likely partially present per the May-2026 anti-persistence pass |
| **Web dashboard hero** | 56 px italic *"Make a mental health advance directive."* (`advance directive.` in primary) + **Combined directive primary card** (large) + two stacked small cards (Declaration only · POA only) | Currently a directives-list dashboard |
| **Privacy promise card** | 2×2 grid: No account / Nothing leaves your browser / No cookies / You keep the file | Recent commit added something similar — verify |
| **Snap / upload to fill (desktop)** | Big **2 px dashed primary** drop zone with serif italic "AI" watermark, `⌘ V` keycap pill, Browse files + Use webcam, side panel "What you can drop here" 2×2 capture targets, "In this session" file list with `"CLEARED ON TAB CLOSE"` MONO note | 🆕 No drop zone in app web build |
| **Snap to fill — mobile browser** | iOS Safari URL bar mock, **"Take a photo"** primary tile + **"Pick a file"** secondary tile, mock native iOS action sheet preview, privacy footer | 🆕 |
| **AI extraction review (desktop)** | 2-pane: photo with bounding box + 96 % confidence pill / extracted fields with `→ Step N · …` provenance + accept/reject + edit | 🆕 |
| **Web wizard 3-pane** with right-rail AI panel | Step rail (180 px) + form + AI panel (320 px). AI panel includes step-aware "Heads up on this step" cards | Mobile-only structure today; desktop is the same wide layout but no right-rail AI |
| **Web wizard step rail** | 11 steps with ✓ done, current bold + 3 px primary left border, MONO step numbers | Currently 9 steps |
| **"THIS TAB ONLY" pill + "Download draft" button on wizard top bar** | Always present | 🟡 Verify against current `wizard_screen.dart` web layout |
| **Web AI assistant (full page)** | 2-pane: chat column + context panel showing Form type / Current step / Filled sections / PII stripped count + suggested prompts + Privacy primaryTint card | Mobile chat only |
| **Browser-window frame** | Mock macOS Chrome with two tabs `PA MHAD · onica5000.github.io` + `988 Lifeline` and a URL bar showing `onica5000.github.io/MHAD/` — this is a **design canvas frame only**, not an app feature | Design-only; ignore |

---

## L. Microcopy differences (canonical strings to adopt where the app differs)

The design re-writes several legacy labels. The app has already adopted most.
Quick reference of design-canonical microcopy:

| Old / app label | Design label |
|---|---|
| "Agent Designation" | **"People I trust"** |
| "Effective Condition" | **"When this kicks in"** |
| "Execution" | **"Sign & witness"** (separate screen, not "Review and Sign" tab) |
| "Drug Trials" | **"Research drug trials"** |
| "ECT Preferences" | **"Electroconvulsive therapy"** |
| "Form Type" | **"Which form fits you?"** |
| "Agent Authority" | merged into People I Trust as "What can they decide?" |
| Wizard CTA "Next" | "Continue to step NN" (web) / `Continue` + Arrow (mobile sticky) |
| Wizard secondary "Skip" | "Save & exit" (text link, top-right) |
| Welcome footer | *"Free · no account · no tracking · open source"* |
| Disclaimer footer | *"You can re-read this anytime from Settings → Legal."* |
| Anonymous web sidebar footer | `"Anonymous session"` + MONO `"NOTHING SAVED · NO ACCOUNT"` |
| Anonymous web banner | *"You're working anonymously. Nothing is saved."* |
| Smart Fill hero title | *"Snap a photo. We'll read it and fill the wizard."* |
| Smart Fill privacy | *"Photo stays on this device · only the extracted text touches the AI · nothing is stored."* |
| Crisis sheet header | `"● 24/7 free, confidential"` + italic *"You are not alone."* |
| Disclaimer banner | *"Short version — This app helps you document your preferences. It is not legal or medical advice. To be valid, your directive must be signed in front of two adult witnesses."* |
| Wizard "Why these three?" callout | *"PA Act 194 specifically calls out ECT, experimental studies, and drug trials as requiring documented consent. Other treatments fall under your general preferences."* |
| Pull-quote (used on welcome / learn) | *"Your directive is your voice — written in advance, kept safe, honored when you can't speak for yourself."* — *— PA MHAD BOOKLET · OMHSAS* |

---

## M. Things the design omits that the app should keep (🛡 functionality protections)

These are real features the design simplifies away. Visual minimalism would
cost user value — keep them.

1. **Onboarding slides 2-4** (carousel content beyond the hero).
2. **Wizard AppBar action icons** (Smart Fill · Document Import · AI Chat ·
   Close) — or collapse into a single overflow menu.
3. **Form-type screen extras**: POA confirmation dialog, AI Setup prompt,
   snapshot/restore, "Import from Existing", loading overlay.
4. **People-I-Trust step** PA-statute fields (current code stores Authority
   Limitations as structured data).
5. **Step 5 preferred-doctor sub-section**.
6. **Step 10 structured fields** (activities, crisis intervention, dietary,
   religious, custody, family notification, records, pet custody) — keep
   behind a single textarea facade if you adopt the design.
7. **Done screen** "What to do next" 5-step checklist + unencrypted-file
   warning.
8. **Settings → Appearance** (color-theme + brightness selectors) — design
   hides these because the prototype has a global toolbar.
9. **Education screen depth** (Ch.54/Ch.58 bridge, advocate checklist,
   provider-duty "shall comply" content — V4-M10b additions).
10. **AI consent dialog** (Apple Nov-2025 compliance) — design shows a
    banner but the explicit modal gate stays.
11. **Privacy Policy screen** (V4-C1 ongoing work) — design doesn't show a
    dedicated screen.
12. **Public mode** behavior (in-memory DB, no encryption) — design only
    shows the entry surfaces; keep the actual mechanism.
13. **Screenshot protection toggle** (Android).
14. **PIN entry / 5-attempt lockout** path (`pin_dialog.dart`) — design
    only shows Face ID.

---

## N. Suggested decision points before any code changes

The biggest forks are:

1. **Wizard step model: keep 9 or move to 11?**
   - +11: adds dedicated diagnoses (ICD-10) + allergies (RxTerms) +
     medications-current; matches design exactly; closer to clinical-
     research best practice; opens cross-step auto-link (Haldol allergy →
     "avoid Haldol" preference).
   - −11: net-new APIs (NLM Clinical Tables), schema, three PDF sections,
     larger forms.
2. **Review + Sign: two screens or one with tabs?** (Design = two.)
3. **Step 10 (Anything else): one big textarea + prompt seeds, or keep the
   existing structured sub-fields?** (Functional value of structure vs
   visual simplicity.)
4. **Net-new screens to actually build vs leave aspirational?** Crisis
   plan (P0), Facilitator mode (P0), Clinician view (P1), Plain ⇄ Legal
   toggle (P1), Ulysses clause (P1), Lock-screen Live Activity (P0),
   Accessibility settings, Snap-to-fill camera + AI extraction review,
   Verifier QR view, Agent invite acceptance, Renewal/Revocation flows,
   Settings groups (My directive / Reminders / About), Article reader.
5. **Web vs mobile parity for new flows** (snap-to-fill is a desktop drop
   zone + mobile camera button; the AI right-rail is web-only in the
   design).
6. **Default palette** on first launch: keep `teal` or switch to design's
   parked `navy`?

---

## O. Reference — design files this audit was built from

Bundle path (extracted from the gzipped tar returned by the Claude Design
handoff URL):

```
mhad/README.md
mhad/chats/chat1.md
mhad/chats/chat2.md
mhad/chats/chat3.md
mhad/project/Mental Health Advance Directive.html   # main canvas entry
mhad/project/Disclaimer Screen.html                 # standalone disclaimer
mhad/project/ds.jsx                                 # tokens + atoms
mhad/project/flow.jsx                               # 15 → 11 step diagram
mhad/project/mobile.jsx                             # core mobile screens
mhad/project/mobile-extra.jsx                       # 19 extra mobile screens
mhad/project/mobile-extra2.jsx                      # 6 OS-level / sign screens
mhad/project/health-steps.jsx                       # diagnoses · allergies · meds-v2
mhad/project/web.jsx                                # web screens
mhad/project/web-snapfill.jsx                       # desktop drop + mobile-browser snap
mhad/project/web-health-steps.jsx                   # web diagnoses / allergies / meds
mhad/project/gap-analysis.jsx                       # 8 gap-fill screens + analysis boards
mhad/project/browser-window.jsx                     # mac browser frame (canvas only)
mhad/project/ios-frame.jsx                          # iOS device frame (canvas only)
mhad/project/design-canvas.jsx                      # canvas chrome (canvas only)
mhad/project/tweaks-panel.jsx                       # palette/mode/density tweaks (canvas only)
```

The cover `BriefCard` mentions "9 wizard steps (was 15)" — that string is
stale; the canonical flow per `flow.jsx` and every wizard artboard is **11
steps**. Chat3 records the contradiction sweep that confirmed 11 as the
final model.
