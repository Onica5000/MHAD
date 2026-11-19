import 'package:flutter/material.dart';
import 'package:mhad/ui/progress/progress_gate.dart' show startDirective;
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/services/blank_form_service.dart';
import 'package:mhad/ui/home/directive_form_choice.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/wizard/widgets/saved_file_import.dart';
import 'package:mhad/ui/widgets/design/photo_action_card.dart';
import 'package:mhad/ui/widgets/design/page_hero.dart';
import 'package:mhad/ui/theme/app_art.dart';
import 'package:mhad/domain/model/directive.dart';

/// Editorial web landing — a faithful Flutter port of the Claude Design
/// `WebDashboard` (web.jsx). Rendered as the Home screen's WIDE (desktop/web)
/// empty-state, for first-time / no-directive users. Returning users (with
/// drafts or past directives) keep the draft/past dashboard.
///
/// Pieces, top to bottom, mirror the artboard:
///   - anonymous-mode tinted banner (web/public sessions)
///   - editorial serif hero "Make a mental health advance directive."
///   - 2-column form choice: bold primary "Combined" card (★ watermark,
///     Recommended badge) + stacked Declaration-only / POA-only cards
///   - 3-column tools row
///   - "Our privacy promise" grid + "From the booklet" pull-quote
class WebDashboardLanding extends ConsumerWidget {
  final bool isPublic;
  const WebDashboardLanding({required this.isPublic, super.key});

