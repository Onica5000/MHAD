/// The per-form statutory prose of the three official PA MHAD forms, verified
/// verbatim against `docs/PA MHAD.pdf` (Disabilities Law Project 2005):
/// Combined pp. 25-32 · Declaration pp. 33-38 · POA pp. 39-45.
///
/// The wording VARIES BETWEEN FORMS in the official booklet itself (e.g. the
/// Combined's revocation clause really says "this Power of Attorney"
/// mid-paragraph on p. 25, and only the Declaration says "Two years AFTER the
/// date"). Those are official quirks, not app drift — do NOT "fix" them.
/// Deliberate app deviations from the official text are marked `App:` below.
library;

import 'package:mhad/domain/model/directive.dart';

/// Resolved prose bundle for one form type. Every string that differs between
/// the three official forms lives here; everything identical lives directly
/// in `pdf_form_sections.dart`.
class FormText {
  final FormType form;
  const FormText(this.form);

  // ── Title (official pp. 25 / 33 / 39) ────────────────────────────────────
  List<String> get titleLines => switch (form) {
        FormType.combined => const [
            'COMBINED MENTAL HEALTH CARE DECLARATION',
            'AND POWER OF ATTORNEY FORM',
          ],
        FormType.declaration => const ['MENTAL HEALTH CARE DECLARATION FORM'],
        FormType.poa => const ['MENTAL HEALTH POWER OF ATTORNEY'],
      };

  /// Header-bar title (with the draft label appended by the caller).
  String get headerTitle => switch (form) {
        FormType.combined => 'Combined Declaration & Power of Attorney',
        FormType.declaration => 'Mental Health Declaration',
        FormType.poa => 'Mental Health Power of Attorney',
      };

  // ── Introduction ─────────────────────────────────────────────────────────
  /// Intro paragraphs; `{name}` is replaced with the declarant's name or a
  /// blank rule. Combined/Declaration are one paragraph; the official POA
  /// (p. 39) splits the same content into three (and says "shall be one of my
  /// treating professionals" where the others say "will be").
  List<String> introParagraphs(String name) => switch (form) {
        FormType.combined => [
            'I, $name, having capacity to make mental health decisions, '
                'willfully and voluntarily make this Declaration and Power of Attorney '
                'regarding my mental health care. I understand that mental health care includes '
                'any care, treatment, service or procedure to maintain, diagnose, treat or '
                'provide for mental health, including any medication program and therapeutic '
                'treatment. Electroconvulsive therapy may be administered only if I have '
                'specifically consented to it in this document. I will be the subject of '
                'laboratory trials or research only if specifically provided for in this '
                'document. Mental health care does not include psychosurgery or termination '
                'of parental rights. I understand that my incapacity will be determined by '
                'examination by a psychiatrist and one of the following: another psychiatrist, '
                'psychologist, family physician, attending physician or mental health treatment '
                'professional. Whenever possible, one of the decision makers will be one of '
                'my treating professionals.',
          ],
        FormType.declaration => [
            'I, $name, having capacity to make mental health decisions, '
                'willfully and voluntarily make this Declaration regarding my mental health care. '
                'I understand that mental health care includes any care, treatment, service or '
                'procedure to maintain, diagnose, treat or provide for mental health, including '
                'any medication program and therapeutic treatment. Electroconvulsive therapy may '
                'be administered only if I have specifically consented to it in this document. '
                'I will be the subject of laboratory trials or research only if specifically '
                'provided for in this document. Mental health care does not include psychosurgery '
                'or termination of parental rights. I understand that my incapacity will be '
                'determined by examination by a psychiatrist and one of the following: another '
                'psychiatrist, psychologist, family physician, attending physician or mental '
                'health treatment professional. Whenever possible, one of the decision makers '
                'will be one of my treating professionals.',
          ],
        FormType.poa => [
            'I, $name, having the capacity to make mental health decisions, '
                'authorize my designated health care agent to make certain decisions on my behalf '
                'regarding my mental health care. If I have not expressed a choice in this '
                'document, I authorize my agent to make the decision that my agent determines is '
                'the decision I would make if I were competent to do so.',
            'I understand that mental health care includes any care, treatment, service or '
                'procedure to maintain, diagnose, treat or provide for mental health, including '
                'any medication program and therapeutic treatment. Electroconvulsive therapy may '
                'be administered only if I have specifically consented to it in this document. '
                'I will be the subject of laboratory trials or research only if specifically '
                'provided for in this document. Mental health care does not include psychosurgery '
                'or termination of parental rights.',
            'I understand that my incapacity will be determined by examination by a '
                'psychiatrist and one of the following: another psychiatrist, psychologist, '
                'family physician, attending physician or mental health treatment professional. '
                'Whenever possible, one of the decision makers shall be one of my treating '
                'professionals.',
          ],
      };

