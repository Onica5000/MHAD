import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ui/wizard/widgets/document_import_sheet.dart';

/// Session-scoped, in-memory list of documents brought into the Snap-to-fill
/// flow (picked / dropped / pasted / snapped).
///
/// It lives at the root [ProviderScope] rather than inside the upload page's
/// widget State so the held files SURVIVE navigating from the upload page into
/// the wizard (which disposes that screen) and back. The upload page ("Have a
/// photo handy") reads this to show an always-visible list of every document
/// kept this session — whether or not it has been read by the AI yet — instead
/// of the list vanishing the moment the screen is disposed.
///
/// Web is in-memory only: the list clears on tab close / refresh. Documents are
/// held here until the user explicitly removes one or taps "Clear all".
class KeptDocumentsNotifier extends Notifier<List<PickedDocument>> {
  @override
  List<PickedDocument> build() => const [];

  /// Append newly added documents, de-duplicating by name + byte length so
  /// re-picking the same file doesn't create a duplicate.
  void addAll(List<PickedDocument> docs) {
    if (docs.isEmpty) return;
    final next = [...state];
    for (final d in docs) {
      final dup = next.any((e) =>
          _name(e) == _name(d) &&
          (e.bytes?.length ?? -1) == (d.bytes?.length ?? -2));
      if (!dup) next.add(d);
    }
    state = next;
  }

  void remove(PickedDocument doc) => state = [...state]..remove(doc);

  void clear() => state = const [];

  static String _name(PickedDocument d) =>
      d.path.replaceAll('\\', '/').split('/').last;
}

final keptDocumentsProvider =
    NotifierProvider<KeptDocumentsNotifier, List<PickedDocument>>(
  KeptDocumentsNotifier.new,
);
