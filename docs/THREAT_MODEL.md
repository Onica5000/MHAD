# MHAD Threat Model & Security Scope (OWASP MASVS)

**Date:** 2026-05-19 · Owner: project maintainer · Review: each release

## Assets
- User-entered mental-health directive PII (names, agents, diagnoses, meds, signatures).
- Private-mode SQLCipher DB encryption key (device secure storage).
- Optional Gemini API key.

## Trust model
- **Local-first.** No app server, no analytics/ads/tracking SDKs, no data sale.
- Only outbound flows: (1) **opt-in** Gemini AI (per-session affirmative consent,
  PII-stripped), (2) NIH/NLM medication/diagnosis lookup (no user PII sent).

## MASVS coverage (deliberate scope)

| MASVS group | Status | Notes |
|---|---|---|
| Storage (MASVS-STORAGE) | ✅ L1/L2 | SQLCipher AES-256 (private), in-memory (public), secure keystore for keys |
| Crypto (MASVS-CRYPTO) | ✅ | Platform keystore; random 32-byte key |
| Auth (MASVS-AUTH) | ✅ | Biometric/passcode gate for private mode |
| Network (MASVS-NETWORK) | ✅ | Strict TLS + cert pinning + host allowlist (Gemini) |
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
