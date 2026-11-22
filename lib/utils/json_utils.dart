/// Returns a non-empty trimmed string from a JSON value, or null.
String? optStr(dynamic v, {String listSeparator = '\n'}) {
  if (v == null) return null;
  // A chat AI often answers a text field with a list; joined, it never
  // prints as "[a, b]" (prompt-hardening review P-4).
  if (v is List) {
    final parts = [
      for (final e in v)
        if (e != null && e.toString().trim().isNotEmpty) e.toString().trim(),
    ];
    return parts.isEmpty ? null : parts.join(listSeparator);
  }
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

/// A yes/no from AI JSON: true/false, or the strings "true"/"false"/"yes"/"no"
/// (chat models often quote them); anything else is null — never guessed true.
/// A quoted "true" used to throw and lose the whole autofill answer (P-5).
bool? optBool(dynamic v) {
  if (v is bool) return v;
  if (v is String) {
    switch (v.trim().toLowerCase()) {
      case 'true' || 'yes':
        return true;
      case 'false' || 'no':
        return false;
    }
  }
  return null;
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
