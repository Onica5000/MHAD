import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'onboarding_completed';

/// Optional first-time onboarding that explains what an MHAD is
/// and what the user should have ready. Shown once, then never again.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({required this.onComplete, super.key});

  /// Returns true if onboarding has been completed.
  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _PageData(
      icon: Icons.description_outlined,
      title: 'What is a Mental Health\nAdvance Directive?',
      body: 'A legal document that lets you state your preferences for '
          'mental health treatment in advance — so your wishes are '
          'respected even during a crisis when you may not be able to '
          'communicate them.\n\n'
          'Under Pennsylvania Act 194 of 2004, your MHAD is legally '
          'binding once signed and witnessed.',
    ),
    _PageData(
      icon: Icons.checklist,
      title: 'What You Can Include',
      body: '\u2022 Medications you want or don\'t want\n'
          '\u2022 Treatment facilities you prefer or want to avoid\n'
          '\u2022 Whether you consent to ECT, experimental studies, or drug trials\n'
          '\u2022 A trusted person (agent) to make decisions for you\n'
          '\u2022 Crisis intervention preferences\n'
          '\u2022 Dietary, religious, and cultural needs\n'
          '\u2022 Guardian nomination',
    ),
    _PageData(
      icon: Icons.inventory_2_outlined,
      title: 'What to Have Ready',
      body: 'To make filling out your directive easier, gather:\n\n'
          '\u2022 A list of your current medications\n'
          '\u2022 Names of your diagnoses or conditions\n'
          '\u2022 Contact info for your chosen agent\n'
          '\u2022 Names and contact info for two adult witnesses\n'
          '\u2022 Any medical documents (the app can import these)\n\n'
          'You can also fill it out over multiple sessions — your '
          'progress is saved automatically.',
    ),
    _PageData(
      icon: Icons.timer_outlined,
      title: 'How Long Does It Take?',
      body: 'Most people complete their directive in 20-40 minutes.\n\n'
          'The app offers Smart Fill to speed things up — select your '
          'conditions and medications, and AI fills the rest.\n\n'
          'You can also import data from medical documents (photos, '
          'PDFs) to auto-fill fields.\n\n'
          'Your directive is valid for 2 years once signed.',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (ctx, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(page.icon, size: 64, color: cs.primary),
                        const SizedBox(height: 24),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _page ? cs.primary : cs.surfaceContainerHighest,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLast
                      ? _finish
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  child: Text(isLast ? 'Get Started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageData {
  final IconData icon;
  final String title;
  final String body;
  const _PageData(
      {required this.icon, required this.title, required this.body});
}
