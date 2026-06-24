import 'package:flutter/material.dart';
import 'package:mhad/services/geo_service.dart';
import 'package:mhad/utils/input_formatters.dart';

/// Standard address input: Address 1 · Address 2 · City · State · ZIP.
/// Used everywhere an address is collected (personal info, agents, guardian,
/// witnesses) so the layout, ZIP formatting (5 or 9 digits), and optionality
/// are identical. All fields are optional; only ZIP is validated when present.
///
/// The ZIP field offers a one-tap lookup that fills City + State from free,
/// keyless, CORS-safe public APIs (Zippopotam) — only the ZIP leaves the
/// browser. Fail-safe: any error just lets the user keep typing.
class AddressFields extends StatefulWidget {
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
  State<AddressFields> createState() => _AddressFieldsState();
}

class _AddressFieldsState extends State<AddressFields> {
  bool _lookingUp = false;

  Future<void> _lookupFromZip() async {
    final zip = widget.zip.text.replaceAll(RegExp(r'\D'), '');
    if (zip.length < 5) {
      _toast('Enter a 5-digit ZIP first.');
      return;
    }
    setState(() => _lookingUp = true);
    final geo = GeoService();
    final z = await geo.lookupZip(zip.substring(0, 5));
    geo.dispose();
    if (!mounted) return;
    setState(() {
      _lookingUp = false;
      if (z != null) {
        widget.city.text = z.city;
        if (z.stateAbbr.isNotEmpty) widget.state.text = z.stateAbbr;
      }
    });
    if (z == null) {
      _toast('Couldn\'t look up that ZIP — you can type it in.');
    } else {
      _toast(
          'Filled: ${[z.city, z.stateAbbr].where((s) => s.isNotEmpty).join(', ')}');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.line1,
          decoration: InputDecoration(
            labelText: widget.line1Label,
            border: const OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: widget.gap),
        TextFormField(
          controller: widget.line2,
          decoration: const InputDecoration(
            labelText: 'Apt, suite, unit, etc.',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: widget.gap),
        TextFormField(
          controller: widget.city,
          decoration: const InputDecoration(
            labelText: 'City',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: widget.gap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.state,
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
                controller: widget.zip,
                decoration: InputDecoration(
                  labelText: 'ZIP',
                  hintText: '12345 or 12345-6789',
                  helperText: 'Tap the icon to fill city & state',
                  border: const OutlineInputBorder(),
                  suffixIcon: _lookingUp
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.travel_explore),
                          tooltip: 'Fill city & state from ZIP',
                          onPressed: _lookupFromZip,
                        ),
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
