import 'dart:typed_data';

/// Wraps raw 16-bit little-endian mono PCM in a minimal WAV (RIFF) container so
/// the recorded audio can be sent to Gemini as `audio/wav`. [sampleRate] must
/// match how the PCM was captured (the recorder uses 16 kHz mono — the smallest
/// quality Gemini still analyzes well, since it downsamples to 16 kHz mono
/// internally anyway).
Uint8List pcm16ToWav(Uint8List pcm,
    {int sampleRate = 16000, int channels = 1}) {
  const bitsPerSample = 16;
  final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
  final blockAlign = channels * bitsPerSample ~/ 8;
  final dataLen = pcm.length;

  final b = BytesBuilder();
  void str(String s) => b.add(s.codeUnits);
  void u32(int v) =>
      b.add([v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF]);
  void u16(int v) => b.add([v & 0xFF, (v >> 8) & 0xFF]);

  str('RIFF');
  u32(36 + dataLen); // file length minus the first 8 bytes
  str('WAVE');
  str('fmt ');
  u32(16); // PCM fmt chunk size
  u16(1); // audio format = PCM
  u16(channels);
  u32(sampleRate);
  u32(byteRate);
  u16(blockAlign);
  u16(bitsPerSample);
  str('data');
  u32(dataLen);
  b.add(pcm);
  return b.toBytes();
}
