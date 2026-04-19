import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';

/// Shown after the user finishes the wizard execution step.
class WizardCompleteScreen extends StatelessWidget {
  final int directiveId;
  const WizardCompleteScreen({required this.directiveId, super.key});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;

    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppBar(
        title: const Text('Directive Complete'),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Go to home',
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: SemanticColors.successBgLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  size: 56, color: SemanticColors.successTextLight),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your directive is saved!',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Here are the next steps to make it legally valid.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              color: p.textMuted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          DesignCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                _NextStep(
                  number: '1',
                  title: 'Print your directive',
                  description: 'Export the PDF and print it on paper.',
                ),
                _NextStep(
                  number: '2',
                  title: 'Sign with ink',
                  description:
                      'Sign the printed directive with original ink '
                      'signatures in the presence of two adult witnesses.',
                ),
                _NextStep(
                  number: '3',
                  title: 'Have witnesses sign',
                  description:
                      'Both witnesses must sign the printed document. '
                      'They cannot be your agent, healthcare provider, or '
                      'facility employee (unless related).',
                ),
                _NextStep(
                  number: '4',
                  title: 'Distribute copies',
                  description:
                      'Give copies to your agent, doctor, hospital, family, '
                      'and anyone who may need it in a crisis.',
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const InfoBanner(
            icon: Icons.flight_takeoff,
            text:
                'If you travel or live part-time in another state, consider '
                'having your directive notarized for broader acceptance.',
            variant: InfoBannerVariant.info,
          ),

          DesignCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.checklist, size: 20, color: p.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Distribution Checklist',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'After printing and signing, give copies to:',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: p.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                const _ChecklistItem(
                    'Your designated agent (and alternate agent)'),
                const _ChecklistItem('Your primary care physician'),
                const _ChecklistItem('Your mental health provider(s)'),
                const _ChecklistItem('Your local hospital'),
                const _ChecklistItem('A trusted family member or friend'),
                const _ChecklistItem('Your attorney (if you have one)'),
                const SizedBox(height: 10),
                Text(
                  'Keep the original in a safe, accessible place. '
                  'Consider telling others where it is stored.',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: p.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const InfoBanner(
            icon: Icons.backup_outlined,
            text: 'Export and save a backup now. If you lose your device, '
                'your directive data cannot be recovered without an '
                'exported copy.',
            variant: InfoBannerVariant.error,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export PDF'),
              onPressed: () =>
                  context.go(AppRoutes.exportRoute(directiveId)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String text;
  const _ChecklistItem(this.text);

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, size: 14, color: p.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: p.text,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final bool isLast;

  const _NextStep({
    required this.number,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: p.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
