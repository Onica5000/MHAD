import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const _prefKey = 'onboarding_completed';

/// First-touch welcome — prototype-exact rebuild of mobile.jsx::ScrWelcome
/// (L37-96).
///
/// Single-screen editorial: 988 pill upper-right, "PA MHAD · Act 194"
/// section label, 68pt italic-serif "In your / **words.**" headline,
/// muted lead paragraph, four value chips, then two CTAs:
///
///   * Primary "Get started" — saves the onboarded flag and dismisses,
///     dropping the user on Home (where they pick a form type).
///   * Ghost "I already have a directive" — saves the flag and routes
///     straight to the form-type selector, mirroring the prototype's
///     intent that returning users can jump to a new draft without
///     re-reading the intro.
///
/// The earlier 4-page PageView (What to Include / What to Have Ready /
/// Time expectation) was removed 2026-06-03 per direction "match the
/// claude design UI/UX EXACTLY." That content remains discoverable
/// through the Learn screen.
class OnboardingScreen extends StatelessWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({required this.onComplete, super.key});

  /// Returns true if onboarding has been completed.
  static Future<bool> isCompleted() async {
    // On web the session is ephemeral (public mode, nothing persisted), so the
    // "In your words" intro shows every visit — same policy as the disclaimer.
    if (kIsWeb) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  Future<void> _markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  Future<void> _getStarted() async {
    await _markCompleted();
    onComplete();
  }

  Future<void> _alreadyHave(BuildContext context) async {
    await _markCompleted();
    if (!context.mounted) return;
    onComplete();
    if (!context.mounted) return;
    context.go(AppRoutes.formTypeSelection);
  }

  Future<void> _dial988() async {
    final uri = Uri(scheme: 'tel', path: '988');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Scaffold(
      backgroundColor: p.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle 988 link in upper right (prototype L43-51).
            Positioned(
              top: 8,
              right: 16,
              child: Semantics(
                button: true,
                label: 'Call 988 Suicide and Crisis Lifeline',
                child: InkWell(
                  onTap: _dial988,
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: SemanticColors.errorBgLight,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: SemanticColors.errorBorderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone, size: 12, color: SemanticColors.errorAccentLight),
                        const SizedBox(width: 5),
                        Text(
                          '988',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: SemanticColors.errorAccentLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Main editorial column. Padding matches prototype L54
            // `padding: '64px 28px 0'` — but we let SafeArea push the
            // top so the 988 chip and content don't collide on devices
            // with deep notches. On wide web this screen is pushed over the
            // (fill-mode) Home route, so cap + centre the column at the
            // design's WebCenter measure (~640) — otherwise the banner and
            // CTAs stretch the full viewport width. No-op on mobile (422 px).
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 64, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('PA MHAD · Act 194'),
                  const SizedBox(height: 18),
                  // Editorial 68pt h1 "In your\nwords." — "words." is the
                  // primary-tinted accent (prototype L58-64).
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'In your\n'),
                        TextSpan(
                          text: 'words.',
                          style: TextStyle(color: p.primary),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontFamily: 'Instrument Serif',
                      fontFamilyFallback: const ['Georgia', 'serif'],
                      fontStyle: FontStyle.italic,
                      fontSize: 68,
                      height: 0.95,
                      letterSpacing: -1.5,
                      fontWeight: FontWeight.w400,
                      color: p.text,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(
                      'Document how you want to be treated during a mental '
                      "health crisis — so your wishes are honored even when "
                      "you can't speak for yourself.",
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 17,
                        height: 1.45,
                        color: p.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // A2 / F17: capacity-presumption reassurance — the single
                  // biggest adoption fear is "does signing this take away my
                  // choices now?". State plainly that it does not.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: p.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Making this changes nothing '
                              'today. '),
                          TextSpan(
                            text: 'You keep every decision',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: p.onPrimaryLight,
                            ),
                          ),
                          const TextSpan(
                              text: ' until two professionals find you '
                                  'unable to decide for yourself.'),
                        ],
                      ),
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13.5,
                        height: 1.4,
                        color: p.onPrimaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _WelcomePills(),
                  const SizedBox(height: 12),
                  // C1: the "Valid 2 years" pill omits the statutory incapacity
                  // exception — clarify it in small print under the pills.
                  Text(
                    'Valid two years from signing — unless you are incapable '
                    'when it would expire, when it stays in effect until your '
                    'capacity returns. (PA Act 194, effective 2005.)',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11.5,
                      height: 1.4,
                      color: p.textMuted,
                    ),
                  ),
                  const Spacer(),
                  // Primary "Get started" (prototype L82-84).
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _getStarted,
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Get started'),
                      style: FilledButton.styleFrom(
                        backgroundColor: p.primary,
                        foregroundColor: p.onPrimary,
                        iconAlignment: IconAlignment.end,
                        minimumSize: const Size.fromHeight(
                            DesignTokens.buttonHeightLg),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(DesignTokens.buttonRadius),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Ghost secondary "I already have a directive" — routes
                  // to form-type selection per user 2026-06-03 direction.
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => _alreadyHave(context),
                      style: TextButton.styleFrom(
                        foregroundColor: p.text,
                        minimumSize: const Size.fromHeight(
                            DesignTokens.buttonHeightMd),
                        textStyle: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('I already have a directive'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Footer reassurance (prototype L89-90).
                  Center(
                    child: Text(
                      'Free · no account · no tracking · open source',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        height: 1.45,
                        color: p.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Four value chips summarizing the directive — prototype L73-78.
/// Calendar / Users / Shield / Lock icons, primaryLight background.
class _WelcomePills extends StatelessWidget {
  const _WelcomePills();

  static const _pills = <(IconData, String)>[
    (Icons.calendar_today_outlined, 'Valid 2 years'),
    (Icons.people_alt_outlined, '2 witnesses'),
    (Icons.shield_outlined, 'PA Act 194'),
    (Icons.lock_outline, 'Stays on your device'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (icon, label) in _pills)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: p.primaryLight,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: p.onPrimaryLight),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: p.onPrimaryLight,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
