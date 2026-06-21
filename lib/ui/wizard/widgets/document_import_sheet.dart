import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:mhad/utils/web_file_browse.dart';

/// Result from the document picker bottom sheet.
class PickedDocument {
  final String path;
  final String mimeType;
  final Uint8List? bytes;

  const PickedDocument({required this.path, required this.mimeType, this.bytes});
}

/// Opens the OS file picker and returns the chosen documents (PDF / text /
/// image, multi-select). Returns an empty list if cancelled. Used by the
/// full-page Snap-to-fill drop zone (no bottom sheet).
/// Returns null if the user cancelled the picker, an empty list if files
/// were selected but none could be read (no bytes), or the readable docs.
Future<List<PickedDocument>?> pickDocumentFiles() async {
  // On web, use a native <input type="file"> instead of file_picker, whose
  // web interop was throwing here ("couldn't open the file picker") even
  // though drag-and-drop worked. Native platforms keep using file_picker.
  if (kIsWeb) {
    const accept = '.pdf,.txt,.csv,.jpg,.jpeg,.png,.webp,.heic,.heif,'
        '.mp3,.m4a,.wav,.aac,.ogg,.oga,.flac';
    final picked = await browseWebFiles(accept: accept, multiple: true);
    if (picked == null) return null; // cancelled
    final docs = <PickedDocument>[];
    for (final f in picked) {
      final mime = _fileMimeType(f.name);
      if (mime == 'application/octet-stream') continue; // unsupported type
      docs.add(PickedDocument(path: f.name, mimeType: mime, bytes: f.bytes));
    }
    return docs;
  }

  // Native: file_picker with FileType.any + Dart-side extension filtering.
  final result = await FilePicker.platform.pickFiles(
    type: FileType.any,
    allowMultiple: true,
    // REQUIRED: load the file bytes into memory. On native (Android/iOS/
    // desktop) FilePicker returns only a path unless withData is set, and the
    // extraction pipeline reads `PickedDocument.bytes` — without this every
    // picked file was silently skipped. On web bytes are already loaded.
    withData: true,
  );
  if (result == null) return null; // cancelled
  final docs = <PickedDocument>[];
  for (final f in result.files) {
    // With withData:true, bytes are loaded on every platform (web preloads
    // them regardless). Skip anything that still has no bytes.
    if (f.bytes == null) continue;
    final mime = _fileMimeType(f.name);
    if (mime == 'application/octet-stream') continue; // unsupported extension
    docs.add(PickedDocument(
      path: f.path ?? f.name,
      mimeType: mime,
      bytes: f.bytes,
    ));
  }
  return docs;
}

/// Captures a single photo from the camera (webcam on mobile web). Returns an
/// empty list if cancelled.
Future<List<PickedDocument>> pickDocumentCameraPhoto() async {
  final picker = ImagePicker();
  final image = await picker.pickImage(
    source: ImageSource.camera,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 75,
  );
  if (image == null) return const [];
  final bytes = await image.readAsBytes();
  return [
    PickedDocument(
      path: image.path,
      mimeType: _imageMimeType(image.path),
      bytes: bytes,
    ),
  ];
}

String _imageMimeType(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
  return 'image/jpeg';
}

String _fileMimeType(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.txt')) return 'text/plain';
  if (lower.endsWith('.csv')) return 'text/csv';
  if (lower.endsWith('.png') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.heic') ||
      lower.endsWith('.heif') ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg')) {
    return _imageMimeType(lower);
  }
  final audio = _audioMimeType(lower);
  if (audio != null) return audio;
  return 'application/octet-stream';
}

/// Audio MIME type for a filename, or null if it isn't a supported audio file.
/// Limited to the formats Gemini accepts as inline audio so a spoken
/// description (conditions, medications, wishes) can be transcribed + extracted.
String? _audioMimeType(String lowerPath) {
  if (lowerPath.endsWith('.mp3')) return 'audio/mp3';
  if (lowerPath.endsWith('.wav')) return 'audio/wav';
  if (lowerPath.endsWith('.aac')) return 'audio/aac';
  if (lowerPath.endsWith('.flac')) return 'audio/flac';
  if (lowerPath.endsWith('.ogg') || lowerPath.endsWith('.oga')) {
    return 'audio/ogg';
  }
  // .m4a is AAC in an MP4 container (iOS/Android voice memos).
  if (lowerPath.endsWith('.m4a')) return 'audio/mp4';
  return null;
}
