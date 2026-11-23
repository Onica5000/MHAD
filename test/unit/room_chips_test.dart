import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/document_extractor.dart';
import 'package:mhad/constants.dart';

/// One list of room-preference chips (kRoomPreferenceChipIds): the screen
/// offers each, the autofill prompt names each, and apply / review accept
/// each. The prompt used to know 4 of the 7 (and mapped "low-stimulation
/// unit" onto quiet floor), so 3 could never be autofilled.
void main() {
  test('the autofill prompt names every chip id', () {
    final prompt = DocumentExtractor.promptFor('combined');
    for (final id in kRoomPreferenceChipIds) {
      expect(prompt, contains('"$id"'), reason: id);
    }
  });

  test('the Where-I-want-care step offers every chip id', () {
    final src =
        File('lib/ui/wizard/steps/treatment_facility_step.dart').readAsStringSync();
    for (final id in kRoomPreferenceChipIds) {
      expect(src, contains("_RoomChip('$id'"), reason: id);
    }
  });

  test('a described roommate match is allowed (specify:<words>)', () {
    expect(DocumentExtractor.promptFor('combined'), contains('"specify: '));
  });
}
