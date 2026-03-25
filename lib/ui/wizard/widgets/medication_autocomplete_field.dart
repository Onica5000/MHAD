import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mhad/services/clinical_data_service.dart';

/// A text field that provides medication name autocomplete suggestions
/// with dosage strengths from the NIH RxTerms API (free, no license needed).
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
  List<MedicationResult> _suggestions = [];
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
      final results =
          await ClinicalDataService.searchMedicationsWithStrengths(query,
              count: 8);
      if (mounted) {
        setState(() => _suggestions = results);
        if (results.isNotEmpty && _focusNode.hasFocus) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
    } catch (_) {
      // Fail silently — user can still type manually
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectMedication(String value) {
    widget.controller.text = value;
    widget.controller.selection =
        TextSelection.collapsed(offset: value.length);
    _removeOverlay();
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final textStyle = Theme.of(ctx).textTheme;
        return Positioned(
          width: context.size?.width ?? 300,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, (context.size?.height ?? 48) + 4),
            child: Material(
              elevation: 4,
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (ctx, i) {
                    final med = _suggestions[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main medication name — tappable to select without strength
                        Semantics(
                          button: true,
                          label: 'Select medication ${med.name}',
                          child: InkWell(
                            onTap: () => _selectMedication(med.name),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                              child: Row(
                                children: [
                                  Icon(Icons.medication,
                                      size: 16, color: cs.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(med.name,
                                        style: textStyle.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Strength chips
                        if (med.strengths.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(36, 0, 12, 8),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: med.strengths.map((s) {
                                final display =
                                    '${med.name.split(' (').first} $s';
                                return Semantics(
                                  button: true,
                                  label: 'Select $display',
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _selectMedication(display),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: cs.primaryContainer,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        s,
                                        style: textStyle.labelSmall?.copyWith(
                                            color: cs.onPrimaryContainer),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        if (i < _suggestions.length - 1)
                          Divider(height: 1, color: cs.outlineVariant),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
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
        autofillHints: const [],
        autocorrect: false,
        enableSuggestions: false,
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