  /// Same as onboarding's "Upload a document to autofill": a fresh
  /// Combined directive, then the standalone autofill page.
  Future<void> _startUpload(BuildContext context, WidgetRef ref) async {
    final id = await startDirective(ref, FormType.combined);
    if (id == null || !context.mounted) return;
    context.go(AppRoutes.uploadRoute(id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;

    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 32, 40, 64),
      children: [
        if (isPublic) ...[_AnonBanner(), const SizedBox(height: 24)],

        // ── Hero: headline + the Home photo (two people walking a path at
        //    sunrise — planning ahead, together). Above the form choice,
        //    never beside an input.
        PageHero(
          art: AppArt.homeHero,
          size: PageHeroSize.large,
          eyebrow: context.l10n.webLandingPennsylvaniaAct194Of2004,
          lead: context.l10n.webLandingALegalDocumentThatTells,
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: context.l10n.webLandingMakeAMentalHealth),
                TextSpan(
                  text: context.l10n.webLandingAdvanceDirective,
                  style: TextStyle(color: p.primary),
                ),
              ],
            ),
            style: EditorialHeading.styleFor(context, HeadingLevel.display),
          ),
        ),
        const SizedBox(height: 32),

        // ── Form choice (reusable — also shown on the returning dashboard so
        //    "Start a new directive" lands on the same picker) ──────────────
        const DirectiveFormChoice(),
        const SizedBox(height: 24),

        // ── Other ways to start: one row of three equal photo cards. It
        //    replaces the lone "Print a blank form" card (which left half the
        //    row empty) and brings the onboarding's upload and saved-file
        //    starts to Home too.
        SectionLabel(context.l10n.homeOtherWaysToStart),
        // Equal boxes, CTAs on one line (the user flagged uneven cards).
        EqualHeightRow(
          children: [
            PhotoActionCard(
                fillHeight: true,
                art: AppArt.startUpload,
                title: context.l10n.onboardingUploadADocumentToAutofill,
                body: context.l10n.homeStartUploadBody,
                cta: context.l10n.homeStartUploadCta,
                onTap: () => _startUpload(context, ref),
            ),
            PhotoActionCard(
                fillHeight: true,
                art: AppArt.startResume,
                title: context.l10n.onboardingContinueFromASavedFile,
                body: context.l10n.homeStartResumeBody,
                cta: context.l10n.homeStartResumeCta,
                onTap: () => importSavedDirectiveFile(context, ref),
            ),
            // Print a blank form — pick any of the three official forms and
            // open the print dialog directly; does NOT start a wizard draft.
            PhotoActionCard(
                fillHeight: true,
                art: AppArt.startPrint,
                title: context.l10n.blankFormPrintTitle,
                body: context.l10n.webLandingPreferPaperOpenAnyOf,
                cta: context.l10n.webLandingPrintBlankForm,
                onTap: () => showBlankFormPicker(context),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // ── Privacy promise + booklet quote ──────────────────────────────
        // Both cards shrink-wrap (their Columns are mainAxisSize.min) so the
        // Row can measure their heights. Earlier they used the default
        // mainAxisSize.max, which under the Row's unbounded height blew up to
        // an infinite height ("BoxConstraints forces an infinite height") and
        // the whole section silently failed to paint — the bottom of the
        // dashboard went missing.
        EqualHeightRow(
          flex: const [14, 10],
          gap: 18,
          children: [
            _PrivacyPromiseCard(),
            _BookletQuoteCard(
                // Deep-link to the plain-language overview ("the basics") rather
                // than the full Learn hub, so the button delivers the summary it
                // promises. Back returns here.
                onRead: () => context.push(
                  AppRoutes.education,
                  extra: (
                    ids: const ['intro_overview', 'intro_why_take_your_time'],
                    title: context.l10n.webLandingTheBasics,
                  ),
                ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Anonymous-mode banner (calm, tinted) ──────────────────────────────────
class _AnonBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: p.primaryTint,
        border: Border.all(color: p.primaryLight),
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: p.primary,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: Icon(Icons.lock_outline, size: 16, color: p.onPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.webLandingYouReWorkingAnonymouslyNothing,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  context.l10n.webLandingNoAccountNoCloudIf,
                  style: TextStyle(
                    fontSize: 12, height: MhadType.leadingParagraph,
                    color: p.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // "HOW THIS WORKS →" link (artboard WebDashboard anon banner) →
          // the privacy policy, which explains the anonymous / nothing-saved
          // model in full.
          InkWell(
            onTap: () => context.push(AppRoutes.privacyPolicy),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                context.l10n.webLandingHowThisWorks,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700, letterSpacing: MhadType.trackingLabel,
                  color: p.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ── "Our privacy promise" 2×2 grid ─────────────────────────────────────────
class _PrivacyPromiseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final rows = <(IconData, String, String)>[
      (
        Icons.lock_outline,
        context.l10n.webLandingNoAccountRequired,
        context.l10n.webLandingNoEmailNoPasswordNo,
      ),
      (
        Icons.shield_outlined,
        context.l10n.webLandingNothingLeavesYourBrowser,
        context.l10n.webLandingYourAnswersLiveInThis,
      ),
      (
        Icons.block,
        context.l10n.webLandingNoCookiesNoTracking,
        context.l10n.webLandingNoAnalyticsNoThirdParty,
      ),
      (
        Icons.download_outlined,
        context.l10n.webLandingYouKeepTheFile,
        context.l10n.webLandingSaveThePdfFromYour,
      ),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SectionLabel(context.l10n.webLandingOurPrivacyPromise),
          const SizedBox(height: 12),
          // Fixed 2×2 grid via two plain Rows.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _PromiseItem(row: rows[0])),
              const SizedBox(width: 8),
              Expanded(child: _PromiseItem(row: rows[1])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _PromiseItem(row: rows[2])),
              const SizedBox(width: 8),
              Expanded(child: _PromiseItem(row: rows[3])),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Single privacy-promise item (icon + title + sub) ──────────────────────
class _PromiseItem extends StatelessWidget {
  final (IconData, String, String) row;
  const _PromiseItem({required this.row});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final (icon, title, sub) = row;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: p.primaryTint,
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          child: Icon(icon, size: 14, color: p.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: p.text,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 12, height: MhadType.leadingParagraph,
                  color: p.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── "From the booklet" serif pull-quote ────────────────────────────────────
class _BookletQuoteCard extends StatelessWidget {
  final VoidCallback onRead;
  const _BookletQuoteCard({required this.onRead});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: BoxDecoration(
            color: p.primaryTint,
            border: Border.all(color: p.primaryLight),
            borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SectionLabel(context.l10n.webLandingFromTheBooklet),
              Text(
                context.l10n.webLandingAnMhadIsYourVoice,
                style: MhadText.serifAccent(context, size: 22, color: p.primaryDark, height: MhadType.leadingUi),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.webLandingPaMhadBookletOfficeOf,
                style: TextStyle(
                  fontSize: 12, letterSpacing: MhadType.trackingLabel,
                  color: p.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRead,
                style: TextButton.styleFrom(
                  foregroundColor: p.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                  alignment: Alignment.centerLeft,
                ),
                child: Text(context.l10n.webLandingReadTheBasics),
              ),
            ],
          ),
    );
  }
}
