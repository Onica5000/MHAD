import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mhad/data/app_data/app_data.dart';

/// One AI-proposed change to app_data.json, awaiting human review.
class ProposedChange {
  /// Dotted path into the data, e.g. `contacts.trevorProject.phone`,
  /// `ai.rpm`, `legal.validityYears`.
  final String path;

  /// The current value at [path] (for the diff), or null if the path is new.
  final String? oldValue;

  /// The proposed new value (as the AI returned it — coerced to the base type
  /// on apply).
  final String newValue;

  /// `auto` (contacts / AI config — may apply once reviewed) or `verify`
  /// (legal / educational — needs deliberate human sign-off).
  final String autonomy;

  /// Citation / URL the AI based the change on. Required for `verify`.
  final String source;

  /// Why the AI proposes this.
  final String rationale;

  /// Human decision (mutable for the review UI). Defaults: `auto` pre-approved,
  /// `verify` unapproved until a person ticks it.
  bool approved;

  ProposedChange({
    required this.path,
    required this.oldValue,
    required this.newValue,
    required this.autonomy,
    required this.source,
    required this.rationale,
    required this.approved,
  });

  bool get isVerify => autonomy == 'verify';
}

/// Drafts and applies admin updates to the app's dynamic data (app_data.json).
///
/// The AI proposes changes WITH sources; a human approves them in the admin
/// screen; the app then emits the updated JSON to commit to the repo (the
/// release is what makes it "live"). Nothing is mutated at runtime, and legal /
/// educational facts (`verify` tier) never auto-apply.
class AdminUpdateService {
  final String apiKey;
  AdminUpdateService({required this.apiKey});

  /// Reads the current bundled data as a JSON map (the base the AI edits).
  static Future<Map<String, dynamic>> currentData() async {
    return await AppData.loadRawJson();
  }

  /// Ask the AI to draft changes for [request] against [current]. Returns the
  /// raw model text (expected to be a JSON object). Live call — not exercised
  /// in CI.
  Future<String> draftRaw(
      String request, Map<String, dynamic> current) async {
    final model = GenerativeModel(model: appData.ai.model, apiKey: apiKey);
    final prompt = buildPrompt(request, current);
    final resp = await model.generateContent([Content.text(prompt)]);
    return resp.text ?? '';
  }

  /// The drafting prompt. Public so it can be inspected/tested.
  static String buildPrompt(String request, Map<String, dynamic> current) {
    final pretty = prettyJson(current);
    return '''
You maintain the data file for a Pennsylvania Mental Health Advance Directive
app. Propose updates to the JSON below based on the maintainer's request.

RULES (non-negotiable):
- Return ONLY a JSON object: {"changes":[{"path","newValue","autonomy","source","rationale"}]}.
- "path" is a dotted path into the JSON (e.g. "contacts.trevorProject.phone", "ai.rpm", "legal.validityYears"). Only paths that already exist.
- "autonomy": use "verify" for ANYTHING under "legal" or any legal/statutory fact; "auto" for contacts and "ai"/"urls" config.
- "source": a citation or URL you based the change on. REQUIRED. For "verify" changes it must be an authoritative legal/government source.
- NEVER guess or fabricate. If you are not certain of a value, DO NOT include a change for it. If unsure about everything, return {"changes":[]}.
- Do not restructure the JSON; only change leaf values.

Maintainer request:
$request

Current data:
$pretty
''';
  }

  /// Parse the model's JSON proposal into reviewable changes, attaching the
  /// current value at each path from [current]. Tolerant of fenced/extra text.
  static List<ProposedChange> parseProposal(
      String modelText, Map<String, dynamic> current) {
    final jsonText = _extractJsonObject(modelText);
    if (jsonText == null) return const [];
    Map<String, dynamic> obj;
    try {
      obj = jsonDecode(jsonText) as Map<String, dynamic>;
    } catch (_) {
      return const [];
    }
    final changes = <ProposedChange>[];
    for (final raw in (obj['changes'] as List?) ?? const []) {
      if (raw is! Map) continue;
      final m = raw.cast<String, dynamic>();
      final path = (m['path'] ?? '').toString();
      if (path.isEmpty) continue;
      final newValue = (m['newValue'] ?? '').toString();
      final autonomy = (m['autonomy'] ?? 'verify').toString();
      changes.add(ProposedChange(
        path: path,
        oldValue: _readPath(current, path)?.toString(),
        newValue: newValue,
        autonomy: autonomy,
        source: (m['source'] ?? '').toString(),
        rationale: (m['rationale'] ?? '').toString(),
        // auto pre-approved; verify must be ticked deliberately.
        approved: autonomy != 'verify',
      ));
    }
    return changes;
  }

  /// Apply the [approved] changes onto a deep copy of [base], coercing each new
  /// value to the existing leaf's type (so numbers stay numbers). Pure.
  static Map<String, dynamic> applyApproved(
      Map<String, dynamic> base, Iterable<ProposedChange> approved) {
    final copy = jsonDecode(jsonEncode(base)) as Map<String, dynamic>;
    for (final c in approved) {
      if (!c.approved) continue;
      _writePath(copy, c.path, _coerce(_readPath(base, c.path), c.newValue));
    }
    return copy;
  }

  static String prettyJson(Object data) =>
      const JsonEncoder.withIndent('  ').convert(data);

  // ── path helpers ───────────────────────────────────────────────────────

  static Object? _readPath(Map<String, dynamic> root, String path) {
    dynamic node = root;
    for (final key in path.split('.')) {
      if (node is Map && node.containsKey(key)) {
        node = node[key];
      } else {
        return null;
      }
    }
    return node;
  }

  static void _writePath(Map<String, dynamic> root, String path, Object value) {
    final keys = path.split('.');
    Map<String, dynamic> node = root;
    for (var i = 0; i < keys.length - 1; i++) {
      final next = node[keys[i]];
      if (next is Map<String, dynamic>) {
        node = next;
      } else if (next is Map) {
        node = next.cast<String, dynamic>();
        node[keys[i]] = node;
      } else {
        return; // path doesn't exist — refuse to create new structure
      }
    }
    node[keys.last] = value;
  }

  /// Coerce [raw] (a String from the AI) to match [existing]'s type.
  static Object _coerce(Object? existing, String raw) {
    if (existing is int) return int.tryParse(raw) ?? existing;
    if (existing is double) return double.tryParse(raw) ?? existing;
    if (existing is bool) return raw.toLowerCase() == 'true';
    return raw;
  }

  /// Pull the first balanced top-level `{...}` object out of [text] (handles
  /// ```json fences and chatter around it).
  static String? _extractJsonObject(String text) {
    final start = text.indexOf('{');
    if (start < 0) return null;
    var depth = 0;
    for (var i = start; i < text.length; i++) {
      final ch = text[i];
      if (ch == '{') depth++;
      if (ch == '}') {
        depth--;
        if (depth == 0) return text.substring(start, i + 1);
      }
    }
    return null;
  }
}
