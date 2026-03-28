import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/pii_stripper.dart';

void main() {
  group('PiiStripper', () {
    group('SSN stripping', () {
      test('strips SSN with dashes', () {
        expect(
          PiiStripper.strip('My SSN is 123-45-6789'),
          'My SSN is [SSN removed]',
        );
      });

      test('strips SSN with spaces', () {
        expect(
          PiiStripper.strip('SSN: 123 45 6789'),
          'SSN: [SSN removed]',
        );
      });

      test('strips labeled bare 9-digit SSN', () {
        expect(
          PiiStripper.strip('SSN 123456789 here'),
          '[SSN removed] here',
        );
      });

      test('strips "social security number" labeled SSN', () {
        expect(
          PiiStripper.strip('social security number: 123456789'),
          '[SSN removed]',
        );
      });

      test('does not strip arbitrary 9-digit numbers without label', () {
        // Should NOT strip — could be an arbitrary number
        const input = 'Reference 987654321 for the case';
        expect(PiiStripper.strip(input), input);
      });
    });

    group('phone number stripping', () {
      test('strips (xxx) xxx-xxxx format', () {
        expect(
          PiiStripper.strip('Call me at (215) 555-1234'),
          'Call me at [phone removed]',
        );
      });

      test('strips xxx-xxx-xxxx format', () {
        expect(
          PiiStripper.strip('Phone: 215-555-1234'),
          'Phone: [phone removed]',
        );
      });

      test('strips xxx.xxx.xxxx format', () {
        expect(
          PiiStripper.strip('Number is 215.555.1234'),
          'Number is [phone removed]',
        );
      });

      test('strips 1-800 numbers', () {
        expect(
          PiiStripper.strip('Call 1-800-555-1234'),
          'Call [phone removed]',
        );
      });

      test('strips +1 prefixed numbers', () {
        expect(
          PiiStripper.strip('Phone +1 215 555 1234'),
          'Phone [phone removed]',
        );
      });
    });

    group('email stripping', () {
      test('strips simple email', () {
        expect(
          PiiStripper.strip('Email me at john@example.com'),
          'Email me at [email removed]',
        );
      });

      test('strips email with dots and plus', () {
        expect(
          PiiStripper.strip('Contact: john.doe+test@example.co.uk'),
          'Contact: [email removed]',
        );
      });
    });

    group('date of birth stripping', () {
      test('strips DOB with label', () {
        expect(
          PiiStripper.strip('DOB: 01/15/1990'),
          '[date of birth removed]',
        );
      });

      test('strips date of birth with full label', () {
        expect(
          PiiStripper.strip('date of birth: 1/15/1990'),
          '[date of birth removed]',
        );
      });

      test('strips born on pattern', () {
        expect(
          PiiStripper.strip('born on 01-15-1990'),
          '[date of birth removed]',
        );
      });

      test('strips "birthday is" pattern', () {
        final result = PiiStripper.strip('my birthday is 03/15/1960');
        expect(result, contains('[date of birth removed]'));
        expect(result, isNot(contains('03/15/1960')));
      });

      test('strips "I was born" pattern', () {
        final result = PiiStripper.strip('I was born 01-15-1990');
        expect(result, isNot(contains('01-15-1990')));
      });

      test('strips contextual date with b-day label', () {
        final result = PiiStripper.strip('b-day: 12/25/1985');
        expect(result, contains('[date of birth removed]'));
        expect(result, isNot(contains('12/25/1985')));
      });

      test('strips DOB in YYYY-MM-DD format', () {
        final result = PiiStripper.strip('DOB: 1990-01-15');
        expect(result, contains('[date of birth removed]'));
        expect(result, isNot(contains('1990-01-15')));
      });
    });

    group('ZIP code stripping', () {
      test('strips 5-digit ZIP after state abbreviation', () {
        final result = PiiStripper.strip('Philadelphia PA 19103');
        expect(result, isNot(contains('19103')));
        expect(result, contains('[ZIP removed]'));
      });

      test('strips 5-digit ZIP after comma', () {
        final result = PiiStripper.strip('Philadelphia, 19103');
        expect(result, isNot(contains('19103')));
        expect(result, contains('[ZIP removed]'));
      });

      test('strips 9-digit ZIP after state abbreviation', () {
        final result = PiiStripper.strip('Philadelphia PA 19103-1234');
        expect(result, isNot(contains('19103')));
        expect(result, contains('[ZIP removed]'));
      });
    });

    group('street address stripping', () {
      test('strips typical street address', () {
        expect(
          PiiStripper.strip('I live at 123 Main Street'),
          'I live at [address removed]',
        );
      });

      test('strips avenue abbreviation', () {
        expect(
          PiiStripper.strip('Office at 456 Oak Ave'),
          'Office at [address removed]',
        );
      });

      test('strips boulevard', () {
        expect(
          PiiStripper.strip('Located at 789 N. Broad Blvd'),
          'Located at [address removed]',
        );
      });

      test('strips parkway addresses', () {
        final result = PiiStripper.strip('Office at 100 City Parkway');
        expect(result, contains('[address removed]'));
        expect(result, isNot(contains('100 City Parkway')));
      });
    });

    group('PO Box stripping', () {
      test('strips PO Box', () {
        final result = PiiStripper.strip('Send to PO Box 1234');
        expect(result, contains('[address removed]'));
        expect(result, isNot(contains('1234')));
      });

      test('strips P.O. Box', () {
        final result = PiiStripper.strip('Mail to P.O. Box 567');
        expect(result, contains('[address removed]'));
        expect(result, isNot(contains('567')));
      });

      test('strips Post Office Box', () {
        final result = PiiStripper.strip('Post Office Box 89');
        expect(result, contains('[address removed]'));
      });
    });

    group('named person stripping', () {
      test('strips titled names (Dr.)', () {
        final result = PiiStripper.strip('Contact Dr. Jane Smith');
        expect(result, contains('[name removed]'));
        expect(result, isNot(contains('Jane Smith')));
      });

      test('strips titled names (Mr./Mrs.)', () {
        final result = PiiStripper.strip('Signed by Mr. Robert Johnson');
        expect(result, contains('[name removed]'));
        expect(result, isNot(contains('Robert Johnson')));
      });

      test('strips Rev. titles', () {
        final result = PiiStripper.strip('Contact Rev. Samuel Green');
        expect(result, contains('[name removed]'));
      });

      test('strips relationship + name pattern', () {
        final result = PiiStripper.strip('my sister Maria called');
        expect(result, contains('[name removed]'));
        expect(result, isNot(contains('Maria')));
      });

      test('strips agent name pattern', () {
        final result = PiiStripper.strip('my agent John Smith');
        expect(result, contains('[name removed]'));
        expect(result, isNot(contains('John Smith')));
      });

      test('strips alternate agent name pattern', () {
        final result = PiiStripper.strip('my alternate agent Mary Jones');
        expect(result, contains('[name removed]'));
        expect(result, isNot(contains('Mary Jones')));
      });

      test('strips guardian name', () {
        final result = PiiStripper.strip('my guardian Tom Williams');
        expect(result, contains('[name removed]'));
      });

      test('strips pastor/minister name', () {
        final result = PiiStripper.strip('my pastor David Lee');
        expect(result, contains('[name removed]'));
      });

      test('preserves non-name capitalized words', () {
        const input = 'I live in Pennsylvania and need help.';
        expect(PiiStripper.strip(input), input);
      });
    });

    group('"my name is" pattern stripping', () {
      test('strips "my name is First Last"', () {
        final result = PiiStripper.strip('my name is John Smith');
        expect(result, contains('[name removed]'));
        expect(result, isNot(contains('John Smith')));
      });

      test('strips "I am First Last"', () {
        final result = PiiStripper.strip('I am Jane Doe');
        expect(result, contains('[name removed]'));
        expect(result, isNot(contains('Jane Doe')));
      });

      test('strips "I, First Last," pattern', () {
        final result = PiiStripper.strip('I, Michael Brown, hereby declare');
        expect(result, contains('[name removed]'));
        expect(result, isNot(contains('Michael Brown')));
      });

      test('strips lowercase "my name is" with trailing punctuation', () {
        final result = PiiStripper.strip('my name is john smith.');
        expect(result, contains('[name removed]'));
        expect(result, isNot(contains('john smith')));
      });

      test('does not strip "I am feeling better"', () {
        const input = 'I am feeling better after treatment.';
        expect(PiiStripper.strip(input), input);
      });
    });

    group('alias pattern stripping', () {
      test('strips "named [Name]"', () {
        final result = PiiStripper.strip('a person named John');
        expect(result, contains('[name removed]'));
      });

      test('strips "known as [Name]"', () {
        final result = PiiStripper.strip('known as Bobby Jones');
        expect(result, contains('[name removed]'));
      });
    });

    group('patient name stripping', () {
      test('strips "patient: Name"', () {
        final result = PiiStripper.strip('Patient: John Smith');
        expect(result, contains('[patient name removed]'));
      });

      test('strips "witness: Name"', () {
        final result = PiiStripper.strip('Witness: Mary Johnson');
        expect(result, contains('[patient name removed]'));
      });

      test('strips "agent: Name"', () {
        final result = PiiStripper.strip('Agent: Robert Williams');
        expect(result, contains('[patient name removed]'));
      });
    });

    group('credit card number stripping', () {
      test('strips card number with spaces', () {
        final result = PiiStripper.strip('Card: 4111 1111 1111 1111');
        expect(result, contains('[card number removed]'));
        expect(result, isNot(contains('4111')));
      });

      test('strips card number with dashes', () {
        final result = PiiStripper.strip('CC 4111-1111-1111-1111');
        expect(result, contains('[card number removed]'));
      });

      test('strips labeled bare card number', () {
        final result =
            PiiStripper.strip('card number: 4111111111111111');
        expect(result, contains('[card number removed]'));
      });
    });

    group('Medicare/Medicaid ID stripping', () {
      test('strips Medicare ID with label', () {
        final result =
            PiiStripper.strip('Medicare ID: 1EG4TE5MK72');
        expect(result, contains('[Medicare ID removed]'));
        expect(result, isNot(contains('1EG4')));
      });

      test('strips MBI with dashes', () {
        final result = PiiStripper.strip('MBI 1EG4-TE5-MK72');
        expect(result, contains('[Medicare ID removed]'));
      });
    });

    group("driver's license stripping", () {
      test('strips DL number', () {
        final result =
            PiiStripper.strip("driver's license: 12345678");
        expect(result, contains('[license removed]'));
        expect(result, isNot(contains('12345678')));
      });

      test('strips DL abbreviation', () {
        final result = PiiStripper.strip('DL# A1234567');
        expect(result, contains('[license removed]'));
      });
    });

    group('passport number stripping', () {
      test('strips passport number', () {
        final result =
            PiiStripper.strip('passport number: AB1234567');
        expect(result, contains('[passport removed]'));
        expect(result, isNot(contains('AB1234567')));
      });
    });

    group('combined stripping', () {
      test('strips multiple PII types in one message', () {
        final input = 'My name is John, SSN 123-45-6789, '
            'email john@example.com, phone (215) 555-1234';
        final result = PiiStripper.strip(input);
        expect(result, isNot(contains('123-45-6789')));
        expect(result, isNot(contains('john@example.com')));
        expect(result, isNot(contains('555-1234')));
      });

      test('strips name + address + DOB together', () {
        final input = 'I am John Smith, born on 01/15/1990, '
            'living at 123 Main Street';
        final result = PiiStripper.strip(input);
        expect(result, isNot(contains('John Smith')));
        expect(result, isNot(contains('01/15/1990')));
        expect(result, isNot(contains('123 Main Street')));
      });

      test('preserves non-PII text', () {
        const input = 'I want my directive to include treatment preferences '
            'for medication and facility choices.';
        expect(PiiStripper.strip(input), input);
      });

      test('handles empty string', () {
        expect(PiiStripper.strip(''), '');
      });

      test('preserves medical content', () {
        const input = 'I take Lithium 300mg twice daily for bipolar disorder. '
            'I want to avoid Haldol due to side effects.';
        expect(PiiStripper.strip(input), input);
      });
    });

    group('stripWithReport', () {
      test('reports all stripped categories', () {
        final result = PiiStripper.stripWithReport(
          'My SSN is 123-45-6789 and email is test@example.com',
        );
        expect(result.hadPii, isTrue);
        expect(result.removedCategories, contains('SSN'));
        expect(result.removedCategories, contains('email address'));
      });

      test('reports empty for clean text', () {
        final result = PiiStripper.stripWithReport(
          'I prefer outpatient treatment.',
        );
        expect(result.hadPii, isFalse);
        expect(result.removedCategories, isEmpty);
      });
    });

    group('stripMapValues', () {
      test('strips PII from map values', () {
        final result = PiiStripper.stripMapValues({
          'Health history': 'Dr. Jane Smith treated me at 123 Oak Street',
          'Crisis plan': 'Call my sister Maria at (215) 555-1234',
        });
        expect(result.hadPii, isTrue);
        expect(result.sanitizedMap, isNotNull);
        expect(
            result.sanitizedMap!['Health history'],
            isNot(contains('Jane Smith')));
        expect(
            result.sanitizedMap!['Crisis plan'],
            isNot(contains('Maria')));
        expect(
            result.sanitizedMap!['Crisis plan'],
            isNot(contains('555-1234')));
      });

      test('preserves clean map values', () {
        final result = PiiStripper.stripMapValues({
          'Activities': 'Walking, reading, music therapy',
        });
        expect(result.hadPii, isFalse);
        expect(
            result.sanitizedMap!['Activities'],
            'Walking, reading, music therapy');
      });
    });

    group('detect', () {
      test('detects PII categories without stripping', () {
        final found = PiiStripper.detect(
          'SSN 123-45-6789, email test@example.com',
        );
        expect(found, contains('SSN'));
        expect(found, contains('email address'));
      });

      test('returns empty for clean text', () {
        expect(PiiStripper.detect('I prefer quiet environments'), isEmpty);
      });
    });
  });
}
