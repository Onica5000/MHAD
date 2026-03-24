/// Generates a credit-card-sized (3.375" x 2.125") printable wallet card
/// matching the official PA MHAD booklet front-page card format.
library;

import 'dart:typed_data';

import 'package:mhad/data/database/app_database.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_helpers.dart';

/// Credit-card dimensions: 3.375 x 2.125 inches at 72 DPI.
const _cardWidth = 3.375 * PdfPageFormat.inch;
const _cardHeight = 2.125 * PdfPageFormat.inch;

const _cardFormat = PdfPageFormat(_cardWidth, _cardHeight);

/// Generates a single-page wallet-card PDF from directive data.
///
/// Matches the official PA MHAD booklet cover card:
/// "I, [name], have executed an advance directive..."
class WalletCardGenerator {
  const WalletCardGenerator();

  Future<Uint8List> generate({
    required Directive directive,
    required List<Agent> agents,
  }) async {
    final pdf = pw.Document(
      title: 'PA MHAD Wallet Card',
      author: directive.fullName,
      subject: 'PA Mental Health Advance Directive — Wallet Card',
    );

    final primaryAgent =
        agents.where((a) => a.agentType == 'primary').firstOrNull;
    final agentPhone = _bestPhone(primaryAgent);

    // Format phone for display: xxx-xxx-xxxx
    final phoneDisplay = agentPhone.isNotEmpty
        ? agentPhone
        : '___-___-____';
    final agentName = primaryAgent?.fullName ?? '________________________';

    pdf.addPage(
      pw.Page(
        pageFormat: _cardFormat,
        margin: const pw.EdgeInsets.all(6),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: kTeal, width: 1.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  color: kTeal,
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6, vertical: 3),
                  child: pw.Center(
                    child: pw.Text(
                      'MENTAL HEALTH ADVANCE DIRECTIVE',
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),

                // Official card text matching the PA MHAD booklet
                pw.Text(
                  'I, ${directive.fullName.isNotEmpty ? directive.fullName : "_____________________"}, '
                  'have executed an advance directive specifying my decisions '
                  'about my mental health care.',
                  style: pw.TextStyle(fontSize: 6.5, height: 1.3),
                ),
                pw.SizedBox(height: 3),

                pw.Text(
                  'My Mental Health Care Agent is $agentName.',
                  style: pw.TextStyle(
                      fontSize: 6.5,
                      fontWeight: pw.FontWeight.bold,
                      height: 1.3),
                ),
                pw.SizedBox(height: 2),

                pw.Text(
                  'If I am hospitalized, my Agent should be immediately '
                  'contacted at $phoneDisplay.',
                  style: pw.TextStyle(fontSize: 6.5, height: 1.3),
                ),

                pw.Spacer(),

                // PA P&A contact (matches official card)
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Text(
                    'If the hospital has questions about its legal '
                    'responsibilities to honor my decisions, it should '
                    'contact Pennsylvania Protection and Advocacy at: '
                    '1-800-692-7443',
                    style: pw.TextStyle(
                      fontSize: 5.5,
                      fontStyle: pw.FontStyle.italic,
                      color: kDarkGrey,
                      height: 1.2,
                    ),
                  ),
                ),

                pw.SizedBox(height: 2),

                // Footer with dates and legal reference
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'PA Act 194 of 2004',
                      style: pw.TextStyle(fontSize: 5, color: kDarkGrey),
                    ),
                    if (directive.executionDate != null)
                      pw.Text(
                        'Executed: ${_fmtDate(directive.executionDate!)}',
                        style: pw.TextStyle(fontSize: 5, color: kDarkGrey),
                      ),
                    if (directive.expirationDate != null)
                      pw.Text(
                        'Expires: ${_fmtDate(directive.expirationDate!)}',
                        style: pw.TextStyle(fontSize: 5, color: kDarkGrey),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static String _bestPhone(Agent? agent) {
    if (agent == null) return '';
    if (agent.cellPhone.isNotEmpty) return agent.cellPhone;
    if (agent.homePhone.isNotEmpty) return agent.homePhone;
    if (agent.workPhone.isNotEmpty) return agent.workPhone;
    return '';
  }

  static String _fmtDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.month}/${d.day}/${d.year}';
  }
}
