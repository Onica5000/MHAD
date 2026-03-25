import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
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
  final _preferFacilityCtrl = TextEditingController();
  final _preferLocationCtrl = TextEditingController();
  final _avoidFacilityCtrl = TextEditingController();
  final _avoidLocationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _preferFacilityCtrl.dispose();
    _preferLocationCtrl.dispose();
    _avoidFacilityCtrl.dispose();
    _avoidLocationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final pref = await ref
        .read(directiveRepositoryProvider)
        .getPreferences(widget.directiveId);
    if (pref != null && mounted) {
      setState(() {
        // Split "Name | Location" format if present
        final prefParts = pref.preferredFacilityName.split(' | ');
        _preferFacilityCtrl.text = prefParts.first;
        if (prefParts.length > 1) _preferLocationCtrl.text = prefParts[1];

        final avoidParts = pref.avoidFacilityName.split(' | ');
        _avoidFacilityCtrl.text = avoidParts.first;
        if (avoidParts.length > 1) _avoidLocationCtrl.text = avoidParts[1];
      });
    }
  }

  @override
  Future<bool> validateAndSave() async {
    _formKey.currentState?.validate();

    final preferName = _preferFacilityCtrl.text.trim();
    final preferLoc = _preferLocationCtrl.text.trim();
    final preferred = preferName.isEmpty
        ? ''
        : preferLoc.isEmpty
            ? preferName
            : '$preferName | $preferLoc';

    final avoidName = _avoidFacilityCtrl.text.trim();
    final avoidLoc = _avoidLocationCtrl.text.trim();
    final avoid = avoidName.isEmpty
        ? ''
        : avoidLoc.isEmpty
            ? avoidName
            : '$avoidName | $avoidLoc';

    // Determine pref value based on what's filled in
    final prefValue = preferred.isNotEmpty
        ? 'prefer'
        : avoid.isNotEmpty
            ? 'avoid'
            : 'noPreference';

    await ref.read(directiveRepositoryProvider).upsertPreferences(
          DirectivePrefsCompanion(
            directiveId: Value(widget.directiveId),
            treatmentFacilityPref: Value(prefValue),
            preferredFacilityName: Value(preferred),
            avoidFacilityName: Value(avoid),
          ),
        );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const helpText =
        'You may specify treatment facilities you prefer or want to avoid. '
        'These preferences guide your agent and treatment providers but '
        'may not always be possible to honor. Both fields are optional.';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WizardHelpButton(helpText: helpText, stepId: 'treatmentFacility'),
          const SizedBox(height: 8),
          Card(
            color: cs.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18,
                      color: cs.onSecondaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Leave both sections blank if you have no preference. '
                      'Your directive will indicate "No Preference" for '
                      'treatment facility.',
                      style: TextStyle(
                          fontSize: 12.5,
                          color: cs.onSecondaryContainer,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Preferred Facility',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'If you are hospitalized, which facility would you prefer?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _preferFacilityCtrl,
            decoration: const InputDecoration(
              labelText: 'Preferred facility name (optional)',
              hintText: 'e.g., Community Hospital',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _preferLocationCtrl,
            decoration: const InputDecoration(
              labelText: 'Location (optional)',
              hintText: 'e.g., 123 Main St, Philadelphia, PA',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 24),
          Text(
            'Facility to Avoid',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Is there a facility where you do not want to be treated?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _avoidFacilityCtrl,
            decoration: const InputDecoration(
              labelText: 'Facility to avoid (optional)',
              hintText: 'e.g., County Crisis Center',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _avoidLocationCtrl,
            decoration: const InputDecoration(
              labelText: 'Location (optional)',
              hintText: 'e.g., 456 Oak Ave, Pittsburgh, PA',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}
