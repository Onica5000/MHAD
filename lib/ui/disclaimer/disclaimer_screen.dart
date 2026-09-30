import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/notification_service.dart';
import 'package:mhad/ui/disclaimer/legal_sheet.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/brand_motif.dart';

/// First-launch legal disclaimer + read-only Settings variant.
///
/// Gate layout — matches the Claude Design web `WebDisclaimer`
/// (web-flow-screens.jsx) per user direction (2026-06-12):
///   * SectionLabel "Before you begin"
///   * Italic serif header "A few things to understand."
///   * Muted lead paragraph (Act 194 framing)
///   * Four editorial icon cards: not-legal-advice, signed-on-paper,
///     nothing-saved (kIsWeb-adaptive), stop-or-change
///   * Tinted acknowledgment row — "I'm 18 or older, and I understand and
///     want to continue." (the 18+ requirement, which the artboard omits, is
///     folded in here)
///   * Footer row: "Read full disclaimer" ghost link + primary "Get started".
///
/// The single check affirms both age (18+) and acknowledgment. The full
/// 8-section legal text (two-year validity, witness eligibility, PA P&A /
/// attorney resources, etc.) is reachable via "Read full disclaimer", which
/// opens the accordion in a modal sheet ([FullLegalSheet]). The read-only
/// Settings variant renders the same sections as [ReadOnlyAccordion]; both
/// live in `legal_sheet.dart`.
class DisclaimerScreen extends StatefulWidget {
  final DisclaimerNotifier? _notifier;
  final bool _readOnly;

  /// First-launch gate variant — user ticks one checkbox before
  /// they can tap Continue.
  const DisclaimerScreen.gate({
    required DisclaimerNotifier notifier,
    super.key,
  })  : _notifier = notifier,
        _readOnly = false;

  /// Read-only variant — the 8-section accordion with an AppBar back
  /// button instead of the accept footer. Used from Settings → Legal.
  const DisclaimerScreen.readOnly({super.key})
      : _notifier = null,
        _readOnly = true;

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  bool _accepted = false;

  Future<void> _accept() async {
    if (widget._notifier == null) return;
    await widget._notifier!.accept();
    await NotificationService.instance.requestPermission();
  }

  void _openFullLegal() {
    final p = Theme.of(context).mhadPalette;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.scaffoldBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return FullLegalSheet(scrollController: controller);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final readOnly = widget._readOnly;

    if (readOnly) {
      return ReadOnlyAccordion(palette: p);
    }
    return _GateLayout(
      palette: p,
      accepted: _accepted,
      onAcceptToggle: () => setState(() => _accepted = !_accepted),
      onContinue: _accepted ? _accept : null,
      onOpenFull: _openFullLegal,
    );
  }
}

// ─── Gate layout (prototype-faithful) ───────────────────────────────────

class _GateLayout extends StatelessWidget {
  final MhadPalette palette;
  final bool accepted;
  final VoidCallback onAcceptToggle;
  final VoidCallback? onContinue;
  final VoidCallback onOpenFull;

