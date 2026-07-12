part of 'document_pipeline_flow.dart';

// Review-step data construction, display-label helpers, and the
// review/results-step UI for the document pipeline, plus the _SnapReviewRow
// row widget. Split out of document_pipeline_flow.dart; these extension
// methods share the pipeline State's private fields, so behavior is unchanged.
//
// ignore_for_file: invalid_use_of_protected_member
// (extension methods on the State legitimately call its protected setState)

// Display-only badges appended to a facility's review value to show whether the
// name matched the NPI organization registry. Stripped before saving (see
// `_facilityValue` in pipeline_apply_service.dart).
const String facilityVerifiedBadge = ' [NPI verified]';
const String facilityUnverifiedBadge = ' [unverified]';

/// Smart-fill display keys that are drafting GUIDANCE for the user to read,
/// deliberately never written into the directive (AI meta-text must not print
/// into the legal form). The user makes the actual choice in the Procedures &
/// research step. Keys match [SmartFillResult.toDisplayMap].
const Set<String> _smartGuidanceOnlyKeys = {
  'ECT Guidance',
  'Experimental Studies Guidance',
  'Drug Trials Guidance',
};

extension _PipelineReviewUi on _PipelineScreenState {
  void _buildReviewData(ValidatedExtractionResult v) {
    _reviewChecked = {};
    _reviewEdited = {};

    for (final m in v.preferredMeds) {
      final key = 'med_prefer_${m.originalName}';
      _reviewChecked[key] = true;
      final badge = m.isValidated ? ' [RxNorm verified]' : ' [unverified]';
      final reason = m.reason.isNotEmpty ? ' — ${m.reason}' : '';
      _reviewEdited[key] = '${m.displayName}$reason$badge';
    }
    for (final m in v.avoidMeds) {
      final key = 'med_avoid_${m.originalName}';
      _reviewChecked[key] = true;
      final badge = m.isValidated ? ' [RxNorm verified]' : ' [unverified]';
      final reason = m.reason.isNotEmpty ? ' — ${m.reason}' : '';
      _reviewEdited[key] = '${m.displayName}$reason$badge';
    }
    for (final c in v.conditions) {
      final key = 'cond_${c.originalText}';
      _reviewChecked[key] = true;
      final badge =
          c.isValidated ? ' [${c.code}]' : ' [no ICD match]';
      _reviewEdited[key] = '${c.displayName}$badge';
    }
    // Health history is verbatim prose (one reviewable note), not split into
    // ICD-matched fragments — preserves everything the document said.
    if (v.healthHistory != null) {
      _reviewChecked['hh_note'] = true;
      _reviewEdited['hh_note'] = v.healthHistory!;
    }
    // The person's verbatim "when it kicks in" wording — editable and applied
    // as written (the cond_* chips above are derived context, not a
    // replacement for the person's own trigger language).
    if (v.effectiveCondition != null) {
      _reviewChecked['effective_condition'] = true;
      _reviewEdited['effective_condition'] = v.effectiveCondition!;
    }
    // Pass-through text fields
    // Facility names carry an NPI-registry check (verified = recognized
    // facility). The badge is display-only — _applyAll strips it before saving,
    // since facilities (unlike meds) are applied straight from this value.
    if (v.preferredFacility != null) {
      _reviewChecked['facility_prefer'] = true;
      _reviewEdited['facility_prefer'] =
          '${v.preferredFacility!}${v.preferredFacilityVerified ? facilityVerifiedBadge : facilityUnverifiedBadge}';
    }
    if (v.avoidFacility != null) {
      _reviewChecked['facility_avoid'] = true;
      _reviewEdited['facility_avoid'] =
          '${v.avoidFacility!}${v.avoidFacilityVerified ? facilityVerifiedBadge : facilityUnverifiedBadge}';
    }
    if (v.dietary != null) {
      _reviewChecked['dietary'] = true;
      _reviewEdited['dietary'] = v.dietary!;
    }
    if (v.religious != null) {
      _reviewChecked['religious'] = true;
      _reviewEdited['religious'] = v.religious!;
    }
    if (v.activities != null) {
      _reviewChecked['activities'] = true;
      _reviewEdited['activities'] = v.activities!;
    }
    if (v.crisisIntervention != null) {
      _reviewChecked['crisis'] = true;
      _reviewEdited['crisis'] = v.crisisIntervention!;
    }
    if (v.petCustody != null) {
      _reviewChecked['pet_custody'] = true;
      _reviewEdited['pet_custody'] = v.petCustody!;
    }
    if (v.childrenCustody != null) {
      _reviewChecked['children_custody'] = true;
      _reviewEdited['children_custody'] = v.childrenCustody!;
    }
    if (v.familyNotification != null) {
      _reviewChecked['family_notification'] = true;
      _reviewEdited['family_notification'] = v.familyNotification!;
    }
    if (v.recordsDisclosure != null) {
      _reviewChecked['records_disclosure'] = true;
      _reviewEdited['records_disclosure'] = v.recordsDisclosure!;
    }
    if (v.other != null) {
      _reviewChecked['other'] = true;
      _reviewEdited['other'] = v.other!;
    }

    // ── Diagnoses — one review key per diagnosis
    for (final d in v.diagnoses) {
      final key = 'diag_${d.name}';
      _reviewChecked[key] = true;
      _reviewEdited[key] = d.display;
    }

    // ── Allergies — one review key per allergy. Drug allergies carry an
    // RxNorm check: verified = recognized medication name; unverified = worth a
    // second look (often a spelling slip). Non-drug allergies show no badge.
    for (final a in v.allergies) {
      final key = 'allergy_${a.substance}';
      _reviewChecked[key] = true;
      final badge = a.kind == 'drug'
          ? (a.rxNormVerified ? ' [RxNorm verified]' : ' [unverified]')
          : '';
      _reviewEdited[key] = '${a.display}$badge';
    }

    // ── Currently-taking medications (reference list) — the one category that
    // also carries a dosage.
    for (final m in v.currentMeds) {
      final key = 'med_current_${m.originalName}';
      _reviewChecked[key] = true;
      final badge = m.isValidated ? ' [RxNorm verified]' : ' [unverified]';
      final dose = m.dosage.isNotEmpty ? ' (${m.dosage})' : '';
      _reviewEdited[key] = '${m.displayName}$dose$badge';
    }

    // ── Medication limitations
    for (final m in v.limitedMeds) {
      final key = 'med_limit_${m.originalName}';
      _reviewChecked[key] = true;
      final badge = m.isValidated ? ' [RxNorm verified]' : ' [unverified]';
      final reason = m.reason.isNotEmpty ? ' — ${m.reason}' : '';
      _reviewEdited[key] = '${m.displayName}$reason$badge';
    }

    // ── Agent authority limitations
    if (v.agentAuthorityLimitations != null) {
      _reviewChecked['agent_authority_limitations'] = true;
      _reviewEdited['agent_authority_limitations'] = v.agentAuthorityLimitations!;
    }

    // ── Consent fields (ECT / experimental / drug trial)
    if (v.ectConsent != null) {
      _reviewChecked['ect_consent'] = true;
      _reviewEdited['ect_consent'] = v.ectConsent!;
    }
    if (v.experimentalConsent != null) {
      _reviewChecked['experimental_consent'] = true;
      _reviewEdited['experimental_consent'] = v.experimentalConsent!;
    }
    if (v.drugTrialConsent != null) {
      _reviewChecked['drug_trial_consent'] = true;
      _reviewEdited['drug_trial_consent'] = v.drugTrialConsent!;
    }
    if (v.medicationConsent != null) {
      _reviewChecked['medication_consent'] = true;
      _reviewEdited['medication_consent'] = v.medicationConsent!;
    }

    // ── Statutory activation triggers (set only on an explicit designation)
    if (v.triggerTwoProfessionals == true) {
      _reviewChecked['trigger_two_professionals'] = true;
      _reviewEdited['trigger_two_professionals'] =
          'Activate when professionals determine I cannot make '
          'mental-health decisions';
    }
    if (v.triggerCourtOrder == true) {
      _reviewChecked['trigger_court_order'] = true;
      _reviewEdited['trigger_court_order'] = 'Activate upon a court order';
    }
    if (v.triggerInvoluntaryCommitment == true) {
      _reviewChecked['trigger_involuntary_commitment'] = true;
      _reviewEdited['trigger_involuntary_commitment'] =
          'Activate upon involuntary commitment';
    }

    // ── Room preferences note
    if (v.roomPreferencesNote != null) {
      _reviewChecked['room_prefs_note'] = true;
      _reviewEdited['room_prefs_note'] = v.roomPreferencesNote!;
    }

    // ── Structured toggles (agent authority / Ulysses / same-gender roommate).
    // Extracted only on an explicit statement; shown here so the user confirms
    // (or unchecks) before they're applied.
    if (v.agentCanConsentHospitalization != null) {
      _reviewChecked['authority_hospitalization'] = true;
      _reviewEdited['authority_hospitalization'] =
          v.agentCanConsentHospitalization!
              ? 'Agent MAY consent to hospitalization'
              : 'Agent may NOT consent to hospitalization';
    }
    if (v.agentCanConsentMedication != null) {
      _reviewChecked['authority_medication'] = true;
      _reviewEdited['authority_medication'] = v.agentCanConsentMedication!
          ? 'Agent MAY decide medications'
          : 'Agent may NOT decide medications';
    }
    if (v.selfBindingUlysses == true) {
      _reviewChecked['ulysses_optin'] = true;
      _reviewEdited['ulysses_optin'] =
          'Self-binding (Ulysses): follow my directive even if I object';
    }
    if (v.sameGenderRoommate == true) {
      final match = switch (v.roommateGenderMatch) {
        'women' => ' (women)',
        'men' => ' (men)',
        'sameAsIdentity' => ' (same as my identity)',
        _ => '',
      };
      _reviewChecked['roommate_same_gender'] = true;
      _reviewEdited['roommate_same_gender'] =
          'Same-gender roommate requested$match';
    }
    // Room-preference chips beyond the same-gender one — a single
    // confirmable row; apply reads the ids from the validated result.
    const chipLabels = {
      'singleRoom': 'Single room',
      'windowIfPossible': 'Window if possible',
      'quietFloor': 'Quiet floor',
    };
    final extraChips = v.roomPreferenceChips
        .where(chipLabels.containsKey)
        .map((c) => chipLabels[c]!)
        .toList();
    if (extraChips.isNotEmpty) {
      _reviewChecked['room_pref_chips'] = true;
      _reviewEdited['room_pref_chips'] = extraChips.join(', ');
    }
    // Guardianship conditions (explicit statements only) — the display is a
    // sentence; apply reads the booleans/notes from the validated result.
    void guardianCondition(String key, bool? value, String? note,
        {required String yes, required String no}) {
      if (value == null) return;
      final suffix = (note != null && note.isNotEmpty) ? ' — $note' : '';
      _reviewChecked[key] = true;
      _reviewEdited[key] = '${value ? yes : no}$suffix';
    }

    guardianCondition('guardian_can_revoke', v.guardianCanRevoke,
        v.guardianCanRevokeNote,
        yes: 'A guardian MAY override this directive',
        no: 'A guardian may NOT override this directive');
    guardianCondition('guardian_can_change_agent', v.guardianCanChangeAgent,
        v.guardianCanChangeAgentNote,
        yes: 'A guardian MAY replace my agent',
        no: 'A guardian may NOT replace my agent');
    guardianCondition(
        'guardian_must_consult_agent', v.guardianMustConsultAgent,
        v.guardianMustConsultAgentNote,
        yes: 'A guardian MUST consult my agent first',
        no: 'A guardian does NOT need to consult my agent');

    // Structured crisis plan — one confirmable row; apply reads the lists
    // from the validated result and merges into crisisPlanJson.
    if (v.crisisPlan != null && !v.crisisPlan!.isEmpty) {
      _reviewChecked['crisis_plan'] = true;
      _reviewEdited['crisis_plan'] = v.crisisPlan!.display();
    }

    // ── Personal info (PII) — autofill the declarant + the people they
    // designate. Address is split into components matching the app's form.
    final pi = v.personalInfo;
    void put(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        _reviewChecked[key] = true;
        _reviewEdited[key] = value.trim();
      }
    }