  // ── Effective time (official pp. 25 / 33 / 40) ───────────────────────────
  String get effectiveHeader => switch (form) {
        FormType.combined =>
          'A. When this Combined Mental Health Declaration and Power of Attorney becomes effective',
        FormType.declaration => 'A. When this Declaration becomes effective',
        FormType.poa => 'C. When this Power of Attorney becomes effective',
      };

  /// Official POA says "will become effective"; the other two "becomes".
  String get effectiveLeadIn => switch (form) {
        FormType.combined =>
          'This Combined Mental Health Declaration and Power of Attorney becomes '
              'effective at the following designated time:',
        FormType.declaration =>
          'This Declaration becomes effective at the following designated time:',
        FormType.poa =>
          'This Power of Attorney will become effective at the following designated time:',
      };

  // ── Revocation & Amendments (official pp. 25 / 36 / 43) ──────────────────
  String get revocationHeader => switch (form) {
        FormType.combined => 'B. Revocation and Amendments',
        FormType.declaration => 'C. Revocation and Amendments',
        FormType.poa => 'E. Revocation and Amendments',
      };

  /// Official quirks preserved: the Combined paragraph switches to "this
  /// Power of Attorney" mid-paragraph (p. 25); only the Declaration says
  /// "Two years after" (p. 36; the others say "Two years from").
  /// App: the official POA numbers these items "(4)(5)(6)" (p. 43 typo) —
  /// normalized to (1)(2)(3).
  String get revocationParagraph => switch (form) {
        FormType.combined =>
          'This Combined Mental Health Care Declaration and Power of Attorney may be '
              'revoked in whole or in part at any time, either orally or in writing, as '
              'long as I have not been found to be incapable of making mental health '
              'decisions. My revocation will be effective upon communication to my attending '
              'physician or other mental health care provider, either by me or a witness to '
              'my revocation, of the intent to revoke. If I choose to revoke a particular '
              'instruction contained in this Power of Attorney in the manner specified, I '
              'understand that the other instructions contained in this Power of Attorney '
              'will remain effective until:\n'
              '(1) I revoke this Power of Attorney in its entirety;\n'
              '(2) I make a new combined Mental Health Care Declaration and Power of Attorney; or\n'
              '(3) Two years from the date this document was executed.',
        FormType.declaration =>
          'This Declaration may be revoked in whole or in part at any time, either '
              'orally or in writing, as long as I have not been found to be incapable of '
              'making mental health decisions. My revocation will be effective upon '
              'communication to my attending physician or other mental health care provider, '
              'either by me or a witness to my revocation, of the intent to revoke. If I '
              'choose to revoke a particular instruction contained in this Declaration in '
              'the manner specified, I understand that the other instructions contained in '
              'this Declaration will remain effective until:\n'
              '(1) I revoke this Declaration in its entirety;\n'
              '(2) I make a new Mental Health Advance Directive; or\n'
              '(3) Two years after the date this document was executed.',
        FormType.poa =>
          'This Power of Attorney may be revoked in whole or in part at any time, either '
              'orally or in writing, as long as I have not been found to be incapable of '
              'making mental health decisions. My revocation will be effective upon '
              'communication to my attending physician or other mental health care provider, '
              'either by me or a witness to my revocation, of the intent to revoke. If I '
              'choose to revoke a particular instruction contained in this Power of Attorney '
              'in the manner specified, I understand that the other instructions contained in '
              'this Power of Attorney will remain effective until:\n'
              '(1) I revoke this Power of Attorney in its entirety;\n'
              '(2) I make a new combined Mental Health Care Declaration and Power of Attorney; or\n'
              '(3) Two years from the date this document was executed.',
      };

  /// Official quirks preserved: Combined (p. 25) says "this Advance
  /// Directive … in the same way as the original document … by me, my agent,
  /// or a witness"; Declaration (p. 36) says "this Advance Directive … in the
  /// same way the original document was executed … by me or a witness"; POA
  /// (p. 43) says "this Power of Attorney … by me, my agent, or a witness".
  String get amendmentsParagraph => switch (form) {
        FormType.combined =>
          'I may make changes to this Advance Directive at any time, as long as I have '
              'capacity to make mental health care decisions. Any changes will be made in '
              'writing and be signed and witnessed by two individuals in the same way as the '
              'original document. Any changes will be effective as soon the changes are '
              'communicated to my attending physician or other mental health care provider, '
              'either by me, my agent, or a witness to my amendments.',
        FormType.declaration =>
          'I may make changes to this Advance Directive at any time, as long as I have '
              'capacity to make mental health care decisions. Any changes will be made in '
              'writing and be signed and witnessed by two individuals in the same way the '
              'original document was executed. Any changes will be effective as soon the '
              'changes are communicated to my attending physician or other mental health '
              'care provider, either by me or a witness to my amendments.',
        FormType.poa =>
          'I may make changes to this Power of Attorney at any time, as long as I have '
              'capacity to make mental health care decisions. Any changes will be made in '
              'writing and be signed and witnessed by two individuals in the same way the '
              'original document was executed. Any changes will be effective as soon the '
              'changes are communicated to my attending physician or other mental health '
              'care provider, either by me, my agent, or a witness to my amendments.',
      };

