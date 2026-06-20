# PA Mental Health Advance Directive (MHAD)

A free, open-source app for creating, managing, and exporting Pennsylvania Mental Health Advance Directives under [PA Act 194 of 2004](https://www.legis.state.pa.us/cfdocs/legis/li/uconsCheck.cfm?yr=2004&sessInd=0&act=194) (codified at [20 Pa.C.S. Ch. 58](https://www.palegis.us/statutes/consolidated/view-statute?iFrame=true&txtType=HTM&ttl=20&div=0&chpt=58)).

**Try it on the web:** [https://onica5000.github.io/MHAD/](https://onica5000.github.io/MHAD/)

## What is a Mental Health Advance Directive?

A Mental Health Advance Directive (MHAD) lets you document your mental-health treatment preferences in advance, so they are honored if you are ever unable to make decisions for yourself. Under Pennsylvania law, you can:

- Specify which treatments, medications, and facilities you prefer or want to avoid.
- Designate an agent (healthcare proxy) to make mental-health decisions on your behalf (POA / Combined forms).
- Nominate a guardian in case a court ever appoints one.

The directive is valid for **2 years** and must be signed in the presence of **two adult witnesses** to be legally binding.

The app supports all three PA Act 194 form types: **Combined Declaration + Power of Attorney**, **Declaration Only**, and **Power of Attorney Only**.

## Features

- **Adaptive guided wizard** that ranges from 6 to 11 steps depending on form type — **Combined 11 / Declaration 9 / POA 6**. Steps: `About you`, `When this kicks in`, `People I trust` (POA/Combined), `If a court appoints a guardian` (POA/Combined), `Where I want care`, `Diagnoses`, `Medications`, `Allergies & reactions`, `Procedures & research`, `Anything else`, `Review & sign`. Each step supports embedded clinical autocomplete (ICD-10-CM diagnoses, RxTerms medications) and a backward-nudge model that surfaces cross-step contradictions instead of auto-mutating earlier steps.
- **Editorial visual design** based on a Claude-Design HTML/CSS handoff — Instrument Serif italic display, DM Sans body, JetBrains Mono labels (all three font families bundled, no runtime fetch).
- **Navigation tuned to the prototype:** a floating pill **bottom nav** on mobile (Home · Learn · Ask · Settings) and a persistent **WebSidebar** on wide screens (≥1000px). No hamburger drawer.
- **AI assistant** (Google Gemini 2.5 Flash) for guided help, smart-fill suggestions, document import, and a **cross-step consistency check** at Review — entirely optional, with per-session affirmative consent and PII-stripping at a single named chokepoint (`GeminiApiAssistant.sanitizeForApi`). The consistency check warns but never blocks PDF generation.
- **Crisis plan / WRAP toolbox** — optional add-on capturing early warning signs, triggers, what genuinely helps, things to say, and what *not* to do; mirrors the v2 prototype's WRAP layout and is read by agents and ER staff first.
- **Self-binding (Ulysses) clause** — explicit opt-in confirming the structural effect of PA Act 194 § 5802 (a signed directive binds you when you later refuse care during a crisis).
- **Revocation flow** with the verbatim statutory revocation statement (20 Pa.C.S. § 5808), per-recipient notification opt-in, and honest copy about what marking a directive revoked locally does and does not communicate to providers.
- **Local share sheet** (email · SMS · QR · system share · print) routed through your device's native OS share sheet (`share_plus` / `Printing.sharePdf`) — no verified links, one-time codes, expiry, or read receipts. (The only RFC-style URIs in the app are the crisis contacts' `tel:` / `sms:` links, not the directive share.)
- **Legal toggle** — a read-only render mode of a signed directive in strict statutory-citation language for legal review, alongside the plain-language official form. (A separate clinician-summary view was considered and dropped: the full signed directive / PDF is the authoritative clinician-facing artifact, and a paraphrased summary would only risk misrepresenting it.)
- **Past directives + revocation history** — every superseded directive stays viewable on the device with status pill (Active / Expired / Revoked), explicit Delete confirmation, and the v3 promise that no share log is kept in Public Mode.
- **PDF generation** with coordinate-based, pixel-faithful layout matching the official PA MHAD forms, including guardian-relation-aware nominee resolution (same-as-primary / same-as-alternate / specific / no preference).
- **Encrypted storage** (SQLCipher AES-256) in Private Mode, with biometric / passcode unlock and a device-secure-keystore-backed key. Public Mode keeps everything in memory only.
- **Accessibility settings** wired into `MaterialApp` — text-scale slider, language selection, dyslexia-font / high-contrast / reduce-motion / VoiceOver-hints toggles, plus a facilitator-support screen for the *facilitated PAD* workflow.
- **Educational content** sourced verbatim from the PA MHAD booklet (FAQ, glossary, instructions), framed around the research-validated *facilitated PAD* approach, with Ch. 54 (psychiatric advance) ↔ Ch. 58 (mental-health advance) bridge articles and provider-duty (§ 5837) explanations.
- **Crisis-availability tooling** addressing the "transmitter/receiver problem": wallet card generator, QR code, NFC tag writing, FHIR JSON export, and a post-wizard checklist for distributing copies and making the directive findable in a crisis.
- **988 Suicide & Crisis Lifeline** persistent on every screen.

## Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| **Web** | Available now | [onica5000.github.io/MHAD](https://onica5000.github.io/MHAD/) — public mode only |
| **Android** | Builds locally | APK available |
| **Windows** | Builds locally | `.exe` available |
| **iOS** | Compiles on CI (Codemagic) | Requires Apple Developer account for distribution |
| **macOS** | Compiles on CI (Codemagic) | Requires Apple Developer account for notarization |

## Privacy, security, and legal posture

- **Local-first.** All directive data stays on your device. There is no app server, no cloud sync, no developer-side copy.
- **No analytics, no tracking, no cookies, no ads.** Outbound flows are limited to (1) the **opt-in** Google Gemini AI feature and (2) free public U.S. government reference lookups — NIH/NLM Clinical Tables (medication / condition / provider-NPI), NLM MedlinePlus Connect (plain-language condition info), and FDA openFDA (drug labels that ground the side-effects list). **The reference lookups send only the term, code, or provider name being searched — never your identity or your directive.** AI chat/suggestions are PII-stripped; document **autofill** is the one deliberate exception (the uploaded file is sent so the AI can read its personal details to fill the form, reviewed before saving, and never required).
- **Strict TLS + certificate pinning** on the Gemini path, with a host allowlist covering the Gemini and the NIH/NLM/FDA reference hosts; **SQLCipher AES-256** for Private Mode; key in the platform secure keystore.
- **Per-session affirmative consent** for AI features, with prominent PII warnings.
- **Public Mode** holds data in memory only and can be erased at any time. **Private Mode** uses encrypted on-device storage with biometric / passcode unlock.
- This app is **not HIPAA-compliant** and is intended for personal use only.
- The app is designed to comply with the amended **FTC Health Breach Notification Rule** (16 CFR Part 318, eff. 2024-07-29), state consumer-health-data laws (**CA, WA, CT, NV, NY**), and emerging Google Play / Apple platform requirements for health apps. See:
  - [`PRIVACY_POLICY.md`](./PRIVACY_POLICY.md) — public, non-PDF privacy policy (also rendered in-app).
  - [`docs/BREACH_PLAN.md`](./docs/BREACH_PLAN.md) — amended-rule breach procedure.
  - [`docs/THREAT_MODEL.md`](./docs/THREAT_MODEL.md) — OWASP MASVS scope and deliberate deferrals.
  - [`docs/GAP_ANALYSIS_V4.md`](./docs/GAP_ANALYSIS_V4.md) — current prioritized gap & improvement status (V2/V3 are historical).

## Not legal or medical advice

This app helps you **document** your mental-health treatment preferences. It does **not** provide legal advice, medical advice, or create any professional relationship. Consult a licensed PA attorney for legal questions and a qualified mental-health professional for treatment decisions.

For assistance with your rights under PA Act 194:

- **PA Protection & Advocacy:** 1-800-692-7443 (toll-free)
- **988 Suicide & Crisis Lifeline:** call or text 988

## Building from source

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) 3.41.4+ / Dart 3.11.1+
- Android SDK (for Android builds)
- Xcode (iOS/macOS builds — macOS only, or via Codemagic CI)
- Visual Studio with C++ tools (Windows builds)

