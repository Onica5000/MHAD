import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/services/reminder_scheduler.dart';

/// Locks the renewal/check-in window predicates that drive the in-app reminder
/// sheets. The renewal path only came back to life once `expirationDate` began
/// being written (see directive_expiration_test); these guard the window math.
void main() {
  late AppDatabase db;
  late DirectiveRepository repo;
  late Directive base;

  setUpAll(() => AppData.instance =
      AppData.fromJson(const {})); // renewalWindow 28, checkInWindow 90

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DirectiveRepository(db);
    final id = await repo.createDirective(FormType.combined);
    base = (await repo.getDirectiveById(id))!;
  });

  tearDown(() => db.close());

  group('renewalDue', () {
    Directive withExpiry(DateTime exp) =>
        base.copyWith(expirationDate: Value(exp.millisecondsSinceEpoch));

    test('true inside the 28-day window', () {
      final d = withExpiry(DateTime(2028, 1, 1));
      expect(ReminderScheduler.renewalDue(d, DateTime(2027, 12, 20)), isTrue);
    });

    test('false well outside the window', () {
      final d = withExpiry(DateTime(2028, 1, 1));
      expect(ReminderScheduler.renewalDue(d, DateTime(2027, 11, 1)), isFalse);
    });

    test('true once past expiry (needs renewal)', () {
      final d = withExpiry(DateTime(2028, 1, 1));
      expect(ReminderScheduler.renewalDue(d, DateTime(2028, 2, 1)), isTrue);
    });

    test('false when expirationDate is null (never fires)', () {
      final d = base.copyWith(expirationDate: const Value(null));
      expect(ReminderScheduler.renewalDue(d, DateTime(2028, 1, 1)), isFalse);
    });
  });

  group('checkInDue', () {
    final now = DateTime(2026, 6, 1);

    test('true after >= 90 days since last edit', () {
      final d = base.copyWith(
          updatedAt: now.subtract(const Duration(days: 100)).millisecondsSinceEpoch);
      expect(ReminderScheduler.checkInDue(d, now), isTrue);
    });

    test('false when recently edited', () {
      final d = base.copyWith(
          updatedAt: now.subtract(const Duration(days: 10)).millisecondsSinceEpoch);
      expect(ReminderScheduler.checkInDue(d, now), isFalse);
    });
  });
}
