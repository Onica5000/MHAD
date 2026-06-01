import 'package:flutter/material.dart';
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

  static const _questions = _QuizQuestions.all;

  void _pick(int q, int o) {
    setState(() {
      _picks[q] = o;
    });
  }

  void _next() {
    if (_picks[_step] == null) return;
    setState(() {
      _step = (_step + 1).clamp(0, _questions.length);
    });
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _step = (_step - 1).clamp(0, _questions.length);
    });
  }

  void _retake() {
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

  int get _confidencePct {
    final s = _scores;
    final total = s.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return 0;
    final leaderScore = s[_leader] ?? 0;
    return ((leaderScore / total) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;

    // Constrain to a reasonable size on tablet/desktop; full-bleed on phone.
    return Dialog(
      backgroundColor: p.scaffoldBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                onContinue: _next,
                leader: _leader,
                confidencePct: _confidencePct,
                anyPicked: _picks.any((e) => e != null),
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
  final VoidCallback onContinue;
  final FormType leader;
  final int confidencePct;
  final bool anyPicked;

  const _QuestionBody({
    required this.step,
    required this.total,
    required this.question,
    required this.picked,
    required this.onPick,
    required this.onBack,
    required this.onContinue,
    required this.leader,
    required this.confidencePct,
    required this.anyPicked,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header — back row + step dots + "question N of 4" eyebrow
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                tooltip: step == 0 ? 'Cancel' : 'Back',
                onPressed: onBack,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Help me choose · question ${step + 1} of $total',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace'
                      ],
                      fontSize: 10.5,
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
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
            children: [
              const SectionLabel('In your words'),
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
                  fontFamily: 'DM Sans',
                  fontSize: 13.5,
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
              if (anyPicked) ...[
                const SizedBox(height: 12),
                _LeaningPreview(leader: leader, confidencePct: confidencePct),
              ],
            ],
          ),
        ),

        // Footer
        Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
          decoration: BoxDecoration(
            color: p.card,
            border: Border(top: BorderSide(color: p.border)),
          ),
          child: Row(
            children: [
              TextButton(
                onPressed: onBack,
                child: Text(step == 0 ? 'Cancel' : 'Back'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: picked != null ? onContinue : null,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(step == total - 1 ? 'See result' : 'Continue'),
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
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? p.primaryTint : p.card,
          border: Border.all(
            color: selected ? p.primary : p.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
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
                      fontFamily: 'DM Sans',
                      fontSize: 14.5,
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
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
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

class _LeaningPreview extends StatelessWidget {
  final FormType leader;
  final int confidencePct;
  const _LeaningPreview({required this.leader, required this.confidencePct});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.primaryTint,
        border: Border.all(color: p.primaryLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 14, color: p.primary),
              const SizedBox(width: 6),
              Text(
                'So far we think you want',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontFamilyFallback: const [
                    'Consolas',
                    'Menlo',
                    'Courier New',
                    'monospace'
                  ],
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: p.textMuted,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _leaderHeadline(leader),
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: p.text,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                value: (confidencePct / 100).clamp(0.0, 1.0),
                backgroundColor: p.border,
                valueColor: AlwaysStoppedAnimation(p.primary),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$confidencePct% confident',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontFamilyFallback: const [
                'Consolas',
                'Menlo',
                'Courier New',
                'monospace'
              ],
              fontSize: 10,
              letterSpacing: 0.6,
              color: p.textMuted,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  String _leaderHeadline(FormType t) => switch (t) {
        FormType.combined => 'Combined form (agents + preferences)',
        FormType.declaration => 'Declaration only (preferences, no agent)',
        FormType.poa => 'Power of Attorney (agent, no preferences)',
      };
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
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                tooltip: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Help me choose · result',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace'
                      ],
                      fontSize: 10.5,
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
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
            children: [
              const SectionLabel('Recommended for you'),
              const SizedBox(height: 8),
              EditorialHeading(
                textSpan: TextSpan(
                  children: [
                    const TextSpan(text: 'You probably want\n'),
                    TextSpan(
                      text: _formName(leader),
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
                _explanation(leader),
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  color: p.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),

              // Stacked confidence bar with three segments
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
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
                label: 'Combined',
                pct: pctFor(FormType.combined),
                emphasized: leader == FormType.combined,
              ),
              _LegendRow(
                color: p.primaryMid,
                label: 'Declaration only',
                pct: pctFor(FormType.declaration),
                emphasized: leader == FormType.declaration,
              ),
              _LegendRow(
                color: p.primaryLight,
                label: 'Power of Attorney only',
                pct: pctFor(FormType.poa),
                emphasized: leader == FormType.poa,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
          decoration: BoxDecoration(
            color: p.card,
            border: Border(top: BorderSide(color: p.border)),
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: onRetake,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retake'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: onUse,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text('Use ${_formName(leader)}'),
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

  String _formName(FormType t) => switch (t) {
        FormType.combined => 'Combined',
        FormType.declaration => 'Declaration',
        FormType.poa => 'POA',
      };

  String _explanation(FormType type) => switch (type) {
        FormType.combined =>
          'Includes both your treatment preferences AND an agent designation. '
              'The most comprehensive option — and what most people choose.',
        FormType.poa =>
          'Designates an agent to make decisions for you, without locking in '
              'specific treatment preferences. Best when you trust someone '
              'completely and want them to decide in the moment.',
        FormType.declaration =>
          'Documents your treatment preferences without naming an agent. '
              'Your treatment team will follow your written wishes directly.',
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
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
                color: emphasized ? p.text : p.textMuted,
              ),
            ),
          ),
          Text(
            '$pct%',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
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
  static const all = <_QuizQuestion>[
    _QuizQuestion(
      headline: "Do you have someone in mind to **speak for you**?",
      sub: 'A family member, partner, or close friend who could make '
          "treatment decisions if you can't.",
      options: [
        _QuizOption(
          label: 'Yes — and I trust them completely',
          hint: 'You probably want a Combined or POA-only form.',
          weights: {FormType.combined: 2, FormType.poa: 2},
        ),
        _QuizOption(
          label: 'Yes, but I want to set firm limits',
          hint: 'Combined gives you both an agent and a binding declaration.',
          weights: {FormType.combined: 3},
        ),
        _QuizOption(
          label: 'No — I want providers to follow my written wishes',
          hint: 'Declaration-only is for you.',
          weights: {FormType.declaration: 3},
        ),
        _QuizOption(
          label: "I'm not sure yet",
          hint: "No problem — we can come back to this.",
          weights: {FormType.combined: 1},
        ),
      ],
    ),
    _QuizQuestion(
      headline:
          "Do you want to **write down** specific treatment preferences?",
      sub: 'Medications, facilities, ECT, experimental studies, drug trials.',
      options: [
        _QuizOption(
          label: 'Yes — I have specific things I want or refuse',
          hint: 'You probably want a Combined or Declaration form.',
          weights: {FormType.combined: 3, FormType.declaration: 2},
        ),
        _QuizOption(
          label: "Some preferences, but I'd rather my agent decide",
          hint: 'Combined still works — agent decides where you didn\'t write.',
          weights: {FormType.combined: 2, FormType.poa: 1},
        ),
        _QuizOption(
          label: "No — let my agent or doctors decide everything",
          hint: 'Power of Attorney only is the lightest path.',
          weights: {FormType.poa: 3},
        ),
        _QuizOption(
          label: "I'm not sure yet",
          hint: "No problem — Combined leaves both doors open.",
          weights: {FormType.combined: 1},
        ),
      ],
    ),
    _QuizQuestion(
      headline:
          "If you can't decide, **whose voice** should reach the doctors first?",
      sub: 'The directive you write today, or the person you trust?',
      options: [
        _QuizOption(
          label: "What I wrote — even over what someone says in the moment",
          hint: 'Declaration-only or Combined with strong written preferences.',
          weights: {FormType.declaration: 3, FormType.combined: 1},
        ),
        _QuizOption(
          label: 'My agent — they can read the situation in real time',
          hint: 'POA-only or Combined where the agent has broad authority.',
          weights: {FormType.poa: 3, FormType.combined: 1},
        ),
        _QuizOption(
          label: 'Both — what I wrote, with my agent filling gaps',
          hint: 'Combined is the strongest fit.',
          weights: {FormType.combined: 3},
        ),
        _QuizOption(
          label: "I'm not sure yet",
          hint: "No problem — Combined supports both pathways.",
          weights: {FormType.combined: 1},
        ),
      ],
    ),
    _QuizQuestion(
      headline:
          "What's the **most important** thing this document does for you?",
      sub: 'There\'s no wrong answer — this just confirms what we\'re seeing.',
      options: [
        _QuizOption(
          label: 'Names who I trust to speak for me',
          hint: 'Combined or POA-only.',
          weights: {FormType.combined: 2, FormType.poa: 2},
        ),
        _QuizOption(
          label: 'Locks in specific treatments I want — or refuse',
          hint: 'Combined or Declaration-only.',
          weights: {FormType.combined: 2, FormType.declaration: 2},
        ),
        _QuizOption(
          label: 'Both — equally',
          hint: 'Combined.',
          weights: {FormType.combined: 3},
        ),
        _QuizOption(
          label: "Just having something on file",
          hint: 'Any form works. Combined gives the broadest coverage.',
          weights: {FormType.combined: 1},
        ),
      ],
    ),
  ];
}
