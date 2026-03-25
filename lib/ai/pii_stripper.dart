/// Detects and strips personally identifiable information from text before
/// sending to external AI APIs.
///
/// PII includes: names, addresses, phone numbers, SSNs, DOBs, emails,
/// insurance info, medical record numbers.
///
/// Medical data (medications, conditions, facilities) is NOT stripped — that
/// is the information we intentionally send for analysis.
class PiiStripper {
  PiiStripper._();

  /// Detects PII in [text] and returns a report of what was found.
  /// Returns an empty list if no PII was detected.
  static List<String> detect(String text) {
    final found = <String>{};
    // Check each category — use ordered list to catch all patterns
    // including duplicated keys
    for (final entry in _allPatterns) {
      if (entry.pattern.hasMatch(text)) {
        found.add(entry.label);
      }
    }
    return found.toList();
  }

  /// Strips detected PII from [text] and returns a [PiiStripResult]
  /// containing the sanitized text and a list of what was removed.
  static PiiStripResult stripWithReport(String text) {
    var result = text;
    final removed = <String>{};

    for (final entry in _allPatterns) {
      if (entry.pattern.hasMatch(result)) {
        removed.add(entry.label);
        result = result.replaceAll(entry.pattern, entry.replacement);
      }
    }

    return PiiStripResult(
      sanitizedText: result,
      removedCategories: removed.toList(),
    );
  }

  /// Strips detected PII from [text] and returns the sanitized version.
  /// Use [stripWithReport] if you need to know what was removed.
  static String strip(String text) => stripWithReport(text).sanitizedText;

  // ── Pattern definitions ─────────────────────────────────────────────

  // SSN patterns: 123-45-6789, 123 45 6789, 123456789
  static final _ssnPattern = RegExp(
    r'\b\d{3}[-\s]?\d{2}[-\s]?\d{4}\b',
  );

  // Phone: (215) 555-1234, 215-555-1234, +1 215 555 1234, etc.
  static final _phonePattern = RegExp(
    r'(?:\+?1[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}\b',
  );

