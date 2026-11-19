import 'package:mhad/ui/education/education_article_detail.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/data/app_data/app_data.dart' show appData;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart' show endPublicSession;
import 'package:mhad/services/web_session_cache.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/widgets/design/crisis_sheet.dart';

/// App-wide actions shared by every navigation surface — the desktop sidebar,
/// the phone More sheet, Home. ONE implementation each (2026-11 overhaul: the
/// sidebar and the More sheet carried copies of reset, "most recent
/// directive", "open for a directive" and the crisis opener, and the More
/// sheet's "Get help" could stack duplicate pages).
///
/// They navigate with the global [appRouter] and show dialogs on the root
/// navigator, so they work from widgets that sit above the router.

/// The most recently edited directive's id, or null when there are none yet
/// (a fresh web session).
int? mostRecentDirectiveId(List<Directive> directives) {
  if (directives.isEmpty) return null;
  final sorted = [...directives]
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return sorted.first.id;
}

/// Opens a per-directive page ([route], e.g. Export or Autofill) for
/// [preferredId], else the most recent directive, else a new Combined
/// directive created first — so the page is reachable even in a fresh session.
Future<void> openForDirective(
  WidgetRef ref,
  String Function(int id) route, {
  int? preferredId,
}) async {
  final id = preferredId ??
      mostRecentDirectiveId(
          ref.read(allDirectivesProvider).value ?? const []) ??
      await ref.read(directiveRepositoryProvider).createDirective(
            FormType.combined,
          );
  appRouter.go(route(id));
}

/// "Revoke a directive" (More): the Revoke page for this session's directive;
/// with none in this tab (the web keeps nothing between visits), the Learn
/// article on how to revoke one signed earlier. Always reachable.
Future<void> openRevokeOrGuide(WidgetRef ref) async {
  final id =
      mostRecentDirectiveId(ref.read(allDirectivesProvider).value ?? const []);
  if (id != null) {
    appRouter.go(AppRoutes.revocationRoute(id));
    return;
  }
  final nav = rootNavigatorKey.currentState;
  final ctx = rootNavigatorKey.currentContext;
  if (nav == null || ctx == null) return;
  final guide = EducationalContent.sectionsFor(
          Localizations.localeOf(ctx).languageCode)
      .where((s) => s.id == 'faq_revoke');
  if (guide.isEmpty) return;
  await nav.push(MaterialPageRoute<void>(
      builder: (_) => ArticleDetailScreen(section: guide.first)));
}

/// Erases everything in this session after a confirmation (destructive), then
/// lands on a blank Home — the visibly fresh dashboard is the confirmation.
Future<void> confirmAndResetSession(WidgetRef ref) async {
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null) return;
  final confirmed = await showDialog<bool>(
    context: ctx,
    builder: (dctx) {
      final cs = Theme.of(dctx).colorScheme;
      return AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 36),
        title: Text(dctx.l10n.moreSheetResetAndStartFresh),
        content: Text((appData.ai.apiModeVisible ? dctx.l10n.moreSheetThisPermanentlyErasesEverythingIn : dctx.l10n.moreSheetThisPermanentlyErasesEverythingInHandoff)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx, false),
            child: Text(dctx.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dctx, true),
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: Text(dctx.l10n.moreSheetResetEverything),
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

/// Opens the crisis-resources sheet (988 and more) on the root navigator.
void openCrisisHelp() {
  final ctx = rootNavigatorKey.currentContext;
  if (ctx != null) showCrisisSheet(ctx);
}

bool _getHelpOpen = false;

/// Opens "Get help" (peer support, advocates, referrals) once — repeated taps
/// don't stack copies.
Future<void> openGetHelp() async {
  if (_getHelpOpen) return;
  _getHelpOpen = true;
  try {
    await appRouter.push(AppRoutes.facilitator);
  } finally {
    _getHelpOpen = false;
  }
}
