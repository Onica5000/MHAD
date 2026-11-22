import 'dart:convert';

import 'package:mhad/ai/handoff/handoff_prompt.dart';

/// Why a pasted answer could not be used. Each maps to a plain explanation and
/// a "fix-it" message the person can paste back into their AI.
enum HandoffProblem {
  /// Nothing was pasted.
  empty,

  /// The instructions themselves were pasted (the clipboard still held them).
  promptPastedBack,

  /// No JSON could be read.
  notJson,

  /// The JSON stops before its end (the AI's reply was cut off).
  truncated,

  /// A valid answer, but for a different task.
  wrongTask,

  /// A valid answer, but for a different directive / record.
  wrongRef,

  /// The AI reports that nothing was attached.
  noAttachment,
}

/// The outcome of reading a pasted answer.
class HandoffReply {
  final Map<String, dynamic>? json;
  final HandoffProblem? problem;

  const HandoffReply.ok(Map<String, dynamic> this.json) : problem = null;
  const HandoffReply.fail(HandoffProblem this.problem) : json = null;

  bool get ok => problem == null && json != null;
}

/// Reads a pasted AI answer for the task tagged [taskTag] about [ref].
///
/// Forgiving about what chat apps add around JSON — a ```json fence, a line of
/// commentary before or after, trailing commas, curly quotes — but strict
/// about WHAT it is: the answer must carry the right `mhad_task` and
/// `mhad_ref`, so an answer for another task or directive is never applied.
/// [alsoAccept]: other references that mean the same thing — after a reload
/// restored the work under a new id, the answer still carries the old one.
HandoffReply parseHandoffReply(
  String raw, {
  required String taskTag,
  required String ref,
  Set<String> alsoAccept = const {},
}) {
  final text = raw.trim();
  if (text.isEmpty) return const HandoffReply.fail(HandoffProblem.empty);

  // Every top-level JSON object in the paste, in order. A paste can hold the
  // instructions too ("Select all" in a chat app copies the whole thread),
  // and the instructions contain JSON-looking examples — so reading only the
  // first "{" lost good answers (prompt-hardening review P-9).
  final unfenced = text.replaceAll(RegExp(r'```[a-zA-Z]*'), '');
  final objects = <Map<String, dynamic>>[];
  var truncated = false;
  var i = unfenced.indexOf('{');
  while (i >= 0) {
    final end = _matchingBrace(unfenced, i);
    if (end < 0) {
      truncated = true;
      break;
    }
    final decoded = _decode(unfenced.substring(i, end + 1));
    if (decoded != null) objects.add(decoded);
    // A non-JSON brace (prose like "{name: …}") is skipped one character on,
    // so a real object inside it is still found.
    i = unfenced.indexOf('{', decoded != null ? end + 1 : i + 1);
  }

  bool refOk(Map<String, dynamic> o) {
    final r = '${o['mhad_ref']}';
    return r == ref || alsoAccept.contains(r);
  }

  final answers = [
    for (final o in objects)
      if (o['mhad_task'] == taskTag && o['error'] == null) o,
  ];
  if (answers.isNotEmpty) {
    // The answer comes after the instructions: prefer the last one.
    for (final o in answers.reversed) {
      if (refOk(o)) return HandoffReply.ok(o);
    }
    return const HandoffReply.fail(HandoffProblem.wrongRef);
  }
  // Only the instructions' own examples (like the no-attachment reply they
  // describe) — the person pasted the message they sent.
  if (text.contains(kHandoffMarker)) {
    return const HandoffReply.fail(HandoffProblem.promptPastedBack);
  }
  if (objects.any((o) => o['error'] == 'no_attachment')) {
    return const HandoffReply.fail(HandoffProblem.noAttachment);
  }
  if (objects.any((o) => o.containsKey('mhad_task'))) {
    return const HandoffReply.fail(HandoffProblem.wrongTask);
  }
  if (truncated) return const HandoffReply.fail(HandoffProblem.truncated);
  return const HandoffReply.fail(HandoffProblem.notJson);
}

/// [candidate] as a JSON object, forgiving trailing commas and curly quotes.
Map<String, dynamic>? _decode(String candidate) {
  for (final attempt in [
    candidate,
    _dropTrailingCommas(candidate),
    _straightQuotes(_dropTrailingCommas(candidate)),
  ]) {
    try {
      final v = jsonDecode(attempt);
      if (v is Map<String, dynamic>) return v;
    } catch (_) {}
  }
  return null;
}

/// Index of the `}` closing the object that opens at [start], skipping braces
/// inside strings; -1 when the text ends first (a cut-off reply).
int _matchingBrace(String s, int start) {
  var depth = 0;
  var inString = false;
  var escaped = false;
  for (var i = start; i < s.length; i++) {
    final c = s[i];
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (c == r'\') {
        escaped = true;
      } else if (c == '"') {
        inString = false;
      }
      continue;
    }
    if (c == '"') {
      inString = true;
    } else if (c == '{') {
      depth++;
    } else if (c == '}') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return -1;
}

String _dropTrailingCommas(String s) =>
    s.replaceAllMapped(RegExp(r',\s*([}\]])'), (m) => m.group(1)!);

/// Last resort: some chat apps turn straight quotes into curly ones when the
/// answer is copied as text rather than from the code block.
String _straightQuotes(String s) => s
    .replaceAll('“', '"')
    .replaceAll('”', '"')
    .replaceAll('‘', "'")
    .replaceAll('’', "'");
