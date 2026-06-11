import 'package:flutter/foundation.dart';

/// Safe platform checks that work on all platforms including web.
///
/// Unlike `dart:io`'s `Platform.isXxx`, these do not crash on web.
/// Always check [kIsWeb] first since `defaultTargetPlatform` can return
/// any value on web (it follows the user-agent, not the actual runtime).

bool get platformIsAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

bool get platformIsIOS =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

bool get platformIsMobile => platformIsAndroid || platformIsIOS;

/// Whether the device has a camera (mobile native or mobile web browser).
/// On web, detects mobile browsers via user-agent so camera/gallery are
/// offered on phones but not desktop browsers.
bool get deviceHasCamera =>
    platformIsMobile ||
    (kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
         defaultTargetPlatform == TargetPlatform.iOS));

bool get platformIsWindows =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

bool get platformIsMacOS =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

bool get platformIsLinux =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

bool get platformIsDesktop =>
    platformIsWindows || platformIsMacOS || platformIsLinux;

/// True on Apple platforms (macOS / iOS), INCLUDING Apple browsers on web
/// (here we intentionally do not gate on [kIsWeb] — `defaultTargetPlatform`
/// follows the user-agent on web, which is what we want for picking the
/// correct modifier-key nomenclature). Use for "⌘ vs Ctrl" UI copy only.
bool get isApplePlatform =>
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// The clipboard-paste shortcut label for the current OS — "⌘V" on Apple,
/// "Ctrl+V" on Windows / Linux. Matches the keys the user actually presses
/// (on web this follows the browser's reported platform).
String get pasteShortcutLabel => isApplePlatform ? '⌘V' : 'Ctrl+V';
