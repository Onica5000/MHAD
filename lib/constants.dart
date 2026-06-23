// Contact / resource phone numbers moved to assets/data/app_data.json (read via
// `appData.contact(...)` / `appData.phoneOf(...)`) so they can be updated via
// the admin propose/approve flow. See lib/data/app_data/app_data.dart.
import 'package:mhad/data/app_data/app_data.dart';

/// Consent / authority values persisted in the directive's string preference
/// fields (medicationConsent, ectConsent, experimentalConsent, drugTrialConsent).
/// A value may also be a bare `conditional:<text>` carrying the user's
/// qualification — test it with [consentConditionalPrefix].
const consentYes = 'yes';
const consentNo = 'no';
const consentAgentDecides = 'agentDecides';
const consentConditionalPrefix = 'conditional:';

/// Canonical human label for a stored consent value, or null when the value is
/// unset or unrecognized. Use where an unset field should be omitted entirely
/// (e.g. the AI chat context). For an always-present label, use [consentLabel].
String? consentLabelOrNull(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  if (value == consentYes) return 'consented';
  if (value == consentNo) return 'refused';
  if (value == consentAgentDecides) return 'agent decides';
  if (value.startsWith(consentConditionalPrefix)) {
    return 'conditional (see form)';
  }
  return null;
}

/// Like [consentLabelOrNull] but never null — for inline summaries that must
/// render something for every field. Unset → 'not set'; an unrecognized value →
/// 'set (see form)' (never echoes the raw value, which could carry PII).
String consentLabel(String? value) {
  if (value == null || value.trim().isEmpty) return 'not set';
  return consentLabelOrNull(value) ?? 'set (see form)';
}

/// Heuristic: does [key] look like a Google Gemini API key? Real Gemini keys
/// start with "AIza", are ~39 characters, and contain no whitespace. Used to
/// warn before a request (a genuine key always passes); not a hard gate.
bool isLikelyGeminiKey(String key) {
  final k = key.trim();
  return k.startsWith('AIza') && k.length >= 35 && !k.contains(RegExp(r'\s'));
}

// Gemini model id + context window + rate limits moved to
// assets/data/app_data.json (read via `appData.ai.*`) so they track Google's
// changes via the admin update flow. See lib/data/app_data/app_data.dart.

/// Public-mode session-cache TTL. Confirmed work is held in memory only this
/// long (public/web halves of the same ephemeral-session feature share it).
/// Read from the dynamic `config` block (`config.sessionCacheMinutes`).
Duration get sessionCacheTtl => appData.config.sessionCacheTtl;

/// Canonical short caveat shown wherever AI generates content (chat replies,
/// field suggestions). Keep this exact wording so the app's voice stays
/// consistent — see the legal-wording canon.
const aiNotAdvice = 'AI-generated — not legal or medical advice.';

// privacyPolicyUrl moved to assets/data/app_data.json (`appData.privacyPolicyUrl`).
// Google Play (Jan 2026 health-app rules) requires it to be a publicly
// accessible web page identical across the Play Console, the app, and the
// developer site; update it there before submission.
