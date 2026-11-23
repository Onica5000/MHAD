# CLAUDE.md — MHAD Flutter Project

## Project
Pennsylvania Mental Health Advance Directive app — Flutter/Dart.

**Primary target (2026-06-16 pivot): the Chrome/Edge WEB app — responsive for both PC and
mobile browsers. This is the ONLY actively-developed surface.**

**Only the web app exists.** Native mobile (Android + iOS) and desktop (macOS) are POSTPONED
INDEFINITELY and may never ship (user, 2026-11-23) — **no user-facing text may suggest another app
or a feature "coming" later** (`only_web_copy_test`). Do not
spend effort on Android/iOS-specific behavior, and never let native concerns compromise the
PC/Mobile web app's functionality — web is what ships. When a feature is mobile-only by
nature (camera/gallery, NFC, biometrics, notifications), it stays gracefully degraded/absent
on web and is fine to leave unfinished for native. The `android/`, `ios/`, and `macos/`
folders, their plugins, and `codemagic.yaml`'s native jobs **stay in the tree** (do not
remove without confirmation) — they're just not a development priority. Windows desktop
remains buildable but is secondary to web.

When implementing screens, assume Material 3 + a responsive web layout. Lean toward
Material affordances (`Scaffold`, `FilledButton`, `MaterialPageRoute`) and avoid
`Cupertino*` widgets — keep the codebase Cupertino-free.

The shipped UI/UX is the source of truth: the **2026-11 design system** (see *Design
system* below) — extend it, don't fork it. The old Claude Design artboard/handoff bundle
was removed 2026-06-28; do not reintroduce it or design against it.

Source PDF: `docs/PA MHAD.pdf`. Improvement backlog: `docs/GAP_ANALYSIS_V4.md`.

## Flutter / Dart
- Flutter 3.47.9, Dart 3.13.7 (CI pins the same version in `deploy-web.yml`; keep local and CI in step)
- Run with: `D:\flutter\bin\flutter.bat run`
- **Ship target (web — what actually deploys):** `D:\flutter\bin\flutter.bat build web --release`
  (CI uses `--pwa-strategy=none --source-maps --base-href "/MHAD/"`; auto-deploys to GitHub Pages on push to `main`).
- Build debug APK (native, deferred): `D:\flutter\bin\flutter.bat build apk`
- Build release APK (native, deferred): `D:\flutter\bin\flutter.bat build apk --release --obfuscate --split-debug-info=build/debug-info`
- Code gen: `D:\flutter\bin\flutter.bat pub run build_runner build --delete-conflicting-outputs`

## Architecture
```
lib/
  data/
    database/     -- Drift tables + generated code (app_database.dart + app_database.g.dart)
    repository/   -- DirectiveRepository
  domain/
    model/        -- directive.dart (enums, extensions)
  ai/
    ai_assistant.dart          -- Abstract interface
    ai_provider.dart           -- AiProvider enum (the multi-provider source of truth)
    llm_client.dart            -- Provider-agnostic transport (Gemini/Claude/OpenAI/Grok)
    gemini_api_assistant.dart   -- LlmAssistant (typedef GeminiApiAssistant); chat + helpers
    document_extractor.dart / smart_fill_service.dart -- multimodal autofill / smart-fill
    handoff/                   -- copy-and-paste handoff (what users see): task, prompt, parser, wait
  ui/
    theme/        -- app_theme.dart (DesignTokens + MhadPalette; navy by default, Material 3)
    home/         -- HomeScreen
    wizard/       -- Step-by-step form flow (adaptive per FormType)
    education/    -- FAQ, instructions, glossary
    getting_ready/ -- Getting ready checklist (+ PDF)
    audio_guide/  -- voice questionnaire (+ PDF)
    ai/           -- handoff card, Ask AI page, step helper, "Back to paste" banner
    assistant/    -- AI chat UI (API path — hidden)
    export/       -- PDF preview & export options
    router.dart   -- GoRouter config + AppRoutes constants
  main.dart       -- ProviderScope + MaterialApp.router
```

## Key Packages
- **State**: flutter_riverpod 3 (hand-written providers; `StateProvider`/`StateNotifierProvider`/`ChangeNotifierProvider` come from `package:flutter_riverpod/legacy.dart`). Auto-retry is disabled at the root `ProviderScope` (`retry: (_, _) => null`).
- **Database**: drift + sqlcipher_flutter_libs (encrypted SQLite; code gen — run build_runner after schema changes)
- **Navigation**: go_router
- **AI**: multi-provider (BYO key) via `LlmClient` — Google Gemini (default, `google_generative_ai`), Anthropic Claude, OpenAI, xAI Grok (REST)
- **PDF**: pdf + printing (pixel-perfect PDF generation)
- **Signature**: signature
- **Secure storage**: flutter_secure_storage (per-provider AI API keys)

