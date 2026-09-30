import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/ui/widgets/breach_notice_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// V4-H3: the FTC HBNR in-app notice channel promised by docs/BREACH_PLAN.md.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BreachNotice.fromJson', () {
    test('missing block or empty id → no notice', () {
      expect(BreachNotice.fromJson(null), isNull);
      expect(BreachNotice.fromJson('nope'), isNull);
      expect(BreachNotice.fromJson(const {'id': '  ', 'title': 'x'}), isNull);
    });

    test('parses every content field and drops blank contacts', () {
      final n = BreachNotice.fromJson(const {
        'id': '2026-10-01-test',
        'date': 'October 1, 2026',
        'title': 'T',
        'whatHappened': 'WH',
        'informationInvolved': 'II',
        'thirdParties': 'TP',
        'whatWeAreDoing': 'WD',
        'whatYouCanDo': 'YD',
        'contactMethods': ['email: a@b.c', ' ', 'web: x.org'],
      })!;
      expect(n.id, '2026-10-01-test');
      expect(n.thirdParties, 'TP');
      expect(n.contactMethods, ['email: a@b.c', 'web: x.org']);
    });

    test('AppData wires the block through', () {
      expect(AppData.fromJson(const {}).breachNotice, isNull);
      final d = AppData.fromJson(const {
        'breachNotice': {'id': 'abc'},
      });
      expect(d.breachNotice?.id, 'abc');
    });

    test('the bundled app_data.json ships with NO active notice', () async {
      final d = await AppData.load();
      expect(
        d.breachNotice,
        isNull,
        reason: 'A breach notice must only ship deliberately.',
      );
    });
  });

  group('BreachNoticeGate', () {
    const notice = BreachNotice(
      id: 'n1',
      title: 'Security incident',
      whatHappened: 'Something happened.',
      contactMethods: ['Email: privacy@example.org'],
    );

    Widget host({BreachNotice? n, bool acked = false}) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BreachNoticeGate(
        notice: n,
        initiallyAcknowledged: acked,
        child: const Scaffold(body: Text('APP')),
      ),
    );

    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('no notice → pass-through', (tester) async {
      await tester.pumpWidget(host());
      expect(find.text('APP'), findsOneWidget);
      expect(find.text('I have read this notice'), findsNothing);
    });

    testWidgets('shows notice over the app, acknowledges and persists', (
      tester,
    ) async {
      await tester.pumpWidget(host(n: notice));
      expect(find.text('Security incident'), findsOneWidget);
      expect(find.text('Something happened.'), findsOneWidget);
      expect(find.text('• Email: privacy@example.org'), findsOneWidget);
      // Empty sections are omitted.
      expect(find.text('What we are doing'), findsNothing);

      await tester.tap(find.text('I have read this notice'));
      await tester.pumpAndSettle();
      expect(find.text('Security incident'), findsNothing);
      expect(find.text('APP'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(BreachNoticeGate.ackKey('n1')), isTrue);
      expect(await BreachNoticeGate.loadAcknowledged(notice), isTrue);
    });

    testWidgets('already acknowledged → not shown', (tester) async {
      await tester.pumpWidget(host(n: notice, acked: true));
      expect(find.text('Security incident'), findsNothing);
    });

    test('a new notice id is not covered by an old acknowledgement', () async {
      SharedPreferences.setMockInitialValues({
        BreachNoticeGate.ackKey('n1'): true,
      });
      expect(await BreachNoticeGate.loadAcknowledged(notice), isTrue);
      expect(
        await BreachNoticeGate.loadAcknowledged(const BreachNotice(id: 'n2')),
        isFalse,
      );
      expect(await BreachNoticeGate.loadAcknowledged(null), isFalse);
    });
  });
}
