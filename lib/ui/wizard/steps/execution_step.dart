import 'dart:convert';
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
import 'package:mhad/utils/platform_utils.dart';
import 'package:signature/signature.dart';

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

  // Signature controllers are initialized in initState so we can access theme
  late final SignatureController _principalSigController;
  late final SignatureController _w1SigController;
  late final SignatureController _w2SigController;

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
    // Use post-frame callback to access theme for signature pad colors
    _principalSigController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _w1SigController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _w2SigController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _principalSigController.dispose();
    _w1NameCtrl.dispose();
    _w1AddressCtrl.dispose();
    _w1SigController.dispose();
    _w2NameCtrl.dispose();
    _w2AddressCtrl.dispose();
    _w2SigController.dispose();
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
    if (_executionDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an execution date')),
        );
      }
      return false;
    }
    if (_w1NameCtrl.text.trim().isEmpty ||
        _w2NameCtrl.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Both witness names are required')),
        );
      }
      return false;
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

    // Save witness signatures and info
    Future<void> saveWitness(int number, int? existingId,
        TextEditingController nameCtrl,
        TextEditingController addressCtrl,
        SignatureController sigCtrl) async {
      final sigBytes = await sigCtrl.toPngBytes();
      final sigB64 = sigBytes != null ? base64Encode(sigBytes) : null;
      await repo.upsertWitness(WitnessesCompanion(
        id: existingId != null ? Value(existingId) : const Value.absent(),
        directiveId: Value(widget.directiveId),
        witnessNumber: Value(number),
        fullName: Value(nameCtrl.text.trim()),
        address: Value(addressCtrl.text.trim()),
        signatureBase64: Value(sigB64),
        signatureDate: Value(executionMs),
      ));
    }

    await saveWitness(1, _w1Id, _w1NameCtrl, _w1AddressCtrl, _w1SigController);
    await saveWitness(2, _w2Id, _w2NameCtrl, _w2AddressCtrl, _w2SigController);

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
        const SizedBox(height: 8),
        const WitnessReminderButton(),
        const SizedBox(height: 8),
        // Execution date picker
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Execution date'),
            subtitle: Text(dateStr),
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
        if (_executionDate != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              'This directive will expire on $expirationStr',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        const SizedBox(height: 24),

        // Principal signature
        _SectionHeader(
          title: 'Your signature (Principal)',
          subtitle: 'Sign in the box below',
        ),
        _SignaturePad(controller: _principalSigController),
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
            color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Note: The agent\'s signature is collected on the printed document. '
            'Have your agent review and sign the printed directive.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Witness 1
        _SectionHeader(
          title: 'Witness 1',
          subtitle: 'Must be an adult who is not your agent, healthcare provider, '
              'or facility employee',
        ),
        TextFormField(
          controller: _w1NameCtrl,
          decoration: const InputDecoration(
            labelText: 'Witness 1 full name *',
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
        _SignaturePad(controller: _w1SigController),
        const SizedBox(height: 24),

        // Witness 2
        _SectionHeader(
          title: 'Witness 2',
          subtitle: 'Must meet the same requirements as Witness 1',
        ),
        TextFormField(
          controller: _w2NameCtrl,
          decoration: const InputDecoration(
            labelText: 'Witness 2 full name *',
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
        _SignaturePad(controller: _w2SigController),
        const SizedBox(height: 40),

        // Legal notice
        Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'By tapping "Finish" you confirm that this directive was executed '
              'voluntarily, that you have legal capacity, and that it was signed '
              'in the presence of the two witnesses listed above. '
              'This app does not constitute legal advice.',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onErrorContainer),
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
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15)),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _SignaturePad extends StatefulWidget {
  final SignatureController controller;
  const _SignaturePad({required this.controller});

  @override
  State<_SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<_SignaturePad> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Use a light surface for the signing area so ink is always visible,
    // while adapting to the theme rather than forcing pure white.
    final padBackground = cs.surfaceContainerLowest;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(8),
        color: padBackground,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            MouseRegion(
              cursor: platformIsDesktop
                  ? SystemMouseCursors.precise
                  : MouseCursor.defer,
              child: Signature(
                controller: widget.controller,
                height: 150,
                backgroundColor: padBackground,
              ),
            ),
            Positioned(
              right: 4,
              top: 4,
              child: IconButton(
                icon: const Icon(Icons.clear, size: 18),
                tooltip: 'Clear signature',
                onPressed: () =>
                    setState(() => widget.controller.clear()),
                style: IconButton.styleFrom(
                  backgroundColor: cs.surfaceContainerHighest,
                  minimumSize: const Size(48, 48),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Sign here',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

