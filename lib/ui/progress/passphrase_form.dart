import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/services/passphrase/passphrase_lists.dart';
import 'package:mhad/services/passphrase/passphrase_policy.dart';
import 'package:mhad/services/passphrase/passphrase_strength.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// A chosen passphrase and how strong it is.
class ChosenPassphrase {
  const ChosenPassphrase(this.passphrase, this.estimate);
  final String passphrase;
  final PassphraseEstimate estimate;
}

/// The words for a crack-time bucket ("hours", "centuries").
String crackTimeLabel(AppLocalizations l, CrackTime t) => switch (t) {
      CrackTime.underAMinute => l.crackTimeUnderAMinute,
      CrackTime.minutes => l.crackTimeMinutes,
      CrackTime.hours => l.crackTimeHours,
      CrackTime.days => l.crackTimeDays,
      CrackTime.months => l.crackTimeMonths,
      CrackTime.years => l.crackTimeYears,
      CrackTime.centuries => l.crackTimeCenturies,
    };

/// Choosing a passphrase: the field, a second entry to catch typos, the
/// owner's rules as a live checklist (at least [kPassphraseMinLength]
/// characters, a lowercase letter, a capital, a symbol or space, not a common
/// passphrase — user decision 2026-11-18) and a strength gauge with how long
/// a guessing attack on a copied file could take.
///
/// [onChanged] gets the passphrase once every rule is met and both entries
/// match, else null.
class PassphraseForm extends StatefulWidget {
  const PassphraseForm({required this.onChanged, super.key});

  final ValueChanged<ChosenPassphrase?> onChanged;

  @override
  State<PassphraseForm> createState() => _PassphraseFormState();
}

class _PassphraseFormState extends State<PassphraseForm> {
  final _first = TextEditingController();
  final _second = TextEditingController();
  PassphraseLists? _lists;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    PassphraseLists.load().then((lists) {
      if (mounted) setState(() => _lists = lists);
    });
    _first.addListener(_changed);
    _second.addListener(_changed);
  }

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  Set<PassphraseRequirement> _unmet = PassphraseRequirement.values.toSet();
  PassphraseEstimate? _estimate;

  void _changed() {
    final lists = _lists;
    if (lists == null) return;
    final p = _first.text;
    setState(() {
      _unmet = unmetPassphraseRequirements(p, lists);
      _estimate = p.isEmpty ? null : estimatePassphrase(p, lists);
    });
    final ok = _unmet.isEmpty && p == _second.text && _estimate != null;
    widget.onChanged(ok ? ChosenPassphrase(p, _estimate!) : null);
  }

  String _ruleLabel(AppLocalizations l, PassphraseRequirement r) =>
      switch (r) {
        PassphraseRequirement.minLength =>
          l.passphraseRuleMinLength(kPassphraseMinLength),
        PassphraseRequirement.lowercase => l.passphraseRuleLowercase,
        PassphraseRequirement.uppercase => l.passphraseRuleUppercase,
        PassphraseRequirement.special => l.passphraseRuleSpecial,
        PassphraseRequirement.notCommon => l.passphraseRuleNotCommon,
      };

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          tooltip: _show ? context.l10n.passphraseHide : context.l10n.passphraseShow,
          icon: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: () => setState(() => _show = !_show),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (_lists == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final matches = _first.text.isNotEmpty && _first.text == _second.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _first,
          obscureText: !_show,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.visiblePassword,
          decoration: _decoration(l.passphraseFieldLabel),
        ),
        const SizedBox(height: 12),
        if (_estimate != null) StrengthGauge(estimate: _estimate!),
        const SizedBox(height: 16),
        TextField(
          controller: _second,
          obscureText: !_show,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.visiblePassword,
          decoration: _decoration(l.passphraseConfirmLabel),
        ),
        const SizedBox(height: 16),
        Text(l.passphraseNeeds, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final r in PassphraseRequirement.values)
          _Rule(label: _ruleLabel(l, r), met: !_unmet.contains(r)),
        _Rule(label: l.passphraseRuleMatch, met: matches),
        const SizedBox(height: 12),
        Text(l.passphraseTip, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.label, required this.met});
  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = Theme.of(context).mhadPalette;
    final color = met ? p.primary : p.textMuted;
    return Semantics(
      label: '$label: ${met ? l.passphraseRuleMet : l.passphraseRuleNotMet}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(met ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}

/// Four segments filled by strength (weak → strong), the level in words and
/// how long guessing a copied file could take. Never colour alone: the level
/// is always written out.
class StrengthGauge extends StatelessWidget {
  const StrengthGauge({required this.estimate, super.key});
  final PassphraseEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final p = theme.mhadPalette;
    final level = estimate.strength;
    final (name, color) = switch (level) {
      PassphraseStrength.weak => (
          l.passphraseStrengthWeak,
          dark ? SemanticColors.errorAccentDark : SemanticColors.errorAccentLight
        ),
      PassphraseStrength.fair => (
          l.passphraseStrengthFair,
          dark ? SemanticColors.warningTextDark : SemanticColors.warningTextLight
        ),
      PassphraseStrength.good => (l.passphraseStrengthGood, p.primary),
      PassphraseStrength.strong => (
          l.passphraseStrengthStrong,
          dark ? SemanticColors.successTextDark : SemanticColors.successTextLight
        ),
    };
    final title = l.passphraseStrength(name);
    final time = l.passphraseCrackTime(crackTimeLabel(l, estimate.crackTime));
    return Semantics(
      label: '$title. $time',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < PassphraseStrength.values.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: i <= level.index ? color : p.border,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(title,
              style: theme.textTheme.titleSmall?.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(time, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
