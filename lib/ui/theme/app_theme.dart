import 'package:flutter/material.dart';

/// Design tokens — single source of truth for radii, spacing, shadows used
/// throughout the MHAD redesign. Keep in sync with the prototype.
class DesignTokens {
  static const cardRadius = 16.0;
  static const buttonRadius = 14.0;
  static const inputRadius = 12.0;
  static const chipRadius = 100.0;
  static const sheetRadius = 20.0;
  static const iconTileRadius = 12.0;

  static const buttonHeightMd = 52.0;
  static const buttonHeightSm = 40.0;
  static const buttonHeightLg = 56.0;

  static const cardElevation = 1.0;
  static const sectionLabelLetterSpacing = 1.2;

  static List<BoxShadow> cardShadow(Brightness b) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: b == Brightness.dark ? 0.3 : 0.06),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ];
}

/// Status/semantic colors shared across palettes (light & dark variants tuned
/// to pass WCAG AA against their backgrounds).
class SemanticColors {
  // Warning
  static const warningBgLight = Color(0xFFFFF8E1);
  static const warningBorderLight = Color(0xFFFFE082);
  static const warningTextLight = Color(0xFFB45309);
  static const warningBgDark = Color(0xFF3A2F0C);
  static const warningBorderDark = Color(0xFF8B6B1A);
  static const warningTextDark = Color(0xFFFBC67A);

  // Error / crisis
  static const errorBgLight = Color(0xFFFDF2F2);
  static const errorBorderLight = Color(0xFFF5C6C6);
  static const errorTextLight = Color(0xFF922B21);
  static const errorAccentLight = Color(0xFFC0392B);
  static const errorBgDark = Color(0xFF3A1B17);
  static const errorBorderDark = Color(0xFF8B3A32);
  static const errorTextDark = Color(0xFFF5B5AF);
  static const errorAccentDark = Color(0xFFE06B5D);

  // Success
  static const successBgLight = Color(0xFFF0FBF4);
  static const successBorderLight = Color(0xFFBBF7D0);
  static const successTextLight = Color(0xFF15803D);
  static const successBgDark = Color(0xFF0F2A19);
  static const successBorderDark = Color(0xFF2F6B46);
  static const successTextDark = Color(0xFF7CD9A1);

  // Purple (POA accent)
  static const purpleText = Color(0xFF6D28D9);
  static const purpleBg = Color(0xFFF5F3FF);
}

/// A full palette = primary family + supporting surface/text tokens for a
/// single brightness. Each palette in [ThemePalette] resolves to a pair
/// (light + dark).
class MhadPalette {
  final Color primary;
  final Color primaryMid;
  final Color primaryDark;
  final Color primaryLight;
  final Color primaryTint;

  final Color surface;
  final Color card;
  final Color border;
  final Color text;
  final Color textMuted;

  final Color scaffoldBackground;

  const MhadPalette({
    required this.primary,
    required this.primaryMid,
    required this.primaryDark,
    required this.primaryLight,
    required this.primaryTint,
    required this.surface,
    required this.card,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.scaffoldBackground,
  });

