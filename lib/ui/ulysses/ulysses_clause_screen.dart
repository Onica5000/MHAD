import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:mhad/ui/widgets/design/back_link.dart';
import 'package:mhad/ui/widgets/design/page_hero.dart';
import 'package:mhad/ui/theme/app_art.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/widgets/design/status_views.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';

/// Self-binding ("Ulysses") clause (v2 prototype `m-ulysses`, v3 corrected
/// framing).
///
/// IMPORTANT (per v3): in Pennsylvania, self-binding is **structural, not
/// opt-in** — once two qualified professionals find the principal incapable,
/// the directive can only be revoked when capacity returns (revocation:
/// 20 Pa.C.S. §§ 5825, 5839; continued effect during incapacity:
/// §§ 5824(e), 5834(c)). The toggle on this screen simply records the principal's
/// **acknowledgment** that they understand this structural effect, so the
/// rendered PDF can include a one-line acknowledgment that the principal
/// reviewed the boundary.
class UlyssesClauseScreen extends ConsumerStatefulWidget {
  final int directiveId;
  const UlyssesClauseScreen({required this.directiveId, super.key});

  @override
  ConsumerState<UlyssesClauseScreen> createState() =>
      _UlyssesClauseScreenState();
}

class _UlyssesClauseScreenState extends ConsumerState<UlyssesClauseScreen> {
  bool _acknowledged = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final pref = await ref
        .read(directiveRepositoryProvider)
        .getPreferences(widget.directiveId);
    if (!mounted) return;
    setState(() {
      _acknowledged = pref?.selfBindingEnabled ?? false;
      _loading = false;
    });
  }

  Future<void> _setAcknowledged(bool v) async {
    if (v) {
      final confirmed = await _confirmEnable();
      if (!confirmed) return;
    }
    setState(() => _acknowledged = v);
    await ref.read(directiveRepositoryProvider).upsertPreferences(
          DirectivePrefsCompanion(
            directiveId: Value(widget.directiveId),
            selfBindingEnabled: Value(v),
          ),
        );
  }

  Future<bool> _confirmEnable() async {
    final cs = Theme.of(context).colorScheme;
    final v = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.ulyssesClauseBeforeYouAcknowledge),
        content: Text(
          context.l10n.ulyssesClauseThisIsASignificantDecision,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.neverWantCrossAddNotNow)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: cs.primary),
              child: Text(context.l10n.ulyssesClauseIUnderstand)),
        ],
      ),
    );
    return v == true;
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      // Prototype ScrUlysses (gap-analysis.jsx L727-901) uses CrisisBar + an
      // in-body back chevron. The editorial "If future-me refuses…" header
      // owns the visual title rather than a Material AppBar string.
      body: Column(children: [
        const BackLink(),
        Expanded(child: _loading
          ? const PageLoading()
          : ListView(
              padding: DesignTokens.pagePadding,
              children: [
                PageHero(
                  art: AppArt.flowUlysses,
                  eyebrow: context.l10n.sideEffectsOptionalAddOn,
                  title: EditorialHeading(text: context.l10n.ulyssesClauseIfFutureMeRefuses),
                  lead: context.l10n.ulyssesClauseSometimesDuringACrisisPeople,
                ),
                const SizedBox(height: 16),
                Card(
                  color: _acknowledged ? cs.primary : cs.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.ulyssesClauseSelfBindingUlysses,
                          style: TextStyle(
                            fontSize: 12, letterSpacing: MhadType.trackingEyebrow,
                            fontWeight: FontWeight.w700,
                            color: _acknowledged
                                ? cs.onPrimary
                                : cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.ulyssesClauseTieMyselfToTheMast,
                          style: EditorialHeading.styleFor(context, HeadingLevel.sub).copyWith(color: _acknowledged ? cs.onPrimary : cs.onSurface),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.ulyssesClausePerPaAct19420,
                          style: TextStyle(
                            fontSize: 14, height: MhadType.leadingParagraph,
                            color: _acknowledged
                                ? cs.onPrimary
                                : cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          value: _acknowledged,
                          onChanged: _setAcknowledged,
                          activeThumbColor: cs.onPrimary,
                          title: Text(
                            context.l10n.ulyssesClauseIAcknowledgeThis,
                            style: TextStyle(
                              color: _acknowledged
                                  ? cs.onPrimary
                                  : cs.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            context.l10n.ulyssesClauseRecordedInYourDirectivePdf,
                            style: TextStyle(
                              color: _acknowledged
                                  ? cs.onPrimary.withValues(alpha: 0.8)
                                  : cs.onSurfaceVariant,
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _BoundariesCard(),
                const SizedBox(height: 16),
                InfoBanner(
                  icon: Icons.warning_amber_rounded,
                  variant: InfoBannerVariant.warning,
                  text:
                      context.l10n.ulyssesClauseStronglyRecommendedTalkWithA,
                ),
              ],
            )),
      ]),
    );
  }
}

class _BoundariesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final boundaries = [
      context.l10n.ulyssesOnlyAppliesOnceIHave,
      context.l10n.ulyssesOnlyForTreatmentsIExplicitly,
      context.l10n.ulyssesDoesNotAuthorizePhysicalRestraint,
      context.l10n.ulyssesACourtAppointedGuardianNot,
      context.l10n.ulyssesMyDirectiveStillTerminatesAt,
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(context.l10n.ulyssesClauseBoundariesOnThisClause, padding: const EdgeInsets.only(bottom: 8)),
            const SizedBox(height: 8),
            for (final b in boundaries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(b,
                          style: const TextStyle(
                            fontSize: 14, height: MhadType.leadingParagraph,
                          )),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
