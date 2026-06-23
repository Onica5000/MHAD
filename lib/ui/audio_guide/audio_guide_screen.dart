import 'package:flutter/material.dart';
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
    try {
      final bytes = await buildAudioQuestionnairePdf();
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'MHAD-voice-questionnaire.pdf',
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not open the questionnaire to print: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      appBar: AppBar(title: const Text('Record your wishes by voice')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Text(
            'Describe your wishes out loud, upload the recording on the '
            'Snap-to-fill screen, and the AI fills your directive — you review '
            'every field before anything is saved.',
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 14.5,
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
              label: const Text('Print the questionnaire'),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Print it to read aloud while you record, or to fill in by hand '
            'first.',
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 12,
              color: p.textMuted,
            ),
          ),
          const SizedBox(height: 20),

          // ── Recording tips & limits ──
          const SectionLabel('How to record'),
          const SizedBox(height: 8),
          _tip(p, Icons.high_quality_outlined,
              'Quality doesn\'t matter. Any phone voice memo works — the AI '
              'downsamples audio anyway, so a small low-quality file '
              'transcribes just as well as a large one.'),
          _tip(p, Icons.timer_outlined,
              'Keep each clip short — under about 2 minutes. Record one clip '
              'per section below and upload them together; the app merges them. '
              'Long clips can time out.'),
          _tip(p, Icons.spellcheck_outlined,
              'Say medication and doctor names slowly and spell them. The AI '
              'won\'t guess a drug or condition it didn\'t clearly hear.'),
          const SizedBox(height: 10),
          const InfoBanner(
            icon: Icons.privacy_tip_outlined,
            variant: InfoBannerVariant.warning,
            text: 'To transcribe, your recording — including any personal '
                'details you speak — is sent to Google\'s AI. On the free tier '
                'it may be retained and reviewed, and can\'t be recalled. Don\'t '
                'say anything you\'re not comfortable sending; you can always '
                'type sensitive fields by hand instead.',
          ),
          const SizedBox(height: 24),

          // ── The questionnaire ──
          Row(
            children: [
              Expanded(child: SectionLabel(audioQTitle)),
              TextButton.icon(
                onPressed: () => _printQuestionnaire(context),
                icon: const Icon(Icons.print_outlined, size: 16),
                label: const Text('Print'),
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
              fontSize: 13.5,
              height: 1.5,
              color: p.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          for (final s in audioQSections) _section(p, s),

          const SizedBox(height: 16),
          const SectionLabel('What the recording can\'t fill'),
          const SizedBox(height: 4),
          Text(
            'Set these in the app:',
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 12.5,
              color: p.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          for (final item in audioQCantDo) _bullet(p, item, muted: true),
          const SizedBox(height: 14),
          Text(
            'Worth saying out loud — autofill now captures these:',
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 12.5,
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
                    fontSize: 13.5,
                    color: muted ? p.textMuted : p.text)),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 13.5,
                  height: 1.45,
                  color: muted ? p.textMuted : p.text,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _section(MhadPalette p, AudioQSection s) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.card,
          border: Border.all(color: p.border),
          borderRadius: BorderRadius.circular(12),
        ),
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
                  fontSize: 11.5,
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Example: ${s.example}',
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 12.5,
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
