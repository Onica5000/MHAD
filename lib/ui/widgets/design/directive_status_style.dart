import 'package:flutter/material.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Display label for a directive's `status` string (Draft / Active / Expired /
/// Revoked). Previously an inline ternary chain in past-detail.
String directiveStatusLabel(String status, AppLocalizations l) {
  if (status == DirectiveStatus.revoked.name) return l.directiveStatusRevoked;
  if (status == DirectiveStatus.expired.name) return l.directiveStatusExpired;
  if (status == DirectiveStatus.complete.name) return l.directiveStatusActive;
  return l.directiveStatusDraft;
}

/// Accent color for a directive's status, dark-mode aware.
Color directiveStatusColor(String status, {required bool dark}) {
  if (status == DirectiveStatus.revoked.name) {
    return dark
        ? SemanticColors.errorAccentDark
        : SemanticColors.errorAccentLight;
  }
  if (status == DirectiveStatus.expired.name) {
    return dark
        ? SemanticColors.warningTextDark
        : SemanticColors.warningTextLight;
  }
  return dark
      ? SemanticColors.successTextDark
      : SemanticColors.successTextLight;
}
