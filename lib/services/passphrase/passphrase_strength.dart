import 'dart:math' as math;

import 'passphrase_lists.dart';
import 'passphrase_policy.dart' show isLeetCharacter, leetVariants;

/// Guesses per second an attacker with one high-end gaming GPU can make against
/// the saved-progress lock: PBKDF2-HMAC-SHA256 at 600,000 iterations (hashcat
/// mode 10900 on an RTX 4090 manages about 8.8 MH/s at 999 iterations, so about
/// 15,000 per second at 600,000). This is the figure the owner was shown.
const double kOfflineGuessesPerSecond = 15000;

/// How hard a passphrase is to guess offline. Drives the 4-level gauge.
enum PassphraseStrength { weak, fair, good, strong }

/// Rough time to crack, for the "about N ..." line next to the gauge.
enum CrackTime {
  underAMinute,
  minutes,
  hours,
  days,
  months,
  years,
  centuries,
}

/// The estimate for one passphrase. [seconds] = [guesses] /
/// [kOfflineGuessesPerSecond] (on average an attacker needs about half of that).
class PassphraseEstimate {
  const PassphraseEstimate({
    required this.guesses,
    required this.seconds,
    required this.crackTime,
    required this.strength,
  });

  final double guesses;
  final double seconds;
  final CrackTime crackTime;
  final PassphraseStrength strength;
}

const double _minute = 60;
const double _hour = 3600;
const double _day = 86400;
const double _year = 365 * _day;

/// weak < 1 day, fair < 1 year, good < 100 years, strong beyond.
PassphraseStrength strengthForSeconds(double seconds) {
  if (seconds < _day) return PassphraseStrength.weak;
  if (seconds < _year) return PassphraseStrength.fair;
  if (seconds < 100 * _year) return PassphraseStrength.good;
  return PassphraseStrength.strong;
}

/// < 1 minute, < 1 hour, < 1 day, < 30 days, < 365 days, < 100 years, else.
CrackTime crackTimeForSeconds(double seconds) {
  if (seconds < _minute) return CrackTime.underAMinute;
  if (seconds < _hour) return CrackTime.minutes;
  if (seconds < _day) return CrackTime.hours;
  if (seconds < 30 * _day) return CrackTime.days;
  if (seconds < _year) return CrackTime.months;
  if (seconds < 100 * _year) return CrackTime.years;
  return CrackTime.centuries;
}

/// Characters examined; a longer passphrase is already "strong".
const int _maxScanLength = 64;

/// The word lists hold nothing longer than this.
const int _maxWordLength = 32;

/// Guesses that put an attacker at the "strong" line.
const double _strongGuesses = 100 * _year * kOfflineGuessesPerSecond;

/// A simplified zxcvbn-style estimate of how many guesses it takes to find
/// [passphrase].
///
/// The passphrase is cut into segments in every possible way and the cheapest
/// cut wins. Each segment is priced as the cheapest of
///  - a dictionary word (rank in the lists, times capitalization and leet
///    variations; x2 when written backwards),
///  - a repeat of a shorter block (cost of the block x repeat count),
///  - a letter or digit sequence ("abc", "9876"),
///  - a run along a QWERTY row ("asdf", "poiuy"),
///  - a year 1900-2039 (distance from [referenceYear], at least 20),
///  - plain brute force (the product of each character's pool).
/// Non-brute-force segments cost at least 10 (one character) or 50 guesses
/// unless one spans the whole passphrase. A cut into m segments multiplies by
/// m! (the attacker also has to find the order). Only the first 64 code points
/// are examined; anything longer is already "strong".
///
/// Cheap enough to run on every keystroke (about a millisecond at 64
/// characters). [referenceYear] defaults to the current year; tests pass one.
PassphraseEstimate estimatePassphrase(
  String passphrase,
  PassphraseLists lists, {
  int? referenceYear,
}) {
  final chars = <String>[];
  var total = 0;
  for (final rune in passphrase.runes) {
    total++;
    if (chars.length < _maxScanLength) chars.add(String.fromCharCode(rune));
  }
  final engine = _Engine(lists, referenceYear ?? DateTime.now().year);
  var guesses = chars.isEmpty ? 1.0 : engine.guesses(chars);
  if (total > _maxScanLength) guesses = math.max(guesses, _strongGuesses);
  final seconds = guesses / kOfflineGuessesPerSecond;
  return PassphraseEstimate(
    guesses: guesses,
    seconds: seconds,
    crackTime: crackTimeForSeconds(seconds),
    strength: strengthForSeconds(seconds),
  );
}

