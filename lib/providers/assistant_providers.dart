import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/ai/ai_context_builder.dart';
import 'package:mhad/ai/ai_prefs.dart';
import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/draft_recovery_service.dart';
import 'package:mhad/services/gemini_rate_tracker.dart';
import 'package:mhad/services/public_session_cache.dart';

// Secure-storage keys. Keys/models are stored per provider so switching
// providers doesn't lose a previously-entered key.
String _keyStorageKey(AiProvider p) => 'ai_key_${p.name}';
String _modelStorageKey(AiProvider p) => 'ai_model_${p.name}';
const _activeProviderStorageKey = 'ai_active_provider';
const _legacyGeminiKeyStorageKey = 'gemini_api_key'; // pre-multi-provider

final _secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device),
  ),
);

// ---------------------------------------------------------------------------
// Private mode — AI prefs persisted to flutter_secure_storage
// ---------------------------------------------------------------------------

class _PrivateAiNotifier extends StateNotifier<AsyncValue<AiPrefs>> {
  final FlutterSecureStorage _storage;

  _PrivateAiNotifier(this._storage) : super(const AsyncValue.loading()) {
    _load();
  }

  AiPrefs get _current => state.valueOrNull ?? AiPrefs.initial;

  Future<void> _load() async {
    try {
      final provider =
          AiProvider.fromName(await _storage.read(key: _activeProviderStorageKey));
      final keys = <AiProvider, String>{};
      final models = <AiProvider, String>{};
      for (final p in AiProvider.values) {
        var key = await _storage.read(key: _keyStorageKey(p));
        // Migrate the pre-multi-provider single Gemini key on first load.
        if ((key == null || key.isEmpty) && p == AiProvider.gemini) {
          final legacy = await _storage.read(key: _legacyGeminiKeyStorageKey);
          if (legacy != null && legacy.isNotEmpty) {
            key = legacy;
            await _storage.write(key: _keyStorageKey(p), value: legacy);
            await _storage.delete(key: _legacyGeminiKeyStorageKey);
          }
        }
        if (key != null && key.isNotEmpty) keys[p] = key;
        final model = await _storage.read(key: _modelStorageKey(p));
        if (model != null && model.isNotEmpty) models[p] = model;
      }
      state = AsyncValue.data(
          AiPrefs(provider: provider, keys: keys, models: models));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveKey(AiProvider p, String key) async {
    state = AsyncValue.data(_current.withKey(p, key));
    if (key.trim().isEmpty) {
      await _storage.delete(key: _keyStorageKey(p));
    } else {
      await _storage.write(key: _keyStorageKey(p), value: key.trim());
    }
  }

  Future<void> setProvider(AiProvider p) async {
    state = AsyncValue.data(_current.withProvider(p));
    await _storage.write(key: _activeProviderStorageKey, value: p.name);
  }

  Future<void> setModel(AiProvider p, String model) async {
    state = AsyncValue.data(_current.withModel(p, model));
    await _storage.write(key: _modelStorageKey(p), value: model.trim());
  }

  Future<void> deleteKey(AiProvider p) => saveKey(p, '');
}

final _privateAiProvider =
    StateNotifierProvider<_PrivateAiNotifier, AsyncValue<AiPrefs>>((ref) {
  return _PrivateAiNotifier(ref.watch(_secureStorageProvider));
});

// ---------------------------------------------------------------------------
// Public mode / web — AI prefs in memory, mirrored to PublicSessionCache (TTL)
// for crash recovery. Not persisted long-term / encrypted like private mode.
// ---------------------------------------------------------------------------

class _EphemeralAiNotifier extends StateNotifier<AiPrefs> {
  _EphemeralAiNotifier(super.preloaded);

  void _cache() => PublicSessionCache.cachePrefs(state);

  void saveKey(AiProvider p, String key) {
    state = state.withKey(p, key);
    _cache();
  }

  void setProvider(AiProvider p) {
    state = state.withProvider(p);
    _cache();
  }

  void setModel(AiProvider p, String model) {
    state = state.withModel(p, model);
    _cache();
  }

  void deleteKey(AiProvider p) => saveKey(p, '');

  void clear() {
    state = AiPrefs.initial;
    PublicSessionCache.clearAll();
  }
}

/// Pre-loaded cached AI prefs from the public-session cache, resolved in main()
/// before runApp() so they're available synchronously on the first frame.
final preloadedAiPrefsProvider = StateProvider<AiPrefs>((_) => AiPrefs.initial);

final _ephemeralAiProvider =
    StateNotifierProvider<_EphemeralAiNotifier, AiPrefs>((ref) {
  return _EphemeralAiNotifier(ref.read(preloadedAiPrefsProvider));
});

// ---------------------------------------------------------------------------
// Unified AI prefs/config — delegates to private or ephemeral based on mode
// ---------------------------------------------------------------------------

/// The active AI configuration for the session (mode-aware).
final aiPrefsProvider = Provider<AsyncValue<AiPrefs>>((ref) {
  final mode = ref.watch(privacyModeNotifierProvider);
  if (mode.isPrivate) {
    return ref.watch(_privateAiProvider);
  }
  return AsyncValue.data(ref.watch(_ephemeralAiProvider));
});

/// The currently-selected provider (defaults to Gemini).
final activeProviderProvider = Provider<AiProvider>((ref) =>
    ref.watch(aiPrefsProvider).valueOrNull?.provider ?? AiProvider.gemini);

/// The model id for the active provider.
final activeModelProvider = Provider<String>((ref) =>
    ref.watch(aiPrefsProvider).valueOrNull?.activeModel ?? appData.ai.model);

/// The API key for the active provider (kept as the historical "do we have a
/// key?" signal across the app).
final apiKeyProvider = Provider<AsyncValue<String?>>(
    (ref) => ref.watch(aiPrefsProvider).whenData((p) => p.activeKey));

/// Resolved (provider, model, key) for the active provider — null when there's
/// no usable key yet. Construction sites (assistant, extractor, smart-fill)
/// read this.
typedef AiConfig = ({AiProvider provider, String model, String key});

final aiConfigProvider = Provider<AiConfig?>((ref) {
  final prefs = ref.watch(aiPrefsProvider).valueOrNull;
  final key = prefs?.activeKey;
  if (prefs == null || key == null || key.isEmpty) return null;
  return (provider: prefs.provider, model: prefs.activeModel, key: key);
});

/// Whether the current session uses ephemeral (non-persisted) key storage.
bool isEphemeralApiKeyMode(WidgetRef ref) =>
    !ref.read(privacyModeNotifierProvider).isPrivate;

// ---------------------------------------------------------------------------
// Mutators — call the right notifier based on mode
// ---------------------------------------------------------------------------

/// Save an API key for [provider] (defaults to the active provider). In private
/// mode it persists to secure storage; in public mode it's in-memory only.
Future<void> saveApiKey(WidgetRef ref, String key, {AiProvider? provider}) async {
  final AiProvider p = provider ?? ref.read(activeProviderProvider);
  if (ref.read(privacyModeNotifierProvider).isPrivate) {
    await ref.read(_privateAiProvider.notifier).saveKey(p, key);
  } else {
    ref.read(_ephemeralAiProvider.notifier).saveKey(p, key);
  }
}

/// Delete [provider]'s API key (defaults to the active provider).
Future<void> deleteApiKey(WidgetRef ref, {AiProvider? provider}) async {
  final AiProvider p = provider ?? ref.read(activeProviderProvider);
  if (ref.read(privacyModeNotifierProvider).isPrivate) {
    await ref.read(_privateAiProvider.notifier).deleteKey(p);
  } else {
    ref.read(_ephemeralAiProvider.notifier).deleteKey(p);
  }
}

/// Switch the active provider.
Future<void> setActiveProvider(WidgetRef ref, AiProvider provider) async {
  if (ref.read(privacyModeNotifierProvider).isPrivate) {
    await ref.read(_privateAiProvider.notifier).setProvider(provider);
  } else {
    ref.read(_ephemeralAiProvider.notifier).setProvider(provider);
  }
}

/// Set the model for the active provider.
Future<void> setActiveModel(WidgetRef ref, String model) async {
  final p = ref.read(activeProviderProvider);
  if (ref.read(privacyModeNotifierProvider).isPrivate) {
    await ref.read(_privateAiProvider.notifier).setModel(p, model);
  } else {
    ref.read(_ephemeralAiProvider.notifier).setModel(p, model);
  }
}

/// Wipe all public session data: AI keys, draft recovery, conversation, consent.
/// Call when the user explicitly ends their public session.
Future<void> endPublicSession(WidgetRef ref) async {
  ref.read(_ephemeralAiProvider.notifier).clear();
  ref.read(conversationProvider.notifier).clear();
  ref.read(aiConsentGivenProvider.notifier).state = false;
  await DraftRecoveryService.clearDraft();
  await PublicSessionCache.clearAll();
}

// ---------------------------------------------------------------------------
// Conversation history (per-session, not persisted)
// ---------------------------------------------------------------------------

class ConversationNotifier extends StateNotifier<List<ChatMessage>> {
  ConversationNotifier() : super([]);

  static int get maxMessages => appData.config.maxChatMessages;

  void add(ChatMessage message) {
    final updated = [...state, message];
    if (updated.length > maxMessages) {
      state = updated.sublist(updated.length - maxMessages);
    } else {
      state = updated;
    }
  }

  void clear() => state = [];
}

final conversationProvider =
    StateNotifierProvider<ConversationNotifier, List<ChatMessage>>(
  (_) => ConversationNotifier(),
);

// ---------------------------------------------------------------------------
// Sending state
// ---------------------------------------------------------------------------

final isSendingProvider = StateProvider<bool>((_) => false);

// ---------------------------------------------------------------------------
// Per-session AI consent. Resets on app restart.
// ---------------------------------------------------------------------------

final aiConsentGivenProvider = StateProvider<bool>((_) => false);

// ---------------------------------------------------------------------------
// AiAssistant instance (derived from the active provider/model/key)
// ---------------------------------------------------------------------------

final aiAssistantProvider = Provider<AiAssistant?>((ref) {
  final cfg = ref.watch(aiConfigProvider);
  if (cfg == null) return null;
  return LlmAssistant(
    provider: cfg.provider,
    model: cfg.model,
    apiKey: cfg.key,
  );
});

// ---------------------------------------------------------------------------
// Wizard AI rail — live per-step "heads-up" + suggested-question chips
// ---------------------------------------------------------------------------

/// Key for [wizardRailSuggestionsProvider]: the form type + current step name
/// + the directive id (so the rail can ground its suggestions in the answers
/// already entered). A record so Riverpod caches one generation per distinct
/// step/directive and re-uses it when revisiting the step.
typedef RailSuggestionKey = ({String formType, String stepName, int directiveId});

/// Live-generated heads-up note + suggested-question chips for the wizard's
/// inline AI rail. Null when there's no API key or generation fails (the rail
/// then shows its static fallback / "set up AI" prompt). Cached per step.
///
/// The suggestions are grounded in the user's answers so far: it pulls the
/// PII-safe correlating fields ([buildAiFilledFields]) for this directive and
/// passes them as context, so a step's heads-up/chips reflect what's already
/// filled (e.g. medications listed earlier) rather than being generic.
///
/// `autoDispose`: the result is dropped when the user leaves the step (the rail
/// unmounts), so RE-ENTERING a step regenerates with the latest answers — if
/// they go back and change an earlier answer, the rail refreshes on return.
/// Within a step it stays cached (one generation per visit), so it never
/// regenerates on every keystroke and stays within the free-tier rate budget.
final wizardRailSuggestionsProvider = FutureProvider.autoDispose.family<
    ({String headsUp, List<String> chips})?, RailSuggestionKey>(
  (ref, key) async {
    final assistant = ref.watch(aiAssistantProvider);
    if (assistant is! LlmAssistant) return null;
    final repo = ref.read(directiveRepositoryProvider);
    final filled = await buildAiFilledFields(repo, key.directiveId);
    return assistant.generateStepSuggestions(
      AssistantContext(
        formType: key.formType,
        stepName: key.stepName,
        filledFields: filled.isEmpty ? null : filled,
      ),
    );
  },
);

// ---------------------------------------------------------------------------
// Gemini rate limit tracker (per-session, in-memory)
// ---------------------------------------------------------------------------

final geminiRateTrackerProvider =
    ChangeNotifierProvider<GeminiRateTracker>((_) => GeminiRateTracker());
