/// The additional-instructions `other` column holds the person's own "Other
/// instructions" text plus three app sections — de-escalation techniques,
/// potential crisis triggers, reproductive health care — each line of a
/// section prefixed with its tag. ONE definition, used by the Anything-else
/// step, the PDF and autofill / smart-fill.
///
/// Every line of a section carries the tag, so a multi-line answer survives.
/// (Only the first line used to be tagged: the rest fell into "Other
/// instructions" on reload and on the PDF.) A legacy one-line section still
/// reads the same way.
class OtherInstructions {
  const OtherInstructions({
    this.deescalation = '',
    this.triggers = '',
    this.reproductive = '',
    this.other = '',
  });

  static const deescalationTag = '[DE-ESCALATION] ';
  static const triggersTag = '[TRIGGERS] ';
  static const reproductiveTag = '[REPRODUCTIVE] ';

  final String deescalation;
  final String triggers;
  final String reproductive;

  /// Everything untagged — the "Other instructions" box.
  final String other;

  factory OtherInstructions.parse(String raw) {
    final de = <String>[], tr = <String>[], re = <String>[], ot = <String>[];
    for (final line in raw.split('\n')) {
      if (line.startsWith(deescalationTag)) {
        de.add(line.substring(deescalationTag.length));
      } else if (line.startsWith(triggersTag)) {
        tr.add(line.substring(triggersTag.length));
      } else if (line.startsWith(reproductiveTag)) {
        re.add(line.substring(reproductiveTag.length));
      } else {
        ot.add(line);
      }
    }
    return OtherInstructions(
      deescalation: de.join('\n').trim(),
      triggers: tr.join('\n').trim(),
      reproductive: re.join('\n').trim(),
      other: ot.join('\n').trim(),
    );
  }

  String serialize() {
    Iterable<String> tagged(String tag, String text) => text.trim().isEmpty
        ? const []
        : text.trim().split('\n').map((l) => '$tag$l');
    return [
      ...tagged(deescalationTag, deescalation),
      ...tagged(triggersTag, triggers),
      ...tagged(reproductiveTag, reproductive),
      if (other.trim().isNotEmpty) other.trim(),
    ].join('\n');
  }

  /// Adds text to a section (on a new line after anything already there).
  OtherInstructions append({
    String? deescalation,
    String? triggers,
    String? reproductive,
    String? other,
  }) {
    String add(String old, String? more) {
      if (more == null || more.trim().isEmpty) return old;
      return old.trim().isEmpty ? more.trim() : '${old.trim()}\n${more.trim()}';
    }

    return OtherInstructions(
      deescalation: add(this.deescalation, deescalation),
      triggers: add(this.triggers, triggers),
      reproductive: add(this.reproductive, reproductive),
      other: add(this.other, other),
    );
  }
}
