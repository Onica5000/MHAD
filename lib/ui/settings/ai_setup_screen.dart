import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/ai/llm_client.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/ui/widgets/design/labeled_spinner.dart';
import 'package:mhad/ui/widgets/friendly_error.dart';
import 'package:mhad/utils/platform_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen setup for the Gemini API key with step-by-step instructions.
///
/// In **private mode**, the key is stored in flutter_secure_storage and
/// persists across sessions.
///
/// In **public mode** (or web), the key is held in memory only and is
/// automatically discarded when the app closes or the session ends.
class AiSetupScreen extends ConsumerStatefulWidget {
  /// Where to go after the key is saved. When set (e.g. arriving from the
  /// snap-to-fill `/upload` page), saving navigates here instead of just
  /// popping — so the user lands back where they started rather than in the
  /// assistant chat.
  final String? returnRoute;
  const AiSetupScreen({this.returnRoute, super.key});

  @override
  ConsumerState<AiSetupScreen> createState() => _AiSetupScreenState();
}

class _AiSetupScreenState extends ConsumerState<AiSetupScreen> {
  final _keyCtrl = TextEditingController();
  bool _saving = false;
  bool _obscure = true;
  late AiProvider _provider;
  late String _model;

  // Connection-test state.
  bool _testing = false;
  bool _testOk = false;
  String? _testResult;

  bool get _isEphemeral => isEphemeralApiKeyMode(ref);

  @override
  void initState() {
    super.initState();
    _provider = ref.read(activeProviderProvider);
    _model = ref.read(activeModelProvider);
    _prefillKeyFor(_provider);
  }

  /// Pre-fill the key field with the stored key for [p] (private mode only; in
  /// ephemeral mode the key isn't surfaced back into the field).
  void _prefillKeyFor(AiProvider p) {
    final existing = ref.read(aiPrefsProvider).value?.keys[p];
    _keyCtrl.text = (!_isEphemeral && existing != null) ? existing : '';
  }