  // ─── Warm Teal ─────────────────────────────────────────────────────────
  static const tealLight = MhadPalette(
    primary: Color(0xFF1A7A6E),
    primaryMid: Color(0xFF20A090),
    primaryDark: Color(0xFF125A52),
    primaryLight: Color(0xFFE6F4F2),
    primaryTint: Color(0xFFF0F9F7),
    surface: Color(0xFFF6FAF8),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE2EDEA),
    text: Color(0xFF1A2E2B),
    textMuted: Color(0xFF6B8884),
    scaffoldBackground: Color(0xFFF6FAF8),
  );

  static const tealDark = MhadPalette(
    primary: Color(0xFF4ABFB1),
    primaryMid: Color(0xFF20A090),
    primaryDark: Color(0xFF125A52),
    primaryLight: Color(0xFF1B3330),
    primaryTint: Color(0xFF142524),
    surface: Color(0xFF0F1A18),
    card: Color(0xFF172622),
    border: Color(0xFF26342F),
    text: Color(0xFFE8F2EF),
    textMuted: Color(0xFF9AB5B0),
    scaffoldBackground: Color(0xFF0A1413),
  );

  // ─── Deep Navy ─────────────────────────────────────────────────────────
  static const navyLight = MhadPalette(
    primary: Color(0xFF1E3A8A),
    primaryMid: Color(0xFF3B5BD9),
    primaryDark: Color(0xFF152A66),
    primaryLight: Color(0xFFE6EBF7),
    primaryTint: Color(0xFFF0F3FB),
    surface: Color(0xFFF7F9FC),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE0E5F0),
    text: Color(0xFF111A2E),
    textMuted: Color(0xFF6B7688),
    scaffoldBackground: Color(0xFFF7F9FC),
  );

  static const navyDark = MhadPalette(
    primary: Color(0xFF8B9EE3),
    primaryMid: Color(0xFF6B82D9),
    primaryDark: Color(0xFF152A66),
    primaryLight: Color(0xFF1C2442),
    primaryTint: Color(0xFF151C33),
    surface: Color(0xFF0D1220),
    card: Color(0xFF151B2E),
    border: Color(0xFF232B3E),
    text: Color(0xFFE5EAF5),
    textMuted: Color(0xFF9AA4BB),
    scaffoldBackground: Color(0xFF0A0F1B),
  );

  // ─── Sage Green ────────────────────────────────────────────────────────
  static const sageLight = MhadPalette(
    primary: Color(0xFF4A7A5C),
    primaryMid: Color(0xFF6BA07F),
    primaryDark: Color(0xFF2F5A40),
    primaryLight: Color(0xFFEAF3ED),
    primaryTint: Color(0xFFF1F8F3),
    surface: Color(0xFFF7FAF8),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFDDE8E0),
    text: Color(0xFF1E2E23),
    textMuted: Color(0xFF6B8875),
    scaffoldBackground: Color(0xFFF7FAF8),
  );

  static const sageDark = MhadPalette(
    primary: Color(0xFF9BC5A9),
    primaryMid: Color(0xFF7AB38B),
    primaryDark: Color(0xFF2F5A40),
    primaryLight: Color(0xFF1E2F24),
    primaryTint: Color(0xFF17231B),
    surface: Color(0xFF0F1811),
    card: Color(0xFF172218),
    border: Color(0xFF243025),
    text: Color(0xFFE5F0E8),
    textMuted: Color(0xFF9AB3A2),
    scaffoldBackground: Color(0xFF0A130C),
  );
}

/// Selectable color palettes exposed to users via Settings.
enum ThemePalette {
  teal(
    label: 'Warm Teal',
    description: 'Balanced, calm, professional.',
    light: MhadPalette.tealLight,
    dark: MhadPalette.tealDark,
  ),
  navy(
    label: 'Deep Navy',
    description: 'Formal, steady, high-contrast.',
    light: MhadPalette.navyLight,
    dark: MhadPalette.navyDark,
  ),
  sage(
    label: 'Sage Green',
    description: 'Soft, natural, approachable.',
    light: MhadPalette.sageLight,
    dark: MhadPalette.sageDark,
  );

  final String label;
  final String description;
  final MhadPalette light;
  final MhadPalette dark;
  const ThemePalette({
    required this.label,
    required this.description,
    required this.light,
    required this.dark,
  });

  MhadPalette forBrightness(Brightness b) =>
      b == Brightness.dark ? dark : light;
}

/// Extension holding our palette tokens on [ThemeData] so any widget can do
/// `Theme.of(context).mhadPalette` to pull the exact colors used in the
/// prototype without re-deriving them.
extension MhadThemeX on ThemeData {
  MhadPalette get mhadPalette {
    // We stash the palette in [extensions] so it's available from any
    // `Theme.of(context)` call.
    return extension<_MhadPaletteExt>()?.palette ??
        MhadPalette.tealLight;
  }
}

