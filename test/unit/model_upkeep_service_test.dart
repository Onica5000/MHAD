import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mhad/ai/ai_prefs.dart';
import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/services/ai_model_catalog_service.dart';
import 'package:mhad/services/model_upkeep_service.dart';

/// Guards the all-provider model upkeep: filtering, retired/new detection,
/// the proposed list, and that the app follows the admin-updated lists.
void main() {
  group('isRelevant', () {
    test('keeps chat models, drops non-chat and snapshots', () {
      bool r(AiProvider p, String id) => ModelUpkeepService.isRelevant(p, id);
      expect(r(AiProvider.openai, 'gpt-6.1-sol'), isTrue);
      expect(r(AiProvider.openai, 'o5-mini'), isTrue);
      expect(r(AiProvider.openai, 'gpt-6.1-sol-2026-08-01'), isFalse);
      expect(r(AiProvider.openai, 'gpt-5.4-realtime'), isFalse);
      expect(r(AiProvider.openai, 'text-embedding-3-large'), isFalse);
      expect(r(AiProvider.openai, 'gpt-image-2'), isFalse);
      expect(r(AiProvider.openai, 'whisper-1'), isFalse);
      expect(r(AiProvider.anthropic, 'claude-sonnet-5-5'), isTrue);
      expect(r(AiProvider.grok, 'grok-4.7'), isTrue);
      expect(r(AiProvider.grok, 'grok-imagine-image'), isFalse);
    });
  });

  group('audit', () {
    test('flags retired curated models and offers new ones (capped)', () {
      final a = ModelUpkeepService.audit(
        AiProvider.anthropic,
        ['claude-old', 'claude-haiku-4-5'],
        ['claude-new', 'claude-haiku-4-5', 'claude-x'],
        ['claude-new', 'claude-haiku-4-5', 'claude-x'],
      );
      expect(a.checked, isTrue);
      expect(a.retired, ['claude-old']);
      expect(a.newcomers, ['claude-new', 'claude-x']);
    });

    test('an empty catalog is a problem, not "everything retired"', () {
      final a = ModelUpkeepService.audit(
          AiProvider.grok, ['grok-4.7'], const [], const []);
      expect(a.checked, isFalse);
      expect(a.retired, isEmpty);
    });

    test('newcomers are capped', () {
      final ids = [for (var i = 0; i < 20; i++) 'grok-$i'];
      final a = ModelUpkeepService.audit(AiProvider.grok, const [], ids, ids);
      expect(a.newcomers.length, ModelAudit.maxNewcomers);
    });
  });

  group('proposedList', () {
    const a = ModelAudit(
      provider: AiProvider.openai,
      current: ['gpt-a', 'gpt-b', 'gpt-c'],
      retired: ['gpt-a'],
      newcomers: ['gpt-d'],
    );

    test('drops retired (default moves up) and appends picks', () {
      expect(ModelUpkeepService.proposedList(a, {'gpt-d'}),
          ['gpt-b', 'gpt-c', 'gpt-d']);
    });

    test('null when nothing changes or the list would be empty', () {
      const same = ModelAudit(provider: AiProvider.openai, current: ['gpt-a']);
      expect(ModelUpkeepService.proposedList(same, const {}), isNull);
      const allGone = ModelAudit(
          provider: AiProvider.openai, current: ['gpt-a'], retired: ['gpt-a']);
      expect(ModelUpkeepService.proposedList(allGone, const {}), isNull);
    });
  });

  test('check() never throws; no key → skipped with a reason', () async {
    final a = await ModelUpkeepService().check(AiProvider.grok, '', ['grok-4.7']);
    expect(a.checked, isFalse);
    expect(a.problem, contains('No xAI Grok key'));
  });

  test('catalog ids come back newest first', () async {
    final client = MockClient((req) async => http.Response(
        jsonEncode({
          'data': [
            {'id': 'claude-older', 'created_at': '2025-01-01T00:00:00Z'},
            {'id': 'claude-newest', 'created_at': '2026-09-01T00:00:00Z'},
            {'id': 'claude-mid', 'created_at': '2026-02-01T00:00:00Z'},
          ],
        }),
        200));
    final ids = await AiModelCatalogService(client: client)
        .fetchModelIds(AiProvider.anthropic, 'sk-ant-test');
    expect(ids, ['claude-newest', 'claude-mid', 'claude-older']);
  });

  group('app follows the admin-updated lists', () {
    tearDown(() => AppData.instance = AppData.fromJson(const {}));

    test('non-Gemini default = first entry of providerModels', () {
      AppData.instance = AppData.fromJson(const {
        'ai': {
          'providerModels': {
            'anthropic': ['claude-next', 'claude-haiku-4-5'],
          },
        },
      });
      expect(AiProvider.anthropic.currentDefault, 'claude-next');
      expect(AiProvider.anthropic.resolveModel(null), 'claude-next');
    });

    test('a saved model that was retired falls back to the default', () {
      AppData.instance = AppData.fromJson(const {
        'ai': {
          'model': 'gemini-next-lite',
          'providerModels': {
            'openai': ['gpt-new', 'gpt-other'],
            'gemini': ['gemini-next-lite'],
          },
        },
      });
      const prefs = AiPrefs(provider: AiProvider.openai, models: {
        AiProvider.openai: 'gpt-retired',
        AiProvider.gemini: 'gemini-next-lite',
      });
      expect(prefs.modelFor(AiProvider.openai), 'gpt-new');
      expect(prefs.modelFor(AiProvider.gemini), 'gemini-next-lite');
      const kept = AiPrefs(
          provider: AiProvider.openai, models: {AiProvider.openai: 'gpt-other'});
      expect(kept.modelFor(AiProvider.openai), 'gpt-other');
    });
  });
}
