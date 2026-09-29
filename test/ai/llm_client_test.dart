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

  test('server errors stay generic (not rate-limit typed) and name the status',
      () {
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
          e is! LlmAuthError &&
          e is! LlmModelNotFoundError &&
          e.toString().contains('500'))),
    );
  });

  // A rejected key and a retired model are user-fixable, not transient. They
  // used to arrive as a bare "API error (401)", which the UI rendered as
  // "please try again later" — advice that can never resolve either one.
  for (final status in [401, 403]) {
    test('HTTP $status throws LlmAuthError', () {
      final mock = MockClient((req) async => http.Response('nope', status));
      final client = LlmClient(
        provider: AiProvider.openai,
        model: 'gpt-x',
        apiKey: 'bad',
        httpClient: mock,
      );
      expect(
        () => client.generateText('hello'),
        throwsA(isA<LlmAuthError>()),
      );
    });
  }

  test('HTTP 404 throws LlmModelNotFoundError naming the model', () {
    final mock = MockClient((req) async => http.Response('nope', 404));
    final client = LlmClient(
      provider: AiProvider.openai,
      model: 'gpt-retired',
      apiKey: 'k',
      httpClient: mock,
    );
    expect(
      () => client.generateText('hello'),
      throwsA(isA<LlmModelNotFoundError>()
          .having((e) => e.message, 'message', contains('gpt-retired'))),
    );
  });

  test('a transport failure becomes LlmNetworkError, not a raw ClientException',
      () {
    // Stands in for a browser CORS rejection / offline state, which `http`
    // reports as ClientException on web.
    final mock = MockClient((req) async => throw http.ClientException('Failed to fetch'));
    final client = LlmClient(
      provider: AiProvider.openai,
      model: 'gpt-x',
      apiKey: 'k',
      httpClient: mock,
    );
    expect(
      () => client.generateText('hello'),
      throwsA(isA<LlmNetworkError>()),
    );
  });

  test('HEIC is refused on providers that cannot decode it', () {
    // iPhone default format. Only Gemini reads it; the app cannot transcode,
    // so the other providers must say so rather than upload something they
    // will reject (previously it was relabelled image/jpeg and failed opaquely).
    final mock = MockClient((req) async => http.Response('{}', 200));
    for (final p in [AiProvider.anthropic, AiProvider.openai, AiProvider.grok]) {
      final client = LlmClient(
        provider: p,
        model: 'm',
        apiKey: 'k',
        httpClient: mock,
      );
      expect(
        () => client.generateMultimodal(
          parts: [LlmData('image/heic', Uint8List(0))],
        ),
        throwsA(isA<UnsupportedInputError>()),
        reason: '${p.label} cannot read HEIC',
      );
    }
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
