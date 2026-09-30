import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/data/audio_questionnaire_content.dart';
import 'package:mhad/ui/export/pdf/questionnaire_pdf.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:printing/printing.dart';

/// In-app guide for the voice-autofill feature: how to record an audio file
/// that fills the directive, plus the read-aloud questionnaire (printable).
class AudioGuideScreen extends StatelessWidget {
  const AudioGuideScreen({super.key});

  Future<void> _printQuestionnaire(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final bytes = await buildAudioQuestionnairePdf();
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'MHAD-voice-questionnaire.pdf',
      );
    } catch (e) {
      debugPrint('Audio questionnaire print failed: $e');
      messenger.showSnackBar(
        SnackBar(
            content: Text(l10n.audioGuideCouldnTOpenTheQuestionnaire)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      appBar: AppBar(title: Text(context.l10n.audioGuideRecordYourWishesByVoice)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Text(
            context.l10n.audioGuideDescribeYourWishesOutLoud,
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 15,
              height: 1.5,
              color: p.text,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _printQuestionnaire(context),
              icon: const Icon(Icons.print_outlined, size: 18),
              label: Text(context.l10n.audioGuidePrintTheQuestionnaire),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.audioGuidePrintItToReadAloud,
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 12,
              color: p.textMuted,
            ),
          ),
          const SizedBox(height: 20),

          // ── Recording tips & limits ──
          SectionLabel(context.l10n.audioGuideHowToRecord),
          const SizedBox(height: 8),
          _tip(p, Icons.high_quality_outlined,
              context.l10n.audioGuideTipQualityDoesnTMatterAny),
          _tip(p, Icons.timer_outlined,
              context.l10n.audioGuideTipKeepEachClipShortUnder),
          _tip(p, Icons.spellcheck_outlined,
              context.l10n.audioGuideTipSayMedicationAndDoctorNames),
          const SizedBox(height: 10),
          InfoBanner(
            icon: Icons.privacy_tip_outlined,
            variant: InfoBannerVariant.warning,
            text: context.l10n.audioGuideToTranscribeYourRecordingIncluding,
          ),
          const SizedBox(height: 24),

          // ── The questionnaire ──
          Row(
            children: [
              Expanded(child: SectionLabel(audioQTitle)),
              TextButton.icon(
                onPressed: () => _printQuestionnaire(context),
                icon: const Icon(Icons.print_outlined, size: 16),
                label: Text(context.l10n.audioGuidePrint),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            audioQIntro,
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 14,
              height: 1.5,
              color: p.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          for (final s in audioQSections) _section(context, p, s),

          const SizedBox(height: 16),
          SectionLabel(context.l10n.audioGuideWhatTheRecordingCanT),
          const SizedBox(height: 4),
          Text(
            context.l10n.audioGuideSetTheseInTheApp,
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 13,
              color: p.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          for (final item in audioQCantDo) _bullet(p, item, muted: true),
          const SizedBox(height: 14),
          Text(
            context.l10n.audioGuideWorthSayingOutLoudAutofill,
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 13,
              color: p.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          for (final item in audioQNowCaptured) _bullet(p, item, muted: true),
          const SizedBox(height: 6),
          _bullet(p, audioQFormTypeNote, muted: true),
          const SizedBox(height: 14),
          Text(
            audioQClosing,
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.45,
              color: p.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tip(MhadPalette p, IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 17, color: p.primary),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 13,
                  height: 1.45,
                  color: p.text,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _bullet(MhadPalette p, String text, {bool muted = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•  ',
                style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 14,
                    color: muted ? p.textMuted : p.text)),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 14,
                  height: 1.45,
                  color: muted ? p.textMuted : p.text,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _section(BuildContext context, MhadPalette p, AudioQSection s) => DesignCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        radius: DesignTokens.inputRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${s.number}.  ${s.title}',
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
            if (s.appliesWhen != null) ...[
              const SizedBox(height: 1),
              Text(
                s.appliesWhen!,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: p.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 8),
            for (final prompt in s.prompts) _bullet(p, prompt),
            if (s.example != null) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Text(
                  context.l10n.audioGuideExample(s.example!),
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                    color: p.textMuted,
                  ),
                ),
              ),
            ],
            if (s.note != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 14, color: p.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      s.note!,
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 12,
                        height: 1.4,
                        color: p.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
}
