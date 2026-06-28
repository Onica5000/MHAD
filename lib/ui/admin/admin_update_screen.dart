import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/admin_backup_store.dart';
import 'package:mhad/services/admin_update_service.dart';
import 'package:mhad/services/federal_register_service.dart';
import 'package:mhad/services/gemini_model_service.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/utils/launch_utils.dart';

/// Hidden, non-user-facing admin tool: the AI drafts updates to the app's
/// dynamic data (app_data.json) WITH sources, a human approves a per-field diff,
/// and the screen emits the updated JSON to commit to the repo. Nothing is
/// mutated at runtime; legal/educational ("verify") changes never pre-approve.
///
/// Reached only via a hidden long-press on Settings → About, behind a
/// passphrase. The passphrase is obscurity (keeps casual users out), NOT a
/// security boundary — the tool only produces text for a human to commit.
class AdminUpdateScreen extends ConsumerStatefulWidget {
  const AdminUpdateScreen({super.key});

  /// Change this before shipping. Obscurity gate, not security.
  static const passphrase = '0000';

  @override
  ConsumerState<AdminUpdateScreen> createState() => _AdminUpdateScreenState();
}

enum _Stage { gate, draft, review, output }

class _AdminUpdateScreenState extends ConsumerState<AdminUpdateScreen> {
  _Stage _stage = _Stage.gate;
  final _passCtrl = TextEditingController();
  final _requestCtrl = TextEditingController();
  final _focusCtrl = TextEditingController();
  // AI provider to draft with + its model and API key (admin-only; the key is
  // entered here, ephemeral to this screen, and never persisted).
  AdminAiProvider _provider = AdminAiProvider.gemini;
  String _model = AdminAiProvider.gemini.defaultModel;
  // Live free-tier Gemini model ids, fetched on demand to refresh the dropdown
  // from the real catalog (null = not fetched; falls back to the curated enum).
  List<String>? _geminiLiveModels;
  final _keyCtrl = TextEditingController();
  AdminDataTarget _target = AdminDataTarget.appData;
  Map<String, dynamic> _base = const {};
  Map<String, dynamic> _backup = const {};
  List<ProposedChange> _changes = const [];
  String _output = '';
  bool _loading = false;
  bool _isRevert = false;
  String? _error;

