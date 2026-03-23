import 'package:flutter/material.dart';

const mhadTeal = Color(0xFF00827F);
const mhadTealDark = Color(0xFF005F5C);
const mhadTealLight = Color(0xFF80CBC4); // lighter teal for WCAG AA contrast on dark

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
