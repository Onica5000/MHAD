import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/ui/widgets/design/status_views.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';
import 'package:mhad/ai/interaction_note.dart';
import 'package:mhad/ai/side_effect_item.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/brand_motif.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';
import 'package:mhad/ui/widgets/fda_label_dialog.dart';

/// "Are you experiencing these side effects?" — for the user's CURRENT
/// medications the AI lists common, well-documented side effects; the user
/// checks which they actually experience. Confirmed items (especially ones
/// that affect daily activities, or that the AI flags as serious) are saved so
/// the care team can handle them appropriately.
///
/// Informational only — the AI never recommends or changes medications and
/// never says how to treat a side effect (see ai_clinical_policy.dart). The
/// checklist is stored as JSON in `directive_prefs.side_effects_json`.
class SideEffectsScreen extends ConsumerStatefulWidget {
  final int directiveId;
  const SideEffectsScreen({required this.directiveId, super.key});

  @override
  ConsumerState<SideEffectsScreen> createState() => _SideEffectsScreenState();
}

class _SideEffectsScreenState extends ConsumerState<SideEffectsScreen> {
  List<SideEffectItem> _items = [];
  List<InteractionNote> _interactions = [];
  List<String> _currentMeds = [];

  /// Medications that get an FDA label card: currently taken plus those
  /// accepted with limits. (Refused and preferred-if-treated meds don't.)
  List<String> _labelMeds = [];
  bool _loading = true;
  bool _generating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final repo = ref.read(directiveRepositoryProvider);
    final pref = await repo.getPreferences(widget.directiveId);
    final meds = await repo.getMedications(widget.directiveId);
    if (!mounted) return;
    // "Currently taking" = the medications the user is currently on
    // (entryType 'current'). Preferred meds are ones they'd want IF treated,
    // not ones they take now; avoid/limitation entries aren't taken either —
    // none of those belong in a side-effect check of current medications.
    final names = meds
        .where((m) => m.entryType == MedicationEntryType.current.name)
        .map((m) => m.medicationName.trim())
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList();
    final labelNames = <String>{
      ...names,
      ...meds
          .where((m) => m.entryType == MedicationEntryType.limitation.name)
          .map((m) => m.medicationName.trim())
          .where((n) => n.isNotEmpty),
    }.toList();
    final raw = pref?.sideEffectsJson ?? '';
    var items = <SideEffectItem>[];
    var interactions = <InteractionNote>[];
    if (raw.isNotEmpty) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        items = ((m['items'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(SideEffectItem.fromJson)
            .toList();
        interactions = ((m['interactions'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(InteractionNote.fromJson)
            .toList();
      } catch (_) {
        /* ignore malformed */
      }
    }
    setState(() {
      _currentMeds = names;
      _labelMeds = labelNames;
      _items = items;
      _interactions = interactions;
      _loading = false;
    });
  }

  Future<void> _persist() async {
    final json = jsonEncode({
      'items': _items.map((i) => i.toJson()).toList(),
      'interactions': _interactions.map((i) => i.toJson()).toList(),
      'generatedForMeds': _currentMeds,
    });
    await ref
        .read(directiveRepositoryProvider)
        .upsertPreferences(
          DirectivePrefsCompanion(
            directiveId: Value(widget.directiveId),
            sideEffectsJson: Value(json),
          ),
        );
  }

  Future<void> _generate() async {
    final assistant = ref.read(aiAssistantProvider);
    if (assistant is! GeminiApiAssistant) return;
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      // Run the two grounded lookups together: common side effects (per med)
      // and possible interactions BETWEEN the current meds. Interactions need
      // 2+ meds and degrade silently to [] otherwise.
      final results = await Future.wait([
        assistant.generateSideEffects(_currentMeds),
        assistant.generateInteractionNotes(_currentMeds),
      ]);
      final found = results[0] as List<SideEffectItem>;
      final interactions = results[1] as List<InteractionNote>;
      if (!mounted) return;
      if (found.isEmpty) {
        setState(() => _error = context.l10n.sideEffectsNoneFound);
      } else {
        // Preserve any previously-checked items that match.
        final priorChecked = {
          for (final p in _items.where((p) => p.experiencing))
            '${p.med}|${p.effect}',
        };
        for (final f in found) {
          if (priorChecked.contains('${f.med}|${f.effect}')) {
            f.experiencing = true;
          }
        }
        setState(() => _items = found);
      }
      setState(() => _interactions = interactions);
      await _persist();
    } catch (e) {
      if (mounted) {
        setState(() => _error = context.l10n.sideEffectsGenerateError);
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final hasKey = ref.watch(apiKeyProvider).value?.isNotEmpty == true;

    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      body: Column(
        children: [
          WizardHeader(
            backLabel: context.l10n.back,
            onBack: () => Navigator.of(context).maybePop(),
            actionLabel: '',
          ),
          Expanded(
            child: _loading
                ? const PageLoading()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                    children: [
                      BrandMotif(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionLabel(context.l10n.sideEffectsOptionalAddOn),
                            const SizedBox(height: 6),
                            EditorialHeading(
                              text: context.l10n.medsStepSideEffectsTitle,
                              size: 30,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.l10n.sideEffectsForTheMedicationsYouRe,
                              style: TextStyle(
                                fontFamily: kSansFamily,
                                fontSize: 14,
                                height: 1.5,
                                color: p.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_labelMeds.isEmpty)
                        _noMedsCard(p)
                      else ...[
                        // The AI checklist covers medications taken now; a
                        // list with only limited meds still gets the labels.
                        if (_currentMeds.isNotEmpty) _generateBar(p, hasKey),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          InfoBanner(
                            icon: Icons.info_outline,
                            variant: InfoBannerVariant.warning,
                            text: _error!,
                          ),
                        ],
                        if (_items.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ..._buildGroupedItems(p),
                          const SizedBox(height: 14),
                          InfoBanner(
                            icon: Icons.medical_information_outlined,
                            variant: InfoBannerVariant.info,
                            text: context
                                .l10n
                                .sideEffectsBringAnythingYouCheckAnd,
                          ),
                        ],
                        if (_interactions.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          SectionLabel(
                            context.l10n.sideEffectsAskYourDoctorOrPharmacist,
                          ),
                          const SizedBox(height: 8),
                          ..._interactions.map((n) => _interactionCard(p, n)),
                          const SizedBox(height: 6),
                          InfoBanner(
                            icon: Icons.info_outline,
                            variant: InfoBannerVariant.info,
                            text: context
                                .l10n
                                .sideEffectsTheseArePossibleInteractionsDrawn,
                          ),
                        ],
                        // AI-free: the official FDA label for every current
                        // medication, with or without an AI key. The AI
                        // checklist above is an optional summary of these.
                        const SizedBox(height: 22),
                        SectionLabel(
                          context.l10n.sideEffectsOfficialLabelsHeading,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.sideEffectsOfficialLabelsIntro,
                          style: TextStyle(
                            fontFamily: kSansFamily,
                            fontSize: 13,
                            height: 1.45,
                            color: p.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final med in _labelMeds)
                          FdaLabelCard(medName: med),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _noMedsCard(MhadPalette p) {
    return InfoBanner(
      icon: Icons.medication_outlined,
      variant: InfoBannerVariant.info,
      text: context.l10n.sideEffectsAddTheMedicationsYouRe,
    );
  }

  Widget _generateBar(MhadPalette p, bool hasKey) {
    if (!hasKey) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.primaryTint,
          borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
          border: Border.all(color: p.primaryLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.sideEffectsChecklistOptionalTitle,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.sideEffectsChecklistOptionalBody,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 13,
                height: 1.45,
                color: p.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.aiSetup),
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: Text(context.l10n.pipelineSetupAi),
            ),
          ],
        ),
      );
    }
    // Stacked (Column) rather than Row + Expanded. On the deployed --release
    // web build the Row's Expanded was collapsing to ~0 width, wrapping the
    // "Checking covers:" text one character per line (vertical). A Column with
    // a plain Text has no flex child to collapse, so it lays out horizontally
    // regardless of the renderer's flex quirks.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _items.isEmpty
              ? context.l10n.sideEffectsCheckingCovers(_currentMeds.join(', '))
              : context.l10n.sideEffectsReCheckFor(_currentMeds.join(', ')),
          style: TextStyle(
            fontFamily: kSansFamily,
            fontSize: 13,
            color: p.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _generating ? null : _generate,
          icon: _generating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome, size: 16),
          label: Text(
            _items.isEmpty
                ? context.l10n.sideEffectsCheckSideEffects
                : context.l10n.sideEffectsReCheck,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGroupedItems(MhadPalette p) {
    final byMed = <String, List<SideEffectItem>>{};
    for (final i in _items) {
      byMed.putIfAbsent(i.med, () => []).add(i);
    }
    final widgets = <Widget>[];
    byMed.forEach((med, items) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            med,
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: p.text,
            ),
          ),
        ),
      );
      for (final item in items) {
        widgets.add(
          _SideEffectRow(
            item: item,
            onChanged: (v) async {
              setState(() => item.experiencing = v);
              await _persist();
            },
          ),
        );
      }
    });
    return widgets;
  }

  /// A single possible-interaction note: the meds involved + a plain-language
  /// question to ask a doctor or pharmacist. Informational only.
  Widget _interactionCard(MhadPalette p, InteractionNote note) {
    return DesignCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      radius: DesignTokens.inputRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.meds.join(' + '),
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: p.text,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            note.note,
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 13,
              height: 1.4,
              color: p.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SideEffectRow extends StatelessWidget {
  final SideEffectItem item;
  final ValueChanged<bool> onChanged;
  const _SideEffectRow({required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final seriousColor = dark
        ? SemanticColors.errorAccentDark
        : SemanticColors.errorAccentLight;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(
          color: item.serious ? seriousColor.withValues(alpha: 0.5) : p.border,
        ),
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item.experiencing,
            onChanged: (v) => onChanged(v ?? false),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 11),
                  child: Text(
                    item.effect,
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                ),
                if (item.adlImpact.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      context.l10n.sideEffectsMayAffect(item.adlImpact),
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 12,
                        height: 1.35,
                        color: p.textMuted,
                      ),
                    ),
                  ),
                if (item.serious)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.priority_high,
                          size: 14,
                          color: seriousColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            context
                                .l10n
                                .sideEffectsWorthDiscussingWithYourDoctor,
                            style: TextStyle(
                              fontFamily: kSansFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: seriousColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
