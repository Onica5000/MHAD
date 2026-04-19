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
    // Defaults — hydrated asynchronously once prefs are loaded.
    _hydrate();
    return const AppThemeSettings(
      palette: ThemePalette.teal,
      mode: ThemeMode.system,
    );
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final paletteName = prefs.getString(_paletteKey);
    final modeName = prefs.getString(_modeKey);

    ThemePalette? palette;
    for (final p in ThemePalette.values) {
      if (p.name == paletteName) {
        palette = p;
        break;
      }
    }

    ThemeMode? mode;
    for (final m in ThemeMode.values) {
      if (m.name == modeName) {
        mode = m;
        break;
      }
    }

    if (palette == null && mode == null) return;
    state = state.copyWith(palette: palette, mode: mode);
  }

  Future<void> setPalette(ThemePalette palette) async {
    state = state.copyWith(palette: palette);
    await _prefs?.setString(_paletteKey, palette.name);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _prefs?.setString(_modeKey, mode.name);
  }
}

final appThemeControllerProvider =
    NotifierProvider<AppThemeController, AppThemeSettings>(
        AppThemeController.new);
