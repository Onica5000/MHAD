import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/ai_prefs.dart';
import 'package:mhad/ai/ai_provider.dart';

void main() {
  test('toJson/fromJson round-trips provider, keys, and models', () {
    const prefs = AiPrefs(
      provider: AiProvider.anthropic,
      keys: {AiProvider.gemini: 'g-key', AiProvider.anthropic: 'a-key'},
      models: {AiProvider.openai: 'gpt-4o'},
    );
    final restored = AiPrefs.fromJson(prefs.toJson());
    expect(restored.provider, AiProvider.anthropic);
    expect(restored.keys[AiProvider.gemini], 'g-key');
    expect(restored.keys[AiProvider.anthropic], 'a-key');
    expect(restored.models[AiProvider.openai], 'gpt-4o');
  });

  test('fromJson tolerates junk and defaults the provider to gemini', () {
    final p = AiPrefs.fromJson({
      'provider': 'nonsense',
      'keys': {'gemini': 'g', 'bogus': 'x', 'openai': ''},
      'models': 'not-a-map',
    });
    expect(p.provider, AiProvider.gemini);
    expect(p.keys[AiProvider.gemini], 'g');
    expect(p.keys.containsKey(AiProvider.openai), isFalse); // empty dropped
    expect(p.keys.length, 1); // 'bogus' ignored
    expect(p.models, isEmpty);
  });

  test('immutable updates: withKey / withProvider / withModel', () {
    const base = AiPrefs(provider: AiProvider.gemini);

    final withKey = base.withKey(AiProvider.openai, '  sk-x  ');
    expect(withKey.keys[AiProvider.openai], 'sk-x'); // trimmed
    expect(base.keys, isEmpty); // original untouched

    final cleared = withKey.withKey(AiProvider.openai, '   ');
    expect(cleared.keys.containsKey(AiProvider.openai), isFalse); // empty removes

    expect(base.withProvider(AiProvider.grok).provider, AiProvider.grok);
    expect(base.withModel(AiProvider.anthropic, 'claude-x').models[
        AiProvider.anthropic], 'claude-x');
  });
}
