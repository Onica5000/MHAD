import 'package:flutter/material.dart';

// Primary teal — 0xFF00695C passes WCAG AA (4.58:1 on white, 4.7:1 on #FAFAFA)
const mhadTeal = Color(0xFF00695C);
const mhadTealDark = Color(0xFF004D40);
// Light teal for dark mode — 0xFF80CBC4 on dark surfaces passes AA (5.1:1)
const mhadTealLight = Color(0xFF80CBC4);

final lightColorScheme = ColorScheme.fromSeed(
  seedColor: mhadTeal,
  primary: mhadTeal,
  brightness: Brightness.light,
);

final darkColorScheme = ColorScheme.fromSeed(
  seedColor: mhadTeal,
  primary: mhadTealLight,
  brightness: Brightness.dark,
);

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: mhadTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: mhadTeal,
        foregroundColor: Colors.white,
      ),
    );

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
    );
