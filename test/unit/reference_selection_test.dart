import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';
import 'package:mhad/ai/handoff/handoff_prompt.dart';
import 'package:mhad/ai/handoff/handoff_task.dart';
import 'package:mhad/ai/reference_selection.dart';
import 'package:mhad/data/educational_content.dart';

/// The copied Ask prompt carried every Learn section (~127K chars, ~32K
/// tokens) — over the free ChatGPT (~27K tokens) and Gemini (32K tokens)
/// windows (Nov 2026). It now carries the relevant sections within a budget.
/// (flutter_test_config loads the Learn articles, as main() does.)
void main() {
  const budget = LlmAssistant.handoffReferenceChars;

  String copied(String question, {AssistantContext? ctx}) => buildHandoffPrompt(
        HandoffTask(
          kind: HandoffTaskKind.ask,
          instructions: LlmAssistant.systemPromptFor(ctx,
              question: question, referenceBudget: budget),
          ref: 'd1',
          question: question,
        ),
        languageCode: 'en',
        paPhone: '1-800-692-7443',
      );

  test('the copied Ask prompt fits the free plans with room to answer', () {
    for (final q in ['Who can be a witness?', '', 'What is ECT?']) {
      final p = copied(q);
      // ~14K tokens at ~4 chars/token; free ChatGPT ~27K, Gemini 32K.
      expect(p.length, lessThan(60000), reason: 'question "$q"');
    }
  });

  test('the sections it picks are about the question', () {
    final picked = selectReferenceSections('Who can be a witness?', budget);
    expect(picked.any((s) => s.title.toLowerCase().contains('witness')), isTrue);
    final total = picked.fold<int>(0, (n, s) => n + sectionChars(s));
    expect(total, lessThanOrEqualTo(budget));
  });

  test('the step adds to the relevance', () {
    final p = copied('What do I need?',
        ctx: const AssistantContext(formType: 'combined', stepName: 'People I trust'));
    expect(p.toLowerCase(), contains('agent'));
  });

  test('everything left out is still named, so the AI can point to it', () {
    final p = copied('Who can be a witness?');
    final picked = selectReferenceSections('Who can be a witness?', budget);
    expect(p, contains('OTHER TOPICS'));
    for (final s in allEducationSections) {
      expect(p, contains(s.title), reason: picked.contains(s) ? 'included' : 'titled');
    }
  });

  test('the API path still carries every section', () {
    final full = LlmAssistant.systemPromptFor(null);
    expect(full.length, greaterThan(100000));
    expect(full, isNot(contains('OTHER TOPICS')));
  });

  test('picked sections keep their original order', () {
    final picked = selectReferenceSections('witness agent revoke', budget);
    final idx = [for (final s in picked) allEducationSections.indexOf(s)];
    expect(idx, orderedEquals([...idx]..sort()));
  });
}
