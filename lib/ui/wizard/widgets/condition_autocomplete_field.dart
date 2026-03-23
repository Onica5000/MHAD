import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// A text field that provides condition/diagnosis autocomplete suggestions
/// from the NIH ICD-10-CM Clinical Table Search Service (free, no license).
/// When the user picks a condition, the display name is inserted (not the code).
class ConditionAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final int? maxLines;
  final Widget? suffixIcon;

  const ConditionAutocompleteField({
    required this.controller,
    this.labelText,
    this.hintText,
    this.maxLines,
    this.suffixIcon,
    super.key,
  });

  @override
  State<ConditionAutocompleteField> createState() =>
      _ConditionAutocompleteFieldState();
}

class _ConditionAutocompleteFieldState
    extends State<ConditionAutocompleteField> {
  Timer? _debounce;
  List<_IcdResult> _suggestions = [];
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
    if (!_focusNode.hasFocus) _removeOverlay();
  }

  void _onTextChanged() {
    _debounce?.cancel();
    // Only search the last "phrase" — text after the last period or newline
    final text = widget.controller.text;
    final lastSep = text.lastIndexOf(RegExp(r'[.\n]'));
    final query = (lastSep >= 0 ? text.substring(lastSep + 1) : text).trim();

    if (query.length < 3) {
      _removeOverlay();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse(
          'https://clinicaltables.nlm.nih.gov/api/icd10cm/v3/search'
          '?sf=code,name&df=code,name'
          '&terms=${Uri.encodeComponent(query)}&count=8');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body) as List;
      if (data.length >= 4 && data[3] is List) {
        final results = (data[3] as List).map((item) {
          final arr = item as List;
          return _IcdResult(
            code: arr.isNotEmpty ? arr[0].toString() : '',
            name: arr.length > 1 ? arr[1].toString() : '',
          );
        }).toList();

        if (mounted) {
          setState(() => _suggestions = results);
          if (results.isNotEmpty && _focusNode.hasFocus) {
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
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (ctx, i) {
                  final r = _suggestions[i];
                  return Semantics(
                    button: true,
                    label: 'Select condition ${r.name}, code ${r.code}',
                    child: InkWell(
                    onTap: () {
                      _insertCondition(r.name);
                      _removeOverlay();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name,
                              style: Theme.of(ctx).textTheme.bodyMedium),
                          Text(r.code,
                              style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(ctx)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  )),
                        ],
                      ),
                    ),
                  ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _insertCondition(String name) {
    final text = widget.controller.text;
    final lastSep = text.lastIndexOf(RegExp(r'[.\n]'));
    final prefix = lastSep >= 0 ? '${text.substring(0, lastSep + 1)} ' : '';
    widget.controller.text = '$prefix$name';
    widget.controller.selection =
        TextSelection.collapsed(offset: widget.controller.text.length);
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
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          suffixIcon: _loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : widget.suffixIcon,
        ),
      ),
    );
  }
}

class _IcdResult {
  final String code;
  final String name;
  const _IcdResult({required this.code, required this.name});
}
