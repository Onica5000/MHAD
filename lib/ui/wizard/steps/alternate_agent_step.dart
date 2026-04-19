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
  final _phoneCtrl = TextEditingController();

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
    _phoneCtrl.dispose();
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
        _phoneCtrl.text = [
          alternate.cellPhone,
          alternate.homePhone,
          alternate.workPhone,
        ].firstWhere((p) => p.isNotEmpty, orElse: () => '');
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
              homePhone: const Value(''),
              workPhone: const Value(''),
              cellPhone: Value(_phoneCtrl.text.trim()),
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
                final picked = [c.cellPhone, c.homePhone, c.workPhone]
                    .firstWhere((p) => p.isNotEmpty, orElse: () => '');
                if (picked.isNotEmpty) _phoneCtrl.text = picked;
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
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
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
