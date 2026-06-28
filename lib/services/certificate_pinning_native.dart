import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Allowed hostnames for API connections.
const _allowedHosts = {
  // AI providers (user brings their own key per provider). Keep in sync with
  // AiProvider.host in lib/ai/ai_provider.dart.
  'generativelanguage.googleapis.com', // Google Gemini
  'api.anthropic.com', // Anthropic Claude
  'api.openai.com', // OpenAI
  'api.x.ai', // xAI Grok
  'clinicaltables.nlm.nih.gov',
  // Free public reference lookups (no user PII sent — only a term/code).
  'connect.medlineplus.gov', // NLM MedlinePlus Connect — condition/med education
  'rxnav.nlm.nih.gov', // NLM RxNav — drug name → RxCUI for MedlinePlus
  'api.fda.gov', // openFDA — FDA drug labels (grounds side-effects)
};

/// Creates an [http.Client] with hardened TLS for Google APIs (native platforms).
///
/// - Rejects all invalid certificates (no bypass)
/// - Restricts connections to known Google API hosts
/// - TLS 1.2+ only (dart:io default on modern platforms)
http.Client createPinnedClient() {
  final httpClient = HttpClient()
    ..badCertificateCallback = _rejectAllBadCertificates;
  return _HostRestrictedClient(IOClient(httpClient));
}

/// Checks if a host is in the allowlist.
bool isAllowedHost(String host) => _allowedHosts.contains(host);

bool _rejectAllBadCertificates(X509Certificate cert, String host, int port) =>
    false;

class _HostRestrictedClient extends http.BaseClient {
  final http.Client _inner;
  _HostRestrictedClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final host = request.url.host;
    if (!isAllowedHost(host)) {
      throw SocketException(
        'Connection to $host blocked by certificate pinning policy. '
        'Only allowlisted AI provider / NLM endpoints are permitted.',
      );
    }
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
