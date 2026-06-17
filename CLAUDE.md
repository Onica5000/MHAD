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

When implementing screens from the design bundle (`MHAD-handoff/bundle/`), assume Material
3 + a responsive web layout. Lean toward Material affordances (`Scaffold`, `FilledButton`,
`MaterialPageRoute`) and avoid `Cupertino*` widgets — keep the codebase Cupertino-free.

Source PDF: `PA MHAD.pdf`. Plan: `ACTION_PLAN.md`. Design bundle: `MHAD-handoff/bundle/`
(refreshed 2026-06-04 with Android/Chrome platform-tag chrome).

## Flutter / Dart
- Flutter 3.41.4, Dart 3.11.1
- Run with: `D:\flutter\bin\flutter.bat run`
- Build debug APK: `D:\flutter\bin\flutter.bat build apk`
- Build release APK: `D:\flutter\bin\flutter.bat build apk --release --obfuscate --split-debug-info=build/debug-info`
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
    gemini_api_assistant.dart   -- Gemini API via google_generative_ai package
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
- **AI**: google_generative_ai (Gemini 2.5 Flash free tier)
- **PDF**: pdf + printing (pixel-perfect PDF generation)
- **Signature**: signature
- **Secure storage**: flutter_secure_storage (Gemini API key)

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

## AI Assistant
- Model: `gemini-2.5-flash` via `google_generative_ai` package
- API key stored in flutter_secure_storage in private mode (never in source)
- In public mode, API key is ephemeral (in-memory only, 10-min TTL cache for crash recovery)
- Always inject context: form type, current step, filled fields
- PII stripping before sending to external API
- "Not legal advice" disclaimer always shown in UI

## Navigation (current model — no hamburger drawer)
- **Mobile**: floating pill `MhadBottomNav` (Home · Learn · Ask · Settings) on the four
  top-level screens. **Wide ≥1000px**: persistent `WebSidebar` via `ResponsiveShell`.
- `app_drawer.dart` was deleted — do not reintroduce a Scaffold `drawer:`.
- Secondary destinations (New directive, Export, AI setup, Privacy policy) are reached
  contextually, not via global nav (mirrors the prototype).

## Localization (single mechanism)
- Use **only** the generated `AppLocalizations` (ARB files in `lib/l10n/app_*.arb`,
  `l10n.yaml`). The old `lib/ui/strings.dart` `AppStrings` layer was **deleted** — do
  not add a parallel string-constants class.
- Migrate hardcoded UI strings to ARB screen-by-screen; only ship a locale (`es`) for a
  screen once it is fully covered (partial localization is worse than none).

## Docs
- Authoritative gap/improvement status: `docs/GAP_ANALYSIS_V4.md` (V2/V3 are historical).
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
