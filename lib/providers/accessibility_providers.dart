import 'package:flutter_riverpod/flutter_riverpod.dart';

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
