# Submissions to Claude Design — MHAD Implementation Walkthrough

Generated from the decisions log at `docs/PROTOTYPE_DIFF_DECISIONS.md`
(companion to `docs/PROTOTYPE_DIFF_AUDIT.md`).

**Context for Claude Design:** the user (Onica5000) walked through every
prototype-vs-app delta in the audit and made 50 implementation decisions.
The 34 items below are points where the prototype's spec is silent,
inconsistent, contradicts an architectural constraint, or makes claims that
need clarification. They're grouped by theme to make iteration efficient.

**Critical context:**

1. **Wizard step model is 11 steps**, with a **user-overridden order** that
   differs from `flow.jsx`:
   `1 About you · 2 When this kicks in · 3 People I trust · 4 Guardian ·
    5 Where I want care · 6 Diagnoses (ICD-10) · 7 Medications (Current +
    Avoid only — NO Prefer) · 8 Allergies & reactions (ICD-10 + RxTerms) ·
    9 Procedures & research · 10 Anything else · 11 Review`.
   This reordering means the prototype's pre-fill auto-link from Allergies
   to Medications becomes a **backward nudge** (Severe allergy in step 8 →
   banner suggesting going back to step 7 to add to Avoid).
2. **The digital Sign & Witness screen is dropped entirely.** PA Act 194
   requires wet-ink signatures with two adult witnesses present (the app's
   own disclaimer says this). Step 11 = Review only. Wizard ends with
   *"Generate PDF"*. User prints, signs in ink, distributes. Drops:
   `execution_step.dart` signature pads, full-screen signature canvas,
   witness picker.
3. **Architectural constraint: NO REMOTE STORAGE OF ANY KIND.** The app is
   strictly local-first / anonymous. Every prototype feature implying a
   server, hosted URL, verified-link system, read-receipt, share-history
   backend, hosted-QR endpoint, or over-the-wire token exchange must be
   re-spec'd as local-only (QR-scan handoff between devices, system
   mail/SMS composers, signed local files transmitted manually). The
   privacy-policy URL (V4-C1) is the only HTTP endpoint hosted — it's a
   static page for Play/App Store compliance, not app data.
