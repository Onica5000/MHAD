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

/// Canonical "who is my preferred guardian" choices from the v2 prototype.
/// Persists as a string in `guardianRelation`. The `different` branch is the
/// only one that shows the inline name / address / phone fields.
enum _GuardianRel {
  // "No preference" is intentionally first (per user direction) — it's the
  // default and the lowest-effort choice.
  noPreference('noPreference', 'No preference',
      'Let the court decide. They will usually appoint a family member or county guardianship office.'),
  sameAsPrimary('sameAsPrimary', 'Same as my primary agent',
      'The simplest path. The court is not required to follow this, but it is strong guidance.'),
  sameAsAlternate('sameAsAlternate', 'Same as my alternate agent',
      'Use this if your alternate would be a better fit for a longer-term guardianship role.'),
  different('different', 'Someone different',
      'Choose another person — e.g. an attorney, sibling, or close friend not already named.');

  final String id;
  final String label;
  final String hint;
  const _GuardianRel(this.id, this.label, this.hint);

  static _GuardianRel fromId(String id) =>
      _GuardianRel.values.firstWhere(
        (e) => e.id == id,
        orElse: () => _GuardianRel.noPreference,
      );
}

class _GuardianNominationStepState
    extends ConsumerState<GuardianNominationStep> with WizardStepMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _relationshipCtrl;
  // Free-form detail for each "yes" condition (revealed only when Yes).
  late final TextEditingController _changeAgentNoteCtrl;
  late final TextEditingController _revokeNoteCtrl;
  late final TextEditingController _consultNoteCtrl;
  int? _existingId;
  bool _guardianCanRevoke = false;
  bool _guardianCanChangeAgent = false;
  bool _guardianMustConsultAgent = false;
  _GuardianRel _relation = _GuardianRel.noPreference;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _relationshipCtrl = TextEditingController();
    _changeAgentNoteCtrl = TextEditingController();
    _revokeNoteCtrl = TextEditingController();
    _consultNoteCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _relationshipCtrl.dispose();
    _changeAgentNoteCtrl.dispose();
    _revokeNoteCtrl.dispose();
    _consultNoteCtrl.dispose();
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
        _guardianCanRevoke = g.guardianCanRevoke;
        _guardianCanChangeAgent = g.guardianCanChangeAgent;
        _guardianMustConsultAgent = g.guardianMustConsultAgent;
        _changeAgentNoteCtrl.text = g.guardianCanChangeAgentNote;
        _revokeNoteCtrl.text = g.guardianCanRevokeNote;
        _consultNoteCtrl.text = g.guardianMustConsultAgentNote;
        _relation = _GuardianRel.fromId(g.guardianRelation);
      });
    }
  }

  @override
  Future<bool> validateAndSave() async {
    _formKey.currentState?.validate();
    // PRESERVE the nominee text fields even when the user is currently on a
    // non-'different' radio: we always write whatever's in the controllers
    // back to the row. The downstream consumers (PDF generators, clinician
    // view) read `guardianRelation` to decide whether the nominee fields
    // are active or whether to substitute the named agent. Blanking the
    // fields here would silently destroy contact-picker-imported names if
    // the user toggled "different" → "Same as primary" → save → and later
    // came back. See review finding A5.
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
            guardianCanRevoke: Value(_guardianCanRevoke),
            guardianCanChangeAgent: Value(_guardianCanChangeAgent),
            guardianMustConsultAgent: Value(_guardianMustConsultAgent),
            // Persist notes only while the matching condition is Yes; clear
            // otherwise so a later "No" doesn't leave orphaned detail.
            guardianCanChangeAgentNote: Value(
                _guardianCanChangeAgent ? _changeAgentNoteCtrl.text.trim() : ''),
            guardianCanRevokeNote: Value(
                _guardianCanRevoke ? _revokeNoteCtrl.text.trim() : ''),
            guardianMustConsultAgentNote: Value(
                _guardianMustConsultAgent ? _consultNoteCtrl.text.trim() : ''),
            guardianRelation: Value(_relation.id),
          ),
        );
    return true;
  }

  /// Free-form detail box revealed under a guardianship condition set to Yes.
  Widget _conditionNote(TextEditingController ctrl, String hint) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2, bottom: 8),
      child: TextField(
        controller: ctrl,
        minLines: 1,
        maxLines: 3,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
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
                      'A guardian is different from your agent. A guardian is '
                      'appointed by a court during formal incapacity proceedings. '
                      'This nomination tells the court who you prefer.',
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
          // Phase 2 — 4-radio Opt pattern per v2 prototype's `ScrWizardGuardian`.
          // The 'Someone different' branch expands inline to show the existing
          // free-text fields; other branches hide them (and clear on save).
          Text(
            'Preferred guardian',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Pick what fits — your nomination is guidance for the court, not '
            'a binding instruction.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          for (final rel in _GuardianRel.values) ...[
            _GuardianRelOptCard(
              option: rel,
              selected: _relation == rel,
              onTap: () => setState(() => _relation = rel),
            ),
            const SizedBox(height: 8),
          ],

          // Inline expansion: only visible for 'Someone different'. Keeps the
          // existing contact-picker + 4 free-text fields the previous step had.
          if (_relation == _GuardianRel.different) ...[
            const SizedBox(height: 8),
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
          const SizedBox(height: 24),
          Text(
            'Conditions on the guardianship',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'If a court appoints a guardian, set the limits you want it to '
            'honor. These are guidance for the court, not binding.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _GuardianConditionRow(
            label: 'Can change my agent',
            value: _guardianCanChangeAgent,
            onChanged: (v) => setState(() => _guardianCanChangeAgent = v),
          ),
          if (_guardianCanChangeAgent)
            _conditionNote(
              _changeAgentNoteCtrl,
              'When or how may the guardian change my agent? (optional)',
            ),
          _GuardianConditionRow(
            label: 'Can override this directive',
            sub: 'Revoke, suspend, or terminate it.',
            value: _guardianCanRevoke,
            onChanged: (v) => setState(() => _guardianCanRevoke = v),
          ),
          if (_guardianCanRevoke)
            _conditionNote(
              _revokeNoteCtrl,
              'Any limits on overriding this directive? (optional)',
            ),
          _GuardianConditionRow(
            label: 'Must consult my agent first',
            value: _guardianMustConsultAgent,
            onChanged: (v) => setState(() => _guardianMustConsultAgent = v),
          ),
          if (_guardianMustConsultAgent)
            _conditionNote(
              _consultNoteCtrl,
              'What should the guardian consult my agent about? (optional)',
            ),
        ],
      ),
    );
  }
}

/// A single guardian "condition" — a label with a Yes/No segmented toggle,
/// mirroring the artboard's ConsentRow.
class _GuardianConditionRow extends StatelessWidget {
  final String label;
  final String? sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _GuardianConditionRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget pill(String text, bool isYes) {
      final selected = value == isYes;
      return InkWell(
        onTap: () => onChanged(isYes),
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? cs.onPrimary : cs.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (sub != null)
                  Text(sub!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              border: Border.all(color: cs.outlineVariant),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [pill('No', false), pill('Yes', true)],
            ),
          ),
        ],
      ),
    );
  }
}

/// Radio-card variant used by the Guardian step's 4-option pattern. Mirrors
/// the prototype's `Opt` card: tinted background when selected, 2 px primary
/// border, sub-explanation only on the selected card.
class _GuardianRelOptCard extends StatelessWidget {
  final _GuardianRel option;
  final bool selected;
  final VoidCallback onTap;

  const _GuardianRelOptCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? cs.primary : cs.outline,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      height: 1.3,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(height: 4),
                    Text(
                      option.hint,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
