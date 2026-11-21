# Field and AI audit — 2026-11-21

Every field a person fills in, or that gets filled in for them, checked against the AI
instructions that read or write it. Branch `audit/ai-fields-2026-11-21`.

## What was checked

| | |
|---|---|
| Fields | **81**, in 16 sections (table below): each traced screen → database column → autofill / smart-fill / AI check → PDF |
| Autofill can fill | **75** — from a photo, scan, PDF or voice recording (`lib/ai/document_extractor.dart`) |
| Smart-fill can suggest | **15** text boxes, plus neutral ECT / research guidance that is shown but never written (`lib/ai/smart_fill_service.dart`) |
| Never AI-filled, on purpose | witnesses and the signing date (wet ink); the side-effects checklist (its own AI task); the guardian choice (apply sets it) |
| Second opinion | Jev (TypeSafe) judged all 81 field cards against the autofill prompt; its flags matched the code trace |
| Envelope | `assets/data/ai_handoff.json` (v2) — the text wrapped around every copy-and-paste task, with the verified PA legal facts |

Forms: **C** Combined · **D** Declaration · **P** Power of attorney. The POA skips the five
preference steps and "Anything else"; autofill leaves those keys empty on a POA.

## Inventory

| Field (as on screen) | Stored in | How it's entered | Autofill key | Smart-fill | Forms |
|---|---|---|---|---|---|
| **About you** | | | | | |
| Full legal name | `Directives.fullName` | Text box, required. | `personal_info.full_name` | — | all |
| Date of birth | `Directives.dateOfBirth` | Text box MM/DD/YYYY plus a date picker, required. | `personal_info.date_of_birth` | — | all |
| Street address | `Directives.address` | Text box. | `personal_info.address_line1` | — | all |
| Apt, suite, unit | `Directives.address2` | Text box. | `personal_info.address_line2` | — | all |
| City | `Directives.city` | Text box; ZIP lookup can fill it. | `personal_info.city` | — | all |
| County | `Directives.county` | Text box; ZIP lookup can fill it. | `personal_info.county` | — | all |
| State | `Directives.state` | Text box, defaults to PA. | `personal_info.state` | — | all |
| ZIP | `Directives.zip` | Text box, accepts 12345 or 12345-6789; a lookup fills city/county/state. | `personal_info.zip` | — | all |
| Phone number | `Directives.phone` | Text box, formatted (xxx) xxx-xxxx, 10 digits. | `personal_info.phone` | — | all |
| **When this kicks in** | | | | | |
| A psychiatrist + one other professional find I lack capacity | `Directives.triggerTwoProfessionals` | Checkbox. | `trigger_two_professionals` | — | all |
| A court determines I lack capacity | `Directives.triggerCourtOrder` | Checkbox. | `trigger_court_order` | — | all |
| I am involuntarily committed | `Directives.triggerInvoluntaryCommitment` | Checkbox. | `trigger_involuntary_commitment` | — | all |
| In your own words (when it takes effect) | `Directives.effectiveCondition` | Multi-line text box, optional. | `effective_condition` | effective_condition (only when empty) | all |
| Name of doctor I prefer to evaluate my capacity | `Directives.preferredDoctorName` | Text box. | `personal_info.preferred_evaluating_doctor_name` | — | all |
| That doctor's address / phone number | `Directives.preferredDoctorContact` | Text box. | `personal_info.preferred_evaluating_doctor_contact` | — | all |
| **People I trust — agent** | | | | | |
| Agent: full name | `Agents (agentType=primary).fullName` | Text box. | `personal_info.agent.name` | — | C, P |
| Agent: relationship | `Agents (agentType=primary).relationship` | Text box. | `personal_info.agent.relationship` | — | C, P |
| Agent: street address | `Agents (agentType=primary).address` | Address fields (street). | `personal_info.agent.address_line1` | — | C, P |
| Agent: apt, suite, unit | `Agents (agentType=primary).address2` | Address fields (line 2). | `personal_info.agent.address_line2` | — | C, P |
| Agent: city / state / ZIP | `Agents (agentType=primary).city,state,zip` | Address fields. | `personal_info.agent.city/state/zip` | — | C, P |
| Agent: phone number | `Agents (agentType=primary).cellPhone` | One 'Phone number' box (the contact picker may also fill home/work phones, not shown as separate boxes). | `personal_info.agent.phone` | — | C, P |
| **People I trust — alternate agent** | | | | | |
| Alternate agent: full name | `Agents (agentType=alternate).fullName` | Text box. | `personal_info.alternate_agent.name` | — | C, P |
| Alternate agent: relationship | `Agents (agentType=alternate).relationship` | Text box. | `personal_info.alternate_agent.relationship` | — | C, P |
| Alternate agent: street address | `Agents (agentType=alternate).address` | Address fields (street). | `personal_info.alternate_agent.address_line1` | — | C, P |
| Alternate agent: apt, suite, unit | `Agents (agentType=alternate).address2` | Address fields (line 2). | `personal_info.alternate_agent.address_line2` | — | C, P |
| Alternate agent: city / state / ZIP | `Agents (agentType=alternate).city,state,zip` | Address fields. | `personal_info.alternate_agent.city/state/zip` | — | C, P |
| Alternate agent: phone number | `Agents (agentType=alternate).cellPhone` | One 'Phone number' box (the contact picker may also fill home/work phones, not shown as separate boxes). | `personal_info.alternate_agent.phone` | — | C, P |
| **Agent authority** | | | | | |
| Agent may consent to medication (general psychiatric medications only — does not include ECT) | `DirectivePrefs.agentCanConsentMedication` | Checkbox. | `agent_can_consent_medication` | — | C, P |
| Additional limitations or instructions for the agent | `DirectivePrefs.agentAuthorityLimitations` | Multi-line text box, optional. | `agent_authority_limitations` | — | C, P |
| **If a court appoints a guardian** | | | | | |
| Who I nominate: same as my primary agent / same as my alternate agent / a different person / no preference | `GuardianNominations.guardianRelation` | Four choices. | — (apply sets it when autofill fills a nominee: same as the agent or alternate when the name matches, else “a different person”) | — | all |
| Nominee: full name | `GuardianNominations.nomineeFullName` | Text box (shown for 'a different person'). | `personal_info.guardian.name` | — | all |
| Nominee: relationship to you | `GuardianNominations.nomineeRelationship` | Text box. | `personal_info.guardian.relationship` | — | all |
| Nominee: address and phone | `GuardianNominations.nomineeAddress/Address2/City/State/Zip/Phone` | Address fields + phone box. | `personal_info.guardian.address_line1/address_line2/city/state/zip/phone` | — | all |
| Can override this directive (yes / no) | `GuardianNominations.guardianCanRevoke` | Yes/No choice. | `guardian_can_revoke` | — | all |
| Condition on overriding (shown when Yes) | `GuardianNominations.guardianCanRevokeNote` | Text box shown only when the answer is Yes. | `guardian_can_revoke_note` | — | all |
| **Where I want care** | | | | | |
| Preferred treatment facilities (name + optional location, one or more rows) | `DirectivePrefs.preferredFacilityName` | Rows of 'Facility name' (with a facility search) + 'Location (optional)'. | `preferred_facility` | preferred_facility_note → Other instructions | C, D |
| Facilities to avoid (name + optional location, one or more rows) | `DirectivePrefs.avoidFacilityName` | Same rows as above. | `avoid_facility` | avoid_facility_note → Other instructions | C, D |
| Room preferences (chips) | `DirectivePrefs.roomPreferences` | Seven chips: single room, window if possible, quiet floor, same-gender roommate, no roommate, trans-affirming staff, low-stimulation unit. | `room_preference_chips (all 7) + same_gender_roommate` | — | C, D |
| Same-gender roommate: match me with (women / men / same as my gender identity / describe) | `DirectivePrefs.roommateGenderMatch` | Four options shown when the same-gender chip is on; 'describe' opens a text box. | `roommate_gender_match (women / men / sameAsIdentity / specify: …)` | — | C, D |
| Other room preferences | `DirectivePrefs.roomPreferencesNote` | Text box. | `room_preferences_note` | — | C, D |
| **Diagnoses** | | | | | |
| Diagnoses (each a condition name + ICD-10-CM code from the registry search) | `DiagnosisEntries.name/icdCode` | Search box over ICD-10-CM; each pick adds a row. | `diagnoses` | — | C, D |
| Primary doctor: name | `Directives.primaryDoctorName` | Text box with a provider-registry search. | `personal_info.primary_doctor_name` | — | C, D |
| Primary doctor: specialty | `Directives.primaryDoctorSpecialty` | Text box. | `personal_info.primary_doctor_specialty` | — | C, D |
| Primary doctor: phone | `Directives.primaryDoctorPhone` | Text box. | `personal_info.primary_doctor_phone` | — | C, D |
| **Medications** | | | | | |
| Medications I currently take (name, dosage, reason) | `MedicationEntries(entryType=current)` | Rows: medication name (search), 'Dosage (e.g. 20 mg twice daily)', 'Reason / notes (optional)'. | `medications_current` | — | C, D |
| Medications I prefer (name, reason) | `MedicationEntries(entryType=preferred)` | Rows: name + 'Reason / notes (optional)'. | `medications_preferred` | — | C, D |
| Medications I never want (name, reason) | `MedicationEntries(entryType=exception)` | Rows: name + reason. | `medications_to_avoid` | — | C, D |
| Medications only under limits (name, conditions) | `MedicationEntries(entryType=limitation)` | Rows: name + reason. | `medications_limited` | — | C, D |
| General consent to medications | `DirectivePrefs.medicationConsent` | Choice: I consent · my agent decides (Combined) · I do not consent (a conditional consent is kept and shown). | `medication_consent` | — | C, D |
| **Allergies & reactions** | | | | | |
| Allergy: kind (drug / food / material / other) | `DirectiveAllergies.kind` | Choice of four. | `allergies[].kind` | — | C, D |
| Allergy: substance | `DirectiveAllergies.substance` | Search box (RxTerms for drugs). | `allergies[].substance` | — | C, D |
| Allergy: severity (mild / moderate / severe) | `DirectiveAllergies.severity` | Choice of three. | `allergies[].severity` | — | C, D |
| Allergy: reactions | `DirectiveAllergies.reactions` | Reaction chips + 'e.g. Hives, Swelling, Throat closing' text box. | `allergies[].reactions` | — | C, D |
| Allergy: notes | `DirectiveAllergies.notes` | Optional notes box. | `allergies[].notes` | — | C, D |
| **Procedures & research** | | | | | |
| Electroconvulsive therapy (ECT): I consent / I do not consent / my agent decides / I consent under conditions (+ conditions text) | `DirectivePrefs.ectConsent` | Four choices; 'under conditions' opens a required 'Conditions' text box. 'My agent decides' only on forms with an agent. | `ect_consent` | guidance shown, never written | C, D |
| Experimental studies: I consent / I do not consent / my agent decides / I consent under conditions (+ conditions text) | `DirectivePrefs.experimentalConsent` | Four choices; 'under conditions' opens a required 'Conditions' text box. 'My agent decides' only on forms with an agent. | `experimental_consent` | guidance shown, never written | C, D |
| Drug trials: I consent / I do not consent / my agent decides / I consent under conditions (+ conditions text) | `DirectivePrefs.drugTrialConsent` | Four choices; 'under conditions' opens a required 'Conditions' text box. 'My agent decides' only on forms with an agent. | `drug_trial_consent` | guidance shown, never written | C, D |
| **Anything else** | | | | | |
| Activities & environment | `AdditionalInstructions.activities` | Multi-line text box, optional. | `activities` | activities | C, D |
| Crisis intervention | `AdditionalInstructions.crisisIntervention` | Multi-line text box, optional. | `crisis_intervention` | crisis_intervention | C, D |
| De-escalation techniques | `AdditionalInstructions.other [DE-ESCALATION] line` | Multi-line text box, optional. | — (a document’s de-escalation goes to crisis_intervention; see O1) | deescalation | C, D |
| Potential crisis triggers | `AdditionalInstructions.other [TRIGGERS] line` | Multi-line text box, optional. | — (a document’s triggers go to crisis_plan.triggers; see O1) | triggers | C, D |
| Health history | `AdditionalInstructions.healthHistory` | Multi-line text box, optional. | `health_history` | health_history | C, D |
| Dietary preferences | `AdditionalInstructions.dietary` | Multi-line text box, optional. | `dietary` | dietary | C, D |
| Religious & spiritual | `AdditionalInstructions.religious` | Multi-line text box, optional. | `religious` | religious | C, D |
| Children & custody | `AdditionalInstructions.childrenCustody` | Multi-line text box, optional. | `children_custody` | children_custody | C, D |
| Family notification | `AdditionalInstructions.familyNotification` | Multi-line text box, optional. | `family_notification` | family_notification | C, D |
| Pet care | `AdditionalInstructions.petCustody` | Multi-line text box, optional. | `pet_custody` | pet_custody | C, D |
| Reproductive health care | `AdditionalInstructions.other [REPRODUCTIVE] line` | Multi-line text box, optional. | `reproductive_health` | — | C, D |
| Records: who may receive my records | `AdditionalInstructions.recordsDisclosure 'Authorized to receive my records:' block` | Multi-line text box, optional. | `records_authorized` | — | C, D |
| Records: who must NOT receive my records | `AdditionalInstructions.recordsDisclosure 'Not authorized to receive my records:' block` | Multi-line text box, optional. | `records_not_authorized` | — | C, D |
| Records: other limitations on disclosure | `AdditionalInstructions.recordsDisclosure 'Other limitations on disclosure:' block` | Multi-line text box, optional. | `records_disclosure` | records_disclosure | C, D |
| Other instructions | `AdditionalInstructions.other (untagged lines)` | Multi-line text box, optional. | `other` | agent_guidance (agent forms) → Other instructions | C, D |
| **Crisis plan (optional add-on)** | | | | | |
| Early warning signs | `DirectivePrefs.crisisPlanJson.early_warning` | List of short notes; '+ Add' adds one. | `crisis_plan.early_warning` | — | C, D |
| Triggers to watch for | `DirectivePrefs.crisisPlanJson.triggers` | List of short notes; '+ Add' adds one. | `crisis_plan.triggers` | — | C, D |
| Things that genuinely help | `DirectivePrefs.crisisPlanJson.helps` | List of short notes; '+ Add' adds one. | `crisis_plan.helps` | — | C, D |
| Things to say to me | `DirectivePrefs.crisisPlanJson.say_to_me` | List of short notes; '+ Add' adds one. | `crisis_plan.say_to_me` | — | C, D |
| Don’t do these | `DirectivePrefs.crisisPlanJson.dont_do` | List of short notes; '+ Add' adds one. | `crisis_plan.dont_do` | — | C, D |
| **Self-binding (Ulysses) clause** | | | | | |
| I acknowledge this (follow my directive even if I object during a crisis) | `DirectivePrefs.selfBindingEnabled` | Switch. | `self_binding_ulysses` | — | C, D |
| **Side effects checklist** | | | | | |
| Side effects I experience (per current medication: effect, daily-life impact, serious) | `DirectivePrefs.sideEffectsJson` | Checklist the separate side-effects AI task builds from current medications; the person ticks what they experience. | — (its own AI task: side effects) | — | C, D |
| **Signing (wet ink, not in the app)** | | | | | |
| Witness 1 and 2: name, address, phone, signature date | `Witnesses.*` | Not entered in the app; blank lines on the PDF to fill in by hand. | never (prompt rule) | — | all |
| Date signed (execution date) | `Directives.executionDate` | Not entered; left blank to write by hand. | never | — | all |

