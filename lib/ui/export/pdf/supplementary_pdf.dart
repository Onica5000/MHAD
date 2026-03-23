import 'package:pdf/widgets.dart' as pw;
import 'pdf_helpers.dart';

/// Builds 1–2 pages of key statutory information from 20 Pa.C.S. Chapter 58
/// that is NOT included in the standard PA MHAD PDF booklet.
List<pw.Page> buildSupplementaryPages() {
  return [
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader('Supplementary Legal Information'),
          sectionHeader('SUPPLEMENTARY INFORMATION — PA Act 194 (20 Pa.C.S. Chapter 58)'),
          pw.SizedBox(height: 6),
          pw.Text(
            'The following information summarizes key statutory provisions not '
            'included in the standard PA MHAD booklet. This is for informational '
            'purposes only and does not constitute legal advice.',
            style: bodyStyle(fontSize: 8),
          ),
          pw.SizedBox(height: 8),
          partHeader('Provider Obligations (§5804, §5807, §5842)'),
          pw.Text(
            'Providers MUST comply with your directive. If a provider objects or '
            'treatment is unavailable, they must: inform you (or your agent/guardian), '
            'document reasons, attempt transfer to a compliant provider, and continue '
            'treating per the directive during transfer. Providers must ask about '
            'directives at intake and cannot require a directive as a condition of '
            'treatment.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),
          partHeader('Emergency Override & Section 302'),
          pw.Text(
            'Your medication refusal (including by MHAD) must be honored unless you '
            'pose imminent danger. Override requires simultaneous initiation of '
            'involuntary commitment under Section 302. Non-emergency override requires '
            'court-ordered commitment under Section 304(c).',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),
          partHeader('Substituted Judgment Standard (§5836)'),
          pw.Text(
            'Your agent must decide as YOU would — based on your known instructions '
            'and preferences — not what the agent thinks is "best." Your agent has '
            'the same rights as you to access mental health records (unless limited '
            'in the POA).',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),
          partHeader('Agent Removal (§5837)'),
          pw.Text(
            'Agents may be removed for: death/incapacity, noncompliance, assault or '
            'threats, coercion, voluntary withdrawal, or divorce. Third parties may '
            'challenge agent authority in orphan\'s court.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),
          partHeader('Divorce Effect (§5838)'),
          pw.Text(
            'Spouse designation as agent is AUTOMATICALLY REVOKED when either spouse '
            'files for divorce — unless the POA clearly states intent to continue.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),
          partHeader('Criminal Penalties (§5806)'),
          pw.Text(
            'It is a third-degree felony to willfully conceal, alter, forge, or '
            'destroy a directive without consent, or to cause execution through '
            'fraud, duress, or undue influence.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),
          partHeader('Provider Immunity (§5805)'),
          pw.Text(
            'Providers acting in good faith are protected from liability for: '
            'complying with or refusing agent directions, capacity determinations, '
            'and authorized disclosures.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),
          partHeader('Conflicting Directives (§5844)'),
          pw.Text(
            'If multiple directives exist, the latest execution date prevails. A '
            'mental health POA ALWAYS prevails over a general POA regardless of date.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),
          partHeader('Interstate Validity (§5845)'),
          pw.Text(
            'Out-of-state mental health POAs are valid in PA if they conform to that '
            'jurisdiction\'s laws, unless agent decisions would conflict with PA law.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),
          partHeader('Court Petition (§5843)'),
          pw.Text(
            'If compliance could cause irreparable harm or death, interested parties '
            'may petition orphan\'s court. The court must act within 72 hours.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),
          partHeader('Guardian vs. Agent (§5841)'),
          pw.Text(
            'Your mental health POA remains effective even after guardianship '
            'adjudication. The court SHALL PREFER allowing your agent to continue '
            'making decisions. A guardian is bound by the same obligations as an agent.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),
          partHeader('Absolute Agent Limits'),
          pw.Text(
            'Agents can NEVER consent to psychosurgery or termination of parental '
            'rights. ECT and experimental procedures require SPECIFIC authorization '
            'in the directive.',
            style: bodyStyle(),
          ),
          pw.Spacer(),
          pageFooter('Supplementary Information — PA Act 194'),
        ],
      ),
    ),
  ];
}