// ---------------------------------------------------------------------------

final RegExp _letter = RegExp(r'\p{L}', unicode: true);
final RegExp _digit = RegExp(r'\p{Nd}', unicode: true);

const List<String> _keyboardRows = [
  'qwertyuiop',
  'asdfghjkl',
  'zxcvbnm',
  '1234567890',
];
final List<String> _keyboardRowsReversed = [
  for (final row in _keyboardRows) row.split('').reversed.join(),
];

/// Distinct keyboard patterns of 3+ keys an attacker would try, per zxcvbn.
const double _keyboardStartGuesses = 94;

final List<double> _logFactorial = () {
  final table = List<double>.filled(_maxScanLength + 2, 0);
  for (var k = 2; k < table.length; k++) {
    table[k] = table[k - 1] + math.log(k);
  }
  return table;
}();

/// n choose k as a double (small arguments only).
double _choose(int n, int k) {
  var result = 1.0;
  for (var i = 1; i <= k; i++) {
    result = result * (n - k + i) / i;
  }
  return result;
}

class _Engine {
  _Engine(this.lists, this.referenceYear);

  final PassphraseLists lists;
  final int referenceYear;

  /// Estimates of repeated blocks, by block text (one call's worth).
  final Map<String, double> _memo = {};

  /// Guesses to find [chars] (one code point per entry; 1 to 64 of them).
  double guesses(List<String> chars) {
    final key = chars.join();
    final cached = _memo[key];
    if (cached != null) return cached;
    final result = _solve(chars);
    _memo[key] = result;
    return result;
  }

  double _solve(List<String> chars) {
    final n = chars.length;
    final lower = [for (final c in chars) c.toLowerCase()];
    final isUpper = [for (var k = 0; k < n; k++) chars[k] != lower[k]];
    final isLower = [for (final c in chars) c != c.toUpperCase()];

    // seg[s * n + e] = cheapest log-cost of the segment chars[s..e].
    final seg = List<double>.filled(n * n, double.infinity);

    // Brute force: product of per-character pools.
    final cum = List<double>.filled(n + 1, 0);
    for (var k = 0; k < n; k++) {
      final pool = _letter.hasMatch(chars[k])
          ? 26
          : _digit.hasMatch(chars[k])
          ? 10
          : 33;
      cum[k + 1] = cum[k] + math.log(pool);
    }
    for (var s = 0; s < n; s++) {
      for (var e = s; e < n; e++) {
        seg[s * n + e] = cum[e + 1] - cum[s];
      }
    }

    // Everything else: floor of 10 / 50 unless it spans the whole passphrase.
    void offer(int s, int e, double guesses) {
      if (!(s == 0 && e == n - 1)) {
        guesses = math.max(guesses, e == s ? 10.0 : 50.0);
      }
      final cost = math.log(guesses);
      if (cost < seg[s * n + e]) seg[s * n + e] = cost;
    }

    _addSequences(chars, offer);

    // Lowercase text and its reverse as two strings, so every token is one
    // substring; offsets map character index -> string offset.
    final isLetter = [for (final c in chars) _letter.hasMatch(c)];
    final isLeet = [for (final c in lower) isLeetCharacter(c)];
    final isKey = [for (final c in lower) _isKeyboardChar(c)];
    final text = lower.join();
    final textBack = lower.reversed.join();
    final off = List<int>.filled(n + 1, 0);
    final offBack = List<int>.filled(n + 1, 0);
    for (var k = 0; k < n; k++) {
      off[k + 1] = off[k] + lower[k].length;
      offBack[k + 1] = offBack[k] + lower[n - 1 - k].length;
    }

    for (var i = 0; i < n; i++) {
      var hasLeet = false;
      var hasLetter = false;
      var allLetters = true; // words and names are letters only
      var allWordish = true; // letters or leet substitutes
      var allKeys = true; // a-z and 0-9, the keyboard rows
      for (var j = i; j < n && j - i < _maxWordLength; j++) {
        final len = j - i + 1;
        hasLeet = hasLeet || isLeet[j];
        hasLetter = hasLetter || isLetter[j];
        allLetters = allLetters && isLetter[j];
        allWordish = allWordish && (isLetter[j] || isLeet[j]);
        allKeys = allKeys && isKey[j];

        final tok = text.substring(off[i], off[j + 1]);
        final rev = textBack.substring(offBack[n - 1 - j], offBack[n - i]);

        final word = _dictionaryGuesses(
          tok,
          rev,
          len,
          allLetters,
          hasLeet && hasLetter && allWordish,
        );
        if (word != null) {
          offer(i, j, word * _upperVariations(isUpper, isLower, i, j));
        }
        if (allKeys && len >= 3 && len <= 10) {
          final keyboard = _keyboardGuesses(tok, len);
          if (keyboard != null) offer(i, j, keyboard);
        }
        if (len == 4 && allKeys) {
          final year = _yearGuesses(tok);
          if (year != null) offer(i, j, year);
        }
        if (len >= 3) {
          final block = _repeatedBlockLength(chars, i, j);
          if (block != null) {
            final base = guesses(chars.sublist(i, i + block));
            offer(i, j, base * (len ~/ block));
          }
        }
      }
    }

    // best[e][m] = cheapest log-cost of chars[0..e) cut into m segments.
    final width = n + 1;
    final best = List<double>.filled(width * width, double.infinity);
    best[0] = 0;
    for (var e = 1; e <= n; e++) {
      for (var s = 0; s < e; s++) {
        final cost = seg[s * n + e - 1];
        for (var m = 1; m <= s + 1; m++) {
          final v = best[s * width + m - 1] + cost;
          if (v < best[e * width + m]) best[e * width + m] = v;
        }
      }
    }

    // Cheapest cut overall: product of the segments x m!.
    var cheapest = double.infinity;
    for (var m = 1; m <= n; m++) {
      final v = best[n * width + m] + _logFactorial[m];
      if (v < cheapest) cheapest = v;
    }
    return math.max(1.0, math.exp(cheapest).roundToDouble());
  }

