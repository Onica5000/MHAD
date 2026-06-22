import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/web_session_cache.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';

/// True while the "More" sheet is on screen — guards against stacking multiple
/// copies when the bottom-nav "More" pill is tapped repeatedly. Mirrors the
/// crisis-sheet guard.
bool _moreSheetOpen = false;

/// Mobile-only "More" bottom sheet: the secondary destinations that the
/// persistent [WebSidebar] shows on wide screens but the four-item floating
/// [MhadBottomNav] has no room for — Autofill, Download & print, Get help, and
/// Reset. This brings narrow-screen navigation to parity with the desktop
/// sidebar WITHOUT a hamburger drawer (CLAUDE.md forbids one); it is the same
/// modal-bottom-sheet pattern as [showCrisisSheet].
///
/// Crisis/988 is intentionally NOT duplicated here — it stays the always-on
/// floating button so help is one tap away from any screen.
///
/// Navigation uses the global [appRouter] (not `context.go`) so it is safe
/// across the `await`s when a fresh directive must be created first.
Future<void> showMoreSheet(BuildContext context, WidgetRef ref) async {
  if (_moreSheetOpen) return;
  _moreSheetOpen = true;
  try {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoreSheet(ref: ref),
    );
  } finally {
    _moreSheetOpen = false;
  }
}

class _MoreSheet extends StatelessWidget {
  final WidgetRef ref;
  const _MoreSheet({required this.ref});

  /// Most-recently-edited directive id, or null when none exist yet (fresh web
  /// session). Mirrors the sidebar's `recentId`.
  int? _recentId() => ref.read(allDirectivesProvider).maybeWhen(
        data: (list) {
          if (list.isEmpty) return null;
          final sorted = [...list]
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return sorted.first.id;
        },
        orElse: () => null,
      );

  /// Open a per-directive route (upload / export). Reuses the directive you're
  /// working on; creates a Combined one first if none exist — exactly the
  /// sidebar's behavior.
  Future<void> _openForDirective(
      BuildContext context, String Function(int) route) async {
    Navigator.of(context).pop();
    final id = _recentId() ??
        await ref
            .read(directiveRepositoryProvider)
            .createDirective(FormType.combined);
    appRouter.go(route(id));
  }

  /// Reset everything in this session and return to a blank start. Confirms
  /// first (destructive). Mirrors the sidebar's `_resetForm`.
  Future<void> _reset(BuildContext context) async {
    Navigator.of(context).pop();
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dctx) {
        final cs = Theme.of(dctx).colorScheme;
        return AlertDialog(
          icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 36),
          title: const Text('Reset and start fresh?'),
          content: const Text(
            'This permanently erases everything in this session — all '
            'directives, your AI key, and chat history — and returns you to a '
            'blank start.\n\nExport or print anything you want to keep first. '
            'This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dctx, true),
              style: FilledButton.styleFrom(backgroundColor: cs.error),
              child: const Text('Reset everything'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    await endPublicSession(ref);
    await WebSessionCache.clear();
    try {
      await ref.read(directiveRepositoryProvider).deleteAllDirectives();
    } catch (_) {}
    appRouter.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(DesignTokens.sheetRadius)),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: p.border,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const EditorialHeading(text: 'More', size: 30),
              const SizedBox(height: 4),
              Text(
                'Everything else you can do here.',
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 13,
                  color: p.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              _MoreRow(
                icon: Icons.document_scanner_outlined,
                title: 'Autofill',
                detail: 'Upload a document, photo, or recording',
                onTap: () => _openForDirective(context, AppRoutes.uploadRoute),
              ),
              _MoreRow(
                icon: Icons.print_outlined,
                title: 'Download & print',
                detail: 'Preview and export your directive packet',
                onTap: () => _openForDirective(context, AppRoutes.exportRoute),
              ),
              _MoreRow(
                icon: Icons.support_agent_outlined,
                title: 'Get help',
                detail: 'Peer support · advocates · referrals',
                onTap: () {
                  Navigator.of(context).pop();
                  appRouter.push(AppRoutes.facilitator);
                },
              ),
              const SizedBox(height: 4),
              _MoreRow(
                icon: Icons.delete_sweep_outlined,
                title: 'Reset',
                detail: 'Erase this session and start fresh',
                destructive: true,
                onTap: () => _reset(context),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final bool destructive;
  final VoidCallback onTap;

  const _MoreRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = destructive
        ? (dark ? SemanticColors.errorBgDark : SemanticColors.errorBgLight)
        : p.surface;
    final border = destructive
        ? (dark
            ? SemanticColors.errorBorderDark
            : SemanticColors.errorBorderLight)
        : p.border;
    final iconBg = destructive
        ? (dark
            ? SemanticColors.errorAccentDark
            : SemanticColors.errorAccentLight)
        : p.primaryLight;
    final iconFg = destructive ? Colors.white : p.onPrimaryLight;
    final titleColor = destructive
        ? (dark ? SemanticColors.errorTextDark : SemanticColors.errorTextLight)
        : p.text;
    final detailColor = destructive
        ? titleColor.withValues(alpha: 0.85)
        : p.textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: iconFg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: kSansFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        detail,
                        style: TextStyle(
                          fontFamily: kSansFamily,
                          fontSize: 12,
                          color: detailColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, size: 16, color: detailColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
