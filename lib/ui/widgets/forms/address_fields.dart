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