  // ---- dictionary --------------------------------------------------------

  /// Smallest rank of [word] in any list that applies: `passwords` takes any
  /// length, the word and name lists only letters-only words of 3+ characters.
  int? _rank(String word, int len, bool lettersOnly) {
    var rank = lists.passwords[word];
    if (lettersOnly && len >= 3) {
      final en = lists.enWords[word];
      if (en != null && (rank == null || en < rank)) rank = en;
      final es = lists.esWords[word];
      if (es != null && (rank == null || es < rank)) rank = es;
      final name = lists.names[word];
      if (name != null && (rank == null || name < rank)) rank = name;
    }
    return rank;
  }

  /// Cheapest dictionary reading of the lowercase token [tok] ([rev] is the
  /// token backwards), before capitalization: rank x leet variations, x2 when
  /// backwards. Null when no list has it. [letters]: the token is letters
  /// only. [tryLeet]: it also has a substitute character and a real letter,
  /// and nothing else, so decoded readings are worth trying.
  double? _dictionaryGuesses(
    String tok,
    String rev,
    int len,
    bool letters,
    bool tryLeet,
  ) {
    double? best;
    for (var pass = 0; pass < 2; pass++) {
      final text = pass == 0 ? tok : rev;
      final factor = pass == 0 ? 1.0 : 2.0;
      final plain = _rank(text, len, letters);
      if (plain != null) {
        final g = plain * factor;
        if (best == null || g < best) best = g;
      }
      if (tryLeet) {
        for (final variant in leetVariants(text)) {
          final rank = _rank(variant, len, true);
          if (rank != null && variant.length == text.length) {
            final g = rank * _leetVariations(text, variant) * factor;
            if (best == null || g < best) best = g;
          }
        }
      }
    }
    return best;
  }

  bool _isKeyboardChar(String c) {
    if (c.length != 1) return false;
    final u = c.codeUnitAt(0);
    return (u >= 0x61 && u <= 0x7a) || (u >= 0x30 && u <= 0x39);
  }