## After Any Database Schema Change
Run: `flutter pub run build_runner build --delete-conflicting-outputs`
This regenerates `app_database.g.dart`.

## Form Types & Wizard Steps
- COMBINED: all steps including agent designation, alternate agent, agent authority
- DECLARATION: no agent sections (guardian nomination included — official form part E)
- POA: About you, When, People I trust, Guardian, Procedures & research, Review (6). Its
  procedures offer ONLY the official form's two choices per treatment ("My agent is / is not
  authorized to consent…") — user, 2026-11-22; this rule is for that case only, the app's
  extra information sections elsewhere stay
- `FormType.steps` getter returns the correct step list per type

## PDF Generation (Phase 6)
- Use `pdf` package coordinate-based drawing for pixel-perfect layout
- One renderer for all three form types (layout differences handled in code)
- Dynamic text expansion: measure text, expand box, shift content down

## AI — copy-and-paste handoff (what users see; user decision 2026-11-17)
No API key in view: the person copies MHAD's instructions into ChatGPT / Claude / Gemini /
Grok, attaches any document **there**, and pastes the JSON answer back. The API path below
stays as a hidden backup (`app_data.json` → `ai.apiModeVisible: false`). A dedicated MHAD
key would need a **relay server** — keys never ship to the browser.

| Piece | Where | Rule |
|---|---|---|
| The card | `AiHandoffPanel` (`ui/ai/`) | ONE card everywhere: choose AI → copy (+ Open, see what's included) → paste. Privacy notice once per session |
| Prompts | `buildHandoffPrompt` + `assets/data/ai_handoff.json` (versioned: services + what each accepts, legal facts, en/es envelope) | Task instructions come from the API path's own builders — never fork them |
| Answers | `parseHandoffReply` | Forgiving about format; strict about `mhad_task` + `mhad_ref` (`directiveHandoffRef` = the one `d<id>` format) |
| The wait | `PendingHandoff` (`progressWindowMinutes`, extendable; tab storage) | A locked progress copy lasts at least until its deadline; a reload restores the work (after the passphrase) and returns to the paste page; "Back to paste your AI answer" banner elsewhere |
| After a paste | panel | Clipboard cleared; a failed paste says a fresh copy may be needed |
| Fields ↔ AI keys | `docs/FIELD_AND_AI_AUDIT_2026-11-21.md` (all 81 fields) | A new field needs its autofill key, apply, review row and a test. Packed columns: `OtherInstructions` / `RecordsDisclosure` (`domain/model`) — never hand-parse their tags; room chips: `kRoomPreferenceChipIds` |
| API-only extras | Consolidate, rate limits, AI setup | Hidden with the API path; return when it's shown |
| Review screen | `pipeline_review_widget.dart`, `reviewFormatProblem`, `diagnosisFromReview` / `allergyFromReview` | The AI's `check_notes` show in a "Please check" card (filtered: no links, numbers masked); DOB / ZIP / phone get the wizard's own checks and start unchecked; diagnosis codes are checked against ICD-10-CM; every row honors the person's edits; 988 banner on crisis words |
| Voice questionnaire | `AudioQuestionnaire` (`lib/data/audio_questionnaire_content.dart`) → `/audio-guide?form=` + PDF | Same steps, order and labels as the wizard, per form; prompts quote the screen's own labels |
| Ask prompt size | `selectReferenceSections`, `LlmAssistant.handoffReferenceChars` | A copied Ask prompt carries only the Learn sections relevant to the question / step / article (budget) + the titles of the rest; all of them (~127K chars, ~32K tokens) overflowed free ChatGPT (~27K) and Gemini (32K) — Nov 2026. `reference_selection_test` keeps it under 60K chars. The hidden API path still sends every section |
| Mock simulation | method in memory `field-ai-audit-2026-11-21` | A stand-in AI answers the REAL copied prompt for a test file; paste its reply into the release build and score against the kit's answer key. A Claude stand-in is not ChatGPT/Gemini — say so |

## AI API path (hidden backup — multi-provider, see lib/ai/)
- **Provider-agnostic** since 2026-06-28. `AiProvider` (lib/ai/ai_provider.dart) is the
  single source of truth (label/keyHint/models/host + capability flags); `LlmClient`
  (lib/ai/llm_client.dart) is the transport (Gemini via `google_generative_ai`; Anthropic
  Messages REST; OpenAI/Grok Chat Completions REST). The chat/extractor/smart-fill take
  `(provider, model, apiKey)`; `GeminiApiAssistant` is now a typedef onto `LlmAssistant`.
- **Default = Gemini Flash-Lite** (`appData.ai.model` = `gemini-3.5-flash-lite`,
  admin-updatable) because the Gemini free tier allows ~500 requests/day on Flash-Lite vs
  ~20 on Flash (Oct 2026); `appData.ai.freeTierRpdByModel` drives the per-model daily cap.
  Other providers' curated lists live in `AiProvider.models` / `app_data.ai.providerModels`
  (defaults: Claude `claude-sonnet-5-5`, OpenAI `gpt-5.4-mini`, Grok `grok-4.7`).
  The app follows those lists at runtime (`AiProvider.currentDefault` = first entry; a
  saved pick that's no longer listed falls back to it). **Model upkeep:** the admin
  page's "Check models — all providers" (`ModelUpkeepService`) compares every list with
  the provider's live catalog, flags retired models and offers new ones → reviewed
  `ai.providerModels.*` / `ai.model` changes.
- **Claude requests** (LlmClient): 16k `max_tokens` (current models think by default),
  `output_config.effort: medium` on 4.6+ models, `fallbacks: "default"` + beta
  `server-side-fallback-2026-07-01` on Fable 5.1 / Opus 5.5 / Opus 5 / Sonnet 5.5. Never
  send `temperature`, `thinking: disabled`, or an assistant prefill (400 on current models).
  `stop_reason: "refusal"` → `LlmRefusalError` (message points to 988).
- **OpenAI** uses `max_completion_tokens` (GPT-5+ reject `max_tokens`); xAI keeps `max_tokens`.
- **Crisis safety net:** `looksLikeCrisis` (lib/ai/crisis_detector.dart) runs on every
  message before any AI gating and shows `CrisisSupportBanner` (988) on all chat surfaces —
  independent of whether the AI answers.
- **Per-provider keys** (`ai_key_<provider>`): private mode → flutter_secure_storage;
  public/web → in-memory + 10-min TTL crash-recovery cache. Active provider/model resolved
  via `aiConfigProvider` (lib/providers/assistant_providers.dart).
- **Capabilities differ:** web-search grounding + audio = Gemini only; PDF autofill =
  Gemini + Claude; images = all; OpenAI/Grok are often CORS-blocked in-browser (web).
- Always inject context: form type, current step, filled fields.
- PII stripping (`sanitizeForApi`) before sending — chat (incl. history), suggestions,
  smart-fill. **Document autofill is the one PII-exempt path** (sends the doc as-is, with
  explicit consent). Keep AI copy provider-agnostic (don't hardcode "Gemini").
- "Not legal advice" disclaimer always shown in UI.

## Saved progress (web — user decisions 2026-11-18)
| Piece | Where | Rule |
|---|---|---|
| The choice | `ensureProgressChoice` (`ui/progress/progress_gate.dart`) | Asked at the start (new / upload / import), once per tab: a passphrase-locked copy on this device, or nothing outside the tab (`sessionStorage`, names left out) |
| Lock | `services/locked_progress/` (`lock_crypto*`, `locked_format`) | AES-256-GCM + PBKDF2-SHA-256 600,000 rounds, random salt/nonce, header sealed as AAD. Web Crypto (non-extractable key) on web, pointycastle elsewhere; one Web Crypto test vector keeps them identical. CI's browser smoke test (`tool/web_smoke.py`) locks, independently decrypts, reloads and unlocks a copy in the release build |
| Life | `LockedProgressStore` | Expires `progressWindowMinutes` (30) after the page was last open. A closed tab can't erase it, so `sweep()` erases it unopened at the next start. 10 wrong passphrases erase it; one tab writes at a time |
| Saving | `ProgressAutosave` | 2 s after any DB change; quietly when hidden (`WizardStepMixin.saveQuietly` — steps use `showWarnings` / `saveSubStep`, `quiet_save_rule_test`); 60 s heartbeat |
| Passphrase | `services/passphrase/` | Min 4, no max; lowercase + capital + symbol or space; common-passphrase blocklist (zxcvbn-ts lists, MIT + ODC-BY notice); strength gauge; never stored |
| Files | `downloadLockedProgress`, `saved_file_import.dart` | Downloads are always locked (no expiry); older readable / app-key `.mhad` files still open |
| Wording | ARB | Never an unqualified "Nothing is saved" ("unless you choose"); the window comes from the setting, never a typed "30" |

## Privacy facts (verified in a browser 2026-11-19)
| Fact | Where | Rule |
|---|---|---|
| Outside hosts on load | `tool/web_smoke.py` `LOAD_HOSTS` | Google's `www.gstatic.com` (CanvasKit) + `fonts.gstatic.com`; the smoke test fails on any other — name a new host in the privacy policy first |
| Lookups the person starts | privacy policy "No third-party tracking" | NIH/NLM, MedlinePlus/RxNav, openFDA, Zippopotam.us + FCC (ZIP fill), browser speech service (dictation). Never claim "nothing leaves your browser" without naming them |
| pdf.js | `web/pdfjs/` (index.html `dartPdfJsBaseUrl`) | Served with the app, not unpkg; pinned to printing's version (`pdfjs_bundle_test`) |
| ICD lookups | `ClinicalDataService.searchConditions` (NLM, English) | **English only, on purpose** (user, 2026-11-22): no keyless Spanish ICD-10-CM API exists, and a bundled Spanish table (CIE-10-ES) was rejected — bundled data goes stale and needs manual updates. A Spanish search term finds nothing; type the English name |
| MedlinePlus language | `MedlinePlusService` (`languageCode`) | Asked in the reader's language (`informationRecipient.languageCode.c`) — a live API option, nothing bundled |
| Deleting | `DirectiveRepository.directiveChildTables` | No FK cascade (no `PRAGMA foreign_keys`): deletes remove child rows themselves (`directive_delete_test`) |

## Navigation (current model — no hamburger drawer)
- **Mobile**: floating `MhadBottomNav` (Home · Learn · Ask · Settings · More), every tab
  labelled. **Wide ≥1000px** (total window width): persistent `WebSidebar` via `ResponsiveShell`.
- Home/Learn/Ask/Settings are ONE definition: `primaryDestinations()`
  (`widgets/design/primary_destinations.dart`), read by the nav and the More sheet.
- **Focus mode** (`routeUsesFocusMode`): wizard + Export shrink the sidebar to a 72px icon
  rail; `sidebarWidthFor(route)` is the one width source. **Phones hide the nav in the
  wizard** (`routeHidesBottomNav`); the step header's More opens the More sheet WITH the
  four primary destinations — nothing is more than one tap away.
- Wizard actions = ONE `WizardBottomBar`: `[✦ Ask] … [Back] [Continue →]` (Ask only where
  the AI rail isn't shown). It MEASURES its fit (theme text styles × text size — the app's
  default is 1.2×): label → ✦ icon → no Ask (More still has Ask AI). Never stack a second bar.
- `app_drawer.dart` was deleted — do not reintroduce a Scaffold `drawer:`.
- Secondary destinations (New directive, Getting ready, Voice questionnaire, Export, AI setup,
  Privacy policy) are reached contextually or via the More sheet / sidebar.

## Design system (2026-11 refresh — extend, don't fork)
| Piece | Where | Rule |
|---|---|---|
| Tokens, palette, type, eyebrow | `ui/theme/app_theme.dart` (`DesignTokens`, `MhadPalette`, `MhadText`) | Font sizes 12/14/16 + display sizes; no 11/13/15 literals (`type_scale_test`) |
| Photos | `AppArt` enum (`ui/theme/app_art.dart`) → `ArtImage`; files `assets/images/<group>/<id>.webp` | Never `Image.asset` directly (decode buckets + one shared provider) |
| Headers | `PageHero` (compact / large); gates use `SplitHero` | Keep each screen's own back / exit / status controls |
| Card rows | `EqualHeightRow`, `PhotoActionCard(fillHeight:)` | **Sibling cards in a row are equal height** (user, 2026-11-17) |
| Pills | `ActionPill`, `RemovablePill` (`widgets/design/pills.dart`) | Never `ActionChip` / `InputChip`: Flutter web announces every chip as a checkbox (`web_chip_semantics_rule_test`). `FilterChip` / `ChoiceChip` are fine (they are selectable) |
| Tab titles | `ui/route_titles.dart` | Every route has one (`route_titles_test`) |
| Art pipeline | `tool/art/art_manifest.json` (single source) → `tool/art/generate_art.py` (Grok `image_gen`, verified, WebP); see `assets/images/README.md` | People photos name a **diverse cast** (user, 2026-11-17); review every image |
| Copy | `lib/l10n/app_{en,es}.arb` | Sentence case (form names, orgs, acronyms excepted); ’ “ ” … not ' " ... (`arb_typography_test`); one key per meaning (merge, don't copy); "PA MHAD" = the app, "directive" / es "DASM" = the document; plain words for legal terms ("the person who made it", not "principal"); never suggest another app or a future release (`only_web_copy_test`) |
| File names | `mhadFileName()` (`lib/utils/file_names.dart`) | Never hand-build a download name (blank parts were leaving `PA_MHAD_.pdf`) |
| Nothing-removed check | `tool/ui_inventory.py --build build/web --out after.json`, then `--diff tool/ui_inventory_before.json after.json` | Explain every missing control before merging a UI change. Baseline re-captured from main 3ac9c24 (2026-11-23) after PR #26's diff was explained — re-capture after each explained diff |
| Wizard step padding | `DesignTokens.pagePadding` | Every step's own list uses it, so the form lines up with the step header (`wizard_step_padding_rule_test`) |
| Step header (phones) | `StepHead(compact:)` | Collapses to one line while the step is scrolled, expands at the top — never toggled by the keyboard (R5) |
| Welcome photo (phones) | `SplitHeroBanner` | Placed by the screen as the first item of its own scroll, so it scrolls away; the consent row + CTA stay pinned |
| Getting ready | `GettingReadyChecklist` (`lib/data/getting_ready_content.dart`) → `/getting-ready?form=` + PDF | One definition for page and PDF; validity facts only from the legal canon / booklet (Jev-checked) |

**Widget tests:** size the VIEW (`tester.view.physicalSize` + `devicePixelRatio = 1`), never
`binding.setSurfaceSize` — it leaves MediaQuery at 800×600, so "desktop" cases silently
render the phone layout (`test_view_size_rule_test`). `test/flutter_test_config.dart` loads
the Learn articles (as `main()` does) and makes `ArtImage` paint placeholders.

## Localization (single mechanism)
- Use **only** the generated `AppLocalizations` (ARB files in `lib/l10n/app_*.arb`,
  `l10n.yaml`). The old `lib/ui/strings.dart` `AppStrings` layer was **deleted** — do
  not add a parallel string-constants class.
- **No hardcoded English on screens** (sweep 2026-11-21, Jev over every literal in `lib/`):
  `hardcoded_ui_text_test` fails on a word-bearing literal passed to `Text(` or a text
  parameter in `lib/ui` (PDF form text + admin excluded; exceptions listed with a reason).
  A scan can't see text built in a service/model and shown later — keep display words in
  ARB (e.g. `NtiNote` enum → `medNtiNote*`, `smartFillLabel()`, `AudioQuestionnaire(l)`).
- **Text in data files** (`app_data.json`: facts, referral lines, breach notice) is
  `LocalizedText` — a string or `{"en", "es"}` (`app_data_localized_text_test`).
- Left English on purpose: the official PDF form, AI prompts, exported data files, the
  owner-only admin screen, the hidden API-key path, logs, proper names. Labels autofill
  writes INTO the directive text are document content (still English — open question).
- **Spanish style** (terms, typography, names): `docs/SPANISH_STYLE.md`, one source for
  `app_es.arb` and the Learn articles.
- **Learn articles** are content, not strings: `assets/data/educational_content_es.json`
  (same ids; `sourceHash` = the English each was translated from). Draft 2026-11-18, **off**
  until a fluent review (`app_data.json` `learn.spanishArticles`); display only, the AI keeps
  the English. `learn_es_test` checks sections, lists, bold, numbers, typography, staleness.
  Reviewer's Word copy: `tool/learn_review` (see `docs/SPANISH_STYLE.md`).

## Docs
- Gap/improvement backlog: `docs/GAP_ANALYSIS_V4.md` (V2/V3 historical; re-scoped 2026-06-20
  for the web pivot — its old Play/Apple "Critical" items are now `deferred — native`).
- Security scope/threat model: `docs/THREAT_MODEL.md`. Breach process: `docs/BREACH_PLAN.md`.

## Multi-Platform
- Platform utility: `lib/utils/platform_utils.dart` (safe checks for web)
- Conditional imports: `_native.dart` / `_web.dart` / `_stub.dart` pattern
- Web: public mode only (in-memory DB; optional passphrase-locked progress copy — see *Saved progress*)
- Camera/gallery: mobile only; file picker: all platforms
- NFC: mobile only; notifications: no Windows/Web; biometrics: no Web

## Coding Style
- Prefer const constructors
- ConsumerWidget for screens that read Riverpod state
- StatelessWidget for pure display widgets
- Providers in separate `providers/` file per feature when they grow large
- Never hardcode UI strings — use the generated `AppLocalizations` (see Localization)
