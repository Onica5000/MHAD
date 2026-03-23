import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/widgets/contact_picker_button.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class GuardianNominationStep extends ConsumerStatefulWidget {
  final int directiveId;
  const GuardianNominationStep({required this.directiveId, super.key});

  @override
  ConsumerState<GuardianNominationStep> createState() =>
      _GuardianNominationStepState();
}

class _GuardianNominationStepState
    extends ConsumerState<GuardianNominationStep> with WizardStepMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _relationshipCtrl;
  int? _existingId;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _relationshipCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _relationshipCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final g = await ref
        .read(directiveRepositoryProvider)
        .getGuardianNomination(widget.directiveId);
    if (g != null && mounted) {
      setState(() {
        _existingId = g.id;
        _nameCtrl.text = g.nomineeFullName;
        _addressCtrl.text = g.nomineeAddress;
        _phoneCtrl.text = g.nomineePhone;
        _relationshipCtrl.text = g.nomineeRelationship;
      });
    }
  }

  @override
  Future<bool> validateAndSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return false;
    await ref.read(directiveRepositoryProvider).upsertGuardianNomination(
          GuardianNominationsCompanion(
            id: _existingId != null
                ? Value(_existingId!)
                : const Value.absent(),
            directiveId: Value(widget.directiveId),
            nomineeFullName: Value(_nameCtrl.text.trim()),
            nomineeAddress: Value(_addressCtrl.text.trim()),
            nomineePhone: Value(_phoneCtrl.text.trim()),
            nomineeRelationship: Value(_relationshipCtrl.text.trim()),
          ),
        );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WizardHelpButton(
            helpText:
                'You may nominate someone to be your guardian if a court ever '
                'appoints a guardian for you. This nomination is not binding — '
                'the court will consider it but makes the final decision. '
                'This section is optional.',
            stepId: 'guardianNomination',
          ),
          const SizedBox(height: 8),
          Text(
            'This section is optional. You may nominate a guardian in case a '
            'court ever needs to appoint one for you.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          ContactPickerButton(
            onContactPicked: (c) => setState(() {
              _nameCtrl.text = c.fullName;
              if (c.address.isNotEmpty) _addressCtrl.text = c.address;
              if (c.cellPhone.isNotEmpty) {
                _phoneCtrl.text = c.cellPhone;
              } else if (c.homePhone.isNotEmpty) {
                _phoneCtrl.text = c.homePhone;
              }
            }),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nominee full name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _relationshipCtrl,
            decoration: const InputDecoration(
              labelText: 'Relationship to you',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressCtrl,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneCtrl,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}

