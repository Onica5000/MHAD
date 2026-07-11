/// Attachment pages appended after the official form content — clearly
/// labeled additions carrying data the app captures that the official 2005
/// booklet has no section for (2026-07-09 PDF audit, defects #1-#3):
/// allergies & adverse reactions, the structured crisis plan, and the
/// self-binding (Ulysses) acknowledgment. Rendered ONLY when data exists, so
/// blank forms and directives without this data are unchanged.
library;

import 'dart:convert';

import 'package:mhad/data/database/app_database.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_helpers.dart';

/// Whether any attachment content exists for this data set.
bool hasAttachmentContent({
  required List<DirectiveAllergy> allergies,
  required DirectivePref? prefs,
}) =>
    allergies.isNotEmpty ||
    _parseCrisisPlan(prefs?.crisisPlanJson).isNotEmpty ||
    (prefs?.selfBindingEnabled ?? false);

/// The crisis-plan lists in display order, parsed from `crisisPlanJson`
/// (same keys the crisis-plan screen persists). Empty on missing/malformed.
List<(String, List<String>)> _parseCrisisPlan(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  const labels = [
    ('earlyWarning', 'Early warning signs'),
    ('triggers', 'Things that trigger or worsen a crisis'),
    ('helps', 'What helps during a crisis'),
    ('sayToMe', 'Things to say to me'),
    ('dontDo', 'Things NOT to do'),
  ];
  try {
    final m = jsonDecode(raw) as Map<String, dynamic>;
    final out = <(String, List<String>)>[];
    for (final (key, label) in labels) {
      final items = ((m[key] as List?) ?? const [])
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (items.isNotEmpty) out.add((label, items));
    }
    return out;
  } catch (_) {
    return const [];
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Builds the attachment pages. Returns an empty list when there is nothing
/// to attach.
List<pw.Page> buildAttachmentPages({
  required Directive directive,
  required List<DirectiveAllergy> allergies,
  required DirectivePref? prefs,
  DraftMode draftMode = DraftMode.finalCopy,
}) {
  final crisisPlan = _parseCrisisPlan(prefs?.crisisPlanJson);
  final selfBinding = prefs?.selfBindingEnabled ?? false;
  if (allergies.isEmpty && crisisPlan.isEmpty && !selfBinding) {
    return const [];
  }

  final label = draftLabel(draftMode);
  final formTitle = label.isEmpty
      ? 'Attachments to My Mental Health Advance Directive'
      : 'Attachments to My Mental Health Advance Directive  ·  $label';
  final whose = directive.fullName.isNotEmpty
      ? 'the Mental Health Advance Directive of ${directive.fullName}'
      : 'my Mental Health Advance Directive';
  var attachmentNo = 0;
  String nextLabel() {
    attachmentNo++;
    return 'Attachment ${String.fromCharCode(64 + attachmentNo)}';
  }

  return [
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: kPageFormat,
        margin: pageMargins,
        buildBackground: (ctx) => draftWatermark(draftMode),
      ),
      header: (ctx) => pageHeader(formTitle),
      footer: (ctx) =>
          pageFooter('Page ${ctx.pageNumber} of ${ctx.pagesCount}'),
      build: (ctx) => [
        pw.Center(
          child: pw.Text(
            'ATTACHMENTS',
            style: boldStyle(fontSize: 13),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'The following pages accompany and form part of $whose. They record '
          'information I provided for my care team; where they state a '
          'preference, it carries the same intent as the instructions in the '
          'form itself.',
          style: bodyStyle(),
        ),
        pw.SizedBox(height: 10),

        // ── Allergies & adverse reactions ─────────────────────────────
        if (allergies.isNotEmpty) ...[
          sectionHeader('${nextLabel()}: Allergies and Adverse Reactions'),
          pw.SizedBox(height: 4),
          pw.Text(
            'Known allergies, sensitivities, and past adverse reactions. '
            'Please check this list before administering any medication or '
            'treatment.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),
          for (final a in allergies) ...[
            pw.Text(
              '${a.substance}'
              '${a.kind.isNotEmpty ? ' (${a.kind})' : ''}'
              ' · severity: ${a.severity}',
              style: boldStyle(),
            ),
            if (a.reactions.isNotEmpty)
              pw.Text('Reactions: ${a.reactions}', style: bodyStyle()),
            if (a.notes.isNotEmpty)
              pw.Text('Notes: ${a.notes}', style: bodyStyle()),
            pw.SizedBox(height: 5),
          ],
          pw.SizedBox(height: 6),
        ],

        // ── Crisis plan ───────────────────────────────────────────────
        if (crisisPlan.isNotEmpty) ...[
          sectionHeader('${nextLabel()}: Crisis Plan'),
          pw.SizedBox(height: 4),
          pw.Text(
            'My personal crisis plan. These points help my care team '
            'recognize, avoid, and de-escalate a crisis in the way that '
            'works for me.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),
          for (final (heading, items) in crisisPlan) ...[
            pw.Text('$heading:', style: boldStyle()),
            for (final item in items)
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Text('· ${_capitalize(item)}', style: bodyStyle()),
              ),
            pw.SizedBox(height: 5),
          ],
          pw.SizedBox(height: 6),
        ],

        // ── Self-binding (Ulysses) acknowledgment ─────────────────────
        if (selfBinding) ...[
          sectionHeader('${nextLabel()}: Self-Binding Acknowledgment'),
          pw.SizedBox(height: 4),
          pw.Text(
            'I acknowledge and intend that, under the Pennsylvania Mental '
            'Health Advance Directive Act (Act 194 of 2004, 20 Pa.C.S. '
            'Ch. 58), the instructions in my directive remain in effect '
            'during a period in which I am incapable of making mental health '
            'care decisions, even if I object at that time. I have made this '
            'choice deliberately, while having the capacity to do so.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),
        ],
      ],
    ),
  ];
}
