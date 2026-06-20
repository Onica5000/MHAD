import 'package:flutter/material.dart';
import 'package:mhad/services/pin_auth_service.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Dialog for creating a new passcode (enter + confirm).
///
/// Returns the passcode [String] on success, or `null` if cancelled.
class PinSetupDialog extends StatefulWidget {
  const PinSetupDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PinSetupDialog(),
    );
  }

  @override
  State<PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<PinSetupDialog> {
  final _passcodeController = TextEditingController();
  final _confirmController = TextEditingController();
  final _confirmFocus = FocusNode();
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _passcodeController.dispose();
    _confirmController.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final passcode = _passcodeController.text;
    final confirm = _confirmController.text;

    if (passcode.length < 4) {
      setState(() => _error = 'Passcode must be at least 4 characters.');
      return;
    }
    if (passcode != confirm) {
      setState(() => _error = 'Passcodes do not match.');
      _confirmController.clear();
      _confirmFocus.requestFocus();
      return;
    }
    Navigator.of(context).pop(passcode);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Create Passcode'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biometric authentication is not available on this device. '
              'Create a passcode to protect your private data.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passcodeController,
              obscureText: _obscure,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Passcode',
                hintText: 'At least 4 characters',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off),
                  tooltip:
                      _obscure ? 'Show passcode' : 'Hide passcode',
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: (_) => _confirmFocus.requestFocus(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              focusNode: _confirmFocus,
              obscureText: _obscure,
              decoration: const InputDecoration(
                labelText: 'Confirm Passcode',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(color: cs.error, fontSize: 13)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}

/// Outcome of the editorial unlock dialog. Three explicit states beat
/// `Future<bool?>` because the "Switch to public mode" affordance needs
/// to be distinguishable from a plain cancel.
enum PinUnlockResult {
  /// Passcode entered and verified.
  unlocked,
  /// User asked to switch to public mode instead. Caller should invoke
  /// `setPublicMode()` on the privacy notifier.
  switchToPublic,
  /// User cancelled (closed the dialog without unlocking or switching).
  cancelled,
}

/// Full-screen editorial unlock for entering an existing passcode.
///
/// Visual mirror of prototype `ScrFaceID` (mobile-extra.jsx::ScrFaceID
/// L9-88): brand row top-left, centered editorial italic "Use your
/// passcode." heading + scanning-style icon tile, monospace status pill,
/// passcode field, and a "Switch to public mode" fallback.
class PinEntryDialog extends StatefulWidget {
  const PinEntryDialog({super.key});

  /// Show the editorial unlock dialog. Resolves to a [PinUnlockResult]
  /// indicating which path the user took.
  static Future<PinUnlockResult> show(BuildContext context) async {
    final result = await showGeneralDialog<PinUnlockResult>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Unlock private mode',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => const PinEntryDialog(),
      transitionBuilder: (_, anim, _, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
    return result ?? PinUnlockResult.cancelled;
  }

  @override
  State<PinEntryDialog> createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<PinEntryDialog> {
  final _controller = TextEditingController();
  String? _error;
  bool _obscure = true;
  bool _verifying = false;
  int _failedAttempts = 0;
  bool _lockedOut = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final passcode = _controller.text;
    if (passcode.isEmpty) {
      setState(() => _error = 'Please enter your passcode.');
      return;
    }

    setState(() {
      _verifying = true;
      _error = null;
    });

    final ok = await PinAuthService.verify(passcode);
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(PinUnlockResult.unlocked);
    } else {
      _failedAttempts++;
      _controller.clear();

      if (_failedAttempts >= 5) {
        // Lock out for 30 seconds after 5 failed attempts
        setState(() {
          _verifying = false;
          _lockedOut = true;
          _error = 'Too many attempts. Please wait 30 seconds.';
        });
        await Future.delayed(const Duration(seconds: 30));
        if (!mounted) return;
        setState(() {
          _lockedOut = false;
          _failedAttempts = 0;
          _error = null;
        });
      } else {
        // Increasing delay: 0s, 1s, 2s, 3s before allowing retry
        final delay = Duration(seconds: _failedAttempts - 1);
        if (delay > Duration.zero) {
          await Future.delayed(delay);
          if (!mounted) return;
        }
        setState(() {
          _verifying = false;
          _error = 'Incorrect passcode. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Brand row — small "m" italic chip + "PA MHAD" / "PRIVATE
              // MODE · LOCKED" monospace status. Matches prototype
              // ScrFaceID L16-27.
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: p.primary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'm',
                      style: TextStyle(
                        fontFamily: 'Instrument Serif',
                        fontFamilyFallback: const ['Georgia', 'serif'],
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        color: p.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PA MHAD',
                        style: TextStyle(
                          fontFamily: kSansFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: p.text,
                        ),
                      ),
                      Text(
                        'PRIVATE MODE · LOCKED',
                        style: TextStyle(
                          fontFamily: kMonoFamily,
                          fontFamilyFallback: const [
                            'Consolas',
                            'Menlo',
                            'Courier New',
                            'monospace',
                          ],
                          fontSize: 10,
                          letterSpacing: 0.6,
                          color: p.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: p.textMuted, size: 22),
                    tooltip: 'Cancel',
                    onPressed: _verifying
                        ? null
                        : () => Navigator.of(context)
                            .pop(PinUnlockResult.cancelled),
                  ),
                ],
              ),
              const Spacer(),
              // Centered glyph — a "lock with key pad" silhouette that
              // sits in the same visual slot as the prototype's Face ID
              // icon. We use Material's `lock_outline` framed in a
              // rounded tile with a pulse-ring overlay.
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 124,
                      height: 124,
                      decoration: BoxDecoration(
                        color: p.card,
                        border: Border.all(color: p.primary, width: 2),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.lock_outline,
                        size: 56,
                        color: p.primary,
                      ),
                    ),
                    // Pulse ring — drawn as a slightly larger rounded
                    // border with 30% alpha so it reads as a halo.
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: p.primary.withValues(alpha: 0.30),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Use your '),
                    TextSpan(
                      text: 'passcode.',
                      style: TextStyle(color: p.primary),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Instrument Serif',
                  fontFamilyFallback: ['Georgia', 'serif'],
                  fontStyle: FontStyle.italic,
                  fontSize: 36,
                  height: 1.05,
                  letterSpacing: -0.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your passcode to unlock private mode.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 13.5,
                  height: 1.5,
                  color: p.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              // Status pill — mirrors the prototype's "SCANNING…" /
              // "AUTHENTICATING…" indicator (verifying), or
              // "ATTEMPT N / 5" while the user is mid-retry.
              if (_verifying || _failedAttempts > 0)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _verifying
                          ? p.primaryTint
                          : (_lockedOut
                              ? cs.errorContainer
                              : p.primaryTint),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _verifying
                                ? p.primary
                                : (_lockedOut
                                    ? cs.error
                                    : p.primary),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _verifying
                              ? 'AUTHENTICATING…'
                              : (_lockedOut
                                  ? 'LOCKED · WAIT 30S'
                                  : 'ATTEMPT $_failedAttempts / 5'),
                          style: TextStyle(
                            fontFamily: kMonoFamily,
                            fontFamilyFallback: const [
                              'Consolas',
                              'Menlo',
                              'Courier New',
                              'monospace',
                            ],
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: _verifying
                                ? p.primary
                                : (_lockedOut ? cs.error : p.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              TextField(
                controller: _controller,
                obscureText: _obscure,
                autofocus: true,
                enabled: !_verifying && !_lockedOut,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kMonoFamily,
                  fontSize: 18,
                  letterSpacing: 6,
                  fontWeight: FontWeight.w700,
                  color: p.text,
                ),
                decoration: InputDecoration(
                  hintText: '· · · ·',
                  hintStyle: TextStyle(
                    fontFamily: kMonoFamily,
                    letterSpacing: 8,
                    color: p.textMuted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(DesignTokens.inputRadius),
                    borderSide: BorderSide(color: p.border, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(DesignTokens.inputRadius),
                    borderSide: BorderSide(color: p.border, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(DesignTokens.inputRadius),
                    borderSide: BorderSide(color: p.primary, width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off),
                    tooltip: _obscure ? 'Show passcode' : 'Hide passcode',
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.error, fontSize: 13),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      (_verifying || _lockedOut) ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                        DesignTokens.buttonHeightLg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          DesignTokens.buttonRadius),
                    ),
                  ),
                  child: _verifying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                      : const Text('Unlock'),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _verifying
                    ? null
                    : () => Navigator.of(context)
                        .pop(PinUnlockResult.switchToPublic),
                child: Text(
                  'Switch to public mode',
                  style: TextStyle(color: p.textMuted, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
