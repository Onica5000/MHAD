import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Editorial voice-record bottom sheet — matches prototype `ScrVoice`
/// (mobile-extra.jsx L2219-2323).
///
/// Returns the dictated text on confirm, or `null` on cancel. The caller
/// (typically `VoiceInputButton`) appends the returned text to its
/// `TextEditingController`.
///
/// Layout (top → bottom):
///   - Drag handle
///   - "● Recording" primary SectionLabel
///   - Italic 28pt "Say it your way."
///   - Muted body "We'll transcribe locally — you can edit before saving."
///   - 19-bar animated waveform (4px bars with random heights pulsing
///     while listening — speech_to_text doesn't expose raw audio levels
///     so this is decorative pulsation)
///   - Monospace 22pt timer (m:ss)
///   - Live caption card: confirmed text in normal weight, in-flight
///     partial transcript in italic muted, blinking cursor at end
///   - Three circular controls: Cancel (52pt surface) · Record/Stop
///     (76pt crisis-accent toggle) · Confirm (52pt primary check)
///   - Monospace footer "AUDIO ISN'T SAVED · TRANSCRIPT STAYS IN THIS
///     SESSION"
Future<String?> showVoiceRecordOverlay(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isDismissible: false, // require explicit Cancel / Confirm
    enableDrag: false,
    builder: (_) => const _VoiceRecordSheet(),
  );
}

class _VoiceRecordSheet extends StatefulWidget {
  const _VoiceRecordSheet();

  @override
  State<_VoiceRecordSheet> createState() => _VoiceRecordSheetState();
}