## Findings and fixes

| # | What was wrong | What it did to a person | Fix | Commit |
|---|---|---|---|---|
| F1 | Medications step had one checkbox ("agent decides"); anything else saved as "yes" | A refusal or conditional consent from autofill turned into "I consent to the medications my physician recommends" on the next save | The official form's choices; a conditional consent is kept | 459faab |
| F11 | POA PDF's medication rows read the person's consent, which the POA never asks | A POA always printed "consent to the medications my agent agrees to", even when the agent may not consent | Rows follow "Agent may consent to medication" | 4b63b14 |
| F6 | Prompt knew 4 of the 7 room chips (and mapped low-stimulation onto quiet floor); review showed 3 | No roommate, trans-affirming staff and low-stimulation unit could never be autofilled | One chip list (`kRoomPreferenceChipIds`) for prompt, apply and review; "specify: …" roommate match | dc01937 |
| F10 | Spanish replies wrote medication / diagnosis / allergy names in Spanish | "litio", "trastorno bipolar" can't be checked against RxNorm / ICD-10-CM — everything showed unverified, and Spanish drug names landed on the English form | Those names come back as standard English names; anything unclear is copied exactly so it's flagged | dc01937 |
| F9 | AI check never saw the three "takes effect when" checkboxes | A directive using the standard trigger looked like it had no effect condition | Summary lists the checked triggers | dc01937 |
| F4 | Only the first line of de-escalation / triggers / reproductive care was tagged | Extra lines fell into "Other instructions" on reload and on the PDF | `OtherInstructions` — one format, every line tagged, used by the step, the PDF and apply | 5061a3d |
| S5 | Smart-fill was never given the person's entries | It "built on" empty boxes, and told the AI the default consent values were the person's choices | Both smart-fill paths pass the directive's real (PII-filtered) entries | 5061a3d |
| S1 | Smart-fill de-escalation / triggers went into "Crisis intervention" under English labels | Suggestions landed in the wrong box | They go to their own boxes | 5061a3d |
| S3 / S4 | Smart-fill asked for "timeline, past treatments, hospitalizations"; triggers written as facts | Invited invented history; generic triggers read as the person's own | Only facts the person gave; triggers are suggestions to keep or delete | 5061a3d |
| F2 | "Reproductive health care" had a box but no autofill key | Never autofilled | `reproductive_health` key | 5061a3d |
| F8 | Apply never set the guardian choice | An autofilled nominee stayed hidden behind an earlier "no preference" | Apply sets it (same as agent / alternate by name, else "a different person") | 7d12b37 |
| F3 | Autofill wrote allergy notes and the PDF printed them, but no screen showed them | Notes the person couldn't see or change | Optional notes box on the Allergies step (EN + ES) | 7d12b37 |
| F5 | Records: 3 boxes on screen, 1 untagged answer from autofill; text before the first label was lost on save | "Who may" / "who must not" always landed in "Other limitations" | `RecordsDisclosure` — one format; `records_authorized` / `records_not_authorized` keys | 3f07d00 |
| P1 | Prompt had the § 5836(b) fact but no rule | A document "consenting" to psychosurgery or to ending parental rights went into the directive (the "never drop an instruction — put it in other" rule) | Never put such a permission in any field | ed6ba98 |
| P2 | No rule for witness plans | "My agent will be my witness" could print in "Other instructions" | Witnesses are never autofilled | ed6ba98 |
| P3 | "NEVER put any person's name into a care field" contradicted the prompt's own example ("call my sister Jane") | "My neighbor Mr. Ortiz has a key" lost the name | Phone numbers and addresses stay out of care fields; names the instruction needs stay | 485ee7e |
| P4 | No rule for ID numbers on the PII-exempt autofill path | "Put my Social Security number in the directive" would print it on a form shared with providers | SSN, insurance, ID-card, record and account numbers never go in any field | 91e95f8 |
| S6 | Smart-fill's consent block (live after S5) asked for "risks, benefits" on a YES; the ECT field said never | Contradictory instructions; possible advice in the guidance | Neutral: never argue for or against a choice, never name a medication; no "HIPAA" meta-text | bb034a0 |

