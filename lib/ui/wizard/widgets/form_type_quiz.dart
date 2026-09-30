import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/step_dots.dart';

/// Interactive 4-question quiz that recommends a form type.
///
/// Visual model from the v2 Claude Design prototype (`MobileExtra · quiz`):
/// editorial italic question with one keyword in primary, 4 radio Opt cards
/// per question, a "So far we think you want…" preview card with confidence
/// meter, and a stacked-bar result screen with a retake control.
///
/// Returns the chosen [FormType] when the user accepts the recommendation,
/// or null if cancelled.
Future<FormType?> showFormTypeQuiz(BuildContext context) {
  return showDialog<FormType>(
    context: context,
    builder: (ctx) => const _QuizDialog(),
  );
}

class _QuizDialog extends StatefulWidget {
  const _QuizDialog();

  @override
  State<_QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<_QuizDialog> {
  /// Current question (0-3) or 4 = result screen.
  int _step = 0;

  /// Selected option per question (null = not yet answered).
  final List<int?> _picks = [null, null, null, null];

  /// Pending auto-advance after an option tap (artboard `WebQuiz` behaviour).
  Timer? _advanceTimer;

  List<_QuizQuestion> get _questions => _QuizQuestions.all(context.l10n);

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  /// Tapping an option selects it and auto-advances after a short beat — the
  /// artboard `WebQuiz` flow has no per-question Continue button. Re-tapping a
  /// different option before the beat elapses resets the timer.
  void _pick(int q, int o) {
    setState(() => _picks[q] = o);
    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _step = (_step + 1).clamp(0, _questions.length));
    });
  }

  void _back() {
    _advanceTimer?.cancel();
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _step = (_step - 1).clamp(0, _questions.length);
    });
  }

  void _retake() {
    _advanceTimer?.cancel();
    setState(() {
      _step = 0;
      for (var i = 0; i < _picks.length; i++) {
        _picks[i] = null;
      }
    });
  }

  /// Running confidence score per form type, based on the answers given so
  /// far (each option carries weights). Higher = more confident.
  Map<FormType, int> get _scores {
    final map = <FormType, int>{
      FormType.combined: 0,
      FormType.declaration: 0,
      FormType.poa: 0,
    };
    for (var q = 0; q < _picks.length; q++) {
      final picked = _picks[q];
      if (picked == null) continue;
      final w = _questions[q].options[picked].weights;
      w.forEach((k, v) => map[k] = (map[k] ?? 0) + v);
    }
    return map;
  }

  FormType get _leader {
    final s = _scores;
    if (s.values.every((v) => v == 0)) return FormType.combined;
    return s.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;

    // Constrain to a reasonable size on tablet/desktop; full-bleed on phone.
    return Dialog(
      backgroundColor: p.scaffoldBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.sheetRadius)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 720),
        child: _step >= _questions.length
            ? _ResultBody(
                leader: _leader,
                scores: _scores,
                onRetake: _retake,
                onUse: () => Navigator.pop(context, _leader),
              )
            : _QuestionBody(
                step: _step,
                total: _questions.length,
                question: _questions[_step],
                picked: _picks[_step],
                onPick: (o) => _pick(_step, o),
                onBack: _back,
              ),
      ),
    );
  }
}

// ─── Question body ──────────────────────────────────────────────────────

class _QuestionBody extends StatelessWidget {
  final int step;
  final int total;
  final _QuizQuestion question;
  final int? picked;
  final ValueChanged<int> onPick;
  final VoidCallback onBack;

  const _QuestionBody({
    required this.step,
    required this.total,
    required this.question,
    required this.picked,
    required this.onPick,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header — back row + step dots + "question N of 4" eyebrow
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                tooltip: step == 0 ? context.l10n.cancel : context.l10n.back,
                onPressed: onBack,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    context.l10n.quizQuestionEyebrow(step + 1, total),
                    style: TextStyle(
                      fontFamily: kMonoFamily,
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace'
                      ],
                      fontSize: 11,
                      letterSpacing: 1,
                      color: p.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40), // keep title centered
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: StepDots(current: step + 1, total: total),
        ),