  void _onProviderChanged(AiProvider p) {
    setState(() {
      _provider = p;
      _model = ref.read(aiPrefsProvider).value?.modelFor(p) ??
          p.currentDefault;
      _prefillKeyFor(p);
      _obscure = true;
    });
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

    // Basic per-provider format validation (a real key always passes).
    if (!_provider.looksLikeKey(key)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              context.l10n.aiSetupThatDoesnTLookLike(_provider.label, _provider.keyHint)),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    await setActiveProvider(ref, _provider);
    await setActiveModel(ref, _model);
    await saveApiKey(ref, key, provider: _provider);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEphemeral
              ? context.l10n.aiSetupApiKeySetForThis
              : context.l10n.aiSetupApiKeySaved),
        ),
      );
      final ret = widget.returnRoute;
      if (ret != null && ret.isNotEmpty) {
        // Came from a specific page (e.g. /upload) — go back there.
        context.go(ret);
      } else if (context.canPop()) {
        // Pushed on top of another page — return to it.
        context.pop();
      } else {
        // Reached via a stack-replacing `go` (e.g. the sidebar) — there is
        // nothing to pop, so Navigator.pop would blank the page. Navigate to a
        // real route and let the router's redirect place the user correctly
        // (e.g. onto the "In your words" onboarding intro if it isn't done).
        context.go(AppRoutes.home);
      }
    }
  }

  /// Sends one tiny real request with the key/model currently typed in, and
  /// reports exactly what came back.
  ///
  /// Without this the first sign that a key was wrong, expired, or pointed at a
  /// retired model was a failed action somewhere deep in the app — reported, at
  /// the time, as "please try again later". A round trip here costs one request
  /// and turns an unexplained dead end into a specific, fixable message.
  Future<void> _testConnection() async {
    final key = _keyCtrl.text.trim();
    if (key.isEmpty) return;
    setState(() {
      _testing = true;
      _testResult = null;
      _testOk = false;
    });
    final client = LlmClient(
      provider: _provider,
      model: _provider.resolveModel(_model),
      apiKey: key,
    );
    try {
      // Minimal prompt + tiny output cap: enough to prove the key, model and
      // network path all work, without burning quota.
      await client.generateText(
        context.l10n.aiSetupReplyWithTheSingleWord,
        timeout: const Duration(seconds: 20),
        maxOutputTokens: 16,
      );
      if (!mounted) return;
      setState(() {
        _testOk = true;
        _testResult = context.l10n.aiSetupTestOk(_provider.label);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testOk = false;
        _testResult = FriendlyError.from(e, context.l10n);
      });
    } finally {
      client.dispose();
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.aiSetupRemoveApiKey),
        content: Text(
            context.l10n.aiSetupAiFeaturesWillBeDisabled),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.pickRemove)),
        ],
      ),
    );
    if (confirmed == true) {
      await deleteApiKey(ref, provider: _provider);
      _keyCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.aiSetupApiKeyRemoved)),
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
          SnackBar(
              content: Text(
                  context.l10n.aiSetupCouldNotPasteTryPasting(pasteShortcutLabel))),
        );
      }
    }
  }

  /// Where to create a key for the selected provider. Gemini uses the
  /// admin-updatable app_data URL; others use the provider's console URL.
  Uri get _getKeyUri => Uri.parse(_provider == AiProvider.gemini
      ? appData.geminiApiKeyUrl
      : _provider.getKeyUrl);

  /// Short example of the selected provider's key shape (field hint).
  String get _keyExample => switch (_provider) {
        AiProvider.gemini => 'AIza...',
        AiProvider.anthropic => 'sk-ant-...',
        AiProvider.openai => 'sk-...',
        AiProvider.grok => 'xai-...',
      };

  /// Provider-aware privacy-notice body.
  String get _privacyNotice {
    final lead = _provider == AiProvider.gemini
        ? context.l10n.aiSetupPrivacyLeadGemini
        : context.l10n.aiSetupPrivacyLeadOther(_provider.label);
    final keyLine = _isEphemeral
        ? context.l10n.aiSetupPrivacyKeyEphemeral
        : context.l10n.aiSetupPrivacyKeyStored;
    return context.l10n.aiSetupPrivacyNoticeBody(lead, keyLine);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Whether the SELECTED provider (not necessarily the active one) has a key.
    final hasKey =
        ref.watch(aiPrefsProvider).value?.keys[_provider]?.isNotEmpty ??
            false;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.aiSetupAiAssistantSetup),
        actions: [
          if (hasKey)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: context.l10n.aiSetupRemoveApiKey2,
              onPressed: _delete,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
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
                        context.l10n.aiSetupYourApiKeyWillNot,
                        style: TextStyle(
                            fontSize: 13,
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

          // ---- Provider + model ----
          _ProviderModelPicker(
            provider: _provider,
            model: _model,
            onProviderChanged: _onProviderChanged,
            onModelChanged: (m) => setState(() => _model = m),
          ),
          const SizedBox(height: 16),

          // ---- Web/CORS caveat for providers that browsers tend to block ----
          if (kIsWeb && !_provider.worksInBrowser) ...[
            Card(
              color: cs.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.public_off,
                        size: 20, color: cs.onErrorContainer),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.l10n.aiSetupMayBeBlockedByYour(_provider.label),
                        style: TextStyle(
                            fontSize: 13,
                            color: cs.onErrorContainer,
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
          Text(
              _provider == AiProvider.gemini
                  ? context.l10n.aiSetupGetYourFreeGeminiApi
                  : context.l10n.aiSetupAddYourApiKey(_provider.label),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            _provider == AiProvider.gemini
                ? context.l10n.aiSetupTheAssistantUsesGoogleS
                : context.l10n.aiSetupYouBringYourOwnApi(_provider.label),
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
                          context.l10n.aiSetupStep1OpenAPrivate,
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
                    context.l10n.aiSetupYouLlNeedToSign,
                    style: TextStyle(
                        fontSize: 13, color: cs.onErrorContainer,
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
                  _BrowserShortcut(
                    browser: 'DuckDuckGo',
                    shortcut: context.l10n.aiSetupDuckDuckGoNote,
                    macShortcut: '',
                    color: cs.onErrorContainer,
                    isNote: true,
                  ),
                  _BrowserShortcut(
                    browser: 'Comet',
                    shortcut: 'Ctrl + Shift + N',
                    macShortcut: '\u2318 + Shift + N',
                    color: cs.onErrorContainer,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.aiSetupOnAPhoneTapThe,
                    style: TextStyle(
                        fontSize: 12, color: cs.onErrorContainer,
                        fontStyle: FontStyle.italic, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.aiSetupYourGoogleLoginWillBe,
                    style: TextStyle(
                        fontSize: 13, color: cs.onErrorContainer,
                        fontWeight: FontWeight.w600, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ---- Step 2: Open the provider's key page ----
          _StepTile(
            number: '2',
            title: _provider == AiProvider.gemini
                ? context.l10n.aiSetupOpenGoogleAiStudioIn
                : context.l10n.aiSetupOpenInYourPrivateWindow(_provider.label),
            subtitle: _provider == AiProvider.gemini
                ? context.l10n.aiSetupUseAnyGoogleAccountPersonal
                : context.l10n.aiSetupSignInThenOpenThe,
            trailing: OutlinedButton.icon(
              onPressed: () => launchUrl(_getKeyUri,
                  mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(_provider == AiProvider.gemini
                  ? context.l10n.aiSetupOpenAiStudio
                  : context.l10n.aiSetupOpen(_provider.label)),
            ),
          ),
          _StepTile(
            number: '3',
            title: _provider == AiProvider.gemini
                ? context.l10n.aiSetupSignInWithGoogle
                : context.l10n.aiSetupSignInTo(_provider.label),
            subtitle: _provider == AiProvider.gemini
                ? context.l10n.aiSetupNoCreditCardOrPayment
                : context.l10n.aiSetupMostProvidersRequireAPaid,
          ),
          _StepTile(
            number: '4',
            title: context.l10n.aiSetupCreateAnApiKey,
            subtitle: context.l10n.aiSetupCreateANewApiKey,
          ),
          _StepTile(
            number: '5',
            title: context.l10n.aiSetupCopyAndPasteBelow,
            subtitle:
                context.l10n.aiSetupTheKeyLooksLikeCopy(_provider.keyHint),
            trailing: hasKey
                ? Builder(builder: (context) {
                    final success = SemanticColors.successText(
                        Theme.of(context).brightness);
                    return Row(
                      children: [
                        Icon(Icons.check_circle, color: success, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _isEphemeral
                              ? context.l10n.aiSetupKeySetForThisSession
                              : context.l10n.aiSetupKeySaved,
                          style: TextStyle(
                              color: success,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ],
                    );
                  })
                : null,
          ),
          const SizedBox(height: 20),

          // ---- Key input ----
          TextField(
            controller: _keyCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: context.l10n.aiSetupApiKey(_provider.label),
              hintText: _keyExample,
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.content_paste, size: 20),
                    tooltip: context.l10n.aiSetupPasteFromClipboard,
                    onPressed: _pasteFromClipboard,
                  ),
                  IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        size: 20),
                    tooltip: _obscure ? context.l10n.aiSetupShowApiKey : context.l10n.aiSetupHideApiKey,
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
                      label: context.l10n.reviewStepLoading,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.check),
            label: Text(_isEphemeral
                ? context.l10n.aiSetupUseKeyForThisSession
                : context.l10n.aiSetupSaveApiKey),
          ),
          const SizedBox(height: 8),

          // ---- Test connection ----
          // Verifies key + model + reachability before the user relies on it.
          OutlinedButton.icon(
            onPressed:
                _testing || _keyCtrl.text.trim().isEmpty ? null : _testConnection,
            icon: _testing
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: LabeledSpinner(
                        label: context.l10n.aiSetupTestingConnection, strokeWidth: 2),
                  )
                : const Icon(Icons.wifi_tethering),
            label: Text(_testing ? context.l10n.aiSetupTesting : context.l10n.aiSetupTestConnection),
          ),
          if (_testResult != null) ...[
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: DesignCard(
                variant: _testOk
                    ? DesignCardVariant.surface
                    : DesignCardVariant.error,
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _testOk ? Icons.check_circle_outline : Icons.error_outline,
                      size: 18,
                      color: _testOk
                          ? SemanticColors.successText(
                              Theme.of(context).brightness)
                          : cs.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                      Text(context.l10n.aiSetupPrivacyNotice,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: cs.onErrorContainer)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _privacyNotice,
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
                      Text(context.l10n.aiSetupHowYourDataIsHandled,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: cs.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.aiSetupYourDirectiveDataIsHeld,
                    style: TextStyle(fontSize: 12, color: cs.onSurface),
                  ),
                ],
              ),
            ),
          ),

          // ---- FAQ section (Gemini-specific) ----
          if (_provider == AiProvider.gemini) ...[
          const SizedBox(height: 24),
          Text(context.l10n.aiSetupCommonQuestions,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _FaqTile(
            question: context.l10n.aiSetupIsTheApiKeyReally,
            answer:
                context.l10n.aiSetupYesGoogleOffersAGenerous,
          ),
          _FaqTile(
            question: context.l10n.aiSetupWhatGoogleAccountShouldI,
            answer:
                context.l10n.aiSetupAnyGoogleAccountWorksA,
          ),
          _FaqTile(
            question: context.l10n.aiSetupCanIRevokeTheKey,
            answer:
                context.l10n.aiSetupYesVisitAistudioGoogleCom,
          ),
          _FaqTile(
            question: context.l10n.aiSetupWhatIfIDonT,
            answer:
                context.l10n.aiSetupTheAppWorksFullyWithout,
          ),
          ],
          const SizedBox(height: 40),
        ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Provider + model selector at the top of the setup screen. Switching the
/// provider swaps the key field, validation, instructions, and model list.
class _ProviderModelPicker extends StatelessWidget {
  final AiProvider provider;
  final String model;
  final ValueChanged<AiProvider> onProviderChanged;
  final ValueChanged<String> onModelChanged;

  const _ProviderModelPicker({
    required this.provider,
    required this.model,
    required this.onProviderChanged,
    required this.onModelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Picker options come from the admin-updatable app_data list (falling back
    // to the hardcoded set). The active model may not be in it (e.g. a Gemini id
    // set via app_data) — include it so the dropdown can render the selection.
    final curated = provider.availableModels;
    final models = <String>[
      ...curated,
      if (!curated.contains(model)) model,
    ];
    return Card(
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<AiProvider>(
              initialValue: provider,
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: context.l10n.adminUpdateAiProvider,
              ),
              items: [
                for (final p in AiProvider.values)
                  DropdownMenuItem(
                    value: p,
                    child: Text(p == AiProvider.gemini
                        ? context.l10n.aiSetupProviderFree(p.label)
                        : p.label),
                  ),
              ],
              onChanged: (p) {
                if (p != null) onProviderChanged(p);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: models.contains(model) ? model : models.first,
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: context.l10n.adminUpdateModel,
              ),
              items: [
                for (final m in models)
                  DropdownMenuItem(value: m, child: Text(m)),
              ],
              onChanged: (m) {
                if (m != null) onModelChanged(m);
              },
            ),
          ],
        ),
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
                          fontSize: 13,
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
  final bool isNote;

  const _BrowserShortcut({
    required this.browser,
    required this.shortcut,
    required this.color,
    this.macShortcut = '',
    this.isNote = false,
  });

  @override
  Widget build(BuildContext context) {
    final String text;
    if (isNote) {
      text = '$browser:  $shortcut';
    } else if (shortcut.isNotEmpty && macShortcut.isNotEmpty) {
      text = context.l10n.aiSetupShortcutWithMac(browser, shortcut, macShortcut);
    } else if (macShortcut.isNotEmpty) {
      text = context.l10n.aiSetupShortcutMacOnly(browser, macShortcut);
    } else {
      text = '$browser:  $shortcut';
    }
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
                fontFamily: isNote ? null : 'monospace',
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
                  fontSize: 13, color: cs.onSurfaceVariant, height: 1.4)),
        ],
      ),
    );
  }
}
