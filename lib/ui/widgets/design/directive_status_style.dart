import 'package:flutter/material.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Display label for a directive's `status` string (Draft / Active / Expired /
/// Revoked). Previously an inline ternary chain in past-detail.
String directiveStatusLabel(String status) {
  if (status == DirectiveStatus.revoked.name) return 'Revoked';
  if (status == DirectiveStatus.expired.name) return 'Expired';
  if (status == DirectiveStatus.complete.name) return 'Active';
  return 'Draft';
}

/// Accent color for a directive's status, dark-mode aware.
Color directiveStatusColor(String status, {required bool dark}) {
  final label = directiveStatusLabel(status);
  if (label == 'Revoked') {
    return dark
        ? SemanticColors.errorAccentDark
        : SemanticColors.errorAccentLight;
  }
  if (label == 'Expired') {
    return dark
        ? SemanticColors.warningTextDark
        : SemanticColors.warningTextLight;
  }
  return dark
      ? SemanticColors.successTextDark
      : SemanticColors.successTextLight;
}
