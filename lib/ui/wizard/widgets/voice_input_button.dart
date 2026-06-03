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
    // On web, show a disabled button with tooltip instead of hiding —
    // matches prior behaviour. `speech_to_text` doesn't have web support.
    if (kIsWeb) {
      return Tooltip(
        message: 'Voice input available on mobile only',
        child: IconButton(
          icon: Icon(
            Icons.mic_none,
            size: 20,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.4),
          ),
          onPressed: null,
          padding: EdgeInsets.zero,
          // 48pt hit target meets the a11y guideline; the visible icon
          // stays at 20pt thanks to padding: EdgeInsets.zero.
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
      );
    }

    // speech_to_text only works on Android, iOS, and macOS.
    if (!platformIsAndroid && !platformIsIOS && !platformIsMacOS) {
      return const SizedBox.shrink();
    }

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
