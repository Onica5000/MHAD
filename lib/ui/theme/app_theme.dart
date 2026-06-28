import 'package:flutter/material.dart';

/// App-wide font family constants.
const kSansFamily = 'DM Sans';
const kMonoFamily = 'JetBrains Mono';
// Dyslexia-friendly font, applied app-wide when the accessibility toggle is on.
const kDyslexiaFamily = 'Atkinson Hyperlegible';
const kMonoFallbacks = ['Consolas', 'Menlo', 'Courier New', 'monospace'];

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

  // ── Spacing scale (8-pt rhythm) ───────────────────────────────────────────
  // Additive: a single vertical/space scale so screens share one rhythm.
  static const space2 = 2.0;
  static const space4 = 4.0;
  static const space6 = 6.0;
  static const space8 = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space20 = 20.0;
  static const space24 = 24.0;
  static const space32 = 32.0;
  static const space40 = 40.0;
  static const space48 = 48.0;
  static const space64 = 64.0;

  /// Resting card depth — a soft two-layer shadow so cards read as objects, not
  /// just outlined rectangles. Subtle in light, lifted in dark.
  static List<BoxShadow> cardShadow(Brightness b) {
    final dark = b == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.26 : 0.05),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.20 : 0.04),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ];
  }

  /// Raised depth — for hover-lift on web and for hero/feature cards.
  static List<BoxShadow> raisedShadow(Brightness b) {
    final dark = b == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.34 : 0.08),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.24 : 0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }
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

  // Brightness-aware resolvers for single-color icon/text usages (replaces
  // hardcoded Colors.orange/green/red that ignored the active theme).
  static Color warningText(Brightness b) =>
      b == Brightness.dark ? warningTextDark : warningTextLight;
  static Color errorText(Brightness b) =>
      b == Brightness.dark ? errorTextDark : errorTextLight;
  static Color errorAccent(Brightness b) =>
      b == Brightness.dark ? errorAccentDark : errorAccentLight;
  static Color successText(Brightness b) =>
      b == Brightness.dark ? successTextDark : successTextLight;
  static Color warningBg(Brightness b) =>
      b == Brightness.dark ? warningBgDark : warningBgLight;
  static Color successBg(Brightness b) =>
      b == Brightness.dark ? successBgDark : successBgLight;
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

  /// Foreground color to use when drawing on top of [primary]. In light-mode
  /// palettes the primary is dark enough for white; in dark-mode palettes the
  /// primary becomes a light tint, so `onPrimary` flips to a deep color to
  /// preserve WCAG-AA contrast.
  final Color onPrimary;

  /// Foreground color for content on top of [primaryLight]. In light mode the
  /// primaryLight is very pale, so the deep primaryDark reads well; in dark
  /// mode primaryLight is itself dark-tinted and needs a light foreground.
  final Color onPrimaryLight;

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
    required this.onPrimary,
    required this.onPrimaryLight,
  });

  /// Soft brand wash for hero / landing backgrounds — a barely-there tint→
  /// surface diagonal. Calm enough to sit behind text without hurting contrast.
  LinearGradient get heroWash => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryTint, surface],
      );

  /// Tonal brand gradient for feature/hero CARDS and decorative motifs (the
  /// "bold" accent moments). Pairs the light tint with the mid tone.
  LinearGradient get brandGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryLight, primaryTint],
      );

  /// Saturated gradient for primary CTAs / emphasis chips (use sparingly).
  LinearGradient get ctaGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, primaryMid],
      );

  /// Floating-overlay decoration shared by the autocomplete dropdowns
  /// (diagnoses / allergies search). A bordered card with a soft drop shadow.
  BoxDecoration get dropdownDecoration => BoxDecoration(
        color: card,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      );

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
    textMuted: Color(0xFF4C6763),
    scaffoldBackground: Color(0xFFF6FAF8),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryLight: Color(0xFF0A2E2A),
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
    textMuted: Color(0xFFBCD0CB),
    scaffoldBackground: Color(0xFF0A1413),
    onPrimary: Color(0xFF04201C),
    onPrimaryLight: Color(0xFFE8F2EF),
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
    textMuted: Color(0xFF52607A),
    scaffoldBackground: Color(0xFFF7F9FC),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryLight: Color(0xFF101D3B),
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
    textMuted: Color(0xFFBDC6DD),
    scaffoldBackground: Color(0xFF0A0F1B),
    onPrimary: Color(0xFF0A0F1B),
    onPrimaryLight: Color(0xFFE5EAF5),
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
    textMuted: Color(0xFF4F6C59),
    scaffoldBackground: Color(0xFFF7FAF8),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryLight: Color(0xFF112618),
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
    textMuted: Color(0xFFBDD3C4),
    scaffoldBackground: Color(0xFF0A130C),
    onPrimary: Color(0xFF0A130C),
    onPrimaryLight: Color(0xFFE5F0E8),
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
        MhadPalette.navyLight;
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