4. **Snap-to-fill is Option B** — OS image picker (camera + gallery),
   image goes directly to Gemini for OCR+extraction. The prototype's
   *"Photo stays on this device"* copy is no longer accurate and needs
   revising (item #34 covers all such microcopy).

---

## Submissions

### 1. Declaration-only and POA-only step counts in the 11-step model

The form-type screen's tag pills currently say *"Combined = 11 · Declaration = 6 · POA = 7"*. Combined = 11 checks out. **What is the canonical step list for Declaration-only and POA-only in the 11-step flow?** Specifically: which of steps 4 (Guardian), 5 (Care), 6 (Diagnoses), 7 (Medications), 8 (Allergies), 9 (Procedures), 10 (Anything else) are included/excluded for each form type? The current 6/7 totals don't have a clean derivation. We're rendering **Combined 11 / Declaration 9 / POA 6** provisionally — confirm or correct.

### 2. New step ordering changes the cross-step auto-link direction

User reordered to `6 Diagnoses → 7 Medications (Current + Avoid) → 8 Allergies & reactions`. This means the prototype's pre-fill auto-link (Haldol Severe in Allergies → "avoid Haldol" in Medications) is no longer possible because Allergies comes after Medications. **Please redesign the cross-step warning as a backward nudge** — when a user marks a substance Severe in step 8, a banner suggests they go back to step 7 to add it to Avoid. Show the surface treatment (banner / snackbar / modal) and exact wording.

### 3. Medications page without "Prefer"

User is dropping the prototype's "Prefer" Section B affordance — only "Current" (informational) and "Avoid" (binding) remain. **Please re-spec the Medications step layout for two sections instead of three** (Current + Avoid), keeping the AUTO-LINKED badge concept but reframed for the backward-nudge model in #2.

### 4. Allergies step with dual ICD-10 + RxTerms autocomplete

User wants the Allergies & reactions step to use **both** ICD-10 (for non-drug allergies and reaction status codes like Z88.x / T78.x) **and** RxTerms (for drug allergies), not just RxTerms as in the prototype. **Please re-spec the autocomplete UI** — single search field that returns mixed results with source tags, or two separate search fields, or a kind toggle (Drug / Food / Material / Other) that switches the data source? Show the dropdown row treatment with both sources.

### 5. Drop digital Sign & Witness — re-spec Review and Done

PA Act 194 requires wet-ink signatures with witnesses physically present. The digital Sign screen, full-screen signature canvas, and witness picker are being dropped. **Please re-spec:** (a) the Review screen as the *final* step (currently it has a "Continue to sign" button — what's the right last action? "Generate PDF" / "Print" / something else?); (b) the Done screen — currently it reads as if signing happened in-app ("Your directive is legally valid"); it should now read as "Your PDF is ready — print, sign in ink with two adult witnesses, then distribute."

### 6. "Help me choose" quiz — missing artboards

The prototype only shows question 2 of 4 (`ScrQuiz`). **Please provide:** (a) all 4 questions and their answer options, (b) the result/terminal screen after question 4, (c) the confidence-meter math (how does each answer move the dial?), (d) handling of *"I'm not sure yet"* — does it terminate, skip, or loop?

### 7. Step 6 (Diagnoses) layout — add a "Primary care doctor" sub-section

We're moving the preferred-doctor sub-section out of Step 2 and into Step 6 (Diagnoses), since Step 6 already shows diagnosis-provenance lines like *"Dr. Patel (UPMC)"*. **Please re-spec Step 6** to include a dedicated "Primary care doctor" sub-section (name + phone) — placement (above or below the diagnoses chip list?), label treatment, optional/required state.

### 8. Step 3 (People I Trust) — canonical PA-aligned "What can they decide?" questions

The prototype's `ScrWizardPeople` shows 5 ConsentRow rows but the wording may not be canonical PA Act 194 language. **Please confirm or re-spec** the canonical 5 (or N) authority-limitation questions under "What can they decide?", aligned to 20 Pa.C.S. § 5803–5805 authority enumerations. Each gets the Yes / No / Agent decides / If… ConsentRow.

### 9. Step 4 (Guardian) — "Someone different" expansion + Declaration handling

The prototype's `ScrWizardGuardian` shows 4 radio options including *"Someone different"* but never shows the inline name-field expansion when it's selected. **Please re-spec:** (a) the inline expansion treatment when *"Someone different"* is selected (field placement, label, optional sub-fields like relationship/phone); (b) whether Step 4 should be skipped entirely for Declaration-only form type; (c) any auto-link from agent changes back to this step (e.g. if the primary agent is removed, what happens to *"Same as my primary agent"* option?).

### 10. Step 5 (Care) — inclusive room-preference chip set

The prototype's `ScrWizardCare` includes the chip *"Female roommate only"* — a binary-gender phrasing. We want a more inclusive set. **Please re-spec the canonical room-preference chip set**, e.g. Single room · Window if possible · Quiet floor · Same-gender roommate · No roommate · Trans-affirming staff. Confirm the final list, any sub-chips (gender preference values when "Same-gender roommate" is selected?), and whether any are mutually exclusive.

### 11. Step 10 (Anything Else) — single textarea vs structured fields

The prototype's `ScrWizardElse` shows ONE big textarea + 6 prompt-row seeds. The app currently has 9 structured fields (activities, crisis intervention, dietary, religious, custody, family notification, records disclosure, pet custody, other). **Please clarify:** when a user taps a prompt row like *"Restraints & seclusion"*, does the prompt (a) insert a header (e.g. `Restraints & seclusion:`) into the single textarea, or (b) expand into a separate inline textarea (effectively reverting to structured fields)? Show the post-tap state of at least 2 prompts. Also confirm: should the PDF render this as one block or as labelled sub-sections?

### 12. Learn hub — mapping the app's content types into the card grid

The prototype's `MobileExtra · learn` shows 5 named article cards. The app has a rich content library: articles, glossary entries, FAQs, supplementary sections (Ch.54/Ch.58 bridge, advocate checklist, provider-duty "shall comply"), checklists. **Please re-spec the Learn hub** to handle all these content types: (a) does every type get its own card, or are some grouped behind a sub-screen?; (b) should there be category tabs above the grid (Articles · Glossary · FAQ · Checklists)?; (c) how does the featured/MOST READ card get chosen — manual curation or analytics?; (d) glossary entries are short — do they get a card style of their own (more compact / mono-styled)?

### 13. Article reader 🆕 — data model + 'Up next' curation

The prototype's `MobileExtra · article` is well-rendered but the underlying article data model is implicit. **Please confirm:** (a) per-article attribution string + avatar shape (e.g. *"FROM THE OFFICIAL BOOKLET"* + `P&A` avatar — is the avatar derived from the attribution, or set per article?); (b) when the *"TRY IT"* embedded CTA appears — every article, just featured, or per-article flag?; (c) "Up next" curation — next-in-category, editor-curated `related_ids`, or analytics-driven?; (d) reading-progress bar behavior on long vs short articles.

### 14. AI consistency warning 🆕 — canonical rule set + trigger + surface

The prototype's `MobileExtra2 · conflict` shows the warning surface but its rule set, trigger, and routing are implicit. **Please specify:** (a) canonical rule set — list of cross-step contradictions checked (the prototype shows ECT/agent-authority and avoid-UPMC/UPMC-therapist; what else?); (b) trigger model (on every save? only when entering Review? on a manual "Check my answers" button?); (c) surface (separate route accessed how? embedded in Review step? overlay before "Generate PDF"?); (d) what happens to unresolved conflicts — block PDF generation or just surface a warning?

### 15. FHIR R4 export + Apple/Google Wallet pass specs

The Export hub shows `.xml` for HL7 FHIR R4 (*"Consent + RelatedPerson + Practitioner"*) and `.pkpass` for Wallet. **Please specify:** (a) FHIR profile — exact resource types, US Core / PA-specific profiles, IG (implementation guide), and a sample serialization for an MHAD directive; (b) Apple Wallet `.pkpass` content + signing pipeline (Pass.json manifest, what info appears on front/back, QR contents); (c) Android Google Wallet equivalent — Google Pay Pass class + sample JSON or alternative format (`.gpay` link?).

### 16. Optional export encryption — canonical surface

The Export hub shows a primaryTint callout *"Optional: encrypt the export with a password."* but the technical implementation isn't specified. The current `pdf` package doesn't support PDF encryption (V4-M8). **Please specify:** (a) which format(s) are encrypted (just PDF? all of them? the bundled .zip?); (b) implementation approach — native PDF encryption library swap, AES-encrypted .zip wrapper, or other; (c) password capture UX (where the user enters it, password-strength meter, recipient instructions).

### 17. In-app Share Sheet + Wallet QR verifier — re-spec for **NO REMOTE STORAGE** architecture

**User architectural commitment: no server / no remote storage of any kind across the entire app.** The prototype's `MobileExtra · share` AND `MobileExtra · verify` both require server infrastructure (verified links with one-time codes / 7-day expiry / read-receipt requests on share; `qr.mhad.pa.gov`-hosted endpoint on the verifier QR). **Please re-spec both surfaces with strict local-only primitives:** (1) Share Sheet — drop verified-link / one-time-code / expiry / read-receipt features entirely. Wire system Email / SMS composers, QR-of-PDF, Print. *"From your contacts"* row must be ephemeral in public/web mode. (2) Wallet QR + verifier view — replace server-hosted QR with inline-encoded JSON payload (name, primary agent + phone, expiry, top 5 treatment flags, cryptographically signed). Verifier view should render the same whether scanned in-app or via a generic QR app (the QR's JSON payload must be human-readable enough to inform a paramedic even without the app installed). Drop the `qr.mhad.pa.gov` URL header — there is no such URL.

### 18. Settings — full spec for all four groups + Appearance reconciliation

The prototype's `MobileExtra · settings` shows four groups (My directive · Data & privacy · Reminders · About) plus a primary profile chip. The prototype omits Appearance (color theme / brightness) because its design canvas has a global Tweaks toolbar — end-users have no such toolbar. **Please re-spec:** (a) Where does Appearance (palette + brightness) live? Add as a 5th group, fold into Data & privacy, or somewhere else?; (b) For each Settings row, the destination behavior: "View current directive" = where? "Renew or replace" = clone the existing directive into a new draft with values pre-filled? "Past directives" = what list view? "Revoke directive" = full revocation flow per `MobileExtra · revoke`?; (c) "Reminders" group — does the app schedule local notifications (require `flutter_local_notifications`), or rely on calendar event creation, or some other mechanism?; (d) "Auto-lock after" — what are the canonical interval options (1/5/10/30 min, "Never")?; (e) "Export my data" — does this go to the Export hub (§ H.1) or a separate Data Export Hub (§ J row 27a)?

### 19. Accessibility settings 🆕 — phased rollout + technical specs

The prototype's `GapScreens · a11y` enumerates 8 toggles + 1 slider + 1 segmented language picker. Several have non-trivial implementation deps. **Please confirm a phased rollout + technical specs:** (a) Switch Control toggle — does it just inform the user that OS Switch Control works, or does it activate an in-app focus-ring style?; (b) Hearing aid pairing — opens OS Settings link or has in-app MFi/Bluetooth UI?; (c) Read aloud — every section, every screen, or just article body? Which TTS provider?; (d) Language picker — Spanish + Chinese + Arabic; Arabic implies RTL layout throughout (significant). Confirm priority order and acceptable phase-2 deferrals; (e) High contrast — is this a new palette variant or a separate token set?; (f) Dyslexia-friendly font — confirm Atkinson Hyperlegible bundling at runtime swap.

### 20. First-time empty home — updated copy + 11-step time estimates + pre-name greeting

The prototype's `MobileExtra · empty` says *"Nine steps, plain language"* (stale — we're at 11) and has 3 time-estimate rows totaling ~15 min. **Please re-spec:** (a) updated step-count copy + total-time math for 11 steps; (b) updated 3-row time-estimate breakdown (which steps go into each row); (c) greeting copy when the user's name isn't known yet (pre step 1) — *"Welcome."* / *"Let's get started."* / something else?; (d) *"Hi, {name}."* treatment for visits after step 1 is filled.

