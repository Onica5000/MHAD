import 'package:flutter/widgets.dart';
import 'package:mhad/l10n/app_localizations.dart';

export 'package:mhad/l10n/app_localizations.dart';

/// Ergonomic accessor for the generated localizations: `context.l10n.navHome`.
///
/// This is the ONLY sanctioned way to read UI strings (see CLAUDE.md
/// "Localization") — add the key to `app_en.arb`, run codegen, then use it
/// here. Keep new-key English values byte-identical to the shipped copy.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
