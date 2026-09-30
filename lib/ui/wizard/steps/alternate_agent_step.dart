import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/agent_ext.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/widgets/forms/address_fields.dart';
import 'package:mhad/ui/wizard/widgets/contact_picker_button.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';
import 'package:mhad/utils/input_formatters.dart';

class AlternateAgentStep extends ConsumerStatefulWidget {
  const AlternateAgentStep({
    required this.directiveId,
    this.embedded = false,
    super.key,
  });

  final int directiveId;
  final bool embedded;

  @override
  ConsumerState<AlternateAgentStep> createState() => _AlternateAgentStepState();
}

class _AlternateAgentStepState
    extends ConsumerState<AlternateAgentStep> with WizardStepMixin {
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
    final alternate = agents.alternateAgent;
    if (alternate != null && mounted) {
      setState(() {
        _existingAgentId = alternate.id;
        _nameCtrl.text = alternate.fullName;
        _relationshipCtrl.text = alternate.relationship;
        _addressCtrl.text = alternate.address;
        _address2Ctrl.text = alternate.address2;
        _cityCtrl.text = alternate.city;
        _stateCtrl.text = alternate.state;
        _zipCtrl.text = alternate.zip;
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
              address2: Value(_address2Ctrl.text.trim()),
              city: Value(_cityCtrl.text.trim()),
              state: Value(_stateCtrl.text.trim()),
              zip: Value(_zipCtrl.text.trim()),
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
    final helpText = context.l10n.altAgentHelp;

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
            WizardHelpButton(helpText: helpText, stepId: 'alternateAgent'),
            const SizedBox(height: 8),
            Text(
              context.l10n.altAgentTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.altAgentActsIf,
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.altAgentSameAuthority,
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.altAgentNotRequired,
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
              decoration: InputDecoration(
                labelText: context.l10n.fullName,
                border: const OutlineInputBorder(),
              ),
              autofillHints: const [],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _relationshipCtrl,
              decoration: InputDecoration(
                labelText: context.l10n.altAgentRelationship,
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
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
              decoration: InputDecoration(
                labelText: context.l10n.phone,
                hintText: '(215) 555-1234',
                border: const OutlineInputBorder(),
              ),
              autofillHints: const [],
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: const [PhoneInputFormatter()],
              validator: (v) => optionalPhoneValidator(v, context.l10n),
            ),
          ],
        ),
      );
  }
}