class _MhadPaletteExt extends ThemeExtension<_MhadPaletteExt> {
  final MhadPalette palette;
  const _MhadPaletteExt(this.palette);

  @override
  ThemeExtension<_MhadPaletteExt> copyWith({MhadPalette? palette}) =>
      _MhadPaletteExt(palette ?? this.palette);

  @override
  ThemeExtension<_MhadPaletteExt> lerp(
      covariant ThemeExtension<_MhadPaletteExt>? other, double t) {
    if (other is! _MhadPaletteExt) return this;
    // Lerp isn't really meaningful for a packed palette; snap halfway.
    return t < 0.5 ? this : other;
  }
}

/// Builds a Material 3 ThemeData from a [MhadPalette] and [Brightness].
ThemeData buildMhadTheme(ThemePalette palette, Brightness brightness) {
  final p = palette.forBrightness(brightness);

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: p.primary,
    onPrimary: brightness == Brightness.dark ? p.text : Colors.white,
    primaryContainer: p.primaryLight,
    onPrimaryContainer: p.primaryDark,
    secondary: p.primaryMid,
    onSecondary: Colors.white,
    secondaryContainer: p.primaryTint,
    onSecondaryContainer: p.primaryDark,
    tertiary: SemanticColors.warningTextLight,
    onTertiary: Colors.white,
    tertiaryContainer: brightness == Brightness.dark
        ? SemanticColors.warningBgDark
        : SemanticColors.warningBgLight,
    onTertiaryContainer: brightness == Brightness.dark
        ? SemanticColors.warningTextDark
        : SemanticColors.warningTextLight,
    error: brightness == Brightness.dark
        ? SemanticColors.errorAccentDark
        : SemanticColors.errorAccentLight,
    onError: Colors.white,
    errorContainer: brightness == Brightness.dark
        ? SemanticColors.errorBgDark
        : SemanticColors.errorBgLight,
    onErrorContainer: brightness == Brightness.dark
        ? SemanticColors.errorTextDark
        : SemanticColors.errorTextLight,
    surface: p.card,
    onSurface: p.text,
    surfaceContainerHighest: p.primaryTint,
    onSurfaceVariant: p.textMuted,
    outline: p.border,
    outlineVariant: p.border,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: brightness == Brightness.dark ? p.card : p.text,
    onInverseSurface: brightness == Brightness.dark ? p.text : Colors.white,
    inversePrimary: brightness == Brightness.dark
        ? palette.light.primary
        : palette.dark.primary,
  );

  final textTheme = _buildTextTheme(p.text, p.textMuted);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: p.scaffoldBackground,
    fontFamily: 'DM Sans', // falls back to platform sans-serif if unavailable
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    extensions: [_MhadPaletteExt(p)],

    appBarTheme: AppBarTheme(
      backgroundColor: p.card,
      foregroundColor: p.text,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: p.text,
        fontSize: 17,
      ),
      iconTheme: IconThemeData(color: p.primary),
      actionsIconTheme: IconThemeData(color: p.primary),
    ),

    cardTheme: CardThemeData(
      color: p.card,
      elevation: DesignTokens.cardElevation,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        side: BorderSide(color: p.border, width: 1),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.06),
      surfaceTintColor: Colors.transparent,
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: p.border,
        disabledForegroundColor: p.textMuted,
        minimumSize: const Size.fromHeight(DesignTokens.buttonHeightMd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
        ),
        textStyle: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(DesignTokens.buttonHeightMd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.primary,
        minimumSize: const Size.fromHeight(DesignTokens.buttonHeightMd),
        side: BorderSide(color: p.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
        ),
        textStyle: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.primary,
        textStyle: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide(color: p.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide(color: p.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide(color: p.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: TextStyle(
        fontFamily: 'DM Sans',
        color: p.textMuted,
        fontSize: 14,
      ),
      hintStyle: TextStyle(
        fontFamily: 'DM Sans',
        color: p.textMuted,
        fontSize: 14,
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: p.primaryLight,
      side: BorderSide.none,
      labelStyle: TextStyle(
        fontFamily: 'DM Sans',
        color: p.primary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      shape: const StadiumBorder(),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: p.primary,
      linearTrackColor: p.border,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? p.primary : p.border),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),

    dividerTheme: DividerThemeData(
      color: p.border,
      thickness: 1,
      space: 1,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.text,
      contentTextStyle: TextStyle(
        fontFamily: 'DM Sans',
        color: brightness == Brightness.dark ? p.card : Colors.white,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.primary,
      foregroundColor: Colors.white,
    ),

    listTileTheme: ListTileThemeData(
      iconColor: p.primary,
      textColor: p.text,
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.sheetRadius)),
      ),
    ),
  );
}

