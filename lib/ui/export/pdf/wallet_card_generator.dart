/// Generates a credit-card-sized (3.375" x 2.125") printable wallet card
/// summarizing the principal's PA Mental Health Advance Directive.
///
/// The card includes the principal's name, agent contact info, execution
/// and expiration dates, and a reference to PA Act 194 of 2004.
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

    final executionDate = directive.executionDate != null
        ? DateTime.fromMillisecondsSinceEpoch(directive.executionDate!)
            .toString()
            .split(' ')
            .first
        : null;

    final expirationDate = directive.expirationDate != null
        ? DateTime.fromMillisecondsSinceEpoch(directive.expirationDate!)
            .toString()
            .split(' ')
            .first
        : null;

    // Determine the best phone number for the agent
    final agentPhone = _bestPhone(primaryAgent);

    pdf.addPage(
      pw.Page(
        pageFormat: _cardFormat,
        margin: const pw.EdgeInsets.all(8),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: kTeal, width: 1.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header bar
                pw.Container(
                  width: double.infinity,
                  color: kTeal,
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6, vertical: 3),
                  child: pw.Center(
                    child: pw.Text(
                      'PA Mental Health Advance Directive',
                      style: pw.TextStyle(
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),

                pw.SizedBox(height: 5),

                // Principal name
                _labelValue('Principal', directive.fullName),

                pw.SizedBox(height: 3),

                // Agent info (if designated)
                if (primaryAgent != null) ...[
                  _labelValue('Agent', primaryAgent.fullName),
                  if (agentPhone.isNotEmpty)
                    _labelValue('Agent Phone', agentPhone),
                  pw.SizedBox(height: 3),
                ],

                // Dates row
                pw.Row(
                  children: [
                    if (executionDate != null)
                      pw.Expanded(
                        child: _labelValue('Executed', executionDate),
                      ),
                    if (expirationDate != null)
                      pw.Expanded(
                        child: _labelValue('Expires', expirationDate),
                      ),
                    if (expirationDate == null && executionDate != null)
                      pw.Expanded(
                        child: _labelValue('Expires', 'Not specified'),
                      ),
                  ],
                ),

                pw.Spacer(),

                // "Full directive on file" line
                if (primaryAgent != null)
                  pw.Text(
                    'Full directive on file with: ${primaryAgent.fullName}',
                    style: pw.TextStyle(
                      fontSize: 6,
                      fontStyle: pw.FontStyle.italic,
                      color: kDarkGrey,
                    ),
                  ),

                pw.SizedBox(height: 2),

                // Legal reference footer
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'PA Act 194 of 2004',
                      style: pw.TextStyle(fontSize: 5.5, color: kDarkGrey),
                    ),
                    pw.Text(
                      'Carry this card with you at all times',
                      style: pw.TextStyle(
                        fontSize: 5,
                        fontStyle: pw.FontStyle.italic,
                        color: kDarkGrey,
                      ),
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

  /// Picks the best available phone number from an agent record.
  static String _bestPhone(Agent? agent) {
    if (agent == null) return '';
    if (agent.cellPhone.isNotEmpty) return agent.cellPhone;
    if (agent.homePhone.isNotEmpty) return agent.homePhone;
    if (agent.workPhone.isNotEmpty) return agent.workPhone;
    return '';
  }

  /// Small label + value widget for the wallet card.
  static pw.Widget _labelValue(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label: ',
            style: pw.TextStyle(
              fontSize: 6.5,
              fontWeight: pw.FontWeight.bold,
              color: kBlack,
            ),
          ),
          pw.TextSpan(
            text: value.isEmpty ? '---' : value,
            style: pw.TextStyle(fontSize: 6.5, color: kBlack),
          ),
        ],
      ),
    );
  }
}
