import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/admin_update_service.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  AdminDataTarget _target = AdminDataTarget.appData;
  Map<String, dynamic> _base = const {};
  Map<String, dynamic> _backup = const {};
  List<ProposedChange> _changes = const [];
  String _output = '';
  bool _loading = false;
  bool _isRevert = false;
  String? _error;

  // The roll-back backup is stored in SharedPreferences keyed per target. It is
  // INTENTIONALLY persistent across sessions (it survives closing the page —
  // on web it lives in localStorage) so a roll-back is available later. It is
  // admin-only (behind the passphrase gate) and holds only app config/content
  // — no user PII or protected data — so it is exempt from the app's ephemeral
  // session-clearing. Do not wipe it on session end.
  static String _backupKey(AdminDataTarget t) => 'admin_backup_${t.name}';

  @override
  void dispose() {
    _passCtrl.dispose();
    _requestCtrl.dispose();
    _focusCtrl.dispose();
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
    final key = ref.read(apiKeyProvider).valueOrNull;
    if (key == null || key.isEmpty) {
      setState(() => _error = 'Set up the AI (API key) first.');
      return;
    }
    if (_requestCtrl.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _isRevert = false;
    });
    try {
      // Load the base for the SELECTED target so paths + emitted file match.
      _base = await AdminUpdateService.currentData(_target);
      final raw = await AdminUpdateService(apiKey: key).draftRaw(
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

  Future<void> _build() async {
    final updated = _isRevert
        ? AdminUpdateService.applyRestore(_base, _backup, _changes)
        : AdminUpdateService.applyApproved(_base, _changes);
    // Stash the pre-change version as a backup so this (and a future) change
    // can be rolled back — the file is committed to the repo; this is the
    // in-app safety net. Keyed per target.
    await _saveBackup(_target, _base);
    setState(() {
      _output = AdminUpdateService.prettyJson(updated);
      _stage = _Stage.output;
    });
  }

  Future<void> _saveBackup(AdminDataTarget t, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_backupKey(t), AdminUpdateService.prettyJson(data));
    } catch (_) {
      // Non-fatal: a missing backup just means revert is unavailable.
    }
  }

  /// Start a roll-back: load the saved backup for the current target, diff it
  /// against the live file, and present each differing field so the maintainer
  /// can pick WHICH part(s) to restore (not just whole-file). The backup is
  /// admin-only (behind the gate) and never user-facing.
  Future<void> _revert() async {
    String? backupStr;
    try {
      final prefs = await SharedPreferences.getInstance();
      backupStr = prefs.getString(_backupKey(_target));
    } catch (_) {
      backupStr = null;
    }
    if (backupStr == null || backupStr.isEmpty) {
      setState(() => _error =
          'No backup for ${_target.label} yet — a backup is saved each time '
          'you build an update for this file.');
      return;
    }
    try {
      _backup =
          jsonDecode(backupStr) as Map<String, dynamic>; // previous version
      _base = await AdminUpdateService.currentData(_target); // live version
      final diff = AdminUpdateService.diffForRestore(_base, _backup,
          target: _target);
      if (diff.isEmpty) {
        setState(() => _error =
            'The live ${_target.assetPath} already matches the backup — '
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
          TextField(
            controller: _requestCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'e.g. "The Trevor Project number changed to ..." or '
                  '"Check Gemini\'s current free-tier rate limits"',
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
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _loading ? null : _draft,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome),
                label: Text(_loading ? 'Drafting…' : 'Draft with AI'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _loading ? null : _revert,
                icon: const Icon(Icons.history),
                label: const Text('Revert'),
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
