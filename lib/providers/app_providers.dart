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
  final bool boldText;
  final String languageCode; // 'en' / 'es' / 'zh' / 'ar'

  const AccessibilitySettings({
    this.textScale = 1.0,
    this.dyslexiaFont = false,
    this.reduceMotion = false,
    this.highContrast = false,
    this.boldText = false,
    this.languageCode = 'en',
  });

  AccessibilitySettings copyWith({
    double? textScale,
    bool? dyslexiaFont,
    bool? reduceMotion,
    bool? highContrast,
    bool? boldText,
    String? languageCode,
  }) =>
      AccessibilitySettings(
        textScale: textScale ?? this.textScale,
        dyslexiaFont: dyslexiaFont ?? this.dyslexiaFont,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        highContrast: highContrast ?? this.highContrast,
        boldText: boldText ?? this.boldText,
        languageCode: languageCode ?? this.languageCode,
      );

  /// Maps the discrete 0-3 slider to the actual Flutter text-scale factor.
  ///
  /// Older-adult usability (real user test, mid-70s): the out-of-box default
  /// read too small, so "Default" maps to 1.1 — a ~10% lift applied app-wide
  /// (it scales every `Text`, including hardcoded `fontSize:` values) without
  /// anyone needing to open Settings. "Small" still lands below 1.0 for users
  /// who want the tighter editorial look. See [[visual-accessibility-older-users]].
  double get textScaleFactor => switch (textScale.round()) {
        0 => 0.95,
        1 => 1.1,
        2 => 1.3,
        _ => 1.55,
      };
}

const _a11yTextScaleKey = 'mhad_a11y_text_scale';
const _a11yDyslexiaKey = 'mhad_a11y_dyslexia_font';
const _a11yReduceMotionKey = 'mhad_a11y_reduce_motion';
const _a11yHighContrastKey = 'mhad_a11y_high_contrast';
const _a11yBoldTextKey = 'mhad_a11y_bold_text';
const _a11yLanguageKey = 'mhad_a11y_language';

/// Holds the user's accessibility preferences and persists each one to
/// SharedPreferences so they survive a reload (mirrors [AppThemeController]).
class AccessibilitySettingsNotifier extends Notifier<AccessibilitySettings> {
  SharedPreferences? _prefs;

  @override
  AccessibilitySettings build() {
    _hydrate();
    return const AccessibilitySettings();
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    state = AccessibilitySettings(
      textScale: prefs.getDouble(_a11yTextScaleKey) ?? state.textScale,
      dyslexiaFont: prefs.getBool(_a11yDyslexiaKey) ?? state.dyslexiaFont,
      reduceMotion: prefs.getBool(_a11yReduceMotionKey) ?? state.reduceMotion,
      highContrast: prefs.getBool(_a11yHighContrastKey) ?? state.highContrast,
      boldText: prefs.getBool(_a11yBoldTextKey) ?? state.boldText,
      languageCode: prefs.getString(_a11yLanguageKey) ?? state.languageCode,
    );
  }

  void setTextScale(double v) {
    state = state.copyWith(textScale: v);
    _prefs?.setDouble(_a11yTextScaleKey, v);
  }

  void setDyslexiaFont(bool v) {
    state = state.copyWith(dyslexiaFont: v);
    _prefs?.setBool(_a11yDyslexiaKey, v);
  }

  void setReduceMotion(bool v) {
    state = state.copyWith(reduceMotion: v);
    _prefs?.setBool(_a11yReduceMotionKey, v);
  }

  void setHighContrast(bool v) {
    state = state.copyWith(highContrast: v);
    _prefs?.setBool(_a11yHighContrastKey, v);
  }

  void setBoldText(bool v) {
    state = state.copyWith(boldText: v);
    _prefs?.setBool(_a11yBoldTextKey, v);
  }

  void setLanguage(String code) {
    state = state.copyWith(languageCode: code);
    _prefs?.setString(_a11yLanguageKey, code);
  }

  /// Restore every accessibility setting to its default and clear storage.
  void resetToDefaults() {
    state = const AccessibilitySettings();
    for (final k in const [
      _a11yTextScaleKey,
      _a11yDyslexiaKey,
      _a11yReduceMotionKey,
      _a11yHighContrastKey,
      _a11yBoldTextKey,
      _a11yLanguageKey,
    ]) {
      _prefs?.remove(k);
    }
  }
}

final accessibilitySettingsProvider =
    NotifierProvider<AccessibilitySettingsNotifier, AccessibilitySettings>(
        AccessibilitySettingsNotifier.new);

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
