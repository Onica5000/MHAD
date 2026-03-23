import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mhad/utils/platform_utils.dart';

/// Result from the document picker bottom sheet.
class PickedDocument {
  final String path;
  final String mimeType;
  final Uint8List? bytes;

  const PickedDocument({required this.path, required this.mimeType, this.bytes});
}

/// Shows a picker for document import. Uses a bottom sheet on mobile
/// and a centered dialog on desktop for better UX.
Future<List<PickedDocument>?> showDocumentPickerSheet(BuildContext context) {
  final content = _DocumentPickerContent();

  if (platformIsDesktop) {
    return showDialog<List<PickedDocument>>(
      context: context,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: content,
        ),
      ),
    );
  }

  return showModalBottomSheet<List<PickedDocument>>(
    context: context,
    builder: (_) => content,
  );
}

class _DocumentPickerContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Import from Document',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Choose a medication list, discharge summary, or other '
              'medical document. You can select multiple pages.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          // Camera and gallery only on mobile — on desktop/web, use file picker
          if (platformIsMobile) ...[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photos'),
              subtitle: const Text('Photograph one or more pages'),
              onTap: () => _pickMultiplePhotos(context),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select one or more images'),
              onTap: () => _pickFromGallery(context),
            ),
          ],
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(platformIsMobile ? 'Pick Files' : 'Choose Files'),
            subtitle: Text(platformIsMobile
                ? 'PDF, text, or image files (multi-select)'
                : 'PDF, photos, text, or image files (multi-select)'),
            onTap: () => _pickFiles(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Camera: take photos one at a time, keep going until user cancels.
Future<void> _pickMultiplePhotos(BuildContext context) async {
  final picker = ImagePicker();
  final docs = <PickedDocument>[];

  while (true) {
    try {
      final image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );
      if (image == null) break; // user cancelled = done taking photos
      final imageBytes = await image.readAsBytes();
      docs.add(PickedDocument(
        path: image.path,
        mimeType: _imageMimeType(image.path),
        bytes: imageBytes,
      ));

      if (!context.mounted) break;

      // Ask if they want to take another
      final more = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('${docs.length} page${docs.length == 1 ? '' : 's'} captured'),
          content: const Text('Take another page?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Done'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Next Page'),
            ),
          ],
        ),
      );
      if (more != true) break;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
      break;
    }
  }

  if (docs.isNotEmpty && context.mounted) {
    Navigator.pop(context, docs);
  } else if (context.mounted) {
    Navigator.pop(context);
  }
}

/// Gallery: pick multiple images at once.
Future<void> _pickFromGallery(BuildContext context) async {
  final picker = ImagePicker();
  try {
    final images = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 75,
    );
    if (images.isEmpty) {
      if (context.mounted) Navigator.pop(context);
      return;
    }

    final docs = <PickedDocument>[];
    for (final img in images) {
      final imgBytes = await img.readAsBytes();
      docs.add(PickedDocument(
        path: img.path,
        mimeType: _imageMimeType(img.path),
        bytes: imgBytes,
      ));
    }

    if (context.mounted) Navigator.pop(context, docs);
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gallery error: $e')),
      );
    }
  }
}

/// File picker: supports multi-select for all supported types.
Future<void> _pickFiles(BuildContext context) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'csv', 'jpg', 'jpeg', 'png', 'webp'],
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) {
      if (context.mounted) Navigator.pop(context);
      return;
    }

    final docs = <PickedDocument>[];
    for (final f in result.files) {
      if (f.path != null || f.bytes != null) {
        docs.add(PickedDocument(
          path: f.path ?? f.name,
          mimeType: _fileMimeType(f.name),
          bytes: f.bytes,
        ));
      }
    }

    if (docs.isNotEmpty && context.mounted) {
      Navigator.pop(context, docs);
    } else if (context.mounted) {
      Navigator.pop(context);
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File picker error: $e')),
      );
    }
  }
}

String _imageMimeType(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}

String _fileMimeType(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.txt')) return 'text/plain';
  if (lower.endsWith('.csv')) return 'text/csv';
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  return 'application/octet-stream';
}
