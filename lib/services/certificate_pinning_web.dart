import 'package:http/http.dart' as http;

/// On web, browsers handle TLS natively. No certificate pinning is needed
/// or even possible — the browser enforces its own certificate validation.
/// Returns a plain HTTP client.
http.Client createPinnedClient() => http.Client();

/// Checks if a host is in the allowlist.
bool isAllowedHost(String host) {
  const allowedHosts = {'generativelanguage.googleapis.com'};
  return allowedHosts.contains(host);
}
