import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/forms/address_fields.dart';
import 'package:mhad/ui/wizard/widgets/contact_picker_button.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';
import 'package:mhad/utils/input_formatters.dart';

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
  noPreference('noPreference'),
  sameAsPrimary('sameAsPrimary'),
  sameAsAlternate('sameAsAlternate'),
  different('different');

  final String id;
  const _GuardianRel(this.id);

  /// Display label (localized). Only [id] is persisted.
  String label(AppLocalizations l) => switch (this) {
        noPreference => l.guardianNomNoPreference,
        sameAsPrimary => l.guardianNomSameAsPrimary,
        sameAsAlternate => l.guardianNomSameAsAlternate,
        different => l.guardianNomDifferent,
      };

  /// Sub-explanation shown on the selected card (localized).
  String hint(AppLocalizations l) => switch (this) {
        noPreference => l.guardianNomNoPreferenceHint,
        sameAsPrimary => l.guardianNomSameAsPrimaryHint,
        sameAsAlternate => l.guardianNomSameAsAlternateHint,
        different => l.guardianNomDifferentHint,
      };

  static _GuardianRel fromId(String id) =>
      _GuardianRel.values.firstWhere(
        (e) => e.id == id,
        orElse: () => _GuardianRel.noPreference,
      );
}

class _GuardianNominationStepState
    extends ConsumerState<GuardianNominationStep>
    with WizardStepMixin, WizardStepLoadGuard {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _address2Ctrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _zipCtrl;
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
    _address2Ctrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    _zipCtrl = TextEditingController();
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
    _address2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
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
    markLoaded();
    if (g != null && mounted) {
      setState(() {
        _existingId = g.id;
        _nameCtrl.text = g.nomineeFullName;
        _addressCtrl.text = g.nomineeAddress;
        _address2Ctrl.text = g.nomineeAddress2;
        _cityCtrl.text = g.nomineeCity;
        _stateCtrl.text = g.nomineeState;
        _zipCtrl.text = g.nomineeZip;
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
    if (!isLoaded) return true; // don't overwrite the guardian before load
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
            nomineeAddress2: Value(_address2Ctrl.text.trim()),
            nomineeCity: Value(_cityCtrl.text.trim()),
            nomineeState: Value(_stateCtrl.text.trim()),
            nomineeZip: Value(_zipCtrl.text.trim()),
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
        padding: const EdgeInsets.all(20),
        children: [
          WizardHelpButton(
            // The on-screen description below already says this is optional and
            // what a nomination is; help only carries the binding-status detail.
            helpText: context.l10n.guardianNomHelp,
            stepId: 'guardianNomination',
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.guardianNomOptionalIntro,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          InfoBanner(
            icon: Icons.info_outline,
            margin: EdgeInsets.zero,
            text: context.l10n.guardianNomGuardianVsAgent,
          ),
          const SizedBox(height: 12),
          // Phase 2 — 4-radio Opt pattern per v2 prototype's `ScrWizardGuardian`.
          // The 'Someone different' branch expands inline to show the existing
          // free-text fields; other branches hide them (and clear on save).
          Text(
            context.l10n.guardianNomPreferredGuardian,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.guardianNomPickWhatFits,
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
              decoration: InputDecoration(
                labelText: context.l10n.guardianNomNomineeFullName,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _relationshipCtrl,
              decoration: InputDecoration(
                labelText: context.l10n.guardianNomRelationshipToYou,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            AddressFields(
              line1: _addressCtrl,
              line2: _address2Ctrl,
              city: _cityCtrl,
              state: _stateCtrl,
              zip: _zipCtrl,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              decoration: InputDecoration(
                labelText: context.l10n.phone,
                hintText: '(215) 555-1234',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: const [PhoneInputFormatter()],
              validator: optionalPhoneValidator,
            ),
          ],
          const SizedBox(height: 24),
          Text(
            context.l10n.guardianNomConditionsTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.guardianNomConditionsIntro,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _GuardianConditionRow(
            label: context.l10n.guardianNomCanChangeAgent,
            value: _guardianCanChangeAgent,
            onChanged: (v) => setState(() => _guardianCanChangeAgent = v),
          ),
          if (_guardianCanChangeAgent)
            _conditionNote(
              _changeAgentNoteCtrl,
              context.l10n.guardianNomCanChangeAgentHint,
            ),
          _GuardianConditionRow(
            label: context.l10n.guardianNomCanOverride,
            sub: context.l10n.guardianNomCanOverrideSub,
            value: _guardianCanRevoke,
            onChanged: (v) => setState(() => _guardianCanRevoke = v),
          ),
          if (_guardianCanRevoke)
            _conditionNote(
              _revokeNoteCtrl,
              context.l10n.guardianNomCanOverrideHint,
            ),
          _GuardianConditionRow(
            label: context.l10n.guardianNomMustConsult,
            value: _guardianMustConsultAgent,
            onChanged: (v) => setState(() => _guardianMustConsultAgent = v),
          ),
          if (_guardianMustConsultAgent)
            _conditionNote(
              _consultNoteCtrl,
              context.l10n.guardianNomMustConsultHint,
            ),
        ],
      ),
    );
  }
}

/// A single guardian "condition" — a label with a Yes/No segmented toggle,
/// mirroring the artboard's consent-row pattern.
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
        borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: kSansFamily,
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
              borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                pill(context.l10n.no, false),
                pill(context.l10n.yes, true),
              ],
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
      borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
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
                    option.label(context.l10n),
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      height: 1.3,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(height: 4),
                    Text(
                      option.hint(context.l10n),
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 13,
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
