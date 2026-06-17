import 'package:flutter/services.dart';

/// Shared text-input formatters used across every form that collects a phone
/// number, ZIP code, or date, so the whole app standardizes on the same
/// formatting. All are forgiving (they never reject input) — validation of
/// completeness is left to the field's `validator`, and every such field is
/// optional.

/// Auto-formats phone input as `(123) 456-7890` while typing, capped at the
/// 10 significant digits.
class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length && i < 10; i++) {
      if (i == 0) buf.write('(');
      buf.write(digits[i]);
      if (i == 2) buf.write(') ');
      if (i == 5) buf.write('-');
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Auto-formats ZIP input as `12345` or `12345-6789` (5 or 5+4 digits).
class ZipInputFormatter extends TextInputFormatter {
  const ZipInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length && i < 9; i++) {
      if (i == 5) buf.write('-');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Auto-formats date input as `MM/DD/YYYY` while typing.
class DateInputFormatter extends TextInputFormatter {
  const DateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) buf.write('/');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Returns a phone validator error message, or null when valid/empty. Phone is
/// always optional, so empty passes; a non-empty value must have 10 digits.
String? optionalPhoneValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 10) return 'Enter a valid 10-digit phone number';
  return null;
}

/// Returns a ZIP validator error message, or null when valid/empty. ZIP is
/// always optional; a non-empty value must be 5 or 9 digits.
String? optionalZipValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 5 && digits.length != 9) {
    return 'Enter a 5-digit or 5+4-digit ZIP';
  }
  return null;
}
