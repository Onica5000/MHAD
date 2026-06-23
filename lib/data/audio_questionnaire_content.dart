/// Content for the spoken-questionnaire feature — a script the user reads aloud
/// to record an audio file for AI autofill. Single source of truth shared by
/// the in-app audio-guide screen and the printable questionnaire PDF.
///
/// Every prompt maps to a field the autofill extractor can capture (see
/// `document_extractor.dart`'s response schema). Things audio CAN'T fill are in
/// [audioQCantDo].
library;

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

const String audioQTitle = 'Voice questionnaire';

const String audioQIntro =
    'Read this out loud and answer each prompt in your own words, then upload '
    'the recording on the Snap-to-fill screen. The AI turns what you say into '
    'your directive — and you review every field before anything is saved.\n\n'
    'Speak naturally; you don\'t need exact wording. Say "skip" for anything '
    'that doesn\'t apply. For unusual medication or doctor names, say the name '
    'slowly and spell it. Keep each recording under about 2 minutes — record '
    'one clip per section and upload them together.';

const List<AudioQSection> audioQSections = [
  AudioQSection(
    number: '1',
    title: 'About you',
    prompts: [
      'Your full legal name.',
      'Your date of birth (month, day, year).',
      'Your home address: street and number, apartment or unit, city, county, '
          'state, and ZIP code.',
      'A phone number where you can be reached.',
    ],
    example:
        'My name is Jane Quincy Public. I was born March 15th, 1975. I live at '
        '123 Main Street, apartment 4B, Philadelphia, Philadelphia County, '
        'Pennsylvania, 19103. My phone is (215) 555-1234.',
  ),
  AudioQSection(
    number: '2',
    title: 'Your doctors',
    prompts: [
      'Your primary doctor / treating physician: name, specialty (e.g. '
          'psychiatry), and phone number.',
      'If you want a specific doctor to evaluate your capacity (different from '
          'your primary doctor): their name and how to reach them.',
    ],
  ),
  AudioQSection(
    number: '3',
    title: 'Your mental-health agent',
    appliesWhen: 'only if you are naming an agent — Combined or Power of '
        'Attorney form',
    prompts: [
      'Your agent\'s full name, their relationship to you, their address, and '
          'a phone number.',
      'If you have a backup / alternate agent, give the same details for them.',
    ],
    example:
        'My agent is John Public, my husband, at the same address, cell (215) '
        '555-5678. My alternate is Mary Public, my sister, 50 Oak Lane, '
        'Pittsburgh, PA 15201, (412) 555-0000.',
  ),
  AudioQSection(
    number: '4',
    title: 'Guardian nomination',
    appliesWhen: 'optional',
    prompts: [
      'If you want to nominate someone to be your guardian should a court ever '
          'appoint one: their name, relationship, address, and phone.',
    ],
  ),
  AudioQSection(
    number: '5',
    title: 'When this directive takes effect',
    prompts: [
      'Describe the circumstances that should trigger this directive — for '
          'example, "when two professionals certify that I can\'t make my own '
          'mental health decisions." This is the "when it kicks in" language, '
          'not your diagnoses.',
    ],
  ),
  AudioQSection(
    number: '6',
    title: 'Your diagnoses',
    prompts: [
      'List your mental-health diagnoses / conditions. If you happen to know a '
          'diagnosis code (ICD-10) you can say it, but it\'s optional.',
    ],
    example: 'I have bipolar disorder type 1 and generalized anxiety disorder.',
  ),
  AudioQSection(
    number: '7',
    title: 'Medications',
    prompts: [
      'Say these in FOUR separate groups (they go to different places on the '
          'form). For each, add a short reason if you like:',
      '1. Medications I am CURRENTLY taking — what you take now, for reference.',
      '2. Medications I PREFER — ones that have worked well.',
      '3. Medications I NEVER want / refuse — and why.',
      '4. Medications with LIMITATIONS — may be given, but only under '
          'conditions you state.',
    ],
    example:
        'I currently take lithium and lamotrigine, L-A-M-O-T-R-I-G-I-N-E. I '
        'prefer quetiapine, it has worked well. I never want haloperidol, it '
        'caused a severe reaction. Clozapine only with weekly blood monitoring.',
    note: 'Say the dose if you know it (e.g. "lithium 300 mg twice a day") — '
        'autofill captures the dose for medications you currently take. Always '
        'double-check it in the app afterward.',
  ),
  AudioQSection(
    number: '8',
    title: 'Allergies',
    prompts: [
      'List your allergies — drug, food, or material. For each, say the '
          'severity (mild, moderate, or severe), the reactions it causes, and '
          'any notes.',
    ],
    example:
        'I\'m allergic to penicillin — severe, causes anaphylaxis. Latex — '
        'moderate, causes hives.',
  ),
  AudioQSection(
    number: '9',
    title: 'Treatment facility preferences',
    prompts: [
      'A hospital or treatment center you PREFER to be treated at.',
      'A facility you want to AVOID, if any.',
    ],
  ),
  AudioQSection(
    number: '10',
    title: 'Room and environment preferences',
    prompts: [
      'Any room or environment preferences — for example a private room, a '
          'quiet floor, a window, or a same-gender roommate.',
    ],
  ),
  AudioQSection(
    number: '11',
    title: 'ECT, experimental studies, and drug trials',
    prompts: [
      'For EACH of these three, say clearly which you want: "I consent," "I do '
          'not consent," or "I want my agent to decide."',
      'Electroconvulsive therapy (ECT).',
      'Experimental studies / research.',
      'Drug trials.',
    ],
    example:
        'For ECT, I do not consent. For experimental studies, I want my agent '
        'to decide. For drug trials, I do not consent.',
    note: 'If you choose "my agent decides" for any of these three, '
        'Pennsylvania law (§5805(c)(4)) requires you to physically INITIAL '
        'that authorization on the PRINTED form — the recording captures your '
        'choice, but it can\'t initial for you.',
  ),
  AudioQSection(
    number: '12',
    title: 'Limits on your agent\'s authority',
    appliesWhen: 'only if naming an agent',
    prompts: [
      'Any limits or conditions on what your agent may or may not do — e.g. '
          '"my agent must consult my sister first," or "my agent may not '
          'consent to ECT."',
    ],
  ),
  AudioQSection(
    number: '13',
    title: 'Additional instructions',
    prompts: [
      'Cover any of these that apply (say "skip" for the rest):',
      'Activities that help or worsen your symptoms.',
      'What helps you during a crisis — preferred interventions, what calms '
          'you, what to avoid.',
      'Health history — past hospitalizations, what has or hasn\'t worked.',
      'Dietary needs or restrictions.',
      'Religious or cultural preferences relevant to your care.',
      'Children / custody arrangements to be aware of.',
      'Who to notify, and who NOT to notify.',
      'Records disclosure — who may see your records.',
      'Pet care — who cares for your pets if you\'re hospitalized.',
      'Anything else you want your care team and agent to know.',
    ],
  ),
];

/// Things the recording can NOT fill — the user must do these in the app.
const List<String> audioQCantDo = [
  'Your signature and your witnesses\' signatures.',
  'Physical INITIALS for letting your agent decide ECT, experimental studies, '
      'or drug trials (a legal requirement — see section 11).',
  'On/off authority toggles — whether your agent may consent to your '
      'hospitalization, and whether your agent decides your medications.',
  'The treatment-facility "no preference" vs. specific selection, the '
      'room-preference checkboxes, and the same-gender-roommate sub-choice '
      '(your spoken facility names and room notes ARE captured).',
  'The structured crisis plan and the side-effects checklist are built in the '
      'app — autofill does NOT complete them. Please open and fill in (or '
      'review) those two sections yourself. (Your general crisis and activity '
      'notes ARE captured.)',
  'The self-binding (Ulysses) clause opt-in.',
  'Choosing your form type — after autofill, the app recommends a form '
      '(Combined, Declaration, or Power of Attorney) based on what it found, '
      'and you confirm or change it.',
];

/// Closing reminder shown after the questionnaire.
const String audioQClosing =
    'Always review every autofilled field before saving — correct any mis-heard '
    'medications, conditions, names, or numbers.';
