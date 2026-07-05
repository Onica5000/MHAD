# CLAUDE.md — MHAD Flutter Project

## Project
Pennsylvania Mental Health Advance Directive app — Flutter/Dart.

**Primary target (2026-06-16 pivot): the Chrome/Edge WEB app — responsive for both PC and
mobile browsers. This is the ONLY actively-developed surface.**

**Native mobile (Android + iOS) and desktop (macOS) are POSTPONED INDEFINITELY.** Do not
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

The shipped UI/UX (fonts, layout, look) is the source of truth — preserve it. The old
Claude Design artboard/handoff bundle was removed 2026-06-28 (it had served its purpose
and was stale); do not reintroduce it or design against it.

Source PDF: `PA MHAD.pdf`. Improvement backlog: `docs/GAP_ANALYSIS_V4.md`.

## Flutter / Dart
- Flutter 3.41.4, Dart 3.11.1
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
  ui/
    theme/        -- app_theme.dart (teal Material3 theme)
    home/         -- HomeScreen
    wizard/       -- Step-by-step form flow (adaptive per FormType)
    education/    -- FAQ, instructions, glossary
    assistant/    -- AI chat UI
    export/       -- PDF preview & export options
    router.dart   -- GoRouter config + AppRoutes constants
  main.dart       -- ProviderScope + MaterialApp.router
```

## Key Packages
- **State**: flutter_riverpod + riverpod_annotation (code gen with riverpod_generator)
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
- DECLARATION: no agent sections
- POA: all steps including agent sections
- `FormType.steps` getter returns the correct step list per type

## PDF Generation (Phase 6)
- Use `pdf` package coordinate-based drawing for pixel-perfect layout
- One renderer for all three form types (layout differences handled in code)
- Dynamic text expansion: measure text, expand box, shift content down

## AI Assistant (multi-provider — see lib/ai/)
- **Provider-agnostic** since 2026-06-28. `AiProvider` (lib/ai/ai_provider.dart) is the
  single source of truth (label/keyHint/models/host + capability flags); `LlmClient`
  (lib/ai/llm_client.dart) is the transport (Gemini via `google_generative_ai`; Anthropic
  Messages REST; OpenAI/Grok Chat Completions REST). The chat/extractor/smart-fill take
  `(provider, model, apiKey)`; `GeminiApiAssistant` is now a typedef onto `LlmAssistant`.
- **Default = Gemini** (`appData.ai.model` = `gemini-3.5-flash`, admin-updatable). Other
  providers' curated model lists live in `AiProvider.models` (current defaults: Claude
  `claude-sonnet-4-6`, OpenAI `gpt-5.4-mini`, Grok `grok-4.3`).
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

## Navigation (current model — no hamburger drawer)
- **Mobile**: floating pill `MhadBottomNav` (Home · Learn · Ask · Settings) on the four
  top-level screens. **Wide ≥1000px**: persistent `WebSidebar` via `ResponsiveShell`.
- `app_drawer.dart` was deleted — do not reintroduce a Scaffold `drawer:`.
- Secondary destinations (New directive, Export, AI setup, Privacy policy) are reached
  contextually, not via global nav.

## Localization (single mechanism)
- Use **only** the generated `AppLocalizations` (ARB files in `lib/l10n/app_*.arb`,
  `l10n.yaml`). The old `lib/ui/strings.dart` `AppStrings` layer was **deleted** — do
  not add a parallel string-constants class.
- Migrate hardcoded UI strings to ARB screen-by-screen; only ship a locale (`es`) for a
  screen once it is fully covered (partial localization is worse than none).

## Docs
- Gap/improvement backlog: `docs/GAP_ANALYSIS_V4.md` (V2/V3 historical; re-scoped 2026-06-20
  for the web pivot — its old Play/Apple "Critical" items are now `deferred — native`).
- Security scope/threat model: `docs/THREAT_MODEL.md`. Breach process: `docs/BREACH_PLAN.md`.

## Multi-Platform
- Platform utility: `lib/utils/platform_utils.dart` (safe checks for web)
- Conditional imports: `_native.dart` / `_web.dart` / `_stub.dart` pattern
- Web: public mode only (in-memory DB, no encryption)
- Camera/gallery: mobile only; file picker: all platforms
- NFC: mobile only; notifications: no Windows/Web; biometrics: no Web

## Coding Style
- Prefer const constructors
- ConsumerWidget for screens that read Riverpod state
- StatelessWidget for pure display widgets
- Providers in separate `providers/` file per feature when they grow large
- Never hardcode UI strings — use the generated `AppLocalizations` (see Localization)
