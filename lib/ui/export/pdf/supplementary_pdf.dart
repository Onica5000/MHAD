import 'package:pdf/widgets.dart' as pw;
import 'pdf_helpers.dart';

/// Supplementary legal-information pages: key 20 Pa.C.S. Chapter 58
/// provisions that are NOT restated in the official form itself, grouped by
/// who they matter to. Every citation verified against the statute text
/// (2026-07-11 legal audit — see docs/PDF_AUDIT_2026-07-09.md).
List<pw.Page> buildSupplementaryPages() {
  pw.Widget item(String header, String body) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            partHeader(header),
            pw.Text(body, style: bodyStyle()),
          ],
        ),
      );

  return [
    pw.MultiPage(
      pageFormat: kPageFormat,
      margin: pageMargins,
      header: (ctx) => pageHeader('Supplementary Legal Information'),
      footer: (ctx) => pageFooter('Supplementary Information — PA Act 194'),
      build: (ctx) => [
        sectionHeader(
            'SUPPLEMENTARY INFORMATION — PA Act 194 (20 Pa.C.S. Chapter 58)'),
        pw.SizedBox(height: 6),
        pw.Text(
          'The following summarizes key statutory provisions that the official '
          'form does not restate. It is provided for information only and is '
          'not legal or medical advice — consult a licensed Pennsylvania '
          'attorney about your situation.',
          style: bodyStyle(fontSize: 8),
        ),
        pw.SizedBox(height: 8),

        // ── 1 · Your rights and what providers must do ─────────────────
        sectionHeader('1 · Your rights and what providers must do'),
        pw.SizedBox(height: 4),
        item(
          'Providers must comply (§§ 5804, 5842)',
          'Attending physicians and mental health care providers must comply '
              'with your directive, and with your agent\'s decisions to the '
              'same extent as if you had made them. A provider who cannot '
              'comply must promptly tell you (or your agent/guardian), '
              'document the reasons, make every reasonable effort to assist '
              'a transfer to a provider who will comply — and treat you '
              'consistently with the directive while the transfer is pending.',
        ),
        item(
          'Asking about your directive (§ 5807)',
          'Providers must ask whether you have a directive when you come into '
              'their care, and may NOT require you to make (or forgo) one as '
              'a condition of receiving treatment or insurance.',
        ),
        item(
          'Emergencies and involuntary treatment (§ 5843(a))',
          'Your directive governs your voluntary mental health care. It does '
              'not change the separate standards for involuntary emergency '
              'examination and treatment under the Mental Health Procedures '
              'Act (50 P.S. §§ 7302–7304) — treatment over your refusal is '
              'only available through those involuntary-commitment '
              'procedures, with their own protections.',
        ),
        item(
          'Urgent court review (§ 5843(d))',
          'If following the directive could cause irreparable harm or death, '
              'an interested party may petition the orphans\' court, which '
              'must issue an order within 72 hours.',
        ),
        pw.SizedBox(height: 4),

        // ── 2 · Your agent ─────────────────────────────────────────────
        sectionHeader('2 · Your agent'),
        pw.SizedBox(height: 4),
        item(
          'Your agent decides as YOU would (§ 5836(d))',
          'Your agent must make the decision you would make if you were able '
              '— guided by your instructions and known preferences, after '
              'consulting your providers about prognosis, alternatives and '
              'side effects — not what the agent personally thinks is best.',
        ),
        item(
          'Records access (§ 5836(e))',
          'Your agent has the same rights as you to request, examine, copy, '
              'and consent (or refuse consent) to disclosure of your mental '
              'health records — but may not disclose them except as needed '
              'to carry out the agent\'s duties.',
        ),
        item(
          'Hard limits on agent authority (§ 5836(b)–(c))',
          'No agent can ever consent to psychosurgery or the termination of '
              'parental rights. Electroconvulsive therapy, experimental '
              'procedures, and research require your SPECIFIC authorization '
              'in the directive (the initialed items on the form).',
        ),
        item(
          'Removing an agent (§§ 5837, 5806)',
          'An agent can be removed for incapacity, willful noncompliance '
              'with your directive, assault or threats against you, coercion, '
              'voluntary withdrawal, or divorce. Interested parties may '
              'challenge an agent in the orphans\' court, and an agent who '
              'willfully fails to comply may be removed and liable for '
              'damages.',
        ),
        item(
          'Divorce (§ 5838)',
          'If your agent is your spouse, the designation is automatically '
              'revoked the moment either of you files for divorce — unless '
              'your power of attorney clearly says it should continue.',
        ),
        item(
          'If a court appoints a guardian (§ 5841)',
          'Your mental health power of attorney stays effective even after a '
              'guardianship adjudication, and the court is directed to prefer '
              'letting your agent continue making your mental health '
              'decisions. A guardian is bound by the same obligations as an '
              'agent.',
        ),
        pw.SizedBox(height: 4),

        // ── 3 · Your directive's legal force ───────────────────────────
        sectionHeader('3 · Your directive\'s legal force'),
        pw.SizedBox(height: 4),
        item(
          'If documents conflict (§ 5844)',
          'Between conflicting mental health instruments, the one signed '
              'latest controls. A mental health power of attorney ALWAYS '
              'prevails over a general power of attorney, regardless of '
              'which was signed first.',
        ),
        item(
          'Out-of-state documents (§ 5845)',
          'A mental health power of attorney executed in another state is '
              'valid in Pennsylvania if it conforms to that state\'s law, '
              'unless the agent\'s decisions would conflict with '
              'Pennsylvania law.',
        ),
        item(
          'Tampering is a crime (§ 5806)',
          'Concealing, altering, forging, or destroying a directive without '
              'consent — or causing one to be signed or revoked through '
              'fraud, duress, or undue influence — is a felony of the third '
              'degree.',
        ),
      ],
    ),
  ];
}
