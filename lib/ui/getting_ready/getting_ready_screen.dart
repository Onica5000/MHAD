import 'package:flutter/material.dart';
import 'package:mhad/data/app_data/app_data.dart' show appData;
import 'package:mhad/data/getting_ready_content.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/export/pdf/getting_ready_pdf.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_art.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/back_link.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/page_hero.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/utils/file_names.dart';
import 'package:printing/printing.dart';

/// "Getting ready": what makes the directive valid, what to gather (in the
/// wizard's order), and what to do after signing — online and printable.
/// [form] (from `?form=`) shows only that form's items. Ticks are for this
/// visit only.
class GettingReadyScreen extends StatefulWidget {
  const GettingReadyScreen({super.key, this.form});

  final FormType? form;

  @override
  State<GettingReadyScreen> createState() => _GettingReadyScreenState();
}

class _GettingReadyScreenState extends State<GettingReadyScreen> {
  final _ticked = <String>{};

  Future<void> _print() async {
    final messenger = ScaffoldMessenger.of(context);
    final l = context.l10n;
    try {
      final bytes = await buildGettingReadyPdf(l, form: widget.form);
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: mhadFileName([kFileNamePrefix, 'getting-ready']),
      );
    } catch (e) {
      debugPrint('Getting-ready print failed: $e');
      messenger.showSnackBar(SnackBar(content: Text(l.gettingReadyPrintError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final l = context.l10n;
    final c = GettingReadyChecklist(l, form: widget.form);
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BackLink(),
          Expanded(
            child: ListView(
              padding: DesignTokens.pagePadding,
              children: [
                PageHero(
                  art: AppArt.learnChecklists,
                  title: EditorialHeading(text: l.gettingReadyTitle),
                  lead: l.gettingReadyLead,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _print,
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: Text(l.gettingReadyPrintCta),
                  ),
                ),
                const SizedBox(height: 12),
                Text(c.formNote,
                    style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        height: MhadType.leadingParagraph,
                        color: p.textMuted)),
                const SizedBox(height: 20),
                for (final tier in GettingReadyTier.values) ...[
                  SectionLabel(c.tierTitle(tier)),
                  const SizedBox(height: 4),
                  Text(c.tierLead(tier),
                      style: TextStyle(
                          fontSize: 14, height: MhadType.leadingParagraph, color: p.textMuted)),
                  const SizedBox(height: 8),
                  DesignCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    radius: DesignTokens.inputRadius,
                    // The card paints its own background, so the tick rows
                    // need their own Material for the ripple to show.
                    child: Material(
                      type: MaterialType.transparency,
                      child: Column(
                        children: [
                          for (final item in c.items(tier)) _row(p, c, item),
                        ],
                      ),
                    ),
                  ),
                  if (tier == GettingReadyTier.gather) ...[
                    const SizedBox(height: 12),
                    // The sentence and its link share one left edge, under
                    // the mic icon's column.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(Icons.mic_none, size: 16, color: p.primary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.grGatherVoice,
                                  style: TextStyle(
                                      fontSize: 14,
                                      height: MhadType.leadingParagraph,
                                      color: p.text)),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 44),
                                  alignment: Alignment.centerLeft,
                                ),
                                onPressed: () => appRouter.push(widget.form == null
                                    ? AppRoutes.audioGuide
                                    : AppRoutes.audioGuideFor(widget.form!.name)),
                                child: Text(l.grGatherVoiceCta),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
                Text(
                  l.assistantNotLegalOrMedicalAdvice(
                      appData.phoneOf('paProtectionAdvocacy')),
                  style: TextStyle(
                      fontSize: 12, height: MhadType.leadingParagraph, color: p.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(MhadPalette p, GettingReadyChecklist c, GettingReadyItem item) {
    final step = c.stepTag(item);
    final forms = c.formsTag(item);
    return CheckboxListTile(
      value: _ticked.contains(item.id),
      onChanged: (v) => setState(() =>
          v == true ? _ticked.add(item.id) : _ticked.remove(item.id)),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(item.text,
          style: TextStyle(fontSize: 14, height: MhadType.leadingParagraph, color: p.text)),
      subtitle: (step == null && forms == null)
          ? null
          : Text([?step, ?forms].join(' · '),
              style: TextStyle(fontSize: 12, color: p.textMuted)),
    );
  }
}
