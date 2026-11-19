import 'passphrase_lists.dart';

/// Shortest passphrase accepted. There is no maximum.
const int kPassphraseMinLength = 4;

/// The rules a passphrase must meet. Enum order = display order.
enum PassphraseRequirement { minLength, lowercase, uppercase, special, notCommon }

final RegExp _lowercaseLetter = RegExp(r'\p{Ll}', unicode: true);
final RegExp _uppercaseLetter = RegExp(r'\p{Lu}', unicode: true);

/// "Special" = any character that is not a letter and not a number. A space
/// counts; a digit does not.
final RegExp _special = RegExp(r'[^\p{L}\p{N}]', unicode: true);

final RegExp _whitespace = RegExp(r'\s', unicode: true);
final RegExp _edgeNonLetters = RegExp(r'^\P{L}+|\P{L}+$', unicode: true);

/// Character substitutions people use to disguise a word ("p@ssw0rd").
/// Where a character has several readings the first is the primary one.
const Map<String, List<String>> _leet = {
  '@': ['a'],
  '4': ['a'],
  '8': ['b'],
  '(': ['c'],
  '3': ['e'],
  '6': ['g'],
  '1': ['i', 'l'],
  '!': ['i', 'l'],
  '0': ['o'],
  r'$': ['s'],
  '5': ['s'],
  '7': ['t'],
  '+': ['t'],
  '2': ['z'],
};

/// Most leet readings tried per form (several ambiguous characters multiply).
const int _maxLeetVariants = 16;

/// The requirements [passphrase] does not meet, in [PassphraseRequirement]
/// order. Empty means it is acceptable.
///
/// Length counts Unicode code points. Letters are Unicode-aware (n-tilde and
/// e-acute are lowercase, their capitals uppercase).
///
/// `notCommon` is unmet when the passphrase, or a lenient reading of it, is in
/// the common-password list: lowercased, with whitespace removed, with leet
/// characters decoded, and each of those with leading and trailing non-letters
/// stripped ("Password1!" -> "password"). A common word merely appearing
/// inside a longer phrase does not count.
Set<PassphraseRequirement> unmetPassphraseRequirements(
  String passphrase,
  PassphraseLists lists,
) {
  final unmet = <PassphraseRequirement>{};
  if (passphrase.runes.length < kPassphraseMinLength) {
    unmet.add(PassphraseRequirement.minLength);
  }
  if (!_lowercaseLetter.hasMatch(passphrase)) {
    unmet.add(PassphraseRequirement.lowercase);
  }
  if (!_uppercaseLetter.hasMatch(passphrase)) {
    unmet.add(PassphraseRequirement.uppercase);
  }
  if (!_special.hasMatch(passphrase)) {
    unmet.add(PassphraseRequirement.special);
  }
  if (isCommonPassphrase(passphrase, lists)) {
    unmet.add(PassphraseRequirement.notCommon);
  }
  return unmet;
}

/// Whether any normalized form of [passphrase] is in `lists.passwords`.
bool isCommonPassphrase(String passphrase, PassphraseLists lists) {
  if (lists.passwords.isEmpty) return false;
  final lower = passphrase.toLowerCase();
  final bases = <String>{lower, lower.replaceAll(_whitespace, '')};
  final forms = <String>{...bases};
  for (final base in bases) {
    forms.addAll(leetVariants(base));
  }
  for (final form in forms.toList()) {
    forms.add(form.replaceAll(_edgeNonLetters, ''));
  }
  for (final form in forms) {
    if (form.isNotEmpty && lists.passwords.containsKey(form)) return true;
  }
  return false;
}

/// Whether [char] (one character) is a leet substitute such as `@` or `0`.
bool isLeetCharacter(String char) => _leet.containsKey(char);

/// Leet-decoded readings of [text] (at most [_maxLeetVariants]); empty when
/// [text] has no leet characters. Shared with the strength estimator.
List<String> leetVariants(String text) {
  if (!text.runes.any((r) => _leet.containsKey(String.fromCharCode(r)))) {
    return const [];
  }
  var variants = <String>[''];
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    final options = _leet[char] ?? [char];
    final next = <String>[];
    for (final option in options) {
      for (final v in variants) {
        if (next.length >= _maxLeetVariants) break;
        next.add(v + option);
      }
    }
    variants = next;
  }
  return variants;
}
