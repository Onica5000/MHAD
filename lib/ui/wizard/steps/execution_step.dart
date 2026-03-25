import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/notification_service.dart';
import 'package:mhad/ui/wizard/widgets/witness_reminder_button.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class ExecutionStep extends ConsumerStatefulWidget {
  final int directiveId;
  final FormType formType;
  const ExecutionStep({required this.directiveId, required this.formType, super.key});

  @override
  ConsumerState<ExecutionStep> createState() => _ExecutionStepState();
}

class _ExecutionStepState extends ConsumerState<ExecutionStep>
    with WizardStepMixin {
  DateTime? _executionDate;

  // Witness 1
  final _w1NameCtrl = TextEditingController();
  final _w1AddressCtrl = TextEditingController();
  int? _w1Id;

  // Witness 2
  final _w2NameCtrl = TextEditingController();
  final _w2AddressCtrl = TextEditingController();
  int? _w2Id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _w1NameCtrl.dispose();
    _w1AddressCtrl.dispose();
    _w2NameCtrl.dispose();
    _w2AddressCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(directiveRepositoryProvider);
    final directive = await repo.getDirectiveById(widget.directiveId);
    final witnesses = await repo.getWitnesses(widget.directiveId);

    if (!mounted) return;

    setState(() {
      if (directive?.executionDate != null) {
        _executionDate = DateTime.fromMillisecondsSinceEpoch(
            directive!.executionDate!);
      }
      for (final w in witnesses) {
        if (w.witnessNumber == 1) {
          _w1Id = w.id;
          _w1NameCtrl.text = w.fullName;
          _w1AddressCtrl.text = w.address;
        } else if (w.witnessNumber == 2) {
          _w2Id = w.id;
          _w2NameCtrl.text = w.fullName;
          _w2AddressCtrl.text = w.address;
        }
      }
    });
  }

  @override
  Future<bool> validateAndSave() async {
    // Save whatever is filled in — don't block navigation
    if (_executionDate == null) {
      // Default to today if not selected
      _executionDate = DateTime.now();
    }

    final repo = ref.read(directiveRepositoryProvider);
    final executionMs = _executionDate!.millisecondsSinceEpoch;
    final expirationMs = _executionDate!
        .add(const Duration(days: 365 * 2))
        .millisecondsSinceEpoch;

    // Save execution date and expiration on directive
    final db = ref.read(appDatabaseProvider);
    await (db.update(db.directives)
          ..where((t) => t.id.equals(widget.directiveId)))
        .write(DirectivesCompanion(
      executionDate: Value(executionMs),
      expirationDate: Value(expirationMs),
      status: const Value('complete'),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));

    // Save witness info (signatures affixed on printed original only)
    Future<void> saveWitness(int number, int? existingId,
        TextEditingController nameCtrl,
        TextEditingController addressCtrl) async {
      await repo.upsertWitness(WitnessesCompanion(
        id: existingId != null ? Value(existingId) : const Value.absent(),
        directiveId: Value(widget.directiveId),
        witnessNumber: Value(number),
        fullName: Value(nameCtrl.text.trim()),
        address: Value(addressCtrl.text.trim()),
        signatureDate: Value(executionMs),
      ));
    }

    await saveWitness(1, _w1Id, _w1NameCtrl, _w1AddressCtrl);
    await saveWitness(2, _w2Id, _w2NameCtrl, _w2AddressCtrl);

    // Schedule 2-year expiration reminders
    final expirationDate =
        _executionDate!.add(const Duration(days: 365 * 2));
    await NotificationService.instance.scheduleExpirationReminders(
      widget.directiveId,
      expirationDate,
    );

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _executionDate != null
        ? DateFormat('MMMM d, yyyy').format(_executionDate!)
        : 'Not selected';
    final expirationStr = _executionDate != null
        ? DateFormat('MMMM d, yyyy')
            .format(_executionDate!.add(const Duration(days: 365 * 2)))
        : '—';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        WizardHelpButton(
          helpText:
              'To be valid under PA Act 194, the directive must be signed and dated '
              'by you (the principal) in the presence of two adult witnesses. '
              'Witnesses cannot be: your agent, your healthcare provider, an employee '
              'of your treatment facility (unless a relative), or anyone with a '
              'financial interest in your estate.\n\n'
              'The directive is valid for 2 years from the execution date.',
          stepId: 'execution',
        ),
        const SizedBox(height: 16),

        // ── Execution date ─────────────────────────────────
        Text('Execution Date',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(_executionDate != null ? dateStr : 'Tap to select a date'),
            subtitle: _executionDate != null
                ? Text('Expires: $expirationStr',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant))
                : Text('Defaults to today if not selected',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _executionDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _executionDate = picked);
              }
            },
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // ── Principal signature ────────────────────────────
        _SectionHeader(
          title: 'Your Signature (Principal)',
          subtitle: 'Original ink signatures are required on the printed '
              'document for legal validity under PA Act 194.',
        ),
        const _SignaturePlaceholder(
            label: 'Principal\'s signature to be affixed on original document'),
        const SizedBox(height: 24),

        // Agent acceptance (Combined and POA only)
        if (widget.formType.hasAgentSections) ...[
          _SectionHeader(
            title: 'Agent Acceptance',
            subtitle: 'Your designated agent should review and acknowledge '
                'this section. The agent accepts responsibility to act in '
                'accordance with your wishes using the substituted judgment '
                'standard (deciding as you would decide, not what the agent '
                'thinks is best).',
          ),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'I accept the designation as mental health care agent. I understand '
                'that I have a duty to act consistently with the wishes of the '
                'principal as expressed in this directive. I understand that this '
                'document gives me authority to make mental health care decisions '
                'for the principal only when the principal is unable to make those '
                'decisions. I will not consent to psychosurgery or termination of '
                'parental rights on behalf of the principal.',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Note: The agent\'s signature is collected on the printed document. '
            'Have your agent review and sign the printed directive.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
        ],

        const Divider(),
        const SizedBox(height: 16),

        // ── Witnesses ──────────────────────────────────────
        Text('Witnesses',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          'Two adult witnesses must be present when you sign. '
          'Witnesses cannot be your agent, healthcare provider, '
          'or facility employee (unless a relative).',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        const WitnessReminderButton(),
        const SizedBox(height: 16),

        _SectionHeader(
          title: 'Witness 1',
          subtitle: 'Name and address',
        ),
        TextFormField(
          controller: _w1NameCtrl,
          decoration: const InputDecoration(
            labelText: 'Witness 1 full name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _w1AddressCtrl,
          decoration: const InputDecoration(
            labelText: 'Witness 1 address',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 8),
        const _SignaturePlaceholder(
            label: 'Witness 1 signature to be affixed on original document'),
        const SizedBox(height: 24),

        _SectionHeader(
          title: 'Witness 2',
          subtitle: 'Same requirements as Witness 1',
        ),
        TextFormField(
          controller: _w2NameCtrl,
          decoration: const InputDecoration(
            labelText: 'Witness 2 full name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _w2AddressCtrl,
          decoration: const InputDecoration(
            labelText: 'Witness 2 address',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 8),
        const _SignaturePlaceholder(
            label: 'Witness 2 signature to be affixed on original document'),
        const SizedBox(height: 40),

        const Divider(),
        const SizedBox(height: 8),
        // Legal notice
        Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.gavel, size: 16,
                        color: Theme.of(context).colorScheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Text('Important',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onErrorContainer)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'By proceeding you confirm that:\n'
                  '  \u2022 This directive was executed voluntarily\n'
                  '  \u2022 You have legal capacity to make this directive\n'
                  '  \u2022 The printed document will be signed with original '
                  'ink signatures in the presence of both witnesses\n\n'
                  'All signatures must be affixed to the original printed '
                  'document to be legally valid under PA Act 194.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600)),
          Text(subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Placeholder indicating that a signature will be affixed on the
/// printed original document.
class _SignaturePlaceholder extends StatelessWidget {
  final String label;
  const _SignaturePlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outline, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
        color: cs.surfaceContainerLowest,
      ),
      child: Column(
        children: [
          Icon(Icons.draw_outlined, size: 28, color: cs.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

