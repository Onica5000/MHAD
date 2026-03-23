import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/services/privacy_mode_service.dart';

/// Holds the single [PrivacyModeNotifier] instance created in [main()].
/// Overridden via [ProviderScope] before [runApp()] so the same notifier
/// instance used by the router is also visible to Riverpod providers.
final privacyModeNotifierProvider =
    ChangeNotifierProvider<PrivacyModeNotifier>(
  (_) => PrivacyModeNotifier(), // default — overridden in main()
);

/// Holds the database encryption key resolved at startup.
///
/// Overridden in [main()] with the key from [DatabaseEncryptionService].
/// This provider is read (not watched) by [appDatabaseProvider] to build
/// the encrypted connection for private mode.
final dbEncryptionKeyProvider = Provider<String>(
  (_) => throw UnimplementedError(
    'dbEncryptionKeyProvider must be overridden in ProviderScope',
  ),
);

/// Returns the correct database for the current session mode:
///   - Public  -> in-memory (data is lost on app close, no private data exposed)
///   - Private -> encrypted file-based (SQLCipher, key from secure storage)
///
/// Automatically invalidated when the privacy mode changes, so widgets
/// watching this provider get a fresh database for the new mode.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final modeNotifier = ref.watch(privacyModeNotifierProvider);

  final AppDatabase db;
  if (modeNotifier.isPrivate) {
    // Private mode: encrypted file-based database via SQLCipher.
    // The encryption key was resolved at startup and injected via override.
    final encryptionKey = ref.read(dbEncryptionKeyProvider);
    db = createEncryptedDatabase(encryptionKey);
  } else {
    // Public mode (or mode not yet selected): ephemeral, in-memory SQLite.
    db = createMemoryDatabase();
  }
  ref.onDispose(db.close);
  return db;
});

final directiveRepositoryProvider = Provider<DirectiveRepository>(
  (ref) => DirectiveRepository(ref.watch(appDatabaseProvider)),
);

final allDirectivesProvider = StreamProvider<List<Directive>>(
  (ref) => ref.watch(directiveRepositoryProvider).watchAllDirectives(),
);

final directiveByIdProvider =
    FutureProvider.family<Directive?, int>((ref, id) =>
        ref.watch(directiveRepositoryProvider).getDirectiveById(id));
