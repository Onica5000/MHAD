import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [uri] (e.g. a `tel:` number or an `https:` link). When the launch
/// isn't available — notably `tel:` on desktop and web, where there's no dialer
/// — it falls back to copying [copyValue] to the clipboard and showing a
/// SnackBar via [context]. Pass [copyValue] for phone numbers so web/desktop
/// users still get the number; omit it for web links that simply open.
///
/// [mode] forwards to [launchUrl] (use [LaunchMode.externalApplication] for
/// resource links that should leave the app).
///
/// This is the single chokepoint for every crisis / phone / resource tap so
/// the graceful-fallback behaviour is identical everywhere.
Future<void> launchOrCopy(
  BuildContext context,
  String uri, {
  String? copyValue,
  LaunchMode mode = LaunchMode.platformDefault,
}) async {
  final url = Uri.parse(uri);
  try {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: mode);
      return;
    }
  } catch (_) {
    // Fall through to the clipboard fallback below.
  }
  if (copyValue != null) {
    await Clipboard.setData(ClipboardData(text: copyValue));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$copyValue copied to clipboard')),
      );
    }
  }
}
