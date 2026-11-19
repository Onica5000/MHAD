import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/services/passphrase/passphrase_lists.dart';
import 'package:mhad/services/passphrase/passphrase_strength.dart';

void main() {
  final lists = PassphraseLists.fromJson(
    File('assets/data/passphrase_lists.json').readAsStringSync(),
  );
  PassphraseEstimate estimate(String p) =>
      estimatePassphrase(p, lists, referenceYear: 2026);

  group('gauge levels', () {
    test('weak', () {
      for (final p in ['Ab1!', 'Password1!', 'qwerty', '1234', 'Contraseña1!']) {
        final e = estimate(p);
        expect(e.strength, PassphraseStrength.weak, reason: p);
        expect(e.seconds, lessThan(86400), reason: p);
      }
    });

    test('fair: eight random lowercase letters is about 26^8 guesses', () {
      final e = estimate('xkqzvbmw');
      expect(e.strength, PassphraseStrength.fair);
      expect(e.crackTime, CrackTime.months);
      expect(e.guesses, closeTo(math.pow(26, 8), math.pow(26, 8) * 0.01));
    });

    test('strong: a four-word passphrase', () {
      final e = estimate('correct horse battery staple');
      expect(e.strength, PassphraseStrength.strong);
      expect(e.crackTime, CrackTime.centuries);
    });

    test('good or strong: three plain words with a mark', () {
      expect(estimate('Blue horse tea!').strength, isIn([
        PassphraseStrength.good,
        PassphraseStrength.strong,
      ]));
    });

    test('words in either language are found', () {
      expect(estimate('casa').guesses, lessThan(1000)); // Spanish, rank ~100
      expect(estimate('horse').guesses, lessThan(2000)); // English
    });
  });

  group('how the estimate is built', () {
    test('seconds = guesses / the offline rate', () {
      final e = estimate('xkqzvbmw');
      expect(kOfflineGuessesPerSecond, 15000);
      expect(e.seconds, closeTo(e.guesses / 15000, 1e-6));
    });

    test('a common password costs its rank', () {
      expect(estimate('password').guesses, 2);
      expect(estimate('qwerty').guesses, 4);
    });

    test('capitalization multiplies the guesses', () {
      expect(estimate('Password').guesses, 4); // first letter: x2
      expect(estimate('PASSWORD').guesses, 4); // all caps: x2
      expect(estimate('pAsSwOrD').guesses, greaterThan(20));
    });

    test('reversed words cost double', () {
      expect(estimate('drowssap').guesses, 4);
    });

    test('leet speak is decoded', () {
      final plain = estimate('password').guesses;
      final leet = estimate(r'p@$$w0rd').guesses;
      expect(leet, greaterThan(plain));
      expect(leet, lessThan(1000));
    });

    test('sequences, keyboard runs and repeats are cheap', () {
      expect(estimate('abcdefgh').guesses, lessThan(1000)); // 4 x 8
      expect(estimate('hgfedcba').guesses, lessThan(1000)); // descending
      expect(estimate('uiopasdf').guesses, lessThan(500000)); // two runs, 2!
      expect(estimate('zxcvbnm').guesses, lessThan(1000));
      expect(estimate('xqzxqzxqzxqz').guesses, lessThan(26 * 26 * 26 * 10));
    });

    test('a year costs its distance from the reference year', () {
      // Not in the password list, so the year rule decides.
      expect(lists.passwords.containsKey('1912'), isFalse);
      final past = estimatePassphrase('1912', lists, referenceYear: 2026);
      final near = estimatePassphrase('1912', lists, referenceYear: 1920);
      expect(past.guesses, 114);
      expect(near.guesses, 20); // floored at 20
    });

    test('segments multiply, times m!', () {
      // Cheapest cut: "Password1" (rank 229, x2 capital) + "!" (33), 2 segments.
      expect(lists.passwords['password1'], 229);
      expect(estimate('Password1!').guesses, 229 * 2 * 33 * 2);
    });

    test('segments below the whole passphrase cost at least 50 guesses', () {
      // "password" alone is 2; with a mark appended it is a 50-guess floor
      // x 33 for "!" x 2! orders.
      expect(estimate('password!').guesses, 50 * 33 * 2);
    });

    test('empty input is a single guess', () {
      final e = estimate('');
      expect(e.guesses, 1);
      expect(e.strength, PassphraseStrength.weak);
      expect(e.crackTime, CrackTime.underAMinute);
    });
  });

  group('appending characters', () {
    test('random characters never lower the guesses', () {
      const alphabet =
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
          r'!@#$%^&*()-_=+[]{};:,.<>/? ';
      final rng = math.Random(20261118);
      for (final base in [
        'Ab',
        'Password',
        'Blue horse',
        'xkqzvbmw',
        'Contraseña',
        'correct horse battery',
        'Qx7!',
      ]) {
        var p = base;
        var previous = estimate(p).guesses;
        for (var i = 0; i < 30; i++) {
          p += alphabet[rng.nextInt(alphabet.length)];
          final now = estimate(p).guesses;
          expect(now, greaterThanOrEqualTo(previous), reason: p);
          previous = now;
        }
      }
    });
  });

  group('thresholds', () {
    const day = 86400.0;
    const year = 365 * day;

    test('strengthForSeconds at its boundaries', () {
      expect(strengthForSeconds(0), PassphraseStrength.weak);
      expect(strengthForSeconds(day - 0.001), PassphraseStrength.weak);
      expect(strengthForSeconds(day), PassphraseStrength.fair);
      expect(strengthForSeconds(year - 1), PassphraseStrength.fair);
      expect(strengthForSeconds(year), PassphraseStrength.good);
      expect(strengthForSeconds(100 * year - 1), PassphraseStrength.good);
      expect(strengthForSeconds(100 * year), PassphraseStrength.strong);
      expect(strengthForSeconds(double.maxFinite), PassphraseStrength.strong);
    });

    test('crackTimeForSeconds at its boundaries', () {
      expect(crackTimeForSeconds(0), CrackTime.underAMinute);
      expect(crackTimeForSeconds(59.9), CrackTime.underAMinute);
      expect(crackTimeForSeconds(60), CrackTime.minutes);
      expect(crackTimeForSeconds(3599), CrackTime.minutes);
      expect(crackTimeForSeconds(3600), CrackTime.hours);
      expect(crackTimeForSeconds(day - 1), CrackTime.hours);
      expect(crackTimeForSeconds(day), CrackTime.days);
      expect(crackTimeForSeconds(30 * day - 1), CrackTime.days);
      expect(crackTimeForSeconds(30 * day), CrackTime.months);
      expect(crackTimeForSeconds(year - 1), CrackTime.months);
      expect(crackTimeForSeconds(year), CrackTime.years);
      expect(crackTimeForSeconds(100 * year - 1), CrackTime.years);
      expect(crackTimeForSeconds(100 * year), CrackTime.centuries);
    });

    test('an estimate carries the matching crackTime and strength', () {
      for (final p in ['qwerty', 'xkqzvbmw', 'Blue horse tea!']) {
        final e = estimate(p);
        expect(e.crackTime, crackTimeForSeconds(e.seconds), reason: p);
        expect(e.strength, strengthForSeconds(e.seconds), reason: p);
      }
    });
  });

  group('long and slow inputs', () {
    test('beyond 64 code points is strong, whatever it is', () {
      for (final p in ['a' * 65, 'ab' * 100, 'Qx7!${'z' * 500}']) {
        final e = estimate(p);
        expect(e.strength, PassphraseStrength.strong);
        expect(e.guesses.isFinite, isTrue);
        expect(e.guesses, greaterThan(0));
      }
    });

    test('only the first 64 code points are examined', () {
      const head = 'Qx7!vkLm-pa9s ZyR3t#bnWe5d?uFg2hJc8o&kEi4lMn1rTq6yUvXzAs0B';
      final a = estimate('${head}1234');
      final b = estimate('${head}1234${'w' * 400}');
      expect(a.guesses.isFinite, isTrue);
      expect(b.guesses, greaterThanOrEqualTo(a.guesses));
    });

    test('64 characters take well under 50 ms', () {
      final inputs = [
        'Qx7!vkLm-pa9s ZyR3t#bnWe5d?uFg2hJc8o&kEi4lMn1rTq6yUvXzAs0B',
        ('blue horse tea ' * 5).substring(0, 64),
        ('p@ssw0rd4abc9876qwertyaaaa1998' * 3).substring(0, 64),
        'a' * 64,
        'ab' * 32,
        r'1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!1!',
      ];
      for (final p in inputs) {
        estimate(p); // warm up the JIT
        final sw = Stopwatch()..start();
        estimate(p);
        expect(sw.elapsedMilliseconds, lessThan(50), reason: p);
      }
    });
  });
}
