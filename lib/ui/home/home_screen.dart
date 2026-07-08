import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/device_security_service.dart';
import 'package:mhad/services/reminder_scheduler.dart';
import 'package:mhad/services/web_session_cache.dart';
import 'package:mhad/services/notification_service.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/home/directive_form_choice.dart';
import 'package:mhad/ui/home/home_directive_hero.dart';
import 'package:mhad/ui/home/home_tools_grid.dart';
import 'package:mhad/ui/home/web_landing.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/brand_motif.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/ui/widgets/design/reveal.dart';
import 'package:mhad/ui/widgets/draft_recovery_dialog.dart';
import 'package:mhad/utils/date_format.dart';

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
        if (mounted) unawaited(checkAndOfferDraftRecovery(context, ref));
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

    final dateLabel = formatWeekdayMonthDay(DateTime.now());

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
          // The persistent bottom nav now reserves its own space (rendered by
          // ResponsiveShell below this screen), so no extra bottom gap is needed.
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          children: [
            const _DeviceSecurityCheck(),
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
                    ActiveDirectiveHero(directive: drafts.first),
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
              const ToolsGrid(),
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
              ActiveDirectiveHero(directive: drafts.first),
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
        unawaited(context.push(AppRoutes.wizardRoute(newId)));
      }
    } catch (e) {
      debugPrint('Web session restore failed: $e');
      await WebSessionCache.clear();
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
      unawaited(context.push(AppRoutes.wizardRoute(newId)));
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
      unawaited(context.push(AppRoutes.wizardRoute(d.id)));
    }
  }

}

// _LearnMoreCard removed 2026-06-03 — duplicated the Tools-grid "Learn"
// tile that already routes to AppRoutes.education.


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
                  fontFamily: kSansFamily,
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
              fontFamily: kSansFamily,
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
    // The greeting variant (content/behavior unchanged) — wrapped below in a
    // brand-motif hero panel so the dashboard opens on a premium, on-brand
    // surface instead of a bare headline. Visual only.
    final Widget inner;
    // Public mode: always show the guest greeting regardless of whether
    // session directives happen to carry a name. The "guest" framing is
    // the point — Public mode is anonymous by design.
    if (isPublic) {
      inner = const _PublicGuestGreeting();
    } else {
      final fullName = _pickName();
      if (fullName.isEmpty) {
        // No usable name → keep the anonymous editorial. The caller's fallback
        // already covers the empty-directives case; this guards the case where
        // a directive exists but the name field is still blank.
        inner = EditorialHeading(
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
      } else {
        final firstName = fullName.split(RegExp(r'\s+')).first;
        inner = Row(
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
            // Avatar pill — initials in primaryLight chip, matches prototype.
            Semantics(
              label: 'Profile $firstName',
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: p.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: p.primary.withValues(alpha: 0.4)),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initialsFrom(fullName),
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: p.primary,
                  ),
                ),
              ),
            ),
          ],
        );
      }
    }

    return RevealOnMount(
      child: BrandMotif(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
        child: Align(alignment: Alignment.centerLeft, child: inner),
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
    final stamp = formatShortDate(updated);
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
      child: HoverLift(
        radius: 12,
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
                          fontFamily: kSansFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: p.text,
                        ),
                      ),
                      Text(
                        _subLine(),
                        style: TextStyle(
                          fontFamily: kSansFamily,
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
