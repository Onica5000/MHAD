import 'package:pdf/widgets.dart' as pw;
import 'pdf_helpers.dart';

/// Builds a printable checklist and notes page with checkboxes and blank lines.
List<pw.Page> buildNotesPages() {
  return [
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader('Checklist & Notes'),
          sectionHeader('YOUR MHAD CHECKLIST & NOTES'),
          pw.SizedBox(height: 8),

          // Distribution checklist
          partHeader('Distribution — Who Should Get Copies'),
          checkRow('My designated agent'),
          checkRow('My alternate agent'),
          checkRow('My attending physician / psychiatrist'),
          checkRow('My therapist / counselor'),
          checkRow('My local hospital'),
          checkRow('Family members'),
          checkRow('Close friends in my support network'),
          checkRow('Clergy / spiritual advisor'),
          checkRow('My attorney'),
          checkRow('Kept one copy with my important papers'),
          pw.SizedBox(height: 8),

          // Storage
          partHeader('Storage Reminders'),
          checkRow('Original is in a safe, easy-to-find place'),
          checkRow('Agent and alternate agent know where the original is'),
          checkRow('NOT in a safety deposit box'),
          checkRow('Scanned copy stored online or digitally'),
          checkRow('Made multiple copies'),
          pw.SizedBox(height: 8),

          // Capacity letter
          partHeader('Capacity Protection'),
          checkRow('Obtained letter from treating doctor confirming capacity at time of execution'),
          pw.SizedBox(height: 8),

          // Discussion
          partHeader('Discussions Completed'),
          checkRow('Discussed preferences with my agent'),
          checkRow('Discussed preferences with my attending physician'),
          checkRow('Discussed with family members'),
          pw.SizedBox(height: 8),

          // Renewal
          partHeader('Renewal Planning'),
          checkRow('Marked calendar for 2-year expiration date'),
          checkRow('Plan to review and re-execute before expiration'),
          pw.SizedBox(height: 10),

          // Notes section with blank lines
          partHeader('Personal Notes'),
          ...List.generate(8, (_) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Container(
              width: double.infinity,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: kDarkGrey, width: 0.3),
                ),
              ),
              height: 18,
            ),
          )),

          pw.Spacer(),
          pageFooter('Checklist & Notes'),
        ],
      ),
    ),
  ];
}