### 21. Public-mode home — verify 4 privacy-promise claims

The prototype's `MobileExtra · public` makes 4 green-check claims: (1) Nothing saved to disk, (2) No analytics, no tracking, (3) Wipes on lock / close / 5 min idle, (4) AI assistant is off by default. **Please confirm each claim matches what the app actually does.** Particular concern: the "5 min idle wipe" — if the app doesn't currently implement this, either (a) implement an idle-wipe timer in public mode, or (b) revise the claim to remove "5 min idle" (e.g. *"Wipes on lock / close"*). Update the surface copy accordingly.

### 22. Voice input — canonical privacy posture + on-device claim

The prototype's `MobileExtra · voice` shows `● Recording · on device` and footer `ON-DEVICE TRANSCRIPTION · NEVER SENT`. Platform reality: iOS Speech framework can be on-device for some languages (en-US since iOS 13) but defaults vary; Android requires pre-downloaded offline models. **Please confirm:** (a) is on-device-only required, or is cloud STT acceptable with honest disclosure?; (b) if on-device-only — feature-gate to supported platforms/languages, with disabled state copy when unsupported; (c) if cloud-allowed — revise footer to *"Speech-to-text uses [Apple / Google] services"* + optional *"Prefer on-device"* toggle; (d) confirm STT consent flow — does it need its own consent gate or fold under the existing AI consent?

