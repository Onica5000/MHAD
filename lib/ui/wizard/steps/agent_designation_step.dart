import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/widgets/contact_picker_button.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class AgentDesignationStep extends ConsumerStatefulWidget {
  const AgentDesignationStep({required this.directiveId, super.key});

  final int directiveId;

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
    final primary = agents.where((a) => a.agentType == 'primary').firstOrNull;
    if (primary != null && mounted) {
      setState(() {
        _existingAgentId = primary.id;
        _nameCtrl.text = primary.fullName;
        _relationshipCtrl.text = primary.relationship;
        _addressCtrl.text = primary.address;
        _homePhoneCtrl.text = primary.homePhone;
        _workPhoneCtrl.text = primary.workPhone;
        _cellPhoneCtrl.text = primary.cellPhone;
      });
    }
  }

  String? _validateAtLeastOnePhone(String? value) {
    final home = _homePhoneCtrl.text.trim();
    final work = _workPhoneCtrl.text.trim();
    final cell = _cellPhoneCtrl.text.trim();
    if (home.isEmpty && work.isEmpty && cell.isEmpty) {
      return 'At least one phone number is required';
    }
    // Validate that the current field (if filled) has enough digits
    if (value != null && value.trim().isNotEmpty) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 10) {
        return 'Enter a valid phone number (10+ digits)';
      }
    }
    return null;
  }

  @override
  Future<bool> validateAndSave() async {
    // Validate but don't block — always save whatever is entered
    _formKey.currentState?.validate();

    final home = _homePhoneCtrl.text.trim();
    final work = _workPhoneCtrl.text.trim();
    final cell = _cellPhoneCtrl.text.trim();

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
            homePhone: Value(home),
            workPhone: Value(work),
            cellPhone: Value(cell),
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
          padding: const EdgeInsets.all(16),
          children: [
            WizardHelpButton(helpText: helpText, stepId: 'agentDesignation'),
            const SizedBox(height: 8),
            Text(
              'Primary Agent Designation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your agent (also called healthcare proxy) is the person you '
              'authorize to make mental health treatment decisions for you when '
              'this directive is in effect.',
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9()\-+.\s]')),
              ],
              validator: _validateAtLeastOnePhone,
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9()\-+.\s]')),
              ],
              validator: _validateAtLeastOnePhone,
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9()\-+.\s]')),
              ],
              validator: _validateAtLeastOnePhone,
            ),
          ],
        ),
      );
  }
}
