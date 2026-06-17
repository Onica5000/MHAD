// Composes standardized address components (line 1 / line 2 / city / state /
// ZIP) into display strings. Shared by the UI, PDF generators, and exports so
// an address reads identically everywhere. Empty parts are skipped.

String _cityStateZip(String city, String state, String zip) => <String>[
      if (city.trim().isNotEmpty) city.trim(),
      [
        if (state.trim().isNotEmpty) state.trim(),
        if (zip.trim().isNotEmpty) zip.trim(),
      ].join(' ').trim(),
    ].where((s) => s.isNotEmpty).join(', ');

/// One-line form: "123 Main St, Apt 4, Philadelphia, PA 19103".
String composeAddressInline({
  required String line1,
  String line2 = '',
  String city = '',
  String state = '',
  String zip = '',
}) {
  final parts = <String>[
    if (line1.trim().isNotEmpty) line1.trim(),
    if (line2.trim().isNotEmpty) line2.trim(),
  ];
  final tail = _cityStateZip(city, state, zip);
  if (tail.isNotEmpty) parts.add(tail);
  return parts.join(', ');
}

/// Multi-line form (street / apt on their own lines, then "City, State ZIP").
List<String> composeAddressLines({
  required String line1,
  String line2 = '',
  String city = '',
  String state = '',
  String zip = '',
}) {
  final lines = <String>[
    if (line1.trim().isNotEmpty) line1.trim(),
    if (line2.trim().isNotEmpty) line2.trim(),
  ];
  final tail = _cityStateZip(city, state, zip);
  if (tail.isNotEmpty) lines.add(tail);
  return lines;
}
