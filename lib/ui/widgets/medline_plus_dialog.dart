import 'package:flutter/material.dart';
import 'package:mhad/services/medline_plus_service.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/utils/launch_utils.dart';

/// Shows a plain-language MedlinePlus education dialog for [title], resolving
/// [future] (a condition or medication topic). Shared by the diagnoses and
/// medications wizard steps. Educational only — not medical advice; framed that
/// way in the body. Degrades to a "nothing available" message when MedlinePlus
/// has no topic (or the lookup failed).
Future<void> showMedlinePlusDialog(
  BuildContext context, {
  required String title,
  required Future<MedlinePlusTopic?> future,
}) {
  const kSans = kSansFamily;
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      final p = Theme.of(ctx).mhadPalette;
      return AlertDialog(
        title: Text(title, style: const TextStyle(fontFamily: kSans)),
        content: SizedBox(
          width: 420,
          child: FutureBuilder<MedlinePlusTopic?>(
            future: future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final topic = snap.data;
              if (topic == null) {
                return Text(
                  'No plain-language summary is available for this right now. '
                  'You can search it on MedlinePlus.',
                  style: TextStyle(
                      fontFamily: kSans, fontSize: 13, color: p.textMuted),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      topic.summary.isNotEmpty ? topic.summary : topic.title,
                      style: TextStyle(
                        fontFamily: kSans,
                        fontSize: 13,
                        height: 1.5,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Plain-language information from the U.S. National Library '
                      'of Medicine (MedlinePlus). Educational only — not medical '
                      'advice.',
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
          FutureBuilder<MedlinePlusTopic?>(
            future: future,
            builder: (context, snap) {
              final url = snap.data?.url ?? '';
              if (url.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => launchOrCopy(context, url),
                child: const Text('Read more on MedlinePlus'),
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