  // ── Termination (official pp. 25 / 36 / 43) ──────────────────────────────
  String get terminationHeader => switch (form) {
        FormType.combined => 'C. Termination',
        FormType.declaration => 'D. Termination',
        FormType.poa => 'F. Termination',
      };

  /// Official quirk preserved: the Combined's termination clause (p. 25) says
  /// "this Declaration" even though the document is the Combined form.
  String get terminationParagraph => switch (form) {
        FormType.combined || FormType.declaration =>
          'I understand that this Declaration will automatically terminate two years '
              'from the date of execution, unless I am deemed incapable of making mental '
              'health care decisions at the time that this Declaration would expire.',
        FormType.poa =>
          'I understand that this Power of Attorney will automatically terminate two '
              'years from the date of execution unless I am deemed incapable of making '
              'mental health care decisions at the time that the Power of Attorney would expire.',
      };

  // ── Agent designation (official pp. 29 / 39) ─────────────────────────────
  /// The Combined (p. 29) appends the "applies only to mental health
  /// decisions that are not addressed in the accompanying signed Declaration"
  /// sentence; the standalone POA (p. 39) does not.
  String get agentDesignationPreamble => switch (form) {
        FormType.combined =>
          'I hereby designate and appoint the following person as my agent to make mental '
              'health care decisions for me as authorized in this document. This authorization '
              'applies only to mental health decisions that are not addressed in the '
              'accompanying signed Declaration.',
        _ =>
          'I hereby designate and appoint the following person as my agent to make '
              'mental health care decisions for me as authorized in this document.',
      };

  /// Combined Part III repeats the intro naming the declarant (official p. 29,
  /// which adds "or in the accompanying Declaration").
  String? poaPartIntro(String name) => form == FormType.combined
      ? 'I, $name, having the capacity to make mental health decisions, '
          'authorize my designated health care agent to make certain decisions on my behalf '
          'regarding my mental health care. If I have not expressed a choice in this document '
          'or in the accompanying Declaration, I authorize my agent to make the decision that '
          'my agent determines is the decision I would make if I were competent to do so.'
      : null;

  /// Authority preamble (official pp. 30 / 40): the Combined adds
  /// ", or in the accompanying Declaration".
  String get authorityPreamble => switch (form) {
        FormType.combined =>
          'I hereby grant to my agent full power and authority to make mental health '
              'care decisions for me consistent with the instructions and limitations set '
              'forth in this document. If I have not expressed a choice in this Power of '
              'Attorney, or in the accompanying Declaration, I authorize my agent to make '
              'the decision that my agent determines is the decision I would make if I '
              'were competent to do so.',
        _ =>
          'I hereby grant to my agent full power and authority to make mental health '
              'care decisions for me consistent with the instructions and limitations set '
              'forth in this Power of Attorney. If I have not expressed a choice in this '
              'Power of Attorney, I authorize my agent to make the decision that my agent '
              'determines is the decision I would make if I were competent to do so.',
      };

  // ── Guardian & execution (official pp. 31 / 37 / 43-44) ──────────────────
  /// The noun in the guardian revoke/suspend/terminate rows.
  String get guardianDocNoun => switch (form) {
        FormType.combined =>
          'Combined Mental Health Care Declaration and Power of Attorney',
        FormType.declaration => 'Declaration',
        FormType.poa => 'Power of Attorney',
      };

  /// "I am making this … on the [dateStr]." (official pp. 31 / 37 / 44).
  String executionSentence(String dateStr) => switch (form) {
        FormType.combined =>
          'I am making this Combined Mental Health Care Declaration and Power of '
              'Attorney on the $dateStr.',
        FormType.declaration => 'I am making this Declaration on the $dateStr.',
        FormType.poa =>
          'I am making this Mental Health Care Power of Attorney on the $dateStr.',
      };

  /// App: the official POA (p. 44) misprints "Principle Signature" —
  /// rendered correctly as "Principal Signature".
  String get signatureLabel =>
      form == FormType.poa ? 'Principal Signature' : 'My Signature';

  /// The noun in the sign-on-behalf block (official pp. 32 / 38 / 45).
  String get signOnBehalfNoun => switch (form) {
        FormType.combined =>
          'Combined Mental Health Care Declaration and Power of Attorney',
        FormType.declaration => 'Declaration',
        FormType.poa => 'Mental Health Care Power of Attorney',
      };
}
