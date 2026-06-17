import 'package:flutter/material.dart';
import 'package:mhad/utils/input_formatters.dart';

/// Standard address input: Address 1 · Address 2 · City · State · ZIP.
/// Used everywhere an address is collected (personal info, agents, guardian,
/// witnesses) so the layout, ZIP formatting (5 or 9 digits), and optionality
/// are identical. All fields are optional; only ZIP is validated when present.
class AddressFields extends StatelessWidget {
  final TextEditingController line1;
  final TextEditingController line2;
  final TextEditingController city;
  final TextEditingController state;
  final TextEditingController zip;

  /// Label for line 1 (default "Street address").
  final String line1Label;

  /// Vertical gap between fields.
  final double gap;

  const AddressFields({
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.zip,
    this.line1Label = 'Street address',
    this.gap = 12,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: line1,
          decoration: InputDecoration(
            labelText: line1Label,
            border: const OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: gap),
        TextFormField(
          controller: line2,
          decoration: const InputDecoration(
            labelText: 'Apt, suite, unit, etc.',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: gap),
        TextFormField(
          controller: city,
          decoration: const InputDecoration(
            labelText: 'City',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: gap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: state,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                maxLength: 2,
                buildCounter: (_,
                        {required currentLength,
                        required isFocused,
                        maxLength}) =>
                    null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: zip,
                decoration: const InputDecoration(
                  labelText: 'ZIP',
                  hintText: '12345 or 12345-6789',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: const [ZipInputFormatter()],
                validator: optionalZipValidator,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compose the address components into a single inline string for display /
/// machine export, e.g. "123 Main St, Apt 4, Philadelphia, PA 19103". Empty
/// parts are skipped. The "City, State ZIP" tail is assembled US-style.
String composeAddressInline({
  required String line1,
  String line2 = '',
  String city = '',
  String state = '',
  String zip = '',
}) {
  final parts = <String>[];
  if (line1.trim().isNotEmpty) parts.add(line1.trim());
  if (line2.trim().isNotEmpty) parts.add(line2.trim());
  final cityState = <String>[
    if (city.trim().isNotEmpty) city.trim(),
    [
      if (state.trim().isNotEmpty) state.trim(),
      if (zip.trim().isNotEmpty) zip.trim(),
    ].join(' ').trim(),
  ].where((s) => s.isNotEmpty).join(', ');
  if (cityState.isNotEmpty) parts.add(cityState);
  return parts.join(', ');
}

/// Compose the address components into display lines (street / apt on their own
/// lines, then "City, State ZIP"). Used by PDF rendering. Empty parts skipped.
List<String> composeAddressLines({
  required String line1,
  String line2 = '',
  String city = '',
  String state = '',
  String zip = '',
}) {
  final lines = <String>[];
  if (line1.trim().isNotEmpty) lines.add(line1.trim());
  if (line2.trim().isNotEmpty) lines.add(line2.trim());
  final cityState = <String>[
    if (city.trim().isNotEmpty) city.trim(),
    [
      if (state.trim().isNotEmpty) state.trim(),
      if (zip.trim().isNotEmpty) zip.trim(),
    ].join(' ').trim(),
  ].where((s) => s.isNotEmpty).join(', ');
  if (cityState.isNotEmpty) lines.add(cityState);
  return lines;
}
