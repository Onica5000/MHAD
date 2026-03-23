import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/data_export_service.dart';
import 'package:mhad/services/device_security_service.dart';
import 'package:mhad/services/screenshot_protection_service.dart';
import 'package:mhad/services/notification_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/home/directive_card.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/onboarding/onboarding_screen.dart';
import 'package:mhad/ui/widgets/draft_recovery_dialog.dart';
import 'package:mhad/ui/widgets/provider_resources.dart';
import 'package:mhad/utils/platform_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static bool _checkedDraftRecovery = false;

  @override
  void initState() {
    super.initState();
    if (!_checkedDraftRecovery) {
      _checkedDraftRecovery = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        // Show onboarding on first launch
        final onboarded = await OnboardingScreen.isCompleted();
        if (!onboarded && mounted) {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => OnboardingScreen(
              onComplete: () => Navigator.of(context).pop(),
            ),
          ));
        }
        if (mounted) checkAndOfferDraftRecovery(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final directivesAsync = ref.watch(allDirectivesProvider);

    final privacyMode = ref.watch(privacyModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PA Mental Health\nAdvance Directive',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          // Mode badge + optional downgrade action
          if (privacyMode.isPrivate)
            PopupMenuButton<String>(
              tooltip: 'Session: Private',
              icon: const Icon(Icons.lock_outline),
              onSelected: (value) {
                if (value == 'switch_public') {
                  _confirmSwitchToPublic(context, privacyMode);
                } else if (value == 'export_data') {
                  _exportData(context, ref);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  enabled: false,
                  child: Text('Private session',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'export_data',
                  child: Row(children: [
                    Icon(Icons.download_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Export All Data'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'switch_public',
                  child: Row(children: [
                    Icon(Icons.visibility_off_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Switch to Public Mode'),
                  ]),
                ),
              ],
            )
          else if (privacyMode.isPublic)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Tooltip(
                message: 'Public session — data is not saved',
                child: Icon(Icons.visibility_off_outlined,
                    size: 20),
              ),
            ),
          PopupMenuButton<String>(
            tooltip: 'More options',
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'delete_all') {
                _deleteAllData(context, ref);
              } else if (value == 'screenshot_toggle') {
                await ScreenshotProtectionService.toggle();
              }
            },
            itemBuilder: (_) => [
              if (platformIsAndroid)
                PopupMenuItem(
                  value: 'screenshot_toggle',
                  child: Row(children: [
                    Icon(
                      ScreenshotProtectionService.isEnabled
                          ? Icons.screen_lock_portrait
                          : Icons.screenshot_outlined,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(ScreenshotProtectionService.isEnabled
                        ? 'Allow Screenshots'
                        : 'Block Screenshots'),
                  ]),
                ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(children: [
                  Icon(Icons.delete_forever, size: 18),
                  SizedBox(width: 8),
                  Text('Delete All Data'),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _DeviceSecurityCheck(),
          _DisclaimerBanner(),
          const SizedBox(height: 16),
          _LearnMoreCard(),
          const SizedBox(height: 16),
          const ProviderResourcesCard(),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.privacy_tip_outlined, size: 16),
              label: const Text('Privacy Policy',
                  style: TextStyle(fontSize: 12)),
              onPressed: () => context.push(AppRoutes.privacyPolicy),
            ),
          ),
          const SizedBox(height: 8),
          if (privacyMode.isPublic) ...[
            _PublicModeNotice(
              onEndSession: () => _confirmEndSession(context, ref),
            ),
            const SizedBox(height: 16),
            // Public mode still shows directives created this session
            Text(
              'Session Directives',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            directivesAsync.when(
              data: (directives) {
                if (directives.isEmpty) return const _EmptyDirectives();
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: directives.length,
                  itemBuilder: (context, index) {
                    final d = directives[index];
                    return DirectiveCard(
                      key: ValueKey(d.id),
                      directive: d,
                      onDelete: () => _confirmDelete(context, ref, d.id),
                      onRevoke: () => _confirmRevoke(context, ref, d.id),
                      onRenew: () => _renewDirective(context, ref, d),
                    );
                  },
                );
              },
              loading: () => Center(
                    child: Semantics(
                      label: 'Loading',
                      child: const CircularProgressIndicator(),
                    ),
                  ),
              error: (e, _) {
                debugPrint('Error loading directives: $e');
                return const _EmptyDirectives();
              },
            ),
          ] else ...[
            Text(
              'My Directives',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            directivesAsync.when(
              data: (directives) {
                if (directives.isEmpty) return const _EmptyDirectives();
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: directives.length,
                  itemBuilder: (context, index) {
                    final d = directives[index];
                    return DirectiveCard(
                      key: ValueKey(d.id),
                      directive: d,
                      onDelete: () => _confirmDelete(context, ref, d.id),
                      onRevoke: () => _confirmRevoke(context, ref, d.id),
                      onRenew: () => _renewDirective(context, ref, d),
                    );
                  },
                );
              },
              loading: () => Center(
                    child: Semantics(
                      label: 'Loading',
                      child: const CircularProgressIndicator(),
                    ),
                  ),
              error: (e, _) {
                debugPrint('Error loading directives: $e');
                return const _EmptyDirectives();
              },
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.push(AppRoutes.formTypeSelection),
              icon: const Icon(Icons.add),
              label: const Text('New Directive'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _confirmEndSession(
      BuildContext context, WidgetRef ref) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 40),
        title: const Text('End Public Session?'),
        content: const Text(
          'This will immediately and permanently erase:\n\n'
          '  \u2022  All directives created this session\n'
          '  \u2022  Your API key\n'
          '  \u2022  AI conversation history\n'
          '  \u2022  All cached session data\n\n'
          'Make sure you have exported or printed any '
          'documents you need before continuing.\n\n'
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('End Session & Erase'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    // Wipe everything
    await endPublicSession(ref);
    // Delete all in-memory directives
    try {
      await ref.read(directiveRepositoryProvider).deleteAllDirectives();
    } catch (_) {}

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session ended. All data has been erased.'),
        ),
      );
    }
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final db = ref.read(appDatabaseProvider);
      final service = DataExportService(db);
      await service.exportAll();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _confirmSwitchToPublic(
      BuildContext context, PrivacyModeNotifier notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Switch to Public Mode?'),
        content: const Text(
          'Your saved directives will no longer be accessible in this session. '
          'No data will be deleted — you can access your directives again in a '
          'future Private session.\n\nYou cannot return to Private Mode without '
          'restarting the app.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Switch to Public')),
        ],
      ),
    );
    if (confirmed == true) {
      notifier.downgradeToPublic();
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete directive?'),
        content: const Text(
            'This cannot be undone. All data for this directive will be permanently deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).colorScheme.error),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(directiveRepositoryProvider).deleteDirective(id);
      // Cancel any scheduled expiration reminders for this directive
      await NotificationService.instance.cancelReminders(id);
    }
  }

  Future<void> _confirmRevoke(
      BuildContext context, WidgetRef ref, int id) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Revoke Directive?'),
        content: const Text(
          'Revoking means this directive is no longer in effect. '
          'Under PA Act 194, you may revoke your directive at any time '
          'while capable of making mental health decisions.\n\n'
          'You should notify your agent and healthcare providers of this '
          'revocation.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(directiveRepositoryProvider)
          .updateStatus(id, DirectiveStatus.revoked);
    }
  }

  Future<void> _renewDirective(
      BuildContext context, WidgetRef ref, Directive old) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Renew Directive?'),
        content: const Text(
          'This will create a new directive with the same treatment '
          'preferences and agent designations. Personal information, '
          'witnesses, and signatures will need to be re-entered.\n\n'
          'The original directive will remain unchanged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Renew'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final formType = FormType.values.firstWhere(
      (e) => e.name == old.formType,
      orElse: () => FormType.combined,
    );
    final repo = ref.read(directiveRepositoryProvider);
    final newId = await repo.createDirective(formType);

    // Copy non-PII data from old directive
    await repo.updateEffectiveCondition(newId, old.effectiveCondition);

    if (context.mounted) {
      context.push(AppRoutes.wizardRoute(newId));
    }
  }

  Future<void> _deleteAllData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This will permanently delete all your directives, preferences, '
          'and local data. Data previously sent to Google\'s AI cannot be '
          'recalled. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.error),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(directiveRepositoryProvider).deleteAllDirectives();
      const storage = FlutterSecureStorage();
      await storage.deleteAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data deleted successfully.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete data: $e')),
        );
      }
    }
  }
}