  const _GateLayout({
    required this.palette,
    required this.accepted,
    required this.onAcceptToggle,
    required this.onContinue,
    required this.onOpenFull,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: palette.scaffoldBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative brand backdrop behind the gate content (no input/
            // layout impact); uses the gate's threaded palette.
            BrandBackdrop(intensity: 0.6, palette: palette),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(context.l10n.disclaimerBeforeYouBegin, palette: palette),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.disclaimerAFewThingsToUnderstand,
                    style: TextStyle(
                      fontFamily: 'Instrument Serif',
                      fontFamilyFallback: const ['Georgia', 'serif'],
                      fontStyle: FontStyle.italic,
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                      height: 1.05,
                      letterSpacing: -0.5,
                      color: palette.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.disclaimerThisToolHelpsYouWrite,
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 14,
                      color: palette.textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      // Card set mirrors the Claude Design web `WebDisclaimer`.
                      // "Not legal advice" is now the first card (it replaced
                      // the old warning banner); the 18+ requirement is
                      // affirmed in the acknowledgment row below; the two-year
                      // validity and the PA P&A / attorney resources live in
                      // the full legal sections ("Read full disclaimer").
                      children: [
                        _DisclaimerCard(
                          icon: Icons.shield_outlined,
                          title: context.l10n.disclaimerThisIsNotLegalAdvice,
                          body:
                              context.l10n.disclaimerWeGivePlainLanguageHelp,
                        ),
                        const SizedBox(height: 10),
                        _DisclaimerCard(
                          icon: Icons.draw_outlined,
                          title:
                              context.l10n.disclaimerItBecomesValidOnlyWhen,
                          body:
                              context.l10n.disclaimerPaLawRequiresYourSignature,
                        ),
                        const SizedBox(height: 10),
                        _DisclaimerCard(
                          icon: Icons.lock_outline,
                          title: context.l10n.disclaimerNothingIsSavedOrSent,
                          // Accurate on each platform: web is in-memory only;
                          // native Private Mode stores encrypted on-device.
                          body: kIsWeb
                              ? context.l10n.disclaimerYouWorkAnonymouslyInThis
                              : context.l10n.disclaimerNoAccountNoCloudNo,
                        ),
                        const SizedBox(height: 10),
                        _DisclaimerCard(
                          icon: Icons.published_with_changes,
                          title: context.l10n.disclaimerYouCanStopOrChange,
                          body:
                              context.l10n.disclaimerSkipQuestionsGoBackOr,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AckRow(
                    palette: palette,
                    checked: accepted,
                    onToggle: onAcceptToggle,
                  ),
                  const SizedBox(height: 16),
                  // Artboard footer: a "Read full disclaimer" ghost link on the
                  // left and the primary "Get started" CTA on the right.
                  Row(
                    children: [
                      TextButton(
                        onPressed: onOpenFull,
                        style: TextButton.styleFrom(
                          foregroundColor: palette.text,
                          textStyle: const TextStyle(
                            fontFamily: kSansFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(context.l10n.disclaimerReadFullDisclaimer),
                      ),
                      const Spacer(),
                      // NOTE: set the height via minimumSize, NOT a wrapping
                      // SizedBox(height:). Inside a Row with a Spacer, a
                      // SizedBox(height:) lets the button be measured at
                      // UNBOUNDED width ("BoxConstraints forces an infinite
                      // width"), so it silently fails to lay out / paint.
                      FilledButton.icon(
                        onPressed: onContinue,
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        iconAlignment: IconAlignment.end,
                        label: Text(context.l10n.disclaimerGetStarted),
                        style: FilledButton.styleFrom(
                          backgroundColor: palette.primary,
                          foregroundColor: palette.onPrimary,
                          // Visible-but-muted when the 18+ box isn't checked,
                          // so users can see the CTA waiting for them.
                          disabledBackgroundColor: palette.primaryLight,
                          disabledForegroundColor: palette.primary,
                          minimumSize:
                              const Size(0, DesignTokens.buttonHeightLg),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                DesignTokens.buttonRadius),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: kSansFamily,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // No crisis chip on this first-run gate by design; crisis access
            // begins on the dashboard (Home tools / the mobile "More" sheet).
            // (The global floating 988 button was removed 2026-06-22.)
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final MhadPalette palette;
  const _SectionLabel(this.text, {required this.palette});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: kMonoFamily,
        fontFamilyFallback: const [
          'Consolas',
          'Menlo',
          'Courier New',
          'monospace'
        ],
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: palette.textMuted,
      ),
    );
  }
}

/// Editorial icon card — mirrors the Claude Design `WebDisclaimer` cards
/// (38px primaryTint icon square + title + body inside a bordered card).
class _DisclaimerCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _DisclaimerCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return DesignCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: DesignTokens.inputRadius,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: p.primaryLight,
              borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 19, color: p.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 13,
                    height: 1.5,
                    color: p.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AckRow extends StatelessWidget {
  final MhadPalette palette;
  final bool checked;
  final VoidCallback onToggle;
  const _AckRow({
    required this.palette,
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Tinted acknowledgment row (artboard WebDisclaimer). The 18+ requirement
    // — which the artboard omits — is folded into the affirmation here.
    return Semantics(
      checked: checked,
      button: true,
      child: Material(
        color: palette.primaryTint,
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
              border: Border.all(color: palette.primaryLight),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: checked ? palette.primary : Colors.transparent,
                    border: Border.all(color: palette.primary, width: 1.8),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: checked
                      ? Icon(Icons.check, size: 14, color: palette.onPrimary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.disclaimerIM18OrOlder,
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: palette.text,
                    ),
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
