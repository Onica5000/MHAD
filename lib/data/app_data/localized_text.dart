/// Text people read that comes from a data file (`app_data.json`) instead of
/// the ARB files: a plain string (English only) or one entry per language,
/// `{"en": "...", "es": "..."}`. [forLanguage] falls back to English when a
/// language has no text, so a half-translated update never shows a blank.
///
/// Use it for every reader-facing string in the data files (facts, referral
/// descriptions, the breach notice) — `app_data_localized_text_test` checks
/// that the bundled ones carry Spanish.
class LocalizedText {
  const LocalizedText(this.en, [this.translations = const {}]);

  /// The English text (the fallback for every language).
  final String en;

  /// Language code → text, for languages other than English.
  final Map<String, String> translations;

  static const empty = LocalizedText('');

  factory LocalizedText.fromJson(Object? raw) {
    if (raw is Map) {
      final m = raw.cast<String, dynamic>();
      return LocalizedText((m['en'] ?? '').toString().trim(), {
        for (final e in m.entries)
          if (e.key != 'en' &&
              e.value is String &&
              (e.value as String).trim().isNotEmpty)
            e.key: (e.value as String).trim(),
      });
    }
    return LocalizedText((raw ?? '').toString().trim());
  }

  bool get isEmpty => en.isEmpty && translations.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// The text for [languageCode] (e.g. `'es'`), else the English.
  String forLanguage(String languageCode) => translations[languageCode] ?? en;
}
