import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// Loads the editorial typeface trio (DM Sans regular + bold, Instrument
/// Serif italic) as a `pw.ThemeData` so every generated PDF — the forms AND
/// the wallet card — inherits the same typography the app uses on screen.
/// Falls back to the default Helvetica theme if asset loading fails (e.g.
/// inside unit tests that do not initialise the Flutter test binding).
Future<pw.ThemeData?> loadEditorialTheme() async {
  try {
    final dmRegular =
        pw.Font.ttf(await rootBundle.load('assets/fonts/DMSans-Regular.ttf'));
    final dmBold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/DMSans-Bold.ttf'));
    final serifItalic = pw.Font.ttf(
        await rootBundle.load('assets/fonts/InstrumentSerif-Italic.ttf'));
    // boldItalic falls back to italic; that's fine for legal-form copy.
    return pw.ThemeData.withFont(
      base: dmRegular,
      bold: dmBold,
      italic: serifItalic,
    );
  } catch (e) {
    debugPrint('PDF theme: editorial fonts unavailable, '
        'falling back to default Helvetica: $e');
    return null;
  }
}
