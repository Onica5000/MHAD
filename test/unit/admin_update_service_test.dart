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

    test('refuses to create a new leaf under an existing parent', () {
      // `legal` exists but `validityMonths` does not. The AI must not be able
      // to invent a new field even though the parent map is real.
      final base = baseData();
      final result = AdminUpdateService.applyApproved(base, [
        ProposedChange(
            path: 'legal.validityMonths',
            oldValue: null,
            newValue: '24',
            autonomy: 'auto',
            source: 's',
            rationale: 'r',
            approved: true),
      ]);
      expect((result['legal'] as Map).containsKey('validityMonths'), isFalse);
      // existing sibling untouched.
      expect(result['legal']['validityYears'], 2);
    });

    test('prettyJson round-trips', () {
      final s = AdminUpdateService.prettyJson(baseData());
      expect(jsonDecode(s), equals(baseData()));
    });
  });

  group('buildPrompt (target + focus)', () {
    test('app-data target spells out the auto/verify tiers for new blocks', () {
      final p = AdminUpdateService.buildPrompt('update timeouts', baseData());
      expect(p, contains('app_data.json'));
      expect(p, contains('config'));
      expect(p, contains('dated'));
      // verify tier covers legal + dated; auto covers config/facts/contacts.
      expect(p, contains('"verify" for ANYTHING under "legal" or "dated"'));
    });

    test('educational target forces verify + the sections.<id> path shape', () {
      final p = AdminUpdateService.buildPrompt(
        'fix a typo',
        {
          'sections': {
            'faq_valid': {'title': 'T', 'content': 'C', 'category': 'faq'}
          }
        },
        target: AdminDataTarget.educational,
      );
      expect(p, contains('educational_content.json'));
      expect(p, contains('EVERY change is "autonomy":"verify"'));
      expect(p, contains('sections.<id>'));
    });

    test('focus area scopes the proposal and is injected verbatim', () {
      final p = AdminUpdateService.buildPrompt(
        'tune it',
        baseData(),
        focusArea: 'config.timeoutsSeconds',
      );
      expect(p, contains('FOCUS:'));
      expect(p, contains('config.timeoutsSeconds'));
    });

    test('targets expose the right asset path + a human label', () {
      expect(AdminDataTarget.appData.assetPath, 'assets/data/app_data.json');
      expect(AdminDataTarget.educational.assetPath,
          'assets/data/educational_content.json');
      for (final t in AdminDataTarget.values) {
        expect(t.label, isNotEmpty);
      }
    });
  });

  group('revert / restore (granular)', () {
    Map<String, dynamic> live() => {
          '_meta': {'note': 'x'},
          'contacts': {
            'trevorProject': {'phone': '1-866-555-0000'}, // changed
          },
          'config': {
            'maxChatMessages': 200, // changed (int)
            'retry': {
              'backoffsMs': [0, 999] // changed (list)
            },
          },
          'legal': {'validityYears': 3}, // changed (verify)
        };
    Map<String, dynamic> backup() => {
          '_meta': {'note': 'older'},
          'contacts': {
            'trevorProject': {'phone': '1-866-488-7386'},
          },
          'config': {
            'maxChatMessages': 100,
            'retry': {
              'backoffsMs': [0, 500, 2000]
            },
          },
          'legal': {'validityYears': 2},
        };

    test('diffForRestore lists only the changed leaves, skips _meta', () {
      final diff = AdminUpdateService.diffForRestore(live(), backup(),
          target: AdminDataTarget.appData);
      final paths = diff.map((c) => c.path).toSet();
      expect(
          paths,
          {
            'contacts.trevorProject.phone',
            'config.maxChatMessages',
            'config.retry.backoffsMs',
            'legal.validityYears',
          });
      // _meta.note differs but must be ignored.
      expect(paths.any((p) => p.startsWith('_meta')), isFalse);
      // verify-tier path is flagged as verify; auto for config/contacts.
      final legal = diff.firstWhere((c) => c.path == 'legal.validityYears');
      expect(legal.isVerify, isTrue);
      final cfg = diff.firstWhere((c) => c.path == 'config.maxChatMessages');
      expect(cfg.isVerify, isFalse);
    });

    test('applyRestore writes REAL typed values (int + list round-trip)', () {
      final diff = AdminUpdateService.diffForRestore(live(), backup(),
          target: AdminDataTarget.appData);
      final restored =
          AdminUpdateService.applyRestore(live(), backup(), diff);
      expect(restored['config']['maxChatMessages'], 100);
      expect(restored['config']['maxChatMessages'], isA<int>());
      expect(restored['config']['retry']['backoffsMs'], [0, 500, 2000]);
      expect(restored['legal']['validityYears'], 2);
      expect(restored['contacts']['trevorProject']['phone'], '1-866-488-7386');
    });

    test('parseProposal preserves list-type newValue as JSON string', () {
      const model =
          '{"changes":[{"path":"legal.ntiDrugs","newValue":["lithium","carbamazepine"],'
          '"autonomy":"verify","source":"35 P.S. §960.3","rationale":"trimmed"}]}';
      final base = {
        'legal': {
          'ntiDrugs': ['lithium', 'carbamazepine', 'valproic acid'],
        },
      };
      final changes = AdminUpdateService.parseProposal(model, base);
      expect(changes.length, 1);
      // Must be valid JSON, not the Dart toString "[lithium, carbamazepine]".
      expect(changes.first.newValue, '["lithium","carbamazepine"]');
    });

    test('applyApproved round-trips a list-type change (e.g. ntiDrugs)', () {
      final base = {
        'legal': {
          'ntiDrugs': ['lithium', 'carbamazepine', 'valproic acid', 'phenytoin'],
        },
      };
      final result = AdminUpdateService.applyApproved(base, [
        ProposedChange(
          path: 'legal.ntiDrugs',
          oldValue: '["lithium","carbamazepine","valproic acid","phenytoin"]',
          newValue: '["lithium","carbamazepine","valproic acid"]',
          autonomy: 'verify',
          source: '35 P.S. §960.3',
          rationale: 'trimmed to 3',
          approved: true,
        ),
      ]);
      expect(result['legal']['ntiDrugs'],
          ['lithium', 'carbamazepine', 'valproic acid']);
      expect(result['legal']['ntiDrugs'], isA<List>());
    });

    test('applyRestore only rolls back the ticked parts', () {
      final diff = AdminUpdateService.diffForRestore(live(), backup(),
          target: AdminDataTarget.appData);
      // Untick everything except the phone.
      for (final c in diff) {
        c.approved = c.path == 'contacts.trevorProject.phone';
      }
      final restored =
          AdminUpdateService.applyRestore(live(), backup(), diff);
      expect(restored['contacts']['trevorProject']['phone'], '1-866-488-7386');
      // The unticked ones keep the live values.
      expect(restored['config']['maxChatMessages'], 200);
      expect(restored['legal']['validityYears'], 3);
    });
  });
}
