import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mhad/utils/platform_utils.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// A microphone button that appends dictated text to a [TextEditingController].
/// Designed for narrative text fields (effective condition, additional
/// instructions, agent authority limitations, etc.).
class VoiceInputButton extends StatefulWidget {
  final TextEditingController controller;

  const VoiceInputButton({required this.controller, super.key});

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _available = false;
  bool _checkedAvailability = false;

  Future<void> _checkAvailability() async {
    if (_checkedAvailability) return;
    _available = await _speech.initialize(
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
    );
    _checkedAvailability = true;
  }

  Future<void> _toggleListening() async {
    await _checkAvailability();
    if (!_available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Speech recognition is not available on this device.')),
        );
      }
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            final existing = widget.controller.text;
            final space = existing.isNotEmpty && !existing.endsWith(' ')
                ? ' '
                : '';
            widget.controller.text = '$existing$space${result.recognizedWords}';
            widget.controller.selection = TextSelection.collapsed(
                offset: widget.controller.text.length);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
        ),
      );
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // On web, show a disabled button with tooltip instead of hiding
    if (kIsWeb) {
      return Tooltip(
        message: 'Voice input available on mobile only',
        child: IconButton(
          icon: Icon(
            Icons.mic_none,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          onPressed: null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      );
    }

    // speech_to_text only works on Android, iOS, and macOS
    if (!platformIsAndroid && !platformIsIOS && !platformIsMacOS) {
      return const SizedBox.shrink();
    }

    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: _isListening ? 'Stop dictation' : 'Start voice dictation',
      child: Tooltip(
        message: _isListening ? 'Tap to stop' : 'Dictate text',
        child: IconButton(
          icon: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            size: 20,
            color: _isListening ? cs.error : cs.onSurfaceVariant,
          ),
          onPressed: _toggleListening,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ),
    );
  }
}