TextTheme _buildTextTheme(Color text, Color muted) {
  const family = 'DM Sans';
  return TextTheme(
    displayLarge: TextStyle(
        fontFamily: family, fontSize: 40, fontWeight: FontWeight.w700, color: text, letterSpacing: -0.5),
    displayMedium: TextStyle(
        fontFamily: family, fontSize: 32, fontWeight: FontWeight.w700, color: text, letterSpacing: -0.3),
    displaySmall: TextStyle(
        fontFamily: family, fontSize: 26, fontWeight: FontWeight.w700, color: text, letterSpacing: -0.3),
    headlineLarge: TextStyle(
        fontFamily: family, fontSize: 24, fontWeight: FontWeight.w700, color: text, letterSpacing: -0.3),
    headlineMedium: TextStyle(
        fontFamily: family, fontSize: 22, fontWeight: FontWeight.w700, color: text, letterSpacing: -0.3),
    headlineSmall: TextStyle(
        fontFamily: family, fontSize: 20, fontWeight: FontWeight.w700, color: text, letterSpacing: -0.2),
    titleLarge: TextStyle(
        fontFamily: family, fontSize: 18, fontWeight: FontWeight.w700, color: text),
    titleMedium: TextStyle(
        fontFamily: family, fontSize: 16, fontWeight: FontWeight.w600, color: text),
    titleSmall: TextStyle(
        fontFamily: family, fontSize: 14, fontWeight: FontWeight.w600, color: text),
    bodyLarge: TextStyle(
        fontFamily: family, fontSize: 16, fontWeight: FontWeight.w400, color: text, height: 1.5),
    bodyMedium: TextStyle(
        fontFamily: family, fontSize: 14, fontWeight: FontWeight.w400, color: text, height: 1.5),
    bodySmall: TextStyle(
        fontFamily: family, fontSize: 12, fontWeight: FontWeight.w400, color: muted, height: 1.45),
    labelLarge: TextStyle(
        fontFamily: family, fontSize: 14, fontWeight: FontWeight.w600, color: text),
    labelMedium: TextStyle(
        fontFamily: family, fontSize: 12, fontWeight: FontWeight.w600, color: text),
    labelSmall: TextStyle(
        fontFamily: family, fontSize: 11, fontWeight: FontWeight.w700, color: muted, letterSpacing: 1.0),
  );
}

// ─── Legacy aliases (kept to avoid breakage) ────────────────────────────────
// Existing code imports these constants directly. They now map to the active
// Warm Teal palette so existing screens render in the new style until they are
// refactored to use `Theme.of(context).mhadPalette`.
const mhadTeal = Color(0xFF1A7A6E);
const mhadTealDark = Color(0xFF125A52);
const mhadTealLight = Color(0xFF4ABFB1);

/// Legacy helpers — still used by some older screens. They now build themes
/// against the default Warm Teal palette.
ThemeData get lightTheme => buildMhadTheme(ThemePalette.teal, Brightness.light);
ThemeData get darkTheme => buildMhadTheme(ThemePalette.teal, Brightness.dark);
