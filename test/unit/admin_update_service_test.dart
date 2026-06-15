import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/services/admin_update_service.dart';

/// Guards the pure (CI-testable) core of the admin AI-update flow: parsing the
/// model's JSON proposal and applying approved changes. The live Gemini drafting
/// call is verified manually.
void main() {
  Map<String, dynamic> baseData() => {
        'contacts': {
          'trevorProject': {'name': 'Trevor', 'phone': '1-866-488-7386'},
        },
        'ai': {'model': 'gemini-2.5-flash', 'rpm': 10},
        'legal': {'validityYears': 2},
      };

  group('parseProposal', () {
    test('parses changes, attaches old value, and sets approval by tier', () {
      final model = '''
Sure! Here is the proposal:
```json
{"changes":[
  {"path":"contacts.trevorProject.phone","newValue":"1-866-555-0000","autonomy":"auto","source":"thetrevorproject.org","rationale":"number changed"},
  {"path":"legal.validityYears","newValue":"3","autonomy":"verify","source":"20 Pa.C.S. amended","rationale":"statute amended"}
]}
```
''';
      final changes = AdminUpdateService.parseProposal(model, baseData());
      expect(changes.length, 2);

      final phone = changes[0];
      expect(phone.path, 'contacts.trevorProject.phone');
      expect(phone.oldValue, '1-866-488-7386');
      expect(phone.newValue, '1-866-555-0000');
      expect(phone.autonomy, 'auto');
      expect(phone.approved, isTrue, reason: 'auto tier pre-approved');

      final legal = changes[1];
      expect(legal.isVerify, isTrue);
      expect(legal.approved, isFalse,
          reason: 'verify tier must be ticked by a human');
      expect(legal.oldValue, '2');
    });

    test('returns nothing for non-JSON / empty proposals', () {
      expect(AdminUpdateService.parseProposal('no json here', baseData()),
          isEmpty);
      expect(
          AdminUpdateService.parseProposal('{"changes":[]}', baseData()),
          isEmpty);
    });
  });

  group('applyApproved', () {
    test('applies only approved changes and coerces to the leaf type', () {
      final base = baseData();
      final changes = [
        ProposedChange(
            path: 'contacts.trevorProject.phone',
            oldValue: '1-866-488-7386',
            newValue: '1-866-555-0000',
            autonomy: 'auto',
            source: 's',
            rationale: 'r',
            approved: true),
        ProposedChange(
            path: 'ai.rpm',
            oldValue: '10',
            newValue: '15',
            autonomy: 'auto',
            source: 's',
            rationale: 'r',
            approved: true),
        ProposedChange(
            path: 'legal.validityYears',
            oldValue: '2',
            newValue: '3',
            autonomy: 'verify',
            source: 's',
            rationale: 'r',
            approved: false), // not approved → must not apply
      ];

      final result = AdminUpdateService.applyApproved(base, changes);

      expect(result['contacts']['trevorProject']['phone'], '1-866-555-0000');
      // rpm was an int — must stay an int, not become the string "15".
      expect(result['ai']['rpm'], 15);
      expect(result['ai']['rpm'], isA<int>());
      // unapproved verify change left untouched.
      expect(result['legal']['validityYears'], 2);
      // base is not mutated (deep copy).
      expect(base['contacts']['trevorProject']['phone'], '1-866-488-7386');
    });

    test('refuses to create new paths that do not exist in the base', () {
      final base = baseData();
      final result = AdminUpdateService.applyApproved(base, [
        ProposedChange(
            path: 'contacts.madeUpOrg.phone',
            oldValue: null,
            newValue: '555',
            autonomy: 'auto',
            source: 's',
            rationale: 'r',
            approved: true),
      ]);
      expect((result['contacts'] as Map).containsKey('madeUpOrg'), isFalse);
    });

    test('prettyJson round-trips', () {
      final s = AdminUpdateService.prettyJson(baseData());
      expect(jsonDecode(s), equals(baseData()));
    });
  });
}
