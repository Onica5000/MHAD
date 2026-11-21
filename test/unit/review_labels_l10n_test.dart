import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/smart_fill_service.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/ui/wizard/widgets/document_pipeline_flow.dart';

/// Autofill review text the person reads follows the app language: the
/// smart-fill row titles (their keys stay English for apply) and the
/// registry badges (which apply strips in every language).
void main() {
  test('every smart-fill row has a title in English and Spanish', () {
    final all = SmartFillResult.fromJson({
      for (final f in const [
        'effective_condition', 'health_history', 'preferred_facility_note',
        'avoid_facility_note', 'ect_preference', 'experimental_preference',
        'drug_trial_preference', 'crisis_intervention', 'deescalation',
        'triggers', 'activities', 'dietary', 'religious', 'children_custody',
        'family_notification', 'records_disclosure', 'pet_custody',
        'agent_guidance',
      ])
        f: 'x',
    });
    final keys = all.toDisplayMap().keys.toList();
    expect(keys, hasLength(18), reason: 'a new smart-fill field needs a title');
    final es = lookupAppLocalizations(const Locale('es'));
    final en = lookupAppLocalizations(const Locale('en'));
    for (final k in keys) {
      expect(smartFillLabel(es, k), isNot(k), reason: '$k has no Spanish title');
      expect(smartFillLabel(es, k), isNot(smartFillLabel(en, k)), reason: k);
    }
  });

  test('apply strips the badges in every language', () {
    expect(
        allReviewBadges,
        containsAll(const [
          ' [RxNorm verified]', ' [NPI verified]', ' [unverified]',
          ' [verificado en RxNorm]', ' [verificado en NPI]', ' [sin verificar]',
        ]));
  });
}