    put('person_name', pi.fullName);
    put('person_dob', pi.dateOfBirth);
    put('person_address1', pi.addressLine1);
    put('person_address2', pi.addressLine2);
    put('person_city', pi.city);
    put('person_county', pi.county);
    put('person_state', pi.state);
    put('person_zip', pi.zip);
    put('person_phone', pi.phone);
    put('person_doctor_name', pi.primaryDoctorName);
    put('person_doctor_specialty', pi.primaryDoctorSpecialty);
    put('person_doctor_phone', pi.primaryDoctorPhone);
    put('person_eval_doctor_name', pi.preferredEvaluatingDoctorName);
    put('person_eval_doctor_contact', pi.preferredEvaluatingDoctorContact);
    final ag = pi.agent;
    if (ag != null) {
      put('agent_name', ag.name);
      put('agent_relationship', ag.relationship);
      put('agent_address1', ag.addressLine1);
      put('agent_address2', ag.addressLine2);
      put('agent_city', ag.city);
      put('agent_state', ag.state);
      put('agent_zip', ag.zip);
      put('agent_phone', ag.phone);
    }
    final alt = pi.alternateAgent;
    if (alt != null) {
      put('alt_agent_name', alt.name);
      put('alt_agent_relationship', alt.relationship);
      put('alt_agent_address1', alt.addressLine1);
      put('alt_agent_address2', alt.addressLine2);
      put('alt_agent_city', alt.city);
      put('alt_agent_state', alt.state);
      put('alt_agent_zip', alt.zip);
      put('alt_agent_phone', alt.phone);
    }
    final gd = pi.guardian;
    if (gd != null) {
      put('guardian_name', gd.name);
      put('guardian_relationship', gd.relationship);
      put('guardian_address1', gd.addressLine1);
      put('guardian_address2', gd.addressLine2);
      put('guardian_city', gd.city);
      put('guardian_state', gd.state);
      put('guardian_zip', gd.zip);
      put('guardian_phone', gd.phone);
    }
  }

  /// Fill in any city / state / county that the AI didn't read off the document
  /// but which can be derived from an extracted ZIP — for the declarant AND the
  /// designated people (agent, alternate, guardian). Uses the keyless geo APIs
  /// (Zippopotam + FCC) already used by the form's address fields; only the ZIP
  /// (never a street address) leaves the browser, so it stays within the PII
  /// posture. Best-effort: any miss/timeout simply leaves the field as-is. The
  /// values are written into the review map so the user still confirms them.
  Future<void> _geoBackfillReview() async {
    // (prefix, hasCounty). Only the declarant card has a county field.
    const targets = [
      ('person', true),
      ('agent', false),
      ('alt_agent', false),
      ('guardian', false),
    ];
    final zip5 = RegExp(r'^\d{5}$');
    final geo = GeoService();
    final filled = <String, String>{};
    try {
      for (final (prefix, hasCounty) in targets) {
        final zip = (_reviewEdited['${prefix}_zip'] ?? '').trim();
        if (!zip5.hasMatch(zip)) continue;
        final cityKey = '${prefix}_city';
        final stateKey = '${prefix}_state';
        final countyKey = '${prefix}_county';
        final needCity = (_reviewEdited[cityKey] ?? '').trim().isEmpty;
        final needState = (_reviewEdited[stateKey] ?? '').trim().isEmpty;
        final needCounty =
            hasCounty && (_reviewEdited[countyKey] ?? '').trim().isEmpty;
        if (!needCity && !needState && !needCounty) continue;

        final lookup = await geo.lookupZip(zip);
        if (lookup == null) continue;
        if (needCity && lookup.city.isNotEmpty) filled[cityKey] = lookup.city;
        if (needState && lookup.stateAbbr.isNotEmpty) {
          filled[stateKey] = lookup.stateAbbr;
        }
        if (needCounty && lookup.lat != null && lookup.lng != null) {
          final county = await geo.countyForLatLng(lookup.lat!, lookup.lng!);
          if (county != null && county.isNotEmpty) filled[countyKey] = county;
        }
      }
    } finally {
      geo.dispose();
    }
    if (filled.isEmpty || !mounted) return;
    setState(() {
      filled.forEach((key, value) {
        _reviewEdited[key] = value;
        _reviewChecked[key] = true;
      });
    });
  }

  /// After extraction, classify each field by priority and detect conflicts
  /// against the directive's CURRENT scalar values. Low-priority items stay
  /// pre-selected (autofilled silently); conflicting scalars start UNSELECTED
  /// so the user makes a deliberate keep/replace choice, with the more-complete
  /// value pre-filled as the suggested default.
  Future<void> _buildReconciliation() async {
    final repo = ref.read(directiveRepositoryProvider);
    final id = widget.directiveId;
    final prefs = await repo.getPreferences(id);
    final instr = await repo.getAdditionalInstructions(id);
    // Personal-info current values, so an autofilled name/address/phone that
    // would REPLACE something the user already typed starts unchecked (a
    // deliberate keep/replace choice) instead of silently overwriting.
    final directive = await repo.getDirectiveById(id);
    final agents = await repo.getAgents(id);
    final primaryAgents =
        agents.where((a) => a.agentType == 'primary').toList();
    final primaryAgent = primaryAgents.isEmpty ? null : primaryAgents.first;
    final altAgents =
        agents.where((a) => a.agentType == 'alternate').toList();
    final altAgent = altAgents.isEmpty ? null : altAgents.first;
    final guardian = await repo.getGuardianNomination(id);
    final existing = <String, String>{
      'facility_prefer': prefs?.preferredFacilityName ?? '',
      'facility_avoid': prefs?.avoidFacilityName ?? '',
      'dietary': instr?.dietary ?? '',
      'religious': instr?.religious ?? '',
      'activities': instr?.activities ?? '',
      'crisis': instr?.crisisIntervention ?? '',
      'agent_authority_limitations': prefs?.agentAuthorityLimitations ?? '',
      'pet_custody': instr?.petCustody ?? '',
      'children_custody': instr?.childrenCustody ?? '',
      'family_notification': instr?.familyNotification ?? '',
      'records_disclosure': instr?.recordsDisclosure ?? '',
      'other': instr?.other ?? '',
      'hh_note': instr?.healthHistory ?? '',
      // Declarant — split address fields
      'person_name': directive?.fullName ?? '',
      'person_dob': directive?.dateOfBirth ?? '',
      'person_address1': directive?.address ?? '',
      'person_address2': directive?.address2 ?? '',
      'person_city': directive?.city ?? '',
      'person_county': directive?.county ?? '',
      'person_state': directive?.state ?? '',
      'person_zip': directive?.zip ?? '',
      'person_phone': directive?.phone ?? '',
      'person_doctor_name': directive?.primaryDoctorName ?? '',
      'person_doctor_phone': directive?.primaryDoctorPhone ?? '',
      'person_eval_doctor_name': directive?.preferredDoctorName ?? '',
      'person_eval_doctor_contact': directive?.preferredDoctorContact ?? '',
      // Primary agent — split address
      'agent_name': primaryAgent?.fullName ?? '',
      'agent_relationship': primaryAgent?.relationship ?? '',
      'agent_address1': primaryAgent?.address ?? '',
      'agent_address2': primaryAgent?.address2 ?? '',
      'agent_city': primaryAgent?.city ?? '',
      'agent_state': primaryAgent?.state ?? '',
      'agent_zip': primaryAgent?.zip ?? '',
      // cellPhone, not homePhone: the wizard and applyAgent both store the
      // single phone in cellPhone, so conflict detection must read the same
      // column (else an existing phone is never flagged before overwrite).
      'agent_phone': primaryAgent?.cellPhone ?? '',
      // Alternate agent — split address
      'alt_agent_name': altAgent?.fullName ?? '',
      'alt_agent_relationship': altAgent?.relationship ?? '',
      'alt_agent_address1': altAgent?.address ?? '',
      'alt_agent_address2': altAgent?.address2 ?? '',
      'alt_agent_city': altAgent?.city ?? '',
      'alt_agent_state': altAgent?.state ?? '',
      'alt_agent_zip': altAgent?.zip ?? '',
      'alt_agent_phone': altAgent?.cellPhone ?? '',
      // Guardian — split address
      'guardian_name': guardian?.nomineeFullName ?? '',
      'guardian_relationship': guardian?.nomineeRelationship ?? '',
      'guardian_address1': guardian?.nomineeAddress ?? '',
      'guardian_address2': guardian?.nomineeAddress2 ?? '',
      'guardian_city': guardian?.nomineeCity ?? '',
      'guardian_state': guardian?.nomineeState ?? '',
      'guardian_zip': guardian?.nomineeZip ?? '',
      'guardian_phone': guardian?.nomineePhone ?? '',
    };
    _reconItems = buildReconItems(
      extracted: Map<String, String>.of(_reviewEdited),
      existing: existing,
    );
    for (final it in _reconItems) {
      _reviewChecked[it.key] = it.selected;
      // Pre-fill the conflict default (the more-complete value); editable.
      if (it.isConflict) _reviewEdited[it.key] = it.suggestedValue;
    }
  }

  String _displayLabel(String key) {
    if (key.startsWith('med_prefer_')) return 'Preferred Medication';
    if (key.startsWith('med_avoid_')) return 'Medication to Avoid';
    if (key.startsWith('med_current_')) return 'Currently Taking';
    if (key.startsWith('med_limit_')) return 'Restricted-Use Medication';
    if (key.startsWith('cond_')) return 'Condition';
    if (key.startsWith('diag_')) return 'Diagnosis';
    if (key.startsWith('allergy_')) return 'Allergy';
    if (key.startsWith('hh_')) return 'Health History';
    if (key == 'effective_condition') return 'When this kicks in (your words)';
    if (key == 'facility_prefer') return 'Preferred Facility';
    if (key == 'facility_avoid') return 'Facility to Avoid';
    if (key == 'dietary') return 'Dietary';
    if (key == 'religious') return 'Religious/Cultural';
    if (key == 'activities') return 'Activities';
    if (key == 'crisis') return 'Crisis Intervention';
    if (key == 'crisis_plan') return 'Crisis plan';
    if (key == 'agent_authority_limitations') return 'Agent authority limits';
    if (key == 'ect_consent') return 'ECT consent';
    if (key == 'experimental_consent') return 'Experimental treatment consent';
    if (key == 'drug_trial_consent') return 'Drug trial consent';
    if (key == 'medication_consent') return 'Medication consent';
    if (key == 'trigger_two_professionals') return 'Trigger: professionals';
    if (key == 'trigger_court_order') return 'Trigger: court order';
    if (key == 'trigger_involuntary_commitment') {
      return 'Trigger: involuntary commitment';
    }
    if (key == 'room_prefs_note') return 'Room preferences';
    if (key == 'room_pref_chips') return 'Room options';
    if (key == 'roommate_same_gender') return 'Same-gender roommate';
    if (key == 'guardian_can_revoke') return 'Guardian: override';
    if (key == 'guardian_can_change_agent') return 'Guardian: replace agent';
    if (key == 'guardian_must_consult_agent') return 'Guardian: consult agent';
    if (key == 'authority_hospitalization') return 'Agent: hospitalization';
    if (key == 'authority_medication') return 'Agent: medications';
    if (key == 'ulysses_optin') return 'Self-binding (Ulysses)';
    if (key == 'pet_custody') return 'Pet care';
    if (key == 'children_custody') return 'Children / dependents';
    if (key == 'family_notification') return 'Who to notify';
    if (key == 'records_disclosure') return 'Records disclosure';
    if (key == 'other') return 'Other';
    // Personal info (PII) — declarant
    if (key == 'person_name') return 'Your full name';
    if (key == 'person_dob') return 'Date of birth';
    if (key == 'person_address1') return 'Street address';
    if (key == 'person_address2') return 'Apt / suite / unit';
    if (key == 'person_city') return 'City';
    if (key == 'person_county') return 'County';
    if (key == 'person_state') return 'State';
    if (key == 'person_zip') return 'ZIP code';
    if (key == 'person_phone') return 'Your phone';
    if (key == 'person_doctor_name') return 'Primary doctor';
    if (key == 'person_doctor_specialty') return 'Doctor specialty';
    if (key == 'person_doctor_phone') return "Doctor's phone";
    if (key == 'person_eval_doctor_name') return 'Preferred evaluating doctor';
    if (key == 'person_eval_doctor_contact') return 'Evaluating doctor contact';
    // Primary agent
    if (key == 'agent_name') return 'Agent name';
    if (key == 'agent_relationship') return 'Agent relationship';
    if (key == 'agent_address1') return 'Agent street address';
    if (key == 'agent_address2') return 'Agent apt / suite';
    if (key == 'agent_city') return 'Agent city';
    if (key == 'agent_state') return 'Agent state';
    if (key == 'agent_zip') return 'Agent ZIP';
    if (key == 'agent_phone') return 'Agent phone';
    // Alternate agent
    if (key == 'alt_agent_name') return 'Alternate agent name';
    if (key == 'alt_agent_relationship') return 'Alternate agent relationship';
    if (key == 'alt_agent_address1') return 'Alt agent street address';
    if (key == 'alt_agent_address2') return 'Alt agent apt / suite';
    if (key == 'alt_agent_city') return 'Alt agent city';
    if (key == 'alt_agent_state') return 'Alt agent state';
    if (key == 'alt_agent_zip') return 'Alt agent ZIP';
    if (key == 'alt_agent_phone') return 'Alternate agent phone';
    // Guardian
    if (key == 'guardian_name') return 'Guardian nominee';
    if (key == 'guardian_relationship') return 'Guardian relationship';
    if (key == 'guardian_address1') return 'Guardian street address';
    if (key == 'guardian_address2') return 'Guardian apt / suite';
    if (key == 'guardian_city') return 'Guardian city';
    if (key == 'guardian_state') return 'Guardian state';
    if (key == 'guardian_zip') return 'Guardian ZIP';
    if (key == 'guardian_phone') return 'Guardian phone';
    return key;
  }

  String _sectionLabel(String key) {
    if (key.startsWith('med_prefer_')) return 'Preferred Meds';
    if (key.startsWith('med_avoid_')) return 'Meds to Avoid';
    if (key.startsWith('med_current_')) return 'Currently Taking';
    if (key.startsWith('med_limit_')) return 'Restricted-Use Meds';
    if (key.startsWith('cond_')) return 'Conditions';
    if (key.startsWith('diag_')) return 'Diagnoses';
    if (key.startsWith('allergy_')) return 'Allergies';
    if (key.startsWith('hh_')) return 'Health History';
    if (key == 'effective_condition') return 'When this kicks in';
    if (key.startsWith('person_')) return 'Your details';
    if (key.startsWith('agent_') && !key.startsWith('agent_authority')) {
      return 'Your agent';
    }
    if (key == 'agent_authority_limitations' ||
        key == 'authority_hospitalization' ||
        key == 'authority_medication') {
      return 'Agent Authority';
    }
    if (key == 'ulysses_optin') return 'Self-binding';
    if (key == 'crisis_plan') return 'Crisis Plan';
    if (key == 'ect_consent' ||
        key == 'experimental_consent' ||
        key == 'drug_trial_consent' ||
        key == 'medication_consent') {
      return 'Consent';
    }
    if (key.startsWith('trigger_')) return 'When this kicks in';
    if (key == 'room_prefs_note' ||
        key == 'room_pref_chips' ||
        key == 'roommate_same_gender') {
      return 'Room Preferences';
    }
    if (key.startsWith('alt_agent_')) return 'Alternate agent';
    if (key.startsWith('guardian_')) return 'Guardian';
    return 'Other';
  }

  /// Maps a review key to the wizard STEP it belongs to, as (order, title), so
  /// the review can group results into the same sections the user will see in
  /// the wizard instead of one long list. Order mirrors the wizard step order.
  (int, String) _wizardSection(String key) {
    if (key.startsWith('person_eval_doctor')) return (2, 'When this kicks in');
    if (key == 'effective_condition') return (2, 'When this kicks in');
    if (key.startsWith('trigger_')) return (2, 'When this kicks in');
    if (key.startsWith('person_doctor')) return (6, 'Diagnoses');
    if (key.startsWith('person_')) return (1, 'About you');
    if (key == 'authority_hospitalization' ||
        key == 'authority_medication' ||
        key == 'agent_authority_limitations' ||
        key.startsWith('alt_agent_') ||
        (key.startsWith('agent_') && !key.startsWith('agent_authority'))) {
      return (3, 'People I trust');
    }
    if (key.startsWith('guardian_')) return (4, 'If a court appoints a guardian');
    if (key == 'facility_prefer' ||
        key == 'facility_avoid' ||
        key == 'room_prefs_note' ||
        key == 'room_pref_chips' ||
        key == 'roommate_same_gender') {
      return (5, 'Where I want care');
    }
    if (key.startsWith('diag_') || key.startsWith('cond_')) {
      return (6, 'Diagnoses');
    }
    if (key.startsWith('med_')) return (7, 'Medications');
    if (key.startsWith('allergy_')) return (8, 'Allergies & reactions');
    if (key == 'ect_consent' ||
        key == 'experimental_consent' ||
        key == 'drug_trial_consent' ||
        key == 'medication_consent' ||
        key == 'ulysses_optin') {
      return (9, 'Procedures & research');
    }
    return (10, 'Anything else');
  }

  Widget _buildReviewStep() {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final keys = _reviewEdited.keys.toList();
    final checkedCount =
        _reviewChecked.values.where((v) => v).length;

    final okText = dark
        ? SemanticColors.successTextDark
        : SemanticColors.successTextLight;

    // Editorial header (full width) — mono AI pill, italic serif headline,
    // muted body. Below it the artboard forks into a 1fr / 1.4fr two-pane on
    // wide (photo left, fields right); narrow stacks them.
    final header = <Widget>[
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: p.primaryTint,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 11, color: p.primary),
                const SizedBox(width: 5),
                Text(
                  'AI READ THIS PHOTO',
                  style: TextStyle(
                    fontFamily: kMonoFamily,
                    fontFamilyFallback: const [
                      'Consolas',
                      'Menlo',
                      'Courier New',
                      'monospace',
                    ],
                    fontSize: 10.5,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                    color: p.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        "Here's what we read.",
        style: TextStyle(
          fontFamily: 'Instrument Serif',
          fontFamilyFallback: const ['Georgia', 'serif'],
          fontStyle: FontStyle.italic,
          fontSize: 32,
          fontWeight: FontWeight.w400,
          height: 1.05,
          letterSpacing: -0.4,
          color: p.text,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'These are the details the AI pulled from your document. Here\'s how '
        'to use this page:',
        style: TextStyle(
          fontFamily: kSansFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: p.text,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 6),
      _howToLine(p, Icons.check_box_outlined,
          'A checked box means it will be added to your form. Uncheck '
          'anything you don\'t want.'),
      _howToLine(p, Icons.edit_outlined,
          'Tap any field to edit its wording before it\'s added.'),
      _howToLine(p, Icons.rule,
          'Results are grouped by form section (the same steps you\'ll see '
          'next). A "Replaces what you have" note means it would overwrite '
          'something you already entered — those start unchecked.'),
      _howToLine(p, Icons.arrow_forward,
          'When you\'re ready, tap "Autofill Information" at the bottom to '
          'fill these into your form and continue — you\'ll land in the form '
          'to review everything.'),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final twoPane = c.maxWidth >= 720 && _sourceDocs.isNotEmpty;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            ...header,
            const SizedBox(height: 18),
            if (twoPane)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 10, child: _sourceThumb(p)),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 14,
                    child: _reviewFieldsPane(p, keys, checkedCount, okText),
                  ),
                ],
              )
            else ...[
              if (_sourceDocs.isNotEmpty) ...[
                _sourceThumb(p),
                const SizedBox(height: 16),
              ],
              _reviewFieldsPane(p, keys, checkedCount, okText),
            ],
          ],
        );
      },
    );
  }

  // The extracted-fields column of the review screen (right pane on wide):
  // PII notice → "Add to your directive" label → field rows → privacy lock
  // line → ready-count → NLM attribution.
  Widget _reviewFieldsPane(
    MhadPalette p,
    List<String> keys,
    int checkedCount,
    Color okText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_piiStripped.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: p.primaryTint,
              border: Border.all(color: p.primary.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, size: 14, color: p.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PII was detected and removed before analysis: '
                    '${_piiStripped.toSet().join(", ")}',
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 11.5,
                      height: 1.4,
                      color: p.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'Add to your directive',
          style: TextStyle(
            fontFamily: kMonoFamily,
            fontFamilyFallback: const [
              'Consolas',
              'Menlo',
              'Courier New',
              'monospace',
            ],
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: p.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        _buildReconGroups(p, keys),
        const SizedBox(height: 14),
        // Privacy reassurance lock-line — matches prototype L2082-2087.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline, size: 14, color: p.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your photo was sent to the AI to read, then '
                  'discarded. Nothing is stored after you confirm or '
                  'discard.',
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 11.5,
                    color: p.textMuted,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$checkedCount of ${keys.length} fields ready to add',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kMonoFamily,
            fontFamilyFallback: const [
              'Consolas',
              'Menlo',
              'Courier New',
              'monospace',
            ],
            fontSize: 10.5,
            letterSpacing: 0.6,
            color: checkedCount > 0 ? okText : p.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        const NlmAttribution(),
      ],
    );
  }

  /// The extracted fields, grouped into the SAME sections the user will see in
  /// the wizard (About you, People I trust, Medications, …) and shown in wizard
  /// order — instead of one long list. A field that would replace an existing
  /// value still shows a "Replaces what you have" note and starts unchecked.
  Widget _buildReconGroups(MhadPalette p, List<String> keys) {
    // Conflict / reconciliation detail per key (for the "replaces" note).
    final reconByKey = {for (final r in _reconItems) r.key: r};

    // Bucket keys by wizard step, preserving each step's title and order.
    final bySection = <int, List<String>>{};
    final titles = <int, String>{};
    for (final k in keys) {
      final (order, title) = _wizardSection(k);
      bySection.putIfAbsent(order, () => <String>[]).add(k);
      titles[order] = title;
    }
    final orders = bySection.keys.toList()..sort();

    Widget rowFor(String key) {
      final recon = reconByKey[key];
      if (recon != null) return _reconRow(recon, p);
      // No reconciliation entry (e.g. a non-scalar list item) — plain row.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SnapReviewRow(
            ok: _reviewChecked[key] ?? false,
            fieldLabel: _displayLabel(key),
            value: _reviewEdited[key] ?? '',
            target: _sectionLabel(key),
            onToggle: () => setState(
                () => _reviewChecked[key] = !(_reviewChecked[key] ?? false)),
            onEdit: () => _editField(key),
          ),
          _agentInitialsNote(key, p),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final o in orders) ...[
          _groupLabel(titles[o]!, p),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: p.card,
              border: Border.all(color: p.border),
              borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
            ),
            child: Column(
              children: [
                for (var i = 0; i < bySection[o]!.length; i++) ...[
                  rowFor(bySection[o]![i]),
                  if (i < bySection[o]!.length - 1)
                    Divider(height: 1, color: p.border),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _reconRow(ReconItem it, MhadPalette p) {
    // A field that already holds a value → let the user decide what to do with
    // the existing vs. the autofilled value, instead of a silent overwrite.
    if (it.isConflict) return _conflictResolver(it, p);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SnapReviewRow(
          ok: _reviewChecked[it.key] ?? false,
          fieldLabel: _displayLabel(it.key),
          value: _reviewEdited[it.key] ?? '',
          target: _sectionLabel(it.key),
          onToggle: () => setState(() =>
              _reviewChecked[it.key] = !(_reviewChecked[it.key] ?? false)),
          onEdit: () => _editField(it.key),
        ),
        _agentInitialsNote(it.key, p),
      ],
    );
  }

  /// Conflict resolver for a field that's already filled: shows the existing
  /// value vs. the autofilled one and lets the user Keep mine / Use new / Add
  /// both. (Consolidate — an AI merge — is the planned next step.) The choice
  /// just sets the apply maps the rest of the pipeline already consumes.
  Widget _conflictResolver(ReconItem it, MhadPalette p) {
    final existing = it.existing!.trim();
    final extracted = it.extracted.trim();
    final addValue = '$existing\n$extracted';
    final checked = _reviewChecked[it.key] ?? false;
    final edited = (_reviewEdited[it.key] ?? '').trim();
    final action = !checked
        ? 'keep'
        : edited == extracted
            ? 'replace'
            : edited == addValue
                ? 'add'
                : 'consolidate';
    // Identity/PII fields are NEVER AI-merged — they keep the deterministic
    // options + a manual-check nudge, so the app's PII rules stay intact.
    final isIdentity = _isIdentityKey(it.key);
    final busy = _consolidating[it.key] == true;

    Widget valLine(String tag, String value) => Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                text: '$tag: ',
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: p.textMuted,
                ),
              ),
              TextSpan(
                text: value,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 12.5,
                  color: p.text,
                ),
              ),
            ]),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _displayLabel(it.key),
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: p.text,
            ),
          ),
          valLine('You entered', existing),
          valLine('Autofill found', extracted),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _conflictChip(p, 'Keep mine', action == 'keep',
                  () => setState(() => _reviewChecked[it.key] = false)),
              _conflictChip(p, 'Use new', action == 'replace', () {
                setState(() {
                  _reviewChecked[it.key] = true;
                  _reviewEdited[it.key] = extracted;
                });
              }),
              _conflictChip(p, 'Add both', action == 'add', () {
                setState(() {
                  _reviewChecked[it.key] = true;
                  _reviewEdited[it.key] = addValue;
                });
              }),
              if (!isIdentity)
                busy
                    ? const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _conflictChip(p, 'Consolidate (AI)',
                        action == 'consolidate', () => _consolidateField(it)),
            ],
          ),
          if (isIdentity)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Identity fields aren\'t merged by the AI — double-check this '
                'one yourself.',
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  color: p.textMuted,
                ),
              ),
            ),
          if (checked && action != 'keep') ...[
            const SizedBox(height: 8),
            Text(
              'Will save:',
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: p.textMuted,
              ),
            ),
            Text(
              _reviewEdited[it.key] ?? '',
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 12.5,
                color: p.text,
                height: 1.4,
              ),
            ),
          ],
          _agentInitialsNote(it.key, p),
        ],
      ),
    );
  }

  Widget _conflictChip(
          MhadPalette p, String label, bool selected, VoidCallback onTap) =>
      ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
      );

  /// Identity / PII review keys (declarant + agent / alternate / guardian
  /// name·DOB·address·phone·doctor). These are never sent to the AI to merge —
  /// only free-text fields get the Consolidate option.
  bool _isIdentityKey(String key) =>
      key.startsWith('person_') ||
      key.startsWith('alt_agent_') ||
      key.startsWith('guardian_') ||
      (key.startsWith('agent_') && key != 'agent_authority_limitations');

  /// "Consolidate" — ask the AI to merge the existing + extracted value of a
  /// (non-identity) free-text field into one value. Sets the apply maps on
  /// success; fail-safe keeps the extracted value.
  Future<void> _consolidateField(ReconItem it) async {
    final aiCfg = ref.read(aiConfigProvider);
    if (aiCfg == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Set up the AI assistant first to consolidate.'),
      ));
      return;
    }
    setState(() => _consolidating[it.key] = true);
    final extractor = DocumentExtractor(
      apiKey: aiCfg.key,
      provider: aiCfg.provider,
      model: aiCfg.model,
    );
    final String merged;
    try {
      merged = await extractor.consolidate(
        fieldLabel: _displayLabel(it.key),
        existing: it.existing!.trim(),
        extracted: it.extracted.trim(),
      );
    } finally {
      extractor.dispose();
    }
    if (!mounted) return;
    setState(() {
      _consolidating[it.key] = false;
      _reviewChecked[it.key] = true;
      _reviewEdited[it.key] = merged;
    });
  }

  /// §5836(c) reminder: when an autofilled consent would delegate ECT,
  /// experimental studies, or drug trials to the agent, that delegation only
  /// takes legal effect if the declarant physically initials it on the printed
  /// form. Surfaced here so the user confirms the AI's assumption deliberately.
  Widget _agentInitialsNote(String key, MhadPalette p) {
    const procedureKeys = {
      'ect_consent',
      'experimental_consent',
      'drug_trial_consent',
    };
    if (!procedureKeys.contains(key)) return const SizedBox.shrink();
    if ((_reviewEdited[key] ?? '') != 'agent') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.draw_outlined, size: 14, color: p.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'This lets your agent decide. Under PA law (§5836(c)) it only '
              'takes effect if you physically initial this authorization on the '
              'printed form — confirm this is what you want.',
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 11.5,
                height: 1.4,
                color: p.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupLabel(String text, MhadPalette p) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: kMonoFamily,
          fontFamilyFallback: const [
            'Consolas',
            'Menlo',
            'Courier New',
            'monospace',
          ],
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: p.textMuted,
        ),
      );

  // ── Smart Fill results ──────────────────────────────────────────────

  Widget _buildResultsStep() {
    final cs = Theme.of(context).colorScheme;
    final keys = _smartEdited.keys.toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cs.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'The AI generated these additional suggestions based on your '
            'validated conditions and medications. Tap to edit, uncheck '
            'to skip. This is not medical or legal advice.',
            style: TextStyle(
                fontSize: 12,
                color: cs.onTertiaryContainer,
                fontStyle: FontStyle.italic),
          ),
        ),
        ...keys.map((key) {
          // The three procedure fields are neutral drafting guidance ("help
          // the user state their OWN preference") — they are shown to read,
          // never saved: AI meta-guidance must not print into the legal form.
          // The user sets the actual choice in Procedures & research.
          final guidanceOnly = _smartGuidanceOnlyKeys.contains(key);
          final checked = !guidanceOnly && (_smartChecked[key] ?? false);
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            color: checked
                ? cs.surfaceContainerLow
                : cs.surfaceContainerHighest.withValues(alpha: 0.5),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: guidanceOnly ? null : () => _editSmartField(key),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (guidanceOnly)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(Icons.menu_book_outlined,
                            size: 20, color: cs.onSurfaceVariant),
                      )
                    else
                      Checkbox(
                        value: checked,
                        onChanged: (v) =>
                            setState(() => _smartChecked[key] = v ?? false),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(key,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: checked
                                          ? cs.onSurface
                                          : cs.onSurfaceVariant)),
                            if (guidanceOnly) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Guidance to read — not saved to your form. '
                                'Set your choice in Procedures & research.',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                        color: cs.tertiary,
                                        fontStyle: FontStyle.italic),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              _smartEdited[key] ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: checked
                                        ? cs.onSurface
                                        : cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(Icons.edit, size: 14, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Bottom bar ──────────────────────────────────────────────────────

  Widget? _buildBottom() {
    if (_step == _PipelineStep.pick ||
        _step == _PipelineStep.extracting ||
        _step == _PipelineStep.validating ||
        _step == _PipelineStep.generating) {
      return null;
    }

    // Artboard WebSnapReview footer: "Discard all" (left) · "Generate more"
    // (Smart Fill, when conditions/meds were validated) · primary button.
    // Results step keeps Back · Apply All.
    final canSmartFill = _validated?.hasValidatedConditions == true ||
        _validated?.hasValidatedMeds == true;
    // The primary review button is "Autofill Information" in BOTH modes — it
    // applies the checked fields and continues into the wizard (standalone
    // navigates there; the modal pops back to the wizard it was opened over),
    // so the user can verify the autofill. The "N of M fields ready to add"
    // line in the fields pane already communicates the count.
    const addLabel = 'Autofill Information';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        // The primary action is a FULL-WIDTH button on its own line so it can
        // never be clipped off the right edge by a too-narrow footer (the old
        // single-Row layout with a Spacer overflowed and hid this button when
        // "Generate more" was also present or the window was narrow).
        child: _step == _PipelineStep.results
            ? Row(
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        setState(() => _step = _PipelineStep.review),
                    child: const Text('Back'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _applyAll,
                    icon: const Icon(Icons.check),
                    label: const Text('Apply All'),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Secondary actions row.
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _discardExtraction,
                        child: const Text('Discard all'),
                      ),
                      const Spacer(),
                      if (canSmartFill)
                        TextButton.icon(
                          onPressed: _runSmartFill,
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: const Text('Generate more'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Primary: always enabled, full width — applies the checked
                  // fields and continues into the wizard to verify.
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _applyAll,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: Text(addLabel,
                                overflow: TextOverflow.ellipsis),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Editorial extraction-review row matching prototype `ScrSnapReview`
/// L2030-2067. Replaces the prior Material Card + Checkbox row.
///
/// Layout: 22pt rounded checkbox (filled primary when ok, surface with
/// border + X when unchecked) → flex column with monospace UPPERCASE
/// field name + right-aligned "→ Step N · Section" target chip → value
/// in 14pt bold (line-through when unchecked) → 11.5pt muted subtitle
/// → trailing edit pencil icon.
class _SnapReviewRow extends StatelessWidget {
  final bool ok;
  final String fieldLabel;
  final String value;
  final String target;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _SnapReviewRow({
    required this.ok,
    required this.fieldLabel,
    required this.value,
    required this.target,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: ok ? p.primary : p.surface,
                border: ok
                    ? null
                    : Border.all(color: p.border, width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: ok
                  ? Icon(Icons.check, size: 13, color: p.onPrimary)
                  : Icon(Icons.close, size: 11, color: p.textMuted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        fieldLabel.toUpperCase(),
                        style: TextStyle(
                          fontFamily: kMonoFamily,
                          fontFamilyFallback: const [
                            'Consolas',
                            'Menlo',
                            'Courier New',
                            'monospace',
                          ],
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: p.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ok ? '→ $target' : 'Not added',
                      style: TextStyle(
                        fontFamily: kMonoFamily,
                        fontFamilyFallback: const [
                          'Consolas',
                          'Menlo',
                          'Courier New',
                          'monospace',
                        ],
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: ok ? p.primary : p.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ok ? p.text : p.textMuted,
                    decoration:
                        ok ? null : TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.edit_outlined,
                  size: 14, color: p.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
