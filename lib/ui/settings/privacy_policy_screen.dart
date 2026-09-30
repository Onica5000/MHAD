import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/ui/disclaimer/disclaimer_screen.dart';

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
      appBar: AppBar(title: Text(context.l10n.privacyPolicyPrivacyPolicy)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.privacyPolicyPaMhadAppPrivacyPolicy, style: headingStyle),
            const SizedBox(height: 4),
            Text(
              'Last updated: ${appData.dateFact('privacyPolicyUpdated')} '
              '(${appData.dateFact('privacyPolicyVersion')})',
              style: bodyStyle?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            _PolicySection(
              title: context.l10n.privacyPolicyDataWeCollect,
              body:
                  context.l10n.privacyPolicyThisAppCollectsOnlyThe,
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyHowDataIsStoredProtected,
              body:
                  context.l10n.privacyPolicyYourDirectiveDataIsNot,
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyAiFeaturesThirdPartyData,
              body:
                  context.l10n.privacyPolicyIfYouChooseToUse,
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyGeminiFreeTierDataPractices,
              body:
                  context.l10n.privacyPolicyIfYouUseTheAi,
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyInternationalUsersGdpr,
              body:
                  context.l10n.privacyPolicyIfYouAreLocatedIn,
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyUsStateConsumerHealthData,
              body:
                  context.l10n.privacyPolicyThisAppMayBeSubject,
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyMedicalReferenceLookupsUS,
              body:
                  context.l10n.privacyPolicyToHelpYouFillIn,
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyPdfExportSharing,
              body:
                  context.l10n.privacyPolicyWhenYouExportAPdf,
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyYourRights,
              body:
                  context.l10n.privacyPolicyYouCanDeleteAnyDirective,
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyNoThirdPartyTracking,
              body:
                  context.l10n.privacyPolicyThisAppDoesNotInclude,
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyHipaaCompliance,
              body:
                  context.l10n.privacyPolicyThisAppIsNotHipaa,
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyBreachNotification,
              body:
                  context.l10n.privacyPolicyInAccordanceWithTheFtc,
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyContact,
              body:
                  'You can reach the developer through any of the following '
                  '(the FTC Health Breach Notification Rule requires at least '
                  'two contact methods — we provide three):\n\n'
                  '  - In-app: an in-app breach notice will be shown on next '
                  'launch if a breach affects you.\n'
                  '  - Online: ${appData.privacyPolicyUrl} (also used for breach '
                  'postings if direct contact information is insufficient).\n'
                  '  - App store listing: the developer support address shown '
                  'on the Google Play / App Store product page.',
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            const Divider(),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.description_outlined, size: 18),
              label: Text(context.l10n.privacyPolicyReviewLegalDisclaimer),
              // Navigator.push (not GoRouter) so the redirect — which bounces
              // away from /disclaimer once it's accepted — doesn't intercept
              // this read-only review. Mirrors the Settings disclaimer entry.
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DisclaimerScreen.readOnly(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
            ),
          ),
        ],
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
