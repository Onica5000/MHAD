import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/services/gemini_model_service.dart';

GeminiModel _m(String id, {List<String> methods = const ['generateContent']}) =>
    GeminiModel(
      id: id,
      displayName: id,
      description: '',
      inputTokenLimit: 1000000,
      outputTokenLimit: 65536,
      supportedMethods: methods,
    );

void main() {
  group('GeminiModelService.rank', () {
    test('recommends the newest non-lite Flash, ignoring lite/older', () {
      final models = [
        _m('gemini-2.5-flash'),
        _m('gemini-2.5-flash-lite'),
        _m('gemini-3.5-flash'),
        _m('gemini-2.0-flash'),
      ];
      final rec = GeminiModelService.rank(models, 'gemini-2.5-flash');
      expect(rec.bestFlash!.id, 'gemini-3.5-flash');
    });

    test('picks the newest Pro for the alternative', () {
      final models = [
        _m('gemini-2.5-pro'),
        _m('gemini-1.5-pro'),
        _m('gemini-3.5-flash'),
      ];
      final rec = GeminiModelService.rank(models, 'gemini-3.5-flash');
      expect(rec.bestPro!.id, 'gemini-2.5-pro');
      expect(rec.bestFlash!.id, 'gemini-3.5-flash');
    });

    test('excludes aliases, previews, embeddings and non-generate models', () {
      final models = [
        _m('gemini-flash-latest'), // alias
        _m('gemini-3.5-flash-preview-09-2026'), // preview
        _m('gemini-2.0-flash-exp'), // experimental
        _m('text-embedding-004', methods: ['embedContent']), // not generate
        _m('gemini-2.5-flash'), // the only valid one
      ];
      final rec = GeminiModelService.rank(models, 'gemini-2.0-flash');
      expect(rec.bestFlash!.id, 'gemini-2.5-flash');
    });

    test('ties break toward the canonical (shortest) id', () {
      final models = [
        _m('gemini-3.5-flash-002'),
        _m('gemini-3.5-flash'),
      ];
      final rec = GeminiModelService.rank(models, 'gemini-2.5-flash');
      expect(rec.bestFlash!.id, 'gemini-3.5-flash');
    });

    test('falls back to a lite Flash only when no full Flash exists', () {
      final models = [_m('gemini-3.5-flash-lite')];
      final rec = GeminiModelService.rank(models, 'gemini-2.5-flash');
      expect(rec.bestFlash!.id, 'gemini-3.5-flash-lite');
    });

    test('curatedFreeModelIds keeps only free Flash text models, newest-first',
        () {
      final models = [
        _m('gemini-2.5-pro'), // paid → excluded
        _m('gemini-2.5-flash'),
        _m('gemini-3.5-flash'),
        _m('gemini-3.5-flash-lite'),
        _m('gemini-flash-latest'), // alias → excluded
        _m('text-embedding-004', methods: ['embedContent']), // excluded
      ];
      final ids = GeminiModelService.curatedFreeModelIds(models);
      expect(ids, ['gemini-3.5-flash', 'gemini-3.5-flash-lite', 'gemini-2.5-flash']);
      expect(ids.contains('gemini-2.5-pro'), isFalse);
    });

    test('isNewerThanCurrent is false for same id, true for higher version', () {
      final models = [_m('gemini-3.5-flash')];
      final rec = GeminiModelService.rank(models, 'gemini-2.5-flash');
      expect(rec.isNewerThanCurrent(rec.bestFlash), isTrue);

      final same = GeminiModelService.rank(
          [_m('gemini-3.5-flash')], 'gemini-3.5-flash');
      expect(same.isNewerThanCurrent(same.bestFlash), isFalse);
    });
  });
}
