// Contact / resource phone numbers moved to assets/data/app_data.json (read via
// `appData.contact(...)` / `appData.phoneOf(...)`) so they can be updated via
// the admin propose/approve flow. See lib/data/app_data/app_data.dart.

/// Consent / authority values persisted in the directive's string preference
/// fields (medicationConsent, ectConsent, experimentalConsent, drugTrialConsent).
/// A value may also be a bare `conditional:<text>` carrying the user's
/// qualification — test it with [consentConditionalPrefix].
const consentYes = 'yes';
const consentNo = 'no';
const consentAgentDecides = 'agentDecides';
const consentConditionalPrefix = 'conditional:';

/// The Gemini model id used across the AI assistant, document extractor, and
/// smart-fill service. Bump this in one place when changing models.
const geminiFlashModel = 'gemini-2.5-flash';

/// Gemini 2.5 Flash context window (input tokens). Shared by the assistant's
/// budgeting and the rate tracker so the two never drift.
const geminiMaxContextTokens = 1048576;

/// Public-mode session-cache TTL. Confirmed work is held in memory only this
/// long (public/web halves of the same ephemeral-session feature share it).
const sessionCacheTtl = Duration(minutes: 10);

/// Canonical short caveat shown wherever AI generates content (chat replies,
/// field suggestions). Keep this exact wording so the app's voice stays
/// consistent — see the legal-wording canon.
const aiNotAdvice = 'AI-generated — not legal or medical advice.';

/// Public privacy-policy URL.
///
/// Google Play (Jan 2026 health-app rules) requires the privacy policy to be a
/// publicly accessible web page (no PDFs) at a URL **identical** across the Play
/// Console, the app, and the developer website. The repo ships `PRIVACY_POLICY.md`
/// as the source of truth; host it (e.g., GitHub Pages) and update this constant
/// to the live URL before submission. The in-app screen mirrors the same content.
const privacyPolicyUrl = 'https://onica5000.github.io/mhad/privacy';
