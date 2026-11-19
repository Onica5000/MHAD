import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Word lists behind the passphrase blocklist and strength estimate.
///
/// Source: zxcvbn-ts (MIT), trimmed by `tool/passphrase/build_lists.py` into
/// `assets/data/passphrase_lists.json`. Every list is lowercase and maps a word
/// to its 1-based rank (1 = most common).
class PassphraseLists {
  const PassphraseLists({
    this.passwords = const {},
    this.enWords = const {},
    this.esWords = const {},
    this.names = const {},
  });

  /// Common passwords, most common first.
  final Map<String, int> passwords;

  /// Common English words.
  final Map<String, int> enWords;

  /// Common Spanish words.
  final Map<String, int> esWords;

  /// English and Spanish first and last names.
  final Map<String, int> names;

  static const String assetPath = 'assets/data/passphrase_lists.json';
  static const String licenseAssetPath = 'assets/licenses/zxcvbn-ts.txt';

  static Future<PassphraseLists>? _loading;

  /// Parses the asset's JSON (see `build_lists.py` for the format).
  factory PassphraseLists.fromJson(String json) {
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return PassphraseLists(
      passwords: _rankMap(decoded['passwords']),
      enWords: _rankMap(decoded['en_words']),
      esWords: _rankMap(decoded['es_words']),
      names: _rankMap(decoded['names']),
    );
  }

  /// Loads the bundled lists once and caches the result. A failed load is not
  /// cached, so the next call tries again.
  static Future<PassphraseLists> load() => _loading ??= _loadAsset();

  static Future<PassphraseLists> _loadAsset() async {
    try {
      return PassphraseLists.fromJson(await rootBundle.loadString(assetPath));
    } catch (_) {
      _loading = null; // let the next call retry
      rethrow;
    }
  }

  static Map<String, int> _rankMap(Object? joined) {
    if (joined is! String || joined.isEmpty) return const {};
    final map = <String, int>{};
    var rank = 0;
    for (final word in joined.split('\n')) {
      if (word.isEmpty) continue;
      map.putIfAbsent(word, () => ++rank);
    }
    return map;
  }
}

/// Registers the word lists' MIT / ODC-BY notices with Flutter's license page.
/// Call once at startup (main.dart).
void registerPassphraseListLicense() {
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString(PassphraseLists.licenseAssetPath);
    yield LicenseEntryWithLineBreaks(const ['zxcvbn-ts word lists'], text);
  });
}
