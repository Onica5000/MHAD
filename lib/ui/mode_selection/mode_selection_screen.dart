import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mhad/services/pin_auth_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/mode_selection/pin_dialog.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';

/// Shown on every app launch (after the one-time disclaimer).
/// The user must choose Public or Private mode before accessing any directives.
///
/// Visual design follows the prototype `ScrMode` (mobile.jsx): scaffold
/// background with two white "Card2" cards — a Recommended Private mode
/// (encrypted on-device, biometric / passcode) and a Public mode (in-memory,
/// nothing saved). The auth wiring is unchanged from the previous version —
/// `_pickPrivate`, `_pickPublic`, the passcode fallback, and the loading
/// state all behave exactly as before.
class ModeSelectionScreen extends StatefulWidget {
  final PrivacyModeNotifier notifier;
  const ModeSelectionScreen({required this.notifier, super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  String? _loading; // 'private' | 'public'

  Future<void> _pickPublic() async {
    setState(() => _loading = 'public');
    // Small visual pause matches the prototype's tap affordance.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    widget.notifier.setPublicMode();
  }

  Future<void> _pickPrivate() async {
    setState(() => _loading = 'private');

    final result = await widget.notifier.trySetPrivateMode();
    if (!mounted) return;
    setState(() => _loading = null);

    switch (result) {
      case AuthResult.success:
        break;
      case AuthResult.unavailable:
        await _handlePasscodeAuth();
        break;
      case AuthResult.cancelled:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Authentication failed or was cancelled. Please try again.',
            ),
          ),
        );
        break;
    }
  }

  Future<void> _handlePasscodeAuth() async {
    final hasPin = await PinAuthService.hasPin();
    if (!mounted) return;

    if (hasPin) {
      // Three explicit outcomes:
      //   - unlocked       → enter Private mode
      //   - switchToPublic → enter Public mode (button on the dialog)
      //   - cancelled      → no-op (stay on mode selection)
      final result = await PinEntryDialog.show(context);
      if (!mounted) return;
      switch (result) {
        case PinUnlockResult.unlocked:
          widget.notifier.setPrivateMode();
        case PinUnlockResult.switchToPublic:
          await _pickPublic();
        case PinUnlockResult.cancelled:
          break;
      }
    } else {
      final passcode = await PinSetupDialog.show(context);
      if (passcode != null) {
        await PinAuthService.setPin(passcode);
        if (!mounted) return;
        widget.notifier.setPrivateMode();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: p.scaffoldBackground,
        body: SafeArea(
          child: Column(
            children: [
              const CrisisTopBar(compact: true),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Step 1 of 3 · setup'),
                      const SizedBox(height: 6),
                      Text(
                        'How should we handle your data?',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          letterSpacing: -0.5,
                          color: p.text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'You can change this anytime in Settings.',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          height: 1.5,
                          color: p.textMuted,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Mode cards. Order follows the prototype: Private
                      // (recommended) first, then Public. On web, the
                      // Private card is hidden because encrypted storage
                      // isn't available there — matching the prior wiring.
                      if (!kIsWeb)
                        _Card2(
                          icon: Icons.lock_outline,
                          title: 'Private mode',
                          subtitle:
                              'Your data stays on this device, encrypted. '
                              'Unlock with biometrics or a passcode. You can '
                              'come back to your draft anytime.',
                          badges: const [
                            'Biometrics',
                            'AES-256',
                            'Save drafts',
                            'Across sessions',
                          ],
                          recommended: true,
                          loading: _loading == 'private',
                          dimmed: _loading == 'public',
                          onTap: _loading != null ? null : _pickPrivate,
                        ),
                      if (!kIsWeb) const SizedBox(height: 16),

                      _Card2(
                        icon: Icons.visibility_off_outlined,
                        title: 'Public mode',
                        subtitle:
                            'No data is saved after you close the app. Best '
                            'for shared devices, or one-time use without '
                            'leaving a trace.',
                        badges: const [
                          'Nothing saved',
                          'In-memory only',
                          'Single session',
                        ],
                        loading: _loading == 'public',
                        dimmed: _loading == 'private',
                        onTap: _loading != null ? null : _pickPublic,
                      ),

                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          kIsWeb
                              ? 'Private mode with encrypted storage is '
                                'available in the mobile and desktop apps.'
                              : 'This app is not HIPAA-compliant. Nothing '
                                'is sent to a server for storage.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11.5,
                            height: 1.45,
                            color: p.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Prototype `Card2`: a 1.5px-bordered white card with an icon block, title,
/// subtitle, optional pill badges, and an optional floating "Recommended"
/// label. Tapping the card invokes [onTap]; [loading] swaps the icon for a
/// small spinner; [dimmed] reduces opacity while a sibling is in-flight.
class _Card2 extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> badges;
  final bool recommended;
  final bool loading;
  final bool dimmed;
  final VoidCallback? onTap;

  const _Card2({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badges,
    this.recommended = false,
    required this.loading,
    required this.dimmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final borderColor = recommended ? p.primary : p.border;

    return Semantics(
      button: true,
      label: 'Select $title${recommended ? ' (recommended)' : ''}',
      child: AnimatedOpacity(
        opacity: dimmed ? 0.5 : 1,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: p.card,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon + title row
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: p.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: loading
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              p.primary),
                                    ),
                                  )
                                // Prototype `Card2` icon color is
                                // `p.onPrimaryLight` (darker than `primary` on
                                // the pale primaryLight tile) — mobile.jsx
                                // L114-115. Using `primary` here washes out
                                // the icon against navy's primaryLight.
                                : Icon(icon, color: p.onPrimaryLight, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: p.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13.5,
                          height: 1.45,
                          color: p.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: badges
                            .map((b) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: p.scaffoldBackground,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(color: p.border),
                                  ),
                                  child: Text(
                                    b,
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: p.textMuted,
                                    ),
                                  ),
                                ))
                            .toList(growable: false),
                      ),
                    ],
                  ),
                  // Recommended badge — prototype puts it at top -10 left 16
                  // (mobile.jsx L107-110) and uses the SANS Badge atom
                  // (ds.jsx::Badge L169-186): DM Sans 11/700, letter-spacing
                  // 0.4, padding 4×9, radius 6, text-transform uppercase.
                  if (recommended)
                    Positioned(
                      top: -10,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: p.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'RECOMMENDED',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: p.onPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
