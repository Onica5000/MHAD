import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/services/admin_backup_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Verifies the admin backup history: append, list (newest-first), the 1-year
/// archive cutoff, and that archived (gzip-compressed) snapshots still read back
/// byte-for-byte.
void main() {
  const target = 'appData';
  const dayMs = 86400000;

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('append + list returns the snapshot, newest first', () async {
    await AdminBackupStore.append(target, '{"a":1}', 1000);
    await AdminBackupStore.append(target, '{"a":2}', 2000);
    final list = await AdminBackupStore.list(target);
    expect(list.map((b) => b.ts).toList(), [2000, 1000]);
    expect(list.every((b) => !b.archived), isTrue);
  });

  test('read returns the exact JSON for an active snapshot', () async {
    await AdminBackupStore.append(target, '{"hello":"world"}', 5000);
    expect(await AdminBackupStore.read(target, 5000), '{"hello":"world"}');
  });

  test('snapshots older than a year are archived on the next append', () async {
    final now = 500 * dayMs;
    final old = now - (AdminBackupStore.retentionDays + 10) * dayMs;
    // First snapshot is "old" relative to the second append's clock.
    await AdminBackupStore.append(target, '{"old":true}', old);
    await AdminBackupStore.append(target, '{"new":true}', now);

    final list = await AdminBackupStore.list(target);
    expect(list.length, 2);
    final archived = list.firstWhere((b) => b.ts == old);
    final active = list.firstWhere((b) => b.ts == now);
    expect(archived.archived, isTrue, reason: '>1yr old → archived');
    expect(active.archived, isFalse, reason: '<1yr → active');
  });

  test('archived snapshots decompress back to the original JSON', () async {
    final now = 500 * dayMs;
    final old = now - (AdminBackupStore.retentionDays + 10) * dayMs;
    const payload = '{"big":"some content with unicode — 20× ✓","n":42}';
    await AdminBackupStore.append(target, payload, old);
    await AdminBackupStore.append(target, '{"new":true}', now);
    // The old one is now gzip-archived; reading it must round-trip exactly.
    expect(await AdminBackupStore.read(target, old), payload);
  });

  test('histories are independent per target', () async {
    await AdminBackupStore.append('appData', '{"x":1}', 1000);
    await AdminBackupStore.append('educational', '{"y":2}', 1000);
    expect((await AdminBackupStore.list('appData')).length, 1);
    expect(await AdminBackupStore.read('educational', 1000), '{"y":2}');
    expect(await AdminBackupStore.read('appData', 9999), isNull);
  });
}
