import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';

/// Regression coverage for `setExecutionDate` deriving `expirationDate`.
///
/// The bug: `expirationDate` was never written anywhere, so it stayed null on
/// every signed directive — the renewal reminder ([ReminderScheduler]) filtered
/// those out (`if (exp == null) return false`) and every "Expires …" display
/// (export, wallet card, past-directive) was permanently hidden, despite the app
/// promising "we'll remind you when your directive is approaching expiration."
void main() {
  late AppDatabase db;
  late DirectiveRepository repo;
  late int directiveId;

  setUpAll(() => AppData.instance = AppData.fromJson(const {})); // validityYears = 2

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DirectiveRepository(db);
    directiveId = await repo.createDirective(FormType.combined);
  });

  tearDown(() => db.close());

  test('signing derives a two-year expiration date', () async {
    final now = DateTime(2026, 6, 30, 10, 30, 0).millisecondsSinceEpoch;
    await repo.setExecutionDate(directiveId, now);

    final d = await repo.getDirectiveById(directiveId);
    expect(d!.executionDate, now);
    expect(d.expirationDate, isNotNull,
        reason: 'expiration must be derived so reminders/displays work');

    final exp = DateTime.fromMillisecondsSinceEpoch(d.expirationDate!);
    expect(exp.year, 2028, reason: 'PA validity is two years from execution');
    expect(exp.month, 6);
    expect(exp.day, 30);
  });

  test('reverting to draft (now == 0) clears both dates', () async {
    await repo.setExecutionDate(
        directiveId, DateTime(2026, 6, 30).millisecondsSinceEpoch);
    await repo.setExecutionDate(directiveId, 0); // revert sentinel

    final d = await repo.getDirectiveById(directiveId);
    expect(d!.executionDate, 0);
    expect(d.expirationDate, isNull,
        reason: 'an unsigned draft must not carry a stale expiration');
  });
}
