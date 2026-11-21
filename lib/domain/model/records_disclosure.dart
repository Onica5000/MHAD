/// The `recordsDisclosure` column holds three answers as labeled prose
/// blocks — who may receive the person's records, who must not, and other
/// limits. The labels are what the PDF, the FHIR export and the review
/// screen print, so they are written to read well. ONE definition, used by
/// the Anything-else step and autofill.
class RecordsDisclosure {
  const RecordsDisclosure({
    this.authorized = '',
    this.notAuthorized = '',
    this.otherLimits = '',
  });

  static const authorizedLabel = 'Authorized to receive my records:';
  static const notAuthorizedLabel = 'Not authorized to receive my records:';
  static const otherLimitsLabel = 'Other limitations on disclosure:';

  final String authorized;
  final String notAuthorized;
  final String otherLimits;

  /// Reads the labeled blocks. Text with no label (legacy free text, or
  /// text before the first label) is kept in [otherLimits] — never dropped.
  factory RecordsDisclosure.parse(String raw) {
    if (raw.trim().isEmpty) return const RecordsDisclosure();
    const labels = {
      'a': authorizedLabel,
      'n': notAuthorizedLabel,
      'o': otherLimitsLabel,
    };
    final positions = <String, int>{};
    labels.forEach((key, label) {
      final i = raw.indexOf(label);
      if (i >= 0) positions[key] = i;
    });
    if (positions.isEmpty) return RecordsDisclosure(otherLimits: raw.trim());
    final ordered = positions.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final values = {'a': '', 'n': '', 'o': ''};
    final prefix = raw.substring(0, ordered.first.value).trim();
    for (var idx = 0; idx < ordered.length; idx++) {
      final key = ordered[idx].key;
      final start = ordered[idx].value + labels[key]!.length;
      final end =
          idx + 1 < ordered.length ? ordered[idx + 1].value : raw.length;
      values[key] = raw.substring(start, end).trim();
    }
    final other = [prefix, values['o']!].where((t) => t.isNotEmpty).join('\n');
    return RecordsDisclosure(
      authorized: values['a']!,
      notAuthorized: values['n']!,
      otherLimits: other,
    );
  }

  String serialize() {
    final a = authorized.trim(), n = notAuthorized.trim(), o = otherLimits.trim();
    return [
      if (a.isNotEmpty) '$authorizedLabel $a',
      if (n.isNotEmpty) '$notAuthorizedLabel $n',
      if (o.isNotEmpty) '$otherLimitsLabel $o',
    ].join('\n\n');
  }

  /// Adds text to each block (on a new line after anything already there).
  RecordsDisclosure append({
    String? authorized,
    String? notAuthorized,
    String? otherLimits,
  }) {
    String add(String old, String? more) {
      if (more == null || more.trim().isEmpty) return old;
      return old.trim().isEmpty ? more.trim() : '${old.trim()}\n${more.trim()}';
    }

    return RecordsDisclosure(
      authorized: add(this.authorized, authorized),
      notAuthorized: add(this.notAuthorized, notAuthorized),
      otherLimits: add(this.otherLimits, otherLimits),
    );
  }
}
