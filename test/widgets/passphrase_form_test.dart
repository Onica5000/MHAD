import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/services/passphrase/passphrase_lists.dart';
import 'package:mhad/ui/progress/passphrase_form.dart';

/// The passphrase page's form: the owner's rules as a live checklist
/// (user decision 2026-11-18), the strength gauge, and a passphrase handed
/// back only once every rule is met and both entries match.
void main() {
  ChosenPassphrase? chosen;

  Future<void> pumpForm(WidgetTester tester) async {
    PassphraseLists.debugUseLists(PassphraseLists.fromJson(
        File('assets/data/passphrase_lists.json').readAsStringSync()));
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: PassphraseForm(onChanged: (c) => chosen = c),
        ),
      ),
    ));
    // Not pumpAndSettle: the focused field's cursor blinks forever.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Finder field(String label) => find.widgetWithText(TextField, label);

  setUp(() => chosen = null);

  testWidgets('a short passphrase reads as weak and is not handed back',
      (tester) async {
    await pumpForm(tester);
    await tester.enterText(field('Passphrase'), 'Ab1!');
    await tester.pump();
    expect(find.text('Strength: Weak'), findsOneWidget);
    expect(find.textContaining('could guess it in'), findsOneWidget);
    expect(chosen, isNull, reason: 'the second entry is still empty');
  });

  testWidgets('the checklist shows what is still missing', (tester) async {
    await pumpForm(tester);
    await tester.enterText(field('Passphrase'), 'password1');
    await tester.pump();
    String state(String rule) => tester
        .getSemantics(find.textContaining(rule).first)
        .label;
    expect(state('A capital letter'), endsWith('not yet'));
    expect(state('A symbol or a space'), endsWith('not yet'));
    expect(state('A lowercase letter'), endsWith('done'));
    expect(state('Not to be a common passphrase'), endsWith('not yet'));
  });

  testWidgets('every rule met and both entries matching hands it back',
      (tester) async {
    await pumpForm(tester);
    await tester.enterText(field('Passphrase'), 'Blue horse tea!');
    await tester.enterText(field('Type it again'), 'Blue horse tea');
    await tester.pump();
    expect(chosen, isNull, reason: 'the entries differ');

    await tester.enterText(field('Type it again'), 'Blue horse tea!');
    await tester.pump();
    expect(chosen?.passphrase, 'Blue horse tea!');
    expect(find.text('Strength: Strong'), findsOneWidget);
  });
}
