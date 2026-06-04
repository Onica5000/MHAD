import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
