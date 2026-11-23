/// Which Learn sections go into a copy-and-paste "Ask" prompt.
///
/// Sending all of them made the copied message ~127K characters (~32K
/// tokens) — over the free ChatGPT (~27K tokens) and free Gemini (32K tokens)
/// windows as of Nov 2026, so the free plans most people use could cut it off
/// or refuse it. The handoff path now includes the sections most relevant to
/// the question (and step / article) up to a character budget; the hidden API
/// path still sends every section.
library;

import 'package:mhad/data/educational_content.dart';

/// The sections most relevant to [query] whose text fits [budget] characters
/// (title + text + a little framing each), returned in their original order.
/// With no useful words in [query] the budget fills by category priority
/// (FAQ first — the questions people ask most). Pure; [from] for tests.
List<EducationSection> selectReferenceSections(String query, int budget,
    {List<EducationSection>? from}) {
  final all = from ?? allEducationSections;
  final terms = _terms(query);
  final scores = <EducationSection, int>{};
  for (final s in all) {
    if (terms.isEmpty) {
      scores[s] = 0;
      continue;
    }
    final title = _words(s.title);
    final body = _words(s.content);
    var sc = 0;
    for (final t in terms) {
      // A title hit says far more about relevance than a body hit; body
      // hits are capped so one long article can't win on length alone.
      sc += 4 * title.where((w) => _match(w, t)).length;
      final hits = body.where((w) => _match(w, t)).length;
      sc += hits > 8 ? 8 : hits;
    }
    scores[s] = sc;
  }
  final order = {for (var i = 0; i < all.length; i++) all[i]: i};
  final ranked = [...all]..sort((a, b) {
      final d = scores[b]! - scores[a]!;
      if (d != 0) return d;
      final c = _priority(a.category) - _priority(b.category);
      if (c != 0) return c;
      return order[a]! - order[b]!;
    });
  final picked = <EducationSection>{};
  var used = 0;
  for (final s in ranked) {
    final size = sectionChars(s);
    if (used + size > budget) continue;
    picked.add(s);
    used += size;
  }
  return [for (final s in all) if (picked.contains(s)) s];
}

/// The characters a section takes in the reference block.
int sectionChars(EducationSection s) => s.title.length + s.content.length + 40;

int _priority(EducationCategory c) => switch (c) {
      EducationCategory.faq => 0,
      EducationCategory.intro => 1,
      EducationCategory.combined => 2,
      EducationCategory.declaration => 3,
      EducationCategory.poa => 4,
      EducationCategory.checklist => 5,
      EducationCategory.supplementary => 6,
      EducationCategory.glossary => 7,
    };

const _stop = {
  'about', 'after', 'also', 'been', 'being', 'can', 'cannot', 'could', 'does',
  'doing', 'done', 'each', 'from', 'have', 'having', 'here', 'into', 'just',
  'like', 'made', 'make', 'many', 'more', 'most', 'much', 'must', 'need',
  'only', 'other', 'over', 'same', 'should', 'some', 'such', 'than', 'that',
  'their', 'them', 'then', 'there', 'these', 'they', 'this', 'those', 'through',
  'under', 'very', 'want', 'were', 'what', 'when', 'where', 'which', 'while',
  'will', 'with', 'would', 'your', 'yours', 'mine', 'step', 'form', 'know',
  'tell', 'please', 'directive', 'mental', 'health', 'advance',
};

/// Content words of [s] (lower case, 4+ letters, no stop words).
List<String> _terms(String s) =>
    _words(s).where((w) => w.length >= 4 && !_stop.contains(w)).toSet().toList();

List<String> _words(String s) => s
    .toLowerCase()
    .split(RegExp(r'[^a-z0-9áéíóúñü]+'))
    .where((w) => w.isNotEmpty)
    .toList();

/// Same stem: one starts with the other ("witness" ~ "witnesses"), both 4+.
bool _match(String word, String term) =>
    word.length >= 4 && (word.startsWith(term) || term.startsWith(word));
