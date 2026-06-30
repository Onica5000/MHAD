import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/data/app_data/app_data.dart';

void main() {
  group('AiProvider.looksLikeKey', () {
    test('accepts each provider\'s real key shape', () {
      expect(AiProvider.gemini.looksLikeKey('AIza${'x' * 35}'), isTrue);
      expect(AiProvider.anthropic.looksLikeKey('sk-ant-${'x' * 20}'), isTrue);
      expect(AiProvider.openai.looksLikeKey('sk-${'x' * 20}'), isTrue);
      expect(AiProvider.grok.looksLikeKey('xai-${'x' * 20}'), isTrue);
    });

    test('rejects an obviously-wrong shape', () {
      expect(AiProvider.gemini.looksLikeKey('sk-ant-xxxxxxxx'), isFalse);
      expect(AiProvider.anthropic.looksLikeKey('AIzaXXXXXXXX'), isFalse);
      expect(AiProvider.grok.looksLikeKey('sk-xxxxxxxxxxxx'), isFalse);
    });

    test('rejects empty / whitespace for every provider', () {
      for (final p in AiProvider.values) {
        expect(p.looksLikeKey(''), isFalse);
        expect(p.looksLikeKey('   '), isFalse);
        expect(p.looksLikeKey('AIza has a space'), isFalse);
      }
    });
  });

  test('capability flags', () {
    expect(AiProvider.gemini.supportsGrounding, isTrue);
    for (final p in [AiProvider.anthropic, AiProvider.openai, AiProvider.grok]) {
      expect(p.supportsGrounding, isFalse);
    }
    expect(AiProvider.gemini.supportsPdf, isTrue);
    expect(AiProvider.anthropic.supportsPdf, isTrue);
    expect(AiProvider.openai.supportsPdf, isFalse);
    expect(AiProvider.grok.supportsPdf, isFalse);
    for (final p in AiProvider.values) {
      expect(p.supportsVision, isTrue);
    }
    // Audio is Gemini-only.
    expect(AiProvider.gemini.supportsAudio, isTrue);
    for (final p in [AiProvider.anthropic, AiProvider.openai, AiProvider.grok]) {
      expect(p.supportsAudio, isFalse);
    }
    // Browser/CORS: Gemini + Anthropic work in-browser; OpenAI/Grok flagged off.
    expect(AiProvider.gemini.worksInBrowser, isTrue);
    expect(AiProvider.anthropic.worksInBrowser, isTrue);
    expect(AiProvider.openai.worksInBrowser, isFalse);
    expect(AiProvider.grok.worksInBrowser, isFalse);
  });

  test('chatCompletionsUrl for OpenAI-compatible providers', () {
    expect(AiProvider.openai.chatCompletionsUrl,
        'https://api.openai.com/v1/chat/completions');
    expect(AiProvider.grok.chatCompletionsUrl,
        'https://api.x.ai/v1/chat/completions');
    expect(() => AiProvider.gemini.chatCompletionsUrl, throwsStateError);
    expect(() => AiProvider.anthropic.chatCompletionsUrl, throwsStateError);
  });

  group('availableModels (app_data externalization)', () {
    // Restore default app_data so the mutation doesn't leak to other tests.
    tearDown(() => AppData.instance = AppData.fromJson(const {}));

    test('falls back to the hardcoded models when app_data has no override', () {
      AppData.instance = AppData.fromJson(const {});
      for (final p in AiProvider.values) {
        expect(p.availableModels, p.models);
      }
    });

    test('uses the app_data list when present (per provider)', () {
      AppData.instance = AppData.fromJson(const {
        'ai': {
          'providerModels': {
            'grok': ['grok-test-a', 'grok-test-b'],
          },
        },
      });
      expect(AiProvider.grok.availableModels, ['grok-test-a', 'grok-test-b']);
      // Providers without an override still fall back to the hardcoded list.
      expect(AiProvider.gemini.availableModels, AiProvider.gemini.models);
    });
  });

  test('fromName round-trips and defaults to gemini', () {
    for (final p in AiProvider.values) {
      expect(AiProvider.fromName(p.name), p);
    }
    expect(AiProvider.fromName(null), AiProvider.gemini);
    expect(AiProvider.fromName('not-a-provider'), AiProvider.gemini);
  });
}