class _VoiceRecordSheetState extends State<_VoiceRecordSheet>
    with SingleTickerProviderStateMixin {
  final _speech = stt.SpeechToText();
  late final AnimationController _pulse;
  Timer? _ticker;

  bool _initialized = false;
  bool _available = false;
  bool _listening = false;
  Duration _elapsed = Duration.zero;
  DateTime? _startedAt;

  // Confirmed (final) transcript pieces joined with spaces; partial holds
  // the in-flight provisional result that re-renders on every callback.
  final List<String> _confirmed = [];
  String _partial = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulse.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _start() async {
    if (!_initialized) {
      _available = await _speech.initialize(
        onError: (e) {
          if (!mounted) return;
          setState(() {
            _listening = false;
            _error = 'Speech recognition error.';
          });
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _listening = false);
            _ticker?.cancel();
          }
        },
      );
      _initialized = true;
      if (!_available) {
        if (mounted) {
          setState(() => _error =
              'Speech recognition is not available on this device.');
        }
        return;
      }
    }
    setState(() {
      _listening = true;
      _startedAt = DateTime.now();
      _error = null;
    });
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted || _startedAt == null) return;
      setState(() => _elapsed = DateTime.now().difference(_startedAt!));
    });
    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        if (result.finalResult) {
          setState(() {
            _confirmed.add(result.recognizedWords.trim());
            _partial = '';
          });
        } else {
          setState(() => _partial = result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 5),
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
      ),
    );
  }

  Future<void> _stop() async {
    if (_listening) {
      await _speech.stop();
    }
    _ticker?.cancel();
    if (mounted) {
      setState(() => _listening = false);
    }
  }

  void _onCancel() {
    _stop();
    Navigator.of(context).pop();
  }

  Future<void> _onConfirm() async {
    await _stop();
    // Promote any in-flight partial into the confirmed list before exit
    // (the user clearly wanted everything they spoke).
    final pieces = [..._confirmed];
    if (_partial.trim().isNotEmpty) pieces.add(_partial.trim());
    final joined = pieces.where((p) => p.isNotEmpty).join(' ').trim();
    if (mounted) Navigator.of(context).pop(joined.isEmpty ? null : joined);
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _stop();
    } else {
      await _start();
    }
  }

  String _timer() {
    final m = _elapsed.inMinutes;
    final s = _elapsed.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DesignTokens.sheetRadius),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(0, 14, 0, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: p.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  SectionLabel(
                    _error != null
                        ? '● ${_error!.toUpperCase()}'
                        : (_listening ? '● Recording' : '● Paused'),
                    style: TextStyle(
                      color: _error != null
                          ? Theme.of(context).colorScheme.error
                          : (_listening ? p.primary : p.textMuted),
                    ),
                  ),
                  Text(
                    'Say it your way.',
                    style: TextStyle(
                      fontFamily: 'Instrument Serif',
                      fontFamilyFallback: const ['Georgia', 'serif'],
                      fontStyle: FontStyle.italic,
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.5,
                      color: p.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "We'll transcribe locally — you can edit before saving.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.5,
                      height: 1.5,
                      color: p.textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 19-bar waveform — animated only while listening.
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, _) => _Waveform(
                      pulse: _pulse.value,
                      active: _listening,
                      activeColor: p.primary,
                      restColor: p.border,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _timer(),
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace',
                      ],
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: p.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LiveCaption(
                    confirmed: _confirmed.join(' '),
                    partial: _partial,
                    cursorColor: p.primary,
                    textColor: p.text,
                    mutedColor: p.textMuted,
                    borderColor: p.border,
                    surface: p.surface,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleButton(
                    size: 52,
                    label: 'Cancel',
                    bg: p.surface,
                    border: p.border,
                    fg: p.textMuted,
                    onTap: _onCancel,
                    semantics: 'Cancel voice recording',
                  ),
                  const SizedBox(width: 26),
                  _RecordCircle(
                    listening: _listening,
                    onTap: _toggleListening,
                    crisisAccent: Theme.of(context).colorScheme.error,
                    cardColor: p.card,
                  ),
                  const SizedBox(width: 26),
                  _CircleButton(
                    size: 52,
                    icon: Icons.check,
                    bg: p.primary,
                    border: p.primary,
                    fg: p.onPrimary,
                    onTap: _onConfirm,
                    semantics: 'Confirm and use transcript',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              "AUDIO ISN'T SAVED · TRANSCRIPT STAYS IN THIS SESSION",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontFamilyFallback: const [
                  'Consolas',
                  'Menlo',
                  'Courier New',
                  'monospace',
                ],
                fontSize: 10.5,
                letterSpacing: 0.5,
                color: p.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  final double pulse; // 0..1 from the SingleTickerProviderStateMixin
  final bool active;
  final Color activeColor;
  final Color restColor;

  const _Waveform({
    required this.pulse,
    required this.active,
    required this.activeColor,
    required this.restColor,
  });

  static const _baseHeights = <double>[
    12, 28, 18, 44, 36, 52, 30, 58, 42, 24, 38, 50, 22, 46, 32, 18, 40, 26, 12,
  ];

  @override
  Widget build(BuildContext context) {
    // Decorative pulse: each bar's height oscillates around its base by
    // ±25% × pulse × active-flag. When idle the bars sit at base height.
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _baseHeights.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: _bar(i),
            ),
        ],
      ),
    );
  }

  Widget _bar(int i) {
    final base = _baseHeights[i];
    // Phase-offset each bar so they don't all peak in sync.
    final phaseOffset = math.sin((pulse * math.pi * 2) + (i * 0.42));
    final scale = active ? (1 + 0.25 * phaseOffset) : 1.0;
    final height = (base * scale).clamp(8.0, 64.0);
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: active ? activeColor : restColor,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

class _LiveCaption extends StatefulWidget {
  final String confirmed;
  final String partial;
  final Color cursorColor;
  final Color textColor;
  final Color mutedColor;
  final Color borderColor;
  final Color surface;

  const _LiveCaption({
    required this.confirmed,
    required this.partial,
    required this.cursorColor,
    required this.textColor,
    required this.mutedColor,
    required this.borderColor,
    required this.surface,
  });

  @override
  State<_LiveCaption> createState() => _LiveCaptionState();
}

class _LiveCaptionState extends State<_LiveCaption>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasContent =
        widget.confirmed.isNotEmpty || widget.partial.isNotEmpty;
    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: widget.surface,
        border: Border.all(color: widget.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            if (widget.confirmed.isNotEmpty)
              TextSpan(
                text: '"${widget.confirmed}',
                style: TextStyle(color: widget.textColor),
              )
            else if (!hasContent)
              TextSpan(
                text: 'Tap the red record button and start speaking…',
                style: TextStyle(
                  color: widget.mutedColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            if (widget.partial.isNotEmpty) ...[
              if (widget.confirmed.isNotEmpty) const TextSpan(text: ' '),
              TextSpan(
                text: widget.partial,
                style: TextStyle(
                  color: widget.mutedColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (widget.confirmed.isNotEmpty || widget.partial.isNotEmpty)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: AnimatedBuilder(
                  animation: _blink,
                  builder: (_, _) => Opacity(
                    opacity: _blink.value,
                    child: Container(
                      width: 2,
                      height: 14,
                      margin: const EdgeInsets.only(left: 2),
                      color: widget.cursorColor,
                    ),
                  ),
                ),
              ),
            if (widget.confirmed.isNotEmpty)
              const TextSpan(text: '"'),
          ],
        ),
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13.5,
          height: 1.5,
          color: widget.textColor,
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final double size;
  final String? label;
  final IconData? icon;
  final Color bg;
  final Color border;
  final Color fg;
  final VoidCallback onTap;
  final String semantics;

  const _CircleButton({
    required this.size,
    required this.bg,
    required this.border,
    required this.fg,
    required this.onTap,
    required this.semantics,
    this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantics,
      child: Material(
        color: bg,
        shape: CircleBorder(side: BorderSide(color: border, width: 1)),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 22, color: fg)
                  : Text(
                      label!,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordCircle extends StatelessWidget {
  final bool listening;
  final VoidCallback onTap;
  final Color crisisAccent;
  final Color cardColor;

  const _RecordCircle({
    required this.listening,
    required this.onTap,
    required this.crisisAccent,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: listening ? 'Stop recording' : 'Start recording',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: crisisAccent,
            shape: BoxShape.circle,
            boxShadow: [
              // Outer halo per prototype L2305 — a 4px card-color ring +
              // 6px crisis-accent ring at 25% alpha.
              BoxShadow(
                color: cardColor,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: crisisAccent.withValues(alpha: 0.25),
                spreadRadius: 6,
              ),
            ],
          ),
          child: Center(
            child: listening
                // White square = "stop" when listening
                ? Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                // White circle = "record" when paused
                : Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
