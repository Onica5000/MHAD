import 'package:mhad/ui/widgets/rich_content_text.dart';
import 'package:flutter/material.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/back_link.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/page_hero.dart';
import 'package:mhad/ui/theme/app_art.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/ui/disclaimer/disclaimer_screen.dart';

/// In-app privacy policy accessible from settings and disclaimer screen.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(height: MhadType.leadingParagraph);
    final headingStyle = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(fontWeight: FontWeight.w600);

    return Scaffold(
      body: Column(
        children: [
          const BackLink(),
          Expanded(
            child: SingleChildScrollView(
        padding: DesignTokens.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHero(
              art: AppArt.miscPrivacy,
              title: EditorialHeading(
                  text: context.l10n.privacyPolicyPaMhadAppPrivacyPolicy),
              lead: context.l10n.privacyPolicyLastUpdated(
                  appData.dateFactFor('privacyPolicyUpdated',
                      Localizations.localeOf(context).toLanguageTag()),
                  appData.dateFact('privacyPolicyVersion')),
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
                  context.l10n.privacyPolicyYourDirectiveDataIsNot(
                      appData.config.progressWindowMinutes),
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyAiFeaturesThirdPartyData,
              body:
                  (appData.ai.apiModeVisible ? context.l10n.privacyPolicyIfYouChooseToUse : context.l10n.privacyPolicyIfYouChooseToUseHandoff),
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: appData.ai.apiModeVisible
                  ? context.l10n.privacyPolicyGeminiFreeTierDataPractices
                  : context.l10n.privacyPolicyOutsideAiServices,
              body:
                  (appData.ai.apiModeVisible ? context.l10n.privacyPolicyIfYouUseTheAi : context.l10n.privacyPolicyIfYouUseTheAiHandoff),
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyInternationalUsersGdpr,
              body:
                  (appData.ai.apiModeVisible ? context.l10n.privacyPolicyIfYouAreLocatedIn : context.l10n.privacyPolicyIfYouAreLocatedInHandoff),
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyUsStateConsumerHealthData,
              body:
                  (appData.ai.apiModeVisible ? context.l10n.privacyPolicyThisAppMayBeSubject : context.l10n.privacyPolicyThisAppMayBeSubjectHandoff),
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
                  (appData.ai.apiModeVisible ? context.l10n.privacyPolicyYouCanDeleteAnyDirective : context.l10n.privacyPolicyYouCanDeleteAnyDirectiveHandoff),
              headingStyle: headingStyle,
              bodyStyle: bodyStyle,
            ),

            _PolicySection(
              title: context.l10n.privacyPolicyNoThirdPartyTracking,
              body:
                  (appData.ai.apiModeVisible ? context.l10n.privacyPolicyThisAppDoesNotInclude : context.l10n.privacyPolicyThisAppDoesNotIncludeHandoff),
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
                  context.l10n.privacyPolicyYouCanReachTheDeveloper(appData.privacyPolicyUrl),
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
          // The shared renderer: real bold (it showed raw **), and
          // bullets with a hanging indent.
          RichContentText(body, style: bodyStyle),
        ],
      ),
    );
  }
}
