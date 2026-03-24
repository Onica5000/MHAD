# PA Mental Health Advance Directive (MHAD)

A free, open-source app for creating, managing, and exporting Pennsylvania Mental Health Advance Directives under [PA Act 194 of 2004](https://www.legis.state.pa.us/cfdocs/legis/li/uconsCheck.cfm?yr=2004&sessInd=0&act=194).

**Try it now:** [https://onica5000.github.io/MHAD/](https://onica5000.github.io/MHAD/)

## What is a Mental Health Advance Directive?

A Mental Health Advance Directive (MHAD) lets you document your mental health treatment preferences in advance, so they are honored if you are ever unable to make decisions for yourself. Under Pennsylvania law, you can:

- Specify which treatments, medications, and facilities you prefer or want to avoid
- Designate an agent (healthcare proxy) to make mental health decisions on your behalf
- Nominate a guardian in case a court ever appoints one

The directive is valid for **2 years** and requires **two adult witnesses** to be legally binding.

## Features

- **14-step guided wizard** for Combined, Declaration, and Power of Attorney form types
- **AI assistant** (Google Gemini) for guided help, field suggestions, and document import
- **PDF generation** with pixel-perfect layout matching the official PA MHAD forms
- **Encrypted storage** (SQLCipher AES-256) with biometric/passcode authentication
- **Public mode** for one-time use without saving data permanently
- **Educational content** sourced verbatim from the PA MHAD booklet (FAQ, glossary, checklists)
- **Wallet card** generator, QR code, NFC tag writing, and FHIR JSON export
- **Voice dictation** for hands-free form entry
- **Document import** with AI-powered extraction from photos, PDFs, and text files
- **Crisis resources** banner with 988 Suicide & Crisis Lifeline on every screen

## Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| **Web** | Available now | [onica5000.github.io/MHAD](https://onica5000.github.io/MHAD/) |
| **Android** | Builds locally | APK available |
| **Windows** | Builds locally | .exe available |
| **iOS** | Compiles on CI | Requires Apple Developer account for distribution |
| **macOS** | Compiles on CI | Requires Apple Developer account for notarization |

## Privacy & Security

- **All data is stored locally** on your device. Nothing is sent to any server for storage.
- **No analytics, no tracking, no cookies, no ads.** The only external connections are Google Gemini API (optional, user-initiated) and NIH/NLM medication lookup (user-initiated).
- **AI features are optional.** The app works fully without them.
- **PII stripping** automatically removes personal information before sending text to the AI.
- **Per-session AI consent** is required before any data is sent to Google.
- **Public mode** holds data in memory only (or browser storage on web) and can be erased at any time.
- **Private mode** encrypts data with SQLCipher (AES-256) and requires biometric or passcode authentication.
- This app is **NOT HIPAA-compliant** and is intended for personal use only.

## Not Legal or Medical Advice

This app helps you **document** your mental health treatment preferences. It does **not** provide legal advice, medical advice, or create any professional relationship. Consult a licensed attorney for legal questions and a qualified mental health professional for treatment decisions.

For assistance with your rights under PA Act 194, contact:
- **PA Protection & Advocacy:** 1-800-692-7443 (toll-free)
- **988 Suicide & Crisis Lifeline:** Call or text 988

## Building from Source

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) 3.41.4+
- Android SDK (for Android builds)
- Xcode (for iOS/macOS builds, macOS only)
- Visual Studio with C++ tools (for Windows builds)

### Build Commands

```bash
# Get dependencies
flutter pub get

# Run code generation (after database schema changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Build for each platform
flutter build apk --debug          # Android
flutter build web                   # Web
flutter build windows               # Windows
flutter build ios --no-codesign     # iOS (verification only)
flutter build macos --debug         # macOS
```

### Web Database Files

The web build requires two files in the `web/` directory (already included):
- `sqlite3.wasm` — SQLite compiled to WebAssembly
- `drift_worker.js` — Drift database web worker

These are downloaded from the [sqlite3.dart](https://github.com/simolus3/sqlite3.dart/releases) and [drift](https://github.com/simolus3/drift/releases) release pages.

## Tech Stack

- **Framework:** Flutter / Dart
- **State management:** Riverpod
- **Database:** Drift + SQLCipher (encrypted SQLite)
- **Navigation:** GoRouter
- **AI:** Google Gemini 2.5 Flash (free tier)
- **PDF:** pdf + printing packages
- **Medical data:** NIH/NLM RxTerms and ICD-10-CM APIs

## CI/CD

Automated builds via [Codemagic](https://codemagic.io/):
- **Tests** workflow runs on every push
- **Build All** workflow compiles Android, iOS, macOS, and Web on tag or release branch

Web deployment is automated via GitHub Actions to GitHub Pages.

## License

This project is provided as-is for public benefit. See the in-app disclaimer and privacy policy for terms of use.

## Contributing

Issues and pull requests are welcome. Please read the in-app disclaimer before contributing — all content related to PA Act 194 must be sourced verbatim from official documents.
