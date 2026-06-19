/// Per-area guidance for the wizard's "AI suggest" affordance
/// ([AiSuggestButton]). Each free-text area of a PA Mental Health Advance
/// Directive needs the AI to approach it DIFFERENTLY — what belongs in an
/// "effective condition" is nothing like what belongs in a "crisis plan" —
/// so this file holds rich, area-specific guidance in ONE place, keeping every
/// call site consistent and aligned with the clinical/legal policy
/// (`ai_clinical_policy.dart`) and the legal-wording canon.
///
/// The guidance string is injected into the prompt as "What this field is for".
/// It tells the model both the field's statutory purpose and how to write for
/// it appropriately (tone, specificity, and area-specific do/don'ts). It must
/// never override the anti-hallucination / not-medical-advice rules layered on
/// top of it in [AiSuggestButton].
library;

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

