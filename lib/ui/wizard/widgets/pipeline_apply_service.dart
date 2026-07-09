part of 'document_pipeline_flow.dart';

// Smart Fill generation and the apply-to-database logic for the document
// pipeline. Split out of document_pipeline_flow.dart as an extension on the
// pipeline State so it keeps direct access to the State's private fields with
// no behavioral change.
//
// ignore_for_file: invalid_use_of_protected_member
// (extension methods on the State legitimately call its protected setState)

extension _PipelineApplyLogic on _PipelineScreenState {
  // ── Smart Fill generation ───────────────────────────────────────────

  Future<void> _runSmartFill() async {
    final aiCfg = ref.read(aiConfigProvider);
    if (aiCfg == null || _validated == null) return;

    setState(() {
      _step = _PipelineStep.generating;
      _statusMessage = 'AI is generating personalized suggestions...';
    });

    SmartFillService? service;
    try {
      service = SmartFillService(
        apiKey: aiCfg.key,
        provider: aiCfg.provider,
        model: aiCfg.model,
      );
      final response = await service.generate(SmartFillInput(
        conditions: _validated!.icdConditions,
        currentMedications: _validated!.validatedPreferredMedNames,
        medicationsToAvoid: _validated!.validatedAvoidMedNames,
        formType: widget.formType,
      ));

      final result = response.result;
      ref.read(geminiRateTrackerProvider).recordRequest(
          estimatedTokens: response.totalTokens);

      if (!mounted) return;

      if (result.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI could not generate additional suggestions.')),
        );
        // Fall through to apply just the extracted data
        await _applyAll();
        return;
      }

      final display = result.toDisplayMap();
      _smartResult = result;
      _smartChecked = {for (final k in display.keys) k: true};
      _smartEdited = Map<String, String>.from(display);

      setState(() => _step = _PipelineStep.results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Autofill hit a problem. ${FriendlyError.from(e)}')),
        );
        // Still apply extracted data
        await _applyAll();
      }
    } finally {
      service?.dispose();
    }
  }

  // ── Apply everything ────────────────────────────────────────────────

  /// A facility's review value with the display-only NPI badge removed, so the
  /// badge text never gets saved into the facility name.
  String _facilityValue(String key) {
    var v = (_reviewEdited[key] ?? '').trim();
    for (final badge in const [facilityVerifiedBadge, facilityUnverifiedBadge]) {
      if (v.endsWith(badge)) {
        v = v.substring(0, v.length - badge.length).trim();
        break;
      }
    }
    return v;
  }

  Future<void> _applyAll() async {
    final repo = ref.read(directiveRepositoryProvider);
    final id = widget.directiveId;

    // ── Apply extracted + validated data ─────────────────────────────
    final existingMeds = await repo.watchMedications(id).first;
    int medOrder = existingMeds.length;
    // Count only what's actually written so the "N fields added" message is
    // honest (skips duplicates and already-set fields).
    var applied = 0;

    // Dedup: compare full name (including dosage/form) AND entry type.
    // "Sertraline 50 MG" and "Sertraline 100 MG" are different entries.
    // Same drug in "preferred" and "avoid" are both allowed (different intent).
    bool medExists(String name, String entryType) {
      return existingMeds.any((m) =>
          m.medicationName.toLowerCase() == name.toLowerCase() &&
          m.entryType == entryType);
    }

    // A medication row's review value is the display composite
    // ('name — reason [badge]'; current meds: 'name (dosage) [badge]').
    // Honor the user's review-screen edits by parsing the composite back —
    // previously apply re-read the validated objects and silently discarded
    // any edit. When the (badge-stripped) value matches the original
    // composite, the validated values are used verbatim (no parse risk for
    // names that themselves contain parentheses or dashes).
    ({String name, String reason, String dosage}) medFromReview(
      String key, {
      required String name,
      String reason = '',
      String dosage = '',
      bool isCurrent = false,
    }) {
      var v = (_reviewEdited[key] ?? '').trim();
      for (final badge in const [' [RxNorm verified]', ' [unverified]']) {
        if (v.endsWith(badge)) {
          v = v.substring(0, v.length - badge.length).trimRight();
          break;
        }
      }
      // The composite as originally displayed: current meds show
      // 'name (dosage)' (their reason is never displayed, so it is always
      // preserved); the preference categories show 'name — reason'.
      final original = isCurrent
          ? (dosage.isNotEmpty ? '$name ($dosage)' : name)
          : (reason.isNotEmpty ? '$name — $reason' : name);
      if (v.isEmpty || v == original) {
        return (name: name, reason: reason, dosage: dosage);
      }
      if (isCurrent) {
        if (v.endsWith(')')) {
          final open = v.lastIndexOf(' (');
          if (open > 0) {
            return (
              name: v.substring(0, open).trim(),
              reason: reason,
              dosage: v.substring(open + 2, v.length - 1).trim(),
            );
          }
        }
        return (name: v, reason: reason, dosage: '');
      }
      final dash = v.indexOf(' — ');
      if (dash > 0) {
        return (
          name: v.substring(0, dash).trim(),
          reason: v.substring(dash + 3).trim(),
          dosage: '',
        );
      }
      // The user removed the visible reason — honor the removal.
      return (name: v, reason: '', dosage: '');
    }

    // Promote the nullable field to a local so the med/condition branches
    // below are null-safe. `_applyAll` can be invoked from the always-enabled
    // "Autofill Information" button before any successful extraction (or after
    // a reset clears `_validated` at the top of the flow); the validated-data
    // branches must simply no-op in that case rather than throw
    // "Null check operator used on a null value". Smart Fill (which reads
    // `_smartResult`, not `_validated`) still runs below.
    final validated = _validated;

    for (final entry in _reviewChecked.entries) {
      if (!entry.value) continue;
      final key = entry.key;

      if (validated != null && key.startsWith('med_prefer_')) {
        final med = validated.preferredMeds
            .firstWhere((m) => 'med_prefer_${m.originalName}' == key);
        final r = medFromReview(key, name: med.displayName, reason: med.reason);
        if (!medExists(r.name, MedicationEntryType.preferred.name)) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.preferred.name,
            medicationName: Value(r.name),
            reason: Value(r.reason),
            sortOrder: Value(medOrder++),
          ));
          applied++;
        }
      } else if (validated != null && key.startsWith('med_avoid_')) {
        final med = validated.avoidMeds
            .firstWhere((m) => 'med_avoid_${m.originalName}' == key);
        final r = medFromReview(key, name: med.displayName, reason: med.reason);
        if (!medExists(r.name, MedicationEntryType.exception.name)) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.exception.name,
            medicationName: Value(r.name),
            reason: Value(r.reason),
            sortOrder: Value(medOrder++),
          ));
          applied++;
        }
      } else if (key == 'facility_prefer') {
        await repo.upsertPreferences(DirectivePrefsCompanion(
          directiveId: Value(id),
          treatmentFacilityPref: Value(TreatmentFacilityPreference.prefer.name),
          preferredFacilityName: Value(_facilityValue(key)),
        ));
        applied++;
      } else if (key == 'facility_avoid') {
        await repo.upsertPreferences(DirectivePrefsCompanion(
          directiveId: Value(id),
          treatmentFacilityPref: Value(TreatmentFacilityPreference.avoid.name),
          avoidFacilityName: Value(_facilityValue(key)),
        ));
        applied++;
      }
    }

    // Write the effective condition. Prefer the person's VERBATIM "when it
    // kicks in" wording from the document (reviewed/edited by the user);
    // fall back to the synthesized conditions sentence only when the document
    // had no trigger language but condition chips were confirmed.
    final ecEdited = _reviewChecked['effective_condition'] == true
        ? (_reviewEdited['effective_condition'] ?? '').trim()
        : '';
    final condNames = validated == null
        ? <String>[]
        : validated.conditions
            .where((c) => _reviewChecked['cond_${c.originalText}'] == true)
            .map((c) => c.displayName)
            .toList();
    if (ecEdited.isNotEmpty || condNames.isNotEmpty) {
      final directive = await repo.getDirectiveById(id);
      if (directive != null && directive.effectiveCondition.isEmpty) {
        await repo.updateEffectiveCondition(
          id,
          ecEdited.isNotEmpty
              ? ecEdited
              : 'This directive becomes effective when I am unable to make '
                  'mental health treatment decisions as determined by '
                  'qualified professionals. '
                  'Relevant conditions: ${condNames.join(", ")}.',
        );
        applied++;
      }
    }

    // Additional instruction text fields
    final instrMap = <String, String>{};
    void addInstr(String reviewKey, String instrField) {
      if (_reviewChecked[reviewKey] == true &&
          _reviewEdited[reviewKey] != null) {
        instrMap[instrField] = _reviewEdited[reviewKey]!;
      }
    }

    // Health history — verbatim prose the user reviewed (single note).
    addInstr('hh_note', 'healthHistory');

    addInstr('dietary', 'dietary');
    addInstr('religious', 'religious');
    addInstr('activities', 'activities');
    addInstr('crisis', 'crisisIntervention');
    addInstr('pet_custody', 'petCustody');
    addInstr('children_custody', 'childrenCustody');
    addInstr('family_notification', 'familyNotification');
    addInstr('records_disclosure', 'recordsDisclosure');
    addInstr('other', 'other');

    // ── Apply Smart Fill results ─────────────────────────────────────
    if (_smartResult != null && _smartEdited.isNotEmpty) {
      String? smartVal(String key) {
        if (_smartChecked[key] != true) return null;
        final t = _smartEdited[key]?.trim();
        return (t != null && t.isNotEmpty) ? t : null;
      }

      // Smart Fill effective condition (only if not already set by extraction)
      final ec = smartVal('Effective Condition');
      if (ec != null && condNames.isEmpty) {
        final d = await repo.getDirectiveById(id);
        if (d != null && d.effectiveCondition.isEmpty) {
          await repo.updateEffectiveCondition(id, ec);
          applied++;
        }
      }

      // Append a checked smart-fill value onto an additional-instructions
      // field (merging under anything the extraction path already queued).
      void addSmart(String displayKey, String instrField, {String? label}) {
        final t = smartVal(displayKey);
        if (t == null) return;
        final text = label == null ? t : '$label: $t';
        instrMap[instrField] = instrMap.containsKey(instrField)
            ? '${instrMap[instrField]}\n$text'
            : text;
      }

      addSmart('Health History', 'healthHistory');
      addSmart('Crisis Intervention', 'crisisIntervention');
      addSmart('Helpful Activities', 'activities');
      addSmart('Dietary Considerations', 'dietary');
      addSmart('Agent Guidance', 'other');
      // Fields with exact additional-instructions columns.
      addSmart('Religious/Spiritual', 'religious');
      addSmart('Children/Dependent Care', 'childrenCustody');
      addSmart('Family Notification', 'familyNotification');
      addSmart('Records Disclosure', 'recordsDisclosure');
      addSmart('Pet Care', 'petCustody');
      // Crisis-adjacent guidance joins the crisis-intervention narrative.
      addSmart('De-escalation Techniques', 'crisisIntervention',
          label: 'De-escalation');
      addSmart('Crisis Triggers', 'crisisIntervention',
          label: 'Known triggers');
      // Facility NOTES describe the kind of setting (not a facility name),
      // so they can't go into the name columns — keep them, labeled, in
      // "Other instructions".
      addSmart('Facility Notes (preferred)', 'other',
          label: 'Preferred facility type');
      addSmart('Facility Notes (avoid)', 'other',
          label: 'Facility settings to avoid');
      // NOT applied on purpose: 'ECT Guidance', 'Experimental Studies
      // Guidance', 'Drug Trials Guidance' — neutral drafting guidance the
      // user reads (marked guidance-only in the results UI); AI meta-text
      // must never print into the legal form.
      // Smart-fill no longer suggests medications — the AI must never
      // recommend or name drugs the user didn't enter (see smart_fill_service).
    }

    // Write all accumulated instruction fields
    if (instrMap.isNotEmpty) {
      final existing = await repo.getAdditionalInstructions(id);
      String merge(String? old, String? add) {
        if (add == null) return old ?? '';
        if (old == null || old.trim().isEmpty) return add;
        return '$old\n$add';
      }

      await repo.upsertAdditionalInstructions(
        AdditionalInstructionsTableCompanion(
          directiveId: Value(id),
          healthHistory: instrMap.containsKey('healthHistory')
              ? Value(merge(existing?.healthHistory, instrMap['healthHistory']))
              : const Value.absent(),
          dietary: instrMap.containsKey('dietary')
              ? Value(merge(existing?.dietary, instrMap['dietary']))
              : const Value.absent(),
          religious: instrMap.containsKey('religious')
              ? Value(merge(existing?.religious, instrMap['religious']))
              : const Value.absent(),
          activities: instrMap.containsKey('activities')
              ? Value(merge(existing?.activities, instrMap['activities']))
              : const Value.absent(),
          crisisIntervention: instrMap.containsKey('crisisIntervention')
              ? Value(merge(
                  existing?.crisisIntervention, instrMap['crisisIntervention']))
              : const Value.absent(),
          petCustody: instrMap.containsKey('petCustody')
              ? Value(merge(existing?.petCustody, instrMap['petCustody']))
              : const Value.absent(),
          childrenCustody: instrMap.containsKey('childrenCustody')
              ? Value(merge(existing?.childrenCustody, instrMap['childrenCustody']))
              : const Value.absent(),
          familyNotification: instrMap.containsKey('familyNotification')
              ? Value(merge(
                  existing?.familyNotification, instrMap['familyNotification']))
              : const Value.absent(),
          recordsDisclosure: instrMap.containsKey('recordsDisclosure')
              ? Value(merge(
                  existing?.recordsDisclosure, instrMap['recordsDisclosure']))
              : const Value.absent(),
          other: instrMap.containsKey('other')
              ? Value(merge(existing?.other, instrMap['other']))
              : const Value.absent(),
        ),
      );
    }

    // ── Apply diagnoses → DiagnosisEntries table ─────────────────────
    if (validated != null) {
      final existingDiagnoses = await repo.getDiagnoses(id);
      final existingDiagNames =
          existingDiagnoses.map((d) => d.name.toLowerCase()).toSet();
      int diagOrder = existingDiagnoses.length;
      for (final d in validated.diagnoses) {
        final key = 'diag_${d.name}';
        if (_reviewChecked[key] != true) continue;
        if (existingDiagNames.contains(d.name.toLowerCase())) continue;
        await repo.insertDiagnosis(DiagnosisEntriesCompanion.insert(
          directiveId: id,
          name: Value(d.name),
          icdCode: Value(d.icdCode ?? ''),
          sortOrder: Value(diagOrder++),
        ));
        applied++;
      }
    }

    // ── Apply allergies → DirectiveAllergies table ────────────────────
    // Drug allergens applied here are also candidates for the "Medications I
    // never want" list — offered (never auto) via a prompt after everything
    // else is applied (see the end of this method).
    final appliedDrugAllergens = <String>[];
    if (validated != null) {
      final existingAllergies = await repo.getAllergies(id);
      final existingSubstances =
          existingAllergies.map((a) => a.substance.toLowerCase()).toSet();
      int allergyOrder = existingAllergies.length;
      for (final a in validated.allergies) {
        final key = 'allergy_${a.substance}';
        if (_reviewChecked[key] != true) continue;
        if (existingSubstances.contains(a.substance.toLowerCase())) continue;
        // Clamp kind and severity to the values the app understands.
        const validKinds = {'drug', 'food', 'material', 'other'};
        const validSeverities = {'mild', 'moderate', 'severe'};
        final kind = validKinds.contains(a.kind) ? a.kind : 'other';
        final severity =
            validSeverities.contains(a.severity) ? a.severity : 'moderate';
        await repo.addAllergy(DirectiveAllergiesCompanion.insert(
          directiveId: id,
          kind: Value(kind),
          substance: Value(a.substance),
          severity: Value(severity),
          reactions: Value(a.reactions ?? ''),
          notes: Value(a.notes ?? ''),
          sortOrder: Value(allergyOrder++),
        ));
        if (kind == 'drug') appliedDrugAllergens.add(a.substance);
        applied++;
      }
    }

    // ── Apply currently-taking medications (reference list) ──────────
    if (validated != null) {
      for (final med in validated.currentMeds) {
        final key = 'med_current_${med.originalName}';
        if (_reviewChecked[key] != true) continue;
        final r = medFromReview(key,
            name: med.displayName,
            reason: med.reason,
            dosage: med.dosage,
            isCurrent: true);
        if (!medExists(r.name, MedicationEntryType.current.name)) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.current.name,
            medicationName: Value(r.name),
            reason: Value(r.reason),
            // Dosage is captured only for currently-taking meds.
            dosage: Value(r.dosage),
            sortOrder: Value(medOrder++),
          ));
          applied++;
        }
      }
    }

    // ── Apply medication limitations ──────────────────────────────────
    if (validated != null) {
      for (final med in validated.limitedMeds) {
        final key = 'med_limit_${med.originalName}';
        if (_reviewChecked[key] != true) continue;
        final r = medFromReview(key, name: med.displayName, reason: med.reason);
        if (!medExists(r.name, MedicationEntryType.limitation.name)) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.limitation.name,
            medicationName: Value(r.name),
            reason: Value(r.reason),
            sortOrder: Value(medOrder++),
          ));
          applied++;
        }
      }
    }

    // ── Apply personal info (PII) ────────────────────────────────────────
    // Autofill the declarant + the people they designate. Only checked,
    // non-empty values are written; an un-extracted field keeps its current
    // value (we never blank something the user already had).
    String? pv(String key) {
      if (_reviewChecked[key] != true) return null;
      final t = _reviewEdited[key]?.trim();
      return (t != null && t.isNotEmpty) ? t : null;
    }

    final pName = pv('person_name');
    final pDob = pv('person_dob');
    final pAddr1 = pv('person_address1');
    final pAddr2 = pv('person_address2');
    final pCity = pv('person_city');
    final pCounty = pv('person_county');
    final pState = pv('person_state');
    final pZip = pv('person_zip');
    final pPhone = pv('person_phone');
    if (pName != null ||
        pDob != null ||
        pAddr1 != null ||
        pCity != null ||
        pPhone != null) {
      final d = await repo.getDirectiveById(id);
      await repo.updatePersonalInfo(
        id,
        fullName: pName ?? d?.fullName ?? '',
        dateOfBirth: pDob ?? d?.dateOfBirth ?? '',
        address: pAddr1 ?? d?.address ?? '',
        address2: pAddr2 ?? d?.address2 ?? '',
        city: pCity ?? d?.city ?? '',
        county: pCounty ?? d?.county ?? '',
        state: pState ?? d?.state ?? '',
        zip: pZip ?? d?.zip ?? '',
        phone: pPhone ?? d?.phone ?? '',
      );
      applied += [pName, pDob, pAddr1, pCity, pPhone]
          .whereType<String>()
          .length;
    }

    final docName = pv('person_doctor_name');
    final docSpecialty = pv('person_doctor_specialty');
    final docPhone = pv('person_doctor_phone');
    if (docName != null || docSpecialty != null || docPhone != null) {
      final d = await repo.getDirectiveById(id);
      await repo.updatePrimaryDoctor(
        id,
        name: docName ?? d?.primaryDoctorName ?? '',
        specialty: docSpecialty ?? d?.primaryDoctorSpecialty ?? '',
        phone: docPhone ?? d?.primaryDoctorPhone ?? '',
      );
      applied += [docName, docSpecialty, docPhone].whereType<String>().length;
    }

    final evalDocName = pv('person_eval_doctor_name');
    final evalDocContact = pv('person_eval_doctor_contact');
    if (evalDocName != null || evalDocContact != null) {
      final d = await repo.getDirectiveById(id);
      await repo.updatePreferredDoctor(
        id,
        name: evalDocName ?? d?.preferredDoctorName ?? '',
        contact: evalDocContact ?? d?.preferredDoctorContact ?? '',
      );
      applied += [evalDocName, evalDocContact].whereType<String>().length;
    }

    Future<void> applyAgent(String type, String prefix) async {
      final name = pv('${prefix}_name');
      final rel = pv('${prefix}_relationship');
      final addr1 = pv('${prefix}_address1');
      final addr2 = pv('${prefix}_address2');
      final city = pv('${prefix}_city');
      final state = pv('${prefix}_state');
      final zip = pv('${prefix}_zip');
      final phone = pv('${prefix}_phone');
      if (name == null &&
          rel == null &&
          addr1 == null &&
          city == null &&
          phone == null) {
        return;
      }
      final existing =
          (await repo.getAgents(id)).where((a) => a.agentType == type).toList();
      final cur = existing.isEmpty ? null : existing.first;
      await repo.upsertAgent(AgentsCompanion(
        id: cur != null ? Value(cur.id) : const Value.absent(),
        directiveId: Value(id),
        agentType: Value(type),
        fullName: Value(name ?? cur?.fullName ?? ''),
        relationship: Value(rel ?? cur?.relationship ?? ''),
        address: Value(addr1 ?? cur?.address ?? ''),
        address2: Value(addr2 ?? cur?.address2 ?? ''),
        city: Value(city ?? cur?.city ?? ''),
        state: Value(state ?? cur?.state ?? ''),
        zip: Value(zip ?? cur?.zip ?? ''),
        cellPhone: Value(phone ?? cur?.cellPhone ?? ''),
      ));
      applied += [name, rel, addr1, city, phone].whereType<String>().length;
    }

    await applyAgent('primary', 'agent');
    await applyAgent('alternate', 'alt_agent');

    final gName = pv('guardian_name');
    final gRel = pv('guardian_relationship');
    final gAddr1 = pv('guardian_address1');
    final gAddr2 = pv('guardian_address2');
    final gCity = pv('guardian_city');
    final gState = pv('guardian_state');
    final gZip = pv('guardian_zip');
    final gPhone = pv('guardian_phone');
    if (gName != null ||
        gRel != null ||
        gAddr1 != null ||
        gCity != null ||
        gPhone != null) {
      final cur = await repo.getGuardianNomination(id);
      await repo.upsertGuardianNomination(GuardianNominationsCompanion(
        id: cur != null ? Value(cur.id) : const Value.absent(),
        directiveId: Value(id),
        nomineeFullName: Value(gName ?? cur?.nomineeFullName ?? ''),
        nomineeRelationship: Value(gRel ?? cur?.nomineeRelationship ?? ''),
        nomineeAddress: Value(gAddr1 ?? cur?.nomineeAddress ?? ''),
        nomineeAddress2: Value(gAddr2 ?? cur?.nomineeAddress2 ?? ''),
        nomineeCity: Value(gCity ?? cur?.nomineeCity ?? ''),
        nomineeState: Value(gState ?? cur?.nomineeState ?? ''),
        nomineeZip: Value(gZip ?? cur?.nomineeZip ?? ''),
        nomineePhone: Value(gPhone ?? cur?.nomineePhone ?? ''),
      ));
      applied += [gName, gRel, gAddr1, gCity, gPhone].whereType<String>().length;
    }

    // ── Apply agent authority limitations ─────────────────────────────
    final agentLimits = pv('agent_authority_limitations');
    if (agentLimits != null) {
      final existingPrefs = await repo.getPreferences(id);
      final cur = existingPrefs?.agentAuthorityLimitations ?? '';
      final merged = cur.isEmpty ? agentLimits : '$cur\n$agentLimits';
      await repo.upsertPreferences(DirectivePrefsCompanion(
        directiveId: Value(id),
        agentAuthorityLimitations: Value(merged),
      ));
      applied++;
    }

    // ── Apply ECT / experimental / drug trial / medication consent ────
    // Map extracted "yes"/"agent"/"no"/"conditional: <text>" → the canonical
    // stored values (ConsentOption.name, or the 'conditional:' prefix form).
    String? toConsentValue(String? extracted) {
      if (extracted == null) return null;
      if (extracted.startsWith('conditional:')) {
        final restriction =
            extracted.substring('conditional:'.length).trim();
        return restriction.isEmpty
            ? null
            : '$consentConditionalPrefix$restriction';
      }
      switch (extracted) {
        case 'yes': return ConsentOption.yes.name;
        case 'agent': return ConsentOption.agentDecides.name;
        case 'no': return ConsentOption.no.name;
        default: return null;
      }
    }
    final ectVal = toConsentValue(pv('ect_consent'));
    final expVal = toConsentValue(pv('experimental_consent'));
    final drugVal = toConsentValue(pv('drug_trial_consent'));
    final medConsentVal = toConsentValue(pv('medication_consent'));
    final roomNote = pv('room_prefs_note');
    // Structured toggles — apply only if still checked in review AND the AI
    // actually set a value (the boolean lives on the validated result, not the
    // display string). Same-gender roommate maps to the room-preference chip
    // plus the default same-as-identity match.
    final applyHosp = _reviewChecked['authority_hospitalization'] == true &&
        validated?.agentCanConsentHospitalization != null;
    final applyMeds = _reviewChecked['authority_medication'] == true &&
        validated?.agentCanConsentMedication != null;
    final applyUlysses = _reviewChecked['ulysses_optin'] == true &&
        validated?.selfBindingUlysses == true;
    final applyRoommate = _reviewChecked['roommate_same_gender'] == true &&
        validated?.sameGenderRoommate == true;
    if (ectVal != null ||
        expVal != null ||
        drugVal != null ||
        medConsentVal != null ||
        roomNote != null ||
        applyHosp ||
        applyMeds ||
        applyUlysses ||
        applyRoommate) {
      await repo.upsertPreferences(DirectivePrefsCompanion(
        directiveId: Value(id),
        ectConsent: ectVal != null ? Value(ectVal) : const Value.absent(),
        experimentalConsent: expVal != null ? Value(expVal) : const Value.absent(),
        drugTrialConsent: drugVal != null ? Value(drugVal) : const Value.absent(),
        medicationConsent: medConsentVal != null
            ? Value(medConsentVal)
            : const Value.absent(),
        roomPreferencesNote: roomNote != null ? Value(roomNote) : const Value.absent(),
        agentCanConsentHospitalization: applyHosp
            ? Value(validated!.agentCanConsentHospitalization!)
            : const Value.absent(),
        agentCanConsentMedication: applyMeds
            ? Value(validated!.agentCanConsentMedication!)
            : const Value.absent(),
        selfBindingEnabled:
            applyUlysses ? const Value(true) : const Value.absent(),
        roomPreferences:
            applyRoommate ? const Value('sameGenderRoommate') : const Value.absent(),
        roommateGenderMatch:
            applyRoommate ? const Value('sameAsIdentity') : const Value.absent(),
      ));
      applied += [ectVal, expVal, drugVal, medConsentVal, roomNote]
          .whereType<String>()
          .length;
      applied +=
          [applyHosp, applyMeds, applyUlysses, applyRoommate].where((b) => b).length;
    }

    // ── Apply the statutory activation triggers ("when this kicks in") ──
    // Confirmed-in-review trigger checkboxes; the effective-condition TEXT
    // (written above) is preserved by re-writing the current value.
    final trigTwo = _reviewChecked['trigger_two_professionals'] == true &&
        validated?.triggerTwoProfessionals == true;
    final trigCourt = _reviewChecked['trigger_court_order'] == true &&
        validated?.triggerCourtOrder == true;
    final trigCommit =
        _reviewChecked['trigger_involuntary_commitment'] == true &&
            validated?.triggerInvoluntaryCommitment == true;
    if (trigTwo || trigCourt || trigCommit) {
      final d = await repo.getDirectiveById(id);
      await repo.updateEffectiveCondition(
        id,
        d?.effectiveCondition ?? '',
        twoProfessionals: trigTwo ? true : null,
        courtOrder: trigCourt ? true : null,
        involuntaryCommitment: trigCommit ? true : null,
      );
      applied += [trigTwo, trigCourt, trigCommit].where((b) => b).length;
    }

    // Each additional-instruction field actually written counts once (review
    // pass-throughs + smart-fill both land in instrMap).
    applied += instrMap.length;

    // Offer to also add applied drug allergies to "Medications I never want"
    // (opt-in prompt, never automatic — mirrors the manual allergies step).
    if (mounted && appliedDrugAllergens.isNotEmpty) {
      applied += await promptAddDrugAllergiesToNeverWant(
        context: context,
        repo: repo,
        directiveId: id,
        drugSubstances: appliedDrugAllergens,
      );
    }

    _onApplied(applied);
  }

  Future<void> _editField(String key) async {
    final controller = TextEditingController(text: _reviewEdited[key]);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_displayLabel(key)),
        content: TextField(
          controller: controller,
          maxLines: null,
          minLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && mounted) {
      setState(() {
        _reviewEdited[key] = result;
        if (result.trim().isNotEmpty) _reviewChecked[key] = true;
      });
    }
  }

  Future<void> _editSmartField(String key) async {
    final controller = TextEditingController(text: _smartEdited[key]);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(key),
        content: TextField(
          controller: controller,
          maxLines: null,
          minLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && mounted) {
      setState(() {
        _smartEdited[key] = result;
        if (result.trim().isNotEmpty) _smartChecked[key] = true;
      });
    }
  }
}
