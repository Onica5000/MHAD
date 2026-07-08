import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/ai/llm_client.dart';

void main() {
  group('LlmClient routing', () {
    test('Anthropic generateText hits the Messages endpoint', () async {
      late http.Request seen;
      final mock = MockClient((req) async {
        seen = req;
        return http.Response(
          jsonEncode({
            'content': [
              {'type': 'text', 'text': 'hi from claude'}
            ]
          }),
          200,
        );
      });
      final client = LlmClient(
        provider: AiProvider.anthropic,
        model: 'claude-x',
        apiKey: 'secret',
        httpClient: mock,
      );

      final out = await client.generateText('hello');

      expect(out, 'hi from claude');
      expect(seen.url.toString(), 'https://api.anthropic.com/v1/messages');
      expect(seen.headers['x-api-key'], 'secret');
      expect((jsonDecode(seen.body) as Map)['model'], 'claude-x');
    });

    test('OpenAI generateText hits chat completions with JSON mode', () async {
      late http.Request seen;
      final mock = MockClient((req) async {
        seen = req;
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': 'yo from gpt'}
              }
            ]
          }),
          200,
        );
      });
      final client = LlmClient(
        provider: AiProvider.openai,
        model: 'gpt-x',
        apiKey: 'secret',
        httpClient: mock,
      );

      final out = await client.generateText('hello', json: true);

      expect(out, 'yo from gpt');
      expect(seen.url.toString(),
          'https://api.openai.com/v1/chat/completions');
      expect(seen.headers['authorization'], 'Bearer secret');
      expect((jsonDecode(seen.body) as Map)['response_format'],
          {'type': 'json_object'});
    });

    test('Grok hits the x.ai endpoint', () async {
      late Uri seen;
      final mock = MockClient((req) async {
        seen = req.url;
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': 'g'}
              }
            ]
          }),
          200,
        );
      });
      final client = LlmClient(
        provider: AiProvider.grok,
        model: 'grok-x',
        apiKey: 'k',
        httpClient: mock,
      );

      await client.generateText('hi');
      expect(seen.toString(), 'https://api.x.ai/v1/chat/completions');
    });
  });

  test('HTTP 429 surfaces as the typed LlmRateLimitError', () {
    final mock = MockClient(
        (req) async => http.Response('{"error":"rate_limited"}', 429));
    final client = LlmClient(
      provider: AiProvider.anthropic,
      model: 'claude-x',
      apiKey: 'k',
      httpClient: mock,
    );
    expect(
      () => client.generateText('hello'),
      throwsA(isA<LlmRateLimitError>()),
      reason: 'callers key their retry/backoff policy off this type',
    );
  });

  test('non-429 HTTP errors stay generic (not rate-limit typed)', () {
    final mock = MockClient((req) async => http.Response('boom', 500));
    final client = LlmClient(
      provider: AiProvider.openai,
      model: 'gpt-x',
      apiKey: 'k',
      httpClient: mock,
    );
    expect(
      () => client.generateText('hello'),
      throwsA(predicate((e) =>
          e is Exception &&
          e is! LlmRateLimitError &&
          e.toString().contains('API error (500)'))),
    );
  });

  test('PDF input throws UnsupportedInputError on a vision-only provider',
      () {
    final mock = MockClient((req) async => http.Response('{}', 200));
    final client = LlmClient(
      provider: AiProvider.openai,
      model: 'gpt-x',
      apiKey: 'k',
      httpClient: mock,
    );
    expect(
      () => client.generateMultimodal(
        parts: [LlmData('application/pdf', Uint8List(0))],
      ),
      throwsA(isA<UnsupportedInputError>()),
    );
  });
}
