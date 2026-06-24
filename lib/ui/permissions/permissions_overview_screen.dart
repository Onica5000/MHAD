import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';
import 'package:mhad/utils/platform_utils.dart';

/// In-app privacy & permissions overview.
///
/// The OS-native permission dialog the prototype shows (`ScrPermission`,
/// mobile-extra2.jsx L114-200) is shipped by iOS / Android, not by Flutter
/// — we can't customize it. What we CAN build, and what the user actually
/// benefits from, is a plain-language explainer of which permissions this
/// app may request, why, and how to manage them in device Settings.
///
/// Each permission row carries:
///   - the prototype's "What we use it for" 4-check list pattern
///   - a clear "We never upload / We discard right after / Nothing stored"
///     transparency block
///   - a "Status" hint (best-effort static, since plugging the actual
///     permission_handler in is deferred to a later batch)
///
/// Reachable from Settings → AI & Privacy → "Privacy & permissions".
class PermissionsOverviewScreen extends StatelessWidget {
  const PermissionsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      // Prototype ScrPermission (mobile-extra2.jsx L114-200) uses CrisisBar
      // + in-body back chevron. The 'Only what we need.' 30pt editorial
      // owns the header in the body.
      body: Column(children: [
        WizardHeader(
          backLabel: 'Back',
          onBack: () => Navigator.of(context).maybePop(),
          actionLabel: '',
        ),
        Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        children: [
          const SectionLabel('What this app may ask for'),
          const SizedBox(height: 6),
          const EditorialHeading(
            text: 'Only what we need.',
            size: 30,
          ),
          const SizedBox(height: 6),
          Text(
            'PA MHAD requests system permissions only for features you '
            'actively use. Nothing is collected in the background. Each '
            'section below explains exactly what a permission unlocks, '
            'what the app does with the result, and what it never does.',
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 14,
              color: p.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          _PermissionCard(
            icon: Icons.fingerprint,
            title: 'Biometrics / passcode',
            usedFor: 'Unlocking encrypted on-device storage (native app only; '
                'not used by the web app).',
            promises: const [
              'Used only to verify your identity on unlock',
              'Biometric data never leaves the OS keystore',
              'No biometric data is sent to any server',
              'Falls back to a passcode you choose if biometrics fail',
            ],
            statusLine: !kIsWeb && platformIsMobile
                ? 'Available · OS-managed'
                : 'Not applicable on this platform',
            statusOk: !kIsWeb && platformIsMobile,
          ),
          const SizedBox(height: 12),
          _PermissionCard(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            usedFor:
                'Reminding you about witness signing, renewals, and check-ins.',
            promises: const [
              'You choose which reminders to enable',
              'Notifications are scheduled locally on this device',
              'No content (PII, directive text) is in any notification body',
              'Disable per-category in device Settings → Notifications',
            ],
            statusLine: !kIsWeb && platformIsMobile
                ? 'Available · OS-managed'
                : 'Not applicable on this platform',
            statusOk: !kIsWeb && platformIsMobile,
          ),
          const SizedBox(height: 12),
          _PermissionCard(
            icon: Icons.camera_alt_outlined,
            title: 'Camera',
            usedFor:
                'Snapping a photo of your ID, medication labels, or condition lists '
                'for AI-assisted field extraction. Coming in a later release.',
            promises: const [
              'Photo is sent to AI only to read it',
              'Photo is discarded right after extraction',
              "Nothing is saved to your device's photo library by default",
              "You review every field before it's used",
            ],
            statusLine: 'Not yet wired — feature in a future release',
            statusOk: false,
          ),
          const SizedBox(height: 12),
          _PermissionCard(
            icon: Icons.mic_outlined,
            title: 'Microphone',
            usedFor:
                'Speaking long-form answers (e.g. "anything else") instead of typing. '
                'Coming in a later release.',
            promises: const [
              "Audio is processed on-device when possible",
              "If sent to AI for transcription, it isn't stored",
              "Transcript stays in your session — never uploaded",
              "Toggle off at any time in Settings",
            ],
            statusLine: 'Not yet wired — feature in a future release',
            statusOk: false,
          ),
          const SizedBox(height: 12),
          _PermissionCard(
            icon: Icons.contacts_outlined,
            title: 'Contacts',
            usedFor:
                'Picking an agent or witness from your address book instead of '
                "typing their details. Coming in a later release.",
            promises: const [
              'We never upload your contacts',
              'Search runs locally on this device',
              "Only the contact you pick is brought into the directive",
              'You can revoke access in Settings any time',
            ],
            statusLine: 'Not yet wired — feature in a future release',
            statusOk: false,
          ),
          const SizedBox(height: 18),
          const InfoBanner(
            icon: Icons.settings_outlined,
            variant: InfoBannerVariant.info,
            text: 'Permissions are managed by your device, not by this app. '
                "Open your device's Settings → PA MHAD to grant, revoke, "
                'or review any of the above at any time.',
          ),
          const SizedBox(height: 12),
          const InfoBanner(
            icon: Icons.shield_outlined,
            variant: InfoBannerVariant.success,
            text:
                'No analytics. No tracking pixels. No cookies. No third-party '
                'SDKs for advertising or measurement. The only outbound flows '
                'are the opt-in AI features (Gemini) and NLM medical-reference '
                'lookups, both with PII stripping at a single chokepoint.',
          ),
        ],
      )),
      ]),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String usedFor;
  final List<String> promises;
  final String statusLine;
  final bool statusOk;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.usedFor,
    required this.promises,
    required this.statusLine,
    required this.statusOk,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final okText =
        dark ? SemanticColors.successTextDark : SemanticColors.successTextLight;
    final mutedText = p.textMuted;
    final statusColor = statusOk ? okText : mutedText;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: p.primaryLight,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 22, color: p.onPrimaryLight),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            statusLine,
                            style: TextStyle(
                              fontFamily: kMonoFamily,
                              fontFamilyFallback: const [
                                'Consolas',
                                'Menlo',
                                'Courier New',
                                'monospace',
                              ],
                              fontSize: 10,
                              letterSpacing: 0.5,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            usedFor,
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 13,
              color: p.text,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          // Promises block — the prototype's "What we use it for" 4-check list.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in promises)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check, size: 13, color: okText),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            line,
                            style: TextStyle(
                              fontFamily: kSansFamily,
                              fontSize: 12,
                              height: 1.4,
                              color: p.text,
                            ),
                          ),
                        ),
                      ],
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