### 23. Contact picker eligibility rules + provider detection

The prototype's `MobileExtra · contacts` shows per-row eligibility states (Eligible / Ineligible · your healthcare provider). Contacts API doesn't carry "is healthcare provider" — only birthday (for 18+) and the standard fields. **Please re-spec:** (a) the canonical eligibility rule set (PA Act 194 disqualifications); (b) provider-detection approach — pattern match on *"Dr."* prefix (unreliable), or a user-maintained "my providers" list, or a soft warning on every selection?; (c) hard-block vs soft-warn for each rule; (d) what happens when a row is dimmed/ineligible — completely unselectable or selectable with confirmation?

### 24. Past directive detail — scope + share-log persistence model

The prototype's `MobileExtra · past` shows a *"Who had a copy"* section that requires a new `share_log` table (who/when/method per recipient). This introduces a privacy concern in **public mode** where nothing should persist. **Please re-spec:** (a) scope of the share-history section (which recipients are tracked? agent + providers + family + arbitrary email/text?); (b) public-mode behavior (no share history, or session-only ephemeral history?); (c) GDPR/state-law concerns around storing recipient PII even in private mode; (d) edit/redact controls on share-history rows.

### 25. Renewal nudge + quarterly check-in — two distinct surfaces

The prototype's `MobileExtra · renew` shows ONE surface conflating expiration-renewal and check-in nudges. Per user spec, we need **two surfaces**: (1) **Hard renewal nudge** near 2-year expiration — emphasizes legal deadline, offers Quick Renew (clone the existing directive into a new draft, all values pre-filled, then re-print + wet-ink sign). (2) **Soft quarterly check-in** every 3 months — emphasizes *"Anything changed?"*, offers Quick Review without renewing; user can confirm-and-dismiss or jump to specific steps to edit. **Please re-spec both:** copy + visual differentiation, lead-time (28 days before expiry? 7 days?), interaction with each other (does the quarterly check-in still fire during the last 3 months before expiration, or yield to the hard renewal?), the 11-step time math, and notification scheduling mechanism. Hard renewal copy also needs to drop the prototype's *"re-sign with your witnesses"* language — per § C-extra, signing is wet-ink-only and happens on paper after printing.