### Build commands

```bash
flutter pub get

# Re-run after any database schema change
flutter pub run build_runner build --delete-conflicting-outputs

# Per-platform builds
flutter build apk --debug                                # Android (debug)
flutter build apk --release --obfuscate \
  --split-debug-info=build/debug-info                    # Android (release, obfuscated)
flutter build web                                        # Web
flutter build windows                                    # Windows
flutter build ios --no-codesign                          # iOS (verification only)
flutter build macos --debug                              # macOS

# Tests + analysis
flutter test
flutter analyze
```

### Web database files

The web build requires two files in `web/` (already included):

- `sqlite3.wasm` — SQLite compiled to WebAssembly
- `drift_worker.js` — Drift database web worker

These are downloaded from the [sqlite3.dart](https://github.com/simolus3/sqlite3.dart/releases) and [drift](https://github.com/simolus3/drift/releases) release pages.

## Tech stack

- **Framework:** Flutter / Dart (3.41.4 / 3.11.1)
- **State management:** Riverpod
- **Database:** Drift + SQLCipher (encrypted SQLite)
- **Navigation:** GoRouter (no Scaffold drawer; bottom nav on mobile, sidebar on wide)
- **AI:** Google Gemini 2.5 Flash (free tier, optional, opt-in)
- **PDF:** `pdf` + `printing` packages (coordinate-based layout)
- **Fonts (bundled):** Instrument Serif, DM Sans, JetBrains Mono
- **Medical reference data (free, no key, no PII sent):** NIH/NLM Clinical Tables — RxTerms (medications), ICD-10-CM (conditions), NPI registry (provider lookup); NLM MedlinePlus Connect (plain-language condition education); FDA openFDA (drug labels, used to ground the AI side-effects list)

## Project layout

```
lib/
  ai/                                  -- AiAssistant + GeminiApiAssistant
  data/
    database/                          -- Drift schema v10 + generated code
    repository/                        -- DirectiveRepository (snapshot/restore)
  domain/model/directive.dart          -- FormType, WizardStep, AllergySeverity enums
  providers/                           -- Riverpod providers (accessibility, privacy, theme, …)
  ui/
    ai_check/                          -- AI consistency check (cross-step contradictions)
    assistant/                         -- AI chat UI (Gemini)
    crisis_plan/                       -- WRAP toolbox (5 sections, JSON-stored)
    disclaimer/                        -- First-launch gate + Settings read-only variant
    education/                         -- FAQ, glossary, articles, Ch. 54 ↔ Ch. 58 bridge
    export/                            -- PDF, wallet card, QR, FHIR
    facilitator/                       -- Facilitated-PAD workflow support
    home/, mode_selection/, onboarding/ -- Top-level destinations + first-run
    legal_toggle/                      -- Plain-language ↔ statutory citation toggle
    past/                              -- Past directive detail + delete confirm
    revocation/                        -- 20 Pa.C.S. § 5808 flow + per-recipient notify
    settings/                          -- Settings, AI setup, accessibility, privacy
    share/                             -- (reserved/empty; sharing lives in export/ via share_plus)
    ulysses/                           -- Self-binding clause opt-in (§ 5802)
    wizard/                            -- Adaptive 6/9/11-step flow per FormType
    widgets/design/                    -- bottom_nav, web_sidebar, responsive_shell, …
docs/                                  -- ACTION_PLAN, BREACH_PLAN, THREAT_MODEL, GAP_ANALYSIS_V4
PRIVACY_POLICY.md                      -- Public privacy policy source (mirrors in-app)
MHAD-handoff/                          -- Claude-Design HTML/CSS prototype source (reference)
```

For deeper architecture and conventions, see [`CLAUDE.md`](./CLAUDE.md).

## CI/CD

Automated builds via [Codemagic](https://codemagic.io/):

- **Tests** workflow runs on every push.
- **Build All** workflow compiles Android, iOS, macOS, and Web on tag or release branch.

Web deployment is automated to GitHub Pages via GitHub Actions.

## License

This project is provided as-is for public benefit. See the in-app disclaimer and [`PRIVACY_POLICY.md`](./PRIVACY_POLICY.md) for terms of use.

## Contributing

Issues and pull requests are welcome. Please read the in-app disclaimer before contributing — all content related to PA Act 194 must be sourced verbatim from official documents. New contributors should also skim [`CLAUDE.md`](./CLAUDE.md) (project conventions) and [`docs/GAP_ANALYSIS_V4.md`](./docs/GAP_ANALYSIS_V4.md) (current backlog).
