/// Returns a non-empty trimmed string from a JSON value, or null.
String? optStr(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}
