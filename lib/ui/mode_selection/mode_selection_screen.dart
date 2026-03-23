import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mhad/services/pin_auth_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/mode_selection/pin_dialog.dart';

/// Shown on every app launch (after the one-time disclaimer).
/// The user must choose Public or Private mode before accessing any directives.
class ModeSelectionScreen extends StatefulWidget {
  final PrivacyModeNotifier notifier;
  const ModeSelectionScreen({required this.notifier, super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  bool _loading = false;

  Future<void> _pickPublic() async {
    widget.notifier.setPublicMode();
    // GoRouter redirect fires automatically via notifyListeners
  }

  Future<void> _pickPrivate() async {
    setState(() => _loading = true);

    final result = await widget.notifier.trySetPrivateMode();
    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case AuthResult.success:
        // GoRouter redirect fires automatically via notifyListeners.
        break;
      case AuthResult.unavailable:
        // Biometrics / device credentials not usable — fall back to passcode.
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
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Center(
                  child: Icon(Icons.shield_outlined,
                      size: 64, color: cs.primary),
                ),
                const SizedBox(height: 20),
                Text(
                  'Choose Access Mode',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select how you want to use the app in this session.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Public mode card
                _ModeCard(
                  icon: Icons.visibility_off_outlined,
                  title: 'Public Mode',
                  description:
                      'Use the app without saving anything.\n'
                      'All data is temporary and automatically erased when the app closes. '
                      'No stored directives are accessible.',
                  color: cs.secondaryContainer,
                  onColor: cs.onSecondaryContainer,
                  onTap: _loading ? null : _pickPublic,
                ),
                const SizedBox(height: 16),

                // Private mode card (not available on web — no encrypted storage)
                if (!kIsWeb)
                  _ModeCard(
                    icon: Icons.fingerprint,
                    title: 'Private Mode',
                    description:
                        'Access your saved directives.\n'
                        'Requires authentication. Your data is encrypted '
                        'and stored securely on this device.',
                    color: cs.primaryContainer,
                    onColor: cs.onPrimaryContainer,
                    onTap: _loading ? null : _pickPrivate,
                    trailing: _loading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: Semantics(
                              label: 'Loading',
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                if (kIsWeb)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Private mode with encrypted storage is available '
                      'in the mobile and desktop apps.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                const Spacer(flex: 2),
                Text(
                  kIsWeb
                      ? 'Data entered in this session is temporary and will '
                        'not be saved when you close the browser tab.'
                      : 'This selection applies to this session only. '
                        'You will be asked again the next time you open the app.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color onColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onColor,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Select $title mode',
      child: Card(
      color: color,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: onColor, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: onColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(description,
                        style: TextStyle(
                            color: onColor.withValues(alpha: 0.85),
                            fontSize: 13,
                            height: 1.4)),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    ),
    );
  }
}
