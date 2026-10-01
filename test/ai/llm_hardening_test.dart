import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/ai/crisis_detector.dart';
import 'package:mhad/ai/llm_client.dart';
import 'package:mhad/ui/assistant/assistant_message_widgets.dart';
import 'package:mhad/ui/assistant/assistant_send.dart';

/// Hardening for the AI layer (2026-10): refusals and truncation surface as
/// typed errors, current Claude request shape, OpenAI's token parameter, the
/// app-side crisis check, history hygiene, and safe source links.
void main() {
  LlmClient client(AiProvider p, String model, MockClient mock) =>
      LlmClient(provider: p, model: model, apiKey: 'k', httpClient: mock);

  group('Anthropic', () {
    test(
      'refusal (HTTP 200) throws LlmRefusalError that points to 988',
      () async {
        final mock = MockClient(
          (_) async => http.Response(
            jsonEncode({'stop_reason': 'refusal', 'content': []}),
            200,
          ),
        );
        final c = client(AiProvider.anthropic, 'claude-sonnet-5-5', mock);
        await expectLater(
          c.generateText('hi'),
          throwsA(
            isA<LlmRefusalError>().having(
              (e) => e.message,
              'message',
              contains('988'),
            ),
          ),
        );
      },
    );

    test('max_tokens with no text throws LlmTruncatedError', () async {
      final mock = MockClient(
        (_) async => http.Response(
          jsonEncode({'stop_reason': 'max_tokens', 'content': []}),
          200,
        ),
      );
      final c = client(AiProvider.anthropic, 'claude-sonnet-5-5', mock);
      await expectLater(
        c.generateText('hi'),
        throwsA(isA<LlmTruncatedError>()),
      );
    });

    test(
      'current models: effort, fallbacks + beta header, 16k max_tokens',
      () async {
        late http.Request seen;
        final mock = MockClient((req) async {
          seen = req;
          return http.Response(
            jsonEncode({
              'stop_reason': 'end_turn',
              'content': [
                {'type': 'text', 'text': 'ok'},
              ],
            }),
            200,
          );
        });
        await client(
          AiProvider.anthropic,
          'claude-sonnet-5-5',
          mock,
        ).generateText('hi');
        final body = jsonDecode(seen.body) as Map;
        expect(body['max_tokens'], 16000);
        expect(body['output_config'], {'effort': 'medium'});
        expect(body['fallbacks'], 'default');
        expect(
          seen.headers['anthropic-beta'],
          'server-side-fallback-2026-07-01',
        );
        // Rejected by current models — must never be sent.
        expect(body.containsKey('temperature'), isFalse);
        expect(body.containsKey('thinking'), isFalse);
      },
    );

    test('Haiku 4.5: no effort, no fallbacks (it rejects both)', () async {
      late http.Request seen;
      final mock = MockClient((req) async {
        seen = req;
        return http.Response(
          jsonEncode({
            'content': [
              {'type': 'text', 'text': 'ok'},
            ],
          }),
          200,
        );
      });
      await client(
        AiProvider.anthropic,
        'claude-haiku-4-5',
        mock,
      ).generateText('hi');
      final body = jsonDecode(seen.body) as Map;
      expect(body.containsKey('output_config'), isFalse);
      expect(body.containsKey('fallbacks'), isFalse);
      expect(seen.headers.containsKey('anthropic-beta'), isFalse);
    });
  });

  group('OpenAI-compatible', () {
    test('OpenAI refusal / content_filter throws LlmRefusalError', () async {
      final mock = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'choices': [
              {
                'finish_reason': 'stop',
                'message': {'content': null, 'refusal': "I can't help."},
              },
            ],
          }),
          200,
        ),
      );
      await expectLater(
        client(AiProvider.openai, 'gpt-5.4-mini', mock).generateText('hi'),
        throwsA(isA<LlmRefusalError>()),
      );
    });
  });

  group('Crisis detector', () {
    for (final s in [
      'I want to kill myself',
      "I've been having suicidal thoughts",
      'sometimes I think about hurting myself',
      'I keep cutting myself',
      'thinking about harming myself',
      'I want to end my life',
      'Quiero morir',
      'he pensado en hacerme daño',
    ]) {
      test('flags: $s', () => expect(looksLikeCrisis(s), isTrue));
    }
    for (final s in [
      'What medications should I list?',
      'Who can be my agent?',
      'How long is the directive valid?',
    ]) {
      test('does not flag: $s', () => expect(looksLikeCrisis(s), isFalse));
    }
  });

  test('historyForAi drops error notices and the failed user turn', () {
    final h = historyForAi([
      ChatMessage(role: MessageRole.user, content: 'q1'),
      ChatMessage(role: MessageRole.assistant, content: 'a1'),
      ChatMessage(role: MessageRole.user, content: 'q2 (failed)'),
      ChatMessage(role: MessageRole.assistant, content: 'err', isError: true),
      ChatMessage(role: MessageRole.user, content: 'q3'),
    ]);
    expect(h.map((m) => m.content), ['q1', 'a1', 'q3']);
  });

  test('model-supplied source links: only http(s) URLs open', () {
    expect(isSafeWebLink('https://www.nimh.nih.gov/x'), isTrue);
    expect(isSafeWebLink('javascript:alert(1)'), isFalse);
    expect(isSafeWebLink('intent://evil'), isFalse);
    expect(isSafeWebLink('file:///etc/passwd'), isFalse);
    expect(isSafeWebLink('not a url'), isFalse);
  });
}
