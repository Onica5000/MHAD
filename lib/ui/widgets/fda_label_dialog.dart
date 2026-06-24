import 'package:flutter/material.dart';
import 'package:mhad/services/openfda_service.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Shows the official FDA drug-label text for [medName] — the "Adverse
/// Reactions" (side effects) and "Drug Interactions" sections, pulled directly
/// from openFDA. This needs **no AI** (no Gemini key), so it's available to
/// every user, including those who decline AI: it's authoritative reference
/// text, displayed verbatim rather than AI-summarized.
///
/// Reference only — not medical advice; framed that way in the body. Degrades
/// to a "nothing found" message when the FDA has no label for the drug (or the
/// lookup failed).
Future<void> showFdaLabelDialog(
  BuildContext context, {
  required String medName,
}) {
  const kSans = kSansFamily;
  // One combined lookup so the dialog has a single loading state.
  final future = () async {
    final results = await Future.wait([
      OpenFdaService.adverseReactions(medName),
      OpenFdaService.drugInteractions(medName),
    ]);
    return (sideEffects: results[0], interactions: results[1]);
  }();

  return showDialog<void>(
    context: context,
    builder: (ctx) {
      final p = Theme.of(ctx).mhadPalette;

      Widget section(String heading, String body) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(heading,
                  style: const TextStyle(
                      fontFamily: kSans,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                body,
                style: TextStyle(
                    fontFamily: kSans,
                    fontSize: 12.5,
                    height: 1.45,
                    color: p.text),
              ),
              const SizedBox(height: 14),
            ],
          );

      return AlertDialog(
        title: Text('$medName — FDA label',
            style: const TextStyle(fontFamily: kSans)),
        content: SizedBox(
          width: 460,
          child: FutureBuilder<({String? sideEffects, String? interactions})>(
            future: future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final side = snap.data?.sideEffects;
              final inter = snap.data?.interactions;
              if ((side == null || side.isEmpty) &&
                  (inter == null || inter.isEmpty)) {
                return Text(
                  'No FDA label information is available for this medication '
                  'right now. Brand and generic spellings can differ — try the '
                  'other one, or ask your pharmacist.',
                  style: TextStyle(
                      fontFamily: kSans, fontSize: 13, color: p.textMuted),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (side != null && side.isNotEmpty)
                      section('Adverse reactions (side effects)', side),
                    if (inter != null && inter.isNotEmpty)
                      section('Drug interactions', inter),
                    Text(
                      'Official U.S. FDA drug-label text (openFDA). Reference '
                      'only — not medical advice, and not personalized to you. '
                      'Discuss anything here with your doctor or pharmacist.',
                      style: TextStyle(
                        fontFamily: kSans,
                        fontSize: 10.5,
                        fontStyle: FontStyle.italic,
                        color: p.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
