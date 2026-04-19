import 'package:flutter/material.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/notification_service.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';

/// Full-screen legal disclaimer shown once on first launch.
/// The user must tap "I Understand" before accessing the app.
class DisclaimerScreen extends StatelessWidget {
  final DisclaimerNotifier notifier;
  const DisclaimerScreen({required this.notifier, super.key});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: p.surface,
        appBar: AppBar(
          title: const Text('Important Disclaimer'),
          automaticallyImplyLeading: false,
          backgroundColor: p.card,
          foregroundColor: p.text,
          elevation: 0,
          systemOverlayStyle: null,
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InfoBanner(
                        icon: Icons.gavel_rounded,
                        text:
                            'This app helps you document your mental health treatment preferences under PA Act 194 of 2004. It does not provide legal or medical advice.',
                        variant: InfoBannerVariant.warning,
                      ),
                      DesignCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Before You Begin',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
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
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
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
  final bool isLast;
  const _Section({
    required this.number,
    required this.title,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14, top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    color: p.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              body,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: p.textMuted,
                height: 1.5,
              ),
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
    final p = Theme.of(context).mhadPalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: p.card,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _isAdult = !_isAdult),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: _isAdult ? p.primary : Colors.transparent,
                      border: Border.all(
                        color: _isAdult ? p.primary : p.border,
                        width: 2,
                      ),
                    ),
                    child: _isAdult
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'I am 18 years of age or older, or an emancipated minor, and '
                      'I understand this app does not provide legal or medical advice.',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.check),
              onPressed: _isAdult
                  ? () async {
                      await widget.notifier.accept();
                      await NotificationService.instance.requestPermission();
                    }
                  : null,
              label: const Text('I Understand — Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
