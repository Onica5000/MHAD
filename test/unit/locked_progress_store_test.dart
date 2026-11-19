import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/services/locked_progress/key_value_store.dart';
import 'package:mhad/services/locked_progress/lock_crypto.dart';
import 'package:mhad/services/locked_progress/locked_format.dart';
import 'package:mhad/services/locked_progress/locked_progress_store.dart';

class _RefusingStore extends MemoryKeyValueStore {
  @override
  bool write(String key, String value) => false;
}

void main() {
  late MemoryKeyValueStore device;
  late MemoryKeyValueStore tab;
  late DateTime now;

  LockedProgressStore store({String? tabId, KeyValueStore? deviceStore,
          KeyValueStore? tabStore}) =>
      LockedProgressStore(
        device: deviceStore ?? device,
        tab: tabStore ?? tab,
        crypto: createLockCrypto(),
        window: () => const Duration(minutes: 30),
        clock: () => now,
        iterations: 1000, // the real setting is 600,000 (kLockIterations)
        tabId: tabId,
      );

  const payload = {
    'directives': [
      {'personal': {'fullName': 'Ana Núñez'}}
    ]
  };

  setUp(() {
    device = MemoryKeyValueStore();
    tab = MemoryKeyValueStore();
    now = DateTime.utc(2026, 11, 18, 20, 0);
  });

  test('a locked copy is unreadable and expires 30 minutes after saving',
      () async {
    final s = store();
    await s.startLocked('Blue horse tea!');
    expect(await s.save(payload), SaveOutcome.saved);
    final raw = device.values[LockedProgressStore.copyKey]!;
    expect(raw, isNot(contains('Ana')));
    expect(s.savedCopy!.saved, now);
    expect(s.savedCopy!.expires, now.add(const Duration(minutes: 30)));
    expect(tab.values[LockedProgressStore.tabCopyKey], isNull);
  });

  test('after a reload the passphrase opens the copy; wrong ones count down',
      () async {
    final a = store(tabId: 'a');
    await a.startLocked('Blue horse tea!');
    await a.save(payload);

    final b = store(tabId: 'b'); // the reloaded page: key gone
    expect(b.mode, ProgressMode.locked);
    expect(b.hasPassphrase, isFalse);
    final wrong = await b.unlock('blue horse tea!');
    expect(wrong, isA<WrongPassphrase>());
    expect((wrong as WrongPassphrase).triesLeft, 9);
    final ok = await b.unlock('Blue horse tea!');
    expect((ok as Unlocked).payload, payload);
    expect(b.hasPassphrase, isTrue);
    expect(device.values[LockedProgressStore.triesKey], isNull);
  });

  test('ten wrong passphrases erase the copy', () async {
    final a = store();
    await a.startLocked('Blue horse tea!');
    await a.save(payload);
    final b = store(tabId: 'b');
    for (var i = 1; i < LockedProgressStore.maxTries; i++) {
      expect(await b.unlock('nope $i'), isA<WrongPassphrase>());
    }
    expect(await b.unlock('nope 10'), isA<CopyGone>());
    expect(device.values[LockedProgressStore.copyKey], isNull);
    expect(await b.unlock('Blue horse tea!'), isA<CopyGone>());
  });

  test('an expired copy is erased unopened on the next start', () async {
    final a = store();
    await a.startLocked('Blue horse tea!');
    await a.save(payload);
    now = now.add(const Duration(minutes: 31));
    final b = store(tabId: 'b');
    b.sweep();
    expect(b.savedCopy, isNull);
    expect(device.values[LockedProgressStore.copyKey], isNull);
  });

  test('the start sweep erases the old readable recovery copies', () {
    for (final k in LockedProgressStore.legacyKeys) {
      device.values[k] = '"x"';
    }
    device.values['flutter.ui_theme'] = '"dark"'; // a setting: kept
    store().sweep();
    for (final k in LockedProgressStore.legacyKeys) {
      expect(device.values[k], isNull, reason: k);
    }
    expect(device.values['flutter.ui_theme'], '"dark"');
  });

  test('the heartbeat moves the expiry; a pending AI answer can stretch it',
      () async {
    final s = store();
    await s.startLocked('Blue horse tea!');
    await s.save(payload);
    now = now.add(const Duration(minutes: 20));
    expect(await s.reseal(), SaveOutcome.saved);
    expect(s.savedCopy!.expires, now.add(const Duration(minutes: 30)));

    final answerDue = now.add(const Duration(minutes: 55));
    await s.save(payload, keepUntil: answerDue);
    expect(s.savedCopy!.expires, answerDue);

    await s.save(payload, keepUntil: now.add(const Duration(days: 9)));
    expect(s.savedCopy!.expires.isBefore(now.add(LockedProgressStore.maxAhead)),
        isTrue,
        reason: 'never trusted further ahead than a day');
  });

  test('a copy whose expiry is too far ahead is not trusted', () async {
    final s = store();
    await s.startLocked('Blue horse tea!');
    await s.save(payload);
    now = now.subtract(const Duration(days: 3)); // the clock went back
    final b = store(tabId: 'b');
    expect(b.savedCopy, isNull);
  });

  test('a second tab that unlocks takes the work over; the first stops saving',
      () async {
    final a = store(tabId: 'a');
    await a.startLocked('Blue horse tea!');
    await a.save(payload);
    final b = store(tabId: 'b');
    await b.unlock('Blue horse tea!');
    expect(a.openElsewhere, isTrue);
    expect(await a.save({'x': 'older'}), SaveOutcome.otherTab);
    expect(await b.save(payload), SaveOutcome.saved);
    // B goes quiet (closed) for longer than ownerFresh: A may save again.
    now = now.add(LockedProgressStore.ownerFresh + const Duration(seconds: 1));
    expect(await a.save(payload), SaveOutcome.saved);
  });

  test('choosing "No" in a new tab leaves another tab\'s copy alone', () async {
    final a = store(tabId: 'a');
    await a.startLocked('Blue horse tea!');
    await a.save(payload);
    final other = store(tabId: 'c', tabStore: MemoryKeyValueStore());
    other.startTabOnly();
    expect(device.values[LockedProgressStore.copyKey], isNotNull);
  });

  test('tab only keeps a plain copy in this tab and nothing on the device',
      () async {
    final s = store();
    s.startTabOnly();
    expect(await s.save({'directives': []}), SaveOutcome.saved);
    expect(s.tabCopy, {'directives': []});
    expect(device.values.keys.where((k) => k.startsWith('mhad_locked')),
        isEmpty);
  });

  test('"Delete saved progress" erases the copy and stops keeping one',
      () async {
    final s = store();
    await s.startLocked('Blue horse tea!');
    await s.save(payload);
    s.stopKeeping();
    expect(device.values[LockedProgressStore.copyKey], isNull);
    expect(s.mode, ProgressMode.tabOnly);
    expect(await s.reseal(), SaveOutcome.notKept);
  });

  test('a download is locked with the same passphrase and has no expiry',
      () async {
    final s = store();
    await s.startLocked('Blue horse tea!');
    final text = (await s.lockForDownload({'data': 1}))!;
    final blob = LockedBlob.tryParse(text)!;
    expect(blob.header.kind, LockedKind.file);
    expect(blob.header.expires, isNull);

    final other = store(tabId: 'z', tabStore: MemoryKeyValueStore());
    expect(() => other.openFile(blob, 'wrong'),
        throwsA(isA<LockOpenException>()));
    expect(await other.openFile(blob, 'Blue horse tea!'), {'data': 1});
    other.startLockedWithOpenedFile();
    expect(other.hasPassphrase, isTrue);
    expect(other.mode, ProgressMode.locked);
  });

  test('a browser that refuses to store is reported, not hidden', () async {
    final s = store(deviceStore: _RefusingStore());
    await s.startLocked('Blue horse tea!');
    expect(await s.save(payload), SaveOutcome.refused);
  });

  test('after a reload with nothing to unlock, the choice is asked again',
      () async {
    final a = store(tabId: 'a');
    await a.startLocked('Blue horse tea!'); // chose, but nothing saved yet
    final b = store(tabId: 'b');
    b.forgetChoiceIfNothingToUnlock();
    expect(b.mode, ProgressMode.undecided);
  });
}