  // Email addresses
  static final _emailPattern = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b',
  );

  // "date of birth", "DOB", "born on" + date
  static final _dobLabelPattern = RegExp(
    r'(?:date\s+of\s+birth|DOB|born\s+(?:on\s+)?)\s*:?\s*\d{1,2}[-/]\d{1,2}[-/]\d{2,4}',
    caseSensitive: false,
  );

  // "birthday is", "I was born" + date
  static final _unlabeledDobPattern = RegExp(
    r'(?:birthday\s+(?:is\s+)?|I\s+was\s+born\s+(?:on\s+)?)\s*'
    r'\d{1,2}[-/]\d{1,2}[-/]\d{2,4}',
    caseSensitive: false,
  );

  // "my sister Maria", "my agent John Smith"
  static final _namedPersonPattern = RegExp(
    r'(?:(?:my\s+)?(?:sister|brother|mother|father|mom|dad|spouse|husband|wife|'
    r'friend|neighbor|agent|attorney|doctor|psychiatrist|therapist|counselor|'
    r'physician|nurse|social\s+worker)\s+)'
    r'[A-Z][a-z]+(?:\s+[A-Z][a-z]+)?',
  );

  // Dr./Mr./Mrs./Ms. First Last
  static final _titledNamePattern = RegExp(
    r'\b(?:Dr|Mr|Mrs|Ms|Miss|Prof)\.?\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)?',
  );

  // Patient/principal name header patterns (common on medical documents)
  static final _patientNamePattern = RegExp(
    r'(?:patient|name|principal|client)\s*:\s*[A-Z][a-z]+(?:\s+[A-Z][a-z]+){0,2}',
    caseSensitive: false,
  );

  // 5-digit and 9-digit ZIP codes
  static final _zipPattern = RegExp(
    r'(?:,\s*|[A-Z]{2}\s+)\d{5}(?:-\d{4})?\b',
  );

  // Street addresses: "123 Main Street"
  static final _streetPattern = RegExp(
    r'\b\d{1,5}\s+(?:[NSEW]\.?\s+)?(?:[A-Z][a-z]+\s+){1,3}'
    r'(?:Street|St\.?|Avenue|Ave\.?|Boulevard|Blvd\.?|Drive|Dr\.?|'
    r'Road|Rd\.?|Lane|Ln\.?|Way|Court|Ct\.?|Place|Pl\.?|'
    r'Circle|Cir\.?|Pike|Highway|Hwy\.?)\b',
  );

  // Insurance company references
  static final _insurancePattern = RegExp(
    r'(?:(?:covered|insured|insurance|plan|policy)\s+'
    r'(?:by|with|through|is|from)\s+)'
    r'[A-Z][A-Za-z]+(?:\s+[A-Z][A-Za-z]+){0,3}',
    caseSensitive: false,
  );

  // Healthcare facility names: "at Springfield Hospital", "admitted to Valley Center"
  static final _facilityNamePattern = RegExp(
    r'(?:at|admitted\s+to|treated\s+at|visited|seen\s+at|discharged\s+from)\s+'
    r'[A-Z][A-Za-z\s&]+?'
    r'(?:Hospital|Clinic|Center|Institute|Medical|Behavioral|Psychiatric|'
    r'Health\s+System|Associates|Practice|Group)\b',
    caseSensitive: false,
  );

  // Medical record numbers
  static final _mrnPattern = RegExp(
    r'(?:MRN|medical\s+record|record\s+number|patient\s+(?:ID|number))'
    r'\s*[:=#]?\s*(?=.*\d)[A-Za-z0-9\-]{4,20}',
    caseSensitive: false,
  );

  // Medical license numbers (NPI, DEA, state license)
  static final _licensePattern = RegExp(
    r'(?:license|lic|NPI|DEA)\s*[:=#]?\s*[A-Za-z0-9\-]{5,20}',
    caseSensitive: false,
  );

  // Insurance policy/member/group/subscriber IDs
  static final _insuranceIdPattern = RegExp(
    r'(?:policy|member|group|subscriber)\s*(?:id|number|num|no|#)\s*[:=#]?\s*[A-Za-z0-9\-]{4,20}',
    caseSensitive: false,
  );

  /// Ordered list of all PII patterns with labels and replacements.
  /// Order matters: ZIP before SSN to avoid ZIP+4 false positives.
  static final _allPatterns = <_PiiPattern>[
    _PiiPattern('ZIP code', _zipPattern, ' [ZIP removed]'),
    _PiiPattern('SSN', _ssnPattern, '[SSN removed]'),
    _PiiPattern('phone number', _phonePattern, '[phone removed]'),
    _PiiPattern('email address', _emailPattern, '[email removed]'),
    _PiiPattern('date of birth', _dobLabelPattern, '[date of birth removed]'),
    _PiiPattern('date of birth', _unlabeledDobPattern, '[date of birth removed]'),
    _PiiPattern('person name', _namedPersonPattern, '[name removed]'),
    _PiiPattern('person name', _titledNamePattern, '[name removed]'),
    _PiiPattern('patient name', _patientNamePattern, '[patient name removed]'),
    _PiiPattern('street address', _streetPattern, '[address removed]'),
    _PiiPattern('insurance info', _insurancePattern, '[insurance removed]'),
    _PiiPattern('facility name', _facilityNamePattern, '[facility removed]'),
    _PiiPattern('medical record number', _mrnPattern, '[record number removed]'),
    _PiiPattern('medical license number', _licensePattern, '[license number removed]'),
    _PiiPattern('insurance ID', _insuranceIdPattern, '[insurance ID removed]'),
  ];
}

class _PiiPattern {
  final String label;
  final RegExp pattern;
  final String replacement;
  const _PiiPattern(this.label, this.pattern, this.replacement);
}

/// Result of PII stripping with a report of what was removed.
class PiiStripResult {
  final String sanitizedText;
  final List<String> removedCategories;

  const PiiStripResult({
    required this.sanitizedText,
    required this.removedCategories,
  });

  bool get hadPii => removedCategories.isNotEmpty;

  /// Human-readable summary like "name, phone number, SSN"
  String get summary => removedCategories.toSet().join(', ');
}
