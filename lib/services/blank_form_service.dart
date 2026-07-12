import 'package:flutter/material.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/export/pdf/pdf_generator.dart';
import 'package:printing/printing.dart';

/// Produces the official PA MHAD form with every field empty, ready to print
/// and fill in by hand — WITHOUT creating a saved directive. "Print the blank
/// form" must hand the user a printable page, not drop them into the wizard.

/// An in-memory, all-fields-blank [Directive] for [type]. No database row is
/// created, so printing a blank form never leaves a directive behind in the
/// user's "Past directives". Status is a neutral 'blank' (not 'draft') so the
/// page is NOT stamped "DRAFT — UNSIGNED" — it's a clean template.
Directive _blankDirective(FormType type) => Directive(
      id: 0,
      formType: type.name,
      status: 'blank',
      createdAt: 0,
      updatedAt: 0,
      fullName: '',
      dateOfBirth: '',
      address: '',
      address2: '',
      city: '',
      county: '',
      state: '',
      zip: '',
      phone: '',
      effectiveCondition: '',
      triggerTwoProfessionals: false,
      triggerCourtOrder: false,
      triggerInvoluntaryCommitment: false,
      preferredDoctorName: '',
      preferredDoctorContact: '',
      primaryDoctorName: '',
      primaryDoctorSpecialty: '',
      primaryDoctorPhone: '',
      lastStepIndex: 0,
      displayLabel: '',
    );

/// Lets the user pick which of the three official forms to print blank
/// (2026-07-09 PDF audit, defect #8 — the UI previously offered only the
/// Combined form even though all three render). Prints on selection.
Future<void> showBlankFormPicker(BuildContext context) async {
  final type = await showDialog<FormType>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Print a blank form'),
      children: [
        for (final t in FormType.values)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, t),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(t.displayName),
            ),
          ),
      ],
    ),
  );
  if (type == null || !context.mounted) return;
  await printBlankForm(context, type: type);
}

/// Generates the blank form for [type] (Combined by default) and opens the
/// system print dialog (the browser print sheet on web). On failure shows a
/// snackbar rather than failing silently.
Future<void> printBlankForm(
  BuildContext context, {
  FormType type = FormType.combined,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final generator = PdfGenerator(
      includeCombined: type == FormType.combined,
      includeDeclaration: type == FormType.declaration,
      includePoa: type == FormType.poa,
    );
    final bytes = await generator.generate(
      directive: _blankDirective(type),
      agents: const [],
      prefs: null,
      additional: null,
      guardian: null,
      medications: const [],
      witnesses: const [],
      diagnoses: const [],
    );
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'PA-MHAD-blank-form.pdf',
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('Could not open the blank form to print: $e')),
    );
  }
}
