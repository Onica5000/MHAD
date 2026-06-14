import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';
import 'package:mhad/ai/side_effect_item.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';

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
  List<String> _currentMeds = [];
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
    final meds = await repo.watchMedications(widget.directiveId).first;
    if (!mounted) return;
    // "Currently taking" = informational current meds + the user's preferred
    // (named) meds. Avoid/limitation entries are not things they take.
    final names = meds
        .where((m) =>
            m.entryType == 'current' || m.entryType == 'preferred')
        .map((m) => m.medicationName.trim())
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList();
    final raw = pref?.sideEffectsJson ?? '';
    var items = <SideEffectItem>[];
    if (raw.isNotEmpty) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        items = ((m['items'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(SideEffectItem.fromJson)
            .toList();
      } catch (_) {/* ignore malformed */}
    }
    setState(() {
      _currentMeds = names;
      _items = items;
      _loading = false;
    });
  }

  Future<void> _persist() async {
    final json = jsonEncode({
      'items': _items.map((i) => i.toJson()).toList(),
      'generatedForMeds': _currentMeds,
    });
    await ref.read(directiveRepositoryProvider).upsertPreferences(
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
      final found = await assistant.generateSideEffects(_currentMeds);
      if (!mounted) return;
      if (found.isEmpty) {
        setState(() => _error =
            'We couldn\'t find common side effects to list right now. You can '
            'add anything you\'re experiencing in the Anything-else step, and '
            'always raise side-effect concerns with your doctor.');
      } else {
        // Preserve any previously-checked items that match.
        final priorChecked = {
          for (final p in _items.where((p) => p.experiencing))
            '${p.med}|${p.effect}'
        };
        for (final f in found) {
          if (priorChecked.contains('${f.med}|${f.effect}')) {
            f.experiencing = true;
          }
        }
        setState(() => _items = found);
      }
      await _persist();
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Something went wrong generating the list. '
            'Please try again, or note side effects yourself.');
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final hasKey = ref.watch(apiKeyProvider).valueOrNull?.isNotEmpty == true;

    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      body: Column(children: [
        const CrisisTopBar(compact: true),
        WizardHeader(
          backLabel: 'Back',
          onBack: () => Navigator.of(context).maybePop(),
          actionLabel: '',
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                  children: [
                    const SectionLabel('Optional add-on'),
                    const SizedBox(height: 6),
                    const EditorialHeading(
                        text: 'Side effects you may be experiencing',
                        size: 30),
                    const SizedBox(height: 6),
                    Text(
                      'For the medications you\'re currently taking, here are '
                      'common side effects — check the ones you actually have. '
                      'Noting them (especially any that affect your daily '
                      'activities) helps your care team. This is common-side-'
                      'effect information, not medical advice.',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        height: 1.5,
                        color: p.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_currentMeds.isEmpty)
                      _noMedsCard(p)
                    else ...[
                      _generateBar(p, hasKey),
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
                        const InfoBanner(
                          icon: Icons.medical_information_outlined,
                          variant: InfoBannerVariant.info,
                          text:
                              'Bring anything you check — and especially '
                              'anything marked "discuss with your doctor" — to '
                              'your doctor or pharmacist. This list never tells '
                              'you to start, stop, or change a medication.',
                        ),
                      ],
                    ],
                  ],
                ),
        ),
      ]),
    );
  }

  Widget _noMedsCard(MhadPalette p) {
    return InfoBanner(
      icon: Icons.medication_outlined,
      variant: InfoBannerVariant.info,
      text:
          'Add the medications you\'re currently taking on the Medications step '
          'first, then come back here to check their common side effects.',
    );
  }

  Widget _generateBar(MhadPalette p, bool hasKey) {
    if (!hasKey) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.primaryTint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.primaryLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set up AI to check side effects',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This uses your free Gemini key to list common side effects of '
              'your current medications for you to review.',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12.5,
                height: 1.45,
                color: p.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.aiSetup),
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('Set up AI'),
            ),
          ],
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            _items.isEmpty
                ? 'Checking covers: ${_currentMeds.join(', ')}'
                : 'Re-check for: ${_currentMeds.join(', ')}',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12.5,
              color: p.textMuted,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: _generating ? null : _generate,
          icon: _generating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome, size: 16),
          label: Text(_items.isEmpty ? 'Check side effects' : 'Re-check'),
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
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          med,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: p.text,
          ),
        ),
      ));
      for (final item in items) {
        widgets.add(_SideEffectRow(
          item: item,
          onChanged: (v) async {
            setState(() => item.experiencing = v);
            await _persist();
          },
        ));
      }
    });
    return widgets;
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
    final seriousColor =
        dark ? SemanticColors.errorAccentDark : SemanticColors.errorAccentLight;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(
            color: item.serious ? seriousColor.withValues(alpha: 0.5) : p.border),
        borderRadius: BorderRadius.circular(10),
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
                      fontFamily: 'DM Sans',
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
                      'May affect: ${item.adlImpact}',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
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
                        Icon(Icons.priority_high, size: 14, color: seriousColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Worth discussing with your doctor',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 11.5,
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
