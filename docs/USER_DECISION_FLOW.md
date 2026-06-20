# MHAD — User-Facing Decision Flow (web focus)

A trace of **every user-facing decision point** from launch to finish, built from
the router gates (`lib/ui/router.dart`) and the navigation edges across `lib/ui/`.
Below the diagram: **dead ends, duplications, and contradictions** found.
Items marked **(verified)** were confirmed in code; **(candidate)** need a closer
look.

> Rendered as Mermaid — view on GitHub or any Mermaid viewer.

```mermaid
flowchart TD
  Launch([App launch]) --> Gate1{Disclaimer accepted?}
  Gate1 -- no --> Disc[Disclaimer gate\ncheck '18+ & understand']
  Disc -- accept --> Gate2
  Disc -. no decline path .-> Disc
  Gate1 -- yes --> Gate2{Privacy mode selected?}
  Gate2 -- "web" --> AutoPub[[auto: Public mode]] --> Gate3
  Gate2 -- "native: choose" --> Mode{Public or Private?}
  Mode -- Public --> Gate3
  Mode -- Private --> Auth[Biometric / PIN] --> Gate3
  Gate3{Onboarding done?}
  Gate3 -- no --> Onb["'In your words' intro"]
  Onb --> OnbC{Choose}
  OnbC -- "Start fresh" --> Home
  OnbC -- "Upload a document to autofill" --> NewDir1[(create directive)] --> Upload
  OnbC -- "988" --> Crisis
  Gate3 -- yes --> Home

  %% ---------- HOME ----------
  Home{{Home / dashboard}}
  Home -- "empty: pick form" --> FormChoice{Combined / Declaration / POA}
  Home -- "Help me choose" --> Quiz[4-question quiz] --> FormChoice
  Home -- "Print the blank form" --> FormChoice
  FormChoice --> NewDir2[(create directive)] --> Wizard
  Home -- "returning: open draft" --> Wizard
  Home -- "past directive" --> Past{Open / Delete / Revoke / Renew}
  Past -- Revoke --> Revoke[Type REVOKE to confirm]
  Past -- Open --> PastDetail[Past directive detail] --> ExportOrShare
  Home -- Tools --> ToolPick{AI / Learn / Print}
  ToolPick -- AI --> Assistant
  ToolPick -- Learn --> Education

  %% ---------- WIZARD ----------
  subgraph Wizard[Wizard - steps depend on FormType]
    direction TD
    %% Canonical order (Combined 11 / Declaration 9 / POA 6). Agent + guardian
    %% steps are POA/Combined only; ECT/experimental/drug-trials are one merged
    %% ConsentChoiceStep ("Procedures & research"). See FormType.steps.
    W1[About you / personal info] --> W2[When this kicks in\neffective condition: 3 triggers + free text]
    W2 --> W3[People I trust / Agent\nprimary + alternate + agent authority · POA & Combined]
    W3 --> W4[If a court appoints a guardian\nnomination + 3 condition toggles · POA & Combined]
    W4 --> W5[Where I want care\nfacility prefer/avoid/none + roommate]
    W5 --> W6[Diagnoses\nICD-10 search + primary doctor]
    W6 --> W7[Medications\npreferred/avoid/limitations/current + side-effects add-on]
    W7 --> W8[Allergies & reactions]
    W8 --> W9[Procedures & research\nconsent: ECT / experimental / drug-trials -- one ConsentChoiceStep]
    W9 --> W10[Anything else\nadditional-instruction fields]
    W10 --> AddOns{Optional add-ons}
    AddOns -- Crisis plan/WRAP --> CrisisPlan
    AddOns -- Ulysses clause --> Ulysses
    AddOns -- Side effects --> SideFx[AI side-effects checklist]
    W12 --> Wreview[Review & sign\ntap any section to edit]
  end
  Wizard -- "AI Suggest / Ask" --> AiGate{AI key set up?}
  AiGate -- no --> AiSetup
  Wizard -- "Snap your ID / autofill" --> Upload

  Wreview --> Sign[Execution: print + sign\non paper + 2 witnesses]
  Sign -- "Preview signing packet" --> Export
  Sign -- "Continue to summary" --> Complete{{Wizard complete / summary}}
  Complete -- Share --> ShareSheet
  Complete -- Export --> Export
  Complete -- Wallet card --> Wallet[Generate wallet card]
  Complete -- "Done — back to home" --> Home

  %% ---------- PIPELINE ----------
  subgraph Upload[Upload / Snap-to-fill pipeline]
    direction TD
    UAi{AI set up?} -- no --> USetup[Set up AI banner/CTA]
    UAi -- yes --> Pick[Pick: drop / browse / webcam / paste]
    Pick --> Extract[AI extract] --> ReviewP[Review: check / edit / discard per field]
    ReviewP -- "Add N fields" --> ApplyP[(apply to directive)]
    ReviewP -- "Add another" --> Pick
    ApplyP --> Wizard
    ReviewP -- "Skip / type by hand" --> Wizard
  end
  USetup --> AiSetup[AI setup] -. return .-> Upload

  %% ---------- EXPORT ----------
  subgraph Export[Export]
    direction TD
    E0[Select form + include sections] --> Eact{Action}
    Eact -- PDF --> Epdf[Preview / download / print]
    Eact -- "FHIR / CSV / .zip" --> Edata[Machine-readable]
    Eact -- "Encrypt / Unlock" --> Eenc[Password bundle - view only]
    Eact -- Share --> ShareSheet
    Eact -- NFC --> Enfc[Write tag]
    Eact -- "Back to edit" --> Wizard
  end

  %% ---------- SECONDARY / GLOBAL ----------
  Settings{{Settings}}
  Settings --> S1[Theme mode] & S2[AI setup] & S3[Accessibility] & S4[Legal toggle] & S5[AI consistency check] & S6[Facilitator] & S7[Permissions] & S8[Privacy policy] & S9[[hidden: Admin - long-press About]]
  S8 --> Disc2[Read full disclaimer]
  GlobalNav[/Bottom nav / Sidebar/] --> Home & Education & Assistant & Settings & Export & Upload
  Crisis[Crisis sheet\n988 / text / SAMHSA / P&A / Veterans / Trevor / 911]
  Education[Learn: articles / FAQ / glossary]
  Assistant[AI assistant chat\n+ Verify on the web]
```

