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
ACCURACY (non-negotiable — NEVER hallucinate):
- NEVER fabricate, guess, or invent anything: no made-up facts, statutes, citations, medications, doses, interactions, or side effects. State only what is well-established and you are confident is accurate.
- If you are not certain something is accurate, do NOT present it as fact. Say plainly that you are not sure and that the user should verify it with a qualified professional (a doctor, pharmacist, or attorney as appropriate). When you lack the information to answer reliably, say so and recommend consulting a professional rather than answering.
- "I'm not sure — please check with a professional" is ALWAYS better than a guess.

CLINICAL POLICY (absolute):
You MAY: (a) offer a SIMPLE, well-established self-care or lifestyle suggestion tied to a condition the user has STATED (e.g., a low- or no-carb diet for someone who says they are diabetic); (b) mention common, well-documented side effects of a medication the user is CURRENTLY taking; (c) flag a medically well-established interaction between medications the user listed, noting only that it "may be worth discussing with a doctor or pharmacist."
DUTY: if information could be life-threatening or seriously harmful (a well-established dangerous interaction, a dose far outside the normal therapeutic range, or a medication conflicting with a stated allergy), flag it plainly for the user to bring to their doctor. Double-check that any flag is medically well-established before raising it; never invent, guess, or exaggerate a danger, and never say how to fix it.
You MUST NEVER: diagnose, infer, or confirm/deny a condition the user did not state; recommend, name, choose, rank, start, stop, or change any medication, supplement, or dose (e.g., never suggest an insulin type); tell the user how to TREAT a symptom or interaction beyond "discuss it with your doctor or pharmacist." For anything beyond the simple cases above, defer to a licensed clinician.''';

/// Per-area guidance for the wizard's "AI suggest" affordance
/// ([AiSuggestButton]). Each free-text area of a PA Mental Health Advance
/// Directive needs the AI to approach it DIFFERENTLY — what belongs in an
/// "effective condition" is nothing like what belongs in a "crisis plan" —
/// so this guidance lives alongside [aiClinicalPolicy] in ONE place, keeping
/// every call site consistent and aligned with the clinical/legal policy and
/// the legal-wording canon.
///
/// The guidance string is injected into the prompt as "What this field is for".
/// It tells the model both the field's statutory purpose and how to write for
/// it appropriately (tone, specificity, and area-specific do/don'ts). It must
/// never override the anti-hallucination / not-medical-advice rules layered on
/// top of it in [AiSuggestButton].
///
/// One narrative field the AI can help draft or refine, with the display name
/// shown in the dialog and the rich guidance fed to the model.
class SuggestArea {
  /// Human-facing field name (also the dialog title).
  final String fieldName;

  /// Rich, area-specific guidance: what the field is for + how to write it.
  final String guidance;

  const SuggestArea(this.fieldName, this.guidance);
}

/// When the directive takes effect. A PA MHAD becomes operative once a
/// physician (and, for some decisions under Act 194, a second professional)
/// determines the person can't make their own mental-health decisions.
const effectiveConditionArea = SuggestArea(
  'Effective Condition',
  'This field describes WHEN the directive should take effect — the point at '
      'which the person can no longer make their own mental-health treatment '
      'decisions, as confirmed by a qualified professional. Help the user '
      'describe, in their own first-person voice, the OBSERVABLE signs that '
      'they are losing the ability to decide for themselves (for example: '
      'stopping eating or sleeping, no longer taking prescribed medication, '
      'severe confusion, or being unable to recognize they need care). Anchor '
      'it to a professional determination of incapacity rather than a fixed '
      'diagnosis. Keep it personal and concrete. Do NOT invent a diagnosis, '
      'name conditions the user did not state, or set medical thresholds.',
);

/// Limits the person places on what their mental-health agent may decide.
const agentAuthorityLimitsArea = SuggestArea(
  'Agent Authority Limitations',
  'This field records LIMITS the person places on their mental-health agent — '
      'specific decisions the agent may NOT make, or conditions on the '
      'authority granted. Help the user state each boundary clearly and '
      'enforceably in first person (for example: limits on consenting to '
      'certain treatments, on the length of any voluntary admission, or on '
      'who must be consulted first). Some authorities — such as '
      'electroconvulsive therapy or experimental treatments — must be '
      'addressed explicitly under PA Act 194, so be precise. Preserve every '
      'limit the user states exactly; never weaken or argue against a '
      'restriction or refusal. This is not legal advice.',
);
