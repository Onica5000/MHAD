import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mhad/ai/ai_provider.dart';

/// The one shared [FlutterSecureStorage] configuration. Every secure-storage
/// consumer (AI keys, DB encryption key, PIN hash) must use this instance so
/// the Android/iOS options never drift apart between features.
const FlutterSecureStorage appSecureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
);

/// Central registry of the app's secure-storage key strings, so new keys are
/// added in one visible place instead of scattered per feature (collision
/// insurance). Session/preference keys stored in SharedPreferences keep their
/// feature-local constants; this registry is for SECURE storage only.
class SecureStorageKeys {
  SecureStorageKeys._();

  /// Per-provider AI API key ('ai_key_gemini', 'ai_key_anthropic', …).
  static String aiKey(AiProvider p) => 'ai_key_${p.name}';

  /// Per-provider chosen model id ('ai_model_gemini', …).
  static String aiModel(AiProvider p) => 'ai_model_${p.name}';

  /// The active AI provider's name.
  static const aiActiveProvider = 'ai_active_provider';

  /// Pre-multi-provider single Gemini key — read once for migration.
  static const legacyGeminiKey = 'gemini_api_key';

  /// SQLCipher database encryption key (private mode).
  static const dbEncryptionKey = 'mhad_db_encryption_key';

  /// Private-mode passcode HMAC hash + its salt.
  static const pinHash = 'mhad_pin_hash';
  static const pinSalt = 'mhad_pin_salt';
}
