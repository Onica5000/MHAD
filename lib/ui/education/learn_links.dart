import 'package:flutter/material.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/widgets/rich_content_text.dart';

/// Learn's cross-links — the glossary words an article uses, and the articles
/// nearest it — so a reader can check a term or keep reading without going
/// back to the list. ONE place for the matching rules.

/// The words a glossary title is found by in text: the title without a
/// parenthetical note or quotes, and both names around an em dash
/// ("PMHCA — PA Mental Health Consumers' Association").
List<String> glossaryMatchTerms(String title) {
  final plain = title
      .replaceAll(RegExp(r'\([^)]*\)'), '')
      .replaceAll(RegExp('["“”]'), '')
      .trim();
  return [
    for (final part in plain.split(RegExp(r'\s+—\s+')))
      if (part.trim().isNotEmpty) part.trim(),
  ];
}

RegExp _termPattern(String term) => RegExp(
      '(?<![\\w])${RegExp.escape(term)}(?:s|es|d|ed)?(?![\\w])',
      caseSensitive: false,
    );

/// The glossary entries [section] uses, in order of first use (at most
/// [max]); never the entry itself. Plurals and past forms count ("agents",
/// "revoked").
List<EducationSection> glossaryTermsIn(
  EducationSection section, {
  List<EducationSection>? all,
  int max = 8,
}) {
  final text = stripInlineMarkdown(section.content);
  final found = <(int, EducationSection)>[];
  for (final g in all ?? allEducationSections) {
    if (g.category != EducationCategory.glossary || g.id == section.id) {
      continue;
    }
    int? first;
    for (final term in glossaryMatchTerms(g.title)) {
      final m = _termPattern(term).firstMatch(text);
      if (m != null && (first == null || m.start < first)) first = m.start;
    }
    if (first != null) found.add((first, g));
  }
  found.sort((a, b) => a.$1.compareTo(b.$1));
  return [for (final f in found.take(max)) f.$2];
}

/// Up to [max] articles nearest [section] in the booklet's order within its
/// category — the next one first, then the previous, and so on.
List<EducationSection> relatedSections(
  EducationSection section, {
  List<EducationSection>? all,
  int max = 3,
}) {
  final same = [
    for (final s in all ?? allEducationSections)
      if (s.category == section.category) s,
  ];
  final i = same.indexWhere((s) => s.id == section.id);
  if (i < 0) return const [];
  final out = <EducationSection>[];
  for (var d = 1;
      out.length < max && (i + d < same.length || i - d >= 0);
      d++) {
    if (i + d < same.length) out.add(same[i + d]);
    if (out.length < max && i - d >= 0) out.add(same[i - d]);
  }
  return out;
}

/// A glossary entry's meaning in a sheet, with a way to open the full entry.
Future<void> showGlossaryTerm(
  BuildContext context,
  EducationSection entry, {
  required void Function(EducationSection) onOpen,
}) {
  final t = Theme.of(context).textTheme;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheet) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          Semantics(
            header: true,
            child: Text(glossaryMatchTerms(entry.title).first,
                style: t.titleLarge),
          ),
          const SizedBox(height: 12),
          RichContentText(entry.content, style: t.bodyLarge),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(sheet).pop();
                onOpen(entry);
              },
              icon: const Icon(Icons.menu_book_outlined, size: 18),
              label: Text(sheet.l10n.learnOpenInGlossary),
            ),
          ),
        ],
      ),
    ),
  );
}