class _DisclaimerBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Disclaimer: This app helps you document your mental health '
          'preferences. It is not legal advice. Directives are valid for '
          '2 years under PA Act 194 of 2004.',
      container: true,
      child: Card(
        color: cs.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'This app helps you document your mental health preferences. '
            'It is not legal advice. Directives are valid for 2 years under PA Act 194 of 2004.',
            style: TextStyle(fontSize: 12, color: cs.onErrorContainer),
          ),
        ),
      ),
    );
  }
}

class _LearnMoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Learn About MHADs — FAQ, instructions, glossary, legal details and checklist',
      child: Card(
      color: cs.primaryContainer,
      child: InkWell(
        onTap: () => context.push(AppRoutes.education),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Icon(Icons.menu_book, color: cs.primary, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Learn About MHADs',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: cs.onPrimaryContainer)),
                    Text('FAQ, instructions, glossary, legal details & checklist',
                        style: TextStyle(
                            fontSize: 12, color: cs.onPrimaryContainer)),
                  ],
                ),
              ),
              ExcludeSemantics(
                child: Icon(Icons.chevron_right, color: cs.primary),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _PublicModeNotice extends StatelessWidget {
  final VoidCallback onEndSession;
  const _PublicModeNotice({required this.onEndSession});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: 'Public mode. Session data is temporary. '
          'If the app closes unexpectedly, you have 10 minutes to reopen '
          'and recover your work. Tap End Session when done.',
      child: Card(
        color: cs.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ExcludeSemantics(
                child: Icon(Icons.visibility_off_outlined,
                    size: 40, color: cs.onSecondaryContainer),
              ),
              const SizedBox(height: 12),
              Text('Public Mode',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSecondaryContainer)),
              const SizedBox(height: 8),
              Text(
                'This is a temporary session. Your data is not permanently '
                'stored.\n\n'
                'If the app closes unexpectedly, you have 10 minutes to '
                'reopen and recover your work (API key and form data).\n\n'
                'When you\'re done, tap "End Session" below to securely '
                'erase all session data.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: cs.onSecondaryContainer.withValues(alpha: 0.85)),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onEndSession,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('End Session'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSecondaryContainer,
                    side: BorderSide(
                        color: cs.onSecondaryContainer.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDirectives extends StatelessWidget {
  const _EmptyDirectives();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'No directives yet. Tap New Directive to get started.',
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            ExcludeSemantics(
              child: Icon(Icons.description_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Text('No directives yet',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text('Tap "New Directive" to get started',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

/// Zero-size widget that triggers root/jailbreak detection once per session.
/// Placed inside the HomeScreen tree so it has a valid navigator context.
class _DeviceSecurityCheck extends StatefulWidget {
  const _DeviceSecurityCheck();

  @override
  State<_DeviceSecurityCheck> createState() => _DeviceSecurityCheckState();
}

class _DeviceSecurityCheckState extends State<_DeviceSecurityCheck> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        DeviceSecurityService.instance.checkAndWarn(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
