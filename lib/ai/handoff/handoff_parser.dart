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
HandoffReply parseHandoffReply(
  String raw, {
  required String taskTag,
  required String ref,
}) {
  final text = raw.trim();
  if (text.isEmpty) return const HandoffReply.fail(HandoffProblem.empty);
  if (text.contains(kHandoffMarker) && !text.contains('"mhad_task"')) {
    return const HandoffReply.fail(HandoffProblem.promptPastedBack);
  }

  final unfenced = text.replaceAll(RegExp(r'```[a-zA-Z]*'), '');
  final start = unfenced.indexOf('{');
  if (start < 0) return const HandoffReply.fail(HandoffProblem.notJson);
  final end = _matchingBrace(unfenced, start);
  if (end < 0) return const HandoffReply.fail(HandoffProblem.truncated);
  final candidate = unfenced.substring(start, end + 1);

  Map<String, dynamic>? decoded;
  for (final attempt in [
    candidate,
    _dropTrailingCommas(candidate),
    _straightQuotes(_dropTrailingCommas(candidate)),
  ]) {
    try {
      final v = jsonDecode(attempt);
      if (v is Map<String, dynamic>) {
        decoded = v;
        break;
      }
    } catch (_) {}
  }
  if (decoded == null) return const HandoffReply.fail(HandoffProblem.notJson);

  if (decoded['error'] == 'no_attachment') {
    return const HandoffReply.fail(HandoffProblem.noAttachment);
  }
  if (decoded['mhad_task'] != taskTag) {
    return const HandoffReply.fail(HandoffProblem.wrongTask);
  }
  if ('${decoded['mhad_ref']}' != ref) {
    return const HandoffReply.fail(HandoffProblem.wrongRef);
  }
  return HandoffReply.ok(decoded);
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
