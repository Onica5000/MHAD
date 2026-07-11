import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/database_encryption_service.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/notification_service.dart';
import 'package:mhad/services/onboarding_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/services/public_session_cache.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';
import 'package:mhad/utils/platform_utils.dart';
import 'package:mhad/utils/unsaved_guard.dart';

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

    try {
      await _bootstrap();
    } catch (error, stack) {
      // A required startup load failed (asset, storage, secure keystore).
      // Show an explanation + retry instead of stranding the user on a
      // blank frame.
      debugPrint('Startup failed: $error\n$stack');
      runApp(_BootErrorApp(error));
    }
  }, (error, stack) {
    debugPrint('Unhandled async error: $error\n$stack');
  });
}

/// Runs every pre-frame load and calls [runApp]. All loads below must
/// complete before the first frame so their read sites stay synchronous;
/// they are independent of each other, so they run in parallel.
Future<void> _bootstrap() async {
  // AppData: dynamic facts (contacts/resources, AI config, legal facts) from
  // assets/data/app_data.json into the AppData singleton.
  final appDataLoad = AppData.load();
  // Educational corpus (Learn page + AI assistant reference).
  final educationalLoad = EducationalContent.load();
  // Persisted disclaimer + onboarding state.
  final disclaimerLoad = DisclaimerNotifier.load();
  final onboardingLoad = OnboardingNotifier.load();
  // Database encryption key from secure storage (generates on first launch),
  // needed synchronously by appDatabaseProvider. Web never uses it — the web
  // database is always in-memory (createEncryptedDatabase ignores the key),
  // so skip the secure-storage round-trip there rather than let a browser
  // storage failure block boot for a key nothing reads.
  final dbKeyLoad = kIsWeb
      ? Future<String>.value('')
      : DatabaseEncryptionService.getOrCreateKey();
  // Cached AI prefs (per-provider keys / active provider / models) from
  // SharedPreferences, available synchronously on the first frame (avoids
  // async race on web reload).
  final cachedAiPrefsLoad = PublicSessionCache.getCachedPrefs();

  // Lock to portrait orientation on mobile (irrelevant on desktop/web)
  if (platformIsMobile) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  await Future.wait<void>(
      [appDataLoad, educationalLoad, disclaimerLoad, onboardingLoad]);
  final disclaimerNotifier = await disclaimerLoad;
  final onboardingNotifier = await onboardingLoad;
  final dbEncryptionKey = await dbKeyLoad;
  final cachedAiPrefs = await cachedAiPrefsLoad;

  // Privacy mode starts fresh every launch (not persisted)
  final privacyModeNotifier = PrivacyModeNotifier();

  // Wire the gate notifiers into the router before runApp
  initRouter(disclaimerNotifier, onboardingNotifier, privacyModeNotifier);

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
      // Pre-loaded AI prefs from SharedPreferences cache (avoids async race
      // on web page reload).
      if (cachedAiPrefs != null)
        preloadedAiPrefsProvider.overrideWith((_) => cachedAiPrefs),
    ],
    child: const MhadApp(),
  ));
}

/// Fallback UI when a required startup load throws — explains the failure
/// and offers a retry, instead of the blank frame the user got before.
/// Deliberately self-contained (no router/theme/l10n: those may be exactly
/// what failed to load).
class _BootErrorApp extends StatelessWidget {
  final Object error;
  const _BootErrorApp(this.error);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    "The app couldn't start",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Something needed at startup failed to load. '
                    'Your saved data has not been changed.\n\n$error',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: main,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MhadApp extends ConsumerWidget {
  const MhadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(appThemeControllerProvider);
    // Accessibility wiring: text size + dyslexia font + high contrast + bold
    // text flow into the theme; reduce-motion drives both no-transition routes
    // (in the theme) and MediaQuery.disableAnimations (for implicit animations).
    final a11y = ref.watch(accessibilitySettingsProvider);
    final locale = Locale(a11y.languageCode);
    // Web data-loss guard (2026-07-11 UX audit B12): arm the beforeunload
    // prompt whenever ANY directive exists in the in-memory DB — Sign,
    // Export, and Assistant used to be unguarded because only the wizard
    // armed it. `select` keeps this from rebuilding the app on every save.
    if (kIsWeb) {
      ref.listen(
        allDirectivesProvider.select((av) =>
            av.maybeWhen(data: (l) => l.isNotEmpty, orElse: () => false)),
        (_, hasData) => setUnsavedGuard(hasData),
      );
    }
    return MaterialApp.router(
      title: 'PA Mental Health Advance Directive',
      theme: buildMhadTheme(
        themeSettings.palette,
        Brightness.light,
        highContrast: a11y.highContrast,
        boldText: a11y.boldText,
        dyslexiaFont: a11y.dyslexiaFont,
        reduceMotion: a11y.reduceMotion,
      ),
      darkTheme: buildMhadTheme(
        themeSettings.palette,
        Brightness.dark,
        highContrast: a11y.highContrast,
        boldText: a11y.boldText,
        dyslexiaFont: a11y.dyslexiaFont,
        reduceMotion: a11y.reduceMotion,
      ),
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
            // Reduce motion: ask the framework to skip implicit animations too.
            disableAnimations: a11y.reduceMotion || mq.disableAnimations,
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
              // Crisis access on wide screens is the sidebar's crisis card; on
              // mobile it lives in the "More" sheet. (The floating
              // GlobalCrisisButton was removed 2026-06-22.)
              child: ResponsiveShell(
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}
