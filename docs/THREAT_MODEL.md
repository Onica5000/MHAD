# MHAD Threat Model & Security Scope (OWASP MASVS)

**Date:** 2026-05-19 · Owner: project maintainer · Review: each release

## Assets
- User-entered mental-health directive PII (names, agents, diagnoses, meds, signatures).
- Private-mode SQLCipher DB encryption key (device secure storage).
- Optional **per-provider** AI API keys (Gemini default; Anthropic/OpenAI/xAI optional).
  Each is the user's own key, stored per provider (private: secure storage; public:
  in-memory + 10-min crash-recovery cache), and is only ever sent to that provider's
  own endpoint.

## Trust model
- **Local-first.** No app server, no analytics/ads/tracking SDKs, no data sale.
- Outbound flows:
  1. **opt-in** AI (per-session affirmative consent). The user chooses the provider —
     **Gemini (default), Anthropic Claude, OpenAI, or xAI Grok** — and brings their own
     key. PII is stripped for chat (incl. prior turns), suggestions, and smart-fill at a
     single chokepoint (`sanitizeForApi`/`PiiStripper`) regardless of provider.
     **Document autofill is the one deliberate exception:** the uploaded file is sent
     as-is so the AI can read its personal details and fill the form (declarant +
     agents/guardian); the user reviews everything before it is saved, and uploading is
     never required. Audio dictation is Gemini-only; a non-Gemini key is rejected
     locally before any request, so it is never sent to the wrong provider.
  2. Free public U.S. government reference lookups — NIH/NLM Clinical Tables
     (medication / condition / provider-NPI), NLM MedlinePlus Connect + RxNav
     (plain-language condition & medication education), and FDA openFDA (drug labels,
     used to ground the side-effects list). Each request carries **only the term, code,
     or provider name being looked up — no user PII, no directive.**

## MASVS coverage (deliberate scope)

| MASVS group | Status | Notes |
|---|---|---|
| Storage (MASVS-STORAGE) | ✅ L1/L2 | SQLCipher AES-256 (private), in-memory (public), secure keystore for keys |
| Crypto (MASVS-CRYPTO) | ✅ | Platform keystore; random 32-byte key |
| Auth (MASVS-AUTH) | ✅ | Biometric/passcode gate for private mode |
| Network (MASVS-NETWORK) | ✅ | Strict TLS + cert pinning + host allowlist (AI providers: Gemini / Anthropic / OpenAI / xAI; plus NIH/NLM Clinical Tables, MedlinePlus, RxNav, FDA openFDA) |
| Platform (MASVS-PLATFORM) | ✅ | FLAG_SECURE screenshot protection; least-permission |
| Code (MASVS-CODE) | ✅ | Release obfuscation + split-debug-info |
| Resilience (MASVS-RESILIENCE) | ⚠️ **Partial — deliberate** | Root/jailbreak warn (non-blocking). **No** anti-Frida/anti-hooking/anti-debug/tamper RASP. |

## MASVS-RESILIENCE deferral rationale (V4-L13)
The app holds **local-only** data the attacker (a device-local adversary) already
controls if the device is compromised; there is no server secret or licensed content to
protect. Full RASP (e.g. freeRASP/Talsec) defends business logic and licensing, not the
user's own data on their own device. Adding it would increase binary size, false
positives, and maintenance for negligible user-data benefit. **Decision: stay at
L1/L2 + non-blocking root warning.** Revisit only if a server component or paid tier is
introduced. This is an explicit, reviewed choice — not an unaddressed gap.

**Web-first pivot note (2026-06):** the shipping surface is now the Chrome/Edge web app
(native is deferred — see CLAUDE.md). RASP is doubly moot there: a web build runs inside
the browser sandbox with no native binary to harden, and the resilience controls in the
table above (FLAG_SECURE, root/jailbreak warning, cert pinning, obfuscation) are
native-only and gracefully absent on web. Web's exposure is instead governed by the
local-first, public-mode-only posture (in-memory DB, no persistence) and the network
allowlist — not by anti-tamper RASP. The deferral therefore stands unchanged for the
surface that actually ships.
