import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/ai_clinical_policy.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';

/// Prompt-hardening review (2026-11-22): rules that live outside the autofill
/// and smart-fill prompts (those have their own tests).
void main() {
  final handoff = jsonDecode(File('assets/data/ai_handoff.json').readAsStringSync())
      as Map<String, dynamic>;

  test('P-7: the legal facts are background, never answers', () {
    final facts = (handoff['legalFacts'] as List).cast<String>();
    expect(facts.first, contains('They are NOT the person\'s choices'));
    expect(facts.join('\n'), isNot(contains('by default, when the person')));
  });

  test('P-8: the envelope defers to the task for JSON values', () {
    final env = handoff['envelope'] as Map<String, dynamic>;
    expect(env['en']['replyLanguage'], contains('follow the task\'s language rules'));
    expect(env['es']['replyLanguage'], contains('sin traducir'));
  });

  test('P-18: every JSON task may point to 988 first', () {
    final env = handoff['envelope'] as Map<String, dynamic>;
    expect(env['en']['jsonOnly'], contains('988'));
    expect(env['es']['jsonOnly'], contains('988'));
  });

  test('P-16: the shared policy has no diet example', () {
    expect(aiClinicalPolicy, isNot(contains('carb')));
  });

  group('Ask assistant (P-20, P-21)', () {
    final p = LlmAssistant.systemPromptFor(null);
    test('step guide matches the app', () {
      expect(p, contains('Declaration only: 10 steps'));
      expect(p, isNot(contains('set in step 3 governs')));
      expect(p, contains('PROCEDURES &'));
    });
    test('no false privacy claim, no refusing a whole question over a name', () {
      expect(p, isNot(contains('never sent to the AI')));
      expect(p, isNot(contains('Reject the entire message')));
    });
  });

  test('P-22 / P-27 field wording: no blanks, no legal text, the user\'s own voice', () {
    final src = File('lib/ui/wizard/widgets/ai_suggest_button.dart').readAsStringSync();
    expect(src, isNot(contains('[describe ...]')));
    expect(src, isNot(contains('relevant PA Act 194 provisions')));
    expect(src, isNot(contains('("your doctor", "your agent")')));
    expect(src, contains('("my doctor", "my agent")'));
  });

  test('P-24 AI check: never calls it valid; Declarations have no agent gap', () {
    final src = File('lib/ui/ai_check/ai_consistency_screen.dart').readAsStringSync();
    expect(src, contains('Never say the directive is valid'));
    expect(src, contains('A Declaration never names an agent; that is not a gap.'));
  });

  test('P-18: the 988 check runs on every AI box', () {
    for (final f in [
      'lib/ui/wizard/steps/diagnoses_step.dart',
      'lib/ui/wizard/widgets/ai_suggest_button.dart',
      'lib/ui/wizard/widgets/pipeline_review_widget.dart',
    ]) {
      expect(File(f).readAsStringSync(), contains('looksLikeCrisis'), reason: f);
    }
  });
}
