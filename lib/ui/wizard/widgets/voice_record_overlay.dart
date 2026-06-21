import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/audio_transcription_service.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/ai_consent_dialog.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/utils/wav.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Editorial voice-record bottom sheet — matches prototype `ScrVoice`
/// (mobile-extra.jsx L2219-2323).
///
/// Returns the dictated text on confirm, or `null` on cancel. The caller
/// (typically `VoiceInputButton`) appends the returned text to its
/// `TextEditingController`.
///
/// Two transcription modes:
///   - **AI mode** (when a Gemini key is set + the user consents): records the
///     audio and sends it to Gemini, which is far more accurate on clinical
///     terms (medication names, conditions) than the browser/OS speech service.
///   - **Live dictation fallback** (no AI, consent declined, or recording
///     unavailable): the browser/OS speech service with real-time captions —
///     the original behavior.
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

class _VoiceRecordSheet extends ConsumerStatefulWidget {
  const _VoiceRecordSheet();

  @override
  ConsumerState<_VoiceRecordSheet> createState() => _VoiceRecordSheetState();
}

class _VoiceRecordSheetState extends ConsumerState<_VoiceRecordSheet>
    with SingleTickerProviderStateMixin {
  final _speech = stt.SpeechToText();
  final _recorder = AudioRecorder();
  late final AnimationController _pulse;
  Timer? _ticker;

  // AI transcription state.
  String? _apiKey;
  bool _aiMode = false; // resolved on the first record start
  bool _transcribing = false;
  StreamSubscription<Uint8List>? _audioSub;
  final _pcm = BytesBuilder(copy: false);

  bool _speechInitialized = false;
  bool _listening = false;
  Duration _elapsed = Duration.zero;
  DateTime? _startedAt;

  // Confirmed (final) transcript pieces joined with spaces; partial holds the
  // in-flight provisional result (live-dictation mode only).
  final List<String> _confirmed = [];
  String _partial = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _apiKey = ref.read(apiKeyProvider).valueOrNull;
    _aiMode = _apiKey != null && _apiKey!.isNotEmpty;
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
    _audioSub?.cancel();
    _recorder.dispose();
    _speech.stop();
    super.dispose();
  }

  // ── Start / stop dispatch ───────────────────────────────────────────

  Future<void> _start() async {
    setState(() => _error = null);
    // AI mode requires consent (audio with personal details goes to Google).
    if (_aiMode && !ref.read(aiConsentGivenProvider)) {
      final ok = await showAudioConsentDialog(context);
      if (!mounted) return;
      if (ok) {
        ref.read(aiConsentGivenProvider.notifier).state = true;
      } else {
        _aiMode = false; // declined → fall back to live dictation
      }
    }
    if (_aiMode) {
      final started = await _startAiRecording();
      if (!started) _aiMode = false; // recording unavailable → fall back
    }
    if (!_aiMode) {
      await _startSpeech();
    }
  }

  Future<void> _stop() async {
    if (_aiMode) {
      await _stopAiRecording();
    } else {
      await _stopSpeech();
    }
  }

  void _beginTimer() {
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
  }

  // ── AI mode: record PCM → WAV → Gemini ──────────────────────────────

  Future<bool> _startAiRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        if (mounted) {
          setState(() => _error = 'Microphone permission is needed.');
        }
        return false;
      }
      _pcm.clear();
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      _audioSub = stream.listen((data) => _pcm.add(data));
      _beginTimer();
      return true;
    } catch (_) {
      return false; // caller falls back to live dictation
    }
  }

  Future<void> _stopAiRecording() async {
    try {
      await _recorder.stop();
    } catch (_) {/* ignore */}
    await _audioSub?.cancel();
    _audioSub = null;
    _ticker?.cancel();
    final pcm = _pcm.toBytes();
    if (!mounted) return;
    if (pcm.isEmpty) {
      setState(() => _listening = false);
      return;
    }
    setState(() {
      _listening = false;
      _transcribing = true;
    });
    try {
      final wav = pcm16ToWav(pcm);
      final text = await AudioTranscriptionService(_apiKey!).transcribe(wav);
      if (!mounted) return;
      setState(() {
        if (text.isNotEmpty) _confirmed.add(text);
        _transcribing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _transcribing = false;
        _error = "Couldn't transcribe. Try again, or type it instead.";
      });
    }
  }

  // ── Fallback: browser/OS live dictation ─────────────────────────────

  Future<void> _startSpeech() async {
    if (!_speechInitialized) {
      final available = await _speech.initialize(
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
      _speechInitialized = true;
      if (!available) {
        if (mounted) {
          setState(() => _error = kIsWeb
              ? 'Voice needs Chrome, Edge, or Safari.'
              : 'Speech recognition is not available on this device.');
        }
        return;
      }
    }
    _beginTimer();
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

  Future<void> _stopSpeech() async {
    if (_listening) {
      await _speech.stop();
    }
    _ticker?.cancel();
    if (mounted) setState(() => _listening = false);
  }

  // ── Controls ────────────────────────────────────────────────────────

  void _onCancel() {
    _stop();
    Navigator.of(context).pop();
  }

  Future<void> _onConfirm() async {
    await _stop();
    // Promote any in-flight partial (live mode) into the confirmed list.
    final pieces = [..._confirmed];
    if (_partial.trim().isNotEmpty) pieces.add(_partial.trim());
    final joined = pieces.where((p) => p.isNotEmpty).join(' ').trim();
    if (mounted) Navigator.of(context).pop(joined.isEmpty ? null : joined);
  }

  Future<void> _toggleListening() async {
    if (_transcribing) return; // busy
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

  String _statusLabel() {
    if (_error != null) return '● ${_error!.toUpperCase()}';
    if (_transcribing) return '● Transcribing';
    if (_listening) return '● Recording';
    return '● Paused';
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
                    _statusLabel(),
                    style: TextStyle(
                      color: _error != null
                          ? Theme.of(context).colorScheme.error
                          : (_listening || _transcribing
                              ? p.primary
                              : p.textMuted),
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
                    // Honest about where transcription happens. AI mode sends
                    // the recording to Google's Gemini; the fallback uses the
                    // browser/OS speech service (often Google on web too).
                    _aiMode
                        ? 'For better accuracy on medication names and '
                            "conditions, your recording goes to Google's AI to "
                            'transcribe. Review the text before saving.'
                        : (kIsWeb
                            ? 'To transcribe, your browser sends the audio to '
                                "its speech service (often Google). We don't "
                                'keep the audio or text — edit it before saving.'
                            : 'Your device turns speech into text. We never '
                                'store the audio — you can edit before saving.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 12.5,
                      height: 1.5,
                      color: p.textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      fontFamily: kMonoFamily,
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
                  _transcribing
                      ? _TranscribingCard(
                          textColor: p.textMuted,
                          borderColor: p.border,
                          surface: p.surface,
                          spinnerColor: p.primary,
                        )
                      : _LiveCaption(
                          confirmed: _confirmed.join(' '),
                          partial: _partial,
                          cursorColor: p.primary,
                          textColor: p.text,
                          mutedColor: p.textMuted,
                          borderColor: p.border,
                          surface: p.surface,
                          // AI mode has no live partials; prompt accordingly.
                          emptyHint: _aiMode
                              ? 'Tap the red button, speak, then tap stop to '
                                  'transcribe…'
                              : 'Tap the red record button and start speaking…',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _aiMode
                    ? "WE STORE NOTHING · GOOGLE'S AI TRANSCRIBES THE RECORDING"
                    : (kIsWeb
                        ? "WE STORE NOTHING · YOUR BROWSER'S SPEECH SERVICE TRANSCRIBES THE AUDIO"
                        : "AUDIO ISN'T SAVED · TRANSCRIPT STAYS IN THIS SESSION"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kMonoFamily,
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
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown in the caption slot while the AI transcribes the recorded clip.
class _TranscribingCard extends StatelessWidget {
  final Color textColor;
  final Color borderColor;
  final Color surface;
  final Color spinnerColor;

  const _TranscribingCard({
    required this.textColor,
    required this.borderColor,
    required this.surface,
    required this.spinnerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: spinnerColor),
          ),
          const SizedBox(width: 12),
          Text(
            'Transcribing your recording…',
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 13.5,
              color: textColor,
            ),
          ),
        ],
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
  final String emptyHint;

  const _LiveCaption({
    required this.confirmed,
    required this.partial,
    required this.cursorColor,
    required this.textColor,
    required this.mutedColor,
    required this.borderColor,
    required this.surface,
    required this.emptyHint,
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
                text: widget.emptyHint,
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
          fontFamily: kSansFamily,
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
                        fontFamily: kSansFamily,
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
