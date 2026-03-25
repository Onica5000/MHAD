import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mhad/services/clinical_data_service.dart';

/// A search bar that provides ICD-10 condition autocomplete suggestions
/// from the NIH Clinical Tables API. Selected conditions are appended to
/// the [targetController]'s text field.
class ConditionAutocompleteField extends StatefulWidget {
  /// The controller for the main text field where selected conditions
  /// will be appended.
  final TextEditingController targetController;

  const ConditionAutocompleteField({
    required this.targetController,
    super.key,
  });

  @override
  State<ConditionAutocompleteField> createState() =>
      _ConditionAutocompleteFieldState();
}

class _ConditionAutocompleteFieldState
    extends State<ConditionAutocompleteField> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<IcdCondition> _results = [];
  bool _loading = false;
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _searchCtrl.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _onTextChanged() {
    _debounce?.cancel();
    final text = _searchCtrl.text.trim();
    if (text.length < 2) {
      _removeOverlay();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(text);
    });
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    try {
      final results = await ClinicalDataService.searchConditions(query);
      if (mounted) {
        setState(() => _results = results);
        if (results.isNotEmpty && _focusNode.hasFocus) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
    } catch (_) {
      // Fail silently
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectCondition(IcdCondition condition) {
    final current = widget.targetController.text.trim();
    if (current.isEmpty) {
      widget.targetController.text = condition.name;
    } else {
      widget.targetController.text = '$current; ${condition.name}';
    }
    widget.targetController.selection = TextSelection.collapsed(
        offset: widget.targetController.text.length);
    _searchCtrl.clear();
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
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (ctx, i) {
                    final c = _results[i];
                    return Semantics(
                      button: true,
                      label: 'Select condition ${c.name}',
                      child: InkWell(
                        onTap: () => _selectCondition(c),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  c.code,
                                  style: textStyle.labelSmall?.copyWith(
                                    color: cs.onPrimaryContainer,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(c.name,
                                    style: textStyle.bodyMedium),
                              ),
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
      child: TextField(
        controller: _searchCtrl,
        focusNode: _focusNode,
        autofillHints: const [],
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: 'Search ICD-10 conditions',
          hintText: 'e.g., bipolar, anxiety, PTSD',
          border: const OutlineInputBorder(),
          isDense: true,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : null,
        ),
      ),
    );
  }
}
