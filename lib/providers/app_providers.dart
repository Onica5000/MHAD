import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the single [PrivacyModeNotifier] instance created in [main()].
/// Overridden via [ProviderScope] before [runApp()] so the same notifier
/// instance used by the router is also visible to Riverpod providers.
final privacyModeNotifierProvider =
    ChangeNotifierProvider<PrivacyModeNotifier>(
  (_) => PrivacyModeNotifier(), // default — overridden in main()
);

/// Holds the database encryption key resolved at startup.
///
/// Overridden in [main()] with the key from [DatabaseEncryptionService].
/// This provider is read (not watched) by [appDatabaseProvider] to build
/// the encrypted connection for private mode.
final dbEncryptionKeyProvider = Provider<String>(
  (_) => throw UnimplementedError(
    'dbEncryptionKeyProvider must be overridden in ProviderScope',
  ),
);

/// Returns the correct database for the current session mode:
///   - Public  -> in-memory (data is lost on app close, no private data exposed)
///   - Private -> encrypted file-based (SQLCipher, key from secure storage)
///
/// Automatically invalidated when the privacy mode changes, so widgets
/// watching this provider get a fresh database for the new mode.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final modeNotifier = ref.watch(privacyModeNotifierProvider);

  final AppDatabase db;
  if (modeNotifier.isPrivate) {
    // Private mode: encrypted file-based database via SQLCipher.
    // The encryption key was resolved at startup and injected via override.
    final encryptionKey = ref.read(dbEncryptionKeyProvider);
    db = createEncryptedDatabase(encryptionKey);
  } else {
    // Public mode (or mode not yet selected): ephemeral, in-memory SQLite.
    db = createMemoryDatabase();
  }
  ref.onDispose(db.close);
  return db;
});

final directiveRepositoryProvider = Provider<DirectiveRepository>(
  (ref) => DirectiveRepository(ref.watch(appDatabaseProvider)),
);

final allDirectivesProvider = StreamProvider<List<Directive>>(
  (ref) => ref.watch(directiveRepositoryProvider).watchAllDirectives(),
);

final directiveByIdProvider =
    FutureProvider.family<Directive?, int>((ref, id) =>
        ref.watch(directiveRepositoryProvider).getDirectiveById(id));

// ---------------------------------------------------------------------------
// Accessibility settings
// ---------------------------------------------------------------------------

/// Lightweight in-memory accessibility settings (Phase 4).
///
/// In private mode we'd persist these to secure storage; in public/web they
/// stay session-only. The screen wires through the notifier; the app shell
/// can read `accessibilitySettingsProvider` and pass `textScaler` to
/// `MaterialApp.builder`.
class AccessibilitySettings {
  final double textScale; // 0 = small, 1 = default, 2 = large, 3 = huge
  final bool dyslexiaFont;
  final bool reduceMotion;
  final bool highContrast;
  final bool voiceOverHints;
  final String languageCode; // 'en' / 'es' / 'zh' / 'ar'

  const AccessibilitySettings({
    this.textScale = 1.0,
    this.dyslexiaFont = false,
    this.reduceMotion = false,
    this.highContrast = false,
    this.voiceOverHints = true,
    this.languageCode = 'en',
  });

  AccessibilitySettings copyWith({
    double? textScale,
    bool? dyslexiaFont,
    bool? reduceMotion,
    bool? highContrast,
    bool? voiceOverHints,
    String? languageCode,
  }) =>
      AccessibilitySettings(
        textScale: textScale ?? this.textScale,
        dyslexiaFont: dyslexiaFont ?? this.dyslexiaFont,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        highContrast: highContrast ?? this.highContrast,
        voiceOverHints: voiceOverHints ?? this.voiceOverHints,
        languageCode: languageCode ?? this.languageCode,
      );

  /// Maps the discrete 0-3 slider to the actual Flutter text-scale factor.
  double get textScaleFactor => switch (textScale.round()) {
        0 => 0.85,
        1 => 1.0,
        2 => 1.2,
        _ => 1.45,
      };
}

class AccessibilitySettingsNotifier
    extends StateNotifier<AccessibilitySettings> {
  AccessibilitySettingsNotifier() : super(const AccessibilitySettings());

  void setTextScale(double v) => state = state.copyWith(textScale: v);
  void setDyslexiaFont(bool v) => state = state.copyWith(dyslexiaFont: v);
  void setReduceMotion(bool v) => state = state.copyWith(reduceMotion: v);
  void setHighContrast(bool v) => state = state.copyWith(highContrast: v);
  void setVoiceOverHints(bool v) => state = state.copyWith(voiceOverHints: v);
  void setLanguage(String code) => state = state.copyWith(languageCode: code);
}

final accessibilitySettingsProvider =
    StateNotifierProvider<AccessibilitySettingsNotifier, AccessibilitySettings>(
        (ref) => AccessibilitySettingsNotifier());

// ---------------------------------------------------------------------------
// Theme settings (palette + brightness mode, persisted via SharedPreferences)
// ---------------------------------------------------------------------------

const _paletteKey = 'mhad_theme_palette';
const _modeKey = 'mhad_theme_mode';

/// Holds the user's visual preferences and persists them via SharedPreferences.
class AppThemeSettings {
  final ThemePalette palette;
  final ThemeMode mode;

  const AppThemeSettings({required this.palette, required this.mode});

  AppThemeSettings copyWith({ThemePalette? palette, ThemeMode? mode}) =>
      AppThemeSettings(
        palette: palette ?? this.palette,
        mode: mode ?? this.mode,
      );
}

class AppThemeController extends Notifier<AppThemeSettings> {
  SharedPreferences? _prefs;

  @override
  AppThemeSettings build() {
    // Per user direction (2026-06-02): the app ships in Deep Navy only.
    // No in-app palette picker; the teal/sage palettes remain in
    // `app_theme.dart` as inert tokens but are unreachable from the UI.
    // Hydration only restores the brightness mode now — any persisted
    // palette is force-migrated to navy and the key is cleared.
    _hydrate();
    return const AppThemeSettings(
      palette: ThemePalette.navy,
      mode: ThemeMode.system,
    );
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;

    // One-shot migration: drop any persisted palette choice from earlier
    // builds. We never write to this key again, so this only fires once
    // per device.
    if (prefs.containsKey(_paletteKey)) {
      await prefs.remove(_paletteKey);
    }

    final modeName = prefs.getString(_modeKey);
    ThemeMode? mode;
    for (final m in ThemeMode.values) {
      if (m.name == modeName) {
        mode = m;
        break;
      }
    }
    if (mode == null) return;
    state = state.copyWith(mode: mode);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _prefs?.setString(_modeKey, mode.name);
  }
}

final appThemeControllerProvider =
    NotifierProvider<AppThemeController, AppThemeSettings>(
        AppThemeController.new);