        // Scrollable body
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            children: [
              SectionLabel(context.l10n.quizInYourWords),
              const SizedBox(height: 8),
              EditorialHeading(
                textSpan: _editorialFor(question.headline, p.primary),
                size: 26,
                height: 1.15,
              ),
              const SizedBox(height: 6),
              Text(
                question.sub,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 14,
                  color: p.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < question.options.length; i++) ...[
                _OptCard(
                  label: question.options[i].label,
                  hint: question.options[i].hint,
                  selected: picked == i,
                  onTap: () => onPick(i),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Build a text span that colors the keywords (wrapped in `**…**`) primary.
  TextSpan _editorialFor(String headline, Color primary) {
    final parts = headline.split('**');
    final spans = <InlineSpan>[];
    for (var i = 0; i < parts.length; i++) {
      final isKeyword = i.isOdd;
      spans.add(TextSpan(
        text: parts[i],
        style: isKeyword ? TextStyle(color: primary) : null,
      ));
    }
    return TextSpan(children: spans);
  }
}

class _OptCard extends StatelessWidget {
  final String label;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  const _OptCard({
    required this.label,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? p.primaryTint : p.card,
          border: Border.all(
            color: selected ? p.primary : p.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? p.primary : p.border,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: p.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                      height: 1.3,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(height: 4),
                    Text(
                      hint,
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 13,
                        color: p.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Result body ────────────────────────────────────────────────────────

class _ResultBody extends StatelessWidget {
  final FormType leader;
  final Map<FormType, int> scores;
  final VoidCallback onRetake;
  final VoidCallback onUse;

  const _ResultBody({
    required this.leader,
    required this.scores,
    required this.onRetake,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final total = scores.values.fold<int>(0, (a, b) => a + b);
    int pctFor(FormType t) =>
        total == 0 ? 0 : (((scores[t] ?? 0) / total) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                tooltip: context.l10n.cancel,
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    context.l10n.quizResultEyebrow,
                    style: TextStyle(
                      fontFamily: kMonoFamily,
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace'
                      ],
                      fontSize: 11,
                      letterSpacing: 1,
                      color: p.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            children: [
              SectionLabel(context.l10n.quizRecommendedForYou),
              const SizedBox(height: 8),
              EditorialHeading(
                textSpan: TextSpan(
                  children: [
                    TextSpan(text: context.l10n.quizYouProbablyWant),
                    TextSpan(
                      text: _formName(context, leader),
                      style: TextStyle(color: p.primary),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                size: 30,
                height: 1.1,
              ),
              const SizedBox(height: 8),
              Text(
                _explanation(context, leader),
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 14,
                  color: p.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),

              // Stacked confidence bar with three segments
              ClipRRect(
                borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      Expanded(
                        flex: pctFor(FormType.combined).clamp(1, 100),
                        child: Container(color: p.primary),
                      ),
                      Expanded(
                        flex: pctFor(FormType.declaration).clamp(1, 100),
                        child: Container(color: p.primaryMid),
                      ),
                      Expanded(
                        flex: pctFor(FormType.poa).clamp(1, 100),
                        child: Container(color: p.primaryLight),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _LegendRow(
                color: p.primary,
                label: context.l10n.quizLegendCombined,
                pct: pctFor(FormType.combined),
                emphasized: leader == FormType.combined,
              ),
              _LegendRow(
                color: p.primaryMid,
                label: context.l10n.quizLegendDeclaration,
                pct: pctFor(FormType.declaration),
                emphasized: leader == FormType.declaration,
              ),
              _LegendRow(
                color: p.primaryLight,
                label: context.l10n.quizLegendPoa,
                pct: pctFor(FormType.poa),
                emphasized: leader == FormType.poa,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          decoration: BoxDecoration(
            color: p.card,
            border: Border(top: BorderSide(color: p.border)),
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: onRetake,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(context.l10n.quizRetake),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: onUse,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(context.l10n.quizUseForm(_formName(context, leader))),
                style: FilledButton.styleFrom(
                  iconAlignment: IconAlignment.end,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formName(BuildContext context, FormType t) => switch (t) {
        FormType.combined => context.l10n.quizFormNameCombined,
        FormType.declaration => context.l10n.quizFormNameDeclaration,
        FormType.poa => context.l10n.quizFormNamePoa,
      };

  String _explanation(BuildContext context, FormType type) => switch (type) {
        FormType.combined => context.l10n.quizExplainCombined,
        FormType.poa => context.l10n.quizExplainPoa,
        FormType.declaration => context.l10n.quizExplainDeclaration,
      };
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int pct;
  final bool emphasized;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.pct,
    required this.emphasized,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 13,
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
                color: emphasized ? p.text : p.textMuted,
              ),
            ),
          ),
          Text(
            '$pct%',
            style: TextStyle(
              fontFamily: kMonoFamily,
              fontFamilyFallback: const [
                'Consolas',
                'Menlo',
                'Courier New',
                'monospace'
              ],
              fontSize: 12,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
              color: emphasized ? p.text : p.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Question + scoring data ────────────────────────────────────────────

class _QuizOption {
  final String label;
  final String hint;
  final Map<FormType, int> weights;
  const _QuizOption({
    required this.label,
    required this.hint,
    required this.weights,
  });
}

class _QuizQuestion {
  final String headline; // wrap keywords in **…** for primary color
  final String sub;
  final List<_QuizOption> options;
  const _QuizQuestion({
    required this.headline,
    required this.sub,
    required this.options,
  });
}

class _QuizQuestions {
  static List<_QuizQuestion> all(AppLocalizations l) => [
    _QuizQuestion(
      headline: l.quizQ1Headline,
      sub: l.quizQ1Sub,
      options: [
        _QuizOption(
          label: l.quizQ1O1Label,
          hint: l.quizQ1O1Hint,
          weights: {FormType.combined: 2, FormType.poa: 2},
        ),
        _QuizOption(
          label: l.quizQ1O2Label,
          hint: l.quizQ1O2Hint,
          weights: {FormType.combined: 3},
        ),
        _QuizOption(
          label: l.quizQ1O3Label,
          hint: l.quizQ1O3Hint,
          weights: {FormType.declaration: 3},
        ),
        _QuizOption(
          label: l.quizQ1O4Label,
          hint: l.quizQ1O4Hint,
          weights: {FormType.combined: 1},
        ),
      ],
    ),
    _QuizQuestion(
      headline: l.quizQ2Headline,
      sub: l.quizQ2Sub,
      options: [
        _QuizOption(
          label: l.quizQ2O1Label,
          hint: l.quizQ2O1Hint,
          weights: {FormType.combined: 3, FormType.declaration: 2},
        ),
        _QuizOption(
          label: l.quizQ2O2Label,
          hint: l.quizQ2O2Hint,
          weights: {FormType.combined: 2, FormType.poa: 1},
        ),
        _QuizOption(
          label: l.quizQ2O3Label,
          hint: l.quizQ2O3Hint,
          weights: {FormType.poa: 3},
        ),
        _QuizOption(
          label: l.quizQ2O4Label,
          hint: l.quizQ2O4Hint,
          weights: {FormType.combined: 1},
        ),
      ],
    ),
    _QuizQuestion(
      headline: l.quizQ3Headline,
      sub: l.quizQ3Sub,
      options: [
        _QuizOption(
          label: l.quizQ3O1Label,
          hint: l.quizQ3O1Hint,
          weights: {FormType.declaration: 3, FormType.combined: 1},
        ),
        _QuizOption(
          label: l.quizQ3O2Label,
          hint: l.quizQ3O2Hint,
          weights: {FormType.poa: 3, FormType.combined: 1},
        ),
        _QuizOption(
          label: l.quizQ3O3Label,
          hint: l.quizQ3O3Hint,
          weights: {FormType.combined: 3},
        ),
        _QuizOption(
          label: l.quizQ3O4Label,
          hint: l.quizQ3O4Hint,
          weights: {FormType.combined: 1},
        ),
      ],
    ),
    _QuizQuestion(
      headline: l.quizQ4Headline,
      sub: l.quizQ4Sub,
      options: [
        _QuizOption(
          label: l.quizQ4O1Label,
          hint: l.quizQ4O1Hint,
          weights: {FormType.combined: 2, FormType.poa: 2},
        ),
        _QuizOption(
          label: l.quizQ4O2Label,
          hint: l.quizQ4O2Hint,
          weights: {FormType.combined: 2, FormType.declaration: 2},
        ),
        _QuizOption(
          label: l.quizQ4O3Label,
          hint: l.quizQ4O3Hint,
          weights: {FormType.combined: 3},
        ),
        _QuizOption(
          label: l.quizQ4O4Label,
          hint: l.quizQ4O4Hint,
          weights: {FormType.combined: 1},
        ),
      ],
    ),
  ];
}
