/// Returns a non-empty trimmed string from a JSON value, or null.
String? optStr(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

/// Strips markdown code fences (``` / ```json, tolerant of \r\n) that LLMs
/// wrap around JSON responses. Shared by the assistant's JSON helpers, the
/// document extractor, and smart fill — keep the one copy here.
///
/// Also tolerates prose around the JSON ("Here is the result: {...} Hope
/// this helps!"), which providers without a JSON mode (Claude) or with a
/// loose one sometimes add: a fenced block anywhere wins; otherwise text
/// before the first `{` / after the last `}` is dropped.
String stripLlmCodeFences(String raw) {
  var text = raw.trim();
  if (text.startsWith('```')) {
    text = text.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
    final end = text.indexOf('```');
    if (end >= 0) text = text.substring(0, end);
    return text.trim();
  }
  final fenced =
      RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(text)?.group(1);
  if (fenced != null && fenced.trim().startsWith(RegExp(r'[\[{]'))) {
    return fenced.trim();
  }
  if (!text.startsWith('{') && !text.startsWith('[')) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start >= 0 && end > start) return text.substring(start, end + 1);
  }
  return text;
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
