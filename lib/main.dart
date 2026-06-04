import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/accessibility_providers.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/database_encryption_service.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/notification_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/services/public_session_cache.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/theme/theme_controller.dart';
import 'package:mhad/ui/widgets/crisis_resources_banner.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';
import 'package:mhad/utils/platform_utils.dart';

void main() {
  // Global error handler for Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter error: ${details.exception}');
  };

  // Catch async errors not handled by Flutter.
  // ensureInitialized and runApp must be called in the SAME zone to avoid
  // the "Zone mismatch" fatal error.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Lock to portrait orientation on mobile (irrelevant on desktop/web)
    if (platformIsMobile) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    // Load persisted disclaimer state
    final disclaimerNotifier = await DisclaimerNotifier.load();

    // Resolve database encryption key from secure storage (generates on first
    // launch). This must complete before runApp so the key is available
    // synchronously to the appDatabaseProvider.
    final dbEncryptionKey =
        await DatabaseEncryptionService.getOrCreateKey();

    // Pre-load cached API key from SharedPreferences so it's available
    // synchronously on the first frame (avoids async race on web reload).
    final cachedApiKey = await PublicSessionCache.getCachedApiKey();

    // Privacy mode starts fresh every launch (not persisted)
    final privacyModeNotifier = PrivacyModeNotifier();

    // Wire both notifiers into the router before runApp
    initRouter(disclaimerNotifier, privacyModeNotifier);

    // Non-fatal background init
    await NotificationService.instance.initialize();

    runApp(ProviderScope(
      overrides: [
        // Expose the same PrivacyModeNotifier instance to Riverpod so that
        // appDatabaseProvider can watch its mode changes.
        privacyModeNotifierProvider.overrideWith((_) => privacyModeNotifier),
        // Inject the database encryption key so appDatabaseProvider can use it
        // to open the SQLCipher-encrypted database in private mode.
        dbEncryptionKeyProvider.overrideWithValue(dbEncryptionKey),
        // Pre-loaded API key from SharedPreferences cache (avoids async race
        // on web page reload).
        preloadedApiKeyProvider.overrideWith((_) => cachedApiKey),
      ],
      child: const MhadApp(),
    ));
  }, (error, stack) {
    debugPrint('Unhandled async error: $error\n$stack');
  });
}

class MhadApp extends ConsumerWidget {
  const MhadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(appThemeControllerProvider);
    // Phase 4 — Accessibility wiring. The provider previously existed but
    // nothing consumed it at the MaterialApp level, so adjusting "Text size"
    // in Accessibility settings had no visible effect. The textScaler below
    // is the minimum wiring; the dyslexia font / high-contrast / reduce-motion
    // toggles still need theme-level plumbing but at least no longer silently
    // discard input.
    final a11y = ref.watch(accessibilitySettingsProvider);
    final locale = Locale(a11y.languageCode);
    return MaterialApp.router(
      title: 'PA Mental Health Advance Directive',
      theme: buildMhadTheme(themeSettings.palette, Brightness.light),
      darkTheme: buildMhadTheme(themeSettings.palette, Brightness.dark),
      themeMode: themeSettings.mode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Honor the user's chosen language from accessibility settings — but
      // fall back to system locale if the chosen one isn't in the supported
      // list (avoids breaking on legacy codes).
      locale: AppLocalizations.supportedLocales
              .any((l) => l.languageCode == locale.languageCode)
          ? locale
          : null,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          // Apply the accessibility text-scale on top of the platform's own
          // accessibility scale (so platform AX settings still compose).
          data: mq.copyWith(
            textScaler: TextScaler.linear(a11y.textScaleFactor),
          ),
          // Desktop keyboard shortcuts (Windows + Chrome/Edge web). Mobile
          // ignores these — Android's back gesture / system back button
          // already covers the same intents. The map deliberately keeps a
          // small surface (Esc only for now) so we don't interfere with
          // existing PopScope handlers, TextField focus traversal, or
          // browser-native shortcuts like Ctrl+R.
          child: Shortcuts(
            shortcuts: const <ShortcutActivator, Intent>{
              SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
            },
            child: Actions(
              actions: <Type, Action<Intent>>{
                // Esc → pop topmost popup route (dialogs, bottom sheets,
                // modal sheets). Routes that don't want this can override
                // with their own DismissAction higher in the focus tree.
                // The maybePop branch keeps us a no-op on the home route
                // so Esc never accidentally exits the app on web.
                DismissIntent: CallbackAction<DismissIntent>(
                  onInvoke: (_) {
                    final nav = Navigator.maybeOf(context, rootNavigator: true);
                    if (nav != null && nav.canPop()) {
                      nav.maybePop();
                    }
                    return null;
                  },
                ),
              },
              child: Column(
                children: [
                  Expanded(
                    // Remove the bottom safe-area padding from the content
                    // area because the CrisisResourcesBanner below already
                    // handles it. Without this, every Scaffold/SafeArea
                    // inside the Expanded adds redundant bottom padding,
                    // stealing vertical space.
                    child: MediaQuery.removePadding(
                      context: context,
                      removeBottom: true,
                      child: ResponsiveShell(
                        child: child ?? const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  const CrisisResourcesBanner(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
