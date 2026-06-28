import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/educational_content.dart';

/// The admin tool drafts updates with the same provider set the user-facing AI
/// uses — see [AiProvider] (lib/ai/ai_provider.dart), the single source of
/// truth. Kept as an alias so existing admin call sites read unchanged.
typedef AdminAiProvider = AiProvider;

/// Which dynamic-data file the admin flow is editing. Each is a separate
/// bundled JSON asset committed to the repo; the AI drafts changes against the
/// chosen one and the screen emits the updated file.
enum AdminDataTarget {
  appData,
  educational;

  String get label => switch (this) {
        appData => 'App data (contacts · AI · config · legal · dated · facts)',
        educational => 'Educational corpus (Learn page + AI reference)',
      };

  String get assetPath => switch (this) {
        appData => 'assets/data/app_data.json',
        educational => 'assets/data/educational_content.json',
      };

  /// Read the current bundled JSON for this target (the base the AI edits).
  Future<Map<String, dynamic>> loadRawJson() async => switch (this) {
        appData => AppData.loadRawJson(),
        educational => EducationalContent.loadRawJson(),
      };
}

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

  /// Provider to draft with (defaults to Gemini for backward compatibility).
  final AdminAiProvider provider;

  /// Model id for [provider]. Empty → the provider's default model.
  final String model;

  AdminUpdateService({
    required this.apiKey,
    this.provider = AdminAiProvider.gemini,
    String model = '',
  }) : model = model.trim().isEmpty ? provider.defaultModel : model.trim();

  /// Reads the current bundled data as a JSON map (the base the AI edits) for
  /// [target] (defaults to the main app-data file).
  static Future<Map<String, dynamic>> currentData(
          [AdminDataTarget target = AdminDataTarget.appData]) =>
      target.loadRawJson();

  /// Ask the AI to draft changes for [request] against [current]. Returns the
  /// raw model text (expected to be a JSON object). Live call — not exercised
  /// in CI. [focusArea] (optional) scopes the AI to one path/area; [target]
  /// selects the file's update rules.
  Future<String> draftRaw(
    String request,
    Map<String, dynamic> current, {
    AdminDataTarget target = AdminDataTarget.appData,
    String focusArea = '',
  }) async {
    final prompt =
        buildPrompt(request, current, target: target, focusArea: focusArea);
    return switch (provider) {
      // Gemini drafts WITH Google-Search grounding so the model checks current
      // facts and the required "source" URLs are real, not recalled from
      // memory. Falls back to the ungrounded call if grounding is unavailable.
      AdminAiProvider.gemini => _draftGemini(prompt),
      AdminAiProvider.anthropic => _draftAnthropic(prompt),
      // xAI's API is OpenAI-compatible — same request/response, different host.
      AdminAiProvider.openai =>
        _draftChatCompletions(prompt, 'https://api.openai.com/v1/chat/completions'),
      AdminAiProvider.grok =>
        _draftChatCompletions(prompt, 'https://api.x.ai/v1/chat/completions'),
    };
  }

  Future<String> _draftGemini(String prompt) async {
    // Prefer a search-grounded draft: the maintainer is updating live facts
    // (phone numbers, statute references, version dates), so letting the model
    // look them up makes both the VALUE and the cited "source" trustworthy
    // instead of recalled. If grounding fails for any reason (model without the
    // tool, network, API shape change) fall back to a plain generation so the
    // admin flow still works.
    try {
      final grounded = await _draftGeminiGrounded(prompt);
      if (grounded.trim().isNotEmpty) return grounded;
    } catch (_) {
      // fall through to the ungrounded path
    }
    final m = GenerativeModel(model: model, apiKey: apiKey);
    final resp = await m.generateContent([Content.text(prompt)]);
    return resp.text ?? '';
  }

  /// Gemini generation with the `google_search` grounding tool enabled, called
  /// over the REST endpoint (the bundled package can't toggle the tool). Returns
  /// the concatenated text of the first candidate. The proposal JSON is parsed
  /// out of this text downstream by [parseProposal], which tolerates the extra
  /// grounding chatter/citations the model may add around it.
  Future<String> _draftGeminiGrounded(String prompt) async {
    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/'
        'models/$model:generateContent?key=$apiKey');
    final resp = await http.post(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt}
            ],
          }
        ],
        'tools': [
          {'google_search': <String, dynamic>{}}
        ],
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Gemini grounding ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final candidates = (data['candidates'] as List?) ?? const [];
    if (candidates.isEmpty) return '';
    final cand = candidates.first as Map<String, dynamic>;
    final parts = ((cand['content'] as Map?)?['parts'] as List?) ?? const [];
    return parts
        .whereType<Map<String, dynamic>>()
        .map((p) => (p['text'] ?? '').toString())
        .join()
        .trim();
  }

  /// Anthropic Messages API (REST). content is an array of blocks; we
  /// concatenate the text blocks.
  Future<String> _draftAnthropic(String prompt) async {
    final resp = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'content-type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': model,
        'max_tokens': 4096,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Anthropic API ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final blocks = (data['content'] as List?) ?? const [];
    final buf = StringBuffer();
    for (final b in blocks) {
      if (b is Map && b['type'] == 'text') buf.write(b['text'] ?? '');
    }
    return buf.toString();
  }

  /// OpenAI-compatible Chat Completions API (used by OpenAI and xAI Grok —
  /// same wire format, [url] differs). Reads choices[0].message.content.
  Future<String> _draftChatCompletions(String prompt, String url) async {
    final resp = await http.post(
      Uri.parse(url),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('${provider.label} API ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = (data['choices'] as List?) ?? const [];
    if (choices.isEmpty) return '';
    final msg = (choices.first as Map)['message'] as Map?;
    return msg?['content']?.toString() ?? '';
  }

  /// The drafting prompt. Public so it can be inspected/tested. [target] picks
  /// the per-file tier rules; [focusArea] (optional) is a free-text area/path
  /// the maintainer wants the AI to restrict itself to — this is how the
  /// maintainer points the AI at a spot that isn't otherwise called out.
  static String buildPrompt(
    String request,
    Map<String, dynamic> current, {
    AdminDataTarget target = AdminDataTarget.appData,
    String focusArea = '',
  }) {
    final pretty = prettyJson(current);
    final tierRules = switch (target) {
      AdminDataTarget.appData => '''
- "autonomy": use "verify" for ANYTHING under "legal" or "dated" (legal/statutory facts, compliance statements, version/effective dates); use "auto" for "contacts", "ai", "urls", "config", and "facts".
- "path" examples: "contacts.trevorProject.phone", "ai.rpm", "config.timeoutsSeconds.chat", "config.reminders.renewalWindowDays", "legal.validityYears", "dated.privacyPolicyVersion", "facts.facilitatorCompletionStat". Only paths that already exist.''',
      AdminDataTarget.educational => '''
- This is the educational corpus (Learn-page + AI-reference prose). EVERY change is "autonomy":"verify" — a human must confirm accuracy (the legal-wording canon governs it).
- "path" is always "sections.<id>.title", "sections.<id>.content", or "sections.<id>.category" for an EXISTING section id. Only change leaf values; never add/remove/rename sections or change ids.''',
    };
    final focus = focusArea.trim().isEmpty
        ? ''
        : '\nFOCUS: Restrict your proposal to this area/path only — '
            '"${focusArea.trim()}". Do NOT propose changes anywhere else.\n';
    return '''
You maintain the "${target.assetPath}" data file for a Pennsylvania Mental
Health Advance Directive app. Propose updates to the JSON below based on the
maintainer's request.

RULES (non-negotiable):
- Return ONLY a JSON object: {"changes":[{"path","newValue","autonomy","source","rationale"}]}.
- "path" is a dotted path into the JSON. Only paths that already exist.
$tierRules
- "source": a citation or URL you based the change on. REQUIRED. For "verify" changes it must be an authoritative legal/government source.
- NEVER guess or fabricate. If you are not certain of a value, DO NOT include a change for it. If unsure about everything, return {"changes":[]}.
- Do not restructure the JSON; only change leaf values.
$focus
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
      final rawVal = m['newValue'];
      final newValue = (rawVal is Map || rawVal is List)
          ? jsonEncode(rawVal)
          : (rawVal ?? '').toString();
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

  // ── Revert / restore ─────────────────────────────────────────────────────

  /// Decide the autonomy tier for a restore of [path] (so the review UI shows
  /// the right badge and verify-tier restores are visibly deliberate).
  static String tierForPath(AdminDataTarget target, String path) {
    if (target == AdminDataTarget.educational) return 'verify';
    if (path.startsWith('legal.') || path.startsWith('dated.')) return 'verify';
    return 'auto';
  }

  /// Leaf-level diff for a roll-back: every path present in BOTH the [current]
  /// live data and the [backup] whose value differs, as a restore proposal
  /// (newValue shows the backup value). The maintainer ticks which parts to
  /// roll back; [applyRestore] writes the real typed backup values. Skips
  /// `_meta`/`_note` keys and only restores leaves that still exist (it never
  /// resurrects a removed field or changes structure).
  static List<ProposedChange> diffForRestore(
    Map<String, dynamic> current,
    Map<String, dynamic> backup, {
    required AdminDataTarget target,
  }) {
    final out = <ProposedChange>[];
    void walk(String prefix, Map<dynamic, dynamic> cur, Map<dynamic, dynamic> bak) {
      for (final e in bak.entries) {
        final key = e.key.toString();
        if (key.startsWith('_')) continue; // skip _meta / _note metadata
        if (!cur.containsKey(key)) continue; // only restore existing leaves
        final path = prefix.isEmpty ? key : '$prefix.$key';
        final bVal = e.value;
        final cVal = cur[key];
        if (bVal is Map && cVal is Map) {
          walk(path, cVal, bVal);
        } else {
          final differs = (bVal is List || bVal is Map || cVal is List || cVal is Map)
              ? jsonEncode(bVal) != jsonEncode(cVal)
              : bVal.toString() != cVal.toString();
          if (differs) {
            out.add(ProposedChange(
              path: path,
              oldValue: _displayValue(cVal),
              newValue: _displayValue(bVal),
              autonomy: tierForPath(target, path),
              source: 'Backup — previous version of ${target.assetPath}',
              rationale: 'Restore the previous value',
              // Pre-ticked so a one-click full roll-back works; untick rows to
              // restore only some parts.
              approved: true,
            ));
          }
        }
      }
    }

    walk('', current, backup);
    return out;
  }

  /// Apply the approved restore [changes] onto a deep copy of [base], writing
  /// the REAL typed value from [backup] at each path (so lists/numbers/bools
  /// round-trip, unlike the string-coercing forward apply). Pure.
  static Map<String, dynamic> applyRestore(
    Map<String, dynamic> base,
    Map<String, dynamic> backup,
    Iterable<ProposedChange> changes,
  ) {
    final copy = jsonDecode(jsonEncode(base)) as Map<String, dynamic>;
    for (final c in changes) {
      if (!c.approved) continue;
      final raw = _readPath(backup, c.path);
      if (raw != null) _writePath(copy, c.path, raw);
    }
    return copy;
  }

  static String _displayValue(Object? v) =>
      (v is Map || v is List) ? jsonEncode(v) : (v?.toString() ?? '(none)');

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
        // .cast writes through to the underlying map, so descending is enough —
        // no self-assignment (an earlier version wrote `node[keys[i]] = node`,
        // creating a self-referential cycle).
        node = next.cast<String, dynamic>();
      } else {
        return; // intermediate path doesn't exist — refuse to create structure
      }
    }
    // Only overwrite a leaf that already exists. The AI may UPDATE known
    // dynamic facts but must never invent a brand-new field, even under an
    // existing parent (e.g. a fabricated `legal.somethingNew`).
    if (!node.containsKey(keys.last)) return;
    node[keys.last] = value;
  }

  /// Coerce [raw] (a String from the AI) to match [existing]'s type.
  static Object _coerce(Object? existing, String raw) {
    if (existing is int) return int.tryParse(raw) ?? existing;
    if (existing is double) return double.tryParse(raw) ?? existing;
    if (existing is bool) return raw.toLowerCase() == 'true';
    if (existing is List || existing is Map) {
      try {
        return jsonDecode(raw) as Object;
      } catch (_) {
        return existing ?? raw;
      }
    }
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
