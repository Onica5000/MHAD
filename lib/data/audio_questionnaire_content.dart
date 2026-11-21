/// Content for the spoken-questionnaire feature — a script the user reads aloud
/// to record an audio file for AI autofill. Single source of truth shared by
/// the in-app audio-guide screen and the printable questionnaire PDF.
///
/// The words are ARB keys (`audioQ*`, English + Spanish), so the script and
/// its printout follow the app language; this file only fixes the structure.
///
/// Every prompt maps to a field the autofill extractor can capture (see
/// `document_extractor.dart`'s response schema). Things audio CAN'T fill are in
/// [AudioQuestionnaire.cantDo].
library;

import 'package:mhad/data/app_data/app_data.dart' show appData;
import 'package:mhad/l10n/app_localizations.dart';

class AudioQSection {
  final String number;
  final String title;

  /// Shown in muted italics under the title, e.g. "only if you're naming an
  /// agent". Null when the section always applies.
  final String? appliesWhen;

  /// One spoken prompt per bullet.
  final List<String> prompts;

  /// Optional example of how to phrase the answer out loud.
  final String? example;

  /// Optional caveat shown beneath the prompts.
  final String? note;

  const AudioQSection({
    required this.number,
    required this.title,
    required this.prompts,
    this.appliesWhen,
    this.example,
    this.note,
  });
}

/// The questionnaire in the language of [l].
class AudioQuestionnaire {
  const AudioQuestionnaire(this.l);

  final AppLocalizations l;

  String get title => l.audioQTitle;

  /// How to record, for the AI path in view (copy-and-paste unless the API
  /// path is shown), then the speaking tips.
  String get intro =>
      '${appData.ai.apiModeVisible ? l.audioQIntroApi : l.audioQIntroHandoff}'
      '\n\n${l.audioQIntroTips}';

  List<AudioQSection> get sections => [
        AudioQSection(
          number: '1',
          title: l.audioQ1Title,
          prompts: [
            l.audioQ1Prompt1,
            l.audioQ1Prompt2,
            l.audioQ1Prompt3,
            l.audioQ1Prompt4,
          ],
          example: l.audioQ1Example,
        ),
        AudioQSection(
          number: '2',
          title: l.audioQ2Title,
          prompts: [l.audioQ2Prompt1, l.audioQ2Prompt2],
        ),
        AudioQSection(
          number: '3',
          title: l.audioQ3Title,
          appliesWhen: l.audioQ3AppliesWhen,
          prompts: [l.audioQ3Prompt1, l.audioQ3Prompt2],
          example: l.audioQ3Example,
        ),
        AudioQSection(
          number: '4',
          title: l.audioQ4Title,
          appliesWhen: l.audioQ4AppliesWhen,
          prompts: [l.audioQ4Prompt1],
        ),
        AudioQSection(
          number: '5',
          title: l.audioQ5Title,
          prompts: [l.audioQ5Prompt1],
        ),
        AudioQSection(
          number: '6',
          title: l.audioQ6Title,
          prompts: [l.audioQ6Prompt1],
          example: l.audioQ6Example,
        ),
        AudioQSection(
          number: '7',
          title: l.audioQ7Title,
          prompts: [
            l.audioQ7Prompt1,
            l.audioQ7Prompt2,
            l.audioQ7Prompt3,
            l.audioQ7Prompt4,
            l.audioQ7Prompt5,
          ],
          example: l.audioQ7Example,
          note: l.audioQ7Note,
        ),
        AudioQSection(
          number: '8',
          title: l.audioQ8Title,
          prompts: [l.audioQ8Prompt1],
          example: l.audioQ8Example,
        ),
        AudioQSection(
          number: '9',
          title: l.audioQ9Title,
          prompts: [l.audioQ9Prompt1, l.audioQ9Prompt2],
        ),
        AudioQSection(
          number: '10',
          title: l.audioQ10Title,
          prompts: [l.audioQ10Prompt1],
        ),
        AudioQSection(
          number: '11',
          title: l.audioQ11Title,
          prompts: [
            l.audioQ11Prompt1,
            l.audioQ11Prompt2,
            l.audioQ11Prompt3,
            l.audioQ11Prompt4,
          ],
          example: l.audioQ11Example,
          note: l.audioQ11Note,
        ),
        AudioQSection(
          number: '12',
          title: l.audioQ12Title,
          appliesWhen: l.audioQ12AppliesWhen,
          prompts: [l.audioQ12Prompt1],
        ),
        AudioQSection(
          number: '13',
          title: l.audioQ13Title,
          prompts: [
            l.audioQ13Prompt1,
            l.audioQ13Prompt2,
            l.audioQ13Prompt3,
            l.audioQ13Prompt4,
            l.audioQ13Prompt5,
            l.audioQ13Prompt6,
            l.audioQ13Prompt7,
            l.audioQ13Prompt8,
            l.audioQ13Prompt9,
            l.audioQ13Prompt10,
            l.audioQ13Prompt11,
          ],
        ),
      ];

  /// Things the recording can NOT fill — the user must do these in the app.
  List<String> get cantDo => [
        l.audioQCantDoSignatures,
        l.audioQCantDoInitials,
        l.audioQCantDoSideEffects,
      ];

  /// Things the recording CAN fill if said clearly — called out so people
  /// know they're worth speaking aloud.
  List<String> get nowCaptured => [
        l.audioQCapturedMedAuthority,
        l.audioQCapturedUlysses,
        l.audioQCapturedDosages,
        l.audioQCapturedRoom,
        l.audioQCapturedCrisisPlan,
      ];

  /// Autofill fills the form the directive already uses; the person can
  /// switch form types later.
  String get formTypeNote => l.audioQFormTypeNote;

  /// Closing reminder shown after the questionnaire.
  String get closing => l.audioQClosing;
}