  @override
  void dispose() {
    _passCtrl.dispose();
    _requestCtrl.dispose();
    _focusCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_passCtrl.text.trim() != AdminUpdateScreen.passphrase) {
      setState(() => _error = 'Incorrect passphrase.');
      return;
    }
    setState(() {
      _error = null;
      _stage = _Stage.draft;
    });
  }

  Future<void> _draft() async {
    // For Gemini, fall back to the app's stored key if the field is blank
    // (preserves the prior behavior); other providers must supply a key here.
    final typedKey = _keyCtrl.text.trim();
    final key = typedKey.isNotEmpty
        ? typedKey
        : (_provider == AdminAiProvider.gemini
            ? (ref.read(apiKeyProvider).valueOrNull ?? '')
            : '');
    if (key.isEmpty) {
      setState(() => _error =
          'Enter the ${_provider.label} API key first (${_provider.keyHint}).');
      return;
    }
    if (_provider == AdminAiProvider.gemini && !isLikelyGeminiKey(key)) {
      setState(() => _error =
          'That doesn\'t look like a Gemini key — it should start with "AIza".');
      return;
    }
    if (_requestCtrl.text.trim().isEmpty) {
      setState(() => _error =
          'Describe the update you want first — type it in the “Describe the '
          'update” box, then tap Draft with AI.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _isRevert = false;
    });
    try {
      // Load the base for the SELECTED target so paths + emitted file match.
      _base = await AdminUpdateService.currentData(_target);
      final raw = await AdminUpdateService(
        apiKey: key,
        provider: _provider,
        model: _model,
      ).draftRaw(
        _requestCtrl.text.trim(),
        _base,
        target: _target,
        focusArea: _focusCtrl.text.trim(),
      );
      final changes = AdminUpdateService.parseProposal(raw, _base);
      setState(() {
        _changes = changes;
        _loading = false;
        _stage = _Stage.review;
        if (changes.isEmpty) {
          _error = 'The AI proposed no changes (it should refuse when unsure).';
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Draft failed: $e';
      });
    }
  }

  /// Refresh the Gemini model dropdown from the live catalog, filtered to the
  /// applicable FREE-tier text models (the app uses Gemini so users pay
  /// nothing). Falls back to the curated enum list if never run.
  Future<void> _refreshGeminiModels() async {
    // Gemini-specific key (NOT the active provider's) — these call Google's
    // ListModels, so an Anthropic/OpenAI key must never be sent here.
    final savedKey =
        (ref.read(aiPrefsProvider).valueOrNull?.keys[AdminAiProvider.gemini] ??
                '')
            .trim();
    final key = savedKey.isNotEmpty ? savedKey : _keyCtrl.text.trim();
    if (key.isEmpty) {
      setState(() => _error =
          'Need a Gemini API key (AIza…) to refresh the model list.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ids = await GeminiModelService(key).freeModelIds();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _geminiLiveModels = ids;
        if (ids.isEmpty) {
          _error = 'No free-tier text models returned by the API.';
        } else if (!ids.contains(_model)) {
          _model = ids.first;
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Refresh failed: $e';
        });
      }
    }
  }

  /// Research the live Gemini catalog and propose switching `ai.model` to the
  /// best available model. Grounds the choice in the ListModels API + a real
  /// test call — so an older model never stays pinned when a better one exists.
  /// Flash is recommended (the app's tier); Pro is offered for accuracy.
  Future<void> _checkGeminiModel() async {
    // Prefer the app's saved Gemini key (correct provider); fall back to a key
    // typed here. Avoids accidentally using an Anthropic/OpenAI key.
    // Gemini-specific key (NOT the active provider's) — these call Google's
    // ListModels, so an Anthropic/OpenAI key must never be sent here.
    final savedKey =
        (ref.read(aiPrefsProvider).valueOrNull?.keys[AdminAiProvider.gemini] ??
                '')
            .trim();
    final key = savedKey.isNotEmpty ? savedKey : _keyCtrl.text.trim();
    if (key.isEmpty) {
      setState(() => _error =
          'Need a Gemini API key (AIza…) — save one in the app or type it above.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _isRevert = false;
    });
    try {
      final base = await AdminUpdateService.currentData(AdminDataTarget.appData);
      final current = ((base['ai'] as Map?)?['model'] ?? '').toString();
      final svc = GeminiModelService(key);
      final rec = await svc.recommend(current);
      if (!mounted) return;
      setState(() => _loading = false);
      if (rec.bestFlash == null && rec.bestPro == null) {
        setState(() => _error = 'No usable text models returned by the API.');
        return;
      }
      final chosen = await _pickModel(rec);
      if (chosen == null || !mounted) return;
      if (chosen.id == current) {
        setState(() => _error = 'Already on $current — nothing to switch.');
        return;
      }
      // Validate the pick with a real call before proposing it.
      setState(() => _loading = true);
      final ok = await svc.validate(chosen.id);
      if (!mounted) return;
      setState(() => _loading = false);
      if (!ok) {
        setState(() =>
            _error = '${chosen.id} failed a test call — not proposing it.');
        return;
      }
      setState(() {
        _target = AdminDataTarget.appData;
        _base = base;
        _changes = [
          ProposedChange(
            path: 'ai.model',
            oldValue: current.isEmpty ? null : current,
            newValue: chosen.id,
            autonomy: 'auto',
            source:
                'Gemini ListModels API (generativelanguage.googleapis.com/v1beta/models) + live generateContent test',
            rationale: _modelReason(rec, chosen),
            approved: true,
          ),
        ];
        _stage = _Stage.review;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Model check failed: $e';
        });
      }
    }
  }

  /// Human-readable reasons for the proposed switch (shown for approval).
  String _modelReason(ModelRecommendation rec, GeminiModel chosen) {
    final tier = chosen.isFlash ? 'Flash' : (chosen.isPro ? 'Pro' : 'model');
    final tokens =
        'context ${chosen.inputTokenLimit} in / ${chosen.outputTokenLimit} out tokens';
    final alt = chosen.isFlash && rec.bestPro != null
        ? ' Pro alternative if Flash accuracy is insufficient (likely a PAID '
            'plan — not free tier): ${rec.bestPro!.id}.'
        : (chosen.isPro && rec.bestFlash != null
            ? ' WARNING: Pro usually needs a paid plan — this breaks the '
                'free-for-users model. Free Flash option: ${rec.bestFlash!.id}.'
            : '');
    return 'Best available $tier model per the live catalog (was ${rec.currentModel}). '
        '$tokens.$alt';
  }

  /// Present the recommended Flash model and the Pro alternative with their
  /// details, returning the maintainer's pick (or null if cancelled).
  Future<GeminiModel?> _pickModel(ModelRecommendation rec) {
    Widget option(String tag, GeminiModel m, String note) => SimpleDialogOption(
          onPressed: () => Navigator.pop(context, m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$tag — ${m.id}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                '${m.displayName}\n$note\ncontext ${m.inputTokenLimit} in / ${m.outputTokenLimit} out',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
    return showDialog<GeminiModel>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Best Gemini model (now: ${rec.currentModel})'),
        children: [
          if (rec.bestFlash != null)
            option('RECOMMENDED · Flash', rec.bestFlash!,
                'Fast, free-tier tier the app is tuned for.'),
          if (rec.bestPro != null)
            option('Alternative · Pro', rec.bestPro!,
                'Most capable — but Pro usually needs a PAID plan (not free '
                'tier). Pick only if Flash accuracy is insufficient.'),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Deterministic, keyless watch over the Federal Register for the FEDERAL
  /// rules the app references (HIPAA, 42 CFR Part 2, advance directives, 988).
  /// Surfaces recent hits with citable URLs so the maintainer can update the
  /// verify-tier `legal`/`dated` facts from an authoritative source. (PA Act
  /// 194 is STATE law and won't appear here.)
  Future<void> _checkFederalRegister() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final svc = FederalRegisterService();
    try {
      final docs = await svc.recentRelevant();
      if (!mounted) return;
      setState(() => _loading = false);
      if (docs.isEmpty) {
        setState(() => _error =
            'No recent Federal Register documents found (or the lookup was '
            'unreachable). This watch covers FEDERAL rules only — PA Act 194 '
            'is state law and is not in the Federal Register.');
        return;
      }
      await _showFederalRegister(docs);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Federal Register check failed: $e';
        });
      }
    } finally {
      svc.dispose();
    }
  }

  /// List the Federal Register hits; each row opens or copies its citable URL
  /// for use as a verify-tier `source`.
  Future<void> _showFederalRegister(List<FederalRegisterDoc> docs) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Federal Register — relevant federal rules'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Federal rules the app references. Use a link as the SOURCE for a '
                'verify-tier legal/dated change. State law (PA Act 194) is not '
                'covered here.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (_, i) {
                    final d = docs[i];
                    final meta = [d.type, d.agencies, d.publicationDate]
                        .where((s) => s.isNotEmpty)
                        .join(' · ');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        if (meta.isNotEmpty)
                          Text(meta,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        if (d.abstract.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              d.abstract,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => launchOrCopy(ctx, d.url),
                              icon: const Icon(Icons.open_in_new, size: 14),
                              label: const Text('Open'),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: d.url));
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                        content: Text('Source link copied')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.copy, size: 14),
                              label: const Text('Copy link'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _build() async {
    final updated = _isRevert
        ? AdminUpdateService.applyRestore(_base, _backup, _changes)
        : AdminUpdateService.applyApproved(_base, _changes);
    // Append the pre-change version to the per-target backup history so this
    // (and any future) change can be rolled back. Snapshots are kept a year,
    // then gzip-archived (see AdminBackupStore). The files are committed to the
    // repo; this is the in-app safety net.
    try {
      await AdminBackupStore.append(
        _target.name,
        AdminUpdateService.prettyJson(_base),
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
      // Non-fatal: a missing backup just means revert is unavailable.
    }
    setState(() {
      _output = AdminUpdateService.prettyJson(updated);
      _stage = _Stage.output;
    });
  }

  /// Start a roll-back: let the maintainer pick WHICH saved snapshot to restore
  /// from (the backup history, newest first; archived ones decompress on
  /// demand), then diff it against the live file so they can pick WHICH
  /// field(s) to roll back. Admin-only (behind the gate), never user-facing.
  Future<void> _revert() async {
    final backups = await AdminBackupStore.list(_target.name);
    if (backups.isEmpty) {
      setState(() => _error =
          'No backups for ${_target.label} yet — one is saved each time you '
          'build an update for this file.');
      return;
    }
    final chosen = await _pickBackup(backups);
    if (chosen == null) return; // cancelled
    try {
      final json = await AdminBackupStore.read(_target.name, chosen.ts);
      if (json == null) {
        setState(() => _error = 'That backup could not be read.');
        return;
      }
      _backup = jsonDecode(json) as Map<String, dynamic>;
      _base = await AdminUpdateService.currentData(_target); // live version
      final diff = AdminUpdateService.diffForRestore(_base, _backup,
          target: _target);
      if (diff.isEmpty) {
        setState(() => _error =
            'The live ${_target.assetPath} already matches that backup — '
            'nothing to restore.');
        return;
      }
      setState(() {
        _error = null;
        _changes = diff;
        _isRevert = true;
        _stage = _Stage.review;
      });
    } catch (e) {
      setState(() => _error = 'Could not read the backup: $e');
    }
  }

  /// Modal list of saved snapshots (newest first; archived ones tagged) so the
  /// maintainer chooses which version to roll back to. Returns null if cancelled.
  Future<BackupEntry?> _pickBackup(List<BackupEntry> backups) {
    return showDialog<BackupEntry>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Restore from which backup?'),
        children: [
          for (final b in backups)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, b),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(b.label)),
                  if (b.archived)
                    const Text('archived',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin · data update')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (_stage) {
          _Stage.gate => _buildGate(),
          _Stage.draft => _buildDraft(),
          _Stage.review => _buildReview(),
          _Stage.output => _buildOutput(),
        },
      ),
    );
  }

  Widget _error_(String? e) => e == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(e,
              style: TextStyle(
                  color: SemanticColors.errorText(
                      Theme.of(context).brightness))),
        );

  Widget _buildGate() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter the admin passphrase.'),
        const SizedBox(height: 12),
        TextField(
          controller: _passCtrl,
          obscureText: true,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'Passphrase'),
          onSubmitted: (_) => _unlock(),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _unlock, child: const Text('Unlock')),
        _error_(_error),
      ],
    );
  }

  Widget _buildDraft() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
              'Describe the update. The AI drafts changes to the selected file '
              'with sources; you review and approve before anything is emitted. '
              'Legal/statutory and educational changes always need your explicit '
              'sign-off.'),
          const SizedBox(height: 12),
          // Which dynamic-data file to edit.
          DropdownButtonFormField<AdminDataTarget>(
            initialValue: _target,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'What to update',
            ),
            items: [
              for (final t in AdminDataTarget.values)
                DropdownMenuItem(value: t, child: Text(t.label)),
            ],
            onChanged: (t) =>
                setState(() => _target = t ?? AdminDataTarget.appData),
          ),
          const SizedBox(height: 12),
          // AI provider — Gemini (bundled), Anthropic Claude, or OpenAI GPT.
          // Admin-only; switching providers just changes which API is called.
          DropdownButtonFormField<AdminAiProvider>(
            initialValue: _provider,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'AI provider',
            ),
            items: [
              for (final p in AdminAiProvider.values)
                DropdownMenuItem(value: p, child: Text(p.label)),
            ],
            onChanged: (p) => setState(() {
              _provider = p ?? AdminAiProvider.gemini;
              // Reset to the new provider's default model.
              _model = _provider.defaultModel;
            }),
          ),
          const SizedBox(height: 12),
          // Model for the chosen provider. For Gemini the list can be refreshed
          // from the live catalog (free-tier text models only); otherwise it's
          // the curated enum defaults.
          Builder(builder: (_) {
            final isGemini = _provider == AdminAiProvider.gemini;
            final live = _geminiLiveModels ?? const [];
            final opts = [
              ...(isGemini && live.isNotEmpty ? live : _provider.models),
            ];
            if (!opts.contains(_model)) opts.insert(0, _model);
            return Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _model,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Model',
                      helperText: isGemini && live.isNotEmpty
                          ? 'Live free-tier models (refreshed from the catalog)'
                          : null,
                    ),
                    items: [
                      for (final m in opts)
                        DropdownMenuItem(value: m, child: Text(m)),
                    ],
                    onChanged: (m) =>
                        setState(() => _model = m ?? _provider.defaultModel),
                  ),
                ),
                if (isGemini) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Refresh free-tier models from the live catalog',
                    onPressed: _loading ? null : _refreshGeminiModels,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ],
            );
          }),
          const SizedBox(height: 12),
          TextField(
            controller: _keyCtrl,
            obscureText: true,
            autofillHints: const [],
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: '${_provider.label} API key',
              hintText: _provider.keyHint,
              helperText: _provider == AdminAiProvider.gemini
                  ? 'Blank = use the app\'s saved Gemini key. Not stored.'
                  : 'Entered for this session only — not stored.',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _requestCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Describe the update *',
              hintText: 'e.g. "The Trevor Project number changed to ..." or '
                  '"Check Gemini\'s current free-tier rate limits"',
              helperText: 'Required — what should the AI draft a change to?',
            ),
          ),
          const SizedBox(height: 12),
          // Optional: point the AI at a specific area/path not otherwise
          // called out (the maintainer can scope the proposal themselves).
          TextField(
            controller: _focusCtrl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Focus area / path (optional)',
              helperText: 'Restrict the AI to one spot, e.g. '
                  '"config.timeoutsSeconds" or "sections.faq_valid".',
            ),
          ),
          const SizedBox(height: 16),
          // PRIMARY action — initiate the AI-drafted update. Full-width so it is
          // unmistakable and can never be clipped by a Row overflow on web.
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _draft,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome),
              label: Text(_loading ? 'Drafting…' : 'Start update with AI'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Secondary actions — wrap (never overflow) on a narrow window.
          // "Check best Gemini model" is a separate maintenance action: it
          // researches the live catalog and proposes switching ai.model to the
          // best free-tier model. It does NOT start a data update.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _loading ? null : _revert,
                icon: const Icon(Icons.history),
                label: const Text('Revert'),
              ),
              OutlinedButton.icon(
                onPressed: _loading ? null : _checkGeminiModel,
                icon: const Icon(Icons.model_training),
                label: const Text('Check best Gemini model'),
              ),
              OutlinedButton.icon(
                onPressed: _loading ? null : _checkFederalRegister,
                icon: const Icon(Icons.gavel),
                label: const Text('Check Federal Register'),
              ),
            ],
          ),
          _error_(_error),
        ],
      ),
    );
  }

  Widget _buildReview() {
    final verifyCount = _changes.where((c) => c.isVerify && !c.approved).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_isRevert
            ? 'Restore from backup: ${_changes.length} field(s) differ from the '
                'previous version of ${_target.assetPath}. Tick the part(s) to '
                'roll back (all pre-ticked = full revert).'
            : '${_changes.length} proposed change(s). '
                'Review each — tick VERIFY items only if you have confirmed them.'),
        _error_(_error),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: _changes.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (_, i) => _changeTile(_changes[i]),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                verifyCount > 0
                    ? '$verifyCount verify-tier change(s) not yet approved'
                    : 'Ready',
                style: TextStyle(
                    color: verifyCount > 0
                        ? SemanticColors.warningText(
                            Theme.of(context).brightness)
                        : SemanticColors.successText(
                            Theme.of(context).brightness)),
              ),
            ),
            FilledButton(
              onPressed: _changes.any((c) => c.approved) ? _build : null,
              child: Text(_isRevert ? 'Build restored JSON' : 'Build updated JSON'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _changeTile(ProposedChange c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: c.isVerify
                    ? SemanticColors.warningBg(Theme.of(context).brightness)
                    : SemanticColors.successBg(Theme.of(context).brightness),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(c.autonomy.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(c.path,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            Checkbox(
              value: c.approved,
              onChanged: (v) => setState(() => c.approved = v ?? false),
            ),
          ],
        ),
        Text('${c.oldValue ?? "(none)"}  →  ${c.newValue}'),
        if (c.source.isNotEmpty)
          Text('Source: ${c.source}',
              style: const TextStyle(fontSize: 12, color: Colors.blue)),
        if (c.rationale.isNotEmpty)
          Text(c.rationale,
              style:
                  const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildOutput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isRevert)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SemanticColors.warningBg(Theme.of(context).brightness),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'RESTORED — the selected field(s) have been rolled back to the '
              'backup. Commit this over ${_target.assetPath} to apply the '
              'roll-back.',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: SemanticColors.warningText(
                      Theme.of(context).brightness)),
            ),
          ),
        Text(
            'Updated ${_target.assetPath}. Replace that file with this and '
            'commit — the release makes it live for everyone.'),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: SingleChildScrollView(
              child: SelectableText(_output,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: _output));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied updated JSON')),
                  );
                }
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy JSON'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => setState(() => _stage = _Stage.draft),
              child: const Text('Another update'),
            ),
          ],
        ),
      ],
    );
  }
}
