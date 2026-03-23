import 'package:flutter/material.dart';
import 'package:mhad/services/pin_auth_service.dart';

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

/// Dialog for entering an existing passcode.
///
/// Returns `true` on successful verification, or `null` if cancelled.
class PinEntryDialog extends StatefulWidget {
  const PinEntryDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PinEntryDialog(),
    );
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
      Navigator.of(context).pop(true);
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
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Enter Passcode'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your passcode to access Private Mode.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              obscureText: _obscure,
              autofocus: true,
              enabled: !_verifying && !_lockedOut,
              decoration: InputDecoration(
                labelText: 'Passcode',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
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
          onPressed: _verifying ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: (_verifying || _lockedOut) ? null : _submit,
          child: _verifying
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Unlock'),
        ),
      ],
    );
  }
}