  /// zxcvbn's capitalization factor for the token chars[i..j].
  double _upperVariations(List<bool> isUpper, List<bool> isLower, int i, int j) {
    var upper = 0;
    var lower = 0;
    for (var k = i; k <= j; k++) {
      if (isUpper[k]) upper++;
      if (isLower[k]) lower++;
    }
    if (upper == 0) return 1;
    if (lower == 0) return 2; // ALL CAPS
    if (upper == 1 && (isUpper[i] || isUpper[j])) return 2; // Start or enD
    var sum = 0.0;
    for (var k = 1; k <= math.min(upper, lower); k++) {
      sum += _choose(upper + lower, k);
    }
    return sum;
  }

  /// zxcvbn's leet factor: for each substitution (e.g. '4' for 'a'), the ways
  /// of choosing which of the S substituted and U plain letters were swapped.
  double _leetVariations(String token, String decoded) {
    final swapped = <String, int>{};
    for (var k = 0; k < token.length; k++) {
      if (token[k] != decoded[k]) {
        final key = token[k] + decoded[k];
        swapped[key] = (swapped[key] ?? 0) + 1;
      }
    }
    var factor = 1.0;
    swapped.forEach((key, s) {
      final letter = key[1];
      var u = 0;
      for (var k = 0; k < token.length; k++) {
        if (token[k] == letter) u++;
      }
      if (u == 0) {
        factor *= 2;
      } else {
        var sum = 0.0;
        for (var i = 1; i <= math.min(u, s); i++) {
          sum += _choose(u + s, i);
        }
        factor *= sum;
      }
    });
    return factor;
  }

  // ---- keyboard, year, repeat, sequence ----------------------------------

  double? _keyboardGuesses(String tok, int len) {
    for (var r = 0; r < _keyboardRows.length; r++) {
      if (_keyboardRows[r].contains(tok)) return _keyboardStartGuesses * len;
      if (_keyboardRowsReversed[r].contains(tok)) {
        return _keyboardStartGuesses * len * 2;
      }
    }
    return null;
  }

  double? _yearGuesses(String tok) {
    final year = int.tryParse(tok);
    if (year == null || tok.length != 4) return null;
    if (tok.codeUnits.any((c) => c < 0x30 || c > 0x39)) return null;
    if (year < 1900 || year > 2039) return null;
    return math.max((year - referenceYear).abs(), 20).toDouble();
  }

  /// Length of the shortest block that, repeated 2+ times, spells chars[i..j].
  int? _repeatedBlockLength(List<String> chars, int i, int j) {
    final len = j - i + 1;
    for (var block = 1; block <= len ~/ 2; block++) {
      if (len % block != 0) continue;
      var same = true;
      for (var k = block; k < len; k++) {
        if (chars[i + k] != chars[i + k - block]) {
          same = false;
          break;
        }
      }
      if (same) return block;
    }
    return null;
  }

  void _addSequences(
    List<String> chars,
    void Function(int s, int e, double guesses) offer,
  ) {
    final n = chars.length;
    // 0 = other, 1 = ASCII letter, 2 = ASCII digit
    int kind(String c) {
      if (c.length != 1) return 0;
      final u = c.codeUnitAt(0);
      if (u >= 0x30 && u <= 0x39) return 2;
      if ((u >= 0x41 && u <= 0x5a) || (u >= 0x61 && u <= 0x7a)) return 1;
      return 0;
    }

    for (var i = 0; i + 2 < n; i++) {
      final k = kind(chars[i]);
      if (k == 0) continue;
      final step = chars[i + 1].length == 1 && kind(chars[i + 1]) == k
          ? chars[i + 1].codeUnitAt(0) - chars[i].codeUnitAt(0)
          : 0;
      if (step != 1 && step != -1) continue;
      var j = i + 1;
      while (j + 1 < n &&
          kind(chars[j + 1]) == k &&
          chars[j + 1].codeUnitAt(0) - chars[j].codeUnitAt(0) == step) {
        j++;
      }
      for (var e = i + 2; e <= j; e++) {
        final len = e - i + 1;
        final start = 'aAzZ019'.contains(chars[i])
            ? 4.0
            : (k == 2 ? 10.0 : 26.0);
        offer(i, e, start * len * (step < 0 ? 2 : 1));
      }
    }
  }
}
