// Runs before every test file (Flutter's test-config convention).
import 'dart:async';

import 'package:mhad/ui/widgets/design/art_image.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Widget tests must not decode the real 47 photos: it is slow under the
  // fake clock and makes tests depend on asset files (review R12). ArtImage
  // paints its tinted placeholder instead. test/unit/app_art_test.dart
  // checks the real files separately.
  ArtImage.debugUsePlaceholders = true;
  await testMain();
}
