import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// The AI chat services a prompt can be handed to (user decision 2026-11-17:
/// ChatGPT, Claude, Gemini, Grok — everything by copy and paste, no API key).
enum AiService { chatgpt, claude, gemini, grok }

/// What a person can attach in the AI for a task.
enum HandoffInput { image, pdf, audio }

/// Whether a service accepts an input kind (assets/data/ai_handoff.json).
enum ServiceSupport {
  yes,

  /// Paid plans only (e.g. ChatGPT audio uploads, Oct 2026).
  paid,
  no,

  /// Listed by the provider but not confirmed on the free tier.
  unconfirmed;

  static ServiceSupport parse(Object? v) => switch (v) {
        'yes' => ServiceSupport.yes,
        'paid' => ServiceSupport.paid,
        'no' => ServiceSupport.no,
        _ => ServiceSupport.unconfirmed,
      };
}

/// One service's display name, chat link and what it accepts.
class AiServiceInfo {
  final AiService service;
  final String label;
  final Uri url;
  final Map<HandoffInput, ServiceSupport> support;

  const AiServiceInfo({
    required this.service,
    required this.label,
    required this.url,
    required this.support,
  });

  ServiceSupport supports(HandoffInput input) =>
      support[input] ?? ServiceSupport.unconfirmed;
}

/// The handoff's wording and service facts — ONE definition, loaded from
/// assets/data/ai_handoff.json at startup (like AppData / EducationalContent),
/// so the wording can be revised without a code change.
class AiHandoffData {
  final int version;
  final Map<AiService, AiServiceInfo> services;
  final List<String> legalFacts;
  final Map<String, Map<String, dynamic>> _envelope;

  const AiHandoffData._(
      this.version, this.services, this.legalFacts, this._envelope);

  /// Loaded by `main()` (and the test config) before the app runs.
  static AiHandoffData instance = AiHandoffData.fromJson(const {});

  static Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data/ai_handoff.json');
    instance = AiHandoffData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  factory AiHandoffData.fromJson(Map<String, dynamic> json) {
    final services = <AiService, AiServiceInfo>{};
    final raw = (json['services'] as Map?)?.cast<String, dynamic>() ?? const {};
    for (final s in AiService.values) {
      final m = (raw[s.name] as Map?)?.cast<String, dynamic>();
      if (m == null) continue;
      services[s] = AiServiceInfo(
        service: s,
        label: m['label'] as String? ?? s.name,
        url: Uri.parse(m['url'] as String? ?? ''),
        support: {
          for (final input in HandoffInput.values)
            input: ServiceSupport.parse(m[input.name]),
        },
      );
    }
    return AiHandoffData._(
      json['version'] as int? ?? 0,
      services,
      ((json['legalFacts'] as List?) ?? const []).cast<String>(),
      ((json['envelope'] as Map?) ?? const {}).map(
          (k, v) => MapEntry(k as String, (v as Map).cast<String, dynamic>())),
    );
  }

  /// Envelope text for [key] in [languageCode], falling back to English.
  String text(String languageCode, String key) {
    final v = _envelope[languageCode]?[key] ?? _envelope['en']?[key];
    return v is String ? v : '';
  }

  /// The localized name of an attachment kind ("document", "audio").
  String attachmentName(String languageCode, String kind) {
    Map? names(String lang) => _envelope[lang]?['attachment'] as Map?;
    return (names(languageCode)?[kind] ?? names('en')?[kind] ?? kind)
        .toString();
  }

  AiServiceInfo? info(AiService s) => services[s];
}
