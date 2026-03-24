import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// A text field that provides medication name autocomplete suggestions
/// from the NIH RxTerms API (free, no license needed).
class MedicationAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;

  const MedicationAutocompleteField({
    required this.controller,
    this.labelText,
    super.key,
  });

  @override
  State<MedicationAutocompleteField> createState() =>
      _MedicationAutocompleteFieldState();
}

class _MedicationAutocompleteFieldState
    extends State<MedicationAutocompleteField> {
  Timer? _debounce;
  List<String> _suggestions = [];
  bool _loading = false;
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onTextChanged() {
    _debounce?.cancel();
    final text = widget.controller.text.trim();
    if (text.length < 2) {
      _removeOverlay();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _fetchSuggestions(text);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse(
          'https://clinicaltables.nlm.nih.gov/api/rxterms/v3/search'
          '?terms=${Uri.encodeComponent(query)}&count=8');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body) as List;
      // data[1] contains the flat array of display strings
      if (data.length >= 2 && data[1] is List) {
        final names = (data[1] as List).cast<String>();
        if (mounted) {
          setState(() => _suggestions = names);
          if (names.isNotEmpty && _focusNode.hasFocus) {
            _showOverlay();
          } else {
            _removeOverlay();
          }
        }
      }
    } catch (_) {
      // Fail silently — user can still type manually
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        width: context.size?.width ?? 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, (context.size?.height ?? 48) + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (ctx, i) => Semantics(
                  button: true,
                  label: 'Select medication ${_suggestions[i]}',
                  child: InkWell(
                    onTap: () {
                      widget.controller.text = _suggestions[i];
                      widget.controller.selection = TextSelection.collapsed(
                          offset: _suggestions[i].length);
                      _removeOverlay();
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Text(_suggestions[i],
                          style: Theme.of(ctx).textTheme.bodyMedium),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.labelText ?? 'Medication name',
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: _loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : widget.controller.text.isNotEmpty
                  ? const Icon(Icons.medication, size: 18)
                  : null,
        ),
      ),
    );
  }
}
