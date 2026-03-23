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

      test('strips SSN without separators', () {
        expect(
          PiiStripper.strip('SSN 123456789 here'),
          'SSN [SSN removed] here',
        );
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
    });

    group('unlabeled date of birth stripping', () {
      test('strips "birthday is" pattern', () {
        final result = PiiStripper.strip('my birthday is 03/15/1960');
        expect(result, contains('[date of birth removed]'));
        expect(result, isNot(contains('03/15/1960')));
      });

      test('strips "I was born" pattern', () {
        final result = PiiStripper.strip('I was born 01-15-1990');
        expect(result, isNot(contains('01-15-1990')));
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

      test('preserves non-name capitalized words', () {
        // "Pennsylvania" should not be stripped as a name
        const input = 'I live in Pennsylvania and need help.';
        expect(PiiStripper.strip(input), input);
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

      test('preserves non-PII text', () {
        const input = 'I want my directive to include treatment preferences '
            'for medication and facility choices.';
        expect(PiiStripper.strip(input), input);
      });

      test('handles empty string', () {
        expect(PiiStripper.strip(''), '');
      });
    });
  });
}