### 26. Revocation flow — expanded scope: canonical wording, revocation PDF, two provider lists

The prototype's `MobileExtra · revoke` shows the visual but per user spec we need: (a) **canonical revocation wording** per PA Act 194 § 5803 — what's the legally-required statement of revocation, and what's the minimum content of the printed revocation document?; (b) a **revocation PDF template** (distinct from the directive PDF); (c) confirmation that auto-notify is **explicit-opt-in only** per recipient (no batch sends without per-row OK); (d) **two provider lists** to populate the Notify section — specific list (providers named in the directive + providers stored in the app's address book if it has one) AND a generic suggestion list (categories of providers/hospitals to consider informing — psychiatrist, PCP, ER of nearest hospital, etc.); (e) email path that opens system mail composer with the revocation PDF attached + canonical revocation body text.

### 27. Crisis plan / WRAP toolbox — canonical placement + step model reconciliation

The prototype's `GapScreens · crisisplan` shows StepDots `5 of 10`, which doesn't reconcile with the 11-step wizard model already settled. **Please re-spec:** (a) placement — 12th wizard step (after Step 10, before Review), standalone optional add-on (reachable from Step 10 / Home / Settings → My directive), or something else?; (b) if standalone, what surfaces it (a Tools tile on Home + a *"Want to add a crisis plan?"* link in Step 10 + a Settings row)?; (c) PDF rendering — as a Supplementary section, or its own dedicated sheet attached to the directive?; (d) whether the Crisis Plan content is included in the wallet-card QR payload's top-5 treatment flags; (e) the canonical 5 section icon set and final chip-suggestion seed lists per section (the prototype's example chips are personal — what are the generic seed examples)?

### 28. Facilitator mode — rework pathways for no-remote-storage + canonical PA referral list

The prototype's `GapScreens · facilitator` shows 3 pathways: (1) Book a peer specialist — implies booking infra; (2) Real-time co-edit with a friend — requires a server (incompatible with no-remote-storage); (3) Send draft to clinician for comments — requires server-mediated comment-return. **Please re-spec under the no-server constraint:** (a) Pathway 1 — referral-only with phone/website list (which PA partners — P&A, MHCA, MHA-PA, NRC-PAD)?; (b) Pathway 2 — drop entirely or reframe to *"Print + review with someone in person"*?; (c) Pathway 3 — *"Email draft to clinician; manually transcribe comments back"* works locally; confirm copy/visual; (d) the 20× completion statistic source citation; (e) what the CTA *"Send invite →"* / *"Send draft →"* buttons do precisely (system mail composer? in-app email template generator?).

### 29. Clinician view + Wallet QR verifier — unified spec under no-server constraint

The prototype's `GapScreens · clinician` (30-second summary for doctors) and `MobileExtra · verify` (paramedic view scanned from wallet QR) appear to be the same screen with different framings. **Please collapse into a single unified spec:** (a) one screen, one component, parameterized by audience (paramedic vs clinician) if differences are needed; (b) drop the audit-trail footer (*"ACCESSED … LOGGED TO PATIENT AUDIT TRAIL"*) — impossible without a server; (c) entry points — scan QR from wallet card AND the patient's own *"Show this to my clinician"* button on Home; (d) action-row buttons (*"Full PDF"* / *"Legal text"* / *"Call agent"*) — confirm scope and behavior in handoff vs scan contexts; (e) the dark-themed surface treatment is the same in both contexts.

### 30. Plain ⇄ Legal toggle — template + attorney review

