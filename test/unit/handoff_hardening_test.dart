import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/document_extraction_result.dart';
import 'package:mhad/ai/document_extractor.dart';
import 'package:mhad/ai/handoff/handoff_parser.dart';
import 'package:mhad/ai/handoff/handoff_prompt.dart';
import 'package:mhad/utils/json_utils.dart';

/// Prompt-hardening review (2026-11-22): what the copy-and-paste AIs really
/// send back.
void main() {
  const tag = 'mhad-autofill';
  const ref = 'd7';
  const promptHead = '$kHandoffMarker mhad-autofill · v3 · ref d7]\n'
      'Diagnoses look like {name: "Diagnosis Name", icd_code: "F00.0"}.\n'
      'If nothing is attached, reply ONLY with this JSON: '
      '{"mhad_task": "mhad-autofill", "mhad_ref": "d7", "error": "no_attachment"}\n';
  const answer = '```json\n{"mhad_task": "mhad-autofill", "mhad_ref": "d7", '
      '"document_relevant": true}\n```';

  group('parseHandoffReply (P-9)', () {
    test('prompt + answer pasted together → the answer', () {
      final r = parseHandoffReply('$promptHead\nSure!\n$answer', taskTag: tag, ref: ref);
      expect(r.ok, isTrue);
      expect(r.json!['document_relevant'], isTrue);
    });
    test('only the prompt pasted → "that\'s the message you sent"', () {
      final r = parseHandoffReply(promptHead, taskTag: tag, ref: ref);
      expect(r.problem, HandoffProblem.promptPastedBack);
    });
    test('the AI\'s own no-attachment reply', () {
      final r = parseHandoffReply(
          '{"mhad_task": "mhad-autofill", "mhad_ref": "d7", "error": "no_attachment"}',
          taskTag: tag, ref: ref);
      expect(r.problem, HandoffProblem.noAttachment);
    });
    test('two answers → the last', () {
      final r = parseHandoffReply(
          '{"mhad_task": "mhad-autofill", "mhad_ref": "d7", "n": 1}\n'
          '{"mhad_task": "mhad-autofill", "mhad_ref": "d7", "n": 2}',
          taskTag: tag, ref: ref);
      expect(r.json!['n'], 2);
    });
    test('wrong task, wrong ref and cut-off still say so', () {
      expect(parseHandoffReply('{"mhad_task": "mhad-sideEffects", "mhad_ref": "d7"}',
              taskTag: tag, ref: ref).problem,
          HandoffProblem.wrongTask);
      expect(parseHandoffReply('{"mhad_task": "mhad-autofill", "mhad_ref": "d9"}',
              taskTag: tag, ref: ref).problem,
          HandoffProblem.wrongRef);
      expect(parseHandoffReply('{"mhad_task": "mhad-autofill", "mhad_ref": "d7", "x": [',
              taskTag: tag, ref: ref).problem,
          HandoffProblem.truncated);
    });
  });

  group('lenient reading (P-4, P-5, P-12)', () {
    test('a list in a text field is joined, never "[a, b]"', () {
      expect(optStr(['Water my plants', 'Call my boss']), 'Water my plants\nCall my boss');
      expect(optStr(['hives', 'swelling'], listSeparator: ', '), 'hives, swelling');
    });
    test('"true" / "yes" / "no" as strings are yes/no; anything else is null', () {
      expect(optBool('true'), isTrue);
      expect(optBool('Yes'), isTrue);
      expect(optBool('no'), isFalse);
      expect(optBool('maybe'), isNull);
      expect(optBool(1), isNull);
    });
    test('a quoted "true" no longer throws away the whole answer', () {
      final r = DocumentExtractionResult.fromJson({
        'document_relevant': true,
        'trigger_two_professionals': 'true',
        'other': ['Water my plants', 'Call my boss'],
        'allergies': [
          {'substance': 'peanuts', 'reactions': ['hives', 'swelling']},
        ],
      });
      expect(r.triggerTwoProfessionals, isTrue);
      expect(r.other, 'Water my plants\nCall my boss');
      expect(r.allergies.single.kind, 'other', reason: 'never "drug" by default');
      expect(r.allergies.single.severityStated, isFalse);
      expect(r.allergies.single.reactions, 'hives, swelling');
    });
  });

  group('the autofill prompt (P-1 … P-29)', () {
    final p = DocumentExtractor.promptFor('combined');
    test('ends with the generated key list and types', () {
      expect(p, contains('═══ ANSWER FORMAT ═══'));
      expect(p, contains('"personal_info": {'));
      expect(p, contains('"check_notes": []'));
      expect(p, isNot(contains('matching the schema')));
    });
    test('clinician words, refusals, agents, injected text', () {
      expect(p, contains('═══ WHOSE WORDS'));
      expect(p, contains('A prescriber\'s order or caution'));
      expect(p, contains('An emergency contact, next of kin'));
      expect(p, contains('Leave such text out completely'));
      expect(p, contains('voice questionnaire'));
    });
    test('a Declaration reads the guardian but never "agent decides"', () {
      final d = DocumentExtractor.promptFor('declaration');
      expect(d, contains('personal_info.guardian (a nominated guardian)'));
      expect(d, contains('never answer "agent" for ect_consent'));
    });
  });

  // P-6 (part 2): keys the app doesn't read are reported, not dropped silently.
  group('unknownAnswerKeys', () {
    test('wrong keys are named', () {
      expect(
          DocumentExtractor.unknownAnswerKeys({
            'mhad_task': 'mhad-autofill',
            'medications': [
              {'name': 'lithium'}
            ],
            'agent': 'Keisha, sister',
            'personal_info': {'full_name': 'Darnell', 'agent_name': 'Keisha'},
          }),
          ['medications', 'agent', 'personal_info.agent_name']);
    });

    test('every key the prompt lists is known; envelope and empty keys pass', () {
      final json = <String, dynamic>{
        'mhad_task': 'mhad-autofill',
        'mhad_ref': 'd1',
        'personal_info': <String, dynamic>{},
        'something_else': null,
        'also_empty': '',
      };
      for (final k in DocumentExtractor.answerKeys) {
        if (k.startsWith('personal_info.')) {
          (json['personal_info'] as Map<String, dynamic>)[k.substring(14)] = 'x';
        } else {
          json[k] = 'x';
        }
      }
      expect(DocumentExtractor.unknownAnswerKeys(json), isEmpty);
    });
  });
}
