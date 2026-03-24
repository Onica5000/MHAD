import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen setup for the Gemini API key with step-by-step instructions.
///
/// In **private mode**, the key is stored in flutter_secure_storage and
/// persists across sessions.
///
/// In **public mode** (or web), the key is held in memory only and is
/// automatically discarded when the app closes or the session ends.
class AiSetupScreen extends ConsumerStatefulWidget {
  const AiSetupScreen({super.key});

  @override
  ConsumerState<AiSetupScreen> createState() => _AiSetupScreenState();
}

class _AiSetupScreenState extends ConsumerState<AiSetupScreen> {
  final _keyCtrl = TextEditingController();
  bool _saving = false;
  bool _obscure = true;

  bool get _isEphemeral => isEphemeralApiKeyMode(ref);

  @override
  void initState() {
    super.initState();
    // Pre-fill only in private mode (persisted key)
    if (!_isEphemeral) {
      final existing = ref.read(apiKeyProvider).whenOrNull(data: (k) => k);
      if (existing != null && existing.isNotEmpty) {
        _keyCtrl.text = existing;
      }
    }
  }

  @override
  void dispose() {
    _keyCtrl.clear();
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final key = _keyCtrl.text.trim();
    if (key.isEmpty) return;

    // Basic format validation
    if (key.length < 20 || key.contains(' ') || key.contains('\n')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'That doesn\'t look like a valid API key. '
              'Gemini keys are typically 39 characters starting with "AIza".'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    await saveApiKey(ref, key);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEphemeral
              ? 'API key set for this session'
              : 'API key saved'),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove API Key?'),
        content: const Text(
            'AI features will be disabled until a new key is added.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed == true) {
      await deleteApiKey(ref);
      _keyCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API key removed')),
        );
      }
    }
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null && data!.text!.isNotEmpty) {
        _keyCtrl.text = data.text!.trim();
        setState(() {});
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not paste. Try pasting manually (Ctrl+V).')),
        );
      }
    }
  }

  static final _aiStudioUri = Uri.parse('https://aistudio.google.com/apikey');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasKey = ref.watch(apiKeyProvider).whenOrNull(
              data: (k) => k != null && k.isNotEmpty,
            ) ??
        false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant Setup'),
        actions: [
          if (hasKey)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remove API key',
              onPressed: _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ---- Ephemeral mode banner ----
          if (_isEphemeral) ...[
            Card(
              color: cs.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 20, color: cs.onTertiaryContainer),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your API key will not be saved permanently. '
                        'It is held in memory only and discarded when '
                        'you clear your data or close the app.',
                        style: TextStyle(
                            fontSize: 12.5,
                            color: cs.onTertiaryContainer,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ---- Instructions ----
          Text('Get Your Free Gemini API Key',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'The AI assistant uses Google\'s Gemini model. You need a '
            'free API key from Google AI Studio — it takes about 30 seconds.',
            style: TextStyle(
                fontSize: 13, color: cs.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 16),

          // ---- Step 1: Private browsing ----
          Card(
            color: cs.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, size: 20,
                          color: cs.onErrorContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Step 1: Open a Private/Incognito Window',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: cs.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll need to sign into your Google account to get an '
                    'API key. To protect your login on shared or public '
                    'devices, open a private browsing window first:',
                    style: TextStyle(
                        fontSize: 12.5, color: cs.onErrorContainer,
                        height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  _BrowserShortcut(
                    browser: 'Chrome',
                    shortcut: 'Ctrl + Shift + N',
                    macShortcut: '\u2318 + Shift + N',
                    color: cs.onErrorContainer,
                  ),
                  _BrowserShortcut(
                    browser: 'Firefox',
                    shortcut: 'Ctrl + Shift + P',
                    macShortcut: '\u2318 + Shift + P',
                    color: cs.onErrorContainer,
                  ),
                  _BrowserShortcut(
                    browser: 'Edge',
                    shortcut: 'Ctrl + Shift + N',
                    macShortcut: '\u2318 + Shift + N',
                    color: cs.onErrorContainer,
                  ),
                  _BrowserShortcut(
                    browser: 'Safari',
                    shortcut: '',
                    macShortcut: '\u2318 + Shift + N',
                    color: cs.onErrorContainer,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'On a phone: tap the menu (\u22EE or \u22EF) and select '
                    '"New Incognito Tab" or "New Private Tab".',
                    style: TextStyle(
                        fontSize: 12, color: cs.onErrorContainer,
                        fontStyle: FontStyle.italic, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Google login will be automatically forgotten when '
                    'you close the private window.',
                    style: TextStyle(
                        fontSize: 12.5, color: cs.onErrorContainer,
                        fontWeight: FontWeight.w600, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ---- Step 2: Open AI Studio ----
          _StepTile(
            number: '2',
            title: 'Open Google AI Studio (in your private window)',
            subtitle: 'Use any Google account (personal Gmail works fine)',
            trailing: OutlinedButton.icon(
              onPressed: () => launchUrl(_aiStudioUri,
                  mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Open AI Studio'),
            ),
          ),
          const _StepTile(
            number: '3',
            title: 'Sign in with Google',
            subtitle:
                'No credit card or payment is needed. '
                'The free tier is generous and sufficient for this app.',
          ),
          const _StepTile(
            number: '4',
            title: 'Create an API key',
            subtitle:
                'Click "Create API key" on the API keys page. '
                'If prompted, select "Create API key in new project" — '
                'the defaults are fine.',
          ),
          _StepTile(
            number: '5',
            title: 'Copy and paste below',
            subtitle:
                'The key starts with "AIza..." — copy it, then '
                'use the paste button or paste it manually.',
            trailing: hasKey
                ? Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        _isEphemeral
                            ? 'Key set for this session'
                            : 'Key saved',
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ],
                  )
                : null,
          ),
          const SizedBox(height: 20),

          // ---- Key input ----
          TextField(
            controller: _keyCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Gemini API Key',
              hintText: 'AIza...',
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.content_paste, size: 20),
                    tooltip: 'Paste from clipboard',
                    onPressed: _pasteFromClipboard,
                  ),
                  IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        size: 20),
                    tooltip: _obscure ? 'Show API key' : 'Hide API key',
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ],
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saving || _keyCtrl.text.trim().isEmpty ? null : _save,
            icon: _saving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: Semantics(
                      label: 'Loading',
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.check),
            label: Text(_isEphemeral
                ? 'Use Key for This Session'
                : 'Save API Key'),
          ),
          const SizedBox(height: 24),

          // ---- Privacy notice ----
          Card(
            color: cs.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.privacy_tip,
                          size: 18, color: cs.onErrorContainer),
                      const SizedBox(width: 8),
                      Text('Privacy Notice',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: cs.onErrorContainer)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'On the Gemini free tier, Google may use data you send '
                    'to improve their AI products, and human reviewers may '
                    'read your inputs.\n\n'
                    'The AI features in this app send text you enter in form '
                    'fields and chat messages to Google\'s servers. '
                    'Do not include personally identifying details (full '
                    'legal name, Social Security number, date of birth, etc.) '
                    'in AI chat or when using AI Suggest.\n\n'
                    '${_isEphemeral ? 'Your API key is held in memory only and will be '
                        'discarded when this session ends. It is never '
                        'written to disk.' : 'Your API key is stored securely on this device only and '
                        'is never shared with anyone other than Google.'}',
                    style: TextStyle(fontSize: 12, color: cs.onErrorContainer),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ---- Security info ----
          Card(
            color: cs.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 18, color: cs.primary),
                      const SizedBox(width: 8),
                      Text('How Your Data Is Handled',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: cs.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '- Your directive data is stored locally on your device\n'
                    '- AI features are optional and the app works without them\n'
                    '- Only text you explicitly send via AI chat or AI Suggest '
                    'leaves your device\n'
                    '- This app is not a medical or legal service\n'
                    '- This app is not HIPAA-compliant',
                    style: TextStyle(fontSize: 12, color: cs.onSurface),
                  ),
                ],
              ),
            ),
          ),

          // ---- FAQ section ----
          const SizedBox(height: 24),
          Text('Common Questions',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const _FaqTile(
            question: 'Is the API key really free?',
            answer:
                'Yes. Google offers a generous free tier for Gemini. '
                'There is no credit card required and no charge for '
                'typical personal use.',
          ),
          const _FaqTile(
            question: 'What Google account should I use?',
            answer:
                'Any Google account works — a personal Gmail is fine. '
                'You do not need a Google Cloud billing account.',
          ),
          const _FaqTile(
            question: 'Can I revoke the key later?',
            answer:
                'Yes. Visit aistudio.google.com/apikey at any time to '
                'delete or regenerate your key. You can also remove it '
                'from this app using the trash icon in the top-right.',
          ),
          const _FaqTile(
            question: 'What if I don\'t add a key?',
            answer:
                'The app works fully without AI. The form wizard, PDF '
                'generation, educational content, and all other features '
                'do not require an API key. AI is purely optional.',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String number;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _StepTile({
    required this.number,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: cs.primary,
            child: Text(number,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: cs.onSurfaceVariant,
                          height: 1.3)),
                ],
                if (trailing != null) ...[
                  const SizedBox(height: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrowserShortcut extends StatelessWidget {
  final String browser;
  final String shortcut;
  final String macShortcut;
  final Color color;

  const _BrowserShortcut({
    required this.browser,
    required this.shortcut,
    required this.macShortcut,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Show both shortcuts since we don't know the user's OS on web
    final text = shortcut.isNotEmpty
        ? '$browser:  $shortcut  (Mac: $macShortcut)'
        : '$browser:  $macShortcut  (Mac only)';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Text('\u2022 ', style: TextStyle(color: color, fontSize: 13)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontFamily: 'monospace',
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
        title: Text(question,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        children: [
          Text(answer,
              style: TextStyle(
                  fontSize: 12.5, color: cs.onSurfaceVariant, height: 1.4)),
        ],
      ),
    );
  }
}