Every fix has a test: `room_chips_test`, `other_instructions_test`, `records_disclosure_test`,
`autofill_legal_rules_test`, `poa_medication_rows_test`, `medications_diagnoses_step_test`,
`clinical_steps_persistence_test`. PDF diff after each PDF-touching change: 39/39 pages identical.

## Open — not changed (your call)

| # | Question | Recommendation |
|---|---|---|
| O1 | Autofill puts a document's de-escalation into "Crisis intervention" and its triggers into the Crisis plan list; smart-fill and the person use the "De-escalation techniques" / "Potential crisis triggers" boxes. All of them print. | Pick one home for each, after the batch-2 tests show what the AIs do |
| O2 | The handoff reply must be JSON only, so the AI can't tell the person what it left out or doubts (an impossible date, a psychosurgery clause it dropped, a drug it couldn't identify). | Add a short `check_notes` list, shown at the top of the autofill review. Batch 2 measures the gap first |
| O3 | The autofill review doesn't check dates, ZIP codes or phone numbers; the About-you step does (impossible date, under 18, 5/9-digit ZIP, 10-digit phone) once the person reaches it | Reuse those checks in the review |
| O4 | Spanish documents often write dates day-first (12/08/1966); the prompt only says "convert to MM/DD/YYYY" | Tell the AI that a Spanish document's numeric date is usually day-first, and to leave a truly ambiguous one for the person |
| O5 | App wording on what each AI accepts (Gemini "about 10 minutes each"; 13 one-section clips vs a 10-file cap; no "sign in to attach" note; Grok audio "unconfirmed") | Verify with the capability test (TEST-PLAN part A), then fix — see `ai-capabilities/README.md` in the test folder |
| O6 | Current medications: the screen's box says "Reason / notes"; the prompt says reason = the condition only | Minor — align the prompt with the box |
| O7 | A medication already on a list is skipped when a later file names it again, even with a different dose (it compares the name and the list only) | Show a different dose as a choice in the review instead of dropping it |
