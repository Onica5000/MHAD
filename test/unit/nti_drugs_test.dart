import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/services/clinical_data_service.dart';

/// The app tells people an NTI drug has "no generic substitution in PA".
/// Pennsylvania publishes no official NTI list; the Department of Health's
/// guidance points to the FDA's 1988 sample list
/// (https://apps.health.pa.gov/pdf/ddc/newNTI2015.pdf, checked 2026-11-20).
/// A drug may carry that claim only if it is on this list — the copy below is
/// the guidance's own, word for word ("Levoxyine" is its typo for
/// levothyroxine; "Oxytriphylline" is its spelling).
const _paDohSampleList = {
  'aminophylline', 'carbamazepine', 'clindamycin', 'clonidine', 'digoxin',
  'disopyramide', 'dyphylline', 'guanethidine', 'isoetharine mesylate',
  'isoproterenol', 'levoxyine', 'lithium carbonate', 'metaproterenol',
  'minoxidil', 'oxytriphylline', 'phenytoin', 'prazosin', 'primidone',
  'procainamide', 'quinidine', 'theophylline', 'valproic acid',
  'valproate sodium', 'warfarin',
};

/// How the app's names map onto the sample list's entries.
const _sameAs = {
  'lithium': 'lithium carbonate',
  'levothyroxine': 'levoxyine',
  'divalproex': 'valproate sodium', // a valproate
  'divalproex sodium': 'valproate sodium',
};

void main() {
  test('every NTI badge drug is on the PA DOH-referenced sample list', () {
    for (final drug in NtiDrugReference.ntiDrugs.keys) {
      expect(_paDohSampleList, contains(_sameAs[drug] ?? drug),
          reason: '$drug would be badged "no generic substitution in PA" '
              'without a source');
    }
  });

  test('the AI prompts name only listed NTI drugs too', () {
    final data = jsonDecode(File('assets/data/app_data.json').readAsStringSync())
        as Map<String, dynamic>;
    for (final drug in (data['legal']['ntiDrugs'] as List).cast<String>()) {
      expect(_paDohSampleList, contains(_sameAs[drug] ?? drug), reason: drug);
    }
  });
}
