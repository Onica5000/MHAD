import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/document_extraction_result.dart';

/// Guards the PII autofill contract: the extractor's response schema/prompt and
/// the `personal_info` parser must agree on key names. A drift here silently
/// drops autofilled personal fields while every build stays green.
void main() {
  group('DocumentExtractionResult personal_info parsing', () {
    test('parses declarant + agent + alternate + guardian from JSON', () {
      final r = DocumentExtractionResult.fromJson({
        'personal_info': {
          'full_name': 'Jane Q. Public',
          'date_of_birth': '1980-05-01',
          'address_line1': '123 Main St',
          'city': 'Philadelphia',
          'state': 'PA',
          'zip': '19103',
          'phone': '(215) 555-1234',
          'primary_doctor_name': 'Dr. Smith',
          'primary_doctor_phone': '(215) 555-9000',
          'agent': {
            'name': 'John Public',
            'relationship': 'Spouse',
            'address_line1': '123 Main St',
            'city': 'Philadelphia',
            'state': 'PA',
            'zip': '19103',
            'phone': '(215) 555-5678',
          },
          'alternate_agent': {'name': 'Mary Public', 'relationship': 'Sister'},
          'guardian': {'name': 'Sam Public'},
        },
      });

      final pi = r.personalInfo;
      expect(pi.isEmpty, isFalse);
      expect(pi.fullName, 'Jane Q. Public');
      expect(pi.dateOfBirth, '1980-05-01');
      expect(pi.addressLine1, '123 Main St');
      expect(pi.city, 'Philadelphia');
      expect(pi.state, 'PA');
      expect(pi.zip, '19103');
      expect(pi.phone, '(215) 555-1234');
      expect(pi.primaryDoctorName, 'Dr. Smith');
      expect(pi.primaryDoctorPhone, '(215) 555-9000');
      expect(pi.agent?.name, 'John Public');
      expect(pi.agent?.relationship, 'Spouse');
      expect(pi.agent?.phone, '(215) 555-5678');
      expect(pi.alternateAgent?.name, 'Mary Public');
      expect(pi.guardian?.name, 'Sam Public');
    });

    test('absent / empty personal_info yields an empty block', () {
      expect(DocumentExtractionResult.fromJson({}).personalInfo.isEmpty, isTrue);
      expect(
        DocumentExtractionResult.fromJson({'personal_info': {}})
            .personalInfo
            .isEmpty,
        isTrue,
      );
      // An object whose people are all-empty maps drops them to null.
      final r = DocumentExtractionResult.fromJson({
        'personal_info': {
          'agent': {'name': '', 'phone': ''},
        },
      });
      expect(r.personalInfo.agent, isNull);
      expect(r.personalInfo.isEmpty, isTrue);
    });

    test('merge across pages fills missing fields without clobbering', () {
      final page1 = DocumentExtractionResult.fromJson({
        'personal_info': {'full_name': 'Jane Public'},
      });
      final page2 = DocumentExtractionResult.fromJson({
        'personal_info': {
          'address_line1': '123 Main St',
          'agent': {'name': 'John Public'},
        },
      });
      final merged = page1.merge(page2).personalInfo;
      expect(merged.fullName, 'Jane Public');
      expect(merged.addressLine1, '123 Main St');
      expect(merged.agent?.name, 'John Public');
    });

    test('personal_info alone makes the result non-empty (so it is applied)',
        () {
      final r = DocumentExtractionResult.fromJson({
        'personal_info': {'full_name': 'Jane Public'},
      });
      expect(r.isEmpty, isFalse);
    });
  });
}
