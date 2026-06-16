# MHAD — Deduplication Plan (post-wizard surfaces) — 2026-06-15

Read-only audit of duplicated functions/logic, focused on the wizard + export/
share/sign/past/revocation surfaces. **Awaiting approval before any changes.**

## Findings (confirmed against source)
1. **Directive-bundle load repeated inline** — the same directive→agents→prefs→additional→guardian→meds→diagnoses→witnesses read is hand-written in `export_screen.dart:85-130`, `review_step.dart:101-127`, `wizard_complete_screen.dart:42-55`, and every consent step.
2. **"Best phone" picker — 3-4 impls** — `pdf_helpers.pickPhone:106`, `wallet_card_generator._bestPhone:155`, `wizard_complete_screen._agentPhone:102`, `export_screen._agentPhoneFor:408` (this one **trims**, others don't → behavioral drift).
3. **Primary/alternate agent lookup — ~11 sites** — `agents.where(agentType==…).firstOrNull` across pdf_helpers, the 3 PDF builders, wallet, complete, review, agent steps, plain-legal-toggle, export.
4. **Wallet-card generate+share** — identical runInBackground→generate→sharePdf block in `wizard_complete_screen:61-86` and `export_screen:448-479`.
5. **Output field-mapping repeated 4×** — same field lists (agents/meds/diagnoses/10 instruction fields/consent) walked in FHIR-JSON, CSV, FHIR-XML (`export_formats_service:35-97,166-257`), and snapshot (`directive_repository:294-390`).
6. **Consent wizard steps near-identical** — `ect_step`, `experimental_studies_step`, `drug_trials_step` are ~195 lines each of the same scaffold; only the pref column + copy differ.
7. **Date formatting fragmented** — ~6 formats, no shared formatter.
8. **FormType→label drift** — `FormTypeExt.displayName:38` is canon, but 5 places re-map with **drifted wording** ("Combined Declaration & " vs "and" vs "Combined form" vs "Combined directive"): `pdf_generator:153`, `gemini_api_assistant:692`, `assistant_screen:488,1027`, `export_screen:2237`.
9. **UI subtrees** — dashed-divider painter verbatim in `past_directive_detail:463-483` + `share_sheet:566-586`; status pill near-identical in `past`/`revocation`; numbered-step row near-identical in `execution_step._SignStep` + `revocation_screen._RevokeStep`; DirectiveStatus→label/color inline chains scattered.

*Already good (no action):* consent value parsing is centralized; shared widgets live under `lib/ui/widgets/design/`; no duplicated expiry computation exists.

## Proposed actions (ordered: safest + highest-value first)
**Group A — Agent & domain helpers (low risk)**
1. `AgentListX` extension (`primaryAgent`/`alternateAgent`/`agentByType`) — replace ~11 lookup sites.
2. `Agent.bestPhone` extension (cell→home→work, **with .trim()**) — replace the 3-4 phone pickers. *(Confirm: trim everywhere is desired.)*

**Group B — FormType label (fixes real drift)**
3. Route all labels through `FormTypeExt`; delete `pdf_generator._formTypeLabel` + the gemini map; add a `shortName` getter for the intentionally-short contexts. *(Confirm: are the short variants intentional?)*

**Group C — Bundle loading (high value, medium risk)**
4. `DirectiveBundle` model + `DirectiveRepository.loadBundle(id)`; migrate export/review/complete (optionally pass the bundle into PDF/CSV/FHIR so they stop taking 8 args). One screen at a time + build/test after each.

**Group D — Output field-mapping (high value, medium risk)**
5. Extract one ordered instructions field list + a medication-category helper, consumed by FHIR-JSON/XML, CSV, snapshot. Verify byte-for-byte export parity after.

**Group E — Wallet card (low risk)**
6. `WalletCardService.generateAndShare(directive, agents)` — call from both screens.

**Group F — UI subtrees (low risk)**
7. `DashedDivider` widget. 8. `StatusPill` + `directiveStatusLabel/Color`. 9. `NumberedStep` widget.

**Group G — Consent steps (medium risk, biggest line-count win)**
10. `ConsentChoiceStep` shared base parameterized by (labels/copy + pref column read/write); collapse ect/experimental/drug-trials to thin configs. Careful save/restore testing per column.

**Group H — Dates (low value, deferable)**
11. Optional shared `DirectiveDates` display formatter.

## Decisions needed before starting
- Item 2: confirm trimming phone whitespace everywhere is correct.
- Item 3: are the short FormType labels (assistant/export) intentional or accidental forks?
- Items 4, 5, 10 are highest-value but touch live export/EHR/wizard paths → do one file at a time with build + targeted test after each. Items 1, 6, 7, 8, 9 are safe mechanical wins for quick momentum.
