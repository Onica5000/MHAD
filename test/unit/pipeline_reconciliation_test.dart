import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ui/wizard/widgets/pipeline_reconciliation.dart';

/// Guards the pipeline reconciliation data layer: priority/kind classification,
/// conflict detection against existing values, default selection, and grouping.
void main() {
  group('classification', () {
    test('high-priority clinical keys vs low-priority notes', () {
      expect(reconPriority('med_prefer_Lithium'), ReconPriority.high);
      expect(reconPriority('cond_Bipolar'), ReconPriority.high);
      expect(reconPriority('facility_prefer'), ReconPriority.high);
      expect(reconPriority('hh_note'), ReconPriority.high);
      expect(reconPriority('crisis'), ReconPriority.high);
      expect(reconPriority('dietary'), ReconPriority.low);
      expect(reconPriority('religious'), ReconPriority.low);
      expect(reconPriority('activities'), ReconPriority.low);
      expect(reconPriority('other'), ReconPriority.low);
    });

    test('meds/conditions are listAdd; scalars are scalar', () {
      expect(reconKind('med_avoid_Haldol'), ReconKind.listAdd);
      expect(reconKind('cond_PTSD'), ReconKind.listAdd);
      expect(reconKind('facility_prefer'), ReconKind.scalar);
      expect(reconKind('dietary'), ReconKind.scalar);
    });
  });

  group('buildReconItems', () {
    test('listAdd items never conflict and are pre-selected', () {
      final items = buildReconItems(
        extracted: {'med_prefer_Lithium': 'Lithium 300mg'},
        existing: const {},
      );
      expect(items.single.isConflict, isFalse);
      expect(items.single.selected, isTrue);
      expect(items.single.priority, ReconPriority.high);
    });

    test('scalar with no existing value is not a conflict, pre-selected', () {
      final items = buildReconItems(
        extracted: {'facility_prefer': 'Pine Center'},
        existing: const {},
      );
      expect(items.single.isConflict, isFalse);
      expect(items.single.selected, isTrue);
    });

    test('scalar that differs from existing IS a conflict, starts unselected',
        () {
      final items = buildReconItems(
        extracted: {'facility_prefer': 'Pine Center'},
        existing: {'facility_prefer': 'Oak Hospital'},
      );
      final i = items.single;
      expect(i.isConflict, isTrue);
      expect(i.selected, isFalse,
          reason: 'a conflict needs a deliberate decision');
      expect(i.existing, 'Oak Hospital');
    });

    test('identical existing value is not a conflict', () {
      final items = buildReconItems(
        extracted: {'dietary': 'Vegetarian'},
        existing: {'dietary': 'Vegetarian'},
      );
      expect(items.single.isConflict, isFalse);
    });

    test('suggestedValue prefers the more complete value on conflict', () {
      final items = buildReconItems(
        extracted: {'facility_prefer': 'Pine Center, Building B'},
        existing: {'facility_prefer': 'Pine'},
      );
      expect(items.single.suggestedValue, 'Pine Center, Building B');
    });
  });

  group('ReconGroups.from', () {
    test('splits low-priority into auto-applied and the rest into decisions',
        () {
      final items = buildReconItems(
        extracted: {
          'dietary': 'Vegetarian', // low, no conflict -> auto
          'med_prefer_Lithium': 'Lithium', // high -> decide
          'facility_prefer': 'Pine', // high scalar, conflict -> decide
        },
        existing: {'facility_prefer': 'Oak'},
      );
      final g = ReconGroups.from(items);
      expect(g.autoApplied.map((e) => e.key), ['dietary']);
      expect(g.needsDecision.map((e) => e.key),
          containsAll(['med_prefer_Lithium', 'facility_prefer']));
    });

    test('a low-priority field that conflicts is escalated to decisions', () {
      final items = buildReconItems(
        extracted: {'dietary': 'Vegan'},
        existing: {'dietary': 'Omnivore'},
      );
      final g = ReconGroups.from(items);
      expect(g.autoApplied, isEmpty);
      expect(g.needsDecision.single.key, 'dietary');
    });
  });
}
