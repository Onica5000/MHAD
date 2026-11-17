import 'dart:io';

import 'package:flutter/services.dart';

/// Load the app's bundled fonts into the test engine, so layout tests measure
/// text with DM Sans / Instrument Serif / JetBrains Mono / Atkinson
/// Hyperlegible instead of the default test font (Ahem), which draws every
/// glyph as a full em square and flags "overflows" that never happen in the
/// app. One definition for every layout test.
Future<void> loadRealFonts() async {
  const families = {
    'DM Sans': [
      'DMSans-Regular',
      'DMSans-Medium',
      'DMSans-SemiBold',
      'DMSans-Bold',
    ],
    'Instrument Serif': ['InstrumentSerif-Regular', 'InstrumentSerif-Italic'],
    'JetBrains Mono': [
      'JetBrainsMono-Regular',
      'JetBrainsMono-Medium',
      'JetBrainsMono-SemiBold',
    ],
    'Atkinson Hyperlegible': [
      'AtkinsonHyperlegible-Regular',
      'AtkinsonHyperlegible-Bold',
    ],
  };
  for (final e in families.entries) {
    final loader = FontLoader(e.key);
    for (final file in e.value) {
      final bytes = File('assets/fonts/$file.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}
