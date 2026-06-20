import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/device_security_service.dart';
import 'package:mhad/services/reminder_scheduler.dart';
import 'package:mhad/services/web_session_cache.dart';
import 'package:mhad/services/notification_service.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/home/web_landing.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/bottom_nav.dart';
import 'package:mhad/ui/widgets/design/crisis_sheet.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/draft_recovery_dialog.dart';

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
      // The "In your words" intro is no longer pushed from here — it's a
      // router gate ([AppRoutes.onboarding]) that runs before Home, so by the
      // time this screen builds the intro is already done. This callback now
      // just handles session restore + draft recovery + reminders.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        if (kIsWeb && mounted) {
          await _tryWebSessionRestore();
        }
        if (mounted) checkAndOfferDraftRecovery(context, ref);
        // Reminder auto-fire (in-app, per-launch). Runs after onboarding +
        // draft recovery so it never stacks on top of those flows. The
        // scheduler is a silent no-op when no reminder is due.
        if (mounted) await ReminderScheduler.maybeShow(context, ref);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final directivesAsync = ref.watch(allDirectivesProvider);
    final privacyMode = ref.watch(privacyModeNotifierProvider);
    final p = Theme.of(context).mhadPalette;

    final dateLabel = DateFormat('EEEE · MMMM d').format(DateTime.now());

    // Layout mirrors prototype `ScrHome` (mobile.jsx L235-362) exactly:
    //   <Screen>
    //     <CrisisBar />   ← persistent global banner already lives at the
    //                       bottom of every screen via main.dart's Column.
    //                       The prototype puts it at top; we keep the
    //                       global bottom-position banner so this Scaffold
    //                       body starts directly with the date label.
    //     <div padding="20px 22px 100px">
    //       SectionLabel(date)
    //       row { greeting + avatar }
    //       gap 22
    //       active-directive hero  ← only when a draft exists
    //       gap 18
    //       outline "Start a new directive"  ← only when a draft exists
    //       gap 22
    //       SectionLabel(Tools)
    //       gap 8
    //       2x2 tools grid
    //       gap 18
    //       SectionLabel(Past directives)
    //       gap 8
    //       past-directive rows  ← compact tiles, tap → past_detail
    //     </div>
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      bottomNavigationBar: const MhadBottomNav(),
      body: SafeArea(
        bottom: false,
        // Prototype `w-home`: at >=1000px the dashboard splits into the main
        // content column + a right "Tools" sidebar (reusing _ToolsGrid). Below
        // that the mobile single-column layout is unchanged.
        child: Builder(
          builder: (context) {
            // Wide vs narrow off the TOTAL window width (the desktop-shell
            // signal), NOT this screen's post-sidebar content width: the
            // persistent WebSidebar eats 232px, so a content-based >=1000
            // check would leave a dead band (1000–1231px) where the sidebar
            // shows but the dashboard still rendered its mobile column.
            final isWide =
                MediaQuery.sizeOf(context).width >= kWideLayoutBreakpoint;
            final list = ListView(
          // Prototype: 20 top, 22 horizontal, 100 bottom (the 100 leaves
          // room for the absolute-positioned floating pill nav).
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 100),
          children: [
            const _DeviceSecurityCheck(),
            // Public-mode ephemeral status strip stays at the very top
            // for Public sessions (prototype `ScrPublic` L1568-1577).
            if (privacyMode.isPublic) const _EphemeralBar(),
            SectionLabel(dateLabel),
            // Greeting row — h1 italic serif + 40pt avatar circle on the
            // right (prototype L243-253).
            directivesAsync.maybeWhen(
              data: (directives) => _GreetingRow(
                directives: directives,
                isPublic: privacyMode.isPublic,
              ),
              orElse: () => _GreetingRow(
                directives: const [],
                isPublic: privacyMode.isPublic,
              ),
            ),
            if (privacyMode.isPublic) ...[
              const SizedBox(height: 22),
              _PublicModeNotice(
                onEndSession: () => _confirmEndSession(context, ref),
              ),
            ],
            // Active draft hero + outline "Start a new directive" button.
            // Spacing matches prototype L255 (22 above hero) and L296
            // (18 above outline button).
            directivesAsync.maybeWhen(
              data: (directives) {
                final drafts = directives
                    .where((d) => d.status == 'draft')
                    .toList()
                  ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                if (drafts.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),
                    // Start-a-new-directive picker (the form-type page was
                    // retired — picking happens on the dashboard now).
                    const SectionLabel('Start a new directive'),
                    const SizedBox(height: 12),
                    const DirectiveFormChoice(),
                    const SizedBox(height: 28),
                    // "Continue where you left off" sits BELOW the form picker
                    // (under "You can switch form types later").
                    _ActiveDirectiveHero(directive: drafts.first),
                  ],
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
            // Tools — inline on narrow; relocated to the right sidebar on wide.
            if (!isWide) ...[
              const SizedBox(height: 22),
              const SectionLabel('Tools'),
              const SizedBox(height: 8),
              const _ToolsGrid(),
            ],
            const SizedBox(height: 18),
            // Past directives — completed / expired / revoked rendered as
            // compact tiles matching prototype L326-334. The active draft
            // is intentionally excluded (it lives in the hero above). When
            // there are NO directives at all, render the editorial empty
            // hero card in this slot.
            directivesAsync.when(
              data: (directives) {
                final past = directives
                    .where((d) => d.status != 'draft')
                    .toList()
                  ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                if (directives.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SectionLabel('Start your directive'),
                      SizedBox(height: 12),
                      DirectiveFormChoice(),
                    ],
                  );
                }
                if (past.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Past directives'),
                    const SizedBox(height: 8),
                    for (final d in past) ...[
                      _PastDirectiveRow(
                        directive: d,
                        onTap: () => context
                            .push(AppRoutes.pastDirectiveRoute(d.id)),
                        onDelete: () =>
                            _confirmDelete(context, ref, d.id),
                        onRevoke: d.status == 'complete'
                            ? () =>
                                context.push(AppRoutes.revocationRoute(d.id))
                            : null,
                        onRenew: () =>
                            _renewDirective(context, ref, d),
                        onAmend: d.status == 'complete'
                            ? () => _amendDirective(context, ref, d)
                            : null,
                        onExport: () => context
                            .push(AppRoutes.exportRoute(d.id)),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
              loading: () => Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Semantics(
                    label: 'Loading',
                    child: const CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (e, _) {
                debugPrint('Error loading directives: $e');
                return const DirectiveFormChoice();
              },
            ),
          ],
            );
            if (!isWide) return list;
            return _buildWideDashboard(
              context,
              ref,
              directivesAsync: directivesAsync,
              isPublic: privacyMode.isPublic,
              dateLabel: dateLabel,
            );
          },
        ),
      ),
    );
  }

  /// Wide (desktop / web) dashboard — a multi-column layout matching the
  /// Claude Design `WebDashboard`: a primary action column (active-draft hero
  /// or first-directive hero) beside a Tools/info aside, with any past
  /// directives in a 2-column grid below. This fills the content width with
  /// structure instead of stretching single cards. The narrow (mobile) layout
  /// in [build] is unchanged.
  Widget _buildWideDashboard(
    BuildContext context,
    WidgetRef ref, {
    required AsyncValue<List<Directive>> directivesAsync,
    required bool isPublic,
    required String dateLabel,
  }) {
    // Start-a-new-directive picker — the dashboard IS the form-type picker now
    // (the separate form-type page was retired and folded in here).
    const newDirective = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('Start a new directive'),
        SizedBox(height: 12),
        DirectiveFormChoice(),
      ],
    );

    return directivesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        debugPrint('Error loading directives: $e');
        return WebDashboardLanding(isPublic: isPublic);
      },
      data: (directives) {
        // First-time / no-directive web user → the editorial landing
        // (anonymous banner + serif hero + bold form-choice + tools row +
        // privacy promise + booklet quote), a faithful port of the Claude
        // Design `WebDashboard`. Returning users get the dashboard below.
        if (directives.isEmpty) {
          return WebDashboardLanding(isPublic: isPublic);
        }

        final drafts = directives
            .where((d) => d.status == 'draft')
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        final past = directives
            .where((d) => d.status != 'draft')
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        final Widget primary;
        if (drafts.isNotEmpty) {
          primary = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ActiveDirectiveHero(directive: drafts.first),
              const SizedBox(height: 28),
              newDirective,
            ],
          );
        } else {
          primary = newDirective;
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 60),
          children: [
            const _DeviceSecurityCheck(),
            // "Private by design" moved to the very top, replacing the
            // public-mode/ephemeral bar (its web copy already says the
            // directive lives only in this session). The Tools section and the
            // "Web app" public-mode notice were removed from the dashboard.
            const _PrivacyByDesignCard(),
            const SizedBox(height: 16),
            SectionLabel(dateLabel),
            _GreetingRow(directives: directives, isPublic: isPublic),
            const SizedBox(height: 28),
            // Primary action column, now full width.
            primary,
            // Past directives — 2-column grid filling the full width.
            if (past.isNotEmpty) ...[
              const SizedBox(height: 28),
              const SectionLabel('Past directives'),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, c) {
                  const gap = 12.0;
                  final colW = (c.maxWidth - gap) / 2;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final d in past)
                        SizedBox(
                          width: colW,
                          child: _PastDirectiveRow(
                            directive: d,
                            onTap: () => context
                                .push(AppRoutes.pastDirectiveRoute(d.id)),
                            onDelete: () =>
                                _confirmDelete(context, ref, d.id),
                            onRevoke: d.status == 'complete'
                                ? () =>
                                    context.push(AppRoutes.revocationRoute(d.id))
                                : null,
                            onRenew: () =>
                                _renewDirective(context, ref, d),
                            onAmend: d.status == 'complete'
                                ? () => _amendDirective(context, ref, d)
                                : null,
                            onExport: () => context
                                .push(AppRoutes.exportRoute(d.id)),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ],
        );
      },
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

  // _exportData / _confirmSwitchToPublic / _deleteAllData moved to
  // `lib/ui/settings/settings_screen.dart` per user direction
  // 2026-06-03 — they're now reached through the Settings → Data &
  // privacy section rather than the (removed) home AppBar popup menu.

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

  // _confirmRevoke (inline dialog) removed \u2014 the "Revoke" action now opens the
  // full RevocationScreen (AppRoutes.revocationRoute), matching the artboard's
  // WebRevoke (statutory explanation + notify checklist + revocation PDF).

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

  /// Amendment (F5) — distinct from Renew. Amending edits THIS directive in
  /// place; under PA Act 194 an amendment must be re-executed the same way as
  /// the original (re-signed and witnessed by two adults). So we revert the
  /// directive to an unsigned draft and reopen the wizard at its own id; the
  /// sign step re-stamps the execution date and wizard completion restores the
  /// "complete" status once it is signed again.
  Future<void> _amendDirective(
      BuildContext context, WidgetRef ref, Directive d) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Amend this directive?'),
        content: const Text(
          'Amending opens this directive so you can change it — your existing '
          'answers stay in place.\n\n'
          'Important: an amendment is only valid once you re-sign it on paper '
          'with two adult witnesses, the same way as the original (PA Act 194). '
          'Until you re-sign, this directive will show as an unsigned draft, '
          'and any printed copies of the old version stay in effect until you '
          'replace them.\n\n'
          'Prefer to keep the signed original untouched? Use “Renew (copy to '
          'new)” instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Amend'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final repo = ref.read(directiveRepositoryProvider);
    // Revert to an unsigned draft so the user must re-execute it.
    await repo.setExecutionDate(d.id, 0);
    await repo.updateStatus(d.id, DirectiveStatus.draft);

    if (context.mounted) {
      context.push(AppRoutes.wizardRoute(d.id));
    }
  }

}

