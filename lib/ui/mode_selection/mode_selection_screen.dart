import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mhad/services/pin_auth_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/mode_selection/pin_dialog.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Shown on every app launch (after the one-time disclaimer).
/// The user must choose Public or Private mode before accessing any directives.
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
      final ok = await PinEntryDialog.show(context);
      if (ok == true) {
        widget.notifier.setPrivateMode();
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
        backgroundColor: p.primary,
        body: SafeArea(
          child: Column(
            children: [
              // Hero
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: p.onPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          color: p.onPrimary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'PA Mental Health\nAdvance Directive',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: p.onPrimary,
                          height: 1.2,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Document your mental health treatment preferences — legally binding under PA Act 194',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          color: p.onPrimary.withValues(alpha: 0.85),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Mode cards
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  children: [
                    if (!kIsWeb)
                      _ModeCard(
                        title: 'Private Mode',
                        description:
                            'Encrypted & saved. Requires biometric or passcode.',
                        icon: Icons.fingerprint,
                        light: true,
                        loading: _loading == 'private',
                        dimmed: _loading == 'public',
                        onTap: _loading != null ? null : _pickPrivate,
                      ),
                    if (!kIsWeb) const SizedBox(height: 12),
                    _ModeCard(
                      title: 'Public Mode',
                      description:
                          'Temporary session. Data erased when you exit.',
                      icon: Icons.visibility_off_outlined,
                      light: false,
                      loading: _loading == 'public',
                      dimmed: _loading == 'private',
                      onTap: _loading != null ? null : _pickPublic,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      kIsWeb
                          ? 'Private mode with encrypted storage is available in the mobile and desktop apps.'
                          : 'This selection applies to this session only.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        color: p.onPrimary.withValues(alpha: 0.75),
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
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool light;
  final bool loading;
  final bool dimmed;
  final VoidCallback? onTap;

  const _ModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.light,
    required this.loading,
    required this.dimmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;

    final bg = light ? p.card : p.onPrimary.withValues(alpha: 0.12);
    final titleColor = light ? p.text : p.onPrimary;
    final descColor =
        light ? p.textMuted : p.onPrimary.withValues(alpha: 0.85);
    final iconBgColor =
        light ? p.primaryLight : p.onPrimary.withValues(alpha: 0.15);
    final iconColor = light ? p.primary : p.onPrimary;
    final chevColor =
        light ? p.textMuted : p.onPrimary.withValues(alpha: 0.7);

    return Semantics(
      button: true,
      label: 'Select $title',
      child: AnimatedOpacity(
        opacity: dimmed ? 0.5 : 1,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: light
                    ? null
                    : Border.all(
                        color: p.onPrimary.withValues(alpha: 0.4),
                        width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: loading
                        ? Padding(
                            padding: const EdgeInsets.all(13),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(iconColor),
                            ),
                          )
                        : Icon(icon, color: iconColor, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          description,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: descColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: chevColor, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
