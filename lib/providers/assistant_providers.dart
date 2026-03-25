import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/draft_recovery_service.dart';
import 'package:mhad/services/gemini_rate_tracker.dart';
import 'package:mhad/services/public_session_cache.dart';

const _apiKeyStorageKey = 'gemini_api_key';

// ---------------------------------------------------------------------------
// Persisted API key (private mode only — stored in flutter_secure_storage)
// ---------------------------------------------------------------------------

final _secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device),
  ),
);

class _PersistedApiKeyNotifier extends StateNotifier<AsyncValue<String?>> {
  final FlutterSecureStorage _storage;

  _PersistedApiKeyNotifier(this._storage) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final key = await _storage.read(key: _apiKeyStorageKey);
      state = AsyncValue.data(key);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> save(String key) async {
    await _storage.write(key: _apiKeyStorageKey, value: key.trim());
    state = AsyncValue.data(key.trim());
  }

  Future<void> delete() async {
    await _storage.delete(key: _apiKeyStorageKey);
    state = const AsyncValue.data(null);
  }
}

final _persistedApiKeyProvider =
    StateNotifierProvider<_PersistedApiKeyNotifier, AsyncValue<String?>>((ref) {
  return _PersistedApiKeyNotifier(ref.watch(_secureStorageProvider));
});

// ---------------------------------------------------------------------------
// Ephemeral API key (public mode / web — in-memory only, never persisted)
// ---------------------------------------------------------------------------

class _EphemeralApiKeyNotifier extends StateNotifier<AsyncValue<String?>> {
  _EphemeralApiKeyNotifier(String? preloadedKey)
      : super(AsyncValue.data(preloadedKey));

  void save(String key) {
    final trimmed = key.trim();
    state = AsyncValue.data(trimmed);
    // Also cache to shared_preferences with TTL for crash recovery
    PublicSessionCache.cacheApiKey(trimmed);
  }

  void delete() {
    state = const AsyncValue.data(null);
    PublicSessionCache.clearAll();
  }
}

/// Pre-loaded cached API key from SharedPreferences, resolved in main()
/// before runApp() so it's available synchronously on the first frame.
final preloadedApiKeyProvider = StateProvider<String?>((_) => null);

final _ephemeralApiKeyProvider =
    StateNotifierProvider<_EphemeralApiKeyNotifier, AsyncValue<String?>>((ref) {
  final preloaded = ref.read(preloadedApiKeyProvider);
  return _EphemeralApiKeyNotifier(preloaded);
});

// ---------------------------------------------------------------------------
// Unified API key provider — delegates to persisted or ephemeral based on mode
// ---------------------------------------------------------------------------

/// Returns the current API key for the session.
///
/// - **Private mode**: reads from flutter_secure_storage (persists across sessions)
/// - **Public mode / web**: reads from in-memory state (lost when app closes)
final apiKeyProvider = Provider<AsyncValue<String?>>((ref) {
  final mode = ref.watch(privacyModeNotifierProvider);

  if (mode.isPrivate) {
    return ref.watch(_persistedApiKeyProvider);
  } else {
    return ref.watch(_ephemeralApiKeyProvider);
  }
});

/// Whether the current session uses ephemeral (non-persisted) API key storage.
bool isEphemeralApiKeyMode(WidgetRef ref) {
  return !ref.read(privacyModeNotifierProvider).isPrivate;
}

// ---------------------------------------------------------------------------
// API key mutators — call the right notifier based on mode
// ---------------------------------------------------------------------------

/// Save an API key. In private mode it persists to secure storage.
/// In public mode it's held in memory only.
Future<void> saveApiKey(WidgetRef ref, String key) async {
  final mode = ref.read(privacyModeNotifierProvider);
  if (mode.isPrivate) {
    await ref.read(_persistedApiKeyProvider.notifier).save(key);
  } else {
    ref.read(_ephemeralApiKeyProvider.notifier).save(key);
  }
}

/// Delete the API key from the current mode's storage.
Future<void> deleteApiKey(WidgetRef ref) async {
  final mode = ref.read(privacyModeNotifierProvider);
  if (mode.isPrivate) {
    await ref.read(_persistedApiKeyProvider.notifier).delete();
  } else {
    ref.read(_ephemeralApiKeyProvider.notifier).delete();
  }
}

/// Wipe all public session data: API key cache, draft recovery, conversation.
/// Call when the user explicitly ends their public session.
Future<void> endPublicSession(WidgetRef ref) async {
  // Clear ephemeral API key (in-memory + shared_preferences cache)
  ref.read(_ephemeralApiKeyProvider.notifier).delete();
  // Clear conversation history
  ref.read(conversationProvider.notifier).clear();
  // Clear AI consent
  ref.read(aiConsentGivenProvider.notifier).state = false;
  // Clear draft recovery files
  await DraftRecoveryService.clearDraft();
  // Clear the public session cache (redundant with delete() above but explicit)
  await PublicSessionCache.clearAll();
}

// ---------------------------------------------------------------------------
// Conversation history (per-session, not persisted)
// ---------------------------------------------------------------------------

class ConversationNotifier extends StateNotifier<List<ChatMessage>> {
  ConversationNotifier() : super([]);

  static const maxMessages = 100;

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
// AiAssistant instance (derived from the current API key)
// ---------------------------------------------------------------------------

final aiAssistantProvider = Provider<AiAssistant?>((ref) {
  final keyAsync = ref.watch(apiKeyProvider);
  return keyAsync.whenOrNull(
    data: (key) =>
        key != null && key.isNotEmpty ? GeminiApiAssistant(apiKey: key) : null,
  );
});

// ---------------------------------------------------------------------------
// Gemini rate limit tracker (per-session, in-memory)
// ---------------------------------------------------------------------------

final geminiRateTrackerProvider =
    ChangeNotifierProvider<GeminiRateTracker>((_) => GeminiRateTracker());
