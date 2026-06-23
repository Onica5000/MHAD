import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/clinical_data_service.dart';
import 'package:mhad/services/medline_plus_service.dart';
import 'package:mhad/utils/debouncer.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/medline_plus_dialog.dart';
import 'package:mhad/ui/widgets/design/health_chip.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/nlm_attribution.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';


class DiagnosesStep extends ConsumerStatefulWidget {
  const DiagnosesStep({
    required this.directiveId,
    this.embedded = false,
    super.key,
  });

  final int directiveId;

  /// When true, render as a non-scrolling Column suitable for embedding in a
  /// parent ListView. When false, render as a full ListView with its own scroll.
  final bool embedded;

  @override
  ConsumerState<DiagnosesStep> createState() => _DiagnosesStepState();
}

class _DiagnosesStepState extends ConsumerState<DiagnosesStep>
    with WizardStepMixin {
  final _searchCtrl = TextEditingController();
  final _searchDebouncer = Debouncer();
  List<IcdCondition> _searchResults = [];
  bool _searching = false;

  // Primary care doctor (artboard "optional" card on this step).
  final _docNameCtrl = TextEditingController();
  final _docSpecialtyCtrl = TextEditingController();
  final _docPhoneCtrl = TextEditingController();

  // NPI provider lookup for the doctor-name field.
  final _docDebouncer = Debouncer(delay: const Duration(milliseconds: 400));
  List<ProviderResult> _docResults = [];
  bool _docSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final d = await ref
          .read(directiveRepositoryProvider)
          .getDirectiveById(widget.directiveId);
      if (d != null && mounted) {
        setState(() {
          _docNameCtrl.text = d.primaryDoctorName;
          _docSpecialtyCtrl.text = d.primaryDoctorSpecialty;
          _docPhoneCtrl.text = d.primaryDoctorPhone;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _docDebouncer.dispose();
    _searchCtrl.dispose();
    _docNameCtrl.dispose();
    _docSpecialtyCtrl.dispose();
    _docPhoneCtrl.dispose();
    super.dispose();
  }

  // ── NPI provider lookup ──────────────────────────────────────────────
  void _onDocNameChanged(String query) {
    if (query.trim().length < 3) {
      _docDebouncer.cancel();
      setState(() => _docResults = []);
      return;
    }
    _docDebouncer.run(() => _searchProviders(query.trim()));
  }

  Future<void> _searchProviders(String query) async {
    setState(() => _docSearching = true);
    try {
      final results = await ClinicalDataService.searchProviders(query);
      if (mounted) setState(() => _docResults = results);
    } finally {
      if (mounted) setState(() => _docSearching = false);
    }
  }

  void _pickProvider(ProviderResult r) {
    setState(() {
      _docNameCtrl.text = r.name;
      if (r.specialty.isNotEmpty) _docSpecialtyCtrl.text = r.specialty;
      if (r.phone.isNotEmpty) _docPhoneCtrl.text = r.phone;
      _docResults = [];
    });
  }

  // ── MedlinePlus plain-language condition info ────────────────────────
  void _showConditionInfo(String icdCode, String name) {
    showMedlinePlusDialog(
      context,
      title: name,
      future: MedlinePlusService.forIcd10(icdCode),
    );
  }

  @override
  Future<bool> validateAndSave() async {
    // Diagnosis entries save on each add/remove; persist the primary-care
    // doctor here on step change.
    await ref.read(directiveRepositoryProvider).updatePrimaryDoctor(
          widget.directiveId,
          name: _docNameCtrl.text.trim(),
          specialty: _docSpecialtyCtrl.text.trim(),
          phone: _docPhoneCtrl.text.trim(),
        );
    return true;
  }

  void _onSearchChanged(String query) {
    if (query.trim().length < 2) {
      _searchDebouncer.cancel();
      setState(() => _searchResults = []);
      return;
    }
    _searchDebouncer.run(() => _search(query.trim()));
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);
    try {
      final results = await ClinicalDataService.searchConditions(query);
      if (mounted) setState(() => _searchResults = results);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _addDiagnosis(
      IcdCondition condition, List<DiagnosisEntry> current) async {
    // Skip if already added
    if (current.any((d) => d.icdCode == condition.code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${condition.name} is already added')),
      );
      return;
    }

    await ref.read(directiveRepositoryProvider).insertDiagnosis(
          DiagnosisEntriesCompanion.insert(
            directiveId: widget.directiveId,
            icdCode: Value(condition.code),
            name: Value(condition.name),
            sortOrder: Value(current.length),
          ),
        );
    _searchCtrl.clear();
    setState(() => _searchResults = []);
  }

  Future<void> _removeDiagnosis(int id) async {
    await ref.read(directiveRepositoryProvider).deleteDiagnosis(id);
  }

  // ─── Search field (editorial SearchField look) ──────────────────────────
  Widget _buildSearchField(MhadPalette p) {
    final active = _searchResults.isNotEmpty || _searching;
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(
          color: active ? p.primary : p.border,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: p.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              autofillHints: const [],
              autocorrect: false,
              enableSuggestions: false,
              onChanged: _onSearchChanged,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: p.text,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Search a condition (e.g. depression, ADHD)…',
                hintStyle: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: p.textMuted,
                ),
              ),
            ),
          ),
          if (_searching)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_searchCtrl.text.isNotEmpty)
            Semantics(
              button: true,
              label: 'Clear search',
              child: InkWell(
                onTap: () {
                  _searchCtrl.clear();
                  setState(() => _searchResults = []);
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 16, color: p.textMuted),
                ),
              ),
            )
          else
            // ICD-10 mono badge pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: p.primaryTint,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ICD-10',
                style: TextStyle(
                  fontFamily: kMonoFamily,
                  fontFamilyFallback: kMonoFallbacks,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: p.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── A result row in the autocomplete dropdown ──────────────────────────
  Widget _buildResultTile(
      IcdCondition c, bool alreadyAdded, List<DiagnosisEntry> current, MhadPalette p) {
    return InkWell(
      onTap: alreadyAdded ? null : () => _addDiagnosis(c, current),
      borderRadius: BorderRadius.circular(7),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 1),
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: p.card,
                border: Border.all(color: p.primaryLight),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                c.code,
                style: TextStyle(
                  fontFamily: kMonoFamily,
                  fontFamilyFallback: kMonoFallbacks,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: p.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                c.name,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: p.text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              alreadyAdded ? Icons.check_circle : Icons.add_circle_outline,
              color: p.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section sub-header inside the dropdown (Psychiatric / Medical) ──────
  Widget _resultSectionHeader(String label, MhadPalette p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: kMonoFamily,
          fontFamilyFallback: kMonoFallbacks,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: p.textMuted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final diagnosesStream = ref
        .watch(directiveRepositoryProvider)
        .watchDiagnoses(widget.directiveId);

    const helpText =
        'Search for your psychiatric and medical diagnoses using ICD-10 codes. '
        'These are the official medical classification codes used by healthcare '
        'providers. Adding your diagnoses helps your care team and agent '
        'understand your conditions.\n\n'
        'Psychiatric diagnoses (F-codes) and medical diagnoses are shown '
        'in separate sections.\n\n'
        'This lookup is free and uses the NIH Clinical Tables Service — '
        'no AI tokens are used.';

    final list = ListView(
      shrinkWrap: widget.embedded,
      physics: widget.embedded ? const NeverScrollableScrollPhysics() : null,
      padding: widget.embedded
          ? const EdgeInsets.symmetric(horizontal: 4)
          : const EdgeInsets.all(16),
      children: [
        WizardHelpButton(helpText: helpText, stepId: 'diagnoses'),
        const SizedBox(height: 8),

        // Search field
        _buildSearchField(p),
        const SizedBox(height: 8),

        // Search results — grouped by psychiatric (F-codes) and medical
        if (_searchResults.isNotEmpty)
          StreamBuilder<List<DiagnosisEntry>>(
            stream: diagnosesStream,
            builder: (context, snap) {
              final current = snap.data ?? [];
              final psych =
                  _searchResults.where((c) => c.code.startsWith('F')).toList();
              final med =
                  _searchResults.where((c) => !c.code.startsWith('F')).toList();

              return Container(
                decoration: p.dropdownDecoration,
                padding: const EdgeInsets.all(6),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: [
                      if (psych.isNotEmpty) ...[
                        _resultSectionHeader('Psychiatric', p),
                        ...psych.map((c) => _buildResultTile(
                              c,
                              current.any((d) => d.icdCode == c.code),
                              current,
                              p,
                            )),
                      ],
                      if (med.isNotEmpty) ...[
                        _resultSectionHeader('Medical', p),
                        ...med.map((c) => _buildResultTile(
                              c,
                              current.any((d) => d.icdCode == c.code),
                              current,
                              p,
                            )),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

        if (_searchResults.isEmpty && _searchCtrl.text.length >= 2)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              _searching ? '' : 'No results found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kSansFamily,
                color: p.textMuted,
              ),
            ),
          ),

        // Added diagnoses
        StreamBuilder<List<DiagnosisEntry>>(
          stream: diagnosesStream,
          builder: (context, snap) {
            final diagnoses = snap.data ?? [];
            if (diagnoses.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: p.surface,
                    border: Border.all(color: p.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.medical_information_outlined,
                          size: 36, color: p.textMuted),
                      const SizedBox(height: 8),
                      Text(
                        'No diagnoses added yet',
                        style: TextStyle(
                          fontFamily: kSansFamily,
                          fontWeight: FontWeight.w600,
                          color: p.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Use the search above to find and add your diagnoses.',
                        style: TextStyle(
                          fontFamily: kSansFamily,
                          fontSize: 12,
                          color: p.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final psychiatric =
                diagnoses.where((d) => d.icdCode.startsWith('F')).toList();
            final medical =
                diagnoses.where((d) => !d.icdCode.startsWith('F')).toList();

            HealthChip chip(DiagnosisEntry d) => HealthChip(
                  code: d.icdCode,
                  label: d.name,
                  sourceTag: 'ICD-10',
                  tone: HealthChipTone.primary,
                  onInfo: d.icdCode.isNotEmpty
                      ? () => _showConditionInfo(d.icdCode, d.name)
                      : null,
                  onRemove: () => _removeDiagnosis(d.id),
                );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel('Added · ${diagnoses.length} '
                    '${diagnoses.length == 1 ? 'condition' : 'conditions'}'),
                if (psychiatric.isNotEmpty) ...[
                  SectionLabel(
                    'Psychiatric (${psychiatric.length})',
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                    style: TextStyle(color: p.primary),
                  ),
                  ...psychiatric.map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: chip(d),
                      )),
                ],
                if (medical.isNotEmpty) ...[
                  SectionLabel(
                    'Medical (${medical.length})',
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                    style: TextStyle(color: p.primary),
                  ),
                  ...medical.map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: chip(d),
                      )),
                ],
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        // Primary care doctor (artboard optional card).
        const SectionLabel('Primary care doctor · optional'),
        const SizedBox(height: 8),
        TextField(
          controller: _docNameCtrl,
          textCapitalization: TextCapitalization.words,
          onChanged: _onDocNameChanged,
          decoration: InputDecoration(
            labelText: 'Doctor name',
            hintText: 'Type a name to search the provider registry',
            border: const OutlineInputBorder(),
            suffixIcon: _docSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.badge_outlined, size: 18),
          ),
        ),
        // NPI provider matches — tap to autofill name / specialty / phone.
        if (_docResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: p.dropdownDecoration,
            padding: const EdgeInsets.all(6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  for (final r in _docResults)
                    InkWell(
                      onTap: () => _pickProvider(r),
                      borderRadius: BorderRadius.circular(7),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.name,
                              style: TextStyle(
                                fontFamily: kSansFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: p.text,
                              ),
                            ),
                            if (r.specialty.isNotEmpty || r.address.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  [r.specialty, r.address]
                                      .where((s) => s.isNotEmpty)
                                      .join(' · '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: kSansFamily,
                                    fontSize: 11.5,
                                    color: p.textMuted,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
                    child: Text(
                      'Provider names from the NPI registry (NIH Clinical '
                      'Tables). Verify details before relying on them.',
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: p.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _docSpecialtyCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Specialty',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _docPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // AI-assist hint (static, mirrors the prototype)
        Container(
          decoration: BoxDecoration(
            color: p.primaryTint,
            border: Border.all(color: p.primaryLight),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome, size: 16, color: p.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 12.5,
                      height: 1.45,
                      color: p.text,
                    ),
                    children: const [
                      TextSpan(text: "Don't know the official name? "),
                      TextSpan(
                        text: 'Describe how it shows up for you',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                          text: " and I'll suggest the closest ICD-10 code "
                              'for you to confirm.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Try →',
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: p.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Footer note
        Text(
          "You're not required to list anything. Anything you do list is "
          'shared only with the people your directive names.',
          style: TextStyle(
            fontFamily: kSansFamily,
            fontSize: 11,
            fontStyle: FontStyle.italic,
            height: 1.45,
            color: p.textMuted,
          ),
        ),

        const SizedBox(height: 12),
        const NlmAttribution(),
      ],
    );
    if (widget.embedded) return list;
    return Column(children: [Expanded(child: list)]);
  }
}
