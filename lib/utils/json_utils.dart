/// Returns a non-empty trimmed string from a JSON value, or null.
String? optStr(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

/// Strips markdown code fences (``` / ```json, tolerant of \r\n) that LLMs
/// wrap around JSON responses. Shared by the assistant's JSON helpers, the
/// document extractor, and smart fill — keep the one copy here.
String stripLlmCodeFences(String raw) {
  var text = raw.trim();
  if (!text.startsWith('```')) return text;
  text = text.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
  if (text.endsWith('```')) {
    text = text.substring(0, text.length - 3);
  }
  return text.trim();
}

/// [stripLlmCodeFences] plus removal of trailing commas before `}` or `]`
/// (a common LLM JSON quirk) — the standard cleanup before `jsonDecode`ing
/// a structured AI response.
///
/// Uses replaceAllMapped: Dart's `replaceAll(Pattern, String)` does NOT
/// expand `$1` (the pre-consolidation copies used it and so replaced `,}`
/// with a literal `$1`, corrupting the very responses they meant to repair).
String cleanLlmJson(String raw) => stripLlmCodeFences(raw)
    .replaceAllMapped(RegExp(r',(\s*[}\]])'), (m) => m.group(1)!);
