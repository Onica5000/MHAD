import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/services/passphrase/passphrase_lists.dart';
import 'package:mhad/services/passphrase/passphrase_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final lists = PassphraseLists.fromJson(
    File('assets/data/passphrase_lists.json').readAsStringSync(),
  );
  Set<PassphraseRequirement> unmet(String p) =>
      unmetPassphraseRequirements(p, lists);

  group('each rule alone', () {
    test('a good passphrase meets every rule', () {
      expect(unmet('Blue horse tea!'), isEmpty);
    });

    test('minLength', () {
      expect(kPassphraseMinLength, 4);
      expect(unmet('A b'), {PassphraseRequirement.minLength});
      expect(unmet('A b!'), isEmpty);
    });

    test('lowercase', () {
      expect(unmet('AB!C'), {PassphraseRequirement.lowercase});
    });

    test('uppercase', () {
      expect(unmet('ab!c'), {PassphraseRequirement.uppercase});
    });

    test('special', () {
      expect(unmet('Qwxz'), {PassphraseRequirement.special});
    });

    test('notCommon', () {
      expect(unmet('Password1!'), {PassphraseRequirement.notCommon});
    });

    test('unmet rules come back in display order', () {
      const tiny = PassphraseLists(passwords: {'12': 1});
      expect(unmetPassphraseRequirements('12', tiny).toList(), [
        PassphraseRequirement.minLength,
        PassphraseRequirement.lowercase,
        PassphraseRequirement.uppercase,
        PassphraseRequirement.special,
        PassphraseRequirement.notCommon,
      ]);
    });

    test('no maximum length', () {
      final long = 'Aa! ${'x' * 5000}';
      expect(unmet(long), isEmpty);
    });
  });

  group('Unicode', () {
    test('n-tilde and e-acute are lowercase letters', () {
      expect(unmet('ñ'), isNot(contains(PassphraseRequirement.lowercase)));
      expect(unmet('é'), isNot(contains(PassphraseRequirement.lowercase)));
      expect(unmet('ñ'), contains(PassphraseRequirement.uppercase));
    });

    test('N-tilde and E-acute are capital letters', () {
      expect(unmet('Ñ'), isNot(contains(PassphraseRequirement.uppercase)));
      expect(unmet('É'), isNot(contains(PassphraseRequirement.uppercase)));
      expect(unmet('É'), contains(PassphraseRequirement.lowercase));
    });

    test('inverted marks are special', () {
      expect(unmet('Año¿'), isEmpty);
      expect(unmet('Año¡'), isEmpty);
      expect(unmet('Año'), contains(PassphraseRequirement.special));
    });

    test('a Spanish passphrase passes', () {
      expect(unmet('Mi casa azul!'), isEmpty);
      expect(unmet('¿Dónde está Ñandú?'), isEmpty);
    });

    test('length counts code points, not UTF-16 units', () {
      // One emoji = 1 code point, 2 UTF-16 units; it is special, not a letter.
      expect(unmet('aB😀'), {PassphraseRequirement.minLength});
      expect(unmet('aB😀😀'), isEmpty);
      expect('aB😀'.length, 4); // would pass if units were counted
    });
  });

  group('what counts as special', () {
    test('a space counts', () {
      expect(unmet('Ab c'), isEmpty);
    });

    test('digits do not count', () {
      expect(unmet('Ab12'), {PassphraseRequirement.special});
      expect(unmet('Ab1 '), isEmpty);
    });

    test('punctuation and symbols count', () {
      for (final mark in ['!', '-', '_', '#', '€', '~', '.']) {
        expect(
          unmet('Ab$mark'),
          isNot(contains(PassphraseRequirement.special)),
          reason: mark,
        );
      }
    });
  });

  group('common-passphrase blocklist', () {
    test('plain, decorated and disguised forms are blocked', () {
      for (final p in [
        'Password1!',
        'P@ssw0rd!',
        'I love you!',
        'Qwerty123#',
        'PASSWORD',
        'p a s s w o r d',
        '!!Letmein!!',
        '  Dragon  ',
        'Iloveyou2',
        'Monkey#1',
      ]) {
        expect(
          unmet(p),
          contains(PassphraseRequirement.notCommon),
          reason: p,
        );
      }
    });

    test('leet-decoded readings are blocked (1 and ! also read as l)', () {
      expect(isCommonPassphrase(r'P4$$w0rD', lists), isTrue);
      expect(isCommonPassphrase('b@seba11', lists), isTrue); // 1 -> l
      expect(isCommonPassphrase('L3tm31n', lists), isTrue);
    });

    test('a common word inside a longer passphrase is not blocked', () {
      for (final p in [
        'Blue horse tea!',
        'Mi casa azul!',
        'My dragon ate 3 apples.',
        'correct Horse battery staple',
      ]) {
        expect(unmet(p), isEmpty, reason: p);
      }
    });

    test('an empty blocklist blocks nothing', () {
      expect(isCommonPassphrase('Password1!', const PassphraseLists()), isFalse);
    });

    test('many leet characters stay cheap', () {
      final p = '1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!' * 4;
      final sw = Stopwatch()..start();
      isCommonPassphrase(p, lists);
      expect(sw.elapsedMilliseconds, lessThan(200));
    });
  });

  group('PassphraseLists', () {
    test('fromJson gives 1-based ranks per list', () {
      final parsed = PassphraseLists.fromJson(
        '{"_source":{},"passwords":"abc\\ndef\\nabc","en_words":"one\\ntwo",'
        '"es_words":"uno","names":""}',
      );
      expect(parsed.passwords, {'abc': 1, 'def': 2});
      expect(parsed.enWords, {'one': 1, 'two': 2});
      expect(parsed.esWords, {'uno': 1});
      expect(parsed.names, isEmpty);
    });

    test('the shipped lists are lowercase, ranked and non-trivial', () {
      expect(lists.passwords['password'], 2);
      expect(lists.passwords.length, greaterThan(5000));
      expect(lists.enWords.length, greaterThan(5000));
      expect(lists.esWords.length, greaterThan(5000));
      expect(lists.names.length, greaterThan(2000));
      for (final map in [
        lists.passwords,
        lists.enWords,
        lists.esWords,
        lists.names,
      ]) {
        expect(map.keys.every((w) => w == w.toLowerCase()), isTrue);
      }
    });

    test('load() reads the bundled asset once', () async {
      final first = await PassphraseLists.load();
      expect(first.passwords['password'], 2);
      expect(identical(await PassphraseLists.load(), first), isTrue);
    });

    test('the license is registered under its name', () async {
      registerPassphraseListLicense();
      final entries = await LicenseRegistry.licenses.toList();
      final mine = entries.where(
        (e) => e.packages.contains('zxcvbn-ts word lists'),
      );
      expect(mine, hasLength(1));
      final text = mine.single.paragraphs.map((p) => p.text).join('\n');
      expect(text, contains('Permission is hereby granted'));
      expect(text, contains('Dan Wheeler'));
    });
  });
}
