/// Educational content sourced directly from the PA MHAD booklet
/// (Act 194 of 2004, published by the Disabilities Law Project).
///
/// The section prose now lives in `assets/data/educational_content.json` (loaded
/// once at startup via [EducationalContent.load]) so it is dynamic — the Learn
/// page AND the AI assistant's reference knowledge base read from the same
/// source, and the admin propose/approve flow can update it (verify tier). This
/// file keeps the typed model, category enum, and the wizard-step → section-id
/// map (wiring, not content).
library;

import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;

enum EducationCategory {
  intro,
  faq,
  combined,
  declaration,
  poa,
  glossary,
  supplementary,
  checklist;

  String get displayName {
    switch (this) {
      case intro:
        return 'Introduction';
      case faq:
        return 'FAQ';
      case combined:
        return 'Combined Form';
      case declaration:
        return 'Declaration';
      case poa:
        return 'Power of Attorney';
      case glossary:
        return 'Glossary';
      case supplementary:
        return 'Beyond the Booklet';
      case checklist:
        return 'Your Checklist';
    }
  }
}

class EducationSection {
  final String id;
  final EducationCategory category;
  final String title;
  final String content;

  const EducationSection({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
  });
}

/// Loads and holds the educational corpus from
/// `assets/data/educational_content.json`. Exposed as a load-once store (like
/// [AppData]) because it is read from non-widget code too — the AI prompt
/// builder injects every section as the assistant's reference material.
class EducationalContent {
  /// All sections, in display order (the JSON object's key order). Empty until
  /// [load] runs (startup, before runApp).
  static List<EducationSection> sections = const [];

  /// Parse the bundled JSON and publish it to [sections]. Never throws — on any
  /// failure it logs and leaves [sections] as the last good value (empty at
  /// startup) so a corrupt asset can't brick the app.
  static Future<void> load() async {
    try {
      final raw =
          await rootBundle.loadString('assets/data/educational_content.json');
      sections = _parse(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('EducationalContent: failed to load corpus: $e');
    }
  }

  /// The raw bundled JSON map — the base the admin update flow edits before
  /// emitting an updated file to commit.
  static Future<Map<String, dynamic>> loadRawJson() async {
    final raw =
        await rootBundle.loadString('assets/data/educational_content.json');
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static List<EducationSection> _parse(Map<String, dynamic> json) {
    final out = <EducationSection>[];
    final sectionsJson =
        (json['sections'] as Map?)?.cast<String, dynamic>() ?? const {};
    for (final e in sectionsJson.entries) {
      final m = (e.value as Map).cast<String, dynamic>();
      out.add(EducationSection(
        id: e.key,
        category: _categoryFromName((m['category'] ?? '').toString()),
        title: (m['title'] ?? '').toString(),
        content: (m['content'] ?? '').toString(),
      ));
    }
    return out;
  }

  static EducationCategory _categoryFromName(String name) {
    for (final c in EducationCategory.values) {
      if (c.name == name) return c;
    }
    return EducationCategory.faq;
  }
}

/// All education sections (Learn page + AI reference), loaded from
/// `assets/data/educational_content.json` at startup. Kept as a top-level getter
/// so existing call sites read it unchanged.
List<EducationSection> get allEducationSections => EducationalContent.sections;

/// Map from wizard step ID strings to relevant education section IDs.
/// Used by wizard step Help buttons to filter to relevant content.
const wizardStepEducationMap = <String, List<String>>{
  'personalInfo': ['faq_valid', 'faq_what_is', 'intro_overview'],
  'effectiveCondition': [
    'combined_effective',
    'decl_effective',
    'poa_effective',
    'faq_effective',
  ],
  'treatmentFacility': [
    'combined_facility',
    'decl_facility',
    'poa_facility',
    'faq_providers_follow',
  ],
  'medications': [
    'combined_medications',
    'decl_medications',
    'poa_medications',
    'faq_what_to_include',
  ],
  'ect': [
    'combined_ect',
    'decl_ect',
    'poa_ect',
    'gloss_mhad',
  ],
  'experimentalStudies': [
    'combined_experimental',
    'decl_experimental',
    'poa_experimental',
  ],
  'drugTrials': [
    'combined_drug_trials',
    'decl_drug_trials',
    'poa_drug_trials',
  ],
  'additionalInstructions': [
    'combined_additional',
    'decl_additional',
    'poa_facility',
    'faq_what_to_include',
    'faq_deescalation',
    'faq_reproductive_health',
  ],
  'agentDesignation': [
    'combined_agent',
    'poa_agent',
    'faq_combined',
    'faq_agent_unavailable',
    'gloss_agent',
  ],
  'alternateAgent': [
    'combined_alt_agent',
    'poa_alt_agent',
    'faq_agent_unavailable',
    'gloss_agent',
  ],
  'agentAuthority': [
    'combined_authority',
    'poa_authority',
    'combined_ect',
    'combined_experimental',
    'combined_drug_trials',
  ],
  'guardianNomination': [
    'combined_guardian',
    'decl_guardian',
    'poa_guardian',
    'faq_guardian',
    'gloss_declaration',
  ],
  'review': ['faq_who_to_give', 'faq_revoke'],
  'execution': [
    'combined_execution',
    'decl_execution',
    'poa_execution',
    'faq_valid',
    'faq_finding_witnesses',
    'faq_revoke',
    'gloss_execute',
    'supp_governing_law',
  ],
};
