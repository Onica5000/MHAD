/// Hardcoded, authoritative classification of which directive data is
/// personally-identifying (PII). The identity of the **user**, their
/// **agents**, and their **guardian nominee** is PII and MUST NEVER be sent to
/// the external AI (Gemini) as context. Clinical/medical content (effective
/// condition, diagnoses, medications, treatment preferences) and care-provider
/// details (doctors, facilities) are deliberately NOT treated as PII here —
/// they are the substance the assistant needs to be useful, and a doctor's
/// name is not the patient's identity.
///
/// Why hardcoded: the AI context is assembled by an explicit ALLOWLIST in
/// `buildAiFilledFields` (lib/ai/ai_context_builder.dart) — it only ever reads
/// the safe fields and never touches the identity columns below. This registry
/// pins that contract so a future change "can't make a mistake": the unit test
/// `test/unit/ai_context_pii_test.dart` seeds every field listed here and
/// asserts none of those values reach the AI context map. If someone later
/// adds, say, the user's name to the context, that test fails.
///
/// Separate path — uploads: photos and PDFs sent to the AI for snap-to-fill
/// cannot be scrubbed client-side (we can't reliably edit pixels), so identity
/// in an uploaded image is NOT covered by this allowlist. The user is instead
/// warned to black out anything they'd rather not share before uploading, and
/// reminded that any field can be filled in by hand to keep it private. See the
/// upload notice in lib/ui/wizard/widgets/document_pipeline_flow.dart.
class AiPiiPolicy {
  AiPiiPolicy._();

  /// `directives` columns that identify the USER. Never sent to the AI.
  static const userIdentityFields = <String>[
    'fullName',
    'dateOfBirth',
    'address',
    'address2',
    'city',
    'county',
    'state',
    'zip',
    'phone',
  ];

  /// `agents` columns that identify a designated AGENT / alternate. Never sent.
  static const agentIdentityFields = <String>[
    'fullName',
    'relationship',
    'address',
    'address2',
    'city',
    'state',
    'zip',
    'homePhone',
    'workPhone',
    'cellPhone',
  ];

  /// `guardianNominations` columns that identify the GUARDIAN nominee. Never
  /// sent.
  static const guardianIdentityFields = <String>[
    'nomineeFullName',
    'nomineeAddress',
    'nomineeAddress2',
    'nomineeCity',
    'nomineeState',
    'nomineeZip',
    'nomineePhone',
    'nomineeRelationship',
  ];

  /// `witnesses` columns that identify a WITNESS. Never sent.
  static const witnessIdentityFields = <String>[
    'fullName',
    'address',
    'address2',
    'city',
    'state',
    'zip',
    'phone',
  ];

  /// Care-provider / facility fields. NOT PII per project policy (a treating
  /// doctor's name is not the patient's identity), so these MAY be sent — though
  /// the current allowlist keeps the context minimal and omits most of them.
  static const nonPiiProviderFields = <String>[
    'preferredDoctorName',
    'preferredDoctorContact',
    'primaryDoctorName',
    'primaryDoctorSpecialty',
    'primaryDoctorPhone',
  ];

  /// Every PII field across the identity-bearing entities. Used by the lock
  /// test as the exhaustive set that must never appear in AI context.
  static const allIdentityFields = <String>[
    ...userIdentityFields,
    ...agentIdentityFields,
    ...guardianIdentityFields,
    ...witnessIdentityFields,
  ];
}