// _LearnMoreCard removed 2026-06-03 — duplicated the Tools-grid "Learn"
// tile that already routes to AppRoutes.education.

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
                      'If you close or refresh the tab — or the app crashes — '
                      'your work (form data and AI key) is kept on this device '
                      'for 10 minutes so you can reopen and recover it, then '
                      'permanently erased.\n\n'
                      'Export or print your directive to keep a copy.'
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

/// Prototype `ScrHome` active-directive hero card. Shows the most-recent
/// draft directive with form type, last-edited stamp, progress bar, and a
/// "Continue where you left off" CTA pointing at the wizard route.
///
/// Pure visual addition — does not replace the per-directive cards below.
class _ActiveDirectiveHero extends StatelessWidget {
  final Directive directive;
  const _ActiveDirectiveHero({required this.directive});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final formType = FormType.values.firstWhere(
      (e) => e.name == directive.formType,
      orElse: () => FormType.combined,
    );
    final totalSteps = formType.steps.length;
    final currentStep =
        (directive.lastStepIndex + 1).clamp(1, totalSteps);
    final pct = (currentStep / totalSteps).clamp(0.0, 1.0);
    final pctLabel = '${(pct * 100).round()}% complete';
    final remaining = totalSteps - currentStep;
    final remainingLabel = remaining <= 0
        ? 'Ready to review & sign'
        : '~ $remaining more step${remaining == 1 ? '' : 's'}';
    final updated = DateTime.fromMillisecondsSinceEpoch(directive.updatedAt);
    final lastEdited = _humanRelative(updated);
    final formLabel = switch (formType) {
      FormType.combined => 'Combined form',
      FormType.declaration => 'Declaration only',
      FormType.poa => 'Power of Attorney',
    };
    final headline = directive.fullName.trim().isNotEmpty
        ? '${directive.fullName.split(' ').first}’s MHAD'
        : 'Your MHAD';

