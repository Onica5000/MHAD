import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class TreatmentFacilityStep extends ConsumerStatefulWidget {
  const TreatmentFacilityStep({required this.directiveId, super.key});

  final int directiveId;

  @override
  ConsumerState<TreatmentFacilityStep> createState() =>
      _TreatmentFacilityStepState();
}

class _TreatmentFacilityStepState
    extends ConsumerState<TreatmentFacilityStep> with WizardStepMixin {
  final _formKey = GlobalKey<FormState>();
  TreatmentFacilityPreference _pref = TreatmentFacilityPreference.noPreference;
  final _preferFacilityCtrl = TextEditingController();
  final _avoidFacilityCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _preferFacilityCtrl.dispose();
    _avoidFacilityCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final pref = await ref
        .read(directiveRepositoryProvider)
        .getPreferences(widget.directiveId);
    if (pref != null && mounted) {
      setState(() {
        _pref = TreatmentFacilityPreference.values.firstWhere(
          (e) => e.name == pref.treatmentFacilityPref,
          orElse: () => TreatmentFacilityPreference.noPreference,
        );
        _preferFacilityCtrl.text = pref.preferredFacilityName;
        _avoidFacilityCtrl.text = pref.avoidFacilityName;
      });
    }
  }

  @override
  Future<bool> validateAndSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return false;

    await ref.read(directiveRepositoryProvider).upsertPreferences(
          DirectivePrefsCompanion(
            directiveId: Value(widget.directiveId),
            treatmentFacilityPref: Value(_pref.name),
            preferredFacilityName: Value(
              _pref == TreatmentFacilityPreference.prefer
                  ? _preferFacilityCtrl.text.trim()
                  : '',
            ),
            avoidFacilityName: Value(
              _pref == TreatmentFacilityPreference.avoid
                  ? _avoidFacilityCtrl.text.trim()
                  : _pref == TreatmentFacilityPreference.prefer
                      ? _avoidFacilityCtrl.text.trim()
                      : '',
            ),
          ),
        );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const helpText =
        'You may specify a treatment facility you prefer or want to avoid. '
        'This preference is not binding — it guides your agent and treatment '
        'providers but may not always be possible to honor.';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WizardHelpButton(helpText: helpText, stepId: 'treatmentFacility'),
          const SizedBox(height: 8),
          RadioGroup<TreatmentFacilityPreference>(
            groupValue: _pref,
            onChanged: (v) => setState(() => _pref = v!),
            child: Column(
              children: [
                RadioListTile<TreatmentFacilityPreference>(
                  title: const Text('No preference'),
                  value: TreatmentFacilityPreference.noPreference,
                ),
                RadioListTile<TreatmentFacilityPreference>(
                  title: const Text('I prefer this facility'),
                  value: TreatmentFacilityPreference.prefer,
                ),
                RadioListTile<TreatmentFacilityPreference>(
                  title: const Text('I want to avoid this facility'),
                  value: TreatmentFacilityPreference.avoid,
                ),
              ],
            ),
          ),
          if (_pref == TreatmentFacilityPreference.prefer) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _preferFacilityCtrl,
              decoration: const InputDecoration(
                labelText: 'Preferred facility name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _avoidFacilityCtrl,
              decoration: const InputDecoration(
                labelText: 'Facility to avoid (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          if (_pref == TreatmentFacilityPreference.avoid) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _avoidFacilityCtrl,
              decoration: const InputDecoration(
                labelText: 'Facility to avoid',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
          ],
        ],
      ),
    );
  }
}
