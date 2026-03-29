/// Detects and strips personally identifiable information from text before
/// sending to external AI APIs.
///
/// PII includes: names, addresses, phone numbers, SSNs, DOBs, emails,
/// insurance info, medical record numbers, credit card numbers, Medicare/
/// Medicaid IDs, driver's license numbers, and PO Box addresses.
///
/// Medical data (medications, conditions, facilities) is NOT stripped — that
/// is the information we intentionally send for analysis.
class PiiStripper {
  PiiStripper._();

  /// Detects PII in [text] and returns a report of what was found.
  /// Returns an empty list if no PII was detected.
  static List<String> detect(String text) {
    final found = <String>{};
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

  /// Strips PII from each value in a map of fields.
  /// Keys are preserved; only values are sanitized.
  /// Returns the sanitized map and a merged list of all removed categories.
  static PiiStripResult stripMapValues(Map<String, String> fields) {
    final sanitized = <String, String>{};
    final allRemoved = <String>{};
    for (final entry in fields.entries) {
      final result = stripWithReport(entry.value);
      sanitized[entry.key] = result.sanitizedText;
      allRemoved.addAll(result.removedCategories);
    }
    return PiiStripResult(
      sanitizedText:
          sanitized.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
      removedCategories: allRemoved.toList(),
      sanitizedMap: sanitized,
    );
  }

  // ── Pattern definitions ─────────────────────────────────────────────

  // SSN patterns: 123-45-6789, 123 45 6789.
  // Requires dashes or spaces to reduce false positives on arbitrary 9-digit
  // numbers. Bare 9-digit sequences are handled by _ssnBarePattern with a
  // contextual label requirement.
  static final _ssnDashPattern = RegExp(
    r'\b\d{3}[-\s]\d{2}[-\s]\d{4}\b',
  );

  // Bare 9-digit SSN only when preceded by a label like "SSN", "social
  // security", etc. to avoid false positives on other 9-digit numbers.
  static final _ssnLabeledBarePattern = RegExp(
    r'(?:SSN|social\s+security(?:\s+number)?|soc\s+sec)\s*[:=#]?\s*\d{9}\b',
    caseSensitive: false,
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

  // Standalone dates in common formats that are likely DOBs when context
  // suggests personal info. Matches MM/DD/YYYY, MM-DD-YYYY, YYYY-MM-DD.
  // Only matches when preceded by common PII-context words.
  static final _contextualDatePattern = RegExp(
    r'(?:born|birth|DOB|birthday|b-day|b\.d\.)\s*[:=]?\s*'
    r'(?:\d{1,2}[-/\.]\d{1,2}[-/\.]\d{2,4}|\d{4}[-/\.]\d{1,2}[-/\.]\d{1,2})',
    caseSensitive: false,
  );

  // "my name is John Smith", "I am John Smith", "I, John Smith,"
  static final _myNameIsPattern = RegExp(
    r'(?:my\s+name\s+is|I\s+am|I,)\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+){0,2}',
  );

  // "my name is john smith" — case-insensitive variant for lowercase input.
  // Only "my name is" (not "I am") to avoid matching "I am feeling better".
  static final _myNameIsPatternCI = RegExp(
    r'my\s+name\s+is\s+[a-z]+(?:\s+[a-z]+){1,2}(?=\s*[,.\n])',
    caseSensitive: false,
  );

  // "my sister Maria", "my agent John Smith" — case-sensitive
  static final _namedPersonPattern = RegExp(
    r'(?:(?:my\s+)?(?:sister|brother|mother|father|mom|dad|spouse|husband|wife|'
    r'partner|friend|neighbor|agent|alternate\s+agent|attorney|doctor|'
    r'psychiatrist|therapist|counselor|physician|nurse|social\s+worker|'
    r'guardian|caregiver|aide|pastor|rabbi|imam|priest|minister)\s+)'
    r'[A-Z][a-z]+(?:\s+[A-Z][a-z]+)?',
  );

  // Same as above but case-insensitive for lowercase input
  static final _namedPersonPatternCI = RegExp(
    r'(?:(?:my\s+)?(?:sister|brother|mother|father|mom|dad|spouse|husband|wife|'
    r'partner|friend|neighbor|agent|alternate\s+agent|attorney|doctor|'
    r'psychiatrist|therapist|counselor|physician|nurse|social\s+worker|'
    r'guardian|caregiver|aide|pastor|rabbi|imam|priest|minister)\s+)'
    r'[a-z]+(?:\s+[a-z]+)?(?=\s*[,.\n]|\s+(?:is|can|will|should|and|who)\b)',
    caseSensitive: false,
  );

  // Dr./Mr./Mrs./Ms. First Last
  static final _titledNamePattern = RegExp(
    r'\b(?:Dr|Mr|Mrs|Ms|Miss|Prof|Rev|Fr|Sr|Atty)\.?\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)?',
  );

  // Patient/principal name header patterns (common on medical documents)
  static final _patientNamePattern = RegExp(
    r'(?:patient|name|principal|client|witness|agent)\s*:\s*[A-Z][a-z]+(?:\s+[A-Z][a-z]+){0,2}',
    caseSensitive: false,
  );

  // "named [Name]", "called [Name]", "known as [Name]"
  static final _aliasPattern = RegExp(
    r'(?:named|called|known\s+as|goes\s+by)\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)?',
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
    r'Circle|Cir\.?|Pike|Highway|Hwy\.?|Parkway|Pkwy\.?|'
    r'Terrace|Ter\.?|Trail|Trl\.?|Alley|Aly\.?)\b',
  );

  // PO Box: "PO Box 123", "P.O. Box 123", "Post Office Box 123"
  static final _poBoxPattern = RegExp(
    r'\b(?:P\.?\s*O\.?\s*Box|Post\s+Office\s+Box)\s+\d+\b',
    caseSensitive: false,
  );

  // Apartment/unit/suite numbers: "Apt 4B", "Unit 12", "Suite 200"
  // Requires a leading # or digit after the keyword to avoid matching
  // common words like "building was" or "room was".
  static final _unitPattern = RegExp(
    r'\b(?:Apt|Apartment|Unit|Suite|Ste|Bldg|Building|Floor|Fl|Room|Rm)\.?\s*#\s*[A-Za-z0-9-]+\b'
    r'|'
    r'\b(?:Apt|Apartment|Suite|Ste)\.?\s+[A-Za-z]?\d+[A-Za-z]?\b',
    caseSensitive: false,
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
    r'(?:policy|member|group|subscriber|beneficiary)\s*(?:id|number|num|no|#)\s*[:=#]?\s*[A-Za-z0-9\-]{4,20}',
    caseSensitive: false,
  );

  // Medicare Beneficiary Identifier (MBI): format like 1EG4-TE5-MK72
  static final _medicareIdPattern = RegExp(
    r'(?:medicare|medicaid|MBI)\s*(?:id|number|num|no|#)?\s*[:=#]?\s*'
    r'[0-9][A-Za-z0-9]{3}-?[A-Za-z0-9]{3}-?[A-Za-z0-9]{4}\b',
    caseSensitive: false,
  );

  // Credit/debit card numbers: 4 groups of 4 digits, or 13-19 consecutive digits
  static final _creditCardPattern = RegExp(
    r'\b(?:\d{4}[-\s]){3}\d{4}\b',
  );

  // Labeled credit card for bare sequences
  static final _creditCardLabeledPattern = RegExp(
    r'(?:card|cc|credit|debit)\s*(?:number|num|no|#)\s*[:=#]?\s*\d{13,19}\b',
    caseSensitive: false,
  );

  // Driver's license: labeled with state or "DL" prefix
  static final _driversLicensePattern = RegExp(
    r"(?:driver'?s?\s*(?:license|lic)|DL|D\.L\.)\s*(?:number|num|no|#)?\s*[:=#]?\s*[A-Za-z0-9\-]{5,20}",
    caseSensitive: false,
  );

  // Passport number (labeled)
  static final _passportPattern = RegExp(
    r'(?:passport)\s*(?:number|num|no|#)?\s*[:=#]?\s*[A-Za-z0-9]{6,12}\b',
    caseSensitive: false,
  );

  /// Ordered list of all PII patterns with labels and replacements.
  /// Order matters: more specific patterns before broader ones to reduce
  /// false positives and ensure correct replacement text.
  static final _allPatterns = <_PiiPattern>[
    // Addresses first (most specific context)
    _PiiPattern('PO Box', _poBoxPattern, '[address removed]'),
    _PiiPattern('ZIP code', _zipPattern, ' [ZIP removed]'),
    _PiiPattern('street address', _streetPattern, '[address removed]'),
    _PiiPattern('unit/apartment', _unitPattern, '[address removed]'),
    // Identity numbers (specific labels before broad patterns)
    _PiiPattern('SSN', _ssnDashPattern, '[SSN removed]'),
    _PiiPattern('SSN', _ssnLabeledBarePattern, '[SSN removed]'),
    _PiiPattern('Medicare/Medicaid ID', _medicareIdPattern, '[Medicare ID removed]'),
    _PiiPattern('credit card number', _creditCardPattern, '[card number removed]'),
    _PiiPattern('credit card number', _creditCardLabeledPattern, '[card number removed]'),
    _PiiPattern("driver's license", _driversLicensePattern, '[license removed]'),
    _PiiPattern('passport number', _passportPattern, '[passport removed]'),
    // Contact info
    _PiiPattern('phone number', _phonePattern, '[phone removed]'),
    _PiiPattern('email address', _emailPattern, '[email removed]'),
    // Dates of birth
    _PiiPattern('date of birth', _dobLabelPattern, '[date of birth removed]'),
    _PiiPattern('date of birth', _unlabeledDobPattern, '[date of birth removed]'),
    _PiiPattern('date of birth', _contextualDatePattern, '[date of birth removed]'),
    // Names (multiple strategies)
    _PiiPattern('person name', _myNameIsPattern, '[name removed]'),
    _PiiPattern('person name', _myNameIsPatternCI, '[name removed]'),
    _PiiPattern('person name', _namedPersonPattern, '[name removed]'),
    _PiiPattern('person name', _namedPersonPatternCI, '[name removed]'),
    _PiiPattern('person name', _titledNamePattern, '[name removed]'),
    _PiiPattern('patient name', _patientNamePattern, '[patient name removed]'),
    _PiiPattern('person name', _aliasPattern, '[name removed]'),
    // Insurance and medical identifiers
    _PiiPattern('insurance info', _insurancePattern, '[insurance removed]'),
    _PiiPattern('facility name', _facilityNamePattern, '[facility removed]'),
    _PiiPattern('medical record number', _mrnPattern, '[record number removed]'),
    _PiiPattern('medical license number', _licensePattern, '[license removed]'),
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

  /// When [PiiStripper.stripMapValues] is used, contains the sanitized
  /// key-value pairs. Null for plain text stripping.
  final Map<String, String>? sanitizedMap;

  const PiiStripResult({
    required this.sanitizedText,
    required this.removedCategories,
    this.sanitizedMap,
  });

  bool get hadPii => removedCategories.isNotEmpty;

  /// Human-readable summary like "name, phone number, SSN"
  String get summary => removedCategories.toSet().join(', ');
}
