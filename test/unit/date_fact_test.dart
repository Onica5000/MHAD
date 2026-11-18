import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mhad/data/app_data/app_data.dart';

/// Dated facts (the privacy policy's "Last updated") read in the person's
/// language: stored as yyyy-MM, shown as "November 2026" / "noviembre de
/// 2026". Free text (typed on the admin page) still shows as written.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('es');
  });

  AppData withDated(Map<String, String> dated) =>
      AppData.fromJson({'dated': dated});

  test('yyyy-MM reads as a month in each language', () {
    final d = withDated({'privacyPolicyUpdated': '2026-11'});
    expect(d.dateFactFor('privacyPolicyUpdated', 'en'), 'November 2026');
    expect(d.dateFactFor('privacyPolicyUpdated', 'es'), 'noviembre de 2026');
  });

  test('free text is shown as written', () {
    final d = withDated({'privacyPolicyUpdated': 'Sept 2026'});
    expect(d.dateFactFor('privacyPolicyUpdated', 'es'), 'Sept 2026');
  });
}
