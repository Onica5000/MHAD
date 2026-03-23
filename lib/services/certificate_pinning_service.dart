import 'package:http/http.dart' as http;

import 'certificate_pinning_stub.dart'
    if (dart.library.io) 'certificate_pinning_native.dart'
    if (dart.library.js_interop) 'certificate_pinning_web.dart'
    as impl;

/// Provides a hardened HTTP client for the Gemini API.
///
/// On native platforms: strict TLS, hostname allowlist, system trust store.
/// On web: plain client (browsers handle TLS natively).
class CertificatePinningService {
  CertificatePinningService._();

  static http.Client createPinnedClient() => impl.createPinnedClient();

  static bool isAllowedHost(String host) => impl.isAllowedHost(host);
}
