import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// A single contact / resource entry (crisis line, advocacy org, etc.).
class ContactEntry {
  final String name;
  final String? phone;
  final String? tdd;
  final String? office;
  final String? web;
  final String? tagline;
  final String? availability;

  const ContactEntry({
    required this.name,
    this.phone,
    this.tdd,
    this.office,
    this.web,
    this.tagline,
    this.availability,
  });

  factory ContactEntry.fromJson(Map<String, dynamic> m) => ContactEntry(
        name: (m['name'] ?? '').toString(),
        phone: m['phone']?.toString(),
        tdd: m['tdd']?.toString(),
        office: m['office']?.toString(),
        web: m['web']?.toString(),
        tagline: m['tagline']?.toString(),
        availability: m['availability']?.toString(),
      );
}

/// A "Get help" referral partner row (a [ContactEntry] plus its display sub).
class ReferralPartner {
  final ContactEntry contact;
  final String sub;
  const ReferralPartner({required this.contact, required this.sub});
}

/// The app's dynamic, updatable facts — loaded once from
/// `assets/data/app_data.json` at startup (see [load]). This is the source of
/// truth for data that drifts over time (contacts now; AI config and legal
/// facts in later phases) so it can be changed via the admin propose/approve
/// flow without code edits.
///
/// Exposed as a load-once singleton ([instance] / the top-level [appData]
/// getter) because it's read from non-widget code too (PDF generators, AI
/// prompt builders, services) that can't reach a Riverpod provider. The data is
/// immutable at runtime in this phase; when the admin update flow can mutate it
/// live, this can move behind a provider for reactivity.
class AppData {
  final Map<String, ContactEntry> contacts;
  final List<ReferralPartner> referralPartners;

  const AppData({required this.contacts, required this.referralPartners});

  /// Look up a contact by its key (e.g. `'crisis988'`). Returns an empty
  /// [ContactEntry] rather than null so call sites never crash on a missing key.
  ContactEntry contact(String key) =>
      contacts[key] ?? const ContactEntry(name: '');

  /// Null-safe phone for [key] — empty string if absent (a `tel:` built from it
  /// just won't launch, rather than crashing or printing "null").
  String phoneOf(String key) => contact(key).phone ?? '';

  /// Null-safe website URL for [key] — empty string if absent.
  String webOf(String key) => contact(key).web ?? '';

  factory AppData.fromJson(Map<String, dynamic> json) {
    final contactsJson =
        (json['contacts'] as Map?)?.cast<String, dynamic>() ?? const {};
    final contacts = <String, ContactEntry>{
      for (final e in contactsJson.entries)
        e.key: ContactEntry.fromJson((e.value as Map).cast<String, dynamic>()),
    };
    final partners = <ReferralPartner>[];
    for (final raw in (json['referralPartners'] as List?) ?? const []) {
      final m = (raw as Map).cast<String, dynamic>();
      final c = contacts[m['contact']?.toString()];
      if (c != null) {
        partners.add(
            ReferralPartner(contact: c, sub: (m['sub'] ?? '').toString()));
      }
    }
    return AppData(contacts: contacts, referralPartners: partners);
  }

  /// The loaded data. Initialised to a minimal [_fallback] so reads never throw
  /// before [load] runs (tests, probes) or if the asset fails to parse.
  static AppData instance = _fallback;

  /// Parse `assets/data/app_data.json` and publish it to [instance]. Called
  /// from `main()` before `runApp`. Falls back to [_fallback] on any error so a
  /// corrupt asset can never brick startup.
  static Future<AppData> load() async {
    try {
      final raw = await rootBundle.loadString('assets/data/app_data.json');
      instance = AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      instance = _fallback;
    }
    return instance;
  }

  /// Compact safety net: the genuinely critical contacts, so crisis features
  /// keep working even if the asset can't be read (should never happen — it's
  /// bundled). The full set lives in the JSON.
  static final AppData _fallback = AppData.fromJson(const {
    'contacts': {
      'crisis988': {
        'name': '988 Suicide & Crisis Lifeline',
        'phone': '988',
        'tagline': 'Call or text 988',
        'availability': '24/7, free, confidential',
      },
      'crisisTextLine': {
        'name': 'Crisis Text Line',
        'phone': '741741',
        'tagline': 'Text HOME to 741741',
      },
      'paProtectionAdvocacy': {
        'name': 'PA Protection & Advocacy',
        'phone': '1-800-692-7443',
        'tdd': '1-877-375-7139',
        'web': 'https://www.disabilityrightspa.org/',
        'tagline': 'Your rights under Act 194',
      },
    },
    'referralPartners': [],
  });
}

/// Ergonomic global accessor for the loaded [AppData].
AppData get appData => AppData.instance;
