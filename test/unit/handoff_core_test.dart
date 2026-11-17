import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/handoff/ai_handoff_data.dart';
import 'package:mhad/ai/handoff/handoff_parser.dart';
import 'package:mhad/ai/handoff/handoff_prompt.dart';
import 'package:mhad/ai/handoff/handoff_task.dart';
import 'package:mhad/ai/handoff/pending_handoff.dart';

/// The copy-and-paste AI handoff (user decision 2026-11-17): the data file,
/// the prompt the person copies, the parser for the answer they paste back,
/// and the 30-minute wait. (AiHandoffData is loaded by flutter_test_config.)
void main() {
  final data = AiHandoffData.instance;

  group('ai_handoff.json', () {
    test('lists the four services with links', () {
      expect(data.services.keys, containsAll(AiService.values));
      for (final s in data.services.values) {
        expect(s.url.scheme, 'https', reason: '${s.label} link');
      }
    });

    test('records the verified audio support (re-verify when it changes)', () {
      ServiceSupport audio(AiService s) =>
          data.info(s)!.supports(HandoffInput.audio);
      expect(audio(AiService.gemini), ServiceSupport.yes);
      expect(audio(AiService.chatgpt), ServiceSupport.paid);
      expect(audio(AiService.claude), ServiceSupport.no);
      expect(audio(AiService.grok), ServiceSupport.unconfirmed);
      for (final s in AiService.values) {
        expect(data.info(s)!.supports(HandoffInput.image), ServiceSupport.yes);
        expect(data.info(s)!.supports(HandoffInput.pdf), ServiceSupport.yes);
      }
    });

    test('has English and Spanish envelope wording', () {
      for (final lang in ['en', 'es']) {
        for (final key in [
          'intro', 'replyLanguage', 'jsonOnly', 'attachmentGuard',
          'askLead', 'questionLabel', 'wordingLead',
        ]) {
          expect(data.text(lang, key), isNotEmpty, reason: '$lang.$key');
        }
      }
      expect(data.text('es', 'intro'), isNot(data.text('en', 'intro')));
    });
  });

  group('buildHandoffPrompt', () {
    const autofill = HandoffTask(
      kind: HandoffTaskKind.autofill,
      instructions: 'TASK INSTRUCTIONS',
      ref: 'd12',
      attachment: HandoffAttachment.document,
    );

    String build(HandoffTask t, {String lang = 'en'}) =>
        buildHandoffPrompt(t, languageCode: lang, paPhone: '1-800-692-7443');

    test('starts with the header naming the task and what it is for', () {
      final p = build(autofill);
      expect(p.split('\n').first,
          '$kHandoffMarker mhad-autofill · v${data.version} · ref d12]');
    });

    test('carries the legal facts, the task, the guard and the JSON rules', () {
      final p = build(autofill);
      expect(p, contains('two witnesses'));
      expect(p, contains('No notary is required'));
      expect(p, contains('1-800-692-7443'));
      expect(p, contains('TASK INSTRUCTIONS'));
      expect(p, contains('"error": "no_attachment"'));
      expect(p, contains('"mhad_task": "mhad-autofill"'));
      expect(p, contains('"mhad_ref": "d12"'));
    });

    test('leaves no placeholder unfilled', () {
      for (final lang in ['en', 'es']) {
        final p = build(autofill, lang: lang);
        expect(RegExp(r'\{(task|ref|paPhone|attachment)\}').hasMatch(p), isFalse,
            reason: lang);
      }
    });

    test('a question has no JSON rules or attachment guard', () {
      final p = build(const HandoffTask(
        kind: HandoffTaskKind.ask,
        instructions: 'SYSTEM',
        ref: 'general',
        question: 'Who can be my agent?',
      ));
      expect(p, contains('Who can be my agent?'));
      expect(p, isNot(contains('"mhad_task"')));
      expect(p, isNot(contains('no_attachment')));
    });

    test('Spanish uses the Spanish envelope', () {
      final p = build(autofill, lang: 'es');
      expect(p, contains(data.text('es', 'intro')));
      expect(p, contains('documento'));
    });
  });

  group('parseHandoffReply', () {
    HandoffReply parse(String raw) =>
        parseHandoffReply(raw, taskTag: 'mhad-autofill', ref: 'd12');
    const good = '{"mhad_task": "mhad-autofill", "mhad_ref": "d12", "a": 1}';

    test('reads plain JSON', () {
      final r = parse(good);
      expect(r.ok, isTrue);
      expect(r.json!['a'], 1);
    });

    test('ignores code fences and commentary around the JSON', () {
      final r = parse('Sure! Here it is:\n```json\n$good\n```\nLet me know.');
      expect(r.ok, isTrue);
    });

    test('tolerates trailing commas and curly quotes', () {
      expect(parse('{"mhad_task": "mhad-autofill", "mhad_ref": "d12", "x": [1, 2,],}').ok,
          isTrue);
      expect(
          parse('{“mhad_task”: “mhad-autofill”, '
                  '“mhad_ref”: “d12”}')
              .ok,
          isTrue);
    });

    test('keeps braces inside text values', () {
      final r = parse(
          '{"mhad_task": "mhad-autofill", "mhad_ref": "d12", "note": "use {x} } here"}');
      expect(r.ok, isTrue);
      expect(r.json!['note'], 'use {x} } here');
    });

    test('names each problem', () {
      expect(parse('   ').problem, HandoffProblem.empty);
      expect(parse('$kHandoffMarker mhad-autofill · v1 · ref d12]\nYou are…').problem,
          HandoffProblem.promptPastedBack);
      expect(parse('I could not read the document.').problem,
          HandoffProblem.notJson);
      expect(parse('{"mhad_task": "mhad-autofill", "mhad_ref": "d12", "a": [1, 2')
              .problem,
          HandoffProblem.truncated);
      expect(parse('{"mhad_task": "mhad-review", "mhad_ref": "d12"}').problem,
          HandoffProblem.wrongTask);
      expect(parse('{"mhad_task": "mhad-autofill", "mhad_ref": "d7"}').problem,
          HandoffProblem.wrongRef);
      expect(
          parse('{"mhad_task": "mhad-autofill", "mhad_ref": "d12", '
                  '"error": "no_attachment"}')
              .problem,
          HandoffProblem.noAttachment);
    });
  });

  group('PendingHandoff', () {
    test('waits 30 minutes and round-trips through storage', () {
      expect(PendingHandoff.window, const Duration(minutes: 30));
      final now = DateTime(2026, 11, 17, 12);
      final p = PendingHandoff(
        taskTag: 'mhad-autofill',
        ref: 'd12',
        route: '/upload/12',
        deadline: now.add(PendingHandoff.window),
      );
      expect(p.remaining(now), const Duration(minutes: 30));
      expect(p.isExpired(now.add(const Duration(minutes: 31))), isTrue);
      final back = PendingHandoff.fromJson(p.toJson())!;
      expect(back.ref, 'd12');
      expect(back.route, '/upload/12');
      expect(back.deadline, p.deadline);
    });
  });
}
