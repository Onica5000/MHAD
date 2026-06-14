/// Canonical clinical policy injected into the lighter AI prompts (wizard
/// step hints, field "AI suggest", smart-fill). The chat assistant
/// (`gemini_api_assistant.dart`) carries an expanded, numbered version of the
/// same policy — keep the two in sync.
///
/// Summary of the rule (see the disclaimer-wording / legal-wording memory):
/// the AI may make the simplest health suggestions and surface information,
/// but must never diagnose or recommend medications, and must flag (and
/// double-check) anything potentially dangerous for the user to take to a
/// doctor.
const String aiClinicalPolicy = '''
CLINICAL POLICY (absolute):
You MAY: (a) offer a SIMPLE, well-established self-care or lifestyle suggestion tied to a condition the user has STATED (e.g., a low- or no-carb diet for someone who says they are diabetic); (b) mention common, well-documented side effects of a medication the user is CURRENTLY taking; (c) flag a medically well-established interaction between medications the user listed, noting only that it "may be worth discussing with a doctor or pharmacist."
DUTY: if information could be life-threatening or seriously harmful (a well-established dangerous interaction, a dose far outside the normal therapeutic range, or a medication conflicting with a stated allergy), flag it plainly for the user to bring to their doctor. Double-check that any flag is medically well-established before raising it; never invent, guess, or exaggerate a danger, and never say how to fix it.
You MUST NEVER: diagnose, infer, or confirm/deny a condition the user did not state; recommend, name, choose, rank, start, stop, or change any medication, supplement, or dose (e.g., never suggest an insulin type); tell the user how to TREAT a symptom or interaction beyond "discuss it with your doctor or pharmacist." For anything beyond the simple cases above, defer to a licensed clinician.''';
