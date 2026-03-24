import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/widgets/contact_picker_button.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class AlternateAgentStep extends ConsumerStatefulWidget {
  const AlternateAgentStep({required this.directiveId, super.key});

  final int directiveId;

  @override
  ConsumerState<AlternateAgentStep> createState() => _AlternateAgentStepState();
}

class _AlternateAgentStepState
    extends ConsumerState<AlternateAgentStep> with WizardStepMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _relationshipCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _homePhoneCtrl = TextEditingController();
  final _workPhoneCtrl = TextEditingController();
  final _cellPhoneCtrl = TextEditingController();

  int? _existingAgentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _relationshipCtrl.dispose();
    _addressCtrl.dispose();
    _homePhoneCtrl.dispose();
    _workPhoneCtrl.dispose();
    _cellPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final agents = await ref
        .read(directiveRepositoryProvider)
        .getAgents(widget.directiveId);
    final alternate =
        agents.where((a) => a.agentType == 'alternate').firstOrNull;
    if (alternate != null && mounted) {
      setState(() {
        _existingAgentId = alternate.id;
        _nameCtrl.text = alternate.fullName;
        _relationshipCtrl.text = alternate.relationship;
        _addressCtrl.text = alternate.address;
        _homePhoneCtrl.text = alternate.homePhone;
        _workPhoneCtrl.text = alternate.workPhone;
        _cellPhoneCtrl.text = alternate.cellPhone;
      });
    }
  }

  @override
  Future<bool> validateAndSave() async {
    _formKey.currentState?.validate();

    // All fields are optional; only save if a name was provided.
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) {
      await ref.read(directiveRepositoryProvider).upsertAgent(
            AgentsCompanion(
              id: _existingAgentId != null
                  ? Value(_existingAgentId!)
                  : const Value.absent(),
              directiveId: Value(widget.directiveId),
              agentType: const Value('alternate'),
              fullName: Value(name),
              relationship: Value(_relationshipCtrl.text.trim()),
              address: Value(_addressCtrl.text.trim()),
              homePhone: Value(_homePhoneCtrl.text.trim()),
              workPhone: Value(_workPhoneCtrl.text.trim()),
              cellPhone: Value(_cellPhoneCtrl.text.trim()),
            ),
          );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const helpText =
        'Your agent must be 18 or older. They cannot be your treating '
        'physician, an employee of your treatment facility (unless a '
        'relative), or someone with financial interest in your estate. '
        'Choose someone you trust to honor your wishes.';

    return Form(
      key: _formKey,
      child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            WizardHelpButton(helpText: helpText, stepId: 'alternateAgent'),
            const SizedBox(height: 8),
            Text(
              'Alternate Agent Designation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your alternate agent acts if your primary agent is unable or '
              'unwilling to serve.',
            ),
            const SizedBox(height: 4),
            const Text(
              'The alternate agent has the same authority as the primary agent '
              'but only steps in when the primary agent cannot act.',
            ),
            const SizedBox(height: 4),
            Text(
              'You are not required to designate an alternate agent.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            ContactPickerButton(
              onContactPicked: (c) => setState(() {
                _nameCtrl.text = c.fullName;
                if (c.address.isNotEmpty) _addressCtrl.text = c.address;
                if (c.homePhone.isNotEmpty) _homePhoneCtrl.text = c.homePhone;
                if (c.workPhone.isNotEmpty) _workPhoneCtrl.text = c.workPhone;
                if (c.cellPhone.isNotEmpty) _cellPhoneCtrl.text = c.cellPhone;
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full name',
                border: OutlineInputBorder(),
              ),
              autofillHints: const [],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _relationshipCtrl,
              decoration: const InputDecoration(
                labelText: 'Relationship',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              autofillHints: const [],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _homePhoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Home phone',
                border: OutlineInputBorder(),
              ),
              autofillHints: const [],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _workPhoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Work phone',
                border: OutlineInputBorder(),
              ),
              autofillHints: const [],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cellPhoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Cell phone',
                border: OutlineInputBorder(),
              ),
              autofillHints: const [],
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      );
  }
}
