import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mhad/services/clinical_data_service.dart';
import 'package:mhad/utils/debouncer.dart';

/// A text field that provides medication name autocomplete suggestions
/// with dosage strengths from the NIH RxTerms API (free, no license needed).
class MedicationAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;

  /// Whether to offer strength chips in the suggestions. Only the "medications
  /// I currently take" section captures a strength; the preference sections
  /// (never / limitations / preferred) search by NAME only, to avoid confusion.
  final bool showStrengths;

  const MedicationAutocompleteField({
    required this.controller,
    this.labelText,
    this.showStrengths = true,
    super.key,
  });

  @override
  State<MedicationAutocompleteField> createState() =>
      _MedicationAutocompleteFieldState();
}

class _MedicationAutocompleteFieldState
    extends State<MedicationAutocompleteField> {
  final _debouncer = Debouncer();
  List<MedicationResult> _suggestions = [];
  bool _loading = false;
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  // Keyboard-highlighted suggestion row (-1 = none). Arrow keys move it,
  // Enter selects, Esc closes — the custom overlay was mouse-only before
  // (2026-07-11 UX audit A9).
  int _highlighted = -1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    _focusNode.onKeyEvent = _handleKey;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (_overlayEntry == null || _suggestions.isEmpty) {
      return KeyEventResult.ignored;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _highlighted = (_highlighted + 1) % _suggestions.length;
      _overlayEntry?.markNeedsBuild();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _highlighted =
          (_highlighted - 1 + _suggestions.length) % _suggestions.length;
      _overlayEntry?.markNeedsBuild();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter && _highlighted >= 0) {
      _selectMedication(_suggestions[_highlighted].name);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      _removeOverlay();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _debouncer.dispose();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Delay removal so overlay tap handlers fire before the overlay is gone.
      // Without this, tapping a suggestion on web loses focus first, removes
      // the overlay, and the tap never registers.
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _onTextChanged() {
    final text = widget.controller.text.trim();
    if (text.length < 2) {
      _debouncer.cancel();
      _removeOverlay();
      return;
    }
    _debouncer.run(() => _fetchSuggestions(text));
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() => _loading = true);
    try {
      final results =
          await ClinicalDataService.searchMedicationsWithStrengths(query,
              count: 8);
      if (mounted) {
        setState(() => _suggestions = results);
        _highlighted = -1;
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
                    final isNti = NtiDrugReference.isNti(med.name);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main medication name — tappable to select without strength
                        Semantics(
                          button: true,
                          label: 'Select medication ${med.name}'
                              '${isNti ? ', narrow therapeutic index drug' : ''}',
                          child: InkWell(
                            onTap: () => _selectMedication(med.name),
                            child: Container(
                              color: i == _highlighted
                                  ? cs.primaryContainer.withValues(alpha: 0.5)
                                  : null,
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
                                  if (isNti)
                                    Tooltip(
                                      message: 'Narrow Therapeutic Index (NTI) '
                                          'drug — no generic substitution in PA',
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: cs.tertiaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text('NTI',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: cs.onTertiaryContainer,
                                            )),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Strength chips — only where a strength is captured.
                        if (widget.showStrengths && med.strengths.isNotEmpty)
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
    _highlighted = -1;
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
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                      width: 16,
                      height: 16,
                      child: Semantics(
                          label: 'Searching medications',
                          child:
                              const CircularProgressIndicator(strokeWidth: 2))),
                )
              : widget.controller.text.isNotEmpty
                  ? const Icon(Icons.medication, size: 18)
                  : null,
        ),
      ),
    );
  }
}
