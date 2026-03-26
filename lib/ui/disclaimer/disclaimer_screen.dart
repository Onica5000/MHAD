import 'package:flutter/material.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/notification_service.dart';

/// Full-screen legal disclaimer shown once on first launch.
/// The user must tap "I Understand" before accessing the app.
class DisclaimerScreen extends StatelessWidget {
  final DisclaimerNotifier notifier;
  const DisclaimerScreen({required this.notifier, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false, // Cannot dismiss without accepting
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Icon(Icons.gavel_rounded,
                            size: 56, color: cs.primary),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Important Notice',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Please read carefully before using this app.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: cs.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _Section(
                        number: '1',
                        title: 'Not Legal or Medical Advice',
                        body:
                            'This app is designed to help Pennsylvania residents '
                            'document their mental health treatment preferences under '
                            'Pennsylvania Act 194 of 2004. The information provided '
                            'is for informational purposes only and does NOT constitute '
                            'legal advice or medical advice.\n\n'
                            'This app is not a medical device and does not diagnose, '
                            'treat, cure, or prevent any condition. This app does not '
                            'provide medical or legal advice. Consult a qualified '
                            'mental health professional regarding your treatment '
                            'options. For legal advice, consult a licensed Pennsylvania '
                            'attorney.',
                      ),
                      _Section(
                        number: '2',
                        title: 'No Professional Relationship',
                        body:
                            'Use of this app does not create an attorney-client '
                            'relationship, a provider-patient relationship, or any '
                            'other professional relationship between you and the '
                            'app developer.\n\n'
                            'You are solely responsible for ensuring your directive '
                            'meets all legal requirements under Pennsylvania law, '
                            'including proper execution with witnesses.',
                      ),
                      _Section(
                        number: '3',
                        title: 'No Warranty',
                        body:
                            'This app is provided "as is" without warranty of any '
                            'kind, express or implied. The developer assumes no '
                            'liability for any damages arising from the use of this '
                            'app or any document created with it. The developer is '
                            'not responsible for ensuring the legal validity of any '
                            'directive created using this app.',
                      ),
                      _Section(
                        number: '4',
                        title: 'Requirements for a Valid Directive',
                        body:
                            'A Pennsylvania Mental Health Advance Directive is legally '
                            'valid ONLY when:\n'
                            '  • You (the principal) have legal capacity when you sign it\n'
                            '  • It is signed in the presence of two adult witnesses\n'
                            '  • Both witnesses meet eligibility requirements under Act 194\n\n'
                            'Witnesses CANNOT be: your designated agent, your agent\'s '
                            'spouse, your mental health care provider, or an employee of '
                            'your treatment facility (unless related to you).\n\n'
                            'This app captures digital touch-drawn signatures for '
                            'convenience during preparation. However, the printed '
                            'directive must be signed with original ink signatures in '
                            'the presence of your two witnesses to be legally valid.',
                      ),
                      _Section(
                        number: '5',
                        title: 'Two-Year Validity Period',
                        body:
                            'Under Pennsylvania Act 194 of 2004, a Mental Health '
                            'Advance Directive is valid for two (2) years from the '
                            'date of execution unless revoked earlier. This app will '
                            'remind you when your directive is approaching expiration.',
                      ),
                      _Section(
                        number: '6',
                        title: 'Revocation',
                        body:
                            'You may revoke this directive at any time while you have '
                            'legal capacity by:\n'
                            '  • Notifying your healthcare provider or agent in writing\n'
                            '  • Destroying the directive\n'
                            '  • Executing a new directive\n\n'
                            'Notify all who have copies of the revocation.',
                      ),
                      _Section(
                        number: '7',
                        title: 'Privacy & AI Features',
                        body:
                            'In Private Mode, directive data is encrypted and stored on this device. '
                            'In Public Mode or on the web, data is held in memory only and not saved permanently. This '
                            'app is not HIPAA-compliant.\n\n'
                            'If you use the optional AI Assistant feature (powered by '
                            'Google Gemini), text you send via AI chat or AI Suggest '
                            'will be transmitted to Google\'s servers. On the free '
                            'tier, Google may use this data to improve their products '
                            'and human reviewers may read your inputs. Do not include '
                            'personally identifying information (full name, SSN, date '
                            'of birth, address) in AI requests.\n\n'
                            'AI-generated suggestions are not legal or medical advice '
                            'and should be reviewed carefully before accepting.',
                      ),
                      _Section(
                        number: '8',
                        title: 'Resources & Assistance',
                        body:
                            'PA Protection & Advocacy, Inc. (PA P&A) can assist you '
                            'with your rights under Act 194:\n'
                            '  \u2022 Phone: $paProtectionAdvocacyPhone (toll free)\n'
                            '  \u2022 TDD/TTY: 1-877-375-7139\n\n'
                            'PA Mental Health Consumers\' Association (PMHCA):\n'
                            '  \u2022 Phone: 1-800-887-6422\n\n'
                            'Mental Health Association in Pennsylvania (MHAP):\n'
                            '  \u2022 Phone: 1-866-578-3659',
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              _AcceptButton(notifier: notifier),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  const _Section(
      {required this.number, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              body,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _AcceptButton extends StatefulWidget {
  final DisclaimerNotifier notifier;
  const _AcceptButton({required this.notifier});

  @override
  State<_AcceptButton> createState() => _AcceptButtonState();
}

class _AcceptButtonState extends State<_AcceptButton> {
  bool _isAdult = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'By tapping "I Understand" you confirm you have read and '
            'understand the above information.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _isAdult,
            onChanged: (v) => setState(() => _isAdult = v ?? false),
            title: const Text('I am 18 years of age or older, or an emancipated minor'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isAdult
                  ? () async {
                      await widget.notifier.accept();
                      // Request notification permission after acceptance
                      await NotificationService.instance.requestPermission();
                    }
                  : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('I Understand',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
