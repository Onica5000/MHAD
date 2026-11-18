// Runs before every test file (Flutter's test-config convention).
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/handoff/ai_handoff_data.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/ui/widgets/design/art_image.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Widget tests must not decode the real 47 photos: it is slow under the
  // fake clock and makes tests depend on asset files (review R12). ArtImage
  // paints its tinted placeholder instead. test/unit/app_art_test.dart
  // checks the real files separately.
  ArtImage.debugUsePlaceholders = true;

  // The Learn articles, as main() loads them before runApp. Without this,
  // every widget test rendered Learn's "No results found" state — so the
  // layout tests never saw the real Learn page (a Spanish search-hint
  // overflow there went unnoticed until a browser screenshot, 2026-11-17).
  TestWidgetsFlutterBinding.ensureInitialized();
  await EducationalContent.load();
  await AiHandoffData.load();

  await testMain();
}
