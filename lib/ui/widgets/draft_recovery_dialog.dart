import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/draft_recovery_service.dart';
import 'package:mhad/ui/router.dart';

/// Checks for a crash-recovery draft on app startup and shows a dialog
/// offering to restore it. Call from the home screen's initState.
///
/// Requires a [WidgetRef] to access the repository for creating/restoring
/// the directive.
Future<void> checkAndOfferDraftRecovery(
    BuildContext context, WidgetRef ref) async {
  final draft = await DraftRecoveryService.checkForDraft();
  if (draft == null || !context.mounted) return;

  final restore = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.restore, color: cs.primary),
            const SizedBox(width: 8),
            const Expanded(child: Text('Recover Unsaved Work?')),
          ],
        ),
        content: Text(
          'It looks like the app closed unexpectedly. '
          'An auto-saved draft was found from ${draft.ageDescription}.\n\n'
          'This draft contains your treatment preferences and '
          'medical data (no personal information was saved).\n\n'
          'Would you like to restore it?',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await DraftRecoveryService.clearDraft();
              if (ctx.mounted) Navigator.pop(ctx, false);
            },
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      );
    },
  );

  if (restore != true || !context.mounted) {
    await DraftRecoveryService.clearDraft();
    return;
  }

  try {
    final repo = ref.read(directiveRepositoryProvider);

    // Determine form type from draft data
    final formTypeName = draft.data['formType']?.toString() ?? 'combined';
    final formType = FormType.values.firstWhere(
      (e) => e.name == formTypeName,
      orElse: () => FormType.combined,
    );

    // Create a new directive (the old one is gone after crash)
    final newId = await repo.createDirective(formType);

    // Restore effective condition
    final ec = draft.data['effectiveCondition']?.toString() ?? '';
    if (ec.isNotEmpty) {
      await repo.updateEffectiveCondition(newId, ec);
    }

    // Restore last step index
    final lastStep = draft.data['lastStepIndex'];
    if (lastStep is int && lastStep > 0) {
      await repo.updateLastStepIndex(newId, lastStep);
    }

    // Restore preferences
    await repo.upsertPreferences(DirectivePrefsCompanion(
      directiveId: Value(newId),
      treatmentFacilityPref: _valueOrAbsent(draft.data['treatmentFacilityPref']),
      preferredFacilityName: _valueOrAbsent(draft.data['preferredFacilityName']),
      avoidFacilityName: _valueOrAbsent(draft.data['avoidFacilityName']),
      medicationConsent: _valueOrAbsent(draft.data['medicationConsent']),
      ectConsent: _valueOrAbsent(draft.data['ectConsent']),
      experimentalConsent: _valueOrAbsent(draft.data['experimentalConsent']),
      drugTrialConsent: _valueOrAbsent(draft.data['drugTrialConsent']),
    ));

    // Restore additional instructions
    final instrFields = [
      'activities', 'crisisIntervention', 'healthHistory', 'dietary',
      'religious', 'childrenCustody', 'familyNotification',
      'recordsDisclosure', 'petCustody', 'other',
    ];
    final hasInstr = instrFields.any(
        (f) => (draft.data[f]?.toString() ?? '').isNotEmpty);
    if (hasInstr) {
      await repo.upsertAdditionalInstructions(
        AdditionalInstructionsTableCompanion(
          directiveId: Value(newId),
          activities: _valueOrAbsent(draft.data['activities']),
          crisisIntervention: _valueOrAbsent(draft.data['crisisIntervention']),
          healthHistory: _valueOrAbsent(draft.data['healthHistory']),
          dietary: _valueOrAbsent(draft.data['dietary']),
          religious: _valueOrAbsent(draft.data['religious']),
          childrenCustody: _valueOrAbsent(draft.data['childrenCustody']),
          familyNotification: _valueOrAbsent(draft.data['familyNotification']),
          recordsDisclosure: _valueOrAbsent(draft.data['recordsDisclosure']),
          petCustody: _valueOrAbsent(draft.data['petCustody']),
          other: _valueOrAbsent(draft.data['other']),
        ),
      );
    }

    await DraftRecoveryService.clearDraft();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Draft restored. Personal information will need to be re-entered.'),
          duration: Duration(seconds: 4),
        ),
      );
      context.push(AppRoutes.wizardRoute(newId));
    }
  } catch (e) {
    debugPrint('Draft restore failed: $e');
    await DraftRecoveryService.clearDraft();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to restore draft: $e')),
      );
    }
  }
}

Value<String> _valueOrAbsent(dynamic v) {
  final s = v?.toString() ?? '';
  return s.isNotEmpty ? Value(s) : const Value.absent();
}
