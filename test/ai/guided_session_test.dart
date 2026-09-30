import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';
import 'package:mhad/data/app_data/app_data.dart';

/// V4-L12 — guided sessions follow the facilitated-PAD interview order, and
/// the helper ("facilitator") flag actually reaches the model.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => AppData.load());

  Future<String> systemPromptFor(AssistantContext? ctx) async {
    late String system;
    final mock = MockClient((req) async {
      system = (jsonDecode(req.body) as Map<String, dynamic>)['system']
          .toString();
      return http.Response(
        jsonEncode({
          'content': [
            {'type': 'text', 'text': 'ok'},
          ],
        }),
        200,
      );
    });
    await LlmAssistant(
      provider: AiProvider.anthropic,
      apiKey: 'k',
      model: 'm',
      httpClient: mock,
    ).sendMessage('hi', history: const [], context: ctx);
    return system;
  }

  test(
    'every conversation knows the facilitation order (reflection first)',
    () async {
      final p = await systemPromptFor(null);
      final reflect = p.indexOf('1. REFLECT');
      final history = p.indexOf('2. CRISIS HISTORY');
      final trust = p.indexOf('3. WHO THEY TRUST');
      final details = p.indexOf('5. DETAILS');
      expect([reflect, history, trust, details].every((i) => i >= 0), isTrue);
      expect(reflect < history && history < trust && trust < details, isTrue);
      expect(p.contains('GUIDED SESSION ---'), isFalse);
    },
  );

  test('a guided session starts the interview immediately', () async {
    final p = await systemPromptFor(
      const AssistantContext(guidedSession: true),
    );
    expect(p.contains('--- GUIDED SESSION ---'), isTrue);
    expect(p.contains('FACILITATOR MODE'), isFalse);
  });

  test('"I\'m helping someone" turns on facilitator mode', () async {
    final p = await systemPromptFor(
      const AssistantContext(guidedSession: true, facilitatorMode: true),
    );
    expect(p.contains('--- FACILITATOR MODE ---'), isTrue);
    expect(p.contains('Address the facilitator'), isTrue);
  });
}
