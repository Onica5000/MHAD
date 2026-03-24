import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ui/router.dart';

/// In-app privacy policy accessible from settings and disclaimer screen.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bodyStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(height: 1.6);
    final headingStyle = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(fontWeight: FontWeight.w600);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PA MHAD App Privacy Policy', style: headingStyle),
            const SizedBox(height: 4),
            Text(
              'Last updated: March 2026 (v1.0.0)',
              style: bodyStyle?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            _PolicySection(
              title: 'Data We Collect',
              body:
                  'This app collects only the information you enter into your '
                  'Mental Health Advance Directive forms, including:\n'
                  '  - Personal information (name, address, phone, date of birth)\n'
                  '  - Agent and witness information\n'
                  '  - Treatment preferences and medication lists\n'
                  '  - Digital signatures\n'
                  '  - Additional instructions\n\n'
                  'We do not collect analytics, crash reports, device identifiers, '
                  'or location data.',
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: 'How Data Is Stored & Protected',
              body:
                  'All directive data is stored locally on your device in a '
                  'SQLite database. Data is NOT transmitted to the app '
                  'developer or any third party for storage.\n\n'
                  'In Public Mode, data is stored in an in-memory database '
                  'that is erased when you close the app.\n\n'
                  'In Private Mode, data is encrypted using SQLCipher '
                  '(AES-256 encryption) and stored in a file on your device. '
                  'Access requires biometric authentication or a passcode. '
                  'Your encryption key is stored in your device\'s secure '
                  'hardware keystore (Android Keystore / iOS Keychain) and '
                  'never leaves the device.',
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: 'AI Features & Third-Party Data Sharing',
              body:
                  'If you choose to use the optional AI features (AI Assistant '
                  'chat or AI Suggest), text you submit is sent to Google\'s '
                  'Gemini API for processing.\n\n'
                  'On the free tier, Google may:\n'
                  '  - Use your input/output data to improve their products\n'
                  '  - Allow human reviewers to read your inputs and outputs\n'
                  '  - Retain data for up to 30 days\n\n'
                  'The app strips common personally identifiable information '
                  '(SSNs, phone numbers, emails, dates of birth, addresses, '
                  'names) before sending data to Google, but this is a '
                  'best-effort filter and cannot guarantee complete removal.\n\n'
                  'AI features are entirely optional. The app is fully '
                  'functional without them.',
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: 'Gemini Free Tier Data Practices',
              body:
                  'If you use the AI features with Google\'s free Gemini tier, '
                  'be aware of the following:\n\n'
                  '1. Google retains AI conversation data indefinitely on the '
                  'free tier. There is no automatic expiration.\n\n'
                  '2. Human reviewers at Google may read your inputs and '
                  'outputs as part of their quality and safety processes.\n\n'
                  '3. Data sent to Gemini cannot be recalled or deleted by you '
                  'or by this app. Once submitted, it is under Google\'s '
                  'control.\n\n'
                  '4. If you are concerned about data privacy, consider '
                  'upgrading to the paid Gemini tier, which offers stronger '
                  'data protection policies and does not use your data for '
                  'model training.\n\n'
                  'You can avoid all third-party data sharing by not using '
                  'the AI features.',
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: 'International Users (GDPR)',
              body:
                  'If you are located in the European Economic Area (EEA), '
                  'the UK, or Switzerland, the General Data Protection '
                  'Regulation (GDPR) applies to your use of this app.\n\n'
                  'Legal basis for processing: Your explicit consent, '
                  'given through the in-app disclaimer and AI consent '
                  'dialogs.\n\n'
                  'Your rights under GDPR:\n'
                  '  - Right to access: All your data is stored locally on '
                  'your device — you have direct access at all times.\n'
                  '  - Right to erasure: Use "Delete All Data" in the app '
                  'menu to permanently erase all local data.\n'
                  '  - Right to data portability: Export your directives as '
                  'PDF or FHIR JSON at any time.\n'
                  '  - Right to withdraw consent: Stop using AI features at '
                  'any time; remove your API key to prevent further data '
                  'transmission.\n'
                  '  - Right to restriction: You may use the app in Public '
                  'Mode without any data persistence.\n\n'
                  'Data sent to Google\'s Gemini API is processed under '
                  'Google\'s own privacy policy and data processing terms. '
                  'We cannot control or delete data once sent to Google.',
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: 'US State Privacy Compliance (CCPA / MHMDA)',
              body:
                  'This app may be subject to state consumer health data '
                  'privacy laws, including California\'s CCPA/CPRA and '
                  'Washington\'s My Health My Data Act (MHMDA).\n\n'
                  'Under these laws: (1) We collect mental health treatment '
                  'preference data solely for the purpose of creating your '
                  'advance directive. (2) We do not sell your health data. '
                  '(3) Data shared with Google\'s AI service requires your '
                  'explicit per-session consent. (4) You may delete all '
                  'locally stored data at any time via the \'Delete All Data\' '
                  'option in the app menu.\n\n'
                  'This app does not use cookies, tracking pixels, analytics '
                  'SDKs, or any form of behavioral tracking. No cookie '
                  'consent banner is needed because no cookies are set.\n\n'
                  'For questions about your privacy rights, contact the '
                  'developer through the app store listing.',
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: 'Clinical Data Services (NIH)',
              body:
                  'This app uses publicly available data from the U.S. National '
                  'Library of Medicine (NLM), National Institutes of Health, '
                  'Department of Health and Human Services, to provide '
                  'medication name autocomplete (via RxTerms/RxNorm) and '
                  'diagnosis lookup (via ICD-10-CM).\n\n'
                  'NLM is not responsible for this product and does not endorse '
                  'or recommend this or any other product.\n\n'
                  'It is not the intention of NLM to provide specific medical '
                  'advice, but rather to provide users with information to '
                  'better understand their health and their medications. NLM '
                  'urges you to consult with a qualified physician for medical '
                  'advice.\n\n'
                  'These services are subject to a rate limit of 20 requests '
                  'per second. Medication and diagnosis lookups are performed '
                  'in real time and are not cached or stored by this app.\n\n'
                  'Source: U.S. National Library of Medicine.',
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: 'PDF Export & Sharing',
              body:
                  'When you export a PDF of your directive, it is generated '
                  'locally on your device. Sharing the PDF (via email, '
                  'messaging, etc.) sends it through your device\'s standard '
                  'sharing mechanism. The app cannot control where the PDF '
                  'is stored once shared.',
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: 'Your Rights',
              body:
                  'You can delete any directive at any time from the home '
                  'screen. Deleting a directive removes all associated data '
                  '(personal info, agents, medications, witnesses, signatures) '
                  'from the local database.\n\n'
                  'You can remove your Gemini API key at any time from the '
                  'AI Setup screen.\n\n'
                  'Uninstalling the app removes all locally stored data.',
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: 'No Third-Party Tracking',
              body:
                  'This app does not include any third-party analytics SDKs, '
                  'advertising frameworks, crash reporting services (such as '
                  'Firebase, Crashlytics, or Sentry), or tracking pixels.\n\n'
                  'The only external network connections this app makes are:\n'
                  '  - Google Gemini API (only when you use AI features)\n'
                  '  - NIH/NLM Clinical Table Search Service (only when you '
                  'search for medications or conditions)\n\n'
                  'No data is sent to the app developer at any time.',
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: 'HIPAA & Compliance',
              body:
                  'This app is NOT HIPAA-compliant. It is not a covered entity '
                  'or business associate under HIPAA. The app is intended for '
                  'personal use by individuals preparing their own mental '
                  'health advance directives.\n\n'
                  'This app does not meet GDPR, CCPA, or other data privacy '
                  'regulation requirements. If you are subject to these '
                  'regulations, consult with a privacy professional before use.',
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: 'Breach Notification',
              body:
                  'In accordance with the FTC Health Breach Notification Rule, '
                  'if any unauthorized disclosure of your health information '
                  'occurs through a security breach, we will notify affected '
                  'users within 60 calendar days of discovering the breach.\n\n'
                  'Because this app stores data locally on your device and '
                  'does not maintain a server-side database, breach risk is '
                  'limited to the optional AI features. If Google notifies us '
                  'of a breach affecting Gemini API data, we will pass that '
                  'notification along through app store updates and in-app '
                  'notices.',
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: 'Contact',
              body:
                  'For questions about this privacy policy or the app, contact '
                  'the developer through the app store listing.',
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            const Divider(),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.description_outlined, size: 18),
              label: const Text('Review Legal Disclaimer'),
              onPressed: () => context.push(AppRoutes.disclaimer),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;
  final TextStyle? headingStyle;
  final TextStyle? bodyStyle;

  const _PolicySection({
    required this.title,
    required this.body,
    this.headingStyle,
    this.bodyStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: headingStyle),
          const SizedBox(height: 4),
          Text(body, style: bodyStyle),
        ],
      ),
    );
  }
}
