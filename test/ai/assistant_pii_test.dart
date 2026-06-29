import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';
import 'package:mhad/data/app_data/app_data.dart';

/// V4-L15 / L4 — end-to-end assertion that no raw PII leaves the assistant,
/// covering BOTH the new message AND prior conversation turns (the history-leak
/// fixed this session). Uses a mock http client to capture the outbound body.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AppData.load(); // assistant reads appData.config / phone references
  });

  test('strips PII from the message and the history before sending', () async {
    String? sentBody;
    final mock = MockClient((req) async {
      sentBody = req.body;
      return http.Response(
        jsonEncode({
          'content': [
            {'type': 'text', 'text': 'ok'}
          ]
        }),
        200,
      );
    });

    final assistant = LlmAssistant(
      provider: AiProvider.anthropic, // routes through a mockable REST path
      apiKey: 'test-key',
      model: 'claude-test',
      httpClient: mock,
    );

    final reply = await assistant.sendMessage(
      'Please email me at jane.doe@example.com',
      history: [
        ChatMessage(
          role: MessageRole.user,
          content: 'My SSN is 123-45-6789 and my phone is 215-555-1234',
        ),
      ],
    );

    expect(reply, 'ok');
    expect(sentBody, isNotNull);
    // Message PII.
    expect(sentBody!.contains('jane.doe@example.com'), isFalse,
        reason: 'the new message must be PII-stripped');
    // History PII (the bug fixed this session: earlier turns were sent raw).
    expect(sentBody!.contains('123-45-6789'), isFalse,
        reason: 'history SSN must be PII-stripped');
    expect(sentBody!.contains('215-555-1234'), isFalse,
        reason: 'history phone must be PII-stripped');
  });
}