    return Semantics(
      button: true,
      label:
          'Continue your $formLabel — $pctLabel, last edited $lastEdited',
      child: Material(
        color: p.primary,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              context.go(AppRoutes.wizardRoute(directive.id)),
          child: Stack(
            children: [
              // Decorative oversized italic numeral matching the prototype.
              Positioned(
                right: -10,
                top: -28,
                child: Text(
                  '$currentStep',
                  style: TextStyle(
                    fontFamily: 'Instrument Serif',
                    fontFamilyFallback: const ['Georgia', 'serif'],
                    fontStyle: FontStyle.italic,
                    fontSize: 180,
                    height: 1,
                    fontWeight: FontWeight.w400,
                    color: p.onPrimary.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: p.onPrimary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '● Draft',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: p.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Step $currentStep of $totalSteps',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontFamilyFallback: const [
                              'Consolas',
                              'monospace'
                            ],
                            fontSize: 11.5,
                            color: p.onPrimary.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      headline,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: p.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$formLabel · last edited $lastEdited',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        height: 1.4,
                        color: p.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: SizedBox(
                        height: 4,
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor:
                              p.onPrimary.withValues(alpha: 0.20),
                          valueColor:
                              AlwaysStoppedAnimation(p.onPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pctLabel,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              color:
                                  p.onPrimary.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                        Text(
                          remainingLabel,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: p.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 40,
                      child: FilledButton.icon(
                        onPressed: () => context
                            .go(AppRoutes.wizardRoute(directive.id)),
                        icon: Icon(Icons.arrow_forward,
                            size: 16, color: p.primaryDark),
                        label: Text(
                          'Continue where you left off',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w600,
                            color: p.primaryDark,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          iconAlignment: IconAlignment.end,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _humanRelative(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    return DateFormat('MMM d').format(t);
  }
}

/// Prototype `ScrHome` tools grid — a 2×2 of icon tiles linking to the
/// non-directive destinations users hit most often (AI assistant, Learn,
/// the most-recent directive's wallet card / export, and the crisis sheet).
/// Right sidebar shown on the wide (`w-home`) dashboard layout: the Tools grid
/// plus a privacy reassurance card, in a fixed-width column.
/// "Private by design" reassurance card — used in the wide dashboard's
/// Tools/info aside. (Extracted from the former fixed-width tools sidebar,
/// which the multi-column wide layout replaced.)
class _PrivacyByDesignCard extends StatelessWidget {
  const _PrivacyByDesignCard();

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.primaryTint,
        border: Border.all(color: p.primaryLight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, size: 16, color: p.primary),
              const SizedBox(width: 8),
              Text(
                'Private by design',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: p.onPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            // Platform-accurate: on web nothing persists (in-memory, gone when
            // the tab closes), so "stays on your device" would contradict the
            // "nothing is saved" messaging elsewhere. Native keeps the
            // on-device phrasing.
            kIsWeb
                ? 'Your directive never leaves this browser — no server, no '
                    'account, no tracking. It lives only in this session, and '
                    'only you choose who to share it with.'
                : 'Your directive stays on your device. No ads, no tracking, '
                    'no selling your data — only you choose who to share it '
                    'with.',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12.5,
              height: 1.45,
              color: p.onPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolsGrid extends ConsumerWidget {
  const _ToolsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final aiReady =
        ref.watch(apiKeyProvider).valueOrNull?.isNotEmpty ?? false;
    final directivesAsync = ref.watch(allDirectivesProvider);
    final mostRecentDirective = directivesAsync.maybeWhen(
      data: (ds) {
        if (ds.isEmpty) return null;
        final sorted = [...ds]
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return sorted.first;
      },
      orElse: () => null,
    );

    final tiles = <_ToolTile>[
      _ToolTile(
        icon: Icons.auto_awesome,
        label: 'AI assistant',
        sub: aiReady ? 'Suggests + checks' : 'Set up Gemini',
        onTap: () => context.go(
          aiReady ? AppRoutes.assistant : AppRoutes.aiSetup,
        ),
      ),
      _ToolTile(
        icon: Icons.menu_book_outlined,
        label: 'Learn',
        sub: 'FAQ, glossary',
        onTap: () => context.go(AppRoutes.education),
      ),
      _ToolTile(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Wallet card',
        sub: mostRecentDirective != null ? 'Carry a copy' : 'No directive yet',
        onTap: mostRecentDirective != null
            ? () => context.push(
                AppRoutes.exportRoute(mostRecentDirective.id))
            : null,
      ),
      _ToolTile(
        icon: Icons.favorite_outline,
        label: 'Crisis help',
        sub: '988 + more',
        onTap: () => showCrisisSheet(context),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final colWidth = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tiles
              .map((t) => SizedBox(
                    width: colWidth,
                    child: _ToolTileCard(tile: t, palette: p),
                  ))
              .toList(growable: false),
        );
      },
    );
  }
}

class _ToolTile {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback? onTap;
  const _ToolTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });
}

class _ToolTileCard extends StatelessWidget {
  final _ToolTile tile;
  final MhadPalette palette;
  const _ToolTileCard({required this.tile, required this.palette});

  @override
  Widget build(BuildContext context) {
    final disabled = tile.onTap == null;
    return Semantics(
      button: true,
      enabled: !disabled,
      label: '${tile.label} — ${tile.sub}',
      child: Material(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: tile.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 96),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: palette.primaryTint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(tile.icon,
                      size: 18,
                      color: disabled
                          ? palette.textMuted
                          : palette.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  tile.label,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: palette.text,
                  ),
                ),
                Text(
                  tile.sub,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11.5,
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Editorial home greeting — matches prototype `ScrHome` (mobile.jsx::L242-253).
/// Renders one of two states:
///   - **Personalized** (any directive with a stored fullName): big italic
///     "Hi, [Name]." headline + muted "Let's keep your voice clear." subhead,
///     paired with a 40×40 avatar pill bearing the user's initials on the
///     right side.
///   - **Anonymous** (no directives yet): falls back to the v3 dual-color
///     "Your voice, in your words." editorial so first-launch still has a
///     hook. The caller handles this branch via `directivesAsync.maybeWhen`.
class _GreetingRow extends StatelessWidget {
  final List<Directive> directives;
  final bool isPublic;
  const _GreetingRow({
    required this.directives,
    this.isPublic = false,
  });

  /// Picks the user's name to greet. Preference order: the most-recently-
  /// updated DRAFT, then the most-recently-updated directive of any status.
  /// Returns an empty string if none of the directives carry a `fullName`.
  String _pickName() {
    if (directives.isEmpty) return '';
    final sorted = [...directives]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final firstDraft = sorted
        .where((d) => d.status == 'draft' && d.fullName.trim().isNotEmpty)
        .toList();
    final src = firstDraft.isNotEmpty
        ? firstDraft.first
        : sorted.firstWhere(
            (d) => d.fullName.trim().isNotEmpty,
            orElse: () => sorted.first,
          );
    return src.fullName.trim();
  }

  String _initialsFrom(String name) {
    final parts =
        name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    // Public mode: always show the guest greeting regardless of whether
    // session directives happen to carry a name. The "guest" framing is
    // the point — Public mode is anonymous by design.
    if (isPublic) return const _PublicGuestGreeting();
    final fullName = _pickName();
    if (fullName.isEmpty) {
      // No usable name → keep the anonymous editorial. The caller's fallback
      // already covers the empty-directives case; this guards the case where
      // a directive exists but the name field is still blank.
      return EditorialHeading(
        textSpan: TextSpan(
          children: [
            const TextSpan(text: 'Your voice,\n'),
            TextSpan(
              text: 'in your words.',
              style: TextStyle(color: p.primary),
            ),
          ],
        ),
        size: 38,
        height: 1.05,
        letterSpacing: -0.6,
      );
    }
    final firstName = fullName.split(RegExp(r'\s+')).first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Hi, $firstName.\n'),
                TextSpan(
                  text: "Let's keep your voice clear.",
                  style: TextStyle(color: p.textMuted, fontSize: 22),
                ),
              ],
            ),
            style: const TextStyle(
              fontFamily: 'Instrument Serif',
              fontFamilyFallback: ['Georgia', 'serif'],
              fontStyle: FontStyle.italic,
              fontSize: 38,
              height: 1.05,
              letterSpacing: -0.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Avatar pill — initials in primaryLight chip, matches prototype L248-253.
        Semantics(
          label: 'Profile $firstName',
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.primaryLight,
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.center,
            child: Text(
              _initialsFrom(fullName),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: p.onPrimaryLight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dark ephemeral status strip shown above home content while the user is
/// in Public mode. Matches prototype `ScrPublic` (mobile-extra.jsx L1568-
/// 1577): inverted color block, EyeOff icon left, "Public mode · nothing
/// is saved" text center, monospace "EPHEMERAL" pill right.
class _EphemeralBar extends StatelessWidget {
  const _EphemeralBar();

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: p.text,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.visibility_off_outlined,
                size: 13, color: p.scaffoldBackground),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Public mode · nothing is saved',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: p.scaffoldBackground,
                ),
              ),
            ),
            Text(
              'EPHEMERAL',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontFamilyFallback: const [
                  'Consolas',
                  'Menlo',
                  'Courier New',
                  'monospace',
                ],
                fontSize: 10.5,
                letterSpacing: 0.5,
                color: p.scaffoldBackground.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Editorial greeting for Public-mode home.
class _PublicGuestGreeting extends StatelessWidget {
  const _PublicGuestGreeting();

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Let's get started.",
      style: TextStyle(
        fontFamily: 'Instrument Serif',
        fontFamilyFallback: ['Georgia', 'serif'],
        fontStyle: FontStyle.italic,
        fontSize: 38,
        height: 1.05,
        letterSpacing: -0.5,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

/// Prototype `ScrHome` past-directive compact row (mobile.jsx L327-334).
///
/// Layout: 14px-padded card, FileText icon (20pt muted) + flex column
/// {name (13.5/600), sub (11.5 muted)} + trailing DotsH overflow icon (18pt
/// muted). Tapping the row opens the past-directive detail screen; the
/// overflow icon raises a sheet exposing Export / Renew / Revoke / Delete —
/// all the affordances the prior `_DirectiveCardWithAgent` exposed inline.
class _PastDirectiveRow extends StatelessWidget {
  final Directive directive;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onRevoke;
  final VoidCallback? onRenew;
  final VoidCallback? onAmend;
  final VoidCallback? onExport;

  const _PastDirectiveRow({
    required this.directive,
    required this.onTap,
    required this.onDelete,
    this.onRevoke,
    this.onRenew,
    this.onAmend,
    this.onExport,
  });

  String _subLine() {
    final status = directive.status;
    final updated = DateTime.fromMillisecondsSinceEpoch(directive.updatedAt);
    final stamp = DateFormat('MMM d, y').format(updated);
    return switch (status) {
      'complete' => 'Complete · $stamp',
      'expired' => 'Expired · revoke or copy to new',
      'revoked' => 'Revoked · $stamp',
      _ => stamp,
    };
  }

  String _nameLine() {
    final year = DateTime.fromMillisecondsSinceEpoch(directive.updatedAt).year;
    final n = directive.fullName.trim();
    return n.isEmpty ? 'Directive · $year' : '$n · $year';
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Semantics(
      button: true,
      label: '${_nameLine()}. ${_subLine()}. Tap to open.',
      child: Material(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.border),
            ),
            child: Row(
              children: [
                Icon(Icons.description_outlined,
                    size: 20, color: p.textMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _nameLine(),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: p.text,
                        ),
                      ),
                      Text(
                        _subLine(),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11.5,
                          color: p.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Overflow → bottom sheet with all preserved actions.
                IconButton(
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: Icon(Icons.more_horiz, color: p.textMuted),
                  tooltip: 'More',
                  onPressed: () => _showActions(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    final p = Theme.of(context).mhadPalette;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onExport != null)
                ListTile(
                  leading: Icon(Icons.ios_share, color: p.primary),
                  title: const Text('Export'),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    onExport!();
                  },
                ),
              if (onRenew != null)
                ListTile(
                  leading: Icon(Icons.refresh, color: p.primary),
                  title: const Text('Renew (copy to new)'),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    onRenew!();
                  },
                ),
              if (onAmend != null)
                ListTile(
                  leading: Icon(Icons.edit_note, color: p.primary),
                  title: const Text('Amend (edit this one)'),
                  subtitle: const Text('Requires re-signing & re-witnessing'),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    onAmend!();
                  },
                ),
              if (onRevoke != null)
                ListTile(
                  leading: Icon(Icons.cancel_outlined,
                      color: Theme.of(sheetCtx).colorScheme.error),
                  title: const Text('Revoke'),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    onRevoke!();
                  },
                ),
              ListTile(
                leading: Icon(Icons.delete_outline,
                    color: Theme.of(sheetCtx).colorScheme.error),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  onDelete();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
