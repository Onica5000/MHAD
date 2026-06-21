import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/agent_ext.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/widgets/forms/address_fields.dart';
import 'package:mhad/ui/wizard/widgets/contact_picker_button.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';
import 'package:mhad/utils/input_formatters.dart';

class AgentDesignationStep extends ConsumerStatefulWidget {
  const AgentDesignationStep({
    required this.directiveId,
    this.embedded = false,
    super.key,
  });

  final int directiveId;
  final bool embedded;

  @override
  ConsumerState<AgentDesignationStep> createState() =>
      _AgentDesignationStepState();
}

class _AgentDesignationStepState
    extends ConsumerState<AgentDesignationStep> with WizardStepMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _relationshipCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _address2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
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
    _address2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final agents = await ref
        .read(directiveRepositoryProvider)
        .getAgents(widget.directiveId);
    final primary = agents.primaryAgent;
    if (primary != null && mounted) {
      setState(() {
        _existingAgentId = primary.id;
        _nameCtrl.text = primary.fullName;
        _relationshipCtrl.text = primary.relationship;
        _addressCtrl.text = primary.address;
        _address2Ctrl.text = primary.address2;
        _cityCtrl.text = primary.city;
        _stateCtrl.text = primary.state;
        _zipCtrl.text = primary.zip;
        _phoneCtrl.text = [
          primary.cellPhone,
          primary.homePhone,
          primary.workPhone,
        ].firstWhere((p) => p.isNotEmpty, orElse: () => '');
      });
    }
  }

  @override
  Future<bool> validateAndSave() async {
    // Validate but don't block — always save whatever is entered
    _formKey.currentState?.validate();

    final phone = _phoneCtrl.text.trim();

    await ref.read(directiveRepositoryProvider).upsertAgent(
          AgentsCompanion(
            id: _existingAgentId != null
                ? Value(_existingAgentId!)
                : const Value.absent(),
            directiveId: Value(widget.directiveId),
            agentType: const Value('primary'),
            fullName: Value(_nameCtrl.text.trim()),
            relationship: Value(_relationshipCtrl.text.trim()),
            address: Value(_addressCtrl.text.trim()),
            address2: Value(_address2Ctrl.text.trim()),
            city: Value(_cityCtrl.text.trim()),
            state: Value(_stateCtrl.text.trim()),
            zip: Value(_zipCtrl.text.trim()),
            homePhone: const Value(''),
            workPhone: const Value(''),
            cellPhone: Value(phone),
          ),
        );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const helpText =
        'Your agent must be 18 or older. Under PA Act 194, they cannot be '
        'your mental health care provider or an employee of a mental health '
        'care facility or residential facility where you receive care — '
        'unless they are related to you. Choose someone you trust to '
        'honor your wishes.';

    return Form(
      key: _formKey,
      child: ListView(
          shrinkWrap: widget.embedded,
          physics:
              widget.embedded ? const NeverScrollableScrollPhysics() : null,
          padding: widget.embedded
              ? const EdgeInsets.symmetric(horizontal: 4)
              : const EdgeInsets.all(16),
          children: [
            WizardHelpButton(helpText: helpText, stepId: 'agentDesignation'),
            const SizedBox(height: 8),
            Text(
              'Primary Agent Designation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            // Definition of "agent" lives in the info card below (kept once).
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'An agent (healthcare proxy) is someone you choose to make '
                        'mental health care decisions on your behalf when you cannot.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
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
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Note: Under PA Act 194 \u00a75838, if you designate your '
                        'spouse as your agent, that designation is automatically '
                        'revoked if either spouse files for divorce, unless you '
                        'state otherwise in this directive.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            AddressFields(
              line1: _addressCtrl,
              line2: _address2Ctrl,
              city: _cityCtrl,
              state: _stateCtrl,
              zip: _zipCtrl,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '(215) 555-1234',
                border: OutlineInputBorder(),
              ),
              autofillHints: const [],
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: const [PhoneInputFormatter()],
              validator: optionalPhoneValidator,
            ),
          ],
        ),
      );
  }
}
