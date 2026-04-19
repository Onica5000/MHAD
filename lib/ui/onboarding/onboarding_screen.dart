import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';
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

  static const _pages = <_PageData>[
    _PageData(
      icon: Icons.description_outlined,
      title: 'Your Voice in a Crisis',
      body:
          'A Mental Health Advance Directive lets you document your treatment '
          'preferences now — so your wishes are respected even when you can\u2019t '
          'communicate them during a mental health crisis.\n\n'
          'Under Pennsylvania Act 194 of 2004, your MHAD is legally binding once '
          'signed and witnessed.',
      tag: 'PA Act 194 of 2004',
    ),
    _PageData(
      icon: Icons.checklist,
      title: 'What You Can Include',
      bullets: [
        'Medications you want or want to avoid',
        'Treatment facilities you prefer or want to avoid',
        'Your stance on ECT, drug trials, or experimental studies',
        'A trusted agent to decide on your behalf',
        'Crisis intervention preferences',
        'Dietary, religious & cultural preferences',
        'Guardian nomination',
      ],
      accent: _AccentColor.warning,
    ),
    _PageData(
      icon: Icons.inventory_2_outlined,
      title: 'What to Have Ready',
      bullets: [
        'List of your current medications',
        'Names of your diagnoses or conditions',
        'Contact info for your chosen agent',
        'Names & contact info for two adult witnesses',
      ],
      footnote:
          'The app can import from photos, PDFs, or medical documents to auto-fill fields.',
      accent: _AccentColor.success,
    ),
    _PageData(
      icon: Icons.timer_outlined,
      title: 'Takes About 20–40 Minutes',
      body:
          'Use Smart Fill — select your conditions and let AI pre-fill the form.\n\n'
          'In Private Mode, progress is auto-saved and you can complete the form over '
          'multiple sessions. In Public Mode or on the web, data is in memory only — '
          'plan to complete and export in one session.\n\n'
          'Your directive is legally valid for 2 years once signed by you and two witnesses.',
      tag: 'Auto-save in Private Mode',
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
    final p = Theme.of(context).mhadPalette;
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      backgroundColor: p.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      color: p.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (ctx, i) {
                  final page = _pages[i];
                  final (tileBg, iconColor) = _resolveAccent(page.accent, p);
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: tileBg,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(page.icon, size: 42, color: iconColor),
                        ),
                        const SizedBox(height: 16),
                        if (page.tag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: p.primaryLight,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              page.tag!,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: p.primary,
                              ),
                            ),
                          ),
                        if (page.tag != null) const SizedBox(height: 10),
                        Text(
                          page.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(height: 1.25),
                        ),
                        const SizedBox(height: 14),
                        if (page.body != null)
                          ...page.body!.split('\n\n').map((para) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  para,
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 15,
                                    color: p.textMuted,
                                    height: 1.55,
                                  ),
                                ),
                              )),
                        if (page.bullets != null)
                          ...page.bullets!.map((b) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      margin: const EdgeInsets.only(top: 1),
                                      decoration: BoxDecoration(
                                        color: tileBg,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.check,
                                          size: 12, color: iconColor),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        b,
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 15,
                                          color: p.textMuted,
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        if (page.footnote != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              page.footnote!,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                color: p.textMuted,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dots
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active ? p.primary : p.border,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLast
                      ? _finish
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
                  label: Text(isLast ? 'Get Started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AccentColor { primary, warning, success }

(Color, Color) _resolveAccent(_AccentColor? a, MhadPalette p) {
  switch (a) {
    case _AccentColor.warning:
      return (SemanticColors.warningBgLight, SemanticColors.warningTextLight);
    case _AccentColor.success:
      return (SemanticColors.successBgLight, SemanticColors.successTextLight);
    case _AccentColor.primary:
    case null:
      return (p.primaryLight, p.primary);
  }
}

class _PageData {
  final IconData icon;
  final String title;
  final String? body;
  final List<String>? bullets;
  final String? tag;
  final String? footnote;
  final _AccentColor? accent;

  const _PageData({
    required this.icon,
    required this.title,
    this.body,
    this.bullets,
    this.tag,
    this.footnote,
    this.accent,
  });
}