The prototype's `GapScreens · legaltoggle` claims *"Both versions are legally identical."* For this to be true, the Legal-language rendering must be PA-Act-194-attorney-reviewed. **Please confirm:** (a) the Legal template structure (one per form type? per section?); (b) the attorney-review pathway (who reviews? when in the release cycle? PA-licensed bar requirement?); (c) what happens to the toggle while Legal mode is *"Draft — not yet attorney-reviewed"* — disabled / warn-bannered / hidden?; (d) does the Legal mode in-app render exactly match the signed PDF, or is it a simplified read view?

### 31. Self-binding (Ulysses) clause — placement + canonical PA § 5802-5805 wording

The prototype's `GapScreens · ulysses` shows the clause with 5 boundary checkboxes and StepDots `8 of 10` (stale). **Please re-spec:** (a) placement reconciling with the 11-step model — 12th step, standalone optional add-on, or something else?; (b) canonical PA-statutory wording for the clause text rendered in the PDF; (c) confirm the 5 listed boundaries match what PA §§ 5802-5805 permit; (d) interaction with facilitator mode (strongly recommend the toggle is gated behind a confirmation modal pointing users to facilitator pathways); (e) what the PDF renders when the toggle is OFF vs ON.

### 32. Agent acceptance receipt — schema + telemetry scope

The prototype's `GapScreens · agentaccept` is the other side of J.invite (local-only QR-scan handoff). Receipt-PDF schema must be canonical so the agent's app and principal's app interoperate. **Please re-spec:** (a) receipt-PDF JSON + PDF schema; (b) which telemetry fields are honestly captured by the agent's app under no-server architecture — dwell-time tracking, Face ID match boolean, checkbox state, drawn signature SVG, accepted-at timestamp + timezone — drop any that can't be locally captured; (c) updated copy for the 11-step model (*"11 sections"* not *"9 sections"*); (d) the agent-side *"How to use this directive"* one-page guide content.

### 33. Web-app surfaces — canonical responsive breakpoints + mobile-vs-desktop divergence

The web build straddles desktop (≥1000 px sidebar layout) and mobile-browser (iOS Safari URL bar + tap targets). Several prototype web artboards parallel mobile artboards with different chrome. **Please confirm:** (a) the canonical responsive breakpoint(s) where mobile-web vs desktop-web layouts fork (single 1000 px, or multiple including tablet?); (b) for K.4 (snap/upload desktop) — webcam dropped per user; confirm the remaining inputs (drag-drop + Browse files + ⌘V paste) plus the in-session file list visual when empty / 1-file / N-files; (c) for K.7 (wizard 3-pane with right-rail AI) — does the right rail collapse to a bottom sheet on mobile-web, hide entirely, or persist as an icon-only column?; (d) for K.5 (mobile-browser snap to fill) — confirm the iOS Safari URL-bar mock should also appear on Android Chrome (which has different chrome) — is this iOS-only?; (e) for K.8 (*"THIS TAB ONLY"* pill + *"Download draft"*) — confirm placement on tablet/desktop variants.

### 34. Microcopy table — verify against no-remote-storage + Option B image extraction

The audit's canonical microcopy table includes several strings that conflict with decisions made in this log. **Please re-confirm each string is honest:** (a) Smart Fill privacy footnote — drop *"Photo stays on this device"* (false under Option B); confirm honest replacement; (b) Public-mode home's 4 privacy promises (item #21); (c) any *"ON-DEVICE"* / *"NEVER SENT"* labels on voice (item #22) and snap; (d) *"verified link"* / *"expires in N days"* / *"read-receipt"* copy on share + agent invite (no server); (e) Welcome footer *"no tracking"* claim — verify against the app's analytics posture (the disclaimer says *"not HIPAA-compliant"* but doesn't explicitly say *"no analytics"*); (f) the pull-quote attribution — confirm OMHSAS booklet citation is current.

---

## Build status by item (for reference)

| Status | Count | Notes |
|---|---|---|
| ✅ Decided — implement | 18 | Net-new build, defined |
| ⏸ Awaiting Claude Design | 24 | Listed above (some items cover multiple screens) |
| ⛔ Explicitly dropped | 1 | Lock-screen Live Activity (J.lockcard) |
| 🛡 Kept against prototype | 14 | All in M (functional protections) |

Total surfaces touched in the audit: 50+. Total decisions recorded: 50.