---

## Resolution status (2026-06-15)

All findings below were addressed. Summary:

| ID | Status | Resolution |
|----|--------|-----------|
| D1 | ✅ Fixed | "Done — back to home" added to the summary (`wizard_complete_screen.dart`, `go` resets the stack) |
| D2 | ✓ By design | Gate already makes acceptance explicit (disabled CTA + ack wording); forced-accept is correct for a legal gate |
| D3 | ✅ Mitigated | Web `beforeunload` unsaved-work guard while the wizard is open (`utils/unsaved_guard*`); full fix is the parked portable-file work |
| D4 | ✓ Verified | Settings hides directive actions with no directive (`_CurrentDirectiveSection` → `shrink()`); add-ons live in the wizard — no dead-end |
| U1/U4/U5 | ✓ Intentional | Many entry points to export/AI-setup/education/crisis are deliberate convenience/safety redundancy |
| U2 | ✓ Verified | Form-type quiz + cards both route through the same `_start` — can't disagree |
| U3 | ✅ Fixed | Sidebar door relabeled "Autofill from a document" (distinct from the planned "Continue from a saved file") |
| C1 | ✅ Fixed | Onboarding "Stays on your device" → "Nothing is saved" on web (`kIsWeb`); privacy policy already Public/Private-mode-aware |
| C2/C3 | ✓ Verified | Post-sign uses `go` for forward progress, `push` for side-trips; stack depth ~2 — no deep-stack issue |
| C4 | ⏳ In build | "Two editors" is handled by the pipeline reconciliation work (diff-against-existing + guaranteed final review) |

Detailed analysis (as originally found) below.

---

## Findings

### Dead ends
- **D1 (verified) — Wizard-complete "summary" has no explicit *Done → Home* CTA.** It offers Share / Export / Wallet only (`wizard_complete_screen.dart:235-303`); the user leaves via the global nav or device back. On the pushed route with no bottom-nav context this can feel terminal. *Fix:* add a clear "Done" / "Back to home" action.
- **D2 (verified, by-design) — Disclaimer gate has no decline/exit.** `router.dart` forces `/disclaimer` until accepted; on web there's no app to exit to. Acceptable for a legal gate, but it's a no-alternative decision worth stating explicitly ("you must accept to use the app").
- **D3 (verified, web) — Reloading `/wizard/:id` or `/upload/:id` on web orphans the in-memory directive.** No persistence on web (see standalone-snapfill note) → a refresh mid-flow silently loses work. This is the exact gap the portable-file work is meant to close.
- **D4 (candidate) — Add-on / settings-reached sub-screens may dead-end without a directive.** `side-effects`, `ulysses`, `crisis-plan`, `ai-check` take a `:directiveId`. Reached from the wizard they're fine; if reached from Settings → "My directive" against a missing/empty directive, confirm they don't land on an empty/stuck state.

### Duplications
- **U1 — Export is reachable from 6 places** (execution, wizard-complete, home, sidebar, past-detail, wizard back). Convenient, but it means "what happens after I sign?" has several overlapping doors.
- **U2 — Form-type decision exists in two UIs:** the home `DirectiveFormChoice` cards **and** the `form_type_quiz`. Same decision, two surfaces — ensure the quiz result and the cards can't leave the app in conflicting form-type state.
- **U3 — Two (soon three) "bring your info" doors:** onboarding "Upload a document to autofill" and the sidebar "Upload to autofill" both → `/upload`; the planned "Continue from a saved file" adds a third. This is the IA-confusion risk already flagged — they must be labeled distinctly.
- **U4 — AI-setup reachable from 6 places** and **Education from 6 places** (assistant, settings, side-effects, pipeline, ai-suggest, sidebar / home, web-landing, wizard-help, bottom-nav). Expected for utility destinations; listed for completeness.
- **U5 — Crisis access is duplicated across 5 surfaces** (disclaimer pill, onboarding pill, crisis top-bar, sidebar card, in-sheet). Intentional safety redundancy — keep, but it *is* duplication.

### Contradictions / smells
- **C1 (verified-OK, watch) — Web forces Public mode** (`router.dart` auto-`setPublicMode` on web) while the app's value language leans on "Private / on-device." Settings correctly gates private-only sections by `isPrivate`/platform, so there's no *navigational* contradiction — but the **copy** must never imply private storage on web (governed by the legal-wording-canon). Keep auditing copy.
- **C2 (verified, minor) — Post-sign has two "next" affordances:** "Preview signing packet" (→ Export) and "Continue to summary" (→ Complete). Not contradictory (distinct intents), but a user can ping-pong Export ⇄ Complete ⇄ Export via push, deepening the back-stack.
- **C3 (candidate) — Push-stack depth after signing.** Execution → (push) Export, and Complete → (push) Export/Share. Reaching Export from Complete which was reached from Execution stacks three pushed routes; "back" then walks back through them. Consider `go` (replace) instead of `push` for the post-sign hub.
- **C4 (active build) — Two editors for the same fields:** the new pipeline reconciliation and the wizard both write the same directive fields. The reconciliation must diff against current state (not blind-write) and the guaranteed final wizard review must reflect pipeline-applied values — exactly the model being built.
