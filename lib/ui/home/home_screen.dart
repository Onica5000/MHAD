import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/data_export_service.dart';
import 'package:mhad/services/device_security_service.dart';
import 'package:mhad/services/web_session_cache.dart';
import 'package:mhad/services/notification_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/home/directive_card.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/onboarding/onboarding_screen.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/app_drawer.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/draft_recovery_dialog.dart';
import 'package:mhad/ui/widgets/provider_resources.dart';
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
        final onboarded = await OnboardingScreen.isCompleted();
        if (!onboarded && mounted) {
          await Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => OnboardingScreen(
              onComplete: () => Navigator.of(context).pop(),
            ),
          ));
        }
        if (kIsWeb && mounted) {
          await _tryWebSessionRestore();
        }
        if (mounted) checkAndOfferDraftRecovery(context, ref);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final directivesAsync = ref.watch(allDirectivesProvider);
    final privacyMode = ref.watch(privacyModeNotifierProvider);
    final p = Theme.of(context).mhadPalette;

    return Scaffold(
      backgroundColor: p.surface,
      drawer: const MhadAppDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: p.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.shield_outlined, color: p.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'My Directives',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: privacyMode.isPrivate
                              ? SemanticColors.successTextLight
                              : SemanticColors.warningTextLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          privacyMode.isPrivate
                              ? 'Private · Encrypted'
                              : (privacyMode.isPublic
                                  ? 'Public · Not saved'
                                  : 'No session'),
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: p.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        titleSpacing: 4,
        actions: [
          if (privacyMode.isPrivate)
            PopupMenuButton<String>(
              tooltip: 'Session options',
              icon: Icon(Icons.lock_outline, color: p.text),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'switch_public') {
                  _confirmSwitchToPublic(context, privacyMode);
                } else if (value == 'export_data') {
                  _exportData(context, ref);
                } else if (value == 'delete_all') {
                  _deleteAllData(context, ref);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  enabled: false,
                  child: Text('Private session',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans')),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'export_data',
                  child: Row(children: [
                    Icon(Icons.download_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Export All Data'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'switch_public',
                  child: Row(children: [
                    Icon(Icons.visibility_off_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Switch to Public'),
                  ]),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete_all',
                  child: Row(children: [
                    Icon(Icons.delete_forever,
                        size: 18,
                        color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 10),
                    Text(
                      'Delete All Data',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ]),
                ),
              ],
            )
          else
            PopupMenuButton<String>(
              tooltip: 'Session options',
              icon: Icon(Icons.visibility_off_outlined, color: p.text),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'delete_all') {
                  _deleteAllData(context, ref);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  enabled: false,
                  child: Text('Public session',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans')),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete_all',
                  child: Row(children: [
                    Icon(Icons.delete_forever,
                        size: 18,
                        color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 10),
                    Text(
                      'Delete All Data',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ]),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          const _DeviceSecurityCheck(),
          const InfoBanner(
            icon: Icons.gavel_rounded,
            text:
                'This app helps you document your mental health preferences. '
                'It is not legal advice. Directives are valid for 2 years '
                'under PA Act 194 of 2004.',
            variant: InfoBannerVariant.warning,
          ),
          const SizedBox(height: 16),
          _LearnMoreCard(),
          const SizedBox(height: 20),
          if (privacyMode.isPublic) ...[
            _PublicModeNotice(
              onEndSession: () => _confirmEndSession(context, ref),
            ),
            const SizedBox(height: 20),
          ],
          directivesAsync.when(
            data: (directives) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel(
                    privacyMode.isPublic
                        ? 'Session Directives (${directives.length})'
                        : 'Your Directives (${directives.length})',
                  ),
                  const SizedBox(height: 8),
                  if (directives.isEmpty)
                    const _EmptyDirectives()
                  else
                    ...directives.map((d) => _DirectiveCardWithAgent(
                          key: ValueKey(d.id),
                          directive: d,
                          onExport: () =>
                              context.push(AppRoutes.exportRoute(d.id)),
                          onDelete: () => _confirmDelete(context, ref, d.id),
                          onRevoke: () => _confirmRevoke(context, ref, d.id),
                          onRenew: () => _renewDirective(context, ref, d),
                        )),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Semantics(
                  label: 'Loading',
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (e, _) {
              debugPrint('Error loading directives: $e');
              return const _EmptyDirectives();
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.go(AppRoutes.formTypeSelection),
              icon: const Icon(Icons.add),
              label: const Text('New Directive'),
            ),
          ),
          const SizedBox(height: 24),
          const SectionLabel('Resources'),
          const SizedBox(height: 8),
          const ProviderResourcesCard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _tryWebSessionRestore() async {
    try {
      final snap = await WebSessionCache.getCachedDirective();
      if (snap == null || !mounted) return;

      final repo = ref.read(directiveRepositoryProvider);
      final newId = await repo.restoreFromSnapshot(snap);
      await WebSessionCache.clear();

      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session restored. Personal info must be re-entered.'),
            duration: Duration(seconds: 4),
          ),
        );
        context.push(AppRoutes.wizardRoute(newId));
      }
    } catch (e) {
      debugPrint('Web session restore failed: $e');
      await WebSessionCache.clear();
    }
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

    await endPublicSession(ref);
    await WebSessionCache.clear();
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
          'Important: Revoking in this app does NOT automatically revoke '
          'printed copies. You must also:\n\n'
          '  \u2022 Notify your agent in writing\n'
          '  \u2022 Notify your healthcare providers\n'
          '  \u2022 Destroy or mark "REVOKED" on all printed copies\n'
          '  \u2022 Request return of copies you distributed\n\n'
          'This action cannot be undone in the app.',
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
      await WebSessionCache.clear();
      await endPublicSession(ref);
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

class _LearnMoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          'Learn About MHADs — FAQ, instructions, glossary, legal details and checklist',
      child: DesignCard(
        variant: DesignCardVariant.primary,
        onTap: () => context.push(AppRoutes.education),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learn About MHADs',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'FAQ, instructions, glossary, legal details & checklist',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.9)),
          ],
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
    final p = Theme.of(context).mhadPalette;
    final isWeb = kIsWeb;

    return Semantics(
      container: true,
      label: isWeb
          ? 'Web app — data is in memory only, not saved to disk. '
              'Export before closing browser.'
          : 'Public mode. Tap End Session when done.',
      child: DesignCard(
        variant: DesignCardVariant.warning,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color:
                        SemanticColors.warningTextLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isWeb ? Icons.language : Icons.visibility_off_outlined,
                    size: 20,
                    color: SemanticColors.warningTextLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isWeb ? 'Web App' : 'Public Mode',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: p.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isWeb
                  ? 'Your data is stored in memory only and is NOT '
                      'encrypted or saved to disk.\n\n'
                      'Closing or refreshing the browser tab will erase '
                      'all directive data. Your AI key is cached for '
                      '10 minutes for crash recovery only.\n\n'
                      'Export or print your directive before leaving.'
                  : 'This is a temporary session. Your data is not '
                      'permanently stored.\n\n'
                      'If the app closes unexpectedly, you have 10 minutes '
                      'to reopen and recover your work (API key and form '
                      'data).\n\n'
                      'When you\'re done, tap "End Session" below to '
                      'securely erase all session data.',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: p.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onEndSession,
                icon: Icon(
                    isWeb ? Icons.delete_forever : Icons.logout,
                    size: 18),
                label: Text(
                    isWeb ? 'Clear All Data & Start Over' : 'End Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDirectives extends StatelessWidget {
  const _EmptyDirectives();

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Semantics(
      label: 'No directives yet. Tap New Directive to get started.',
      container: true,
      child: DesignCard(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            ExcludeSemantics(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: p.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.description_outlined,
                    size: 32, color: p.primary),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No directives yet',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap "New Directive" to get started',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: p.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

class _DirectiveCardWithAgent extends ConsumerWidget {
  final Directive directive;
  final VoidCallback onDelete;
  final VoidCallback? onRevoke;
  final VoidCallback? onRenew;
  final VoidCallback? onExport;

  const _DirectiveCardWithAgent({
    required this.directive,
    required this.onDelete,
    this.onRevoke,
    this.onRenew,
    this.onExport,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(directiveRepositoryProvider);
    return FutureBuilder<List<Agent>>(
      future: repo.getAgents(directive.id),
      builder: (context, snapshot) {
        final agentName = (snapshot.data != null && snapshot.data!.isNotEmpty)
            ? snapshot.data!.first.fullName
            : null;
        return DirectiveCard(
          directive: directive,
          onDelete: onDelete,
          onRevoke: onRevoke,
          onRenew: onRenew,
          onExport: onExport,
          agentName: agentName,
        );
      },
    );
  }
}
