import 'package:flutter/material.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// A 4-pill row for picking a [ConsentOption]: Yes / No / Agent decides / If…
///
/// Matches the prototype's `ConsentRow`. The "Agent decides" option is hidden
/// when [hasAgent] is false (e.g. for Declaration-only forms).
class ConsentRow extends StatelessWidget {
  final ConsentOption? value;
  final ValueChanged<ConsentOption> onChanged;
  final bool hasAgent;
  final bool dense;

  const ConsentRow({
    required this.value,
    required this.onChanged,
    this.hasAgent = true,
    this.dense = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final options = <(ConsentOption, String)>[
      (ConsentOption.yes, 'Yes'),
      (ConsentOption.no, 'No'),
      if (hasAgent) (ConsentOption.agentDecides, 'Agent decides'),
      (ConsentOption.conditional, 'If…'),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (opt, label) in options)
          _ConsentChip(
            label: label,
            selected: value == opt,
            dense: dense,
            onTap: () => onChanged(opt),
          ),
      ],
    );
  }
}

class _ConsentChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool dense;
  final VoidCallback onTap;

  const _ConsentChip({
    required this.label,
    required this.selected,
    required this.dense,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: dense ? 12 : 14,
              vertical: dense ? 7 : 8,
            ),
            decoration: BoxDecoration(
              color: selected ? p.primary : Colors.transparent,
              border: Border.all(
                color: selected ? p.primary : p.border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: dense ? 12 : 12.5,
                fontWeight: FontWeight.w600,
                height: 1,
                color: selected ? p.onPrimary : p.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
