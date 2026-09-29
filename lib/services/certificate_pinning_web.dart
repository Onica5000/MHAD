import 'package:http/http.dart' as http;

/// On web, browsers handle TLS natively. No certificate pinning is needed
/// or even possible — the browser enforces its own certificate validation,
/// and a Dart-side host check would add nothing a malicious page couldn't
/// bypass anyway. Returns a plain HTTP client.
http.Client createPinnedClient() => http.Client();

/// Hosts the app is designed to talk to.
///
/// Unlike the native build, this list is **advisory** — the web client above
/// applies no host restriction, because the browser's own origin policy is the
/// real control. It is kept exactly in sync with the native allowlist so the
/// two platforms describe the same intent; it previously omitted three of the
/// four AI providers, which read as though Claude/OpenAI/Grok were deliberately
/// barred on web when in fact nothing here is enforced at all.
///
/// Keep in sync with `_allowedHosts` in `certificate_pinning_native.dart` and
/// with `AiProvider.host`.
bool isAllowedHost(String host) {
  const allowedHosts = {
    // AI providers (user brings their own key per provider).
    'generativelanguage.googleapis.com', // Google Gemini
    'api.anthropic.com', // Anthropic Claude
    'api.openai.com', // OpenAI
    'api.x.ai', // xAI Grok
    // Free public reference lookups (no user PII sent — only a term/code).
    'clinicaltables.nlm.nih.gov',
    'connect.medlineplus.gov',
    'rxnav.nlm.nih.gov',
    'api.fda.gov',
  };
  return allowedHosts.contains(host);
}
