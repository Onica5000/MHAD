import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mhad/ui/wizard/widgets/voice_record_overlay.dart';
import 'package:mhad/utils/platform_utils.dart';

/// A microphone button that opens an editorial voice-record overlay
/// (`voice_record_overlay.dart`) and appends the user's dictated text to
/// the supplied [TextEditingController]. Designed for narrative text
/// fields — effective condition, additional instructions, agent authority
/// limitations, etc.
///
/// Visual contract: the button itself is a 20pt mic icon inside a 48pt
/// tap target, matching the inline placement existing wizard steps
/// already use as a `suffixIcon` or trailing widget. Tapping opens the
/// full-screen editorial overlay which mirrors prototype `ScrVoice`
/// (mobile-extra.jsx::ScrVoice L2219-2323) — the prototype's animated
/// waveform / mono timer / live caption / 3-circle controls.
class VoiceInputButton extends StatelessWidget {
  final TextEditingController controller;

  const VoiceInputButton({required this.controller, super.key});

  Future<void> _openOverlay(BuildContext context) async {
    final text = await showVoiceRecordOverlay(context);
    if (text == null || text.isEmpty) return;
    final existing = controller.text;
    final space = existing.isNotEmpty && !existing.endsWith(' ') ? ' ' : '';
    controller.text = '$existing$space$text';
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);
  }

  @override
  Widget build(BuildContext context) {
    // Voice dictation works on Android, iOS, macOS, and web (Chrome/Edge/
    // Safari via the browser Web Speech API — speech_to_text 7.x ships a web
    // plugin). A browser without a speech service (e.g. Firefox) can't be
    // detected synchronously here, so we show the button and let the overlay's
    // `initialize()` report "not available" gracefully on tap.
    final supported =
        kIsWeb || platformIsAndroid || platformIsIOS || platformIsMacOS;
    if (!supported) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Open voice dictation',
      child: Tooltip(
        message: 'Dictate text',
        child: IconButton(
          icon: Icon(
            Icons.mic_none,
            size: 20,
            color: cs.onSurfaceVariant,
          ),
          onPressed: () => _openOverlay(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
      ),
    );
  }
}
