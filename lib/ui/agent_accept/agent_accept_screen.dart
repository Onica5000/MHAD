import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';

/// Agent-acceptance log screen.
///
/// Repurposes the prototype `ScrAgentAccept` (gap-analysis.jsx L1178-1263)
/// per user decision (2026-06-02): instead of an online "agent receives
/// a link, taps acknowledgments, signs digitally" receipt, this screen
/// lets the principal record that each agent verbally accepted in person.
///
/// For each agent on the directive (primary + alternate when present):
///   - **Logged**: editorial "[Name] is now your agent." confirmation
///     card with timestamp, optional notes, "Edit" / "Clear" controls.
///   - **Not yet logged**: plain card with a "Log acceptance" CTA that
///     opens a date + notes dialog.
///
/// The acceptance is local-only — no email/SMS/server. The schema fields
/// (`Agents.acceptedAt`, `Agents.acceptanceNotes`) were added in schema
/// v11; both default to "not logged" so existing directives are unaffected.
class AgentAcceptScreen extends ConsumerStatefulWidget {
  final int directiveId;
  const AgentAcceptScreen({required this.directiveId, super.key});

  @override
  ConsumerState<AgentAcceptScreen> createState() => _AgentAcceptScreenState();
}

class _AgentAcceptScreenState extends ConsumerState<AgentAcceptScreen> {
  List<Agent> _agents = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final repo = ref.read(directiveRepositoryProvider);
    final list = await repo.getAgents(widget.directiveId);
    if (!mounted) return;
    // Sort: primary first.
    list.sort((a, b) => a.agentType.compareTo(b.agentType));
    setState(() {
      _agents = list;
      _loading = false;
    });
  }

  Future<void> _editAcceptance(Agent agent) async {
    final repo = ref.read(directiveRepositoryProvider);
    final initial = agent.acceptedAt == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(agent.acceptedAt!);
    final result = await showDialog<_AcceptanceResult>(
      context: context,
      builder: (_) => _LogAcceptanceDialog(
        agent: agent,
        initialDate: initial,
        initialNotes: agent.acceptanceNotes,
      ),
    );
    if (result == null || !mounted) return;
    await repo.updateAgentAcceptance(
      agent.id,
      acceptedAt: result.cleared ? null : result.date,
      notes: result.cleared ? '' : result.notes,
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      // Prototype ScrAgentAccept (gap-analysis.jsx L1178-1263) uses
      // CrisisBar + in-body back chevron. The 'Manual acceptance log'
      // section label + body lead own the visual title.
      body: Column(children: [
        const CrisisTopBar(compact: true),
        WizardHeader(
          backLabel: 'Back',
          onBack: () => Navigator.of(context).maybePop(),
          actionLabel: '',
        ),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _agents.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      'No agents on this directive yet. Add a primary '
                      '(and optional alternate) in step 3 of the wizard.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: p.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                  children: [
                    const SectionLabel('Manual acceptance log'),
                    const SizedBox(height: 4),
                    Text(
                      'Record that each agent verbally accepted the role. '
                      'Local only — no link is sent to the agent.',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13.5,
                        color: p.textMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    for (final a in _agents)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _AgentAcceptanceCard(
                          agent: a,
                          onEdit: () => _editAcceptance(a),
                        ),
                      ),
                  ],
                )),
      ]),
    );
  }
}

class _AcceptanceResult {
  final DateTime date;
  final String notes;
  final bool cleared;
  const _AcceptanceResult({
    required this.date,
    required this.notes,
    this.cleared = false,
  });
}

class _AgentAcceptanceCard extends StatelessWidget {
  final Agent agent;
  final VoidCallback onEdit;
  const _AgentAcceptanceCard({required this.agent, required this.onEdit});

  String _initials(String name) {
    final parts =
        name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '—';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String _firstName(String name) {
    final t = name.trim();
    if (t.isEmpty) return 'Your agent';
    return t.split(RegExp(r'\s+')).first;
  }

  String _kindLabel() {
    return agent.agentType == 'primary'
        ? 'Primary agent'
        : 'Alternate agent';
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accepted = agent.acceptedAt != null;
    final dateLabel = accepted
        ? DateFormat('EEE MMM d, y · h:mm a').format(
            DateTime.fromMillisecondsSinceEpoch(agent.acceptedAt!))
        : '';
    final okBg =
        dark ? SemanticColors.successBgDark : SemanticColors.successBgLight;
    final okText = dark
        ? SemanticColors.successTextDark
        : SemanticColors.successTextLight;

    return Container(
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: agent.agentType == 'primary'
                      ? p.primary
                      : p.primaryLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(agent.fullName),
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: agent.agentType == 'primary'
                        ? p.onPrimary
                        : p.onPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent.fullName.isEmpty
                          ? '— unnamed —'
                          : agent.fullName,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    Text(
                      [
                        _kindLabel(),
                        if (agent.relationship.isNotEmpty)
                          agent.relationship,
                      ].join(' · '),
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: p.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (accepted)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: okBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ACCEPTED',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace',
                      ],
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: okText,
                    ),
                  ),
                ),
            ],
          ),
          if (accepted) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              '${_firstName(agent.fullName)} is now your agent.',
              style: const TextStyle(
                fontFamily: 'Instrument Serif',
                fontFamilyFallback: ['Georgia', 'serif'],
                fontStyle: FontStyle.italic,
                fontSize: 26,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.4,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.event_outlined, size: 14, color: p.textMuted),
                const SizedBox(width: 6),
                Text(
                  dateLabel,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: p.textMuted,
                  ),
                ),
              ],
            ),
            if (agent.acceptanceNotes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  agent.acceptanceNotes,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: p.text,
                    height: 1.45,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 14),
            Text(
              'No acceptance recorded.',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: p.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.check_circle_outline, size: 17),
                label: const Text('Log acceptance'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LogAcceptanceDialog extends StatefulWidget {
  final Agent agent;
  final DateTime initialDate;
  final String initialNotes;
  const _LogAcceptanceDialog({
    required this.agent,
    required this.initialDate,
    required this.initialNotes,
  });

  @override
  State<_LogAcceptanceDialog> createState() => _LogAcceptanceDialogState();
}

class _LogAcceptanceDialogState extends State<_LogAcceptanceDialog> {
  late DateTime _date;
  late TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
    _notes = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        // Preserve the time-of-day from the previous value.
        _date = DateTime(picked.year, picked.month, picked.day, _date.hour,
            _date.minute);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(
            _date.year, _date.month, _date.day, picked.hour, picked.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dateLabel = DateFormat('EEE MMM d, y').format(_date);
    final timeLabel = DateFormat('h:mm a').format(_date);
    return AlertDialog(
      title: const Text('Log agent acceptance'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.agent.fullName.isEmpty
                  ? 'When did this agent accept the role?'
                  : 'When did ${widget.agent.fullName} accept the role?',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13.5,
                color: p.textMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event, size: 16),
                    label: Text(dateLabel),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time, size: 16),
                    label: Text(timeLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'How it went, what was discussed, etc.',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        if (widget.agent.acceptedAt != null)
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              _AcceptanceResult(
                date: _alwaysNow, // dummy; cleared=true means it's ignored
                notes: '',
                cleared: true,
              ),
            ),
            child: Text(
              'Clear',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _AcceptanceResult(date: _date, notes: _notes.text.trim()),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// A sentinel "always now" DateTime used only for the "Clear" path. The
// caller checks `cleared` first and never reads `date` when cleared.
final DateTime _alwaysNow = DateTime(1970);