/// Disables route transition animations (used when "reduce motion" is on).
class _NoPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoPageTransitionsBuilder();
  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context,
          Animation<double> animation, Animation<double> secondaryAnimation,
          Widget child) =>
      child;
}

/// Builds a Material 3 ThemeData from a [MhadPalette] and [Brightness].
///
/// Accessibility flags adjust the result app-wide:
/// - [highContrast] forces pure black/white text and stronger outlines;
/// - [boldText] raises body font weights;
/// - [dyslexiaFont] swaps the sans family to Atkinson Hyperlegible;
/// - [reduceMotion] removes route transition animations.
ThemeData buildMhadTheme(
  ThemePalette palette,
  Brightness brightness, {
  bool highContrast = false,
  bool boldText = false,
  bool dyslexiaFont = false,
  bool reduceMotion = false,
}) {
  final p = palette.forBrightness(brightness);
  final dark = brightness == Brightness.dark;
  final family = dyslexiaFont ? kDyslexiaFamily : kSansFamily;
  // High contrast: max-separation text + outlines over the palette's softer tones.
  final textColor = highContrast ? (dark ? Colors.white : Colors.black) : p.text;
  final mutedColor = highContrast
      ? (dark ? Colors.white70 : Colors.black87)
      : p.textMuted;
  final outlineColor =
      highContrast ? (dark ? Colors.white : Colors.black) : p.border;

  // Input fields read as "type here": a faint tinted fill distinct from the
  // card, plus a clearly visible resting border. Older-adult usability fix —
  // the default subtle 1.5px border on a card-colored fill was easy to miss.
  // See [[visual-accessibility-older-users]].
  final fieldFill = highContrast
      ? p.card
      : Color.alphaBlend(p.primary.withValues(alpha: 0.05), p.card);
  final fieldBorderColor = highContrast
      ? outlineColor
      : Color.alphaBlend(p.textMuted.withValues(alpha: 0.60), p.border);

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: p.primary,
    onPrimary: p.onPrimary,
    primaryContainer: p.primaryLight,
    onPrimaryContainer: p.onPrimaryLight,
    secondary: p.primaryMid,
    onSecondary: p.onPrimary,
    secondaryContainer: p.primaryTint,
    onSecondaryContainer: p.onPrimaryLight,
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
    onSurface: textColor,
    surfaceContainerHighest: p.primaryTint,
    onSurfaceVariant: mutedColor,
    outline: outlineColor,
    outlineVariant: outlineColor,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: brightness == Brightness.dark ? p.card : p.text,
    onInverseSurface: brightness == Brightness.dark ? p.text : Colors.white,
    inversePrimary: brightness == Brightness.dark
        ? palette.light.primary
        : palette.dark.primary,
  );

  final textTheme =
      _buildTextTheme(textColor, mutedColor, family: family, bold: boldText);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: p.scaffoldBackground,
    fontFamily: family, // falls back to platform sans-serif if unavailable
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    extensions: [_MhadPaletteExt(p)],
    pageTransitionsTheme: reduceMotion
        ? const PageTransitionsTheme(builders: {
            TargetPlatform.android: _NoPageTransitionsBuilder(),
            TargetPlatform.iOS: _NoPageTransitionsBuilder(),
            TargetPlatform.macOS: _NoPageTransitionsBuilder(),
            TargetPlatform.windows: _NoPageTransitionsBuilder(),
            TargetPlatform.linux: _NoPageTransitionsBuilder(),
          })
        : null,

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
      shadowColor: Colors.black.withValues(alpha: 0.04),
      surfaceTintColor: Colors.transparent,
    ),

    // Material 3 overlay alpha defaults are tuned for low-contrast surfaces;
    // on the navy primary they're nearly invisible. We over-ride hover /
    // focus / pressed overlays with explicit alpha values so desktop users
    // (Windows + Chrome/Edge web) get unambiguous visual feedback when
    // moving the cursor over a button or tabbing to it.
    //
    // FilledButton: overlay is the foreground color (onPrimary = white in
    // light navy), which lightens the primary background. Outlined and Text
    // buttons sit on a neutral surface, so we tint with primary itself.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        disabledBackgroundColor: p.border,
        disabledForegroundColor: p.textMuted,
        minimumSize: const Size.fromHeight(DesignTokens.buttonHeightMd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
        ),
        textStyle: const TextStyle(
          fontFamily: kSansFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return p.onPrimary.withValues(alpha: 0.16);
          }
          if (states.contains(WidgetState.focused)) {
            return p.onPrimary.withValues(alpha: 0.14);
          }
          if (states.contains(WidgetState.hovered)) {
            return p.onPrimary.withValues(alpha: 0.10);
          }
          return null;
        }),
        mouseCursor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return SystemMouseCursors.basic;
          }
          return SystemMouseCursors.click;
        }),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        minimumSize: const Size.fromHeight(DesignTokens.buttonHeightMd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return p.onPrimary.withValues(alpha: 0.16);
          }
          if (states.contains(WidgetState.focused)) {
            return p.onPrimary.withValues(alpha: 0.14);
          }
          if (states.contains(WidgetState.hovered)) {
            return p.onPrimary.withValues(alpha: 0.10);
          }
          return null;
        }),
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
          fontFamily: kSansFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return p.primary.withValues(alpha: 0.16);
          }
          if (states.contains(WidgetState.focused)) {
            return p.primary.withValues(alpha: 0.14);
          }
          if (states.contains(WidgetState.hovered)) {
            return p.primary.withValues(alpha: 0.08);
          }
          return null;
        }),
        mouseCursor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return SystemMouseCursors.basic;
          }
          return SystemMouseCursors.click;
        }),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.primary,
        textStyle: const TextStyle(
          fontFamily: kSansFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return p.primary.withValues(alpha: 0.16);
          }
          if (states.contains(WidgetState.focused)) {
            return p.primary.withValues(alpha: 0.14);
          }
          if (states.contains(WidgetState.hovered)) {
            return p.primary.withValues(alpha: 0.08);
          }
          return null;
        }),
        mouseCursor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return SystemMouseCursors.basic;
          }
          return SystemMouseCursors.click;
        }),
      ),
    ),

    // InputDecoration: labels are 13/600 DM Sans textMuted sitting ABOVE the
    // field (not Material's floating-label-when-focused) — so we pin
    // floatingLabelBehavior to `always`. Fields use a faint tinted fill +
    // visible resting border so it's unmistakable where to type (older-adult
    // usability fix), a 2px focus ring, and roomier 16px vertical padding.
    // This applies project-wide without touching individual TextFormFields.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: fieldFill,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide(color: fieldBorderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide(color: p.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      labelStyle: TextStyle(
        fontFamily: kSansFamily,
        color: p.textMuted,
        fontSize: 15,
      ),
      floatingLabelStyle: TextStyle(
        fontFamily: kSansFamily,
        color: p.textMuted,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      hintStyle: TextStyle(
        fontFamily: kSansFamily,
        color: p.textMuted,
        fontSize: 15,
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: p.primaryLight,
      side: BorderSide.none,
      labelStyle: TextStyle(
        fontFamily: kSansFamily,
        color: p.onPrimaryLight,
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
        fontFamily: kSansFamily,
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
      foregroundColor: p.onPrimary,
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

TextTheme _buildTextTheme(Color text, Color muted,
    {String family = kSansFamily, bool bold = false}) {
  final t = TextTheme(
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
        fontFamily: family, fontSize: 14, fontWeight: FontWeight.w400, color: muted, height: 1.45),
    labelLarge: TextStyle(
        fontFamily: family, fontSize: 14, fontWeight: FontWeight.w600, color: text),
    labelMedium: TextStyle(
        fontFamily: family, fontSize: 12, fontWeight: FontWeight.w600, color: text),
    labelSmall: TextStyle(
        fontFamily: family, fontSize: 13, fontWeight: FontWeight.w700, color: muted, letterSpacing: 1.0),
  );
  // Bold-text accessibility: shift every weight up two steps (w400 → w600).
  // TextStyle.apply supports fontWeightDelta; TextTheme.apply does not, so map.
  if (!bold) return t;
  TextStyle? b(TextStyle? s) => s?.apply(fontWeightDelta: 2);
  return TextTheme(
    displayLarge: b(t.displayLarge),
    displayMedium: b(t.displayMedium),
    displaySmall: b(t.displaySmall),
    headlineLarge: b(t.headlineLarge),
    headlineMedium: b(t.headlineMedium),
    headlineSmall: b(t.headlineSmall),
    titleLarge: b(t.titleLarge),
    titleMedium: b(t.titleMedium),
    titleSmall: b(t.titleSmall),
    bodyLarge: b(t.bodyLarge),
    bodyMedium: b(t.bodyMedium),
    bodySmall: b(t.bodySmall),
    labelLarge: b(t.labelLarge),
    labelMedium: b(t.labelMedium),
    labelSmall: b(t.labelSmall),
  );
}
